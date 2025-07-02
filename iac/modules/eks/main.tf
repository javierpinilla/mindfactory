data "aws_ami" "eks_ami" {
  most_recent = true
  owners      = ["602401143452"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-*-x86_64-*"]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.cluster_name}-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_iam_role" "eks_node_role" {
  name = "${local.cluster_name}-node-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_eks_cluster" "eks" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = merge(var.common_tags, {
    Name = local.cluster_name
  })

  depends_on = [aws_iam_role_policy_attachment.attach_AmazonEKSClusterPolicy]
}

resource "aws_launch_template" "eks_lt" {
  name_prefix   = "${local.cluster_name}-lt-"
  image_id      = data.aws_ami.eks_ami.id
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  instance_market_options {
    market_type = var.node_market_type

    spot_options {
      max_price = var.spot_max_price
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${local.cluster_name}-lt"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "eks_grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_desired
    max_size     = var.node_max
    min_size     = var.node_min
  }

  launch_template {
    id      = aws_launch_template.eks_lt.id
    version = "$Latest"
  }

  tags = merge(var.common_tags, {
    Name = "${local.cluster_name}-ng"
  })

  depends_on = [
    aws_iam_role_policy_attachment.attach_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.attach_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.attach_AmazonEKS_CNI_Policy
  ]
}
