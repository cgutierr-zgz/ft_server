#!/bin/bash
mv /var/www/html/index.nginx-debian.html /var/www/html/wordpress/tmp/index.nginx-debian.off
service mysql start

echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password
echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql -u root --skip-password
echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password

mysql -u root --skip-password wordpress < wordpress.sql

service php7.3-fpm start

service nginx start

if [[ "$AUTOINDEX" == "ON" ]]
then
sed 's/off;#autoindex/on;#autoindex/g' /etc/nginx/sites-enabled/config_on.conf > /etc/nginx/sites-enabled/change.conf 
mv etc/nginx/sites-enabled/change.conf etc/nginx/sites-enabled/config_on.conf
mv /var/www/html/index.nginx-debian.html /var/www/html/wordpress/tmp/index.nginx-debian.off 2> /dev/null # Para suprimir warnings de que no existe
service nginx restart
fi

if [[ "$AUTOINDEX" == "OFF" ]]
then
sed 's/on;#autoindex/off;#autoindex/g' /etc/nginx/sites-enabled/config_on.conf > /etc/nginx/sites-enabled/change.conf 
mv etc/nginx/sites-enabled/change.conf etc/nginx/sites-enabled/config_on.conf
mv /var/www/html/wordpress/tmp/index.nginx-debian.off /var/www/html/index.nginx-debian.html 2> /dev/null # Para suprimir warnings de que no existe
service nginx restart
fi

bash
