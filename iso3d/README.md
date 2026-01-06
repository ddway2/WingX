# iso3d

Librairie Lua pour le rendu isométrique 3D dans Love2D.

## Description

iso3d est une librairie pour Love2D qui permet de créer des rendus en perspective isométrique. Elle fournit des fonctions pour convertir des coordonnées 3D en coordonnées 2D d'écran et vice-versa.

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
    debug = true
  })
end
```

### Configuration

Les options de configuration disponibles :

- `tileWidth` : Largeur d'une tuile isométrique (défaut: 64)
- `tileHeight` : Hauteur d'une tuile isométrique (défaut: 32)
- `debug` : Mode debug pour afficher les informations (défaut: false)

### Fonctions disponibles

#### `iso3d.init(config)`
Initialise la librairie avec une configuration optionnelle.

#### `iso3d.toScreen(x, y, z)`
Convertit des coordonnées 3D en coordonnées 2D d'écran.

```lua
local screenX, screenY = iso3d.toScreen(10, 5, 0)
```

#### `iso3d.toWorld(screenX, screenY, z)`
Convertit des coordonnées 2D d'écran en coordonnées 3D.

```lua
local x, y, z = iso3d.toWorld(100, 50, 0)
```

#### `iso3d.drawPoint(x, y, z, color)`
Dessine un point dans l'espace isométrique.

```lua
iso3d.drawPoint(10, 5, 0, {1, 0, 0, 1}) -- Point rouge
```

#### `iso3d.drawLine(x1, y1, z1, x2, y2, z2, color)`
Dessine une ligne dans l'espace isométrique.

```lua
iso3d.drawLine(0, 0, 0, 10, 10, 5, {0, 1, 0, 1}) -- Ligne verte
```

#### `iso3d.getVersion()`
Retourne la version de la librairie.

#### `iso3d.debug()`
Affiche les informations de debug dans la console.

### Fonctions de rendu

#### `iso3d.drawTileDiamond(x, y, z, color, opacity)`
Dessine une tuile isométrique plate (losange).

```lua
iso3d.drawTileDiamond(5, 5, 10, {0.2, 0.8, 0.3, 1}, 1.0)
```

#### `iso3d.drawTileBlock(x, y, z, height, color, opacity)`
Dessine un bloc 3D isométrique avec faces gauche, droite et dessus.

```lua
iso3d.drawTileBlock(5, 5, 0, 30, {0.5, 0.5, 0.5, 1}, 1.0)
```

#### `iso3d.drawTile(tile, x, y, tileset, renderMode)`
Dessine une tuile avec ses propriétés du tileset.

- `renderMode` : 'block' (3D) ou 'flat' (2D)

```lua
local tile = gameMap:getTile(2, 3)
iso3d.drawTile(tile, 2, 3, tileset, 'block')
```

#### `iso3d.drawMap(gameMap, renderMode, offset)`
Dessine une map complète avec tri en profondeur.

```lua
iso3d.drawMap(gameMap, 'block', {x = 400, y = 300})
```

## Gestion des Tilesets

Les tilesets définissent les types de tuiles avec leurs propriétés visuelles, assets et paramètres d'affichage.

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

      -- Assets
      sprite = "assets/tiles/grass.png",
      spriteVariants = {
        "assets/tiles/grass_1.png",
        "assets/tiles/grass_2.png",
      },
      color = {0.2, 0.8, 0.3, 1},  -- RGBA

      -- Affichage
      heightOffset = 0,
      scale = 1.0,
      opacity = 1.0,
      glow = false,

      -- Animation
      animated = false,
      frameCount = 1,
      frameDuration = 0.1,

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
local tilesetModule = require('iso3d.tileset')

-- Depuis un fichier
local tileset = tilesetModule.loadFromFile('tilesets/basic.lua')

-- Créer le tileset par défaut
local tileset = tilesetModule.createDefault()

-- Obtenir une définition de tuile
local grassDef = tileset:getDefinition('g')
print(grassDef.name, grassDef.color)
```

### Associer un Tileset à une Map

```lua
local mapModule = require('iso3d.map')
local tilesetModule = require('iso3d.tileset')

-- Charger tileset et map
local tileset = tilesetModule.loadFromFile('tilesets/basic.lua')
local gameMap = mapModule.loadFromFile('maps/test.map')

-- Associer le tileset à la map
gameMap:setTileset(tileset)

-- Obtenir la définition d'une tuile
local tile = gameMap:getTile(2, 3)
local tileDef = gameMap:getTileDefinition(tile)
if tileDef then
  print("Couleur:", tileDef.color)
  print("Marchable:", tileDef.walkable)
end
```

## Gestion des Maps

iso3d inclut un système de gestion de maps avec support de tuiles et hauteurs (-2 à 3 niveaux).

### Format de fichier Map

Les fichiers `.map` utilisent un format textuel simple :

```
# Commentaire
type:hauteur:paramètres

# Exemple:
g:0 g:1 g:2
w:0 g:1 s:2
```

**Types de tuiles disponibles :**
- `g` = grass (herbe)
- `w` = water (eau)
- `s` = stone (pierre)
- `d` = dirt (terre)
- `.` = tuile vide

**Hauteur :** -2 à 3 (-2 = le plus bas (eau profonde, vallées), 0 = niveau du sol, 3 = le plus haut (montagnes))

**Paramètres optionnels :** `key=value,key2=value2`

Exemple : `g:2:color=green,variant=1`

### Charger une Map

```lua
local mapModule = require('iso3d.map')

function love.load()
  -- Depuis un fichier
  local gameMap = mapModule.loadFromFile('maps/test.map')

  -- Ou depuis une chaîne
  local mapString = [[
    w:-2 w:-1 g:0
    w:-1 g:0 g:1
    g:1 s:2 s:3
  ]]
  local gameMap = mapModule.loadFromString(mapString)
end
```

### Utiliser une Map

```lua
-- Parcourir toutes les tuiles
gameMap:each(function(x, y, tile)
  print(x, y, tile.type, tile.height)
end)

-- Obtenir une tuile spécifique
local tile = gameMap:getTile(2, 3)
if tile then
  print("Type:", tile.type, "Height:", tile.height)
end

-- Modifier une tuile
local newTile = mapModule.Tile.new('s', 2, {color='gray'})
gameMap:setTile(5, 5, newTile)

-- Exporter vers string
local mapString = gameMap:toString()
```

## Exemple complet

```lua
local iso3d = require('iso3d')

local gameMap
local tileset

function love.load()
  -- Initialiser iso3d
  iso3d.init({
    tileWidth = 64,
    tileHeight = 32,
    debug = true
  })

  -- Charger le tileset et la map
  tileset = iso3d.tileset.loadFromFile('tilesets/basic.lua')
  gameMap = iso3d.map.loadFromFile('maps/test.map')

  -- Associer le tileset à la map
  gameMap:setTileset(tileset)
end

function love.draw()
  love.graphics.translate(400, 300) -- Centre l'origine

  -- Dessiner la map avec les couleurs du tileset
  gameMap:each(function(x, y, tile)
    local tileDef = gameMap:getTileDefinition(tile)
    local color = tileDef and tileDef.color or {1, 1, 1, 1}

    -- Appliquer le heightOffset du tileset
    local heightOffset = tileDef and tileDef.heightOffset or 0
    local z = tile.height * 10 + heightOffset

    iso3d.drawPoint(x, y, z, color)
  end)
end
```

## Roadmap

- [x] Structure de base de la librairie
- [x] Conversion de coordonnées 3D vers 2D
- [x] Conversion de coordonnées 2D vers 3D
- [x] Fonctions de dessin basiques (points, lignes)
- [x] Système de maps avec format textuel
- [x] Support de tuiles avec hauteurs (-2 à 3 niveaux)
- [x] Paramètres personnalisables par tuile
- [x] Système de tilesets pour définir les types de tuiles
- [x] Propriétés visuelles : sprites, couleurs, animations
- [x] Propriétés gameplay : walkable, transparent, tags
- [x] Paramètres d'affichage : heightOffset, scale, opacity, glow
- [x] Rendu de tuiles isométriques (losange/bloc 3D)
- [x] Fonction drawTile avec support tileset
- [x] Fonction drawMap avec rendu complet
- [x] Tri en profondeur (depth sorting)
- [x] Modes de rendu : 'block' (3D) et 'flat' (2D)
- [ ] Rendu avec sprites/textures depuis fichiers
- [ ] Support des animations de tuiles
- [ ] Système de caméra avancé (zoom, rotation)
- [ ] Optimisations de performance

## Licence

MIT
