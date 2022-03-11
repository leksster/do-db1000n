terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
  # default = "5109285091285091285091820598120598 (stub)"
}

variable "ssh_public_key" {
  # default = "ssh-rsa $@*ASYSfasfasfas email@email.em (stub)"
}

variable "droplet_size" {
  default = "s-4vcpu-8gb-amd" # https://slugs.do-api.dev/ - list of digitalocean slugs with description
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "Bomber machine key"
  public_key = var.ssh_public_key
}

data "template_file" "user_data" {
  template = file("./configuration.yaml")
  vars = {
    init_ssh_public_key = var.ssh_public_key
  }
}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-20-04-x64"
  name   = "bomber"
  region = "fra1"
  size   = var.droplet_size
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
  user_data = data.template_file.user_data.rendered
}

output "ip" {
  value = digitalocean_droplet.web.ipv4_address
}
