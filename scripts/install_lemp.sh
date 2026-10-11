#!/usr/bin/env bash

set -euo pipefail

#Script para automatizar la instalacion de la pila LEMP en kubuntu
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: no se encuentra $ENV_FILE" >&2
    exit 1
fi

source "$ENV_FILE"

if [[ "$EUID" -ne 0 ]]; then
    echo "Ejecuta el script con: sudo bash scripts/install_lemp.sh" >&2
    exit 1
fi

: "${LEMP_PACKAGES:?Falta definir LEMP_PACKAGES en .env}"
: "${PHP_FPM_SERVICE:?Falta definir PHP_FPM_SERVICE en .env}"

read -r -a packages <<< "$LEMP_PACKAGES"

echo "Actualizando los repositorios..."
apt-get update

echo "Instalando los paquetes de LEMP..."
apt-get install -y "${packages[@]}"

echo "Activando los servicios..."
systemctl enable --now nginx
systemctl enable --now mysql
systemctl enable --now "$PHP_FPM_SERVICE"

echo "Estado de los servicios:"
systemctl is-active nginx
systemctl is-active mysql
systemctl is-active "$PHP_FPM_SERVICE"

echo "Instalacion de LEMP finalizada."
