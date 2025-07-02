module "vpc" {
  source = "./modules/vpc"

  vpc_name                 = var.project_name
  vpc_cidr                 = var.vpc_cidr
  vpc_cidr_all             = var.vpc_cidr_all
  subnet_public_cidrs      = var.subnet_public_cidrs
  subnet_private_cidrs     = var.subnet_private_cidrs
  subnet_private_dbs_cidrs = var.subnet_private_dbs_cidrs
  common_tags              = var.common_tags
  environment              = var.environment
}

module "eks" {
  source = "./modules/eks"

  cluster_name = var.project_name
  subnet_ids   = module.vpc.private_subnet_ids
  common_tags  = var.common_tags
  environment  = var.environment
}

module "elasticache" {
  source = "./modules/elasticache"

  cluster_name      = var.project_name
  subnet_group_name = module.vpc.db_subnet_group_name
  sg_redis_id       = module.vpc.sg_redis_id
  common_tags       = var.common_tags
  environment       = var.environment
}

module "s3_bucket" {
  source      = "./modules/s3"
  bucket_name = var.project_name
  environment = var.environment
  common_tags = var.common_tags
}
