# Tilesets pour iso3d

Ce dossier contient les définitions de tilesets pour la librairie iso3d.

## Structure d'un fichier Tileset

Un fichier tileset est un fichier Lua qui retourne une table avec la structure suivante :

```lua
return {
  -- Nom du tileset
  name = "Nom du Tileset",

  -- Métadonnées (optionnel)
  metadata = {
    author = "Auteur",
    version = "1.0",
    description = "Description du tileset"
  },

  -- Définitions des tuiles
  tiles = {
    -- ID de la tuile (utilisé dans les fichiers .map)
    id = {
      -- Informations de base
      name = "Nom de la tuile",
      description = "Description de la tuile",

      -- Propriétés visuelles
      sprite = "chemin/vers/sprite.png",          -- Sprite unique
      spriteVariants = {                          -- Ou plusieurs variantes
        "chemin/vers/sprite_1.png",
        "chemin/vers/sprite_2.png",
      },
      color = {r, g, b, a},                       -- Couleur RGBA (0-1)

      -- Paramètres d'affichage
      heightOffset = 0,                           -- Décalage en hauteur
      scale = 1.0,                                -- Échelle (1.0 = normal)
      opacity = 1.0,                              -- Opacité (0-1)
      glow = false,                               -- Effet de lueur

      -- Animation
      animated = false,                           -- Tuile animée
      frameCount = 1,                             -- Nombre de frames
      frameDuration = 0.1,                        -- Durée par frame (secondes)

      -- Propriétés gameplay
      walkable = true,                            -- Peut-on marcher dessus
      transparent = false,                        -- Transparent (ordre de rendu)
      tags = {"tag1", "tag2"},                   -- Tags personnalisés

      -- Paramètres personnalisés
      custom = {
        propriete = valeur,
        -- Ajoutez vos propres paramètres
      }
    }
  }
}
```

## Propriétés disponibles

### Propriétés de base
- **name** (string) : Nom lisible de la tuile
- **description** (string) : Description détaillée

### Propriétés visuelles
- **sprite** (string) : Chemin vers le sprite/texture
- **spriteVariants** (table) : Liste de chemins pour variantes multiples
- **color** (table) : Couleur RGBA `{r, g, b, a}` où chaque valeur est entre 0 et 1

### Paramètres d'affichage
- **heightOffset** (number) : Décalage vertical additionnel en pixels
- **scale** (number) : Facteur d'échelle (1.0 = taille normale)
- **opacity** (number) : Opacité de 0 (transparent) à 1 (opaque)
- **glow** (boolean) : Active un effet de lueur/brillance

### Animation
- **animated** (boolean) : Si true, la tuile est animée
- **frameCount** (number) : Nombre de frames dans l'animation
- **frameDuration** (number) : Durée de chaque frame en secondes

### Propriétés gameplay
- **walkable** (boolean) : Indique si on peut marcher sur cette tuile
- **transparent** (boolean) : Pour le tri en profondeur du rendu
- **tags** (table) : Liste de tags pour la logique du jeu

### Paramètres personnalisés
- **custom** (table) : Table libre pour vos propres paramètres

## Exemples de fichiers

### simple.lua
Tileset minimal avec les 4 types de base (herbe, eau, pierre, terre).

### basic.lua
Tileset complet avec 8 types de tuiles incluant forêt, montagne, route et sable.

## Utilisation

```lua
local iso3d = require('iso3d')

-- Charger un tileset
local tileset = iso3d.tileset.loadFromFile('tilesets/basic.lua')

-- Ou créer le tileset par défaut
local tileset = iso3d.tileset.createDefault()

-- Obtenir une définition
local grassDef = tileset:getDefinition('g')
print(grassDef.name)        -- "Grass"
print(grassDef.walkable)    -- true
```

## Créer votre propre Tileset

1. Créez un nouveau fichier `.lua` dans ce dossier
2. Copiez la structure de `simple.lua` ou `basic.lua`
3. Modifiez les définitions selon vos besoins
4. Chargez-le dans votre jeu avec `loadFromFile()`

## Types de tuiles recommandés

Voici les IDs standards utilisés dans les exemples :

- `g` : Grass (herbe)
- `w` : Water (eau)
- `s` : Stone (pierre)
- `d` : Dirt (terre)
- `n` : saNd (sable)
- `f` : Forest (forêt)
- `m` : Mountain (montagne)
- `r` : Road (route)

Vous pouvez utiliser vos propres IDs selon vos besoins.
