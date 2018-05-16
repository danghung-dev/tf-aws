terraform = {
  required_version = ">= 0.9.3"

  backend "s3" {
    bucket = "sml-terraform"

    # key    = "${var.project_name}-${var.environment}"
    key    = "tf-aws"
    region = "ap-southeast-1"
  }
}

# https://github.com/nickcharlton/terraform-aws-vpc
provider "aws" {
  region = "${var.aws_region}"
}

# TODO:
#   1. Target group
#       - elasticsearch
#       - kibana
#       - fluentd
#   2. ALB
#       - sg & subnets
#       - Listener rule
#       - Connect to target group
#   3. Task definition
#   4. ECS Service
#       - Connect to target group

resource "aws_security_group" "es-alb" {
  name        = "es-alb-sg"
  description = "Allow incoming HTTP connections."

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${var.vpc_id}"

  tags {
    Name = "ES-ELB-SG"
  }
}

resource "aws_lb" "es-lb" {
  name               = "es-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.es-alb.id}"]
  subnets            = ["${data.aws_subnet_ids.public.ids}"]
}

data "aws_route53_zone" "danghung-xyz" {
  name = "danghung.xyz."

  # private_zone = true
}

resource "aws_route53_record" "log" {
  zone_id = "${data.aws_route53_zone.danghung-xyz.zone_id}"
  name    = "log.danghung.xyz"
  type    = "A"

  alias {
    name                   = "${aws_lb.es-lb.dns_name}"
    zone_id                = "${aws_lb.es-lb.zone_id}"
    evaluate_target_health = false
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_lb_target_group" "es" {
  name     = "tf-lb-tg-es"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_target_group" "fluentd" {
  name     = "tf-lb-tg-fluentd"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check = {
    path = "/?json=a"
  }
}

resource "aws_lb_target_group" "kibana" {
  name     = "tf-lb-tg-kibana"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_listener" "es" {
  load_balancer_arn = "${aws_lb.es-lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.es.arn}"
    type             = "forward"
  }
}

# resource "aws_lb_listener_rule" "es" {
#   listener_arn = "${aws_lb_listener.es.arn}"

#   action {
#     type             = "forward"
#     target_group_arn = "${aws_lb_target_group.es.arn}"
#   }

#   condition {
#     field  = "host-header"
#     values = ["elasticsearch"]
#   }
# }

resource "aws_lb_listener_rule" "kibana" {
  listener_arn = "${aws_lb_listener.es.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.kibana.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/kibana/*"]
  }
}

resource "aws_lb_listener_rule" "fluentd" {
  listener_arn = "${aws_lb_listener.es.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.fluentd.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/fluentd/*"]
  }
}

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

