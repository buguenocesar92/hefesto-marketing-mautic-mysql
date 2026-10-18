# Hefesto Marketing — Mautic nativo

Contactos, segmentos, formularios, paginas de captacion y automatizacion de campañas mediante Mautic 7.2.1. Paquete Docker Compose para Coolify con MySQL 8.4 y roles web/cron/worker separados.

**Estado:** preparado para desplegar, no instalado ni conectado a un proveedor de correo. No se importaron contactos ni se enviaron mensajes. No hay credenciales reales. Debe pasar aceptacion en staging antes de produccion.

## Por que este stack

Mautic requiere MySQL/MariaDB. Supabase PostgreSQL no es sustituto directo de su base. Elegimos MySQL 8.4 compatible con Mautic 7; Supabase puede integrarse despues por una API si otra app necesita datos, no reemplaza el motor ni comparte tablas de escritura.

## Inicio

1. Ejecutar `python3 scripts/init_env.py`. Crea .env privado sin sobrescribir otro.
2. Completar dominio, administrador, remitente y proxy. Dejar MAILER_DSN=null://null durante preparacion: **descarta correos, no los envia y las metricas de envio en este modo no prueban entregabilidad**.
3. Revisar docs/COOLIFY.md y desplegar con `bash scripts/manage.sh prepare`.
4. Ejecutar `bash scripts/manage.sh install`. Instala cuenta hefesto_admin con password generado. El proxy muestra 503 hasta que termina.
5. Configurar roles, campos, formulario y segmento piloto con docs/PRIMERA-CAMPANA.md. Plantillas HTML en templates/ para adaptar e importar en editor de codigo.
6. Configurar proveedor SMTP y validar bajas/rebotes/entrega antes de activar campañas. No se activa envio externo automaticamente.

## Incluye

- Imagen versionada oficial, DB privada, volumenes persistentes y gate de instalacion.
- Cron y consumidores de colas nativos, generacion de secretos, instalacion CLI y configuracion de zona Chile.
- Backup coherente de DB y archivos, guias de restauracion y traspaso.
- Dos borradores HTML para bienvenida y seguimiento; guia comercial sin precios inventados.

La interfaz es Mautic; el producto y remitente se presentan como Hefesto Marketing. No se ha aplicado un tema visual completo ni se modifico el nucleo. Formularios/campañas/segmentos se configuran en Mautic; las guias no son registros ya creados en una instancia.

## Despliegue en Coolify (MVP Hefesto)

Pasos detallados y validacion en `docs/COOLIFY.md`. Resumen:

- Recurso Docker Compose, build pack Docker Compose, dominio HTTPS al servicio `proxy`.
- Variables obligatorias: `MARKETING_HOST`, `ADMIN_EMAIL`, `ADMIN_PASSWORD`, `DB_PASSWORD`, `DB_ROOT_PASSWORD`, `TRUSTED_PROXIES`, `MAIL_FROM`. `MAILER_DSN` queda en `null://null` mientras no hay SMTP configurado. `MARKETING_HOST` solo dominio, sin `https://`; `ADMIN_PASSWORD` de al menos 32 caracteres.
- El compose no fuerza `name:` raiz, ni en redes ni en volumenes: Coolify asigna los suyos propios. No los declares fijos en el YAML.
- `web`, `cron` y `worker` declaran `build: .` y la misma etiqueta `hefesto-marketing-mautic:7.2.1`, asi Coolify construye la imagen sin depender de `pull_policy: never`.
- `TRUSTED_PROXIES` debe contener la IP/CIDR real del `proxy` interno (y de Traefik de Coolify si la cadena de proxies se procesa completa). Evitar `0.0.0.0/0`; un proxy de Internet es un riesgo de suplantacion.
- Verificacion local del contrato:

  ```sh
  bash scripts/coolify-check.sh
  ```

  Falla con `servicio: motivo` si el compose rompe el contrato Coolify.
