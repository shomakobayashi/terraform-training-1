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
variable "cidr_blocks" {
  type = list(string)
  default = [
    "111.111.111.0/26",
    "111.111.111.11/32"
  ]
}

terraform {
  backend "a3" {
    bucket     = "aws-and-infra-dev-s3-terraform-state"
    key        = "aiu/terraform.tfstate"
    region     = "ap-northeast-1"
    kms_key_id = "arn:aws:kms:ap-northeast-1:111111111111:key/11111111-1111-1111-1111-111111111111"
    dyamodb_table = "aws-and-infra-dev-dynamodb-terraform_locks"
    encrypt    = true
  }
}


