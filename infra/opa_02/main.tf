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

resource "aws_security_group" "OPAActualWLSG" {
  vpc_id = data.terraform_remote_state.base.outputs.VpcId
  name   = "OPAActualWLSG"
}

resource "aws_security_group" "OPAPolicyWLSG" {
  vpc_id = data.terraform_remote_state.base.outputs.VpcId
  name   = "OPAPolicyWLSG"
  ingress {
    security_groups = [aws_security_group.OPAActualWLSG.id]
    protocol        = -1
    from_port       = 0
    to_port         = 0
  }
}

output "OPAActualWLSG" {
  description = "OPAActualWLSG"
  value       = aws_security_group.OPAActualWLSG.id
}

output "OPAPolicyWLSG" {
  description = "OPAPolicyWLSG"
  value       = aws_security_group.OPAPolicyWLSG.id
}
