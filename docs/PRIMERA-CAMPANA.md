# Primer flujo para Hefesto

Objetivo: atender solicitudes voluntarias sobre servicios. Los elementos siguientes son una guia de configuracion, no una campaña publicada.

1. Crear campos: servicio de interes, origen, estado comercial y registro del consentimiento/fecha cuando corresponda. No almacenar passwords ni secretos como campos.
2. Crear formulario "Quiero conocer Hefesto": nombre, correo, servicio y texto claro sobre uso de datos. Ajustar confirmacion y proteccion contra abuso. No cargar automaticamente resultados de Public Lead Finder como suscriptores.
3. Segmentar por interes: Web/Tienda, Gestion, Academia y Automatizacion. Excluir contactos dados de baja o marcados Do Not Contact.
4. Preparar correo de bienvenida con templates/bienvenida.html. Adaptar texto y remitente; comprobar tokens en vista previa con contacto de prueba.
5. Preparar seguimiento con templates/seguimiento.html; definir plazo, condicion y salida cuando hay respuesta comercial o baja.
6. Mantener campaña en borrador durante pruebas. Verificar que una baja evita nuevos mensajes del flujo y que no se reinscribe por otra importacion.
7. Vincular oportunidad a Odoo/Dolibarr solo mediante integracion autorizada, guardando ID externo e idempotencia. No se incluye puente operativo.

Borrador de secuencia: solicitud -> confirmacion/bienvenida -> espera acordada -> seguimiento si sigue pendiente -> terminar al agendar o darse de baja. Ofrecer al cliente revision humana de mensajes, frecuencia y audiencia antes de publicar.

Las aperturas pueden estar afectadas por privacidad y precarga de imagenes. Medir tambien solicitudes respondidas y reuniones, sin prometer atribucion exacta.
