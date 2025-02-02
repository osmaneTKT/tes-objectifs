# === 🚀 STAGE 1 : BUILD STAGE ===
FROM node:20.14.0-alpine AS builder

# Définition du répertoire de travail
WORKDIR /app

# Copier uniquement package.json et package-lock.json pour optimiser le cache Docker
COPY package*.json ./

# Installer les dépendances en mode production
RUN npm install --only=production

# Copier le reste de l’application (en excluant certains fichiers avec `.dockerignore`)
COPY . .

CMD ["npm", "start"]

