region       = "us-east-1"
project_name = "challenge_infra"
environment  = "dev"
common_tags = {
  Project     = "challenge_infra"
  Environment = "dev"
  Owner       = "jpinilla"
}


vpc_cidr_all             = "0.0.0.0/0"
vpc_cidr                 = "10.20.0.0/16"
subnet_public_cidrs      = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
subnet_private_cidrs     = ["10.20.21.0/24", "10.20.22.0/24", "10.20.23.0/24"]
subnet_private_dbs_cidrs = ["10.20.41.0/24", "10.20.42.0/24", "10.20.43.0/24"]