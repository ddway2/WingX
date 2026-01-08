-- iso3d.render - Rendering functions
-- Handles drawing of tiles, sprites, and maps

local render = {}

-- References to other modules (will be set by init.lua)
render.config = nil
render.projection = nil
render.camera = nil

-- Helper: Apply rotation and then project to screen coordinates
local function toScreenRotated(x, y, mapWidth, mapHeight)
  local rotation = render.config.rotation

  if rotation ~= 0 and mapWidth and mapHeight then
    -- Apply rotation transformation
    x, y = render.camera.applyRotation(x, y, mapWidth, mapHeight, rotation)
  end

  -- Apply isometric projection
  return render.projection.toScreen(x, y)
end

-- Draw an isometric tile (diamond shape)
function render.drawTileDiamond(x, y, color, opacity)
  local screenX, screenY = render.projection.toScreen(x, y)
  local zoom = render.config.zoom
  local tw = render.config.tileWidth / 2 * zoom
  local th = render.config.tileHeight / 2 * zoom

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

-- Draw a 3D block (with height)
-- height: height of the block in tile units (0.5, 1, 1.5, 2, etc.)
--         height=1 creates a perfect cube (height = tileWidth)
function render.drawBlock(x, y, height, color, opacity)
  if not height or height <= 0 then
    -- If no height, draw as flat tile
    render.drawTileDiamond(x, y, color, opacity)
    return
  end

  local screenX, screenY = render.projection.toScreen(x, y)
  local zoom = render.config.zoom
  local tw = render.config.tileWidth / 2 * zoom
  local th = render.config.tileHeight / 2 * zoom
  -- Convert height units to pixels for isometric 2:1 projection
  -- Use tileWidth / 2 (= tileHeight) to get correct cube proportions
  local blockHeight = height * render.config.tileWidth / 2 * zoom

  -- Set color and opacity
  local r, g, b, a = 0.8, 0.8, 0.8, 1
  if color then
    r, g, b, a = color[1], color[2], color[3], color[4] or 1
  end
  if opacity then
    a = a * opacity
  end

  -- Calculate face colors (darker for sides)
  local leftR, leftG, leftB = r * 0.6, g * 0.6, b * 0.6
  local rightR, rightG, rightB = r * 0.8, g * 0.8, b * 0.8

  -- Draw left face (darker)
  love.graphics.setColor(leftR, leftG, leftB, a)
  local leftVertices = {
    screenX - tw, screenY - blockHeight,      -- Top left
    screenX, screenY + th - blockHeight,      -- Top right
    screenX, screenY + th,                    -- Bottom right
    screenX - tw, screenY                     -- Bottom left
  }
  love.graphics.polygon('fill', leftVertices)
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.polygon('line', leftVertices)

  -- Draw right face (medium brightness)
  love.graphics.setColor(rightR, rightG, rightB, a)
  local rightVertices = {
    screenX, screenY - th - blockHeight,      -- Top left
    screenX + tw, screenY - blockHeight,      -- Top right
    screenX + tw, screenY,                    -- Bottom right
    screenX, screenY - th                     -- Bottom left
  }
  love.graphics.polygon('fill', rightVertices)
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.polygon('line', rightVertices)

  -- Draw top face (brightest - original color)
  love.graphics.setColor(r, g, b, a)
  local topVertices = {
    screenX, screenY - th - blockHeight,      -- Top
    screenX + tw, screenY - blockHeight,      -- Right
    screenX, screenY + th - blockHeight,      -- Bottom
    screenX - tw, screenY - blockHeight       -- Left
  }
  love.graphics.polygon('fill', topVertices)
  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.polygon('line', topVertices)
end

-- Draw a sprite on an isometric tile
function render.drawTileSprite(x, y, sprite, opacity, scale)
  if not sprite then return end

  local screenX, screenY = render.projection.toScreen(x, y)
  local zoom = render.config.zoom
  local tw = render.config.tileWidth * zoom
  local th = render.config.tileHeight * zoom

  opacity = opacity or 1.0
  scale = scale or 1.0

  love.graphics.setColor(1, 1, 1, opacity)

  -- Calculate sprite dimensions to fit the tile
  local spriteWidth = sprite:getWidth()
  local spriteHeight = sprite:getHeight()

  -- Scale the sprite to fit the tile width (including zoom)
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
-- mapWidth and mapHeight are optional, needed for rotation support
function render.drawTile(tile, x, y, tileset, mapWidth, mapHeight)
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

  -- Get height (tile-specific height overrides tileset default)
  local height = tile.height or (tileDef and tileDef.height) or 0

  -- Apply rotation to coordinates
  local renderX, renderY = x, y
  if render.config.rotation ~= 0 and mapWidth and mapHeight then
    renderX, renderY = render.camera.applyRotation(x, y, mapWidth, mapHeight, render.config.rotation)
  end

  -- Check if we have a sprite to render
  local sprite = tileDef and tileDef:getCurrentSprite()

  if sprite then
    -- Render with sprite
    render.drawTileSprite(renderX, renderY, sprite, opacity, scale)
  elseif height > 0 then
    -- Render as 3D block
    render.drawBlock(renderX, renderY, height, color, opacity)
  else
    -- Render as flat tile (fallback when no sprite and no height)
    render.drawTileDiamond(renderX, renderY, color, opacity)
  end

  -- Draw debug info if enabled
  if render.config.debug then
    local screenX, screenY = render.projection.toScreen(renderX, renderY)
    love.graphics.setColor(1, 1, 1, 1)
    local debugText = tile.type
    if height > 0 then
      debugText = debugText .. ' (h:' .. height .. ')'
    end
    love.graphics.print(debugText, screenX - 20, screenY - 5)
  end
end

-- Draw a complete map
function render.drawMap(gameMap, offset)
  if not gameMap then return end

  offset = offset or {x = 0, y = 0}

  love.graphics.push()
  love.graphics.translate(offset.x, offset.y)

  -- Get draw order based on rotation for proper depth sorting
  local startY, endY, stepY, startX, endX, stepX = render.camera.getDrawOrder(
    gameMap.width,
    gameMap.height,
    render.config.rotation
  )

  -- First pass: Draw flat tiles (height=0) in back-to-front order
  for y = startY, endY, stepY do
    for x = startX, endX, stepX do
      local tile = gameMap:getTile(x, y)
      if tile then
        -- Get tile definition to check height
        local tileDef = gameMap:getTileset() and gameMap:getTileset():getDefinition(tile.type)
        local height = tile.height or (tileDef and tileDef.height) or 0

        -- Only draw flat tiles in this pass
        if height == 0 then
          render.drawTile(tile, x, y, gameMap:getTileset(), gameMap.width, gameMap.height)
        end
      end
    end
  end

  -- Second pass: Draw 3D blocks (height>0) in back-to-front order
  for y = startY, endY, stepY do
    for x = startX, endX, stepX do
      local tile = gameMap:getTile(x, y)
      if tile then
        -- Get tile definition to check height
        local tileDef = gameMap:getTileset() and gameMap:getTileset():getDefinition(tile.type)
        local height = tile.height or (tileDef and tileDef.height) or 0

        -- Only draw blocks in this pass
        if height > 0 then
          render.drawTile(tile, x, y, gameMap:getTileset(), gameMap.width, gameMap.height)
        end
      end
    end
  end

  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)  -- Reset color
end

return render
