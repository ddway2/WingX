-- iso3d.tileset - Tileset definition and management module
-- Handles tile type definitions, assets, and display parameters

local tileset = {}

-- TileDefinition structure
tileset.TileDefinition = {}
tileset.TileDefinition.__index = tileset.TileDefinition

function tileset.TileDefinition.new(id, def)
  local td = setmetatable({}, tileset.TileDefinition)
  td.id = id
  td.name = def.name or id
  td.description = def.description or ""

  -- Asset information
  td.sprite = def.sprite or nil  -- Path to sprite/texture
  td.spriteVariants = def.spriteVariants or {}  -- Multiple sprite variants
  td.color = def.color or {1, 1, 1, 1}  -- Default color (RGBA)

  -- Display parameters
  td.heightOffset = def.heightOffset or 0  -- Additional height offset for rendering
  td.scale = def.scale or 1.0  -- Scale multiplier
  td.opacity = def.opacity or 1.0  -- Opacity (0-1)
  td.glow = def.glow or false  -- Glow effect

  -- Animation parameters
  td.animated = def.animated or false
  td.frameCount = def.frameCount or 1
  td.frameDuration = def.frameDuration or 0.1

  -- Gameplay/logic parameters
  td.walkable = def.walkable ~= false  -- Default: walkable
  td.transparent = def.transparent or false  -- For rendering order
  td.tags = def.tags or {}  -- Custom tags for gameplay logic

  -- Custom parameters
  td.custom = def.custom or {}

  return td
end

-- Tileset structure
tileset.Tileset = {}
tileset.Tileset.__index = tileset.Tileset

function tileset.Tileset.new(name)
  local ts = setmetatable({}, tileset.Tileset)
  ts.name = name or "Unnamed Tileset"
  ts.definitions = {}
  ts.metadata = {}
  return ts
end

-- Add a tile definition to the tileset
function tileset.Tileset:addDefinition(id, definition)
  self.definitions[id] = tileset.TileDefinition.new(id, definition)
end

-- Get a tile definition by ID
function tileset.Tileset:getDefinition(id)
  return self.definitions[id]
end

-- Check if a tile type exists
function tileset.Tileset:hasDefinition(id)
  return self.definitions[id] ~= nil
end

-- Iterate over all definitions
function tileset.Tileset:each(callback)
  for id, def in pairs(self.definitions) do
    callback(id, def)
  end
end

-- Load tileset from a Lua file
-- The file should return a table with tile definitions
function tileset.loadFromFile(filename)
  local chunk, err = love.filesystem.load(filename)
  if not chunk then
    error("Failed to load tileset file: " .. filename .. "\n" .. (err or ""))
  end

  local data = chunk()
  if type(data) ~= "table" then
    error("Tileset file must return a table: " .. filename)
  end

  local ts = tileset.Tileset.new(data.name or filename)

  -- Load metadata
  if data.metadata then
    ts.metadata = data.metadata
  end

  -- Load tile definitions
  if data.tiles then
    for id, def in pairs(data.tiles) do
      ts:addDefinition(id, def)
    end
  end

  return ts
end

-- Load tileset from a table
function tileset.loadFromTable(data)
  local ts = tileset.Tileset.new(data.name or "Unnamed")

  if data.metadata then
    ts.metadata = data.metadata
  end

  if data.tiles then
    for id, def in pairs(data.tiles) do
      ts:addDefinition(id, def)
    end
  end

  return ts
end

-- Export tileset to Lua code
function tileset.Tileset:toLua()
  local lines = {
    "-- Tileset: " .. self.name,
    "return {",
    "  name = \"" .. self.name .. "\",",
    "",
    "  metadata = {",
  }

  for k, v in pairs(self.metadata) do
    table.insert(lines, "    " .. k .. " = " .. tostring(v) .. ",")
  end

  table.insert(lines, "  },")
  table.insert(lines, "")
  table.insert(lines, "  tiles = {")

  for id, def in pairs(self.definitions) do
    table.insert(lines, "    [\"" .. id .. "\"] = {")
    table.insert(lines, "      name = \"" .. def.name .. "\",")
    if def.description ~= "" then
      table.insert(lines, "      description = \"" .. def.description .. "\",")
    end
    table.insert(lines, "    },")
  end

  table.insert(lines, "  }")
  table.insert(lines, "}")

  return table.concat(lines, "\n")
end

-- Create a default tileset with basic tile types
function tileset.createDefault()
  return tileset.loadFromTable({
    name = "Default Tileset",
    metadata = {
      author = "iso3d",
      version = "1.0"
    },
    tiles = {
      g = {
        name = "Grass",
        description = "Grassy terrain",
        color = {0.2, 0.8, 0.3, 1},
        walkable = true,
      },
      w = {
        name = "Water",
        description = "Water tile",
        color = {0.2, 0.4, 0.9, 1},
        walkable = false,
        animated = true,
        frameCount = 4,
        frameDuration = 0.3,
      },
      s = {
        name = "Stone",
        description = "Stone tile",
        color = {0.5, 0.5, 0.5, 1},
        walkable = true,
      },
      d = {
        name = "Dirt",
        description = "Dirt terrain",
        color = {0.6, 0.4, 0.2, 1},
        walkable = true,
      }
    }
  })
end

return tileset
