# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = local.vpc_name
  })
}

# Obtener AZs disponibles
data "aws_availability_zones" "vpc_az_zones" {
  state = "available"
}

# Subnets Publicas
resource "aws_subnet" "subnet_public" {
  count                   = 3
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_public_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.vpc_az_zones.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-public-subnet-${count.index + 1}"
  })
}

# Subnets Privadas.
resource "aws_subnet" "subnet_private" {
  count                   = 3
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_private_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.vpc_az_zones.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-private-subnet-${count.index + 1}"
  })
}

# Subnets Privadas para Rds, ElasticCache, etc o quesio
resource "aws_subnet" "subnet_private_dbs" {
  count                   = 3
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_private_dbs_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.vpc_az_zones.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-private-dbs-subnet-${count.index + 1}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-igw"
  })
}

# rt publicas
resource "aws_route_table" "sn_rt_public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = var.vpc_cidr_all
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-public-rt"
  })
}

# Asociar subnets publicas a las rt publicas
resource "aws_route_table_association" "sn_rta_public" {
  count          = 3
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.sn_rt_public.id
}

# Elastic IP para NAT Gateway
resource "aws_eip" "vpc_nat_eip" {
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-nateip"
  })
}

# NAT Gateway en la primera subnet public
resource "aws_nat_gateway" "vpc_natgw" {
  allocation_id = aws_eip.vpc_nat_eip.id
  subnet_id     = aws_subnet.subnet_public[0].id

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-natgw"
  })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_ec2_tag" "vpc_nat_eni_name" {
  key         = "Name"
  value       = "${local.vpc_name}-natgw-eni"
  resource_id = aws_nat_gateway.vpc_natgw.network_interface_id

  depends_on = [aws_nat_gateway.vpc_natgw]
}

# RT Privadas
resource "aws_route_table" "sn_rt_private" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block     = var.vpc_cidr_all
    nat_gateway_id = aws_nat_gateway.vpc_natgw.id
  }

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-private-rt"
  })
}

# Asociar subnets privadas a la rt privada
resource "aws_route_table_association" "sn_rta_private" {
  count          = 3
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.sn_rt_private.id
}

# Asociar subnets de dbs a la rt privada. Si quieren que estás subnets salgan a internet, descomentar
#resource "aws_route_table_association" "sn_rta_private_dbs" {
#  count          = 3
#  subnet_id      = aws_subnet.subnet_private_dbs[count.index].id
#  route_table_id = aws_route_table.sn_rt_private.id
#}

# DBS Subnets groups
resource "aws_db_subnet_group" "dbs" {
  name       = local.dbs_subnet_group_name
  subnet_ids = aws_subnet.subnet_private_dbs[*].id

  tags = merge(var.common_tags, {
    Name = local.dbs_subnet_group_name
  })
}

# Default ACLs
resource "aws_default_network_acl" "default_acl" {
  default_network_acl_id = aws_vpc.main_vpc.default_network_acl_id

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-default-acl"
  })
}

# Network ACL public subnets
resource "aws_network_acl" "vpc_subnet_public_nacl" {
  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = aws_subnet.subnet_public[*].id

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-public-subnet-nacl"
  })
}

resource "aws_network_acl_rule" "vpc_subnet_public_nacl_inbound" {
  network_acl_id = aws_network_acl.vpc_subnet_public_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_all
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "vpc_subnet_public_nacl_outbound" {
  network_acl_id = aws_network_acl.vpc_subnet_public_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_all
  from_port      = 0
  to_port        = 0
}

# Network ACL private subnets
resource "aws_network_acl" "vpc_subnet_private_nacl" {
  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = aws_subnet.subnet_private[*].id

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-private-subnet-nacl"
  })
}

# Reglas para NACL privada
resource "aws_network_acl_rule" "vpc_subnet_private_nacl_inbound" {
  network_acl_id = aws_network_acl.vpc_subnet_private_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_all
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "vpc_subnet_private_nacl_outbound" {
  network_acl_id = aws_network_acl.vpc_subnet_private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_all
  from_port      = 0
  to_port        = 0
}

# Network ACL DBS subnets
resource "aws_network_acl" "vpc_subnet_private_dbs_nacl" {
  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = aws_subnet.subnet_private_dbs[*].id

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-subnet-private-dbs-nacl"
  })
}

# NACL DBS
resource "aws_network_acl_rule" "vpc_subnet_private_dbs_nacl_inbound" {
  network_acl_id = aws_network_acl.vpc_subnet_private_dbs_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_all
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "vpc_subnet_private_dbs_nacl_outbound" {
  network_acl_id = aws_network_acl.vpc_subnet_private_dbs_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_all
  from_port      = 0
  to_port        = 0
}

resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  domain_name_servers = ["AmazonProvidedDNS"]
  domain_name         = "ec2.internal"

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-dhcp_options"
  })
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp_association" {
  vpc_id          = aws_vpc.main_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.vpc_dhcp_options.id
}

resource "aws_default_route_table" "main_rt" {
  default_route_table_id = aws_vpc.main_vpc.default_route_table_id

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-main-rt"
  })
}

# Security Group para ElasticCache
resource "aws_security_group" "vpc_redis_sg" {
  name        = "${local.vpc_name}-redis-sg"
  description = "Security group for ElasticCache"
  vpc_id      = aws_vpc.main_vpc.id

  # Acceso desde subnets privadas
  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    cidr_blocks = [
      var.subnet_private_cidrs[0],
      var.subnet_private_cidrs[1],
      var.subnet_private_cidrs[2],
      var.subnet_private_dbs_cidrs[0],
      var.subnet_private_dbs_cidrs[1],
      var.subnet_private_dbs_cidrs[2]
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_all]
  }

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-redis-sg"
  })
}