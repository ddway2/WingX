-- WingX - Isometric Map Demo
-- Demonstrates iso3d library with tileset and map rendering

local iso3d = require('iso3d')

-- Global variables
local gameMap
local tileset
local renderMode = 'block'  -- 'block' or 'flat'
local cameraOffset = {x = 0, y = 0}
local font

-- Available maps
local maps = {
  {name = "Demo 3D 4x4", file = "maps/demo_3d.map"},
  {name = "Stairs 3D 4x4", file = "maps/stairs_3d.map"},
  {name = "Test 8x8", file = "maps/test.map"},
  {name = "Island 32x32", file = "maps/island_32x32.map"},
  {name = "Terrain 32x32", file = "maps/terrain_32x32.map"},
  {name = "Island 64x64", file = "maps/island_64x64.map"},
  {name = "Terrain 64x64", file = "maps/terrain_64x64.map"},
  {name = "City 64x64", file = "maps/city_64x64.map"},
  {name = "Checkerboard 64x64", file = "maps/checkerboard_64x64.map"},
}
local currentMapIndex = 1

-- Load a map by index
function loadMap(index)
  currentMapIndex = index
  local mapInfo = maps[currentMapIndex]

  print('Loading map: ' .. mapInfo.name .. ' (' .. mapInfo.file .. ')')
  gameMap = iso3d.map.loadFromFile(mapInfo.file)
  gameMap:setTileset(tileset)

  -- Reset camera to center
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  cameraOffset.x = screenWidth / 2
  cameraOffset.y = screenHeight / 4

  print('Map loaded: ' .. gameMap.width .. 'x' .. gameMap.height)
end

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

  -- Load tileset
  tileset = iso3d.tileset.loadFromFile('tilesets/simple.lua')
  print('Tileset: ' .. tileset.name)

  -- Load sprites (if available)
  tileset:loadSprites()

  -- Load font
  font = love.graphics.newFont(14)
  love.graphics.setFont(font)

  -- Load initial map
  loadMap(currentMapIndex)

  print('')
  print('Controls:')
  print('  Arrow keys: Move camera')
  print('  Space: Toggle render mode (block/flat)')
  print('  D: Toggle debug mode')
  print('  R: Reset camera')
  print('  1-9: Load different maps')
  print('  N/P: Next/Previous map')
end

function love.update(dt)
  -- Update tileset animations
  if tileset then
    tileset:updateAnimations(dt)
  end

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

  -- Map selection with number keys (1-9)
  if key >= '1' and key <= '9' then
    local mapNum = tonumber(key)
    if mapNum <= #maps then
      loadMap(mapNum)
    end
  end

  -- Next map
  if key == 'n' then
    local nextIndex = (currentMapIndex % #maps) + 1
    loadMap(nextIndex)
  end

  -- Previous map
  if key == 'p' then
    local prevIndex = ((currentMapIndex - 2) % #maps) + 1
    loadMap(prevIndex)
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

  love.graphics.print('Map: ' .. maps[currentMapIndex].name .. ' (' .. gameMap.width .. 'x' .. gameMap.height .. ')', 10, uiY)
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
  uiY = uiY + 18
  love.graphics.print('  1-9: Select map', 10, uiY)
  uiY = uiY + 18
  love.graphics.print('  N/P: Next/Prev map', 10, uiY)

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
