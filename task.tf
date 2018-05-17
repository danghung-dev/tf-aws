resource "null_resource" "efk_config_data" {
  connection {
    host        = "54.169.184.38"
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("${var.aws_key_path}")}"
  }

  provisioner "file" {
    source      = "fluentd/fluent.conf"
    destination = "/home/ec2-user/fluent.conf"
  }

  provisioner "file" {
    source      = "kibana/kibana.yml"
    destination = "/home/ec2-user/kibana.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /usr/share/fluentd/etc",
      "sudo mkdir -p /usr/share/fluentd/plugins",
      "sudo mkdir -p /usr/share/kibana",
      "sudo rm -rf /usr/share/fluentd/plugins/in_http_healthcheck.rb",
      "sudo mv /home/ec2-user/fluent.conf /usr/share/fluentd/etc/fluent.conf",
      "sudo mv /home/ec2-user/kibana.yml /usr/share/kibana/kibana.yml",
    ]
  }

  #   # "sudo useradd hung",
  #   # "sudo usermod -aG sudo hung",
  #   # "sudo usermod -aG docker hung",
  # }
}

data "aws_ecs_cluster" "ecs-sml" {
  cluster_name = "${var.ecs_cluster_name}"
}

resource "aws_ecs_task_definition" "es" {
  family                = "tf-elasticsearch"
  container_definitions = "${file("task-definitions/es.json")}"

  volume {
    name      = "esdata"
    host_path = "/usr/share/elasticsearch/data"
  }

  volume {
    name      = "esconfig"
    host_path = "/usr/share/elasticsearch/config/elasticsearch.yml"
  }
}

resource "aws_ecs_service" "es" {
  name            = "elasticsearch"
  cluster         = "${data.aws_ecs_cluster.ecs-sml.arn}"
  task_definition = "${aws_ecs_task_definition.es.arn}"
  desired_count   = 1

  # iam_role        = "${aws_iam_role.foo.arn}"
  # depends_on      = ["aws_iam_role_policy.foo"]

  load_balancer {
    target_group_arn = "${aws_lb_target_group.es.arn}"
    container_name   = "elasticsearch"
    container_port   = 9200
  }
  depends_on = ["aws_lb.es-lb"]
}

resource "aws_ecs_task_definition" "fluentd" {
  family                = "tf-fluentd"
  container_definitions = "${file("task-definitions/fluentd.json")}"

  volume {
    name      = "flconfig"
    host_path = "/usr/share/fluentd/"
  }
}

resource "aws_ecs_service" "fluentd" {
  name            = "fluentd"
  cluster         = "${data.aws_ecs_cluster.ecs-sml.arn}"
  task_definition = "${aws_ecs_task_definition.fluentd.arn}"
  desired_count   = 1

  # iam_role        = "${aws_iam_role.foo.arn}"
  # depends_on      = ["aws_iam_role_policy.foo"]

  load_balancer {
    target_group_arn = "${aws_lb_target_group.fluentd.arn}"
    container_name   = "fluentd"
    container_port   = 9880
  }
  depends_on = ["aws_lb.es-lb"]
}

resource "aws_ecs_task_definition" "kibana" {
  family                = "tf-kibana"
  container_definitions = "${file("task-definitions/kibana.json")}"

  volume {
    name      = "kbnconfig"
    host_path = "/usr/share/kibana/"
  }
}

resource "aws_ecs_service" "kibana" {
  name            = "kibana"
  cluster         = "${data.aws_ecs_cluster.ecs-sml.arn}"
  task_definition = "${aws_ecs_task_definition.kibana.arn}"
  desired_count   = 1

  # iam_role        = "${aws_iam_role.foo.arn}"
  # depends_on      = ["aws_iam_role_policy.foo"]

  load_balancer {
    target_group_arn = "${aws_lb_target_group.kibana.arn}"
    container_name   = "kibana"
    container_port   = 5601
  }
  depends_on = ["aws_lb.es-lb"]
}
