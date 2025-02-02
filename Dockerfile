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

# Vérifier que les fichiers ont bien été copiés
RUN ls -la /app

# === 🚀 STAGE 2 : RUN STAGE ===
FROM node:20.14.0-alpine

# 🛡️ Création d'un utilisateur sécurisé non-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Définition du répertoire de travail
WORKDIR /app

# Copier uniquement les fichiers nécessaires depuis le build stage
COPY --from=builder /app /app

# Changer les permissions pour l'utilisateur sécurisé
RUN chown -R appuser:appgroup /app

# Exécuter l'application en tant qu'utilisateur non-root
USER appuser

# Exposer le port sur lequel l'application écoute
EXPOSE 3000

# Démarrer l’application avec npm
CMD ["npm", "start"]
