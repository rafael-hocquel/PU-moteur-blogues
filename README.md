# Moteur de blogues - `blog.sh`

Un moteur de blogue en **ligne de commande**, écrit en Bash.
Il permet de créer, éditer et lier des pages en Markdown, puis de générer le
blogue dans un **navigateur (HTML)** ou dans un **fichier PDF**.

**Auteurs :** Rafaël HOCQUEL · Zakaria SABRI · Adrian STYZINSKI   
**Version :** 1.0 - décembre 2025

## Cahier des charges

| # | Exigence | Réalisation | Commande |
|---|----------|-------------|----------|
| 1 | Créer une page | Une page = un fichier Markdown dans `markdown/`<br> La commande `editer` crée le fichier s'il n'existe pas | `./blog.sh editer ma-page` |
| 2 | Éditer une page existante | La page s'ouvre dans l'éditeur de texte du système | `./blog.sh editer ma-page` |
| 3 | Lier les pages entre elles | Liens Markdown classiques entre pages<br> Un sommaire est généré automatiquement | `[Ma page](ma-page.html)` |
| 4 | Générer le blogue en PDF | Toutes les pages réunies dans un seul document `blog.pdf` | `./blog.sh construire` |
| 5 | Générer le blogue en HTML | Une page HTML par page<br> Un sommaire `web/index.html` est généré automatiquement | `./blog.sh construire` |

## Contraintes techniques

| Contrainte | Comment elle est respectée |
|------------|----------------------------|
| Édition possible avec n'importe quel éditeur | Le script ne dépend d'aucun éditeur : il utilise `$EDITOR`, puis `/usr/bin/editor`, puis `nano`, `vim` ou `vi` en fallback |
| Code décomposé en fonctions, maintenable | 10 fonctions, une responsabilité chacune, aucune variable globale implicite |
| Code commenté, cartouche devant chaque fonction | Chaque fonction est précédée d'un cartouche `Name / Description / Usage / Arguments / Return` |

## Prérequis

- **Bash** (Linux, macOS, WSL)
- **Pandoc** - moteur de conversion Markdown → HTML/PDF
  - Debian/Ubuntu : `sudo apt install pandoc`
  - macOS : `brew install pandoc`
- Un éditeur de texte en ligne de commande (`nano`, `vim`…)

## Installation

```
bash
git clone https://github.com/rafael-hocquel/PU-moteur-blogues.git
cd PU-moteur-blogues
chmod +x blog.sh
```

## Usage
```
./blog.sh editer accueil        # écrit / modifie le contenu de la page "accueil"
./blog.sh editer contact        # écrit / modifie le contenu de la page "contact"
./blog.sh lister                # liste les pages existantes
./blog.sh construire            # génère le blogue au formats PDF et HTML
./blog.sh visualiser [pdf]            # ouvre le blogue dans un navigateur (html par défaut, pdf si l'option est précisée
```
