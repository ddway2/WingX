-- WingX - Isometric Map Demo
-- Demonstrates iso3d library with tileset and map rendering

local iso3d = require('iso3d')

-- Global variables
local gameMap
local tileset
local renderMode = 'block'  -- 'block' or 'flat'
local cameraOffset = {x = 0, y = 0}
local font

function love.load()
  print('WingX Isometric Map Demo started!')
  print('iso3d version: ' .. iso3d.getVersion())

  -- Set window title
  love.window.setTitle('WingX - Isometric Map Demo')

  -- Initialize iso3d
  iso3d.init({
    tileWidth = 64,
    tileHeight = 32,
    debug = false  -- Set to true to see tile coordinates
  })

  -- Load tileset and map
  tileset = iso3d.tileset.loadFromFile('tilesets/simple.lua')
  gameMap = iso3d.map.loadFromFile('maps/test.map')

  -- Associate tileset with map
  gameMap:setTileset(tileset)

  -- Center camera
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  cameraOffset.x = screenWidth / 2
  cameraOffset.y = screenHeight / 4

  -- Load font
  font = love.graphics.newFont(14)
  love.graphics.setFont(font)

  print('Map loaded: ' .. gameMap.width .. 'x' .. gameMap.height)
  print('Tileset: ' .. tileset.name)
  print('')
  print('Controls:')
  print('  Arrow keys: Move camera')
  print('  Space: Toggle render mode (block/flat)')
  print('  D: Toggle debug mode')
  print('  R: Reset camera')
end

function love.update(dt)
  -- Camera movement
  local moveSpeed = 200 * dt

  if love.keyboard.isDown('left') then
    cameraOffset.x = cameraOffset.x + moveSpeed
  end
  if love.keyboard.isDown('right') then
    cameraOffset.x = cameraOffset.x - moveSpeed
  end
  if love.keyboard.isDown('up') then
    cameraOffset.y = cameraOffset.y + moveSpeed
  end
  if love.keyboard.isDown('down') then
    cameraOffset.y = cameraOffset.y - moveSpeed
  end
end

function love.keypressed(key)
  -- Toggle render mode
  if key == 'space' then
    if renderMode == 'block' then
      renderMode = 'flat'
      print('Render mode: flat')
    else
      renderMode = 'block'
      print('Render mode: block')
    end
  end

  -- Toggle debug mode
  if key == 'd' then
    iso3d.config.debug = not iso3d.config.debug
    print('Debug mode: ' .. tostring(iso3d.config.debug))
  end

  -- Reset camera
  if key == 'r' then
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    cameraOffset.x = screenWidth / 2
    cameraOffset.y = screenHeight / 4
    print('Camera reset')
  end
end

function love.draw()
  -- Set background color (dark gray)
  love.graphics.clear(0.15, 0.15, 0.2)

  -- Draw the isometric map
  iso3d.drawMap(gameMap, renderMode, cameraOffset)

  -- Draw UI
  love.graphics.setColor(1, 1, 1, 0.9)
  local uiY = 10

  love.graphics.print('WingX - Isometric Map Demo', 10, uiY)
  uiY = uiY + 20

  love.graphics.print('iso3d v' .. iso3d.getVersion(), 10, uiY)
  uiY = uiY + 20

  love.graphics.print('Map: ' .. gameMap.width .. 'x' .. gameMap.height, 10, uiY)
  uiY = uiY + 20

  love.graphics.print('Render mode: ' .. renderMode, 10, uiY)
  uiY = uiY + 20

  love.graphics.print('Debug: ' .. tostring(iso3d.config.debug), 10, uiY)
  uiY = uiY + 30

  -- Controls
  love.graphics.setColor(1, 1, 1, 0.7)
  love.graphics.print('Controls:', 10, uiY)
  uiY = uiY + 18
  love.graphics.print('  Arrows: Move camera', 10, uiY)
  uiY = uiY + 18
  love.graphics.print('  Space: Toggle mode', 10, uiY)
  uiY = uiY + 18
  love.graphics.print('  D: Toggle debug', 10, uiY)
  uiY = uiY + 18
  love.graphics.print('  R: Reset camera', 10, uiY)

  -- Tile legend
  uiY = uiY + 30
  love.graphics.setColor(1, 1, 1, 0.9)
  love.graphics.print('Tile Legend:', 10, uiY)
  uiY = uiY + 18

  -- Draw small tile samples
  local legendX = 10
  tileset:each(function(id, def)
    love.graphics.setColor(def.color)
    love.graphics.rectangle('fill', legendX, uiY, 15, 15)
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print(id .. ': ' .. def.name, legendX + 20, uiY + 2)
    uiY = uiY + 18
  end)
end
