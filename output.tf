# output "security_group" {
#     value = "${join(", ", aws_security_group.web.*.id)}"
# }
output "subnet-id" {
  value = "${data.aws_subnet_ids.public.ids}"
}
