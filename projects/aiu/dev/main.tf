provider "aws" {
  region = "ap-northeast-1"  
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "tag-env" {
  type = string
}

variable "subnet_private_AZ-A" {
  type = string
}

variable "subnet_private_AZ-C" {
  type = string
}

variable "subnet_private_AZ-A3" {
  type = string
}

variable "subnet_private_AZ-C3" {
  type = string
}


terraform {
  backend "s3" {
    bucket     = "dpf-${var.env}-s3-terraform-state"
    key        = "aiu/terraform.tfstate"
    region     = "ap-northeast-1"
    kms_key_id = "arn:aws:kms:ap-northeast-1:00000000000000:key/00000000000000000"
    
    dynamodb_table = "dpf-${var.env}-dynamodb-terraform-locks"
    encrypt        = true
  }
}
