<?php
try {
 $db=new PDO('mysql:host=db;dbname=mautic;charset=utf8mb4','mautic',getenv('MAUTIC_DB_PASSWORD'),[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
 if ((int)$db->query('SELECT COUNT(*) FROM users')->fetchColumn()<1) throw new RuntimeException();
 if (!touch('/var/www/html/config/.hefesto-ready')) throw new RuntimeException();
 echo "Instalacion marcada lista para acceso web. Falta completar aceptacion operativa.\n";
} catch (Throwable $e) { fwrite(STDERR,"No hay instalacion valida; no se habilita proxy.\n");exit(1); }
