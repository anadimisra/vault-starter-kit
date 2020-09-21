#!/bin/bash

# The world isn't black and white
export reset='\033[0m'
export black='\033[0;30m'
export red='\033[0;31m'
export green='\033[0;32m'
export yellow='\033[0;33m'
export blue='\033[0;34m'
export purple='\033[0;35m'
export cyan='\033[0;36m'
export white='\033[0;37m'

export info=$cyan

echo -e "${info}login${reset}"
vault login wibble

echo -e "${info}Configure DB plugin${reset}"
vault write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="readonly" \
    connection_url="postgresql://{{username}}:{{password}}@postgres:5432/postgres?sslmode=disable" \
    username="root" \
    password="rootpassword"

echo -e "${info}Create role${reset}"
vault write database/roles/readonly db_name=postgresql \
        creation_statements=@readonly.sql \
        default_ttl=1h max_ttl=24h

echo -e "${info}Create policy${reset}"
vault policy write apps apps-policy.hcl

echo -e "${info}Query token${reset}"
APPS_TOKEN=$(vault token create -policy="apps" -format=json | jq '.auth.client_token' | xargs)

echo -e "${info}Token${reset}"
echo -e "\n\n${green}${APPS_TOKEN}${reset}\n\n"

echo -e "${info}Generate Credentials${reset}"
VAULT_TOKEN=$APPS_TOKEN vault read database/creds/readonly


