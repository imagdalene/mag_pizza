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

data "aws_route53_zone" "selected" {
  name = var.ZoneName
}

resource "aws_security_group" "BackendALBSG" {
  name   = "BackendALBSG"
  vpc_id = data.terraform_remote_state.base.outputs.VpcId
}

resource "aws_security_group" "BEWorkloadSG" {
  name   = "BEWorkloadSG"
  vpc_id = data.terraform_remote_state.base.outputs.VpcId
}

resource "aws_security_group_rule" "PteALBWorkloadIngress" {
  from_port = 0
  to_port = 0
  protocol                 = -1
  type                     = "ingress"
  source_security_group_id = aws_security_group.BackendALBSG.id
  security_group_id        = aws_security_group.BEWorkloadSG.id
}


resource "aws_security_group_rule" "BEALBEgress" {
  from_port = 0
  to_port = 0
  protocol                 = -1
  type                     = "egress"
  security_group_id        = aws_security_group.BackendALBSG.id
  source_security_group_id = aws_security_group.BEWorkloadSG.id
}

resource "aws_security_group_rule" "BEToOPAWorkloadIngress" {
  from_port = 0
  to_port = 0
  protocol                 = -1
  type                     = "ingress"
  security_group_id        = data.terraform_remote_state.opa.outputs.OPAActualWLSG
  source_security_group_id = aws_security_group.BEWorkloadSG.id
  
}

resource "aws_lb" "BEALB" {
  name = "BEALB"
  load_balancer_type = "application"
  internal = false
  idle_timeout = 30
  subnets = [
    data.terraform_remote_state.base.outputs.PublicSn1,
    data.terraform_remote_state.base.outputs.PublicSn2
  ]
  security_groups = [
    aws_security_group.BackendALBSG.id
  ]
}

resource "aws_lb_target_group" "BETargetGroup" {
  name = "BETargetGroup"
  health_check {
    interval = 6
    path = "/healthcheck"
    healthy_threshold = 2
    port = 80
    unhealthy_threshold = 2
  }

  port = 80
  target_type = "ip"
  protocol = "HTTP"
  vpc_id = data.terraform_remote_state.base.outputs.VpcId

}

resource "aws_lb_listener" "BEALBListener" {
  load_balancer_arn = aws_lb.BEALB.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.CertArn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.BETargetGroup.arn
  }
}

resource "aws_iam_role" "BETaskRole" {
  name = "BETaskRole"
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

  inline_policy {
    name = "BETaskPolicy"
    
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["dynamodb:*"]
          Effect   = "Allow"
          Resource = [
            data.terraform_remote_state.storage.outputs.UserTableArn,
            data.terraform_remote_state.storage.outputs.SessionTableArn,
            data.terraform_remote_state.storage.outputs.MenuTableArn,
            data.terraform_remote_state.storage.outputs.OrdersTableArn,
          ]
        },
      ]
    })
  }
}

resource "aws_route53_record" "ALBRecord" {
    name    = var.Aliases[0]
    type   = "A"
    zone_id = data.aws_route53_zone.selected.zone_id
    alias {
      name = aws_lb.BEALB.dns_name
      zone_id = aws_lb.BEALB.zone_id
      evaluate_target_health = false
    }
}

output "PublicListenerArn" {
  description = "PublicListenerArn"
  value       = aws_lb_listener.BEALBListener.arn
}

output "BEWorkloadSG" {
  description = "BEWorkloadSG"
  value       = aws_security_group.BEWorkloadSG.id
}

output "BETargetGroup" {
  description = "BETargetGroup"
  value       = aws_lb_target_group.BETargetGroup.id
} 

output "BETaskRole" {
  description = "BETaskRole"
  value       =  aws_iam_role.BETaskRole.arn
} 
 