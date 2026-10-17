<?php
// Credenciales en memoria del proceso, no en argumentos del sistema operativo.
require '/var/www/html/vendor/autoload.php';
$_SERVER['argv']=[
 'console','mautic:install','https://'.getenv('HEFESTO_HOST'),
 '--admin_firstname=Hefesto','--admin_lastname=Administrador','--admin_username=hefesto_admin',
 '--admin_email='.getenv('HEFESTO_ADMIN_EMAIL'),'--admin_password='.getenv('HEFESTO_ADMIN_PASSWORD'),
 '--no-interaction','--env=prod','--no-debug'
];
$_SERVER['argc']=count($_SERVER['argv']);
$application=include '/var/www/html/app/console-application.php';
$application->setAutoExit(false);
exit($application->run($input));
