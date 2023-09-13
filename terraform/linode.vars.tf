variable "linode_region" {
  type    = string
  default = "eu-central"
}

variable "linode_common_tag" {
  type    = string
  default = "hexlet"
}

variable "instance_user" {
  type = string
  description = "User name for using in linode instances"
  default = "root"
  sensitive = true
}

variable "instance_password" {
  type = string
  description = ""
  sensitive = true
}

#variable "ssh_public_key" {
#  type        = string
#  description = "Path to public key for using in remote-exec provisioner"
#}

#variable "ssh_private_key" {
#  type        = string
#  description = "Path to private key for using in remote-exec provisioner"
#  sensitive = true
#}

###
variable "domain_name" {
  type = string
  description = ""
}

variable "domain_soa_email" {
  type = string
  description = ""
}