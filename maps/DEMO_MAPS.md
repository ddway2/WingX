# Maps de Démonstration 3D

Ce document explique les maps de démonstration 4x4 créées pour illustrer le système de rendu 3D.

## demo_3d.map - Structure Pyramidale

### Contenu du fichier

```
w:-2 w:-1 w:-1 w:-2
w:-1 g:0  g:1  w:-1
w:-1 g:1  s:2  w:-1
w:-2 w:-1 w:-1 w:-2
```

### Description

Cette map forme une **structure pyramidale** entourée d'eau à différentes profondeurs.

**Vue de dessus (coordonnées):**
```
(1,4)  (2,4)  (3,4)  (4,4)
(1,3)  (2,3)  (3,3)  (4,3)
(1,2)  (2,2)  (3,2)  (4,2)
(1,1)  (2,1)  (3,1)  (4,1)
```

**Hauteurs:**
- Niveau -2 (coins) : Eau profonde, blocs enfoncés
- Niveau -1 (bords) : Eau peu profonde
- Niveau 0 (centre proche) : Herbe au niveau du sol
- Niveau 1 : Herbe surélevée
- Niveau 2 (centre) : Pierre au sommet

### Ce qu'elle démontre

1. **Blocs 3D avec différentes hauteurs**
   - Les blocs d'eau profonde (-2) sont visiblement plus bas
   - Les blocs de pierre (+2) s'élèvent au-dessus

2. **Shading automatique**
   - Face gauche : 70% de luminosité (plus sombre)
   - Face droite : 85% de luminosité (ombrage moyen)
   - Face supérieure : 100% de luminosité (pleine lumière)

3. **Tri en profondeur**
   - Les tuiles arrière (Y=4) sont dessinées en premier
   - Les tuiles avant (Y=1) sont dessinées en dernier
   - Occlusion correcte des blocs

### Rendu isométrique attendu

```
Vue isométrique (approximative):

        w:-2
       /    \
      /      \
    w:-1    w:-1
    /  \    /  \
   /    \  /    \
 w:-1   g:0   g:1   w:-1
  |      |  s:2 |     |
  |      | /  \ |     |
 w:-1   g:1    w:-1
  \    /  \    /
   \  /    \  /
    w:-2   w:-2
```

La pierre au centre (s:2) devrait être nettement visible comme le point le plus élevé.

## stairs_3d.map - Escalier Diagonal

### Contenu du fichier

```
s:3  s:2  g:1  w:0
s:2  g:1  w:0  w:-1
g:1  w:0  w:-1 d:-2
w:0  w:-1 d:-2 d:-2
```

### Description

Cette map forme un **escalier diagonal** descendant du coin supérieur gauche (hauteur 3) au coin inférieur droit (hauteur -2).

**Hauteurs par position:**
```
Position (1,4): s:3  (sommet)
Position (2,4): s:2
Position (3,4): g:1
Position (4,4): w:0

Position (1,3): s:2
Position (2,3): g:1
Position (3,3): w:0
Position (4,3): w:-1

Position (1,2): g:1
Position (2,2): w:0
Position (3,2): w:-1
Position (4,2): d:-2

Position (1,1): w:0
Position (2,1): w:-1
Position (3,1): d:-2
Position (4,1): d:-2  (le plus bas)
```

### Ce qu'elle démontre

1. **Progression complète des hauteurs**
   - Utilise toute la plage : -2, -1, 0, 1, 2, 3 (6 niveaux)
   - Chaque niveau est visible au moins une fois

2. **Effet d'escalier visuel**
   - Descente fluide et progressive
   - Permet de comparer visuellement les hauteurs
   - Montre la conversion hauteur → pixels (10px par niveau)

3. **Différents types de tuiles à différentes hauteurs**
   - Pierre (s) en haut : s:3, s:2
   - Herbe (g) au milieu : g:1
   - Eau (w) en dessous : w:0, w:-1
   - Terre (d) au fond : d:-2

4. **Tri diagonal**
   - La diagonale (1,4) → (4,1) montre bien le tri en profondeur
   - Chaque marche est correctement occultée par la précédente

### Rendu isométrique attendu

```
Vue isométrique (approximative):

     s:3
    /   \
   s:2   s:2
  /   \ /   \
 g:1   g:1   g:1
  |     |     |
 w:0   w:0   w:0   w:0
  |     |     |     |
w:-1  w:-1  w:-1  w:-1
  |     |     |     |
 d:-2  d:-2  d:-2  d:-2
```

On devrait voir clairement une descente en escalier de gauche à droite.

## Utilisation dans l'Application

### Charger les maps

**Via les touches numériques:**
- Touche `1` : demo_3d.map (pyramide)
- Touche `2` : stairs_3d.map (escalier)

**Via les commandes:**
```lua
-- Dans le code
gameMap = iso3d.map.loadFromFile('maps/demo_3d.map')
-- ou
gameMap = iso3d.map.loadFromFile('maps/stairs_3d.map')
```

### Tester les modes de rendu

**Mode Block (3D):**
- Appuyer sur `Espace` pour basculer en mode 'block'
- Les blocs 3D avec leurs faces sont visibles
- Le shading automatique est appliqué

**Mode Flat (2D):**
- Appuyer sur `Espace` pour basculer en mode 'flat'
- Seulement les losanges plats, pas de volume
- Les hauteurs affectent la position Y

### Mode Debug

Appuyer sur `D` pour activer le mode debug:
- Affiche les coordonnées de chaque tuile
- Affiche le type et la hauteur : "s:3", "w:-2", etc.
- Utile pour vérifier le tri en profondeur

## Valeurs Techniques

### Conversion hauteur → pixels

```lua
z = tile.height * 10
```

**Correspondance:**
- Hauteur -2 → z = -20px (enfoncé de 20 pixels)
- Hauteur -1 → z = -10px (enfoncé de 10 pixels)
- Hauteur  0 → z =   0px (niveau de référence)
- Hauteur  1 → z = +10px (élevé de 10 pixels)
- Hauteur  2 → z = +20px (élevé de 20 pixels)
- Hauteur  3 → z = +30px (élevé de 30 pixels)

### Dimensions des tiles

**Configuration par défaut:**
- tileWidth = 64 pixels
- tileHeight = 32 pixels

**Demi-dimensions (pour le dessin):**
- tw = 32 pixels (demi-largeur)
- th = 16 pixels (demi-hauteur)

### Shading des blocs

**Face gauche:**
```lua
color * 0.7  -- 70% de luminosité
```

**Face droite:**
```lua
color * 0.85  -- 85% de luminosité
```

**Face supérieure:**
```lua
color * 1.0  -- 100% de luminosité (pleine)
```

## Exercices Suggérés

### 1. Créer une pyramide parfaite

Modifier `demo_3d.map` pour créer une vraie pyramide symétrique:
```
w:-1 w:-1 w:-1 w:-1
w:-1 g:0  g:0  w:-1
w:-1 g:0  s:1  w:-1
w:-1 w:-1 w:-1 w:-1
```

### 2. Escalier inversé

Inverser `stairs_3d.map` pour monter au lieu de descendre:
```
d:-2 d:-2 w:-1 w:0
d:-2 w:-1 w:0  g:1
w:-1 w:0  g:1  s:2
w:0  g:1  s:2  s:3
```

### 3. Damier en hauteur

Créer un motif en damier avec alternance de hauteurs:
```
s:2 g:0 s:2 g:0
g:0 s:2 g:0 s:2
s:2 g:0 s:2 g:0
g:0 s:2 g:0 s:2
```

### 4. Vallée

Créer une vallée avec des bords élevés et un centre bas:
```
s:2 s:2 s:2 s:2
s:2 w:-1 w:-1 s:2
s:2 w:-1 w:-2 s:2
s:2 s:2 s:2 s:2
```

## Voir Aussi

- **[docs/RENDERING.md](../docs/RENDERING.md)** - Système de rendu détaillé
- **[maps/README.md](README.md)** - Format des fichiers map
- **[iso3d/README.md](../iso3d/README.md)** - Documentation de la librairie
