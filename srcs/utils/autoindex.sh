#!/bin/bash

if [[ "$1" == "on" ]]
then
sed 's/off;#autoindex/on;#autoindex/g' /etc/nginx/sites-enabled/config_on.conf > /etc/nginx/sites-enabled/change.conf 
mv etc/nginx/sites-enabled/change.conf etc/nginx/sites-enabled/config_on.conf
service nginx restart
fi

if [[ "$1" == "off" ]]
then
sed 's/on;#autoindex/off;#autoindex/g' /etc/nginx/sites-enabled/config_on.conf > /etc/nginx/sites-enabled/change.conf 
mv etc/nginx/sites-enabled/change.conf etc/nginx/sites-enabled/config_on.conf
service nginx restart
fi

#bash