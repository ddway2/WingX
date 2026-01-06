# WingX - Love2D Project

Un projet minimal basé sur le moteur Love2D qui affiche "Hello World".

## Description

Ce projet utilise Love2D (LÖVE), un framework Lua pour créer des jeux 2D. Le projet inclut un exemple minimal qui affiche "Hello World" avec une animation.

## Structure du projet

```
WingX/
├── iso3d/         # Librairie isométrique 3D pour Love2D
│   ├── init.lua   # Module principal de la librairie
│   └── README.md  # Documentation de la librairie
├── love2d/        # Code source de Love2D (submodule git)
├── main.lua       # Point d'entrée de l'application
├── .gitignore     # Fichiers à ignorer
└── README.md      # Ce fichier
```

## Installation

### 1. Cloner le projet avec les submodules

```bash
git clone --recursive <url-du-repo>
cd WingX
```

Si vous avez déjà cloné le projet sans `--recursive`, initialisez les submodules :

```bash
git submodule update --init --recursive
```

### 2. Installer Love2D

#### Option A : Utiliser un binaire pré-compilé (Recommandé)

**Windows**
- Téléchargez l'installeur depuis : https://love2d.org/
- Installez et ajoutez Love2D à votre PATH (optionnel)

**macOS**
```bash
brew install love
```

**Linux (Ubuntu/Debian)**
```bash
sudo apt-get install love
```

**Linux (Arch)**
```bash
sudo pacman -S love
```

#### Option B : Compiler Love2D depuis les sources

Si vous souhaitez compiler Love2D depuis le submodule inclus :

```bash
cd love2d
mkdir build
cd build
cmake ..
make
sudo make install
```

**Prérequis pour la compilation :**
- CMake 3.1+
- Compilateur C/C++ (GCC, Clang, MSVC)
- Dépendances système (varient selon l'OS)
  - Ubuntu/Debian : `sudo apt-get install build-essential libfreetype6-dev libluajit-5.1-dev libphysfs-dev libsdl2-dev libopenal-dev libogg-dev libvorbis-dev libflac-dev libflac++-dev libtheora-dev libmodplug-dev libmpg123-dev libmng-dev libturbojpeg-dev`
  - macOS : Les dépendances sont gérées par CMake
  - Windows : Consultez https://github.com/love2d/megasource

Pour plus de détails, consultez : https://github.com/love2d/love/blob/main/README.md

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

### Librairie iso3d

Le projet inclut une librairie isométrique 3D (`iso3d/`) pour créer des rendus en perspective isométrique.

**Utilisation :**

```lua
local iso3d = require('iso3d')

function love.load()
  iso3d.init({ tileWidth = 64, tileHeight = 32 })
end

function love.draw()
  love.graphics.translate(400, 300)
  iso3d.drawPoint(10, 5, 0, {1, 0, 0, 1})
end
```

Pour plus de détails, consultez la [documentation de iso3d](iso3d/README.md).

## Ressources

- **Documentation Love2D** : https://love2d.org/wiki/Main_Page
- **GitHub Love2D** : https://github.com/love2d/love
- **Forums** : https://love2d.org/forums/
- **Discord** : https://discord.gg/rhUets9

## Licence

Ce projet est un exemple minimal. Love2D est distribué sous licence zlib/libpng.
