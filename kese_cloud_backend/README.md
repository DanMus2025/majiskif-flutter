# KESE Cloud Backend

Backend cloud dedie a KESE.

## Fonctions

- activation licence
- connexion cloud
- bootstrap entreprise
- synchronisation push / pull
- separation multi-entreprise par `tenant_key`

## Demarrage

```powershell
cd C:\tmp\MajiskifFlutter\kese_cloud_backend
py -3.11 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe run.py
```

## Endpoints

- `GET /health` sur `http://127.0.0.1:8766/health`
- `POST /api/v1/cloud/creator/auth`
- `PUT /api/v1/cloud/creator/profile`
- `GET /api/v1/cloud/creator/tenants`
- `POST /api/v1/cloud/tenants`
- `POST /api/v1/cloud/activate`
- `POST /api/v1/cloud/login`
- `GET /api/v1/cloud/bootstrap`
- `POST /api/v1/cloud/sync/push`
- `GET /api/v1/cloud/sync/pull`

## Configuration

Copie `C:\tmp\MajiskifFlutter\kese_cloud_backend\.env.example` vers un fichier
`.env` si tu veux personnaliser :

- `KESE_CREATOR_USERNAME`
- `KESE_CREATOR_PIN`
- `KESE_DATABASE_URL`

Le backend fonctionne en SQLite local par defaut, mais il est maintenant
prepare pour une base MySQL/MariaDB via une URL du type :

```env
KESE_DATABASE_URL=mysql+pymysql://user:password@host:3306/kese_cloud?charset=utf8mb4
```

## Deploiement propre

Des fichiers de base sont prets pour un backend cloud central :

- `C:\tmp\MajiskifFlutter\kese_cloud_backend\Dockerfile`
- `C:\tmp\MajiskifFlutter\kese_cloud_backend\docker-compose.production.example.yml`

Le principe attendu en production est simple :

1. un seul backend cloud accessible sur Internet
2. une seule base de donnees centrale
3. toutes les machines pointent vers ce meme backend
4. chaque entreprise reste reliee a son propre `tenant_key`

## Build web cible production

Pour que le frontend web pointe directement vers le bon backend cloud, utilise
directement Flutter:

```powershell
cd C:\tmp\MajiskifFlutter
flutter build web --no-tree-shake-icons --dart-define=KESE_CLOUD_BASE_URL=https://votre-domaine.tld/api/v1/cloud
```

Le build web integre alors cette URL comme base cloud par defaut.

## Generateur de licences et d'entreprises

Le backend sait deja creer une entreprise, un administrateur initial et une
licence cloud. Pour le faire sans interface graphique, utilise le script :

```powershell
cd C:\tmp\MajiskifFlutter\kese_cloud_backend
.\.venv\Scripts\python.exe .\tools\create_tenant_license.py `
  --company-name "KESE Boutique" `
  --owner-name "Daniel Test" `
  --phone "+243971238634" `
  --email "contact@kese.local" `
  --address "Bukavu" `
  --branch-name "Site principal" `
  --admin-full-name "Administrateur Principal" `
  --admin-username "admin" `
  --admin-pin "Admin@2026" `
  --plan-code "standard" `
  --max-devices 5
```

Le script retourne notamment :

- `tenant_key`
- `license_code`
- `admin_username`
- `admin_pin`
- `branch_code`

Cela couvre deja la creation d'entreprise et la generation de licence, meme si
un vrai espace createur visuel reste encore a construire.
