resource "digitalocean_ssh_key" "default" {
  name       = "vault-dynamic-secrets"
  public_key = file("../ssh_keys/id_rsa.pub")
}

resource "digitalocean_droplet" "vault" {
  name     = "vault"
  size     = "2gb"
  image    = "centos-8-x64"
  region   = "ams3"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}

resource "digitalocean_droplet" "mysql" {
  name     = "mysql"
  size     = "2gb"
  image    = "centos-8-x64"
  region   = "ams3"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}
