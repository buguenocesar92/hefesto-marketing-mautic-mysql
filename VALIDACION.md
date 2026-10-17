# Validacion y limites

Preparado 14-10-2026. Se revisaron release Mautic 7.2.1, tag Docker 7.2.1-20260923-apache, requisitos Mautic 7 (MySQL >=8.4) y roles/volumenes oficiales. Codigo del comando instalador y bin/console contrastado con tag 7.2.1.

Validaciones locales: YAML, variables requeridas, shell, generador de secretos y ZIP. Build ejecuta php -l. No hay Docker/PHP en entorno de preparacion; imagen, instalacion, cron, colas y restauracion necesitan probarse en staging. No hay instancia publicada ni correo enviado.

Fuentes:
https://mautic.org/releases/
https://hub.docker.com/r/mautic/mautic/tags
https://github.com/mautic/docker-mautic
https://github.com/mautic/mautic/blob/7.x/UPGRADE-7.0.md
https://docs.mautic.org/en/7.2/getting_started/how_to_install_mautic.html

Generador probado con permisos 0600, claves aleatorias de 64 hex, sin imprimir secretos y sin sobrescribir .env. Wrapper de instalacion adapta argv en memoria al arranque nativo de console-application.php; evita incluir passwords en argumentos del sistema.
