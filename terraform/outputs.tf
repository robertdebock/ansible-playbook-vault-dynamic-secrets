output "vault" {
  value = digitalocean_droplet.vault.ipv4_address
}

output "mysql" {
  value = digitalocean_droplet.mysql.ipv4_address
}
