#terraform {
#  backend "s3" {
#    bucket       = "mindfactory-infra-state"
#    key          = "terraform/mindfactory/dev/terraform.tfstate"
#    region       = "us-east-2"
#    encrypt      = true
#    use_lockfile = true
#  }
#}

terraform {
  backend "local" {
    path = "state/terraform.tfstate"
  }
}