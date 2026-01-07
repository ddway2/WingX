# Assets Directory

Ce document décrit les assets utilisés par la librairie iso3d, notamment les sprites de tuiles.

## Directory Structure

```
assets/
└── tiles/          # Tile sprite images
    ├── water_frame1.png
    ├── water_frame2.png
    ├── ...
    └── grass.png
```

## Pré-requis des Sprites

### Format et Dimensions

**Format de fichier:**
- **Format requis:** PNG avec canal alpha (transparence)
- **Profondeur:** 32-bit RGBA recommandé
- **Compression:** PNG standard (compatible Love2D)

**Dimensions recommandées:**
- **Taille standard:** 64x64 pixels (s'adapte automatiquement à la taille des tuiles)
- **Minimum:** 32x32 pixels
- **Maximum:** 128x128 pixels (au-delà, impact sur les performances)
- **Forme:** Les sprites peuvent être rectangulaires, mais les formes carrées ou en losange isométrique fonctionnent mieux

**Important:**
- Les sprites sont automatiquement redimensionnés pour s'adapter à la largeur de tuile configurée (par défaut 64px)
- La transparence (canal alpha) est essentielle pour éviter les fonds rectangulaires visibles
- Le centre du sprite doit contenir l'élément principal (centrage automatique)

### Sprites Statiques (non animés)

**Structure requise:**
```lua
g = {
  name = "Grass",
  sprite = "assets/tiles/grass.png",  -- Chemin vers l'image
  color = {0.2, 0.8, 0.3, 1},        -- Couleur de fallback (obligatoire)
  animated = false                    -- Ou omis (false par défaut)
}
```

**Pré-requis:**
- ✅ Un seul fichier PNG
- ✅ Chemin relatif depuis la racine du projet
- ✅ Propriété `color` définie (utilisée si le sprite ne charge pas)
- ✅ Transparence pour les zones vides

**Conseils:**
- Utilisez des formes en losange pour un rendu isométrique naturel
- Centrez visuellement l'élément principal du sprite
- Évitez les détails trop fins qui seront perdus à petite échelle

### Sprites Animés

**Structure requise:**
```lua
w = {
  name = "Water",
  animated = true,                    -- OBLIGATOIRE
  frameCount = 4,                     -- Nombre de frames (OBLIGATOIRE)
  frameDuration = 0.3,                -- Durée par frame en secondes (OBLIGATOIRE)
  animationFrames = {                 -- Tableau de chemins (OBLIGATOIRE)
    "assets/tiles/water_frame1.png",
    "assets/tiles/water_frame2.png",
    "assets/tiles/water_frame3.png",
    "assets/tiles/water_frame4.png",
  },
  color = {0.2, 0.4, 0.9, 1},        -- Fallback (OBLIGATOIRE)
}
```

**Pré-requis obligatoires:**
- ✅ `animated = true`
- ✅ `frameCount` doit correspondre au nombre d'éléments dans `animationFrames`
- ✅ `frameDuration` > 0 (en secondes)
- ✅ `animationFrames` est un tableau avec au moins 1 frame
- ✅ Toutes les frames doivent avoir les **mêmes dimensions**
- ✅ Tous les fichiers doivent exister et être accessibles
- ✅ Propriété `color` définie pour le fallback

**Pré-requis recommandés:**
- 📌 Nombre de frames: 3-8 frames pour une animation fluide
- 📌 Durée par frame: 0.1s à 0.5s selon le type d'animation
- 📌 Toutes les frames dans le même dossier
- 📌 Nommage cohérent: `nom_frame1.png`, `nom_frame2.png`, etc.

**Types d'animations recommandés:**

| Type        | Frames | Durée/frame | Total cycle |
|-------------|--------|-------------|-------------|
| Eau lente   | 3-4    | 0.3-0.4s    | ~1.2s       |
| Feu         | 4-6    | 0.1-0.15s   | ~0.6s       |
| Lave        | 3-4    | 0.4-0.5s    | ~1.5s       |
| Portail     | 6-8    | 0.15s       | ~1.0s       |
| Cristaux    | 4-5    | 0.2-0.25s   | ~1.0s       |

## Chargement et Performance

### Chargement des Sprites

```lua
function love.load()
  -- Charger le tileset
  tileset = iso3d.tileset.loadFromFile('tilesets/animated.lua')

  -- Charger tous les sprites (fait une seule fois)
  tileset:loadSprites()

  -- Les sprites sont maintenant en cache
end
```

**Processus de chargement:**
1. Lecture du fichier tileset (.lua)
2. Appel de `loadSprites()` - charge toutes les images
3. Mise en cache des images dans `_loadedSprites`
4. Les erreurs de chargement affichent un warning mais n'arrêtent pas l'exécution

**Gestion des erreurs:**
- Si un sprite ne charge pas: warning dans la console + utilisation de la couleur de fallback
- Si une frame d'animation manque: warning + utilisation des frames disponibles
- L'animation continue même si certaines frames sont manquantes

### Optimisation et Performance

**Cache des sprites:**
- Les sprites sont chargés **une seule fois** au démarrage
- Réutilisés à chaque frame de rendu
- Pas de rechargement pendant le jeu

**Recommandations de performance:**

✅ **Bon pour les performances:**
- Sprites de 64x64 ou 32x32 pixels
- 3-6 frames par animation
- Format PNG optimisé
- Toutes les frames dans le même fichier tileset

❌ **Mauvais pour les performances:**
- Sprites de 256x256+ pixels
- 20+ frames par animation
- Formats non compressés (BMP, TGA)
- Chargement dynamique pendant le jeu

**Limites recommandées:**
- **Nombre de tilesets:** 1-3 par map
- **Sprites par tileset:** 10-50 types de tuiles
- **Animations par map:** Pas de limite pratique (géré par le moteur)
- **Taille totale des sprites:** < 50 MB pour une map

## Creating Sprites

### Static Tiles

For static (non-animated) tiles, create a single PNG image:
- Recommended size: 64x64 pixels (will be scaled to fit tiles)
- Format: PNG with transparency
- Shape: Diamond-shaped isometric tiles work best

Example in tileset definition:
```lua
g = {
  name = "Grass",
  sprite = "assets/tiles/grass.png",
  color = {0.2, 0.8, 0.3, 1},  -- Fallback color
}
```

### Animated Tiles

For animated tiles, create multiple frames:
- Each frame should be a separate PNG file
- All frames should have the same dimensions
- Recommended size: 64x64 pixels

Example in tileset definition:
```lua
w = {
  name = "Water",
  animated = true,
  frameCount = 4,
  frameDuration = 0.3,  -- Seconds per frame
  animationFrames = {
    "assets/tiles/water_frame1.png",
    "assets/tiles/water_frame2.png",
    "assets/tiles/water_frame3.png",
    "assets/tiles/water_frame4.png",
  },
  color = {0.2, 0.4, 0.9, 1},  -- Fallback color
}
```

## Generating Example Sprites

A Python script is provided to generate simple example sprites:

```bash
# Install pillow (optional)
pip install pillow

# Generate sprites
python3 generate_sprites.py
```

This will create basic example sprites in `assets/tiles/`.

## Fallback Rendering

If sprite files are not found, the library will automatically fall back to rendering with solid colors. This means:
- You can develop without sprites and add them later
- Missing sprites won't cause errors, just simpler visuals
- The `color` property in tile definitions serves as the fallback

## Sprite Guidelines

### Best Practices
- Use PNG format with transparency
- Keep file sizes reasonable (< 100KB per frame)
- Use consistent dimensions across all tiles
- For animations, aim for 3-8 frames for smooth motion
- Frame duration of 0.1-0.5 seconds works well for most animations

### Animation Types
- **Water**: 3-4 frames, 0.3s duration (gentle waves)
- **Fire**: 4-6 frames, 0.1-0.15s duration (flickering)
- **Portal/Magic**: 6-8 frames, 0.15s duration (swirling)
- **Lava**: 3-4 frames, 0.4-0.5s duration (slow bubbling)

## Tools for Creating Sprites

### Free Tools
- **Aseprite** (paid, but excellent for pixel art and animations)
- **GIMP** (free, good for creating static tiles)
- **Piskel** (free online pixel art tool)
- **Krita** (free, good for digital painting)

### Tips
1. Start with simple shapes and colors
2. Add details gradually
3. Test in-game frequently to see how they look at actual scale
4. For animations, keep the motion subtle and smooth
5. Consider using existing isometric tile sets as reference
