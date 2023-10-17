variable "key_pair_name" {
  default = "proxy"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}
