-- iso3d.map - Map management module for iso3d
-- Handles loading, parsing and managing tile maps

local map = {}

-- Map structure
map.Map = {}
map.Map.__index = map.Map

-- Create a new map
function map.Map.new(width, height, tileset)
  local m = setmetatable({}, map.Map)
  m.width = width or 0
  m.height = height or 0
  m.tiles = {}
  m.metadata = {}
  m.tileset = tileset or nil  -- Optional tileset reference
  return m
end

-- Set the tileset for this map
function map.Map:setTileset(tileset)
  self.tileset = tileset
end

-- Get the tileset for this map
function map.Map:getTileset()
  return self.tileset
end

-- Get the tile definition from the tileset for a tile
function map.Map:getTileDefinition(tile)
  if self.tileset and tile then
    return self.tileset:getDefinition(tile.type)
  end
  return nil
end

-- Set a tile at position (x, y)
function map.Map:setTile(x, y, tile)
  if not self.tiles[y] then
    self.tiles[y] = {}
  end
  self.tiles[y][x] = tile
end

-- Get a tile at position (x, y)
function map.Map:getTile(x, y)
  if self.tiles[y] then
    return self.tiles[y][x]
  end
  return nil
end

-- Iterate over all tiles
function map.Map:each(callback)
  for y = 1, self.height do
    for x = 1, self.width do
      local tile = self:getTile(x, y)
      if tile then
        callback(x, y, tile)
      end
    end
  end
end

-- Tile structure
map.Tile = {}
map.Tile.__index = map.Tile

function map.Tile.new(type, height, params)
  local t = setmetatable({}, map.Tile)
  t.type = type or 'g'  -- Default: grass
  t.height = height or 0  -- Default: flat tile (0 = flat, 1 = cube, 2 = 2x cube height)
  t.params = params or {}
  return t
end

-- Parse a tile string format: "type:height:param1=value1,param2=value2"
-- Examples: "g:0" (flat grass), "B:1" (cube block), "T:2" (tower 2x cube height)
function map.parseTileString(str)
  str = str:match("^%s*(.-)%s*$")  -- Trim whitespace

  if str == "" or str == "." then
    return nil  -- Empty tile
  end

  local parts = {}
  for part in str:gmatch("[^:]+") do
    table.insert(parts, part)
  end

  local tileType = parts[1] or 'g'
  local height = tonumber(parts[2]) or 0
  local params = {}

  -- Parse optional parameters (format: key=value,key2=value2)
  if parts[3] then
    for param in parts[3]:gmatch("[^,]+") do
      local key, value = param:match("([^=]+)=([^=]+)")
      if key and value then
        params[key:match("^%s*(.-)%s*$")] = value:match("^%s*(.-)%s*$")
      end
    end
  end

  -- Validate height (must be >= 0, typically 0, 0.5, 1, 1.5, 2)
  height = math.max(0, height)

  return map.Tile.new(tileType, height, params)
end

-- Load a map from a string
-- Format: Each line is a row, tiles separated by spaces
-- Example:
--   g:0 B:1 B:1       (grass, cube, cube)
--   g:0 g:0 T:2       (grass, grass, tower 2x height)
function map.loadFromString(str)
  local lines = {}
  for line in str:gmatch("[^\r\n]+") do
    -- Skip comment lines starting with # or --
    if not line:match("^%s*#") and not line:match("^%s*%-%-") then
      table.insert(lines, line)
    end
  end

  if #lines == 0 then
    return map.Map.new(0, 0)
  end

  local height = #lines
  local width = 0

  -- First pass: determine width
  for _, line in ipairs(lines) do
    local count = 0
    for _ in line:gmatch("[^%s]+") do
      count = count + 1
    end
    width = math.max(width, count)
  end

  local newMap = map.Map.new(width, height)

  -- Second pass: parse tiles
  for y, line in ipairs(lines) do
    local x = 1
    for tileStr in line:gmatch("[^%s]+") do
      local tile = map.parseTileString(tileStr)
      if tile then
        newMap:setTile(x, y, tile)
      end
      x = x + 1
    end
  end

  return newMap
end

-- Load a map from a file
function map.loadFromFile(filename)
  local content = love.filesystem.read(filename)
  if not content then
    error("Failed to load map file: " .. filename)
  end
  return map.loadFromString(content)
end

-- Export map to string format
function map.Map:toString()
  local lines = {}
  for y = 1, self.height do
    local tiles = {}
    for x = 1, self.width do
      local tile = self:getTile(x, y)
      if tile then
        local str = tile.type .. ":" .. tile.height
        if next(tile.params) then
          local params = {}
          for k, v in pairs(tile.params) do
            table.insert(params, k .. "=" .. v)
          end
          str = str .. ":" .. table.concat(params, ",")
        end
        table.insert(tiles, str)
      else
        table.insert(tiles, ".")
      end
    end
    table.insert(lines, table.concat(tiles, " "))
  end
  return table.concat(lines, "\n")
end

return map
