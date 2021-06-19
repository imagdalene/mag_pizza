variable "vpcCidr" {
  type    = string
  default = "10.138.0.0/16"
}
variable "pub1Cidr" {
  type    = string
  default = "10.138.0.0/24"
}
variable "pub2Cidr" {
  type    = string
  default = "10.138.1.0/24"
}
variable "pte1Cidr" {
  type    = string
  default = "10.138.2.0/24"
}
variable "pte2Cidr" {
  type    = string
  default = "10.138.3.0/24"
}
variable "data1Cidr" {
  type    = string
  default = "10.138.4.0/24"
}
variable "data2Cidr" {
  type    = string
  default = "10.138.5.0/24"
}
