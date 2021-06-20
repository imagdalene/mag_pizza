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
