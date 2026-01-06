-- iso3d - Isometric 3D library for Love2D
-- Version: 0.3.0

local iso3d = {
  _VERSION = '0.3.0',
  _DESCRIPTION = 'Isometric 3D rendering library for Love2D',
  _LICENSE = 'MIT'
}

-- Load submodules
local modulePath = (...):gsub('%.init$', '')
iso3d.map = require(modulePath .. '.map')
iso3d.tileset = require(modulePath .. '.tileset')

-- Module private variables
local private = {}

-- Module configuration
iso3d.config = {
  tileWidth = 64,
  tileHeight = 32,
  debug = false
}

-- Initialize the library
function iso3d.init(config)
  if config then
    for k, v in pairs(config) do
      if iso3d.config[k] ~= nil then
        iso3d.config[k] = v
      end
    end
  end

  if iso3d.config.debug then
    print('[iso3d] Library initialized')
    print('[iso3d] Version: ' .. iso3d._VERSION)
  end

  return iso3d
end

-- Get library version
function iso3d.getVersion()
  return iso3d._VERSION
end

-- Module placeholder functions (to be implemented)

-- Convert 3D coordinates to 2D screen coordinates
function iso3d.toScreen(x, y, z)
  -- Placeholder: basic isometric projection
  local screenX = (x - y) * (iso3d.config.tileWidth / 2)
  local screenY = (x + y) * (iso3d.config.tileHeight / 2) - z
  return screenX, screenY
end

-- Convert 2D screen coordinates to 3D coordinates (inverse projection)
function iso3d.toWorld(screenX, screenY, z)
  z = z or 0
  -- Placeholder: basic inverse isometric projection
  local tw = iso3d.config.tileWidth / 2
  local th = iso3d.config.tileHeight / 2

  local y = (screenX / tw + (screenY + z) / th) / 2
  local x = y + screenX / tw

  return x, y, z
end

-- Draw a point in isometric space
function iso3d.drawPoint(x, y, z, color)
  local screenX, screenY = iso3d.toScreen(x, y, z)

  if color then
    love.graphics.setColor(color)
  end

  love.graphics.circle('fill', screenX, screenY, 3)
end

-- Draw a line in isometric space
function iso3d.drawLine(x1, y1, z1, x2, y2, z2, color)
  local screenX1, screenY1 = iso3d.toScreen(x1, y1, z1)
  local screenX2, screenY2 = iso3d.toScreen(x2, y2, z2)

  if color then
    love.graphics.setColor(color)
  end

  love.graphics.line(screenX1, screenY1, screenX2, screenY2)
end

-- Debug function to display library info
function iso3d.debug()
  print('=== iso3d Debug Info ===')
  print('Version: ' .. iso3d._VERSION)
  print('Tile Width: ' .. iso3d.config.tileWidth)
  print('Tile Height: ' .. iso3d.config.tileHeight)
  print('Debug Mode: ' .. tostring(iso3d.config.debug))
  print('========================')
end

-- Draw an isometric tile (diamond shape)
function iso3d.drawTileDiamond(x, y, z, color, opacity)
  local screenX, screenY = iso3d.toScreen(x, y, z)
  local tw = iso3d.config.tileWidth / 2
  local th = iso3d.config.tileHeight / 2

  -- Set color and opacity
  if color then
    local r, g, b, a = color[1], color[2], color[3], color[4] or 1
    if opacity then
      a = a * opacity
    end
    love.graphics.setColor(r, g, b, a)
  else
    love.graphics.setColor(1, 1, 1, opacity or 1)
  end

  -- Draw diamond (isometric tile top face)
  local vertices = {
    screenX, screenY - th,        -- Top
    screenX + tw, screenY,        -- Right
    screenX, screenY + th,        -- Bottom
    screenX - tw, screenY         -- Left
  }

  love.graphics.polygon('fill', vertices)

  -- Draw outline
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.polygon('line', vertices)
end

-- Draw a 3D tile block (with height)
function iso3d.drawTileBlock(x, y, z, height, color, opacity)
  local screenX, screenY = iso3d.toScreen(x, y, z)
  local tw = iso3d.config.tileWidth / 2
  local th = iso3d.config.tileHeight / 2
  local blockHeight = height or th

  -- Set base color
  local r, g, b, a = 1, 1, 1, 1
  if color then
    r, g, b = color[1], color[2], color[3]
    a = color[4] or 1
  end
  if opacity then
    a = a * opacity
  end

  -- Draw left face (darker)
  love.graphics.setColor(r * 0.7, g * 0.7, b * 0.7, a)
  local leftFace = {
    screenX - tw, screenY,              -- Top left
    screenX, screenY + th,              -- Bottom
    screenX, screenY + th + blockHeight, -- Bottom with height
    screenX - tw, screenY + blockHeight  -- Top left with height
  }
  love.graphics.polygon('fill', leftFace)

  -- Draw right face (medium)
  love.graphics.setColor(r * 0.85, g * 0.85, b * 0.85, a)
  local rightFace = {
    screenX + tw, screenY,              -- Top right
    screenX, screenY + th,              -- Bottom
    screenX, screenY + th + blockHeight, -- Bottom with height
    screenX + tw, screenY + blockHeight  -- Top right with height
  }
  love.graphics.polygon('fill', rightFace)

  -- Draw top face (lightest)
  love.graphics.setColor(r, g, b, a)
  local topFace = {
    screenX, screenY - th + blockHeight,        -- Top
    screenX + tw, screenY + blockHeight,        -- Right
    screenX, screenY + th + blockHeight,        -- Bottom
    screenX - tw, screenY + blockHeight         -- Left
  }
  love.graphics.polygon('fill', topFace)

  -- Draw outlines
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.polygon('line', leftFace)
  love.graphics.polygon('line', rightFace)
  love.graphics.polygon('line', topFace)
end

-- Draw a single tile with tileset properties
function iso3d.drawTile(tile, x, y, tileset, renderMode)
  if not tile then return end

  renderMode = renderMode or 'block'  -- 'block' or 'flat'

  -- Get tile definition from tileset
  local tileDef = nil
  if tileset then
    tileDef = tileset:getDefinition(tile.type)
  end

  -- Get display properties
  local color = tileDef and tileDef.color or {0.8, 0.8, 0.8, 1}
  local heightOffset = tileDef and tileDef.heightOffset or 0
  local opacity = tileDef and tileDef.opacity or 1.0
  local scale = tileDef and tileDef.scale or 1.0

  -- Calculate Z position
  local z = (tile.height or 0) * 10 + heightOffset

  -- Render based on mode
  if renderMode == 'flat' then
    iso3d.drawTileDiamond(x, y, z, color, opacity)
  else
    -- Block rendering with height
    local blockHeight = (tile.height or 0) * 10
    if blockHeight ~= 0 then
      -- For negative heights, draw block below ground level
      iso3d.drawTileBlock(x, y, 0, blockHeight, color, opacity)
    else
      -- Height 0: draw flat diamond
      iso3d.drawTileDiamond(x, y, z, color, opacity)
    end
  end

  -- Draw debug info if enabled
  if iso3d.config.debug then
    local screenX, screenY = iso3d.toScreen(x, y, z)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("%s:%d", tile.type, tile.height), screenX - 10, screenY - 5)
  end
end

-- Draw a complete map
function iso3d.drawMap(gameMap, renderMode, offset)
  if not gameMap then return end

  renderMode = renderMode or 'block'
  offset = offset or {x = 0, y = 0}

  love.graphics.push()
  love.graphics.translate(offset.x, offset.y)

  -- Draw tiles back to front for proper depth sorting
  for y = gameMap.height, 1, -1 do
    for x = 1, gameMap.width do
      local tile = gameMap:getTile(x, y)
      if tile then
        iso3d.drawTile(tile, x, y, gameMap:getTileset(), renderMode)
      end
    end
  end

  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)  -- Reset color
end

return iso3d
