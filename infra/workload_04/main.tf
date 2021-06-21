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


data "terraform_remote_state" "ui" {
  backend = "local"
  config = {
    path = "../ui_03/terraform.tfstate"
  }
}

# BE Task Definition
resource "aws_ecs_task_definition" "BEECSTaskDefinition" {
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
          name  = "MenuTableName"
          value = data.terraform_remote_state.storage.outputs.MenuTableName
        },
        {
          name  = "OrdersTableArn"
          value = data.terraform_remote_state.storage.outputs.OrdersTableName
        },
        {
          name = "ORIGIN"
          value = data.terraform_remote_state.ui.outputs.FEOrigin
        }

      ]

    }
  ])

}

resource "aws_ecs_service" "BEService" {
  name                              = var.BEServiceName
  cluster                           = data.terraform_remote_state.base.outputs.ECSClusterID
  desired_count                     = var.DesiredCount
  enable_ecs_managed_tags           = true
  deployment_maximum_percent        = 150
  health_check_grace_period_seconds = 30
  launch_type                       = "FARGATE"

  load_balancer {
    container_name   = var.BEServiceName
    container_port   = var.ContainerPort
    target_group_arn = data.terraform_remote_state.albs.outputs.BETargetGroup
  }

  network_configuration {
    assign_public_ip = false
    subnets = [
      data.terraform_remote_state.base.outputs.PteSn1,
      data.terraform_remote_state.base.outputs.PteSn2
    ]
    security_groups = [
      data.terraform_remote_state.albs.outputs.BEWorkloadSG
    ]
  }

  platform_version = "1.4.0"
  task_definition  = aws_ecs_task_definition.BEECSTaskDefinition.arn

}
