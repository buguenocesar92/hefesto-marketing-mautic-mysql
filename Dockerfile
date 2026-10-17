FROM mautic/mautic:7.2.1-20260923-apache
COPY scripts/container /opt/hefesto
RUN for file in /opt/hefesto/*.php; do php -l "$file" || exit 1; done
