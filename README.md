# Vault Dynamic Secrets demonstration

Show how dynamic secrets in Vault work.

## Overview

This setup consists of:
- 1 machine running Vault.
- 2 machine running MySQL.

## Requirements

1. Have a Digital Ocean API key saved in an environment variable `TF_VAR_do_token`.
2. Have Terraform installed.
3. Have Ansible installed.

## Prepare

Download Ansible roles:

```shell
anible-galaxy install -r roles/requirements.yml -f
```

Now you can start the machines and configure them:

```shell
./playbook.yml
```

## Demonstration

### Login to the Vault machine

```shell
cd terraform ; terraform output
```

### Setup the environment

```shell
export VAULT_IP=w.x.y.z
export MYSQL_IP=v.w.x.y
export VAULT_ADDR=http://${VAULT_IP}:8200
```

The value for `VAULT_IP` and `MYSQL_IP` can be found using:

```shell
cd terraform
terraform output
```

### Login to Vault

```shell
vault login
```

The token is saved in `group_vars/vault/vault-unseal.yml`.

### Enable the database secrets engine

```shell
vault secrets enable database
```

### Connect Vault to MySQL

```shell
vault write database/config/my-mysql-database \
  plugin_name=mysql-database-plugin \
  connection_url="{{username}}:{{password}}@tcp(${MYSQL_IP}:3306)/" \
  allowed_roles="my-role" \
  username="vault" \
  password="VAULTvault"
 ```

 ### Create a Vault role

 ```shell
 vault write database/roles/my-role \
    db_name=my-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"
```

### Have Vault create a MySQL user

```shell
vault read database/creds/my-role
```

Here is an exemplary output:

```text
Key                Value
---                -----
lease_id           database/creds/my-role/9yVEkp4GoGBmNK09jciSh6C8
lease_duration     1h
lease_renewable    true
password           XBz-3mSrHF9Bdfysj9JV
username           v-root-my-role-4fFsckJnXCrpBxEBt
```

### Try the generated credentials

```shell
dnf install mysql
mysql -u {{ USERNAME_AS_VAULT_REPORTED }} -p{{ PASSWORD_AS_VAULT_REPORTED }} -h ${MYSQL_IP}
mysql show databases;
```

## Cleanup

```shell
cd terraform
terraform destroy
```
