#!/usr/bin/env python3
"""
Generate sample sprite images for WingX iso3d library animations
Creates simple colored tiles with variations for animation
"""

import os

try:
    from PIL import Image, ImageDraw
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("PIL (Pillow) not available. Installing is optional - sprites will use fallback colors.")
    print("To install: pip install pillow")

def create_diamond_sprite(width, height, color, brightness=1.0):
    """Create a simple diamond-shaped isometric tile sprite"""
    if not PIL_AVAILABLE:
        return None

    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Adjust color brightness
    adjusted_color = tuple(int(c * brightness) for c in color[:3]) + (color[3],)

    # Diamond shape (isometric tile)
    cx, cy = width // 2, height // 2
    points = [
        (cx, cy - height // 4),      # Top
        (cx + width // 2, cy),        # Right
        (cx, cy + height // 4),       # Bottom
        (cx - width // 2, cy)         # Left
    ]

    draw.polygon(points, fill=adjusted_color, outline=(0, 0, 0, 200))

    return img

def create_water_frames(output_dir, size=(64, 32)):
    """Create water animation frames with wave effect"""
    if not PIL_AVAILABLE:
        return

    base_color = (50, 100, 230, 255)

    for i in range(4):
        brightness = 0.8 + (i / 8)  # Vary brightness for wave effect
        img = create_diamond_sprite(size[0], size[1], base_color, brightness)

        # Add some wave pattern variation
        draw = ImageDraw.Draw(img)
        offset = i * 2
        draw.line([(10 + offset, size[1]//2), (size[0]-10+offset, size[1]//2)],
                  fill=(70, 120, 250, 100), width=2)

        img.save(os.path.join(output_dir, f'water_frame{i+1}.png'))

    print(f"Created 4 water animation frames")

def create_lava_frames(output_dir, size=(64, 32)):
    """Create lava animation frames with glow effect"""
    if not PIL_AVAILABLE:
        return

    colors = [
        (255, 80, 20, 255),   # Bright orange
        (255, 100, 30, 255),  # Orange-yellow
        (255, 60, 10, 255),   # Deep orange
    ]

    for i, color in enumerate(colors):
        img = create_diamond_sprite(size[0], size[1], color, 1.0)

        # Add glow effect
        draw = ImageDraw.Draw(img)
        cx, cy = size[0] // 2, size[1] // 2
        draw.ellipse([cx-8, cy-4, cx+8, cy+4], fill=(255, 200, 0, 150))

        img.save(os.path.join(output_dir, f'lava_frame{i+1}.png'))

    print(f"Created 3 lava animation frames")

def create_portal_frames(output_dir, size=(64, 32)):
    """Create portal animation frames with swirl effect"""
    if not PIL_AVAILABLE:
        return

    base_color = (180, 50, 230, 230)

    for i in range(6):
        brightness = 0.7 + (i / 10)
        img = create_diamond_sprite(size[0], size[1], base_color, brightness)

        # Add swirl pattern
        draw = ImageDraw.Draw(img)
        cx, cy = size[0] // 2, size[1] // 2
        angle_offset = i * 60

        # Draw some rotating circles for swirl effect
        for j in range(3):
            angle = angle_offset + j * 120
            import math
            x = cx + int(math.cos(math.radians(angle)) * 15)
            y = cy + int(math.sin(math.radians(angle)) * 8)
            draw.ellipse([x-3, y-2, x+3, y+2], fill=(220, 100, 255, 200))

        img.save(os.path.join(output_dir, f'portal_frame{i+1}.png'))

    print(f"Created 6 portal animation frames")

def create_fire_frames(output_dir, size=(64, 32)):
    """Create fire animation frames with flicker effect"""
    if not PIL_AVAILABLE:
        return

    colors = [
        (255, 150, 20, 255),  # Orange
        (255, 180, 30, 255),  # Yellow-orange
        (255, 140, 10, 255),  # Deep orange
        (255, 160, 25, 255),  # Mid orange
    ]

    for i, color in enumerate(colors):
        # Create a smaller, more vertical flame shape
        img = Image.new('RGBA', (size[0], size[1] + 10), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        cx, cy = size[0] // 2, size[1] // 2 + 5

        # Draw flame shape with variation
        height_var = 5 - (i % 3) * 2
        points = [
            (cx, cy - 15 - height_var),      # Top (pointed)
            (cx + 10, cy - 5),                # Right
            (cx + 8, cy + 5),                 # Lower right
            (cx, cy + 8),                     # Bottom point
            (cx - 8, cy + 5),                 # Lower left
            (cx - 10, cy - 5),                # Left
        ]

        draw.polygon(points, fill=color, outline=(0, 0, 0, 0))

        # Add bright center
        draw.ellipse([cx-4, cy-2, cx+4, cy+2], fill=(255, 255, 150, 200))

        img.save(os.path.join(output_dir, f'fire_frame{i+1}.png'))

    print(f"Created 4 fire animation frames")

def create_static_tiles(output_dir, size=(64, 32)):
    """Create static tile sprites for non-animated tiles"""
    if not PIL_AVAILABLE:
        return

    tiles = {
        'grass': (50, 200, 80, 255),
        'stone': (130, 130, 130, 255),
        'dirt': (150, 100, 50, 255),
        'sand': (230, 200, 130, 255),
    }

    for name, color in tiles.items():
        img = create_diamond_sprite(size[0], size[1], color, 1.0)
        img.save(os.path.join(output_dir, f'{name}.png'))

    print(f"Created {len(tiles)} static tile sprites")

if __name__ == '__main__':
    if not PIL_AVAILABLE:
        print("\nSkipping sprite generation - PIL not available.")
        print("Sprites are optional. The library will use solid colors as fallback.")
        exit(0)

    # Create assets directory structure
    assets_dir = 'assets'
    tiles_dir = os.path.join(assets_dir, 'tiles')
    os.makedirs(tiles_dir, exist_ok=True)

    print("Generating sprite images...")
    print(f"Output directory: {tiles_dir}\n")

    # Generate animated tiles
    create_water_frames(tiles_dir)
    create_lava_frames(tiles_dir)
    create_portal_frames(tiles_dir)
    create_fire_frames(tiles_dir)

    # Generate static tiles
    create_static_tiles(tiles_dir)

    print(f"\nDone! Generated sprite images in {tiles_dir}")
    print("\nNote: These are simple example sprites for demonstration.")
    print("For production, replace with your own artwork.")
