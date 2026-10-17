# `blog.sh` — Générateur de blog statique en Bash

Un moteur de blog en ligne de commande écrit en Bash utilisant **Pandoc**. Il permet de créer, éditer et relier des pages en Markdown, puis de compiler l'ensemble du site à la fois en **HTML** (avec sommaire généré automatiquement) et en **document PDF unique**.

## Fonctionnalités et commandes

| Commande | Action | Détails |
| :--- | :--- | :--- |
| `./blog.sh editer <page>` | Créer ou éditer une page | Crée le fichier `markdown/<page>.md` s'il n'existe pas et l'ouvre dans l'éditeur du système |
| `./blog.sh lister` | Lister les articles | Affiche l'ensemble des pages Markdown présentes dans le projet |
| `./blog.sh construire` | Compiler le blog | Génère les pages HTML individuelles, l'index automatique (`web/index.html`) et l'archive complète `blog.pdf` |
| `./blog.sh visualiser [pdf]` | Ouvrir le rendu | Ouvre le site dans le navigateur par défaut (version HTML par défaut, ou le PDF si l'argument `pdf` est passé) |

**Maillage interne :** Les pages peuvent être reliées entre elles via la syntaxe Markdown standard (`[Ma page](ma-page.html)`), en complément du sommaire généré automatiquement à chaque compilation.

## Conception et choix techniques

- **Détection de l'éditeur :** Le script n'impose aucun éditeur de texte en dur. Il interroge dans l'ordre la variable d'environnement `$EDITOR`, l'alternative système `/usr/bin/editor`, puis bascule en *fallback* sur `nano`, `vim` ou `vi`.
- **Architecture modulaire :** Le script est découpé en 10 fonctions isolées (principe de responsabilité unique), sans variables globales implicites.
- **Documentation standardisée :** Chaque fonction est documentée par un cartouche d'en-tête normalisé (`Name`, `Description`, `Usage`, `Arguments`, `Return`).

## Prérequis

- **Bash** (Linux, macOS ou WSL)
- **Pandoc** pour la conversion Markdown vers HTML et PDF :
  - Debian / Ubuntu : `sudo apt install pandoc`
  - macOS : `brew install pandoc`
- Un éditeur en ligne de commande (`nano`, `vim`, etc.)

## Installation et prise en main

```bash
git clone https://github.com/rafael-hocquel/PU-moteur-blogues.git
cd PU-moteur-blogues
chmod +x blog.sh
