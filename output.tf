
output "security_group" {
    value = "${join(", ", aws_security_group.web.*.id)}"
}