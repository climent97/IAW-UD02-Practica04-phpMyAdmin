#!/usr/bin/env bash

set -euo pipefail

# Instalacion y proteccion de phpMyAdmin en Ubuntu/Kubuntu.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$SCRIPT_DIR/.env"
CONF_FILE="$PROJECT_DIR/conf/site_phpmyadmin"

if [[ ! -f "$ENV_FILE" || ! -f "$CONF_FILE" ]]; then
    echo "Error: faltan .env o conf/site_phpmyadmin." >&2
    exit 1
fi

source "$ENV_FILE"

if [[ "$EUID" -ne 0 ]]; then
    echo "Ejecuta el script con sudo." >&2
    exit 1
fi

: "${PHP_FPM_SERVICE:?Falta PHP_FPM_SERVICE en .env}"
: "${PHP_FPM_SOCKET:?Falta PHP_FPM_SOCKET en .env}"
: "${PHPMYADMIN_DIR:?Falta PHPMYADMIN_DIR en .env}"
: "${NGINX_SITE_FILE:?Falta NGINX_SITE_FILE en .env}"
: "${HTPASSWD_FILE:?Falta HTPASSWD_FILE en .env}"
: "${HTPASSWD_USER:?Falta HTPASSWD_USER en .env}"

echo "Actualizando repositorios..."
apt-get update

echo "Instalando phpMyAdmin y dependencias..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    phpmyadmin php-mbstring php-zip php-gd php-curl apache2-utils

echo "Comprobando PHP-FPM..."
systemctl enable --now "$PHP_FPM_SERVICE"

if [[ ! -S "$PHP_FPM_SOCKET" ]]; then
    echo "Error: no existe el socket $PHP_FPM_SOCKET" >&2
    exit 1
fi

if [[ ! -f "$PHPMYADMIN_DIR/index.php" ]]; then
    echo "Error: no se encuentra phpMyAdmin en $PHPMYADMIN_DIR" >&2
    exit 1
fi

echo "Configurando autenticacion HTTP..."
install -d -m 750 "$(dirname "$HTPASSWD_FILE")"

if [[ -f "$HTPASSWD_FILE" ]]; then
    htpasswd -B "$HTPASSWD_FILE" "$HTPASSWD_USER"
else
    htpasswd -B -c "$HTPASSWD_FILE" "$HTPASSWD_USER"
fi

chown root:www-data "$HTPASSWD_FILE"
chmod 640 "$HTPASSWD_FILE"

echo "Instalando la plantilla de configuracion..."
install -d -m 755 /etc/nginx/snippets
install -m 644 "$CONF_FILE" \
    /etc/nginx/snippets/site_phpmyadmin.conf

echo "Revisa la inclusion de la configuracion en Nginx."
echo "El archivo que se debe revisar es: $NGINX_SITE_FILE"

if grep -Eq 'location[[:space:]]+/phpmyadmin' "$NGINX_SITE_FILE"; then
    echo "Ya existe un bloque phpMyAdmin."
    echo "No se insertara otro para evitar duplicar ubicaciones."
    echo "Comprueba que el bloque activo incluya auth_basic y la ruta correcta."
else
    if ! grep -Eq '^[[:space:]]*server_name _;' "$NGINX_SITE_FILE"; then
        echo "No se encuentra el server_name esperado."
        echo "Añade manualmente dentro del bloque server:"
        echo "include /etc/nginx/snippets/site_phpmyadmin.conf;"
        exit 1
    fi

    cp -a "$NGINX_SITE_FILE" "${NGINX_SITE_FILE}.bak"

    sed -i \
        '/^[[:space:]]*server_name _;/a\    include /etc/nginx/snippets/site_phpmyadmin.conf;' \
        "$NGINX_SITE_FILE"
fi

if ! nginx -t; then
    echo "Error en la configuracion de Nginx." >&2
    echo "No se ha recargado el servicio." >&2
    echo "Revisa el archivo y la copia .bak si se ha creado." >&2
    exit 1
fi

systemctl reload nginx

echo "Proceso finalizado."
