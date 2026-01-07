-- iso3d.debug - Debug and utility functions
-- Handles debug visualization and information display

local debug = {}

-- References to other modules (will be set by init.lua)
debug.config = nil
debug.projection = nil

-- Draw a point in isometric space
function debug.drawPoint(x, y, color)
  local screenX, screenY = debug.projection.toScreen(x, y)

  if color then
    love.graphics.setColor(color)
  end

  love.graphics.circle('fill', screenX, screenY, 3)
end

-- Draw a line in isometric space
function debug.drawLine(x1, y1, x2, y2, color)
  local screenX1, screenY1 = debug.projection.toScreen(x1, y1)
  local screenX2, screenY2 = debug.projection.toScreen(x2, y2)

  if color then
    love.graphics.setColor(color)
  end

  love.graphics.line(screenX1, screenY1, screenX2, screenY2)
end

-- Display library information
function debug.printInfo()
  print('=== iso3d Debug Info ===')
  print('Version: ' .. (debug.version or 'unknown'))
  print('Tile Width: ' .. debug.config.tileWidth)
  print('Tile Height: ' .. debug.config.tileHeight)
  print('Debug Mode: ' .. tostring(debug.config.debug))
  print('========================')
end

return debug
