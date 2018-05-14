terraform = {
  required_version = ">= 0.9.3"

  backend "s3" {
    bucket = "sml-terraform"
    key    = "tf-aws.tfstate"
    region = "ap-southeast-1"
  }
}

# https://github.com/nickcharlton/terraform-aws-vpc
provider "aws" {
  region = "${var.aws_region}"
}

# TODO: 
#   1. ALB
#   2. Target group
#       - elasticsearch
#       - kibana
#       - fluentd
#   3. Task definition
#   4. ECS Service
/*
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "terraform-aws-vpc"
  }
}


#   Public Subnet

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${var.public_subnet_cidr}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "ap-southeast-1a-public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "ap-southeast-1a-public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.ap-southeast-1a-public.id}"
}


#   Private Subnet
resource "aws_subnet" "ap-southeast-1a-private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "ap-southeast-1b"

  tags {
    Name = "Private Subnet"
  }
}

# resource "aws_route_table" "ap-southeast-1a-private" {
#     vpc_id = "${aws_vpc.default.id}"


#     route {
#         cidr_block = "0.0.0.0/0"
#         instance_id = "${aws_instance.nat.id}"
#     }


#     tags {
#         Name = "Private Subnet"
#     }
# }


# resource "aws_route_table_association" "ap-southeast-1a-private" {
#     subnet_id = "${aws_subnet.private.id}"
#     route_table_id = "${aws_route_table.ap-southeast-1a-private.id}"
# }

*/

