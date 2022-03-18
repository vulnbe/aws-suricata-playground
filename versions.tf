terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.64.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}
