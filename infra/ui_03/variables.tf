variable "CertArn" {
  type    = string
  default = "arn:aws:acm:us-east-1:386145569507:certificate/395ded6a-39c0-4dde-abd8-19fc64e3c756"
}

variable "Aliases" {
  type    = list(string)
  default = ["ui.amazingprimes.com"]
}

variable "ZoneName" {
  type    = string
  default = "amazingprimes.com."
}
