# demande du mot de passe
echo "Entrez le mot de passe à utiliser pour la base de donnée (vous devez vous en souvenir et il doit être suffisament compliqué à trouver pour protéger toutes vos données"
read password
# dépendences nécessaires pour wordpress
echo "Mise à Jour de la liste des paquets"
sudo apt update -y
echo "Installation des dépendances en cours..."
sudo apt install -y apache2
sudo apt install -y ghostscript
sudo apt install -y libapache2-mod-php
sudo apt install -y mysql-server
sudo apt install -y php
sudo apt install -y php-bcmath
sudo apt install -y php-curl
sudo apt install -y php-imagick
sudo apt install -y php-intl
sudo apt install -y php-json
sudo apt install -y php-mbstring
sudo apt install -y php-mysql
sudo apt install -y php-xml 
sudo apt install -y php-zip
echo "Installation de WordPress..."
echo "Création du dossier /srv/www"
sudo mkdir -p /srv/www
echo "Changement des droits pour le dossier /srv/www"
sudo chown www-data: /srv/www
echo "Téléchargement de la dernière version de wordpress depuis wordpress.org et décompressi ndans /srv/www"
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
echo "Configuration du site wordpress dans apache..."
printf "<VirtualHost *:80>\n    DocumentRoot /srv/www/wordpress\n    <Directory /srv/www/wordpress>\n        Options FollowSymLinks\n        AllowOverride Limit Options FileInfo\n        DirectoryIndex index.php\n        Require all granted\n    </Directory>\n    <Directory /srv/www/wordpress/wp-content>\n        Options FollowSymLinks\n        Require all granted\n    </Directory>\n</VirtualHost>
" > /etc/apache2/sites-available/wordpress.conf
echo "Activation du site wordpress"
sudo a2ensite wordpress
sudo a2enmod rewrite
echo "désactivatino de la page par défault Apache"
sudo a2dissite 000-default
echo "redémarrage du service apache2"
sudo service apache2 reload
echo "Mise en place de la base de données"
sudo apt install mysql-server -y
echo "CREATE DATABASE wordpress; CREATE USER wordpress@localhost IDENTIFIED BY '${password}'; GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost; FLUSH PRIVILEGES;" | mysql -u root
sudo service mysql start
echo "Confuguratino de wordpress pour l'utilisatino de la base de données"
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i "s/password_here/${password}/" /srv/www/wordpress/wp-config.php

# là on retire les lignes contenant AUTH_KEY, SECURE_AUTH_KEY, etc pour les remplacés par des variables aléatoires générés par l'api wordpress
sudo sed -i '/AUTH_KEY/d' /srv/www/wordpress/wp-config.php 
sudo sed -i '/SECURE_AUTH_KEY/d' /srv/www/wordpress/wp-config.php 
sudo sed -i '/LOGGED_IN_KEY/d' /srv/www/wordpress/wp-config.php 
sudo sed -i '/NONCE_KEY/d' /srv/www/wordpress/wp-config.php 
sudo sed -i '/AUTH_SALT/d' /srv/www/wordpress/wp-config.php
sudo sed -i '/NONCE_SALT/d' /srv/www/wordpress/wp-config.php
sudo sed -i '/LOGGED_IN_SALT/d' /srv/www/wordpress/wp-config.php
sudo sed -i '/SECURE_AUTH_SALT/d' /srv/www/wordpress/wp-config.php

sudo sed -i '/ABSPATH/d' /srv/www/wordpress/wp-config.php
sudo sed -i '/^}/d' /srv/www/wordpress/wp-config.php


wget https://api.wordpress.org/secret-key/1.1/salt/ -q -O - >> /srv/www/wordpress/wp-config.php # récupèration des variables aléatoires généré par wordpress pour un site sécurisé

printf "if ( ! defined( 'ABSPATH' ) ) {\n        define( 'ABSPATH', __DIR__ . '/' );\n}\n\nrequire_once ABSPATH . 'wp-settings.php';" >> /srv/www/wordpress/wp-config.php


echo "Tout est bon ! vous pouvez maintenant taper l'ip de ce serveur dans votre barre de navigation pour continuer l'installatino de wordpress"
