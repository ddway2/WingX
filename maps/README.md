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
- **hauteur** : Hauteur du bloc en unités de tuile (0 = flat, 1 = cube, 2 = 2x cube)
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

### Tuiles plates (height = 0)

| Type | Nom     | Description           |
|------|---------|-----------------------|
| `g`  | Grass   | Herbe, terrain normal |
| `w`  | Water   | Eau                   |
| `s`  | Stone   | Pierre, roche         |
| `d`  | Dirt    | Terre, sol            |
| `.`  | Empty   | Tuile vide            |

### Blocs 3D (avec hauteur)

| Type | Nom        | Hauteur | Hauteur réelle* | Description            |
|------|------------|---------|-----------------|------------------------|
| `b`  | Block      | 0.5     | 32px            | Demi-cube 3D           |
| `B`  | Cube       | 1       | 64px            | Cube parfait 3D        |
| `W`  | Wall       | 1.5     | 96px            | Mur, cube et demi      |
| `T`  | Tower      | 2       | 128px           | Tour, double cube      |

*_Avec tileWidth=64 (défaut)_

**Note:** Les types de tuiles peuvent être étendus dans les fichiers tileset. Vous pouvez utiliser d'autres lettres pour définir des tuiles personnalisées.

## Hauteurs de blocs 3D

La hauteur d'une tuile détermine si elle est rendue comme une tuile plate ou comme un bloc 3D en perspective isométrique.

Les hauteurs sont exprimées en **unités de tuile**, où **height=1** crée un **cube parfait** (hauteur = largeur).

| Hauteur | Description              | Hauteur réelle* | Rendu                                      |
|---------|--------------------------|-----------------|-------------------------------------------|
| `0`     | Tuile plate              | 0px             | Losange plat (vue de dessus uniquement)   |
| `0.5`   | Demi-cube                | 32px            | Bloc 3D avec faces latérales              |
| `1`     | Cube parfait             | 64px            | Cube (hauteur = largeur)                  |
| `1.5`   | Cube et demi             | 96px            | Bloc 3D allongé                           |
| `2`     | Double cube              | 128px           | Bloc 3D de 2x la hauteur d'un cube        |

*_Avec tileWidth=64 (défaut)_

**Notes importantes:**

- **Hauteur 0** : Rendu classique en losange plat (comme une tuile au sol)
- **Hauteur = 1** : Crée un cube parfait où hauteur = largeur de tuile
- **Hauteur > 0** : Rendu en bloc 3D isométrique avec trois faces visibles :
  - Face du dessus (dessus du bloc) - 100% de luminosité
  - Face droite - 80% de luminosité (ombrage)
  - Face gauche - 60% de luminosité (ombrage plus sombre)
- **Conversion en pixels** : `hauteur_pixels = height * tileWidth`
- **Valeurs personnalisées** : Vous pouvez utiliser n'importe quelle valeur >= 0 (ex: 0.25, 0.75, 3, etc.)
- **Tri en profondeur** : Les blocs sont automatiquement triés pour un rendu correct (arrière vers avant)

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

### Map simple 3x3 avec tuiles plates

```
# Simple terrain plat
g:0 g:0 s:0
g:0 w:0 s:0
d:0 d:0 d:0
```

### Map avec blocs 3D simples

```
# Blocs 3D - hauteurs variées (height=1 = cube parfait)
# 4x4

g:0 b:0 B:0 W:0
g:0 g:0 b:0 B:0
g:0 g:0 g:0 b:0
g:0 g:0 g:0 g:0
```

### Map avec blocs et terrain

```
# Murs et terrain (W=1.5 = cube et demi)
# 5x5

g:0 W:0 W:0 W:0 g:0
g:0 W:0 g:0 W:0 g:0
g:0 g:0 g:0 W:0 g:0
g:0 W:0 W:0 W:0 g:0
g:0 g:0 g:0 g:0 g:0
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

### Hauteurs négatives

Les hauteurs négatives sont automatiquement converties en 0:
- Valeur < 0 → 0

```
g:-5 → g:0  # Converti en 0
s:-1 → s:0  # Converti en 0
```

**Note:** Les hauteurs de blocs doivent être >= 0. Les valeurs recommandées sont 0, 32, 64, 96, 128, mais toute valeur positive est acceptée.

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

### 3. Organisation des blocs 3D

Organisez les blocs pour un rendu visuel cohérent:

```
# Bon - escalier progressif (height=1 = cube parfait)
g:0 b:0 B:0 W:0 T:0

# Structure avec murs (W=1.5 = mur cube et demi)
W:0 W:0 W:0 W:0
W:0 g:0 g:0 W:0
W:0 g:0 g:0 W:0
W:0 W:0 W:0 W:0
```

**Tri en profondeur automatique:** Les blocs sont automatiquement triés de l'arrière vers l'avant selon leur position (x, y) dans la grille. Pas besoin de gérer l'ordre manuellement !

**Système de hauteur:** Les hauteurs sont en unités de tuile. `height=1` crée un cube parfait où la hauteur du bloc = la largeur de la tuile. La conversion est : `hauteur_pixels = height * tileWidth`.

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

### Maps de démonstration de blocs 3D

- **blocks_simple.map** (4x4) - Petite map montrant les différentes hauteurs de blocs (0.5, 1, 1.5)
- **blocks_demo.map** (8x12) - Map complète démontrant :
  - Tours (height=2, double cube)
  - Murs formant une structure (height=1.5, cube et demi)
  - Progression de hauteurs (escalier 0.5→1→1.5→2)
  - Motifs de blocs variés
- **demo_3d.map** (4x4) - Structure pyramidale classique
- **stairs_3d.map** (4x4) - Escalier diagonal

Ces petites maps sont idéales pour:
- Comprendre le rendu des blocs 3D isométriques
- Voir l'effet du shading sur les trois faces (60%, 80%, 100%)
- Tester le tri en profondeur automatique
- Observer comment les blocs s'empilent visuellement
- Comprendre le système où **height=1 = cube parfait**
- Tester la rotation de caméra avec des blocs 3D

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
