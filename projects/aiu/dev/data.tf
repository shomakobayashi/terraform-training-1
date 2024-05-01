#Account & VPC
data "aws_caller_identity" "self" {}

data "aws_vpc" "vpc_analytics_datapf" {
  tags = {  
    Name = "analytics-datapf-${var.env}-vpc"
  } 
}

#IAM ROLE
data "aws_iam_role" "admin_role" {
  name = "AdminRole"  
}

data "aws_iam_role" "power_role" {
  name = "PowerRole"  
}

data "aws_iam_role" "codepipeline" {
  name = "dpf-${var.env}-role-terraform-codepipeline"  
}

data "aws_iam_role" "codebuild" {
  name = "dpf-${var.env}-role-terraform-codebuild"  
}

data "aws_iam_role" "ec2_bastion" {
  name = "dpf-${var.env}-role-ec2-bastion"  
}

data "aws_iam_role" "ec2_jp1" {
  name = "dpf-${var.env}-role-ec2-jp1"  
}

data "aws_iam_role" "glue" {
  name = "dpf-${var.env}-role-glue"  
}

data "aws_iam_role" "codebuild" {
  name = "dpf-${var.env}-role-terraform-codebuild"  
}

#SG
data "aws_security_group" "bastion" {
  vpc_id = data.aws_vpc._analytics_datapf.id
  name   = "dpf-${var.env}-sg-ec2-common"
  tags   = {
    Name = "dpf-${var.env}-sg-ec2-common"
  } 
}

#Lambda
data "aws_lambda_function" "lambda_ec2_stop_start" {
  function_name =  "dpf-${var.env}-lambda-ec2-stop-start" 
}
