variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "subnet_id" {
  description = "Subnet ID for Suricata deployment"
  type        = string
}

variable "instance_type" {
  default = "t3.medium"
  type    = string
}

variable "instance_profile" {
  description = "Instance profile for Suricata"
  default     = ""
  type        = string
}

variable "ssh_key" {
  description = "SSH key for Suricata"
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be set for all resources"
  default     = {}
  type        = map(any)
}

variable "suricata_tags" {
  description = "Tags to be set for suricata instance"
  type        = map(any)
}

variable "skip_tags" {
  description = "Mirroring session won't be set up for instances with these tags"
  type        = map(any)
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
