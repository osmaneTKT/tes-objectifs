#!/bin/bash

# 🚀 Importation de la clé GPG pour Amazon Corretto (Java)
sudo rpm --import https://yum.corretto.aws/corretto.key

# 📌 Ajout du dépôt Amazon Corretto pour Java 17
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

# 🔹 Installation de Java 17 Amazon Corretto et de wget
sudo yum install -y java-17-amazon-corretto-devel wget -y

# 📂 Création des répertoires pour l'installation de Nexus
mkdir -p /opt/nexus/    # Répertoire d'installation principal
mkdir -p /tmp/nexus/    # Répertoire temporaire pour l'extraction de l'archive
cd /tmp/nexus/

# 🌍 Définition de l'URL de téléchargement de Nexus
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"

# 📥 Téléchargement de Nexus depuis Sonatype
wget $NEXUSURL -O nexus.tar.gz
sleep 10  # Pause pour éviter les erreurs dues à la latence réseau

# 📦 Extraction des fichiers de Nexus
EXTOUT=`tar xzvf nexus.tar.gz`  # Extraction des fichiers
NEXUSDIR=`echo $EXTOUT | cut -d '/' -f1`  # Récupération du nom du dossier extrait
sleep 5  # Pause pour éviter les erreurs d'accès

# 🧹 Nettoyage du fichier d'archive après extraction
rm -rf /tmp/nexus/nexus.tar.gz

# 🚀 Copie des fichiers Nexus dans le répertoire final
cp -r /tmp/nexus/* /opt/nexus/
sleep 5

# 👤 Création de l'utilisateur 'nexus' (s'il n'existe pas)
if id "nexus" &>/dev/null; then
    echo "✅ L'utilisateur 'nexus' existe déjà."
else
    echo "📌 Création de l'utilisateur 'nexus'..."
    useradd nexus
fi

# 🔧 Attribution des permissions à l'utilisateur 'nexus' sur /opt/nexus
chown -R nexus:nexus /opt/nexus 

# 🛠️ Création du service systemd pour Nexus
cat <<EOT > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

# ⚙️ Configuration de l'exécution de Nexus en tant qu'utilisateur 'nexus'
echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc

# 🔄 Rechargement des services systemd pour prendre en compte Nexus
systemctl daemon-reload

# ▶️ Démarrage de Nexus
systemctl start nexus

# 📌 Activation de Nexus au démarrage du serveur
systemctl enable nexus

echo "✅ Nexus a été installé et démarré avec succès !"
echo "📌 Accédez à Nexus via http://<IP_DE_VOTRE_SERVEUR>:8081"
