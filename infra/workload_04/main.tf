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

data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../base_01/terraform.tfstate"
  }
}
data "terraform_remote_state" "opa" {
  backend = "local"
  config = {
    path = "../opa_02/terraform.tfstate"
  }
}
data "terraform_remote_state" "storage" {
  backend = "local"
  config = {
    path = "../storage_02/terraform.tfstate"
  }
}

data "terraform_remote_state" "albs" {
  backend = "local"
  config = {
    path = "../albs_03/terraform.tfstate"
  }
}

# BE Task Definition
resource "aws_ecs_task_definition" "ECSTaskDefinition" {
  family                   = var.BEServiceName
  cpu                      = var.ContainerCpu
  memory                   = var.ContainerMemory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.terraform_remote_state.base.outputs.ECSTaskExecutionRole
  task_role_arn            = data.terraform_remote_state.albs.outputs.BETaskRole
  container_definitions = jsonencode([
    {
      name   = var.BEServiceName
      cpu    = var.ContainerCpu
      memory = var.ContainerMemory
      image  = var.ImageHash
      healthCheck = {
        startPeriod = 40
        command = [
          "CMD-SHELL",
          "curl --fail http://localhost:${var.ContainerPort}/health || exit 1"
        ]
        interval = 40
      }
      portMappings = [
        {
          containerPort = var.ContainerPort
        }
      ]

      environment = [
        {
          name  = "UserTableName"
          value = data.terraform_remote_state.storage.outputs.UserTableName
        },
        {
          name  = "SessionTableName"
          value = data.terraform_remote_state.storage.outputs.SessionTableName
        },
        {
          name  = "MenuTableName"
          value = data.terraform_remote_state.storage.outputs.MenuTableName
        },
        {
          name  = "OrdersTableArn"
          value = data.terraform_remote_state.storage.outputs.OrdersTableArn
        }

      ]

    }
  ])

}
