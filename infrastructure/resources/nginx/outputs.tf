output "instance_ids" {
  value = [for instance in aws_instance.nginx : instance.id]
}