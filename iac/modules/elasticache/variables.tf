variable "cluster_name" {
  description = "Nombre del cluster Elasticache o Redis"
  type        = string
}

variable "subnet_group_name" {
  description = "name subnet group"
  type        = string
}

variable "node_type" {
  description = "Tipo de instancia de Redis"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Cantidad de nodos en el cluster"
  type        = number
  default     = 1
}

variable "common_tags" {
  description = "Tags comunes, Posibles usos en el billing"
  type        = map(string)
}

variable "environment" {
  description = "Entorno"
  type        = string
}

variable "sg_redis_id" {
  description = "id security group redis"
  type        = string
}