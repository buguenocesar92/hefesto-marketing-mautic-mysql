# Coolify

Crear recurso Docker Compose desde repositorio privado, compose.yaml. Build Dockerfile y variables runtime del .env generado. No subir .env/backups. Dominio HTTPS al servicio proxy, puerto 80. MARKETING_HOST solo dominio, sin esquema. DNS y TLS se resuelven en Coolify.

Web no tiene puerto publicado al host. DB solo red backend interna. Nginx proxy y web comparten backend. TRUSTED_PROXIES debe contener IP/CIDR real del proxy nginx interno (y proxy de Coolify si se necesita procesar cadena completa), separado por comas. Evitar confiar en todo Internet; comprobar IP cliente y URL HTTPS tras instalar.

Primer despliegue: solo db, web y proxy. Ejecutar `bash scripts/manage.sh prepare` en mismo directorio/proyecto Compose. Coolify puede crear cron/worker y dejarlos esperando health de web; es normal hasta instalacion CLI. No crear un segundo proyecto desde un clon diferente.

Si usas terminal de Coolify, entrar en web y ejecutar, como www-data:
```
php /opt/hefesto/preflight.php
php /opt/hefesto/install.php
php /opt/hefesto/configure.php
php /var/www/html/bin/console cache:clear --env=prod
php /opt/hefesto/ready.php
```
Ejecutar en orden y detenerse ante errores. Luego iniciar cron y worker desde el mismo recurso. Hasta marcar ready el proxy responde 503; el asistente no queda expuesto por ese dominio. No exponer web directamente.

Volumenes: dbdata, config, logs, files e images. No ejecutar down -v. La imagen inicializa permisos de sus rutas; conservar archivos de config con usuario www-data y sin permisos publicos de escritura. MySQL se inicializa una sola vez: cambiar .env no rota password dentro de un volumen existente.

Calcular espacio para imagen (>600 MB comprimida), DB, multimedia y copias. Recomendacion inicial orientativa: 4 GB RAM y 2-4 vCPU; medir volumen de campañas, cola y concurrencia. No garantiza tasa de envio.

Nginx restringe solicitud a 64 MB; otros proxies pueden imponer menos. No instalar plugins directamente dentro de contenedor efimero: incorporarlos a imagen versionada y probar compatibilidad.
