# === 🏗️ STAGE 1 : BUILD STAGE ===
FROM node:20.14.0-alpine AS builder

# Définition du répertoire de travail
WORKDIR /app

# Copier uniquement package.json et package-lock.json pour optimiser le cache
COPY package*.json ./

# Installer les dépendances en mode production
RUN npm install 

# Copier le reste de l’application
COPY . .

# === 🚀 STAGE 2 : RUN STAGE ===
FROM node:20.14.0-alpine

# Définition du répertoire de travail
WORKDIR /app

# Copier uniquement les fichiers nécessaires depuis le build stage
COPY --from=builder /app /app

# Exposer le port sur lequel l'application écoute (modifiable si besoin)
EXPOSE 3000

# Démarrer l'application avec `npm start`
CMD ["npm", "start"]
