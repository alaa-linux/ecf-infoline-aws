terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "infoline_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "infoline-vpc"
  }
}

resource "aws_subnet" "infoline_subnet_1" {
  vpc_id                  = aws_vpc.infoline_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true

  tags = {
    Name = "infoline-subnet-1"
  }
}

resource "aws_subnet" "infoline_subnet_2" {
  vpc_id                  = aws_vpc.infoline_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true

  tags = {
    Name = "infoline-subnet-2"
  }
}

resource "aws_internet_gateway" "infoline_igw" {
  vpc_id = aws_vpc.infoline_vpc.id

  tags = {
    Name = "infoline-igw"
  }
}

resource "aws_route_table" "infoline_route_table" {
  vpc_id = aws_vpc.infoline_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infoline_igw.id
  }

  tags = {
    Name = "infoline-route-table"
  }
}

resource "aws_route_table_association" "infoline_rta_1" {
  subnet_id      = aws_subnet.infoline_subnet_1.id
  route_table_id = aws_route_table.infoline_route_table.id
}

resource "aws_route_table_association" "infoline_rta_2" {
  subnet_id      = aws_subnet.infoline_subnet_2.id
  route_table_id = aws_route_table.infoline_route_table.id
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "infoline-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "infoline_cluster" {
  name     = "infoline-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.infoline_subnet_1.id,
      aws_subnet.infoline_subnet_2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_iam_role" "eks_node_role" {
  name = "infoline-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_policy_1" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_policy_2" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_policy_3" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_eks_node_group" "infoline_nodes" {
  cluster_name    = aws_eks_cluster.infoline_cluster.name
  node_group_name = "infoline-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    aws_subnet.infoline_subnet_1.id,
    aws_subnet.infoline_subnet_2.id
  ]

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.small"]

  depends_on = [
    aws_iam_role_policy_attachment.node_policy_1,
    aws_iam_role_policy_attachment.node_policy_2,
    aws_iam_role_policy_attachment.node_policy_3
  ]
}
