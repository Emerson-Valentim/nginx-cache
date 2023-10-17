variable "key_pair_name" {
  default = "proxy"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "efs_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}


variable "lb_sg_ids" {
  type = list(string)
}

variable "app_ip" {
  type = string
}