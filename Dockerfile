# === 🚀 STAGE 1 : BUILD STAGE ===
FROM node:20.14.0-alpine AS builder
WORKDIR /app

# Copier uniquement package.json et package-lock.json pour optimiser le cache
COPY package*.json ./

# Installer les dépendances
RUN npm install --only=production

# Copier le reste de l’application (en excluant certains fichiers avec `.dockerignore`)
COPY . .

# === 🚀 STAGE 2 : RUN STAGE ===
FROM node:20.14.0-alpine

# Création d'un utilisateur non-root sécurisé
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copier uniquement les fichiers nécessaires depuis le build stage
COPY --from=builder /app /app

# Changer les permissions des fichiers pour l'utilisateur non-root
RUN chown -R appuser:appgroup /app

# Passer à l’utilisateur sécurisé
USER appuser

# Exposer le port de l'application
EXPOSE 3000

# Commande de démarrage de l'application
CMD ["npm", "start"]
