# Redis Cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = local.cluster_name
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name    = var.subnet_group_name
  security_group_ids   = [var.sg_redis_id]

  tags = merge(var.common_tags, {
    Name = local.cluster_name
  })
}