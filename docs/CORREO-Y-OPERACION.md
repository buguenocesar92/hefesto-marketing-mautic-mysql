# Transporte de correo y operacion

MAILER_DSN=null://null descarta correos. Sirve para preparar flujos sin entregas externas, no para comprobar inbox o medir envios reales. No importar contactos reales para simular entrega. Antes de cambiar transporte revisar campañas publicadas y colas: correos pendientes podrian procesarse con el nuevo proveedor.

Para SMTP usar DSN admitido por Symfony/Mautic, por ejemplo smtp://USUARIO_CODIFICADO:CLAVE_CODIFICADA@smtp.proveedor:587; codificar caracteres reservados y seguir TLS/autenticacion del proveedor. No subir DSN real al repo. El proveedor debe admitir ese uso y remitente; configurar dominio remitente, SPF/DKIM y politica DMARC con sus instrucciones.

Cambio controlado: detener cron/worker; guardar credenciales en Coolify; recrear servicios para cargar nuevas variables, ejecutar configuracion y cache clear; revisar destinatarios y cola antes de reanudarlos. manage.sh configure presupone que los contenedores ya recibieron las variables nuevas. Cambiar .env solo no actualiza contenedores existentes. No se envia correo de prueba por este paquete.

Probar primero con direcciones propias autorizadas: alta, bienvenida, enlace de baja y supresion posterior. Configurar rebotes y quejas mediante mecanismo compatible con proveedor; SMTP por si solo no proporciona procesamiento de eventos. Revisar tasa, rechazos y limites; no confundir un mensaje aceptado por SMTP con llegada a bandeja principal.

Cron actualiza segmentos y campañas; worker procesa transportes Doctrine configurados para correo y hits. Revisar logs y comandos disponibles en version instalada mediante bin/console list. No duplicar cron del host encima del contenedor. Los jobs de la imagen oficial deben revisarse contra cadencia/limites del contrato antes de una campaña grande.

No se habilitaron APIs de IA, WhatsApp/SMS, plugins de terceros, pago por suscripcion ni inbox de correo. Cada integracion requiere su alcance, permisos y credenciales.
