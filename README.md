# WingX - LOVR Project

Un projet minimal basé sur le moteur LOVR (Lua Open VR) qui affiche "Hello World".

## Description

Ce projet utilise LOVR, un framework Lua pour la réalité virtuelle et les applications 3D. Le projet inclut un exemple minimal qui affiche "Hello World" dans un espace 3D.

## Structure du projet

```
WingX/
├── lovr/          # Moteur LOVR (submodule git)
├── main.lua       # Point d'entrée de l'application
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

### 2. Installer LOVR

#### Option A : Utiliser un binaire pré-compilé

Téléchargez LOVR depuis le site officiel :
- **Site officiel** : https://lovr.org/download
- Téléchargez la version correspondant à votre système d'exploitation

#### Option B : Compiler LOVR depuis les sources

Si vous souhaitez compiler LOVR depuis le submodule inclus :

```bash
cd lovr
# Suivez les instructions de compilation sur : https://lovr.org/docs/Building
```

**Prérequis pour la compilation :**
- CMake 3.1+
- Compilateur C/C++ (GCC, Clang, MSVC)
- Dépendances système (varient selon l'OS)

## Utilisation

### Lancer l'application

Une fois LOVR installé, lancez l'application depuis la racine du projet :

```bash
lovr .
```

Vous devriez voir "Hello World" affiché dans l'espace 3D !

### Ce que fait l'application

- Affiche le texte "Hello World" dans l'espace 3D
- Dessine un petit cube pour rendre la scène plus intéressante
- Affiche des messages dans la console au démarrage

## Développement

Le fichier `main.lua` contient le code principal de l'application. Les fonctions principales sont :

- `lovr.load()` : Appelée au démarrage de l'application
- `lovr.draw(pass)` : Appelée à chaque frame pour dessiner la scène

Pour modifier l'application, éditez simplement `main.lua` et relancez avec `lovr .`

## Ressources

- **Documentation LOVR** : https://lovr.org/docs
- **GitHub LOVR** : https://github.com/bjornbytes/lovr
- **Communauté** : https://lovr.org/community

## Licence

Ce projet est un exemple minimal. Consultez la licence de LOVR dans le dossier `lovr/` pour plus d'informations sur le moteur.
