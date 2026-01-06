# Assets Directory

This directory contains sprite images and other assets for the iso3d library.

## Directory Structure

```
assets/
└── tiles/          # Tile sprite images
    ├── water_frame1.png
    ├── water_frame2.png
    ├── ...
    └── grass.png
```

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
