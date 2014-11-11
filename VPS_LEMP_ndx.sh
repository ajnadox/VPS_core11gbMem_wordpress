#!/bin/bash
echo -e "This script sets up LEMP Stack on Ubuntu (14.04x64) with Nginx, MySql 5.5, PHP-FPM 5.5, phpMyAdmin"
echo -e "Optimized for 1 Core - 1024 MB, more finetuning can of course always be made."
echo -e "All suggestions are welcome / André - Nadox // aj@nadox.se"
clear
echo -e "Your IPv4 & IPv6 addresses on server:"
ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'
echo 
echo -e "Please type the password you want for MySQL Root account: \c "
read MYSQLROOTPASS
echo -e "Please type the MySQL database name that shall be created (example: wordpress): \c "
read MYSQLDATABASE
echo -e "Please type your webserver address (domainname.123 or IP, look at the top of this side): \c "
read SERVERNAMEORIP
echo -e "Please type the MySQL username you want to create: \c "
read MYSQLDATABASEUSER
echo -e "Please type the MySQL password that user shall have: \c "
read MYSQLUSERPASS
sudo apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get autoremove && sudo apt-get autoclean
sudo apt-get install -y nginx
echo "mysql-server mysql-server/root_password password $MYSQLROOTPASS" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQLROOTPASS" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQLROOTPASS" | sudo debconf-set-selections
sudo apt-get -y install mysql-server php5-fpm php5-mysql php5-curl php5-mcrypt php5-gd
clear
echo -e "In Next step DONT select any Web server to reconfigure automatically"
echo -e "Also in question 'Configure database for phpmyadmin with dbconfig-common' select NO"
read -p "Press [Enter] key to start phpMyAdmin installation..."
sudo apt-get -y install phpmyadmin
sudo mkdir /usr/share/nginx/wordpress
sudo rm /etc/nginx/sites-enabled/default

sudo mv /usr/share/phpmyadmin /usr/share/secu-phpmyadmin
sudo ln -s /usr/share/secu-phpmyadmin /usr/share/nginx/wordpress
sudo php5enmod mcrypt
sudo service php5-fpm restart

sudo printf 'add_header X-Cache $upstream_cache_status;\n' > /etc/nginx/sites-available/wp-ms
sudo printf "server {\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "    listen [::]:80 ipv6only=off;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "    server_name "$SERVERNAMEORIP" *."$SERVERNAMEORIP" ;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "    root /usr/share/nginx/wordpress;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "    index index.php index.html index.htm;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "    location / {\n" >> /etc/nginx/sites-available/wp-ms
sudo printf '        try_files $uri $uri/ /index.php?$args ;\n' >> /etc/nginx/sites-available/wp-ms
sudo printf "    }\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "    location ~ /favicon.ico {\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "        access_log off;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "        log_not_found off;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "   }\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "    location ~ \.php$ {\n" >> /etc/nginx/sites-available/wp-ms
sudo printf '        try_files $uri =404;\n' >> /etc/nginx/sites-available/wp-ms
sudo printf '        fastcgi_split_path_info ^(.+\.php)(/.+)$;\n' >> /etc/nginx/sites-available/wp-ms
sudo printf "        fastcgi_cache microcache;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf '        fastcgi_cache_key $scheme$host$request_uri$request_method;\n' >> /etc/nginx/sites-available/wp-ms
sudo printf "        fastcgi_cache_valid 200 301 302 30s;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "        fastcgi_cache_use_stale updating error timeout invalid_header http_500;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "        fastcgi_pass_header Set-Cookie;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "        fastcgi_pass_header Cookie;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "        fastcgi_ignore_headers Cache-Control Expires Set-Cookie;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "        fastcgi_pass unix:/var/run/php5-fpm.sock;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "        fastcgi_index index.php;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "        include fastcgi_params;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "    }\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "\n" >> /etc/nginx/sites-available/wp-ms
sudo printf '    access_log  /var/log/nginx/$host-access.log;\n' >> /etc/nginx/sites-available/wp-ms
sudo printf "    error_log   /var/log/nginx/wpms-error.log;\n" >> /etc/nginx/sites-available/wp-ms
sudo printf "}\n" >> /etc/nginx/sites-available/wp-ms

sudo ln -s /etc/nginx/sites-available/wp-ms /etc/nginx/sites-enabled/wp-ms
sudo service nginx restart

sudo mysql -uroot -p$MYSQLROOTPASS -e "create database ${MYSQLDATABASE}"
sudo mysql -uroot -p$MYSQLROOTPASS -e "CREATE USER '${MYSQLDATABASEUSER}'@'localhost' IDENTIFIED BY '${MYSQLUSERPASS}';"
sudo mysql -uroot -p$MYSQLROOTPASS -e "GRANT ALL PRIVILEGES ON ${MYSQLDATABASE}.* TO '${MYSQLDATABASEUSER}'@'localhost';"
sudo mysql -uroot -p$MYSQLROOTPASS -e "FLUSH PRIVILEGES;"

sudo wget http://wordpress.org/latest.tar.gz
sudo tar -xf latest.tar.gz
sudo mv wordpress/* /usr/share/nginx/wordpress/
sudo mkdir /usr/share/nginx/wordpress/wp-content/uploads
sudo chown -R www-data:www-data /usr/share/nginx/wordpress
sudo rm -rf wordpress
sudo rm -rf latest.tar.gz

sed -i "s/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
sed -i "s/^;listen.owner = www-data/listen.owner = www-data/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/^;listen.group = www-data/listen.group = www-data/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/^;listen.mode = 0660/listen.mode = 0660/" /etc/php5/fpm/pool.d/www.conf
mkdir /usr/share/nginx/cache
sed -i "s/^\tworker_connections 768;/\tworker_connections 1536;/" /etc/nginx/nginx.conf
sed -i "s/^\t#passenger_ruby \/usr\/bin\/ruby;/\t#passenger_ruby \/usr\/bin\/ruby;\n\n\tfastcgi_cache_path \/usr\/share\/nginx\/cache\/fcgi levels=1:2 keys_zone=microcache:10m max_size=1024m inactive=1h;/" /etc/nginx/nginx.conf
sed -i "s/^\taccess_log \/var\/log\/nginx\/access.log;/\taccess_log off;\n\t#access_log \/var\/log\/nginx\/access.log;/" /etc/nginx/nginx.conf

sudo service nginx restart
sudo service mysql restart
sudo service php5-fpm restart

NGINXDOCROOT="/usr/share/nginx/wordpress"
echo -e "............................."
echo -e "Start Wordpress installation by going to: http://$SERVERNAMEORIP"
echo -e "Your MySQL database name is: $MYSQLDATABASE"
echo -e "Your MySQL database username is: $MYSQLDATABASEUSER"
echo -e "Your MySQL database password is: $MYSQLUSERPASS"
echo -e "Your Nginx document root is: $NGINXDOCROOT"
echo -e "............................."
echo -e "Access phpMyAdmin @ http://$SERVERNAMEORIP/secu-phpmyadmin"
echo -e "with User: $MYSQLDATABASEUSER and Password: $MYSQLUSERPASS"
echo -e "Your MySQL root password is: $MYSQLROOTPASS"
echo -e "............................."
read -p "Press [Enter] key to start updating & cleaning of temp files and then reboot..."
#sudo dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
sudo apt-get autoremove && sudo apt-get autoclean
sudo rm -rf VPS_LEMP_ndx.sh
sudo reboot