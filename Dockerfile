# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cgutierr <cgutierr@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/03/13 18:40:38 by cgutierr          #+#    #+#              #
#    Updated: 2021/05/18 16:01:39 by cgutierr         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

################################################################################
#                              REQUERIMIENTOS                                  #
################################################################################
# Instalar un servidor web con Nginx dentro de un solo contenedor Docker
# Tendrá que funcionar sobre Debian Buster
# Servicios:
#	· Wordpress (Lo tendrá que instalar Ud. mismo)
#	· PhpMyAdmin
#	· MySQL
#
# La base de datos SQL debe funcionar con Wordpress y PhpMyAdmin
#
# Cuando sea posible se debe poder usar el protocolo SSL
#
# Debe redirigir al sitio correcto en función de la URL introducida
#
# Debe funcionar con un índice automático, que se puede desactivar
################################################################################
#                                   USAGE                                      #
################################################################################
# Build:
#	docker build -t ft_server:latest ./
#		-t		=	Nos permite definir un nombre
# Run:
# Creamos el contenedor, entrando en el bash, seteando ENV y borrádolo al finalizar
#	docker run -it --rm -p 80:80 -p 443:443 --env "AUTOINDEX"="OFF" --name test ft_server:latest
#	docker run -it --rm -p 80:80 -p 443:443 --name test ft_server:latest
#
# Creamos el contenedor, entrando en el bash, seteando ENV y borrádolo al finalizar
#	docker run -it -p 80:80 -p 443:443 --env "AUTOINDEX"="OFF" --name test ft_server:latest
#	docker run -it -p 80:80 -p 443:443 --name test ft_server:latest
#
# Entrar en el bash del contenedor ya iniciado:
#	docker exec -it test bash
#		-p		=	Asigna un puerto para poder acceder después
#		-it		=	Permite acceder a la terminal del contenedor
#		--rm	=	Eliminará el contenedor después de que este se detenga
#		--name	=	Asigna el nombre al contenedor

FROM	debian:buster

LABEL	maintainer	=	"cgutierr"
LABEL	contact		=	"cgutierr@student.42madrid.com"
LABEL 	version		=	"1.0"

# Actualizamos y hacemos upgrade
RUN		apt-get update && apt-get upgrade -y

# Instalamos VIM
RUN		apt-get install -y --no-install-recommends vim

# Instalamos NGINX
RUN		apt-get install -y --no-install-recommends nginx

# Copiamos nuestra configuración de NGINX a la carpeta por defecto de NGINX
#	Archivo: config.conf
COPY	./srcs/utils/config_on.conf /etc/nginx/sites-enabled/

# Instalamos OpenSSL
RUN		apt-get install --no-install-recommends openssl

# Generamos nuestro certificado SSL y se exporta a la ubicación indicada en el
#	archivo de configuración de NGINX
#	Archivo: config_on.conf
RUN		openssl req -x509 -nodes -days 365 \
	-subj "/C=ES/ST=Madird/L=Madrid/O=42/OU=42Madrid/CN=cgutierr" \
	-newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt
# openssl:			Es la herramienta de línea de comandos básica para crear y
#	administrar certificados, claves, y otros archivos de OpenSSL.
# req:				Este subcomando especifica que deseamos usar la
#	administración de la solicitud de firma de certificados (CSR) X.509. El
#	“X.509” es un estándar de infraestructura de claves públicas al que se 
#	adecuan SSL y TLS para la administración de claves y certificados a través
#	de él. Queremos crear un nuevo certificado X.509, por lo que usaremos este
#	subcomando.
# -x509:			Modifica aún más el subcomando anterior al indicar a la
#	utilidad que deseamos crear un certificado autofirmado en lugar de generar
#	una solicitud de firma de certificados, como normalmente sucede.
# -nodes:			Indica a OpenSSL que omita la opción para proteger nuestro
#	certificado con una frase de contraseña. Necesitamos que Apache pueda leer
#	el archivo, sin intervención del usuario, cuando se inicie el servidor.
#	Una frase de contraseña evitaría que esto suceda porque tendríamos que
#	ingresarla tras cada reinicio.
# -days 365:		Esta opción establece el tiempo durante el cual el
#	certificado se considerará válido. En este caso, lo configuramos por un año.
# -newkey rsa:2048:	Especifica que deseamos generar un nuevo certificado y una
#	nueva clave al mismo tiempo. No creamos la clave que se requiere para firmar
#	el certificado en un paso anterior, por lo que debemos crearla junto con el
#	certificado. La parte rsa:2048 le indica que cree una clave RSA de 2048 bits
#	de extensión.
# -keyout:			Esta línea indica a OpenSSL dónde colocar el archivo de
#	clave privada generado que estamos creando.
# -out:				Indica a OpenSSL dónde colocar el certificado que creamos

# Instalamos PHP
RUN		apt-get install -y --no-install-recommends php-fpm php-mysql php-xml \
	php-mbstring php-gettext

# Instalamos MySQL-MariaDB
RUN		apt-get install -y --no-install-recommends mariadb-server

# Copiamos nuestro paquete de phpMyAdmin y Wordpress a la ruta especificada
#	Archivo: config.inc.php
COPY	./srcs/phpMyAdmin-5.1.0 /var/www/html/phpmyadmin
#	Archivo: wp-config.php
COPY	./srcs/wordpress /var/www/html/wordpress

# Asignamos propiedad del directorio al usuario que debe referenciar el actual
#	usuario del sistema y cambiamos los permisos
RUN		chown -R $USER:$USER /var/www/ && chmod -R 755 /var/www/
RUN		chmod -R 777 /var/www/html/phpmyadmin/tmp/

# Borramos la cache de los paquetes
RUN		rm -rf /var/lib/apt/lists/*

# Copiamos muestro script de entrada, la base de datos .sql y el autoindex
COPY	./srcs/utils/server.sh ./
COPY	./srcs/utils/wordpress.sql ./
COPY	./srcs/utils/autoindex.sh ./

# Ejecutamos el script de entrada
CMD		bash server.sh

# Exponemos el puerto 80 y 442 de nuestra imagen contenedor
EXPOSE	80

# Seteamos por defecto a ON el autoindex
ENV		"AUTOINDEX"="ON"
