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

## Exemple

```lua
local iso3d = require('iso3d')

function love.load()
  iso3d.init({ debug = true })
end

function love.draw()
  love.graphics.translate(400, 300) -- Centre l'origine

  -- Dessiner un cube en isométrique
  iso3d.drawLine(0, 0, 0, 10, 0, 0, {1, 1, 1, 1})
  iso3d.drawLine(0, 0, 0, 0, 10, 0, {1, 1, 1, 1})
  iso3d.drawLine(0, 0, 0, 0, 0, 10, {1, 1, 1, 1})
end
```

## Roadmap

- [x] Structure de base de la librairie
- [x] Conversion de coordonnées 3D vers 2D
- [x] Conversion de coordonnées 2D vers 3D
- [x] Fonctions de dessin basiques (points, lignes)
- [ ] Dessin de formes 3D (cubes, plans)
- [ ] Gestion de sprites isométriques
- [ ] Système de caméra
- [ ] Tri en profondeur (depth sorting)
- [ ] Optimisations de performance

## Licence

MIT
