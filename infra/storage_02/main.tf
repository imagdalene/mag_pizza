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

resource "aws_dynamodb_table" "User" {
  name           = "User"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "userEmail"

  attribute {
    name = "userEmail"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
}

resource "aws_dynamodb_table" "Session" {
  name           = "Session"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "userEmail"

  attribute {
    name = "userEmail"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }
}

resource "aws_dynamodb_table" "Menu" {
  name           = "Menu"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "menuItemId"

  attribute {
    name = "menuItemId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "Orders" {
  name           = "Orders"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "orderid"

  attribute {
    name = "orderid"
    type = "S"
  }
}

output "UserTableArn" {
  description = "UserTable Arn"
  value       = aws_dynamodb_table.User.arn
}

output "UserTableName" {
  description = "UserTable Name"
  value       = aws_dynamodb_table.User.id
}

output "SessionTableArn" {
  description = "SessionTable Arn"
  value       = aws_dynamodb_table.Session.arn
}

output "SessionTableName" {
  description = "SessionTable Name"
  value       = aws_dynamodb_table.Session.id
}

output "MenuTableArn" {
  description = "MenuTable Arn"
  value       = aws_dynamodb_table.Menu.arn
}

output "MenuTableName" {
  description = "MenuTable Name"
  value       = aws_dynamodb_table.Menu.id
}

output "OrdersTableArn" {
  description = "OrdersTable Arn"
  value       = aws_dynamodb_table.Orders.arn
}

output "OrdersTableName" {
  description = "OrdersTable Name"
  value       = aws_dynamodb_table.Orders.id
}
