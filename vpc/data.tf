data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu-18" {
  most_recent      = true
  owners           = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

terraform {
  backend "s3" {
    bucket = "remote-state-for-tf-hw3"
    key    = "homework3/terraform.tfstate"
    region = "us-east-1"
  }
}