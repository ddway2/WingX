# iso3d

Librairie Lua pour le rendu isométrique 2D dans Love2D.

## Description

iso3d est une librairie pour Love2D qui permet de créer des rendus en perspective isométrique. Elle fournit des fonctions pour convertir des coordonnées de grille 2D en coordonnées d'écran et vice-versa, avec un système complet de gestion de maps et tilesets.

## Architecture

La librairie est organisée en modules :

- **iso3d** - Module principal qui expose toutes les fonctions
- **iso3d.projection** - Fonctions de conversion de coordonnées
- **iso3d.render** - Fonctions de rendu des tuiles et maps
- **iso3d.debug** - Utilitaires de debug et visualisation
- **iso3d.map** - Gestion des maps
- **iso3d.tileset** - Gestion des tilesets

## Installation

La librairie est incluse dans le projet. Pour l'utiliser dans votre code Love2D :

```lua
local iso3d = require('iso3d')
```

## Utilisation de base

### Initialisation

```lua
function love.load()
  iso3d.init({
    tileWidth = 64,
    tileHeight = 32,
    debug = false
  })
end
```

### Configuration

Les options de configuration disponibles :

- `tileWidth` : Largeur d'une tuile isométrique (défaut: 64)
- `tileHeight` : Hauteur d'une tuile isométrique (défaut: 32)
- `debug` : Mode debug pour afficher les types de tuiles (défaut: false)

### Convention de coordonnées

Dans un fichier map, la **première ligne** correspond à la **rangée la plus haute** à l'écran (sommet du losange). L'affichage isométrique correspond à une rotation anti-horaire de 45° avec écrasement vertical.

Exemple de map 4x4 :
```
A B C D   →   A (sommet haut)
E F G H   →   E F B (diagonale suivante)
I J K L   →   I J K C (diagonale suivante)
M N O P   →   M N O L P (coin bas)
```

## API de projection

### `iso3d.toScreen(x, y)`
Convertit des coordonnées de grille 2D en coordonnées d'écran.

```lua
local screenX, screenY = iso3d.toScreen(5, 3)
```

**Paramètres:**
- `x` : Position X dans la grille (colonne)
- `y` : Position Y dans la grille (ligne)

**Retourne:** `screenX, screenY`

### `iso3d.toWorld(screenX, screenY)`
Convertit des coordonnées d'écran en coordonnées de grille 2D.

```lua
local x, y = iso3d.toWorld(100, 50)
```

**Paramètres:**
- `screenX` : Position X à l'écran
- `screenY` : Position Y à l'écran

**Retourne:** `x, y`

## API de rendu

### `iso3d.drawTileDiamond(x, y, color, opacity)`
Dessine une tuile isométrique en forme de losange.

```lua
iso3d.drawTileDiamond(5, 5, {0.2, 0.8, 0.3, 1}, 1.0)
```

**Paramètres:**
- `x, y` : Position dans la grille
- `color` : Table RGBA `{r, g, b, a}` (valeurs 0-1)
- `opacity` : Opacité (0-1)

### `iso3d.drawTileSprite(x, y, sprite, opacity, scale)`
Dessine un sprite sur une tuile isométrique.

```lua
local sprite = love.graphics.newImage('assets/grass.png')
iso3d.drawTileSprite(5, 5, sprite, 1.0, 1.0)
```

**Paramètres:**
- `x, y` : Position dans la grille
- `sprite` : Objet Love2D Image
- `opacity` : Opacité (0-1)
- `scale` : Échelle du sprite

### `iso3d.drawTile(tile, x, y, tileset)`
Dessine une tuile avec ses propriétés du tileset.

```lua
local tile = gameMap:getTile(2, 3)
iso3d.drawTile(tile, 2, 3, tileset)
```

**Paramètres:**
- `tile` : Objet tuile
- `x, y` : Position dans la grille
- `tileset` : Tileset contenant les définitions

### `iso3d.drawMap(gameMap, offset)`
Dessine une map complète avec tri en profondeur.

```lua
iso3d.drawMap(gameMap, {x = 400, y = 300})
```

**Paramètres:**
- `gameMap` : Objet map à dessiner
- `offset` : Table `{x, y}` pour décaler la caméra

## API de debug

### `iso3d.drawPoint(x, y, color)`
Dessine un point dans l'espace isométrique.

```lua
iso3d.drawPoint(10, 5, {1, 0, 0, 1}) -- Point rouge
```

### `iso3d.drawLine(x1, y1, x2, y2, color)`
Dessine une ligne dans l'espace isométrique.

```lua
iso3d.drawLine(0, 0, 10, 10, {0, 1, 0, 1}) -- Ligne verte
```

### `iso3d.debug()`
Affiche les informations de debug dans la console.

```lua
iso3d.debug()
```

### `iso3d.getVersion()`
Retourne la version de la librairie.

```lua
print('iso3d version:', iso3d.getVersion())
```

## Gestion des Tilesets

Les tilesets définissent les types de tuiles avec leurs propriétés visuelles et gameplay.

### Format de fichier Tileset

Les fichiers `.lua` dans `tilesets/` retournent une table avec les définitions :

```lua
return {
  name = "Mon Tileset",

  metadata = {
    author = "Auteur",
    version = "1.0"
  },

  tiles = {
    g = {
      name = "Grass",
      description = "Herbe verte",

      -- Visuel
      color = {0.2, 0.8, 0.3, 1},  -- RGBA (fallback)
      sprite = "assets/tiles/grass.png",  -- Sprite statique

      -- Affichage
      scale = 1.0,
      opacity = 1.0,

      -- Animation (optionnel)
      animated = false,
      frameCount = 1,
      frameDuration = 0.1,
      animationFrames = {},

      -- Gameplay
      walkable = true,
      transparent = false,
      tags = {"terrain", "natural"},

      -- Paramètres custom
      custom = {
        fertility = 0.8
      }
    }
  }
}
```

### Charger un Tileset

```lua
-- Depuis un fichier
local tileset = iso3d.tileset.loadFromFile('tilesets/simple.lua')

-- Charger les sprites
tileset:loadSprites()

-- Obtenir une définition
local grassDef = tileset:getDefinition('g')
print(grassDef.name, grassDef.color)
```

### Associer un Tileset à une Map

```lua
-- Charger tileset et map
local tileset = iso3d.tileset.loadFromFile('tilesets/simple.lua')
local gameMap = iso3d.map.loadFromFile('maps/test.map')

-- Associer le tileset à la map
gameMap:setTileset(tileset)
tileset:loadSprites()

-- Obtenir la définition d'une tuile
local tile = gameMap:getTile(2, 3)
local tileDef = gameMap:getTileDefinition(tile)
```

## Gestion des Maps

### Format de fichier Map

Les fichiers `.map` utilisent un format textuel simple avec séparateurs espaces :

```
# Commentaire
type:height:params

# Exemple :
g:0 g:1 g:2
w:0 g:1 s:2
```

**Note:** La notion de `height` (hauteur) est conservée dans le format de fichier pour compatibilité, mais n'est actuellement pas utilisée par le rendu. Vous pouvez l'utiliser pour stocker des métadonnées.

**Types de tuiles disponibles :**
- `g` = grass (herbe)
- `w` = water (eau)
- `s` = stone (pierre)
- `d` = dirt (terre)
- `.` = tuile vide

**Paramètres optionnels :** `key=value,key2=value2`

Exemple : `g:0:variant=1`

### Charger une Map

```lua
-- Depuis un fichier
local gameMap = iso3d.map.loadFromFile('maps/test.map')

-- Depuis une chaîne
local mapString = [[
  g:0 w:0 g:0
  w:0 g:0 g:0
  g:0 s:0 s:0
]]
local gameMap = iso3d.map.loadFromString(mapString)
```

### Utiliser une Map

```lua
-- Parcourir toutes les tuiles
gameMap:each(function(x, y, tile)
  print(x, y, tile.type)
end)

-- Obtenir une tuile spécifique
local tile = gameMap:getTile(2, 3)

-- Modifier une tuile
local newTile = iso3d.map.Tile.new('s', 0, {variant=2})
gameMap:setTile(5, 5, newTile)

-- Exporter vers string
local mapString = gameMap:toString()
```

## Animations

iso3d supporte les animations de tuiles avec des séquences d'images.

### Pré-requis des Sprites

**Format:**
- Format PNG avec transparence (canal alpha)
- Dimensions recommandées: 64x64 pixels
- Les sprites sont automatiquement redimensionnés

**Sprites animés:**
- Toutes les frames doivent avoir les **mêmes dimensions**
- `frameCount` doit correspondre au nombre de fichiers
- `frameDuration` en secondes (0.1-0.5s recommandé)
- Propriété `color` obligatoire (fallback)

**Voir `assets/README.md` pour plus de détails.**

### Définir une tuile animée

```lua
w = {
  name = "Water",

  animated = true,
  frameCount = 4,
  frameDuration = 0.3,

  animationFrames = {
    "assets/tiles/water_1.png",
    "assets/tiles/water_2.png",
    "assets/tiles/water_3.png",
    "assets/tiles/water_4.png",
  },

  color = {0.2, 0.4, 0.9, 1},  -- Fallback
  walkable = false
}
```

### Mettre à jour les animations

```lua
function love.update(dt)
  if tileset then
    tileset:updateAnimations(dt)
  end
end
```

### Rendu automatique

Le rendu utilise automatiquement les sprites si disponibles, sinon les couleurs de fallback :

```lua
function love.draw()
  iso3d.drawMap(gameMap, {x = 400, y = 300})
end
```

## Exemple complet

```lua
local iso3d = require('iso3d')

local gameMap
local tileset
local cameraOffset = {x = 0, y = 0}

function love.load()
  -- Initialiser iso3d
  iso3d.init({
    tileWidth = 64,
    tileHeight = 32,
    debug = false
  })

  -- Charger tileset et map
  tileset = iso3d.tileset.loadFromFile('tilesets/simple.lua')
  tileset:loadSprites()

  gameMap = iso3d.map.loadFromFile('maps/test.map')
  gameMap:setTileset(tileset)

  -- Centrer la caméra
  cameraOffset.x = love.graphics.getWidth() / 2
  cameraOffset.y = love.graphics.getHeight() / 4
end

function love.update(dt)
  -- Mettre à jour les animations
  tileset:updateAnimations(dt)

  -- Déplacer la caméra avec les flèches
  local speed = 200 * dt
  if love.keyboard.isDown('left') then cameraOffset.x = cameraOffset.x + speed end
  if love.keyboard.isDown('right') then cameraOffset.x = cameraOffset.x - speed end
  if love.keyboard.isDown('up') then cameraOffset.y = cameraOffset.y + speed end
  if love.keyboard.isDown('down') then cameraOffset.y = cameraOffset.y - speed end
end

function love.draw()
  love.graphics.clear(0.15, 0.15, 0.2)

  -- Dessiner la map
  iso3d.drawMap(gameMap, cameraOffset)

  -- UI
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print('iso3d v' .. iso3d.getVersion(), 10, 10)
  love.graphics.print('Map: ' .. gameMap.width .. 'x' .. gameMap.height, 10, 30)
end
```

## Documentation

- **[RENDERING.md](../docs/RENDERING.md)** - Explications détaillées du système de rendu
- **[maps/README.md](../maps/README.md)** - Format et structure des fichiers map
- **[assets/README.md](../assets/README.md)** - Pré-requis et création de sprites

## Roadmap

- [x] Structure modulaire de la librairie
- [x] Conversion de coordonnées 2D grille ↔ écran
- [x] Fonctions de dessin basiques (points, lignes)
- [x] Système de maps avec format textuel
- [x] Système de tilesets
- [x] Rendu de tuiles isométriques (losange)
- [x] Rendu avec sprites/textures
- [x] Support des animations de tuiles
- [x] Tri en profondeur (depth sorting)
- [x] Simplification de l'API (suppression hauteurs 3D)
- [x] Réorganisation en modules séparés
- [ ] Système de caméra avancé (zoom, rotation)
- [ ] Optimisations de performance (culling, batching)

## Licence

MIT
