#!/bin/bash

echo "🚀 Début de l'installation pour Node.js, MySQL et SonarQube..."

# 🔹 Mise à jour des paquets et installation des dépendances
echo "📌 Mise à jour des paquets..."
sudo apt-get update -y
sudo apt-get install -y wget curl unzip ufw nginx zip

# 🔹 Augmenter les limites système (pour SonarQube)
echo "📌 Configuration des limites système..."
cp /etc/sysctl.conf /root/sysctl.conf_backup
cat <<EOT> /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
EOT

cp /etc/security/limits.conf /root/sec_limit.conf_backup
cat <<EOT> /etc/security/limits.conf
sonarqube   -   nofile   65536
sonarqube   -   nproc    4096
EOT

# 🔹 Installer Java (obligatoire pour SonarQube)
echo "📌 Installation de Java 17..."
sudo apt-get install openjdk-17-jdk -y
java -version

# 🔹 Installer MySQL au lieu de PostgreSQL
echo "📌 Installation de MySQL..."
sudo apt-get install mysql-server -y
sudo systemctl enable mysql
sudo systemctl start mysql

# 🔹 Sécuriser MySQL et créer la base de données pour SonarQube
echo "📌 Configuration de MySQL pour SonarQube..."
sudo mysql -u root -e "CREATE DATABASE sonarqube CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -u root -e "CREATE USER 'sonar'@'localhost' IDENTIFIED BY 'admin123';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON sonarqube.* TO 'sonar'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# 🔹 Installer Node.js et npm
echo "📌 Installation de Node.js et npm..."
sudo apt-get install -y nodejs npm

# 🔹 Vérification des versions
node -v
npm -v

# 🔹 Installer SonarQube
echo "📌 Téléchargement et installation de SonarQube..."
sudo mkdir -p /sonarqube/
cd /sonarqube/
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.7.96285.zip
sudo unzip -o sonarqube-9.9.7.96285.zip -d /opt/
sudo mv /opt/sonarqube-9.9.7.96285/ /opt/sonarqube

# 🔹 Créer un utilisateur pour SonarQube
echo "📌 Création de l'utilisateur 'sonar'..."
sudo groupadd sonar
sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube/ -R

# 🔹 Configurer SonarQube pour utiliser MySQL
echo "📌 Configuration de SonarQube pour MySQL..."
cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup
cat <<EOT> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube?useUnicode=true&characterEncoding=utf8&useSSL=false
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT

# 🔹 Configurer SonarQube comme un service systemd
echo "📌 Configuration du service systemd pour SonarQube..."
cat <<EOT> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target mysql.service

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT

# 🔹 Démarrer SonarQube
echo "📌 Démarrage de SonarQube..."
systemctl daemon-reload
systemctl enable sonarqube.service
systemctl start sonarqube.service

# 🔹 Installer et configurer Nginx comme proxy
echo "📌 Installation et configuration de Nginx..."
apt-get install nginx -y
rm -rf /etc/nginx/sites-enabled/default
rm -rf /etc/nginx/sites-available/default

cat <<EOT> /etc/nginx/sites-available/sonarqube
server {
    listen 80;
    server_name sonarqube.example.com;

    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;

        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
systemctl enable nginx.service
systemctl restart nginx.service

# 🔹 Autoriser les ports nécessaires via le pare-feu
echo "📌 Configuration du pare-feu..."
sudo ufw allow 80,9000,3306/tcp

# 🔹 Reboot du serveur après installation
echo "✅ Installation terminée ! Le serveur redémarrera dans 30 secondes..."
sleep 30
reboot
