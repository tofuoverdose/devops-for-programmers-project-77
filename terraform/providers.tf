terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

variable "linode_token" {}

provider "linode" {
  token = var.linode_token
}