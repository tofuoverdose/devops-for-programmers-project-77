data "linode_sshkey" "sshkey" {
  label = "id_rsa"
}

### database

resource "linode_database_postgresql" "hexlet_db" {
  engine_id = "postgresql/14.6"
  region    = var.linode_region
  type      = "g6-nanode-1"

  label = "hexlet-db"
}

resource "linode_database_access_controls" "hexlet_db_access" {
  allow_list    = linode_instance.hexlet_node.*.private_ip_address
  database_id   = linode_database_postgresql.hexlet_db.id
  database_type = "postgresql"
}

### instances

resource "linode_instance" "hexlet_node" {
  count = "2"

  image      = "linode/ubuntu22.04"
  region     = var.linode_region
  type       = "g6-nanode-1"
  private_ip = true
  root_pass  = var.instance_password

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo done!"]

    connection {
      host        = self.ip_address
      type        = "ssh"
      user        = var.instance_user
      password = var.instance_password
    }
  }

  #  provisioner "local-exec" {
  #    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.instance_user} -i '${self.ip_address},' --private-key ${var.ssh_priv} -e 'pub_key=${var.ssh_pub}' playbook.yml"
  #  }

  label = "hexlet-node-${count.index + 1}"
  tags  = [var.linode_common_tag]

  depends_on = [
    linode_database_postgresql.hexlet_db
  ]
}

### balancers

resource "linode_nodebalancer" "hexlet_lb" {
  region = var.linode_region

  label = "hexlet-lb"
  tags  = [var.linode_common_tag]
}

resource "linode_nodebalancer_config" "hexlet_lb_cfg" {
  nodebalancer_id = linode_nodebalancer.hexlet_lb.id
  protocol        = "http" # todo: change later to http
  port            = "80"
  algorithm       = "roundrobin"
  check           = "http"
  check_path      = "/"
}

resource "linode_nodebalancer_node" "hexlet_lb_node" {
  count = "2"

  nodebalancer_id = linode_nodebalancer.hexlet_lb.id
  config_id       = linode_nodebalancer_config.hexlet_lb_cfg.id
  address         = "${element(linode_instance.hexlet_node.*.private_ip_address, count.index)}:80"

  label = "hexlet-node-${count.index + 1}"
}

### domain stuff

resource "linode_domain" "hexlet_domain" {
  type      = "master"
  domain    = var.domain_name
  soa_email = var.domain_soa_email

  tags = [var.linode_common_tag]
}

resource "linode_domain_record" "hexlet_ns" {
  count = "5"

  domain_id   = linode_domain.hexlet_domain.id
  record_type = "NS"
  target      = "ns${count.index + 1}.linode.com"
}

resource "linode_domain_record" "hexlet_aaaa_v4" {
  domain_id   = linode_domain.hexlet_domain.id
  record_type = "AAAA"
  target      = linode_nodebalancer.hexlet_lb.ipv4
}

resource "linode_domain_record" "hexlet_aaaa_v6" {
  domain_id   = linode_domain.hexlet_domain.id
  record_type = "AAAA"
  target      = linode_nodebalancer.hexlet_lb.ipv6
}

### outputs

output "instances_ip_addresses" {
  value = [for node in linode_instance.hexlet_node : node.ip_address]
}

output "database" {
  value = {
    addr : linode_database_postgresql.hexlet_db.host_secondary
    user : linode_database_postgresql.hexlet_db.root_username
    pass : linode_database_postgresql.hexlet_db.root_password
  }
  sensitive = true
}

