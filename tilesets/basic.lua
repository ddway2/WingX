-- Basic Tileset for iso3d
-- Defines common terrain tile types with visual properties

return {
  name = "Basic Terrain",

  metadata = {
    author = "WingX",
    version = "1.0",
    description = "Basic terrain tiles for isometric rendering"
  },

  tiles = {
    -- Grass tile
    g = {
      name = "Grass",
      description = "Green grassy terrain",

      -- Visual properties
      color = {0.2, 0.8, 0.3, 1},  -- Green
      sprite = "assets/tiles/grass.png",  -- Optional sprite path
      spriteVariants = {  -- Multiple variants for variety
        "assets/tiles/grass_1.png",
        "assets/tiles/grass_2.png",
        "assets/tiles/grass_3.png",
      },

      -- Display parameters
      heightOffset = 0,  -- No additional height
      scale = 1.0,
      opacity = 1.0,
      glow = false,

      -- Gameplay properties
      walkable = true,
      transparent = false,
      tags = {"terrain", "natural"},

      -- Custom parameters
      custom = {
        fertility = 0.8,
        biome = "plains"
      }
    },

    -- Water tile
    w = {
      name = "Water",
      description = "Blue water surface with animation",

      -- Visual properties
      color = {0.2, 0.4, 0.9, 0.8},  -- Blue with transparency
      sprite = "assets/tiles/water.png",

      -- Display parameters
      heightOffset = -5,  -- Slightly lower than terrain
      scale = 1.0,
      opacity = 0.8,
      glow = true,  -- Water reflection effect

      -- Animation
      animated = true,
      frameCount = 4,
      frameDuration = 0.3,  -- 0.3 seconds per frame

      -- Gameplay properties
      walkable = false,  -- Cannot walk on water
      transparent = true,  -- For rendering order
      tags = {"water", "liquid"},

      custom = {
        depth = 2,
        flow = "still"
      }
    },

    -- Stone tile
    s = {
      name = "Stone",
      description = "Gray stone tile",

      color = {0.5, 0.5, 0.5, 1},  -- Gray
      sprite = "assets/tiles/stone.png",
      spriteVariants = {
        "assets/tiles/stone_1.png",
        "assets/tiles/stone_2.png",
      },

      heightOffset = 0,
      scale = 1.0,
      opacity = 1.0,
      glow = false,

      walkable = true,
      transparent = false,
      tags = {"terrain", "hard"},

      custom = {
        durability = 1.0,
        mineral = "granite"
      }
    },

    -- Dirt tile
    d = {
      name = "Dirt",
      description = "Brown dirt terrain",

      color = {0.6, 0.4, 0.2, 1},  -- Brown
      sprite = "assets/tiles/dirt.png",

      heightOffset = 0,
      scale = 1.0,
      opacity = 1.0,
      glow = false,

      walkable = true,
      transparent = false,
      tags = {"terrain", "soft"},

      custom = {
        fertility = 0.5,
        moisture = 0.3
      }
    },

    -- Sand tile
    n = {
      name = "Sand",
      description = "Yellow sand tile",

      color = {0.9, 0.8, 0.5, 1},  -- Sandy yellow
      sprite = "assets/tiles/sand.png",

      heightOffset = 0,
      scale = 1.0,
      opacity = 1.0,
      glow = false,

      walkable = true,
      transparent = false,
      tags = {"terrain", "desert"},

      custom = {
        biome = "desert",
        temperature = 35
      }
    },

    -- Forest tile
    f = {
      name = "Forest",
      description = "Dense forest tile",

      color = {0.1, 0.5, 0.2, 1},  -- Dark green
      sprite = "assets/tiles/forest.png",

      heightOffset = 10,  -- Trees are taller
      scale = 1.2,
      opacity = 1.0,
      glow = false,

      walkable = true,
      transparent = false,
      tags = {"terrain", "natural", "vegetation"},

      custom = {
        density = 0.9,
        wood_quality = "oak"
      }
    },

    -- Mountain tile
    m = {
      name = "Mountain",
      description = "Rocky mountain tile",

      color = {0.4, 0.4, 0.4, 1},  -- Dark gray
      sprite = "assets/tiles/mountain.png",

      heightOffset = 20,  -- Very tall
      scale = 1.5,
      opacity = 1.0,
      glow = false,

      walkable = false,  -- Cannot walk on mountains
      transparent = false,
      tags = {"terrain", "obstacle", "high"},

      custom = {
        altitude = 3000,
        climbable = false
      }
    },

    -- Road tile
    r = {
      name = "Road",
      description = "Paved road tile",

      color = {0.3, 0.3, 0.3, 1},  -- Dark gray
      sprite = "assets/tiles/road.png",

      heightOffset = 0,
      scale = 1.0,
      opacity = 1.0,
      glow = false,

      walkable = true,
      transparent = false,
      tags = {"structure", "path"},

      custom = {
        speed_bonus = 1.5,
        condition = "good"
      }
    }
  }
}
