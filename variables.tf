variable "project_name" {
  default = "tf-aws-elk"
}

variable "environment" {
  default = "test"
}

variable "aws_key_path" {}
variable "vpc_id" {}
variable "kibana_host" {}
variable "fluentd_host" {}
variable "ecs_cluster_name" {}
variable "ssl_certificate_arn" {}

variable "instance_type" {}
variable "aws_key_name" {}
variable "availability_zone" {}

variable "aws_region" {
  description = "EC2 Region for the VPC"
  default     = "ap-southeast-1"
}

variable "amis" {
  description = "AMIs by region"

  default = {
    ap-southeast-1 = "ami-52d4802e" # ubuntu 16.04 LTS
  }
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default     = "10.0.1.0/24"
}
