# Système de Rendu Isométrique - iso3d

Ce document explique en détail comment fonctionne le rendu des tuiles dans la librairie iso3d.

## Table des matières

1. [Projection Isométrique](#projection-isométrique)
2. [Rendu des Tuiles](#rendu-des-tuiles)
3. [Tri en Profondeur](#tri-en-profondeur)
4. [Pipeline de Rendu](#pipeline-de-rendu)
5. [Optimisations](#optimisations)

## Projection Isométrique

### Principe de base

La projection isométrique transforme des coordonnées 3D (x, y, z) en coordonnées 2D d'écran (screenX, screenY).

### Formule mathématique

```lua
function iso3d.toScreen(x, y, z)
  local screenX = (x - y) * (tileWidth / 2)
  local screenY = (x + y) * (tileHeight / 2) - z
  return screenX, screenY
end
```

### Explication détaillée

**Axe X de l'écran (horizontal):**
```
screenX = (x - y) * (tileWidth / 2)
```
- `x - y` : Différence entre les coordonnées monde X et Y
- Multipliée par la moitié de la largeur de tuile (32px par défaut)
- Résultat: déplacement horizontal sur l'écran

**Axe Y de l'écran (vertical):**
```
screenY = (x + y) * (tileHeight / 2) - z
```
- `x + y` : Somme des coordonnées monde X et Y
- Multipliée par la moitié de la hauteur de tuile (16px par défaut)
- `- z` : Soustraction de la hauteur pour l'élévation
- Résultat: déplacement vertical sur l'écran

### Exemple visuel

```
Monde 3D (vue du dessus):       Écran 2D (projection iso):

    Y                                  screenY
    ^                                    ^
    |                                   /
  (0,3)                                /
    |                              (0,3)
  (0,2)                              /
    |                              /
  (0,1)                          (0,1)
    |                          /
  (0,0)-->(1,0)-->(2,0)     (0,0)-->(2,0)----> screenX
         X

Coordonnées (2, 0, 0):
  screenX = (2 - 0) * 32 = 64
  screenY = (2 + 0) * 16 = 32
  → Point à (64, 32) sur l'écran

Coordonnées (0, 2, 0):
  screenX = (0 - 2) * 32 = -64
  screenY = (0 + 2) * 16 = 32
  → Point à (-64, 32) sur l'écran

Coordonnées (1, 1, 10):
  screenX = (1 - 1) * 32 = 0
  screenY = (1 + 1) * 16 - 10 = 22
  → Point à (0, 22) sur l'écran (élevé de 10px)
```

## Rendu des Tuiles

### 1. Rendu en Diamant (Flat)

**Fonction:** `iso3d.drawTileDiamond(x, y, z, color, opacity)`

**Processus:**

```lua
-- 1. Convertir la position en coordonnées écran
local screenX, screenY = iso3d.toScreen(x, y, z)

-- 2. Calculer les 4 sommets du diamant
local vertices = {
  screenX, screenY - th,        -- Haut
  screenX + tw, screenY,        -- Droite
  screenX, screenY + th,        -- Bas
  screenX - tw, screenY         -- Gauche
}

-- 3. Dessiner le polygone
love.graphics.polygon('fill', vertices)

-- 4. Dessiner le contour
love.graphics.polygon('line', vertices)
```

**Forme du diamant:**

```
        (screenX, screenY-th)
               /\
              /  \
             /    \
(-tw,       /      \     (+tw,
screenY)   <  tile  >   screenY)
            \      /
             \    /
              \  /
               \/
        (screenX, screenY+th)
```

Avec tileWidth=64 et tileHeight=32:
- tw = 32 (demi-largeur)
- th = 16 (demi-hauteur)

### 2. Rendu en Bloc 3D (Block)

**Fonction:** `iso3d.drawTileBlock(x, y, z, height, color, opacity)`

**Processus:**

Le bloc 3D est composé de **3 faces** :

#### Face Gauche (70% de luminosité)
```lua
local leftFace = {
  screenX - tw, screenY,              -- Haut gauche
  screenX, screenY + th,              -- Bas
  screenX, screenY + th + height,     -- Bas + hauteur
  screenX - tw, screenY + height      -- Haut gauche + hauteur
}
love.graphics.setColor(r * 0.7, g * 0.7, b * 0.7, a)
love.graphics.polygon('fill', leftFace)
```

#### Face Droite (85% de luminosité)
```lua
local rightFace = {
  screenX + tw, screenY,              -- Haut droite
  screenX, screenY + th,              -- Bas
  screenX, screenY + th + height,     -- Bas + hauteur
  screenX + tw, screenY + height      -- Haut droite + hauteur
}
love.graphics.setColor(r * 0.85, g * 0.85, b * 0.85, a)
love.graphics.polygon('fill', rightFace)
```

#### Face Supérieure (100% de luminosité)
```lua
local topFace = {
  screenX, screenY - th + height,        -- Haut
  screenX + tw, screenY + height,        -- Droite
  screenX, screenY + th + height,        -- Bas
  screenX - tw, screenY + height         -- Gauche
}
love.graphics.setColor(r, g, b, a)
love.graphics.polygon('fill', topFace)
```

**Visualisation d'un bloc:**

```
Vue isométrique:

          Top (100%)
            /\
           /  \
          /    \
         /______\
        /\      /
       /  \    / Right (85%)
 Left /    \  /
(70%) \    /\/
       \  /  /
        \/  /
         \/
```

**Shading (ombrage):**
- Face gauche: 70% (plus sombre, moins de lumière)
- Face droite: 85% (ombrage moyen)
- Face supérieure: 100% (pleine lumière)

Cela crée un effet de profondeur et de volume.

### 3. Rendu avec Sprites

**Fonction:** `iso3d.drawTileSprite(x, y, z, sprite, opacity, scale)`

**Processus:**

```lua
-- 1. Convertir la position
local screenX, screenY = iso3d.toScreen(x, y, z)

-- 2. Calculer l'échelle du sprite
local spriteWidth = sprite:getWidth()
local spriteHeight = sprite:getHeight()
local spriteScale = (tileWidth / spriteWidth) * scale

-- 3. Dessiner le sprite centré
love.graphics.draw(
  sprite,
  screenX,
  screenY - (spriteHeight * spriteScale / 2) + tileHeight/2,
  0,  -- rotation
  spriteScale, spriteScale,
  spriteWidth / 2, spriteHeight / 2  -- origine (centre)
)
```

**Positionnement:**
- Le sprite est centré horizontalement sur le tile (screenX)
- Verticalement: ajusté pour que le bas du sprite soit au niveau de la tuile
- L'échelle est automatiquement calculée pour s'adapter à la largeur de tuile

### 4. Rendu Combiné (Bloc + Sprite)

Pour les tuiles avec hauteur ET sprite:

```lua
if blockHeight ~= 0 then
  -- 1. Dessiner le bloc 3D (avec opacité réduite)
  iso3d.drawTileBlock(x, y, 0, blockHeight, color, opacity * 0.8)

  -- 2. Dessiner le sprite au-dessus du bloc
  iso3d.drawTileSprite(x, y, blockHeight, sprite, opacity, scale)
end
```

**Résultat visuel:**

```
  [Sprite]       <- Sprite au sommet
     ||
     ||
  [Bloc 3D]      <- Bloc coloré en dessous
     ||
  ========       <- Niveau 0
```

## Tri en Profondeur

### Principe

Pour un rendu correct en isométrique, les tuiles doivent être dessinées **de l'arrière vers l'avant** (back-to-front).

### Algorithme de tri

```lua
-- Parcourir de Y max à Y min (arrière vers avant)
for y = gameMap.height, 1, -1 do
  -- Pour chaque Y, parcourir X de gauche à droite
  for x = 1, gameMap.width do
    local tile = gameMap:getTile(x, y)
    if tile then
      iso3d.drawTile(tile, x, y, tileset, renderMode)
    end
  end
end
```

### Pourquoi cet ordre?

En projection isométrique:
- Les tuiles avec Y **élevé** apparaissent **en arrière** sur l'écran
- Les tuiles avec Y **faible** apparaissent **en avant** sur l'écran

**Exemple visuel:**

```
Map 3x3 (vue du dessus):        Ordre de rendu:
  1,3  2,3  3,3                    1  2  3
  1,2  2,2  3,2                    4  5  6
  1,1  2,1  3,1                    7  8  9

Vue isométrique:
     1  2  3
      \ | /
    4  \|/  6
     \  5  /
      \ | /
    7  \|/  9
        8
```

Si on dessinait dans l'ordre inverse (Y=1 vers Y=3), les tuiles arrières cacheraient les tuiles avant!

### Cas des hauteurs

Les tuiles hautes sont dessinées dans le même ordre Y, mais leur hauteur est prise en compte dans la coordonnée Z:

```lua
local z = tile.height * 10 + heightOffset
```

Le rendu back-to-front + la coordonnée Y d'écran qui intègre Z garantit le bon ordre.

## Pipeline de Rendu

### Fonction principale: `iso3d.drawMap()`

**Étape par étape:**

```lua
function iso3d.drawMap(gameMap, renderMode, offset)
  -- 1. Préparation
  renderMode = renderMode or 'block'
  offset = offset or {x = 0, y = 0}

  -- 2. Appliquer l'offset caméra
  love.graphics.push()
  love.graphics.translate(offset.x, offset.y)

  -- 3. Boucle de rendu (back-to-front)
  for y = gameMap.height, 1, -1 do
    for x = 1, gameMap.width do
      local tile = gameMap:getTile(x, y)
      if tile then
        iso3d.drawTile(tile, x, y, gameMap:getTileset(), renderMode)
      end
    end
  end

  -- 4. Restaurer l'état graphique
  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)
end
```

### Fonction de rendu de tuile: `iso3d.drawTile()`

**Arbre de décision:**

```
drawTile()
    |
    ├─> Récupérer tileDef du tileset
    |
    ├─> Calculer propriétés (color, opacity, scale, z)
    |
    ├─> Récupérer sprite (si disponible)
    |
    └─> Décider du rendu:
         |
         ├─> Si sprite existe:
         |    |
         |    ├─> Mode 'flat':
         |    |    └─> drawTileSprite(x, y, z)
         |    |
         |    └─> Mode 'block':
         |         ├─> Si height != 0:
         |         |    ├─> drawTileBlock() (bloc coloré)
         |         |    └─> drawTileSprite() (sprite au sommet)
         |         |
         |         └─> Sinon:
         |              └─> drawTileSprite(x, y, z)
         |
         └─> Sinon (pas de sprite):
              |
              ├─> Mode 'flat':
              |    └─> drawTileDiamond()
              |
              └─> Mode 'block':
                   ├─> Si height != 0:
                   |    └─> drawTileBlock()
                   |
                   └─> Sinon:
                        └─> drawTileDiamond()
```

### Modes de rendu

**Mode 'flat':**
- Tuiles plates (diamants)
- Pas d'effet 3D
- Sprites dessinés à la hauteur Z
- Plus rapide, style 2.5D

**Mode 'block':**
- Blocs 3D avec volume
- Ombrage sur les faces
- Sprites au sommet des blocs
- Plus réaliste, vrai 3D isométrique

## Gestion des Hauteurs

### Conversion hauteur → pixels

```lua
local z = tile.height * 10 + heightOffset
```

- Chaque niveau de hauteur = 10 pixels
- heightOffset (du tileset) permet un ajustement fin

**Exemple:**
```
Hauteur -2: z = -20 pixels (sous le sol)
Hauteur -1: z = -10 pixels
Hauteur  0: z =   0 pixels (niveau sol)
Hauteur  1: z =  10 pixels
Hauteur  2: z =  20 pixels
Hauteur  3: z =  30 pixels
```

### Rendu des hauteurs négatives

```lua
if blockHeight ~= 0 then
  iso3d.drawTileBlock(x, y, 0, blockHeight, color, opacity)
end
```

- `blockHeight` peut être négatif
- Si négatif: le bloc est dessiné "enfoncé" sous le niveau 0
- La face supérieure apparaît plus bas

**Visualisation:**

```
Hauteur 2:          Hauteur 0:          Hauteur -1:
   ___                 ___              =========
  |   |               |___|                ___
  |   |              =========            |___|
  |___|                                  =========
=========
```

## Animations

### Update des animations

```lua
function love.update(dt)
  tileset:updateAnimations(dt)
end
```

**Processus:**

```lua
function TileDefinition:updateAnimation(dt)
  self._animationTimer = self._animationTimer + dt

  if self._animationTimer >= self.frameDuration then
    self._animationTimer = self._animationTimer - self.frameDuration
    self._currentFrame = (self._currentFrame % self.frameCount) + 1
  end
end
```

### Récupération de la frame courante

```lua
function TileDefinition:getCurrentSprite()
  if self.animated and #self._loadedSprites > 0 then
    return self._loadedSprites[self._currentFrame]
  end
  return self._loadedSprites.main
end
```

### Rendu animé

Chaque appel à `drawTile()` récupère la frame courante via `getCurrentSprite()`, donc l'animation est automatique.

## Optimisations

### 1. Cache des sprites

```lua
-- Chargement une seule fois
tileset:loadSprites()

-- Réutilisation à chaque frame
local sprite = tileDef:getCurrentSprite()
```

**Avantages:**
- Pas de rechargement à chaque frame
- Mémoire GPU optimisée
- Performances stables

### 2. Batching implicite

Love2D groupe automatiquement les appels de rendu similaires (même texture, même mode).

### 3. Culling (non implémenté actuellement)

**Optimisation future possible:**

```lua
-- Ne dessiner que les tuiles visibles
if isVisibleOnScreen(screenX, screenY) then
  iso3d.drawTile(tile, x, y, tileset, renderMode)
end
```

### 4. Dirty rectangles (non implémenté)

**Optimisation future:**
- Marquer les zones modifiées
- Ne redessiner que ces zones
- Utile pour les grandes maps statiques

## Exemples Pratiques

### Exemple 1: Tuile plate simple

```lua
-- Tuile herbe à (5, 5) au niveau du sol
iso3d.drawTileDiamond(5, 5, 0, {0.2, 0.8, 0.3, 1}, 1.0)
```

**Calculs:**
```
screenX = (5 - 5) * 32 = 0
screenY = (5 + 5) * 16 - 0 = 80
```

Diamant centré à (0, 80) sur l'écran.

### Exemple 2: Bloc 3D élevé

```lua
-- Pierre à (3, 2) avec hauteur 2
local tile = {type = 's', height = 2}
local z = 2 * 10 = 20

iso3d.drawTileBlock(3, 2, 0, 20, {0.5, 0.5, 0.5, 1}, 1.0)
```

**Calculs:**
```
screenX = (3 - 2) * 32 = 32
screenY = (3 + 2) * 16 = 80
```

Bloc dessiné à (32, 80) avec 20px de hauteur.

### Exemple 3: Map complète 3x3

```lua
local gameMap = iso3d.map.loadFromString([[
  g:0 g:1 s:2
  w:-1 g:0 g:1
  g:0 g:0 g:0
]])

iso3d.drawMap(gameMap, 'block', {x = 400, y = 300})
```

**Ordre de rendu:**
1. (1,3), (2,3), (3,3) - Ligne arrière
2. (1,2), (2,2), (3,2) - Ligne milieu
3. (1,1), (2,1), (3,1) - Ligne avant

Chaque tuile est rendue avec sa hauteur respective.

## Résumé

Le système de rendu iso3d fonctionne en plusieurs étapes:

1. **Projection**: Transformation 3D→2D avec `toScreen()`
2. **Choix du rendu**: Sprite ou couleur, flat ou block
3. **Tri en profondeur**: Back-to-front (Y élevé vers Y bas)
4. **Dessin**: Polygones ou sprites avec Love2D
5. **Animations**: Frame courante mise à jour automatiquement

**Points clés:**
- Projection isométrique simple et efficace
- Tri par ordre Y pour occlusion correcte
- Support sprites + couleurs de fallback
- Ombrage automatique sur blocs 3D
- Animations fluides avec delta time
