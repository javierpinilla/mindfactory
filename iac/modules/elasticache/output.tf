output "elasticache_endpoint" {
  description = "Redis endpoint"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "elasticache_port" {
  description = "Redis port"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].port
}