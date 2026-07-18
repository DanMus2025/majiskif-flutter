# KESE - Architecture des bases de donnees

## 1. Objectif

KESE est concue comme une application :

- Android offline / online
- Desktop offline / online
- Web principalement online
- multi-entreprise

Chaque entreprise doit voir uniquement ses propres donnees, meme si plusieurs entreprises utilisent les memes noms d'utilisateur (`Admin`, `Caissier`, `Gestionnaire`).

La cle de separation est :

- `tenant_id` = identifiant unique de l'entreprise

## 2. Architecture retenue

### Base locale

Pour Android et Desktop, la base locale cible est :

- **SQLite**

Elle stocke :

- les parametres de l'entreprise
- les produits
- les clients
- les fournisseurs
- les utilisateurs de l'entreprise
- les ventes
- les tickets
- les factures
- les achats
- les depenses
- les mouvements de stock
- les messages
- les alertes
- la file d'attente de synchronisation

### Base centrale

Pour le mode online, la base centrale cible est :

- **PostgreSQL**

Elle conserve les memes entites metier, mais pour toutes les entreprises dans une base mutualisee.

La separation n'est pas faite par une base differente pour chaque client.
La separation est faite par :

- `tenant_id`

## 3. Cle de protection des donnees

Chaque ligne importante doit porter au minimum :

- `tenant_id`

Et tres souvent aussi :

- `branch_id`
- `device_id`
- `created_by_user_id`

Ainsi :

- un admin en Europe
- un caissier a Bukavu
- un gestionnaire sur un autre site

peuvent tous travailler dans la meme entreprise, sans melanger leurs donnees avec celles d'une autre entreprise.

## 4. Regle sur les noms d'utilisateurs

Les noms d'utilisateurs ne doivent pas etre uniques au niveau mondial.

La vraie contrainte est :

- `UNIQUE (tenant_id, username_normalized)`

Donc :

- Entreprise A peut avoir `Admin`
- Entreprise B peut avoir `Admin`

Ce n'est pas un conflit.

Le conflit existe seulement si deux comptes du **meme tenant** ont le meme `username_normalized`.

## 5. Fonctionnement offline

Quand l'utilisateur travaille offline :

1. l'action est ecrite en base SQLite locale
2. un enregistrement est ajoute dans `sync_queue`
3. l'entite est marquee comme `pending sync`

Exemples :

- vente
- achat
- depense
- mouvement de stock
- nouveau client
- reglement de credit

## 6. Fonctionnement online

Quand la connexion revient :

1. l'application lit `sync_queue`
2. elle envoie les operations a l'API
3. l'API ecrit en PostgreSQL
4. si tout est valide, l'operation devient `synced`
5. sinon elle devient `conflict` ou `failed`

## 7. Gestion des conflits

### Conflit de nom d'utilisateur

Cas :

- deux appareils du meme tenant creent offline le meme `username`

Resolution :

1. le premier a synchroniser est accepte
2. le second est refuse par la contrainte SQL
3. une entree est creee dans `sync_conflicts`
4. l'admin ou le gestionnaire renomme le compte
5. la synchronisation est relancee

### Conflits recommandes a resoudre manuellement

- utilisateurs
- roles
- parametres sensibles

### Conflits plus faciles a automatiser

- ventes
- lignes de vente
- depenses
- messages

## 8. Recommandation fonctionnelle

Pour reduire les conflits :

- creation d'utilisateurs : de preference **en ligne**
- parametres entreprise : de preference **en ligne**
- ventes / achats / stock / depenses : offline autorise

## 9. Donnees de demonstration

Les produits de demonstration actuels peuvent etre gardes comme seed initial :

- Pain
- Coca
- Savon
- Riz 1kg
- Meche 12 pouces

L'entreprise cliente peut ensuite :

- les supprimer
- les modifier
- ajouter ses vraies donnees

## 10. Fichiers livres dans ce socle

- `database/kese_multitenant_schema.sql`
  - schema de reference SQLite/PostgreSQL

- `lib/data/kese_store_snapshot.dart`
  - export structure de l'etat applicatif actuel vers un format de synchronisation

## 11. Prochaine etape technique

Les prochaines etapes naturelles sont :

1. brancher une vraie persistance SQLite locale
2. charger/sauvegarder `AppStore` depuis SQLite
3. ajouter une API backend multi-tenant
4. brancher `sync_queue` et `sync_conflicts`
5. proteger chaque requete serveur par `tenant_id`
