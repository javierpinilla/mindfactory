variable "region" {
  type        = string
  description = "AWS Region"
}

variable "project_name" {
  description = "Nombre del Proyecto"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos, se podría usar para el billing"
  type        = map(string)
}

variable "environment" {
  description = "Entorno"
  type        = string
}

variable "vpc_cidr_all" {
  description = "CIDR all (0.0.0.0/0)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
}

variable "subnet_public_cidrs" {
  description = "CIDR subnets publicas"
  type        = list(string)
}

variable "subnet_private_cidrs" {
  description = "CIDR subnets privadas"
  type        = list(string)
}

variable "subnet_private_dbs_cidrs" {
  description = "CIDR subnets privadas dbs"
  type        = list(string)
}