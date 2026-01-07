-- iso3d - Isometric 3D library for Love2D
-- Version: 0.4.0

local iso3d = {
  _VERSION = '0.4.0',
  _DESCRIPTION = 'Isometric rendering library for Love2D',
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

-- Convert 2D grid coordinates to 2D screen coordinates
function iso3d.toScreen(x, y)
  local screenX = (x - y) * (iso3d.config.tileWidth / 2)
  local screenY = (x + y) * (iso3d.config.tileHeight / 2)
  return screenX, screenY
end

-- Convert 2D screen coordinates to 2D grid coordinates (inverse projection)
function iso3d.toWorld(screenX, screenY)
  local tw = iso3d.config.tileWidth / 2
  local th = iso3d.config.tileHeight / 2

  local y = (screenX / tw + screenY / th) / 2
  local x = y + screenX / tw

  return x, y
end

-- Draw a point in isometric space
function iso3d.drawPoint(x, y, color)
  local screenX, screenY = iso3d.toScreen(x, y)

  if color then
    love.graphics.setColor(color)
  end

  love.graphics.circle('fill', screenX, screenY, 3)
end

-- Draw a line in isometric space
function iso3d.drawLine(x1, y1, x2, y2, color)
  local screenX1, screenY1 = iso3d.toScreen(x1, y1)
  local screenX2, screenY2 = iso3d.toScreen(x2, y2)

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
function iso3d.drawTileDiamond(x, y, color, opacity)
  local screenX, screenY = iso3d.toScreen(x, y)
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

-- Draw a sprite on an isometric tile
function iso3d.drawTileSprite(x, y, sprite, opacity, scale)
  if not sprite then return end

  local screenX, screenY = iso3d.toScreen(x, y)
  local tw = iso3d.config.tileWidth
  local th = iso3d.config.tileHeight

  opacity = opacity or 1.0
  scale = scale or 1.0

  love.graphics.setColor(1, 1, 1, opacity)

  -- Calculate sprite dimensions to fit the tile
  local spriteWidth = sprite:getWidth()
  local spriteHeight = sprite:getHeight()

  -- Scale the sprite to fit the tile width
  local spriteScale = (tw / spriteWidth) * scale

  -- Draw sprite centered on the tile
  love.graphics.draw(
    sprite,
    screenX, screenY - (spriteHeight * spriteScale / 2) + th/2,
    0,  -- rotation
    spriteScale, spriteScale,
    spriteWidth / 2, spriteHeight / 2  -- origin
  )
end

-- Draw a single tile with tileset properties
function iso3d.drawTile(tile, x, y, tileset)
  if not tile then return end

  -- Get tile definition from tileset
  local tileDef = nil
  if tileset then
    tileDef = tileset:getDefinition(tile.type)
  end

  -- Get display properties
  local color = tileDef and tileDef.color or {0.8, 0.8, 0.8, 1}
  local opacity = tileDef and tileDef.opacity or 1.0
  local scale = tileDef and tileDef.scale or 1.0

  -- Check if we have a sprite to render
  local sprite = tileDef and tileDef:getCurrentSprite()

  if sprite then
    -- Render with sprite
    iso3d.drawTileSprite(x, y, sprite, opacity, scale)
  else
    -- Render with color (fallback when no sprite)
    iso3d.drawTileDiamond(x, y, color, opacity)
  end

  -- Draw debug info if enabled
  if iso3d.config.debug then
    local screenX, screenY = iso3d.toScreen(x, y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tile.type, screenX - 10, screenY - 5)
  end
end

-- Draw a complete map
function iso3d.drawMap(gameMap, offset)
  if not gameMap then return end

  offset = offset or {x = 0, y = 0}

  love.graphics.push()
  love.graphics.translate(offset.x, offset.y)

  -- Draw tiles back to front for proper depth sorting
  for y = gameMap.height, 1, -1 do
    for x = 1, gameMap.width do
      local tile = gameMap:getTile(x, y)
      if tile then
        iso3d.drawTile(tile, x, y, gameMap:getTileset())
      end
    end
  end

  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)  -- Reset color
end

return iso3d
