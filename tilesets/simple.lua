-- Simple Tileset Example
-- Minimal tileset definition for quick start

return {
  name = "Simple Tileset",

  metadata = {
    author = "iso3d",
    version = "1.0"
  },

  tiles = {
    g = {
      name = "Grass",
      color = {0.2, 0.8, 0.3, 1},
      walkable = true,
    },

    w = {
      name = "Water",
      color = {0.2, 0.4, 0.9, 0.8},
      walkable = false,
      animated = true,
      frameCount = 4,
      frameDuration = 0.3,
    },

    s = {
      name = "Stone",
      color = {0.5, 0.5, 0.5, 1},
      walkable = true,
    },

    d = {
      name = "Dirt",
      color = {0.6, 0.4, 0.2, 1},
      walkable = true,
    },

    -- 3D Block types (with height in tile units)
    b = {
      name = "Block",
      description = "3D block (half cube)",
      color = {0.7, 0.7, 0.7, 1},
      height = 0.5,
      walkable = false,
    },

    B = {
      name = "Cube",
      description = "3D cube (1x cube)",
      color = {0.6, 0.6, 0.6, 1},
      height = 1,
      walkable = false,
    },

    W = {
      name = "Wall",
      description = "Wall block (1.5x cube)",
      color = {0.5, 0.5, 0.5, 1},
      height = 1.5,
      walkable = false,
    },

    T = {
      name = "Tower",
      description = "Tower block (2x cube)",
      color = {0.4, 0.4, 0.4, 1},
      height = 2,
      walkable = false,
    }
  }
}
