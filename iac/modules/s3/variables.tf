variable "bucket_name" {
  description = "Nombre bucket"
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