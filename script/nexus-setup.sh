#!/bin/bash

echo "🚀 Début de l'installation de Nexus pour Node.js..."

# Mise à jour et installation des paquets nécessaires
echo "📌 Installation des dépendances..."
sudo yum install -y wget nodejs npm unzip

# Création des dossiers nécessaires
echo "📌 Création des répertoires pour Nexus..."
mkdir -p /opt/nexus/   
mkdir -p /tmp/nexus/                           
cd /tmp/nexus/

# Télécharger la dernière version de Nexus
echo "📌 Téléchargement de Nexus Repository Manager..."
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
wget $NEXUSURL -O nexus.tar.gz
sleep 10

# Extraction des fichiers
echo "📌 Extraction de Nexus..."
EXTOUT=`tar xzvf nexus.tar.gz`
NEXUSDIR=`echo $EXTOUT | cut -d '/' -f1`
sleep 5

# Nettoyage du fichier d'installation et déplacement des fichiers
echo "📌 Installation de Nexus dans /opt/nexus/"
rm -rf /tmp/nexus/nexus.tar.gz
cp -r /tmp/nexus/* /opt/nexus/
sleep 5

# Création de l'utilisateur Nexus
echo "📌 Création de l'utilisateur 'nexus'..."
useradd nexus
chown -R nexus.nexus /opt/nexus 

# Création du service systemd pour Nexus
echo "📌 Configuration du service systemd pour Nexus..."
cat <<EOT>> /etc/systemd/system/nexus.service
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

# Configuration de l'exécution de Nexus en tant que 'nexus'
echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc

# Démarrage et activation de Nexus
echo "📌 Démarrage de Nexus..."
systemctl daemon-reload
systemctl start nexus
systemctl enable nexus

# Attendre que Nexus démarre complètement
echo "⏳ Attente du démarrage complet de Nexus (60 secondes)..."
sleep 60

# Vérifier si Nexus est en cours d'exécution
if systemctl is-active --quiet nexus; then
    echo "✅ Nexus est en cours d'exécution !"
else
    echo "❌ Échec du démarrage de Nexus. Vérifie les logs : /opt/nexus/$NEXUSDIR/sonatype-work/nexus3/log/"
    exit 1
fi

# Configuration automatique de npm pour utiliser Nexus
echo "📌 Configuration de npm pour utiliser Nexus..."
npm set registry http://localhost:8081/repository/npm-private/

echo "✅ Installation et configuration de Nexus pour npm terminée !"
echo "📌 Accède à Nexus sur http://localhost:8081"
