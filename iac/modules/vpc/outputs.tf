output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.subnet_private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.subnet_public[*].id
}

output "sg_redis_id" {
  value = aws_security_group.vpc_redis_sg.id
}

output "vpc_cidr" {
  description = "VPC CIDRs"
  value       = aws_vpc.main_vpc.cidr_block
}

output "private_subnets_cidrs" {
  description = "CIDRs private subnets"
  value       = aws_subnet.subnet_private[*].cidr_block
}

output "public_subnets_cidrs" {
  description = "CIDRs public subnet"
  value       = aws_subnet.subnet_public[*].cidr_block
}

output "private_subnets_cidrs_dbs" {
  description = "CIDRs private Dbs subnets"
  value       = aws_subnet.subnet_private_dbs[*].cidr_block
}

output "db_subnet_group_name" {
  description = "Subnet Group DBs name"
  value       = aws_db_subnet_group.dbs.name
}
