#!/bin/bash

if [[ "$1" == "on" ]]
then
sed 's/off;#autoindex/on;#autoindex/g' /etc/nginx/sites-enabled/config_on.conf > /etc/nginx/sites-enabled/change.conf 
mv etc/nginx/sites-enabled/change.conf etc/nginx/sites-enabled/config_on.conf
mv /var/www/html/index.nginx-debian.html /var/www/html/wordpress/tmp/index.nginx-debian.off 2> /dev/null # Para suprimir warnings de que no existe
service nginx restart
fi

if [[ "$1" == "off" ]]
then
sed 's/on;#autoindex/off;#autoindex/g' /etc/nginx/sites-enabled/config_on.conf > /etc/nginx/sites-enabled/change.conf 
mv etc/nginx/sites-enabled/change.conf etc/nginx/sites-enabled/config_on.conf
mv /var/www/html/wordpress/tmp/index.nginx-debian.off /var/www/html/index.nginx-debian.html 2> /dev/null # Para suprimir warnings de que no existe
service nginx restart
fi
