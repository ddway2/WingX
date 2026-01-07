# Format de fichier Map (.map)

Ce document décrit le format des fichiers de map utilisés par la librairie iso3d.

## Vue d'ensemble

Les fichiers `.map` utilisent un format textuel simple pour définir des grilles de tuiles isométriques. Chaque fichier représente une map 2D avec des tuiles ayant différents types et hauteurs.

## Syntaxe de base

### Format d'une tuile

```
type:hauteur:paramètres
```

- **type** : Un identifiant de type de tuile (une ou plusieurs lettres)
- **hauteur** : Un nombre entier de -2 à 3
- **paramètres** : (Optionnel) Paramètres personnalisés au format `key=value,key2=value2`

### Structure du fichier

```
# Commentaire
type:hauteur type:hauteur type:hauteur
type:hauteur type:hauteur type:hauteur
type:hauteur type:hauteur type:hauteur
```

- Chaque ligne représente une rangée de tuiles (axe Y)
- Les tuiles sur une ligne sont séparées par des espaces (simples ou multiples)
- Les lignes vides sont ignorées
- Les commentaires commencent par `#` ou `--`

## Types de tuiles

Les types de tuiles standard sont:

| Type | Nom     | Description           |
|------|---------|-----------------------|
| `g`  | Grass   | Herbe, terrain normal |
| `w`  | Water   | Eau                   |
| `s`  | Stone   | Pierre, roche         |
| `d`  | Dirt    | Terre, sol            |
| `n`  | Sand    | Sable                 |
| `.`  | Empty   | Tuile vide            |

**Note:** Les types de tuiles peuvent être étendus dans les fichiers tileset. Vous pouvez utiliser d'autres lettres pour définir des tuiles personnalisées.

## Hauteurs

Les hauteurs vont de **-2** (le plus bas) à **3** (le plus haut):

| Hauteur | Description          | Utilisation typique           |
|---------|----------------------|-------------------------------|
| `-2`    | Très profond         | Eau profonde, fosses          |
| `-1`    | Profond              | Eau peu profonde, routes      |
| `0`     | Niveau du sol        | Terrain plat (référence)      |
| `1`     | Surélevé             | Petites collines              |
| `2`     | Élevé                | Collines, plateaux            |
| `3`     | Très élevé           | Montagnes, tours              |

## Paramètres optionnels

Les paramètres personnalisés peuvent être ajoutés après la hauteur:

```
type:hauteur:param1=value1,param2=value2,param3=value3
```

### Exemples de paramètres

```
g:2:color=darkgreen,variant=2
w:0:flow=north,speed=fast
s:3:type=granite,texture=rough
```

**Note:** Les paramètres sont stockés dans `tile.params` et peuvent être utilisés par votre code de jeu pour des logiques personnalisées.

## Exemples

### Map simple 3x3

```
# Simple terrain
g:0 g:0 g:1
g:0 w:-1 g:1
g:1 g:1 g:2
```

### Map avec commentaires et paramètres

```
# Petite île avec montagne
# 5x5 tiles

w:-2 w:-2 w:-1 w:-1 w:-2
w:-2 w:-1 n:0  w:-1 w:-2
w:-1 n:0  g:1  n:0  w:-1
w:-1 g:1  s:3  g:1  w:-1
w:-2 w:-1 w:-1 w:-2 w:-2
```

### Map avec tuiles vides

```
# Utilisation de tuiles vides (.)
g:0 g:0 . . .
g:0 g:1 g:1 . .
. g:1 g:2 g:1 .
. . g:1 g:0 g:0
. . . g:0 g:0
```

### Map avec paramètres personnalisés

```
# Terrain avec variantes
g:0:variant=1 g:0:variant=2 g:0:variant=1
w:-1:animated=true w:-1:animated=true g:1
s:2:type=rock s:3:type=peak g:1
```

## Règles et conventions

### Espacement

Les tuiles sont séparées par des espaces (un ou plusieurs):
- Espaces simples: `g:0 w:-1 s:2`
- Espaces multiples: `g:0    w:-1    s:2`
- Espacement mixte: `g:0  w:-1      s:2`

### Commentaires

```
# Ceci est un commentaire de ligne complète
-- Ceci aussi est un commentaire

g:0 g:1 # Les commentaires en fin de ligne ne sont PAS supportés
```

### Tuiles manquantes

Si une ligne a moins de tuiles que la largeur de la map, les tuiles manquantes sont considérées comme vides (nil).

```
g:0 g:0 g:0
g:0 g:0      # Cette ligne n'a que 2 tuiles
g:0 g:0 g:0
```

### Hauteurs invalides

Les hauteurs en dehors de la plage [-2, 3] sont automatiquement limitées:
- Valeur < -2 → -2
- Valeur > 3 → 3

```
g:-5 → g:-2  # Limité à -2
s:10 → s:3   # Limité à 3
```

## Conseils pour créer des maps

### 1. Utilisez des commentaires

Décrivez votre map en haut du fichier:

```
# Nom: Forteresse du Nord
# Auteur: VotreNom
# Description: Une forteresse entourée de montagnes
# Taille: 32x32
```

### 2. Alignez visuellement

Pour les petites maps, alignez les tuiles pour mieux visualiser:

```
g:0  g:0  g:1  g:1  g:2
g:0  w:-1 w:-1 g:1  g:2
g:1  w:-1 s:1  g:1  g:2
g:1  g:1  g:1  g:2  g:2
g:2  g:2  g:2  g:2  g:3
```

### 3. Progression logique des hauteurs

Créez des transitions douces entre les hauteurs:

```
# Bon - transition douce
w:-2 w:-1 n:0 g:0 g:1 s:2 s:3

# À éviter - sauts brusques
w:-2 g:0 s:3 w:-2 s:3
```

### 4. Utilisez le script de génération

Pour les grandes maps, utilisez `generate_maps.py`:

```bash
python3 generate_maps.py
```

## Chargement en code

### Depuis un fichier

```lua
local iso3d = require('iso3d')

local gameMap = iso3d.map.loadFromFile('maps/mymap.map')
print('Map chargée: ' .. gameMap.width .. 'x' .. gameMap.height)
```

### Depuis une chaîne

```lua
local mapString = [[
# Mini map
g:0 g:1 g:2
w:-1 g:1 s:2
g:0 g:1 g:1
]]

local gameMap = iso3d.map.loadFromString(mapString)
```

### Accéder aux tuiles

```lua
-- Obtenir une tuile
local tile = gameMap:getTile(2, 3)
if tile then
  print('Type: ' .. tile.type)
  print('Hauteur: ' .. tile.height)

  -- Accéder aux paramètres
  if tile.params.variant then
    print('Variante: ' .. tile.params.variant)
  end
end

-- Parcourir toutes les tuiles
gameMap:each(function(x, y, tile)
  print(string.format('[%d,%d] %s:%d', x, y, tile.type, tile.height))
end)
```

### Modifier des tuiles

```lua
-- Créer une nouvelle tuile
local newTile = iso3d.map.Tile.new('s', 3, {type='peak'})

-- Placer la tuile
gameMap:setTile(5, 5, newTile)
```

### Exporter vers string

```lua
-- Convertir la map en format texte
local mapText = gameMap:toString()

-- Sauvegarder dans un fichier (en dehors de Love2D)
local file = io.open('output.map', 'w')
file:write(mapText)
file:close()
```

## Fichiers d'exemple

Le projet contient plusieurs maps d'exemple:

### Maps de démonstration 3D

- **demo_3d.map** (4x4) - Structure pyramidale montrant les blocs 3D avec différentes hauteurs
- **stairs_3d.map** (4x4) - Escalier diagonal utilisant toute la plage de hauteurs (-2 à 3)

Ces petites maps sont idéales pour:
- Comprendre le rendu des blocs 3D
- Voir l'effet du shading sur les faces (70%, 85%, 100%)
- Tester le tri en profondeur
- Observer la progression visuelle des hauteurs

### Maps de test

- **test.map** (8x8) - Petit terrain de test avec tous les types de hauteurs

### Maps procédurales

- **island_32x32.map** (32x32) - Île avec plage et montagne centrale
- **island_64x64.map** (64x64) - Grande île détaillée
- **terrain_32x32.map** (32x32) - Terrain varié avec rivière
- **terrain_64x64.map** (64x64) - Grand terrain avec vallées et pics
- **city_64x64.map** (64x64) - Grille de ville avec routes et bâtiments
- **checkerboard_64x64.map** (64x64) - Motif de test avec toutes les hauteurs

## Validation

### Format valide ✓

```
g:0
g:1 w:-1
s:2:color=gray
```

### Format invalide ✗

```
g:     # Hauteur manquante
:0     # Type manquant
g:0:   # Paramètres vides après ':'
```

## Performances

- Les fichiers .map sont chargés une seule fois au démarrage
- Pour les très grandes maps (>100x100), considérez le chargement par chunks
- Les commentaires et espaces n'affectent pas les performances (ignorés au parsing)

## Extensions futures

Le format pourrait être étendu pour supporter:
- Multiples couches (objets au-dessus des tuiles)
- Métadonnées de map (nom, auteur, version)
- Références à d'autres fichiers (tileset, scripts)
- Régions nommées
- Points d'intérêt (spawn points, etc.)

## Voir aussi

- **iso3d/README.md** - Documentation complète de la librairie
- **tilesets/README.md** - Format des fichiers tileset
- **assets/README.md** - Guide de création de sprites
- **generate_maps.py** - Script de génération de maps
