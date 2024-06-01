resource "aws_security_group" "common" {
  name       = "aws-and-infra-${var.env}-common"
  description = "aws-and-infra-${var.env}-common"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "aws-and-infra-${var.env}-common"
  }
  
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks =  var.cidr_blocks 
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  
}