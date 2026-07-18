# KESE - Checklist de validation produit

Cette checklist sert a valider que le produit est pret localement, avant tout
deploiement Internet reel.

## 1. Lancement local

- [ ] Le backend cloud demarre sans erreur
- [ ] `http://127.0.0.1:8766/health` repond
- [ ] Le frontend web s'ouvre sur `http://127.0.0.1:5200/`
- [ ] L'application ne montre pas d'erreur de build ni d'ecran vide

## 2. Parcours client

- [ ] La page d'activation est claire au premier regard
- [ ] Les boutons `Premiere activation` / `Ajouter un appareil` sont visibles
- [ ] La page login est propre et sans debordement
- [ ] La page aide et conditions de licence est lisible et complete

## 3. Espace createur

- [ ] L'acces createur s'ouvre depuis `Version 1.0.0`
- [ ] L'authentification createur fonctionne
- [ ] La modification des acces createur fonctionne
- [ ] La supervision des entreprises s'affiche
- [ ] La creation d'entreprise fonctionne
- [ ] La modification / suspension / reactivation d'une licence fonctionne
- [ ] La suppression d'une licence inutilisee fonctionne sans casser la supervision
- [ ] La fiche d'activation se telecharge
- [ ] La preparation du premier appareil remplit bien l'ecran d'activation

## 4. Activation / liaison

- [ ] Le premier appareil s'active avec le code licence
- [ ] La cle entreprise s'affiche apres activation
- [ ] Un autre appareil peut se rattacher avec la cle entreprise
- [ ] L'utilisateur retrouve bien son entreprise apres connexion

## 5. Fonctionnement local

- [ ] L'application reste utilisable hors ligne apres activation
- [ ] Les ventes / operations locales continuent a s'enregistrer
- [ ] Aucun message critique n'apparait hors connexion

## 6. Synchronisation

- [ ] Quand Internet revient, la synchronisation repart
- [ ] Les operations locales sont envoyees
- [ ] Les operations distantes sont recuperees
- [ ] Il n'y a pas de doublons visibles dans le parcours normal

## 7. Rendu professionnel

- [ ] Les pages d'entree sont coherentes entre elles
- [ ] Les textes sont bien alignes, lisibles et sans debordement
- [ ] Les logos / images se chargent correctement
- [ ] L'ensemble donne une impression serieuse et vendable

## 8. Validation finale

Le produit peut etre considere comme pret quand :

- [ ] le parcours createur fonctionne de bout en bout
- [ ] le parcours client fonctionne de bout en bout
- [ ] le hors ligne local fonctionne
- [ ] la synchronisation fonctionne en retour reseau
- [ ] le rendu web est propre
- [ ] le test telephone ne revele pas de blocage critique
