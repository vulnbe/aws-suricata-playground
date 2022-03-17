variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  default = "t3.medium"
  type    = string
}

variable "instance_profile" {
  default = ""
  type    = string
}

variable "ssh_key" {
  default = ""
  type    = string
}

variable "tags" {
  default = {}
  type    = map(any)
}

variable "vxlan_port" {
  default = 4789
  type    = number
}

variable "lambda_url" {
  default = "https://raw.githubusercontent.com/vulnbe/aws-traffic-mirror-lambda/master/lambda_function.py"
  type    = string
}

variable "lambda_name" {
  default = "TrafficMirrorLambda"
  type    = string
}
