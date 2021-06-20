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
