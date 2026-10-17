#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dc() { docker compose "$@"; }
console() { dc exec --user www-data web php /var/www/html/bin/console "$@"; }
case "${1:-help}" in
 validate) dc config --quiet;;
 prepare) dc up -d --build db web proxy;;
 install)
   dc exec -T --user www-data web php /opt/hefesto/preflight.php
   dc exec -T --user www-data web php /opt/hefesto/install.php
   dc exec -T --user www-data web php /opt/hefesto/configure.php
   console cache:clear --env=prod
   dc exec -T --user www-data web php /opt/hefesto/ready.php
   dc up -d cron worker
   ;;
 configure)
   dc stop cron worker
   dc exec -T --user www-data web php /opt/hefesto/preflight.php
   dc exec -T --user www-data web php /opt/hefesto/configure.php
   console cache:clear --env=prod
   dc start cron worker
   ;;
 status) dc ps -a;;
 logs) dc logs --tail=100 web cron worker;;
 console) shift; console "$@";;
 backup) exec bash scripts/backup.sh;;
 *) echo 'Uso: bash scripts/manage.sh validate|prepare|install|configure|status|logs|console COMANDO|backup';;
esac
