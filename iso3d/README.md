# iso3d

Librairie Lua pour le rendu isométrique 2D dans Love2D.

## Description

iso3d est une librairie pour Love2D qui permet de créer des rendus en perspective isométrique. Elle fournit des fonctions pour convertir des coordonnées de grille 2D en coordonnées d'écran et vice-versa, avec un système complet de gestion de maps et tilesets.

## Architecture

La librairie est organisée en modules :

- **iso3d** - Module principal qui expose toutes les fonctions
- **iso3d.camera** - Gestion de la caméra (rotation)
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
- `zoom` : Niveau de zoom (défaut: 1.0, range: 0.2 à 5.0)
- `rotation` : Rotation de la caméra (défaut: 0, valeurs: 0-3 pour nord, est, sud, ouest)

### Convention de coordonnées

Dans un fichier map, la **première ligne** correspond à la **rangée la plus haute** à l'écran (sommet du losange). L'affichage isométrique correspond à une rotation anti-horaire de 45° avec écrasement vertical.

Exemple de map 4x4 :
```
A B C D   →   A (sommet haut)
E F G H   →   E F B (diagonale suivante)
I J K L   →   I J K C (diagonale suivante)
M N O P   →   M N O L P (coin bas)
```

## Zoom

iso3d supporte le zoom dynamique pour agrandir ou réduire l'affichage de la map.

### `iso3d.setZoom(zoom)`
Définit le niveau de zoom.

```lua
iso3d.setZoom(2.0)  -- Zoom 2x (agrandir)
iso3d.setZoom(0.5)  -- Zoom 0.5x (réduire)
```

**Paramètres:**
- `zoom` : Facteur de zoom (nombre positif)
  - `1.0` = zoom normal (100%)
  - `> 1.0` = zoom avant (agrandir)
  - `< 1.0` = zoom arrière (réduire)
  - Range recommandé : 0.2 à 5.0

**Validation:**
- La fonction génère une erreur si zoom ≤ 0

### `iso3d.getZoom()`
Retourne le niveau de zoom actuel.

```lua
local currentZoom = iso3d.getZoom()
print(string.format('Zoom: %.2fx', currentZoom))
```

**Retourne:** Nombre (facteur de zoom actuel)

### Exemple d'utilisation

```lua
function love.wheelmoved(x, y)
  -- Zoom avec la molette de souris
  if y > 0 then
    -- Molette vers le haut = zoom avant
    local zoom = iso3d.getZoom()
    iso3d.setZoom(math.min(zoom * 1.1, 5.0))
  elseif y < 0 then
    -- Molette vers le bas = zoom arrière
    local zoom = iso3d.getZoom()
    iso3d.setZoom(math.max(zoom / 1.1, 0.2))
  end
end

function love.keypressed(key)
  -- Zoom avec les touches + et -
  if key == '=' or key == '+' then
    local zoom = iso3d.getZoom()
    iso3d.setZoom(math.min(zoom * 1.2, 5.0))
  elseif key == '-' then
    local zoom = iso3d.getZoom()
    iso3d.setZoom(math.max(zoom / 1.2, 0.2))
  end
end
```

### Comportement

- Le zoom affecte toutes les projections de coordonnées (toScreen, toWorld)
- Les tuiles (losanges et sprites) sont automatiquement redimensionnées
- Le zoom s'applique de manière uniforme sur les axes X et Y
- La projection isométrique reste correcte à tous les niveaux de zoom

## Rotation de la caméra

iso3d supporte la rotation de la caméra par incréments de 90° pour visualiser la map sous différents angles.

### Concept

La rotation permet de tourner la vue autour de la map en 4 positions discrètes :
- **0 = Nord** : Vue par défaut
- **1 = Est** : Rotation 90° horaire
- **2 = Sud** : Rotation 180°
- **3 = Ouest** : Rotation 270° horaire (ou 90° anti-horaire)

La rotation transforme les coordonnées de grille avant la projection isométrique, garantissant un rendu correct avec tri en profondeur.

### `iso3d.setRotation(rotation)`
Définit la rotation de la caméra.

```lua
iso3d.setRotation(0)  -- Vue nord (défaut)
iso3d.setRotation(1)  -- Vue est (90° horaire)
iso3d.setRotation(2)  -- Vue sud (180°)
iso3d.setRotation(3)  -- Vue ouest (270° horaire)
```

**Paramètres:**
- `rotation` : Rotation (entier 0-3)
  - `0` = Nord (vue par défaut)
  - `1` = Est (rotation 90° horaire)
  - `2` = Sud (rotation 180°)
  - `3` = Ouest (rotation 270° horaire)

**Validation:**
- La fonction génère une erreur si rotation n'est pas entre 0 et 3

### `iso3d.getRotation()`
Retourne la rotation actuelle de la caméra.

```lua
local rotation = iso3d.getRotation()
print('Rotation:', rotation)  -- 0, 1, 2, ou 3
```

**Retourne:** Entier (0-3)

### `iso3d.rotateClockwise()`
Fait pivoter la caméra de 90° dans le sens horaire.

```lua
iso3d.rotateClockwise()  -- 0→1, 1→2, 2→3, 3→0
```

### `iso3d.rotateCounterClockwise()`
Fait pivoter la caméra de 90° dans le sens anti-horaire.

```lua
iso3d.rotateCounterClockwise()  -- 0→3, 3→2, 2→1, 1→0
```

### Exemple d'utilisation

```lua
function love.keypressed(key)
  -- Rotation avec Q et E
  if key == 'q' then
    iso3d.rotateCounterClockwise()
    print('Rotation:', iso3d.getRotation())
  elseif key == 'e' then
    iso3d.rotateClockwise()
    print('Rotation:', iso3d.getRotation())
  end

  -- Ou rotation directe avec les touches 1-4
  if key == '1' then iso3d.setRotation(0) end  -- Nord
  if key == '2' then iso3d.setRotation(1) end  -- Est
  if key == '3' then iso3d.setRotation(2) end  -- Sud
  if key == '4' then iso3d.setRotation(3) end  -- Ouest
end
```

### Comportement

- La rotation transforme les coordonnées de grille avant la projection isométrique
- L'ordre de rendu (depth sorting) est automatiquement adapté selon la rotation
- La rotation n'affecte pas le zoom ni les autres paramètres de caméra
- Les coordonnées de la map (x, y dans le fichier .map) restent constantes
- Compatible avec toutes les fonctionnalités (sprites, animations, debug, etc.)

### Cas d'usage

- **Jeux de stratégie** : Visualiser le terrain sous différents angles
- **City builders** : Accéder aux zones cachées par des bâtiments
- **RPG isométriques** : Mieux voir les obstacles et chemins
- **Level design** : Vérifier l'apparence de la map de tous les côtés

## Blocs 3D

iso3d supporte le rendu de blocs 3D isométriques avec hauteurs paramétrables, permettant de créer des structures verticales comme des murs, tours, et bâtiments.

### Concept

Un bloc 3D est une tuile isométrique avec une hauteur > 0. Il est rendu avec trois faces visibles :
- **Face du dessus** : Losange plat (vue de dessus du bloc) - 100% de luminosité
- **Face droite** : Parallélogramme vertical - 80% de luminosité (ombrage)
- **Face gauche** : Parallélogramme vertical - 60% de luminosité (ombrage plus sombre)

L'ombrage automatique crée un effet 3D réaliste sans nécessiter de sprites supplémentaires.

### Hauteurs standard

Les hauteurs sont exprimées en unités de tuile, où **hauteur = 1** crée un **cube parfait** (hauteur = largeur de tuile) :

| Hauteur | Description      | Hauteur réelle* | Usage typique                    |
|---------|------------------|-----------------|----------------------------------|
| 0       | Tuile plate      | 0px             | Sol, terrain, eau                |
| 0.5     | Demi-cube        | 32px            | Marches, petits obstacles        |
| 1       | Cube             | 64px            | Murs bas, caisses, blocs         |
| 1.5     | Cube et demi     | 96px            | Murs, barrières                  |
| 2       | Double cube      | 128px           | Tours, bâtiments, grandes structures |

*_Avec tileWidth=64 (défaut)_

**Note:**
- Vous pouvez utiliser n'importe quelle valeur >= 0 (ex: 0.25, 0.75, 3, etc.)
- **height = 1** crée un cube parfait où la hauteur du bloc = la largeur de la tuile
- Les hauteurs sont relatives à `tileWidth` : `hauteur_pixels = height * tileWidth`

### Définition dans les tilesets

Ajoutez la propriété `height` aux définitions de tuiles :

```lua
return {
  name = "Tileset avec blocs",
  tiles = {
    -- Tuile plate (hauteur 0)
    g = {
      name = "Grass",
      color = {0.2, 0.8, 0.3, 1},
      height = 0  -- Tuile plate
    },

    -- Blocs 3D (hauteur > 0)
    B = {
      name = "Cube",
      color = {0.6, 0.6, 0.6, 1},
      height = 1,  -- Cube parfait (hauteur = largeur)
      walkable = false
    },

    T = {
      name = "Tower",
      color = {0.4, 0.4, 0.4, 1},
      height = 2,  -- Tour (2x hauteur de cube)
      walkable = false
    }
  }
}
```

### Définition dans les fichiers map

Spécifiez la hauteur dans le format `type:height` :

```
# Format: type:height
# Exemples de blocs 3D (height=1 crée un cube parfait)

g:0 W:1.5 W:1.5 W:1.5 g:0
g:0 W:1.5 g:0   W:1.5 g:0
g:0 g:0   g:0   W:1.5 g:0
g:0 W:1.5 W:1.5 W:1.5 g:0
```

**Note:** La hauteur spécifiée dans le fichier map **remplace** la hauteur par défaut du tileset pour cette tuile.

### Exemple d'utilisation

```lua
-- Créer une tuile avec hauteur dans le code
local cubeTile = iso3d.map.Tile.new('B', 1)   -- Cube parfait (height=1)
local towerTile = iso3d.map.Tile.new('T', 2)  -- Tour (2x cube)

-- Placer dans la map
gameMap:setTile(5, 5, cubeTile)
gameMap:setTile(10, 10, towerTile)

-- Le rendu est automatique
iso3d.drawMap(gameMap, {x = 400, y = 300})
```

### Rendu et tri en profondeur

**Tri automatique:** Les blocs sont automatiquement triés de l'arrière vers l'avant selon leur position (x, y) dans la grille. Les blocs plus éloignés (coordonnées x+y plus petites) sont dessinés en premier.

**Rotation compatible:** Le système de blocs 3D fonctionne parfaitement avec la rotation de caméra. L'ordre de rendu s'adapte automatiquement selon l'orientation.

**Zoom compatible:** Les blocs sont correctement redimensionnés avec le zoom. L'échelle s'applique uniformément aux trois faces.

### Combinaison avec sprites

Les blocs 3D utilisent uniquement des couleurs (rendu procédural). Si vous définissez un sprite pour une tuile, le sprite sera utilisé à la place du rendu en bloc 3D, même si une hauteur est spécifiée.

**Priorité de rendu:**
1. **Sprite** : Si défini, le sprite est utilisé
2. **Bloc 3D** : Si height > 0 et pas de sprite, rendu en bloc 3D
3. **Tuile plate** : Si height = 0 et pas de sprite, rendu en losange plat

### Cas d'usage

- **City builders** : Créer des bâtiments, murs, tours
- **Jeux de stratégie** : Obstacles, fortifications, structures
- **Platformers isométriques** : Plateformes à différentes hauteurs
- **RPG** : Murs de donjons, structures architecturales
- **Level design** : Prototypage rapide de niveaux 3D

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

### `iso3d.drawBlock(x, y, height, color, opacity)`
Dessine un bloc 3D isométrique avec hauteur.

```lua
-- Dessiner un cube parfait (height=1)
iso3d.drawBlock(5, 5, 1, {0.7, 0.7, 0.7, 1}, 1.0)

-- Différentes hauteurs
iso3d.drawBlock(3, 3, 0.5, {0.8, 0.2, 0.2, 1}, 1.0)  -- Demi-cube rouge
iso3d.drawBlock(7, 7, 2, {0.2, 0.2, 0.8, 1}, 1.0)    -- Double cube bleu
```

**Paramètres:**
- `x, y` : Position dans la grille
- `height` : Hauteur du bloc en unités de tuile (0 = tuile plate, 1 = cube, 2 = double cube)
- `color` : Table RGBA `{r, g, b, a}` (valeurs 0-1)
- `opacity` : Opacité (0-1)

**Système de hauteur:**
- `height = 1` crée un **cube parfait** où hauteur = largeur de tuile
- La hauteur en pixels = `height * tileWidth`
- Avec tileWidth=64 (défaut) : height=1 → 64px, height=2 → 128px

**Rendu:**
Le bloc 3D est composé de trois faces :
- **Face du dessus** : Losange plat au sommet du bloc (100% luminosité)
- **Face droite** : Parallélogramme vertical (80% luminosité)
- **Face gauche** : Parallélogramme vertical (60% luminosité)

Les faces sont automatiquement ombrées pour donner un effet 3D réaliste.

### `iso3d.drawTile(tile, x, y, tileset)`
Dessine une tuile avec ses propriétés du tileset. Supporte automatiquement les blocs 3D si la tuile a une hauteur > 0.

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
- [x] Système de zoom dynamique
- [x] Système de caméra avancé (rotation 90°)
- [x] Système de blocs 3D avec hauteurs paramétrables
- [ ] Optimisations de performance (culling, batching)

## Licence

MIT
