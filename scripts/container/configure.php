<?php
$file='/var/www/html/config/local.php';
$parameters=[];
if (!is_file($file)) { fwrite(STDERR,"Falta local.php; iniciar contenedor primero.\n"); exit(1); }
require $file;
$parameters['site_url']='https://'.getenv('HEFESTO_HOST');
$parameters['default_timezone']='America/Santiago';
$parameters['default_locale']='es';
$parameters['trusted_proxies']=array_values(array_filter(array_map('trim',explode(',',getenv('HEFESTO_TRUSTED_PROXIES')))));
$parameters['mailer_dsn']=getenv('MAUTIC_MAILER_DSN') ?: 'null://null';
$parameters['mailer_from_email']=getenv('MAUTIC_MAILER_FROM_EMAIL');
$parameters['mailer_from_name']=getenv('MAUTIC_MAILER_FROM_NAME') ?: 'Hefesto Marketing';
$tmp=$file.'.hefesto.tmp';
if (file_put_contents($tmp,"<?php\n\$parameters = ".var_export($parameters,true).";\n")===false) exit(1);
chmod($tmp,0640);
if (!rename($tmp,$file)) exit(1);
echo "Configuracion aplicada. Transporte null descarta correos si sigue seleccionado.\n";
