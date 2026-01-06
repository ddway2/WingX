#!/usr/bin/env python3
"""
Generate large isometric maps for WingX iso3d library
"""

import random
import math

def generate_island_map(size=64):
    """Generate an island map with water surrounding land"""
    lines = []
    lines.append("# Island Map {}x{} - Island surrounded by water".format(size, size))
    lines.append("# Types: g=grass, w=water, s=stone, d=dirt, n=sand")
    lines.append("")

    center_x, center_y = size // 2, size // 2
    island_radius = size * 0.35

    for y in range(size):
        row = []
        for x in range(size):
            # Distance from center
            dist = math.sqrt((x - center_x)**2 + (y - center_y)**2)

            # Add some noise
            noise = random.random() * 3 - 1.5
            dist += noise

            if dist > island_radius + 8:
                # Deep water
                row.append('w:0')
            elif dist > island_radius + 3:
                # Shallow water with sand
                row.append('w:0' if random.random() > 0.3 else 'n:0')
            elif dist > island_radius:
                # Beach (sand)
                row.append('n:0')
            elif dist > island_radius - 5:
                # Grass near beach
                height = 0 if random.random() > 0.3 else 1
                row.append('g:{}'.format(height))
            elif dist > island_radius - 15:
                # Inner grass with hills
                height = random.randint(0, 2)
                row.append('g:{}'.format(height))
            elif dist > island_radius - 20:
                # Mountain foothills
                height = random.randint(1, 2)
                tile_type = 'g' if random.random() > 0.3 else 's'
                row.append('{}:{}'.format(tile_type, height))
            else:
                # Central mountain
                height = random.randint(2, 3)
                row.append('s:{}'.format(height))

        lines.append(' '.join(row))

    return '\n'.join(lines)

def generate_terrain_map(size=64):
    """Generate a varied terrain map with mountains, valleys, and rivers"""
    lines = []
    lines.append("# Terrain Map {}x{} - Varied natural landscape".format(size, size))
    lines.append("# Types: g=grass, w=water, s=stone, d=dirt")
    lines.append("")

    # Create height map using Perlin-like noise
    heightmap = [[0 for _ in range(size)] for _ in range(size)]

    # Add multiple layers of noise for terrain
    for scale in [8, 16, 32]:
        for y in range(size):
            for x in range(size):
                heightmap[y][x] += random.random() * scale

    # Normalize heights
    max_height = max(max(row) for row in heightmap)
    min_height = min(min(row) for row in heightmap)
    for y in range(size):
        for x in range(size):
            heightmap[y][x] = (heightmap[y][x] - min_height) / (max_height - min_height)

    # Add river
    river_path = set()
    rx, ry = 0, size // 3
    while rx < size:
        river_path.add((rx, ry))
        river_path.add((rx, ry + 1))
        if ry > 0:
            river_path.add((rx, ry - 1))
        rx += 1
        ry += random.randint(-1, 1)
        ry = max(0, min(size - 1, ry))

    for y in range(size):
        row = []
        for x in range(size):
            if (x, y) in river_path:
                row.append('w:0')
            else:
                h = heightmap[y][x]
                if h < 0.2:
                    row.append('g:0')
                elif h < 0.4:
                    row.append('g:1')
                elif h < 0.6:
                    row.append('g:2')
                elif h < 0.8:
                    row.append('s:2')
                else:
                    row.append('s:3')

        lines.append(' '.join(row))

    return '\n'.join(lines)

def generate_city_grid(size=64):
    """Generate a city-like grid with roads and buildings"""
    lines = []
    lines.append("# City Map {}x{} - Grid with roads and buildings".format(size, size))
    lines.append("# Types: g=grass, s=stone (buildings), d=dirt (roads)")
    lines.append("")

    block_size = 8
    road_width = 2

    for y in range(size):
        row = []
        for x in range(size):
            # Check if on a road
            on_horizontal_road = (y % block_size) < road_width
            on_vertical_road = (x % block_size) < road_width

            if on_horizontal_road or on_vertical_road:
                # Road
                row.append('d:0')
            else:
                # Building block
                # Add some variation in building heights
                block_x = x // block_size
                block_y = y // block_size
                seed = (block_x * 1000 + block_y) % 100

                if seed < 20:
                    # Park
                    height = 0 if random.random() > 0.2 else 1
                    row.append('g:{}'.format(height))
                else:
                    # Building
                    height = (seed % 3) + 1
                    row.append('s:{}'.format(height))

        lines.append(' '.join(row))

    return '\n'.join(lines)

def generate_checkerboard(size=64):
    """Generate a checkerboard pattern for testing"""
    lines = []
    lines.append("# Checkerboard Map {}x{} - Pattern for testing".format(size, size))
    lines.append("")

    for y in range(size):
        row = []
        for x in range(size):
            if (x + y) % 2 == 0:
                height = ((x // 8) + (y // 8)) % 4
                row.append('g:{}'.format(height))
            else:
                height = ((x // 8) + (y // 8)) % 4
                row.append('s:{}'.format(height))

        lines.append(' '.join(row))

    return '\n'.join(lines)

if __name__ == '__main__':
    import os

    # Create maps directory if it doesn't exist
    os.makedirs('maps', exist_ok=True)

    print("Generating island map...")
    with open('maps/island_64x64.map', 'w') as f:
        f.write(generate_island_map(64))
    print("  -> maps/island_64x64.map")

    print("Generating terrain map...")
    with open('maps/terrain_64x64.map', 'w') as f:
        f.write(generate_terrain_map(64))
    print("  -> maps/terrain_64x64.map")

    print("Generating city map...")
    with open('maps/city_64x64.map', 'w') as f:
        f.write(generate_city_grid(64))
    print("  -> maps/city_64x64.map")

    print("Generating checkerboard map...")
    with open('maps/checkerboard_64x64.map', 'w') as f:
        f.write(generate_checkerboard(64))
    print("  -> maps/checkerboard_64x64.map")

    # Also generate smaller versions for comparison
    print("\nGenerating 32x32 versions...")
    with open('maps/island_32x32.map', 'w') as f:
        f.write(generate_island_map(32))
    print("  -> maps/island_32x32.map")

    with open('maps/terrain_32x32.map', 'w') as f:
        f.write(generate_terrain_map(32))
    print("  -> maps/terrain_32x32.map")

    print("\nDone! Generated 6 map files.")
