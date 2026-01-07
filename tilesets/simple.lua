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
    }
  }
}
