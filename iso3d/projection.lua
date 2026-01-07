-- iso3d.projection - Coordinate projection functions
-- Handles conversion between grid coordinates and screen coordinates

local projection = {}

-- Reference to parent config (will be set by init.lua)
projection.config = nil

-- Convert 2D grid coordinates to 2D screen coordinates
function projection.toScreen(x, y)
  local tw = projection.config.tileWidth / 2
  local th = projection.config.tileHeight / 2

  local screenX = (x - y) * tw
  local screenY = (x + y) * th

  return screenX, screenY
end

-- Convert 2D screen coordinates to 2D grid coordinates (inverse projection)
function projection.toWorld(screenX, screenY)
  local tw = projection.config.tileWidth / 2
  local th = projection.config.tileHeight / 2

  local y = (screenX / tw + screenY / th) / 2
  local x = y + screenX / tw

  return x, y
end

return projection
