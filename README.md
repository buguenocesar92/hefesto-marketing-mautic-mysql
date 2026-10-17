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
