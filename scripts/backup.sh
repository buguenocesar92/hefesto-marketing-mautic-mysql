#!/usr/bin/env bash
set -euo pipefail
umask 077
cd "$(dirname "$0")/.."
dc() { docker compose "$@"; }
mkdir -p backups
exec 9>backups/.lock
flock -n 9 || { echo 'Otro backup esta activo';exit 1; }
for s in web proxy cron worker; do [ -n "$(dc ps --status running -q "$s")" ] || { echo "Revisar servicio $s antes de backup";exit 1; };done
out="backups/$(date -u +%Y%m%dT%H%M%SZ)";mkdir "$out"
trap 'echo "Backup incompleto; servicios pueden estar detenidos. Revisar antes de reanudar." >&2' ERR
dc stop proxy cron worker web
dc exec -T db sh -ec 'MYSQL_PWD="$MYSQL_PASSWORD" exec mysqldump -u "$MYSQL_USER" --single-transaction --no-tablespaces --set-gtid-purged=OFF --skip-lock-tables "$MYSQL_DATABASE"' > "$out/database.sql"
dc run --rm --no-deps --user root --entrypoint tar web -czf - -C /var/www/html config var/logs docroot/media/files docroot/media/images > "$out/persistent-files.tar.gz"
cp compose.yaml Dockerfile "$out/"
python3 - "$out" <<'PYCHECK'
import sys,pathlib,hashlib
p=pathlib.Path(sys.argv[1]);lines=[]
for f in sorted(p.iterdir()):
 if f.is_file():
  with f.open('rb') as src:lines.append(hashlib.file_digest(src,'sha256').hexdigest()+'  '+f.name)
(p/'SHA256SUMS').write_text('\n'.join(lines)+'\n')
PYCHECK
dc start web cron worker proxy
trap - ERR
echo "Respaldo generado: $out. Config contiene secretos: cifrar y copiar fuera del VPS."
