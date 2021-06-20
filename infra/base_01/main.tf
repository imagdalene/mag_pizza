terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}


data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "Vpc" {
  cidr_block = var.vpcCidr
}

resource "aws_subnet" "PubSn1" {
  vpc_id            = aws_vpc.Vpc.id
  cidr_block        = var.pub1Cidr
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "PubSn2" {
  vpc_id            = aws_vpc.Vpc.id
  cidr_block        = var.pub2Cidr
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_subnet" "PteSn1" {
  vpc_id            = aws_vpc.Vpc.id
  cidr_block        = var.pte1Cidr
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "PteSn2" {
  vpc_id            = aws_vpc.Vpc.id
  cidr_block        = var.pte2Cidr
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_subnet" "DataSn1" {
  vpc_id                  = aws_vpc.Vpc.id
  cidr_block              = var.data1Cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.IGW]

}

resource "aws_subnet" "DataSn2" {
  vpc_id                  = aws_vpc.Vpc.id
  cidr_block              = var.data2Cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.IGW]

}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Vpc.id
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.Vpc.id
}

resource "aws_route" "PublicRoute" {
  route_table_id         = aws_route_table.PublicRouteTable.id
  gateway_id             = aws_internet_gateway.IGW.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "PublicSubnetAssn1" {
  subnet_id      = aws_subnet.PubSn1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "PublicSubnetAssn2" {
  subnet_id      = aws_subnet.PubSn2.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_eip" "EIP1" {
  vpc = true

}

# resource "aws_eip" "EIP2" {
#   vpc = true

# }

# Have NAT for my stuff inside pte subnets to initiatiate outbound connections

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.EIP1.id
  subnet_id     = aws_subnet.PteSn1.id
  depends_on = [
    aws_eip.EIP1
  ]
}

# Connect PteSubnet1 to NAT
resource "aws_route_table" "PteRouteTable1" {
  vpc_id = aws_vpc.Vpc.id
}

resource "aws_route" "PteRoute1" {
  route_table_id         = aws_route_table.PteRouteTable1.id
  nat_gateway_id         = aws_nat_gateway.NAT.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "PteRTAssn1" {
  route_table_id = aws_route_table.PteRouteTable1.id
  subnet_id      = aws_subnet.PteSn1.id
}

# Connect PteSubnet2 to NAT
resource "aws_route_table" "PteRouteTable2" {
  vpc_id = aws_vpc.Vpc.id
}

resource "aws_route" "PteRoute2" {
  route_table_id         = aws_route_table.PteRouteTable2.id
  nat_gateway_id         = aws_nat_gateway.NAT.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "PteRTAssn2" {
  route_table_id = aws_route_table.PteRouteTable2.id
  subnet_id      = aws_subnet.PteSn2.id
}

# Connect data routes
resource "aws_route_table" "DataRouteTable" {
  vpc_id = aws_vpc.Vpc.id
}

resource "aws_route_table_association" "DataRTAssn1" {
  route_table_id = aws_route_table.DataRouteTable.id
  subnet_id      = aws_subnet.DataSn1.id
}

resource "aws_route_table_association" "DataRTAssn2" {
  route_table_id = aws_route_table.DataRouteTable.id
  subnet_id      = aws_subnet.DataSn2.id
}

# ECS Cluster
resource "aws_ecs_cluster" "ECSCluster" {
  name               = "MagPizzaCluster"
  capacity_providers = ["FARGATE"]
}

# ECS Task Execution Role
resource "aws_iam_role" "ECSTaskExecutionRole" {
  name = "ECSTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  path = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

output "ECSClusterID" {
  description = "Name of ECS cluster"
  value       = aws_ecs_cluster.ECSCluster.id
}

output "ECSTaskExecutionRole" {
  description = "ARN of ECS Task Exec Role"
  value       = aws_iam_role.ECSTaskExecutionRole.arn
}

output "VpcId" {
  description = "VPC ID duh"
  value       = aws_vpc.Vpc.id
}

output "PublicSn1" {
  description = "Public Subnet 1"
  value       = aws_subnet.PubSn1.id
}

output "PublicSn2" {
  description = "Public Subnet 2"
  value       = aws_subnet.PubSn2.id
}

output "PteSn1" {
  description = "Pte Subnet 1"
  value       = aws_subnet.PteSn1.id
}

output "PteSn2" {
  description = "Pte Subnet 2"
  value       = aws_subnet.PteSn2.id
}

output "DataSn1" {
  description = "Pte Subnet 1"
  value       = aws_subnet.DataSn1.id
}

output "DataSn2" {
  description = "Pte Subnet 2"
  value       = aws_subnet.DataSn2.id
}
