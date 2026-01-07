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

La projection isométrique transforme des coordonnées 2D de grille (x, y) en coordonnées 2D d'écran (screenX, screenY).

### Formule mathématique

```lua
function iso3d.toScreen(x, y)
  local screenX = (x - y) * (tileWidth / 2)
  local screenY = (x + y) * (tileHeight / 2)
  return screenX, screenY
end
```

### Explication détaillée

**Axe X de l'écran (horizontal):**
```
screenX = (x - y) * (tileWidth / 2)
```
- `x - y` : Différence entre les coordonnées grille X et Y
- Multipliée par la moitié de la largeur de tuile (32px par défaut)
- Résultat: déplacement horizontal sur l'écran

**Axe Y de l'écran (vertical):**
```
screenY = (x + y) * (tileHeight / 2)
```
- `x + y` : Somme des coordonnées grille X et Y
- Multipliée par la moitié de la hauteur de tuile (16px par défaut)
- Résultat: déplacement vertical sur l'écran

### Convention de coordonnées

Dans le fichier map:
- **Première ligne** → Rangée la plus **haute** à l'écran (sommet du losange)
- **Dernière ligne** → Rangée la plus **basse** à l'écran

L'affichage isométrique correspond à une **rotation anti-horaire de 45°** avec écrasement vertical (rapport 2:1).

### Exemple visuel

```
Grille 2D (fichier map):        Écran 2D (projection iso):

    (1,1) (2,1) (3,1)                   (1,1)
    (1,2) (2,2) (3,2)              (1,2)  (2,1)
    (1,3) (2,3) (3,3)         (1,3)  (2,2)  (3,1)
                                 (2,3)  (3,2)
                                    (3,3)

Coordonnées (2, 1):
  screenX = (2 - 1) * 32 = 32
  screenY = (2 + 1) * 16 = 48
  → Point à (32, 48) sur l'écran

Coordonnées (1, 2):
  screenX = (1 - 2) * 32 = -32
  screenY = (1 + 2) * 16 = 48
  → Point à (-32, 48) sur l'écran

Coordonnées (2, 2):
  screenX = (2 - 2) * 32 = 0
  screenY = (2 + 2) * 16 = 64
  → Point à (0, 64) sur l'écran (centre, plus bas)
```

## Rendu des Tuiles

### 1. Rendu en Losange (Diamond)

**Fonction:** `iso3d.drawTileDiamond(x, y, color, opacity)`

**Processus:**

```lua
-- 1. Convertir la position en coordonnées écran
local screenX, screenY = iso3d.toScreen(x, y)

-- 2. Calculer les 4 sommets du losange
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

**Forme du losange:**

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

### 2. Rendu avec Sprites

**Fonction:** `iso3d.drawTileSprite(x, y, sprite, opacity, scale)`

**Processus:**

```lua
-- 1. Convertir la position
local screenX, screenY = iso3d.toScreen(x, y)

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
- Le sprite est centré horizontalement sur la tuile (screenX)
- Verticalement: ajusté pour que le bas du sprite soit au niveau de la tuile
- L'échelle est automatiquement calculée pour s'adapter à la largeur de tuile

### 3. Rendu Combiné (Tuile avec Tileset)

Pour les tuiles avec propriétés du tileset:

**Avec sprite:**
```lua
function iso3d.drawTile(tile, x, y, tileset)
  local tileDef = tileset:getDefinition(tile.type)
  local sprite = tileDef:getCurrentSprite()

  if sprite then
    -- Utiliser le sprite
    iso3d.drawTileSprite(x, y, sprite, opacity, scale)
  else
    -- Fallback: utiliser la couleur
    iso3d.drawTileDiamond(x, y, color, opacity)
  end
end
```

**Animations:**
Pour les tuiles animées, `getCurrentSprite()` retourne la frame actuelle de l'animation selon le temps écoulé.

## Tri en Profondeur

### Ordre de dessin

Pour un rendu correct en isométrique, les tuiles doivent être dessinées **de l'arrière vers l'avant** (back-to-front).

**Règle:** Dessiner d'abord les tuiles avec Y plus grand, puis celles avec Y plus petit.

```lua
for y = gameMap.height, 1, -1 do  -- Y décroissant
  for x = 1, gameMap.width do
    iso3d.drawTile(tile, x, y, tileset)
  end
end
```

### Exemple visuel

```
Map 3x3:

    1 2 3        Ordre de dessin:
    4 5 6        7, 8, 9  (ligne Y=3)
    7 8 9        4, 5, 6  (ligne Y=2)
                 1, 2, 3  (ligne Y=1)

Vue isométrique résultante:
         1
       4   2
     7   5   3
       8   6
         9
```

En dessinant Y=3 en premier (tuiles 7,8,9), puis Y=2 (4,5,6), puis Y=1 (1,2,3), on assure que les tuiles "devant" (Y petit) recouvrent celles "derrière" (Y grand).

## Pipeline de Rendu

### Processus complet

1. **Initialisation**
   ```lua
   iso3d.init({tileWidth = 64, tileHeight = 32})
   tileset = iso3d.tileset.loadFromFile('tilesets/simple.lua')
   tileset:loadSprites()
   gameMap = iso3d.map.loadFromFile('maps/test.map')
   gameMap:setTileset(tileset)
   ```

2. **Update (chaque frame)**
   ```lua
   function love.update(dt)
     tileset:updateAnimations(dt)  -- Avance les animations
   end
   ```

3. **Rendu (chaque frame)**
   ```lua
   function love.draw()
     iso3d.drawMap(gameMap, {x = 400, y = 300})
   end
   ```

### Détail de `drawMap`

```lua
function iso3d.drawMap(gameMap, offset)
  love.graphics.push()
  love.graphics.translate(offset.x, offset.y)  -- Décalage caméra

  -- Parcourir back-to-front
  for y = gameMap.height, 1, -1 do
    for x = 1, gameMap.width do
      local tile = gameMap:getTile(x, y)
      if tile then
        iso3d.drawTile(tile, x, y, gameMap:getTileset())
      end
    end
  end

  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)  -- Reset couleur
end
```

### Détail de `drawTile`

```lua
function iso3d.drawTile(tile, x, y, tileset)
  -- 1. Récupérer les propriétés du tileset
  local tileDef = tileset:getDefinition(tile.type)
  local color = tileDef.color
  local opacity = tileDef.opacity
  local scale = tileDef.scale

  -- 2. Obtenir le sprite actuel (frame d'animation si animé)
  local sprite = tileDef:getCurrentSprite()

  -- 3. Rendu
  if sprite then
    iso3d.drawTileSprite(x, y, sprite, opacity, scale)
  else
    iso3d.drawTileDiamond(x, y, color, opacity)
  end

  -- 4. Debug (si activé)
  if iso3d.config.debug then
    local screenX, screenY = iso3d.toScreen(x, y)
    love.graphics.print(tile.type, screenX - 10, screenY - 5)
  end
end
```

## Optimisations

### 1. Culling (Future)

Ne dessiner que les tuiles visibles à l'écran:

```lua
function isVisible(x, y, cameraOffset, screenWidth, screenHeight)
  local screenX, screenY = iso3d.toScreen(x, y)
  screenX = screenX + cameraOffset.x
  screenY = screenY + cameraOffset.y

  return screenX > -tileWidth and screenX < screenWidth + tileWidth
     and screenY > -tileHeight and screenY < screenHeight + tileHeight
end
```

### 2. Sprite Batching (Future)

Grouper les appels de dessin pour réduire les changements d'état GPU:

```lua
-- Utiliser SpriteBatch de Love2D
local batch = love.graphics.newSpriteBatch(tileset.image, 1000)

-- Ajouter toutes les tuiles au batch
for y = gameMap.height, 1, -1 do
  for x = 1, gameMap.width do
    batch:add(quad, screenX, screenY)
  end
end

-- Dessiner tout en une fois
love.graphics.draw(batch)
```

### 3. Cache de coordonnées écran

Pré-calculer les coordonnées écran si la map ne bouge pas:

```lua
local screenCoords = {}
for y = 1, gameMap.height do
  screenCoords[y] = {}
  for x = 1, gameMap.width do
    screenCoords[y][x] = {iso3d.toScreen(x, y)}
  end
end
```

### 4. Animations optimisées

Le système d'animation actuel:
- Calcule la frame actuelle à chaque appel (O(1))
- Pas de pré-calcul nécessaire
- Très efficace même avec beaucoup de tuiles animées

```lua
function TileDefinition:getCurrentSprite()
  if not self.animated or not self.frames then
    return self.frames and self.frames[1] or nil
  end

  local frameIndex = math.floor(self.currentTime / self.frameDuration) % self.frameCount + 1
  return self.frames[frameIndex]
end
```

## Architecture Modulaire

La librairie est organisée en modules séparés pour la maintenabilité:

- **iso3d/init.lua** - Point d'entrée, exports
- **iso3d/projection.lua** - Conversion coordonnées
- **iso3d/render.lua** - Rendu des tuiles et maps
- **iso3d/debug.lua** - Visualisation et debug
- **iso3d/map.lua** - Gestion des maps
- **iso3d/tileset.lua** - Gestion des tilesets

Cette séparation permet:
- Code plus lisible et maintenable
- Tests unitaires plus faciles
- Modifications ciblées sans impact sur les autres modules
- Réutilisation possible des modules individuellement

## Performances

### Benchmarks (estimation)

Map 64x64 (4096 tuiles):
- Rendu avec couleurs: ~60 FPS
- Rendu avec sprites: ~55 FPS
- Rendu avec animations: ~50 FPS

Map 128x128 (16384 tuiles):
- Avec culling: ~60 FPS
- Sans culling: ~20 FPS

*Note: Les performances réelles dépendent du matériel et du nombre de tuiles animées.*

### Recommandations

1. **Activer le culling** pour les grandes maps (>64x64)
2. **Limiter les animations** aux tuiles visibles
3. **Utiliser SpriteBatch** pour les tilesets avec beaucoup de tuiles
4. **Pré-charger les sprites** au chargement de la map
5. **Éviter les allocations** dans la boucle de rendu

## Conclusion

Le système de rendu iso3d offre:
- ✅ Projection isométrique mathématiquement correcte
- ✅ Support des sprites avec animations
- ✅ Tri en profondeur automatique
- ✅ Architecture modulaire et maintenable
- ✅ Fallback automatique (couleurs si pas de sprite)
- ✅ Mode debug pour le développement
- 🔄 Optimisations futures (culling, batching)

Pour plus d'informations, voir:
- **[iso3d/README.md](../iso3d/README.md)** - Documentation complète de l'API
- **[maps/README.md](../maps/README.md)** - Format des fichiers map
- **[assets/README.md](../assets/README.md)** - Création de sprites
