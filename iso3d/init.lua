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

return iso3d
