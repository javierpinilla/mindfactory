variable "cluster_name" {
  description = "Nombre del cluster"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes, Posibles usos en el billing"
  type        = map(string)
}

variable "environment" {
  description = "Entorno"
  type        = string
}

variable "subnet_ids" {
  description = "Listado de subnets"
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_desired" {
  type    = number
  default = 1
}

variable "node_min" {
  type    = number
  default = 1
}

variable "node_max" {
  type    = number
  default = 1
}

variable "disk_size" {
  type    = number
  default = 30
}

variable "node_market_type" {
  type    = string
  default = "SPOT"
}

variable "spot_max_price" {
  description = "Precio maximo para spots. Esto no sé si sigue siendo requerido, me acuerdo de renegar bastante"
  type        = string
  default     = "0.03"
}

variable "kubernetes_version" {
  description = "Version EKS: aws eks describe-addon-versions | grep 'clusterVersion' | sort -nr | uniq | head -2 | sed 's/ //g'"
  type        = string
  default     = "1.32"
}