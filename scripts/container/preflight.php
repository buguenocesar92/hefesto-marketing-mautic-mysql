<?php
function fail(string $message): never { fwrite(STDERR,$message.PHP_EOL); exit(1); }
foreach (['MAUTIC_DB_PASSWORD','HEFESTO_ADMIN_EMAIL','HEFESTO_ADMIN_PASSWORD','HEFESTO_HOST','HEFESTO_TRUSTED_PROXIES','MAUTIC_MAILER_FROM_EMAIL'] as $key) {
 $value=getenv($key);
 if (!$value || str_contains($value,'REEMPLAZAR')) fail('Falta configurar '.$key);
}
if (!filter_var(getenv('HEFESTO_ADMIN_EMAIL'),FILTER_VALIDATE_EMAIL)) fail('Correo administrador no valido');
if (strlen(getenv('HEFESTO_ADMIN_PASSWORD'))<32) fail('Password administrador demasiado corto');
if (str_contains(getenv('HEFESTO_TRUSTED_PROXIES'),'0.0.0.0/0')) fail('No confiar en Internet completo como proxy');
if (!preg_match('/^[a-zA-Z0-9][a-zA-Z0-9.-]+$/D',getenv('HEFESTO_HOST'))) fail('Dominio sin esquema, puerto ni ruta requerido');
try {
 $db=new PDO('mysql:host=db;port=3306;dbname=mautic;charset=utf8mb4','mautic',getenv('MAUTIC_DB_PASSWORD'),[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
 $v=$db->query('SELECT VERSION()')->fetchColumn();
 if (!str_starts_with($v,'8.4.')) fail('Este paquete usa MySQL 8.4');
 $db->exec('CREATE TEMPORARY TABLE hefesto_preflight_check (id INT)');
 $db->exec('DROP TEMPORARY TABLE hefesto_preflight_check');
 echo "DB y configuracion inicial verificadas.\n";
} catch (Throwable $e) { fail('No se pudo validar DB. Revisar permisos, clave y estado sin compartir secretos.'); }
