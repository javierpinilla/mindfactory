locals {
  vpc_name              = "${var.vpc_name}-${var.environment}-vpc"
  dbs_subnet_group_name = "${var.vpc_name}-${var.environment}-sgn"
}