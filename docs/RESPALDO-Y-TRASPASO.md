# Respaldo y recuperacion

`bash scripts/manage.sh backup` exige Docker Compose, Bash, flock y Python3, desde MISMO proyecto de despliegue. Detiene proxy y procesos escritores, extrae dump y tar de config/logs/files/images, genera hashes y reinicia. Hay indisponibilidad durante la copia. Si falla, revisar logs antes de reanudar; no usar backup parcial. No hay tarea automatica programada: configurarla con alerta y retencion acordada.

Config contiene secret_key, DB y posiblemente SMTP/integraciones. Cifrar respaldos, guardarlos fuera del VPS y preservar .env en gestor seguro. Una copia de MySQL sola no restaura imagenes/archivos. Plugins propios deben estar versionados en Dockerfile/repositorio.

Restaurar en staging: usar misma imagen y nueva DB vacia con usuario mautic, importar database.sql comprobando salida; extraer archivos a volumenes correspondientes y asegurar propietario www-data. Editar config/local.php restaurado ANTES de abrir servicios para apuntar DB/host al destino y poner mailer_dsn=null://null; conservar secret_key. Configuracion de entorno y local.php deben concordar. No arrancar clon con credenciales de produccion ni activar cron/worker hasta revisar campañas y colas. El tar contiene marker ready: eliminarlo durante preparacion de restauracion y reponer solo tras verificar DB e instalacion con ready.php.

Probar login, contacto ficticio, segmento y adjunto. Confirmar ninguna entrega externa desde copia. Para traslado real: congelar origen, backup final, restaurar destino, comprobar y cambiar DNS; evitar dos instancias ejecutando misma campaña.

Actualizaciones: backup completo, staging y revision de plugins. La imagen oficial puede ejecutar migraciones al iniciar web si detecta instalacion, incluso si una variable de control parece desactivarlas segun version. Mantener worker/cron detenidos durante upgrade y leer logs. No aplicar actualizaciones desde la interfaz a codigo efimero. Revertir requiere DB y archivos compatibles, no solo imagen vieja.

Traspaso: repo, imagen/tag/digest real, dump y archivos cifrados, dominio, cron, configuracion de correo, permisos, resultados de pruebas y credenciales por canal seguro. Rotar accesos al cambiar responsable.
