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

## Gestion des Maps

iso3d inclut un système de gestion de maps avec support de tuiles et hauteurs (0-3 niveaux).

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

**Hauteur :** 0-3 (0 = niveau du sol, 3 = plus haut)

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
    g:0 g:1 g:2
    w:0 g:1 s:2
    g:1 g:2 g:3
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
local mapModule = require('iso3d.map')

local gameMap

function love.load()
  iso3d.init({ debug = true })
  gameMap = mapModule.loadFromFile('maps/test.map')
end

function love.draw()
  love.graphics.translate(400, 300) -- Centre l'origine

  -- Dessiner la map
  gameMap:each(function(x, y, tile)
    local screenX, screenY = iso3d.toScreen(x, y, tile.height)
    iso3d.drawPoint(x, y, tile.height, {1, 1, 1, 1})
  end)
end
```

## Roadmap

- [x] Structure de base de la librairie
- [x] Conversion de coordonnées 3D vers 2D
- [x] Conversion de coordonnées 2D vers 3D
- [x] Fonctions de dessin basiques (points, lignes)
- [x] Système de maps avec format textuel
- [x] Support de tuiles avec hauteurs (0-3 niveaux)
- [x] Paramètres personnalisables par tuile
- [ ] Rendu de tuiles avec sprites/textures
- [ ] Dessin de formes 3D (cubes, plans)
- [ ] Système de caméra
- [ ] Tri en profondeur (depth sorting)
- [ ] Optimisations de performance

## Licence

MIT
