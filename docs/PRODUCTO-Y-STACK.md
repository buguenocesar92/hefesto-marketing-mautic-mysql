# Producto Hefesto Marketing

Modelo comercial sugerido: implementacion inicial (dominio, formularios, segmentos y capacitacion) + mensualidad de hosting/respaldos/actualizaciones/soporte. Campañas, redaccion, volumen y servicio de correo se cotizan segun alcance. No se inventaron precios ni ingresos garantizados.

| Necesidad | Plataforma principal |
|---|---|
| Marketing y campañas | Mautic + MySQL 8.4 |
| Venta y oportunidad comercial | Odoo o Dolibarr |
| Conversaciones con clientes | Chatwoot |
| Cursos | Moodle |
| Archivos | Nextcloud |
| Proyectos y tareas | OpenProject |

Usar herramienta existente para el proceso principal. Integraciones por API/webhooks con secretos server-side y reintentos controlados. WordPress/WooCommerce puede aportar formulario/venta; n8n puede coordinar cambios de estado. No se implementaron estas conexiones en este paquete.

Supabase PostgreSQL no ejecuta la DB nativa de Mautic; si una app Hefesto usa Supabase, sincronizar solo campos necesarios por API, evitando dobles fuentes de verdad y respetando bajas en todos los sistemas.

Preferir instancia y DB separadas por cliente cuando se promete aislamiento. Roles de una sola instalacion no equivalen a tenants independientes frente al administrador.
