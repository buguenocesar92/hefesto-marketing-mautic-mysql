# Pruebas antes de operar

- Instalar por CLI y comprobar que dominio muestra 503 antes de ready y login despues; no asistente publico.
- Crear usuario de marketing sin administracion y comprobar permisos con cuenta separada.
- Importar solo datos ficticios de ejemplo; probar mapeo, duplicados y bajas. CSV es entrada de datos, no consentimiento automatico.
- Crear formulario piloto, probar alta duplicada y segmento esperado, revisar HTTPS e IP tras proxy.
- Con null://null confirmar ausencia de entregas externas; las cifras de "enviados" no equivalen a correo entregado.
- Tras autorizar/configurar proveedor, realizar prueba limitada con cuentas propias; verificar enlaces, baja, rebote y supresion.
- Confirmar cron/worker y que las colas no crecen indefinidamente. Revisar logs y limites de envio.
- Subir imagen/archivo, reiniciar servicios y confirmar persistencia.
- Respaldar y restaurar en staging aislado con null://null y cron/worker detenidos hasta revisar colas.

Estas pruebas operativas no se ejecutaron en el entorno de preparacion. Registrar responsable, fecha y evidencia antes de entregar produccion.
