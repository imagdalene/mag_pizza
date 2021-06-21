variable "ImageHash" {
  type    = string
  default = ""
}

variable "RepositoryName" {
  type    = string
  default = ""
}

variable "BEServiceName" {
  type    = string
  default = "BEServiceName"
}

variable "ContainerPort" {
  type    = number
  default = 80
}

variable "ContainerPortStr" {
  type    = string
  default = "80"
}

variable "ContainerCpu" {
  type    = number
  default = 256
}

variable "ContainerMemory" {
  type    = number
  default = 512
}

variable "DesiredCount" {
  type    = number
  default = 2
}

variable "JWT_TOKEN_SIGNING_SECRET" {
  type    = string
  default = ""
}

variable "AWS_REGION" {
  type    = string
  default = "us-east-1"
}
