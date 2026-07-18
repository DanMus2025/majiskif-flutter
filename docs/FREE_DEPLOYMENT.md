# Deploiement gratuit recommande

## Choix recommande

- Backend API: Render Web Service (gratuit)
- Base de donnees: Neon Postgres (gratuit)

## Pourquoi ce choix

- Render permet d'exposer un backend FastAPI gratuitement
- Neon propose un Postgres gratuit sans carte bancaire et sans date de fin imposee
- Le backend est maintenant compatible avec `PORT` dynamique et `postgresql+psycopg://...`

## Variables a definir

Sur Render:

- `KESE_SECRET_KEY`
- `KESE_CREATOR_USERNAME`
- `KESE_CREATOR_PIN`
- `KESE_DATABASE_URL`

Exemple Neon:

```env
KESE_DATABASE_URL=postgresql+psycopg://user:password@ep-example.eu-central-1.aws.neon.tech/neondb?sslmode=require
```

## Deploiement backend sur Render

Le fichier `C:\tmp\MajiskifFlutter\render.yaml` est pret.

Si le depot Git contient tout le projet:

1. creer un compte Render
2. connecter le depot Git
3. deployer avec `render.yaml`
4. renseigner `KESE_SECRET_KEY`
5. renseigner `KESE_DATABASE_URL`

## Test attendu

Une fois deployee, l'URL backend devra repondre sur:

```text
https://votre-backend.onrender.com/health
```

et l'URL cloud a utiliser dans l'application sera:

```text
https://votre-backend.onrender.com/api/v1/cloud
```

## Si Render et Neon existent deja

Ne recommence pas toute la procedure si le backend, la base Neon et l'URL Render
sont deja en place. Fais seulement:

1. verifier les variables Render
2. verifier que `KESE_DATABASE_URL` pointe toujours vers Neon
3. verifier `https://votre-backend.onrender.com/health`
4. redeployer uniquement si le code backend a change
5. reconstruire l'APK et l'installeur Windows si le code Flutter ou l'URL cloud a change
