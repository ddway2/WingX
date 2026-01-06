-- Animated Tileset Example
-- Demonstrates tile animations with sprite sequences

return {
  name = "Animated Tileset",

  metadata = {
    author = "WingX",
    version = "1.0",
    description = "Example tileset with animated tiles"
  },

  tiles = {
    -- Static grass tile
    g = {
      name = "Grass",
      description = "Grassy terrain",
      color = {0.2, 0.8, 0.3, 1},

      -- Optional: sprite path for static image
      -- sprite = "assets/tiles/grass.png",

      walkable = true,
      tags = {"terrain", "natural"}
    },

    -- Animated water tile (4 frames)
    w = {
      name = "Water",
      description = "Animated water tile",
      color = {0.2, 0.4, 0.9, 1},

      -- Animation parameters
      animated = true,
      frameCount = 4,
      frameDuration = 0.3,  -- 0.3 seconds per frame

      -- Animation frames (paths to sprite images)
      -- Each frame should be a separate image file
      animationFrames = {
        "assets/tiles/water_frame1.png",
        "assets/tiles/water_frame2.png",
        "assets/tiles/water_frame3.png",
        "assets/tiles/water_frame4.png",
      },

      walkable = false,
      transparent = false,
      tags = {"water", "animated"}
    },

    -- Stone tile
    s = {
      name = "Stone",
      description = "Stone block",
      color = {0.5, 0.5, 0.5, 1},

      walkable = true,
      tags = {"terrain", "solid"}
    },

    -- Dirt tile
    d = {
      name = "Dirt",
      description = "Dirt terrain",
      color = {0.6, 0.4, 0.2, 1},

      walkable = true,
      tags = {"terrain"}
    },

    -- Animated lava tile (slower animation)
    l = {
      name = "Lava",
      description = "Animated lava tile",
      color = {1.0, 0.3, 0.1, 1},

      animated = true,
      frameCount = 3,
      frameDuration = 0.5,  -- Slower animation

      animationFrames = {
        "assets/tiles/lava_frame1.png",
        "assets/tiles/lava_frame2.png",
        "assets/tiles/lava_frame3.png",
      },

      walkable = false,
      glow = true,
      tags = {"hazard", "animated"}
    },

    -- Sand tile
    n = {
      name = "Sand",
      description = "Sandy beach",
      color = {0.9, 0.8, 0.5, 1},

      walkable = true,
      tags = {"terrain", "beach"}
    },

    -- Animated portal/magic tile (fast animation)
    p = {
      name = "Portal",
      description = "Magical portal tile",
      color = {0.7, 0.2, 0.9, 1},

      animated = true,
      frameCount = 6,
      frameDuration = 0.15,  -- Fast animation

      animationFrames = {
        "assets/tiles/portal_frame1.png",
        "assets/tiles/portal_frame2.png",
        "assets/tiles/portal_frame3.png",
        "assets/tiles/portal_frame4.png",
        "assets/tiles/portal_frame5.png",
        "assets/tiles/portal_frame6.png",
      },

      walkable = true,
      glow = true,
      opacity = 0.9,
      tags = {"special", "animated", "magic"}
    },

    -- Animated torch/fire (used for decorations)
    f = {
      name = "Fire",
      description = "Animated fire",
      color = {1.0, 0.6, 0.1, 1},

      animated = true,
      frameCount = 4,
      frameDuration = 0.1,

      animationFrames = {
        "assets/tiles/fire_frame1.png",
        "assets/tiles/fire_frame2.png",
        "assets/tiles/fire_frame3.png",
        "assets/tiles/fire_frame4.png",
      },

      heightOffset = 5,  -- Slightly elevated
      glow = true,
      walkable = false,
      tags = {"decoration", "animated", "light"}
    }
  }
}
