# WingX - Love2D Project

Un projet minimal basé sur le moteur Love2D qui affiche "Hello World".

## Description

Ce projet utilise Love2D (LÖVE), un framework Lua pour créer des jeux 2D. Le projet inclut un exemple minimal qui affiche "Hello World" avec une animation.

## Structure du projet

```
WingX/
├── main.lua       # Point d'entrée de l'application
├── .gitignore     # Fichiers à ignorer
└── README.md      # Ce fichier
```

## Installation

### 1. Cloner le projet

```bash
git clone <url-du-repo>
cd WingX
```

### 2. Installer Love2D

#### Windows
Téléchargez l'installeur depuis le site officiel :
- **Site officiel** : https://love2d.org/
- Téléchargez la dernière version pour Windows
- Installez et ajoutez Love2D à votre PATH (optionnel)

#### macOS
```bash
brew install love
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get install love
```

#### Linux (Arch)
```bash
sudo pacman -S love
```

## Utilisation

### Lancer l'application

Une fois Love2D installé, lancez l'application depuis la racine du projet :

```bash
love .
```

Vous devriez voir une fenêtre s'ouvrir avec "Hello World" affiché au centre et un cercle animé en dessous !

### Ce que fait l'application

- Affiche le texte "Hello World" centré à l'écran
- Dessine un cercle bleu pulsant pour l'animation
- Affiche des messages dans la console au démarrage
- Définit le titre de la fenêtre

## Développement

Le fichier `main.lua` contient le code principal de l'application. Les fonctions principales sont :

- `love.load()` : Appelée au démarrage de l'application (initialisation)
- `love.update(dt)` : Appelée à chaque frame pour mettre à jour la logique (dt = delta time)
- `love.draw()` : Appelée à chaque frame pour dessiner à l'écran

Pour modifier l'application, éditez simplement `main.lua` et relancez avec `love .`

## Ressources

- **Documentation Love2D** : https://love2d.org/wiki/Main_Page
- **GitHub Love2D** : https://github.com/love2d/love
- **Forums** : https://love2d.org/forums/
- **Discord** : https://discord.gg/rhUets9

## Licence

Ce projet est un exemple minimal. Love2D est distribué sous licence zlib/libpng.
