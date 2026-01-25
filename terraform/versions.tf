terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.29"
    }
  }

  backend "s3" {
    bucket  = "dsk52-foundation-vnx3xku"
    key     = "terraform/aws-foundation-ops/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "default"
  }
}
