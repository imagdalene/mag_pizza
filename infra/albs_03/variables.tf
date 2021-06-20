variable "CertArn" {
  type    = string
  default = "arn:aws:acm:us-east-1:386145569507:certificate/a4773cc7-c0d9-44fe-8612-ed55ff9476dd"
}

variable "Aliases" {
  type    = list(string)
  default = ["api.amazingprimes.com"]
}

variable "ZoneName" {
  type    = string
  default = "amazingprimes.com."
}
