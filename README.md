# Sorabot Digital

Site de services digitaux : **création de site web**, **trading (robots & indicateurs)**, **création de CV** et **solutions IA**.
Le client choisit une ou plusieurs offres, paie via **Orange Money**, et la commande arrive dans l'**admin** + sur **WhatsApp**.

## Fichiers

- `index.html` — page d'accueil publique (les 4 services, le panier, le paiement, WhatsApp).
- `admin.html` — tableau de bord privé pour voir et gérer les commandes.

## Modifier les offres et les prix

Tout se trouve dans `index.html`, dans la variable **`SERVICES`** (en haut du `<script>`).
Chaque offre a un `name`, une `desc` et un `price` (en **euros** — converti automatiquement dans la devise du client).
`price: 0` affiche « Sur devis ».

## Contacts

- WhatsApp / Orange Money : **+224 625 91 46 07**

## Mise en ligne

Site statique — hébergé via **GitHub Pages**.

## À améliorer (prochaine étape)

- Base de données temps réel (Supabase) pour que l'admin voie **toutes** les commandes de tous les clients.
- Authentification admin sécurisée (le mot de passe actuel est en clair côté navigateur).
