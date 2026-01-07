-- iso3d.render - Rendering functions
-- Handles drawing of tiles, sprites, and maps

local render = {}

-- References to other modules (will be set by init.lua)
render.config = nil
render.projection = nil

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
function render.drawTile(tile, x, y, tileset)
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
    render.drawTileSprite(x, y, sprite, opacity, scale)
  else
    -- Render with color (fallback when no sprite)
    render.drawTileDiamond(x, y, color, opacity)
  end

  -- Draw debug info if enabled
  if render.config.debug then
    local screenX, screenY = render.projection.toScreen(x, y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tile.type, screenX - 10, screenY - 5)
  end
end

-- Draw a complete map
function render.drawMap(gameMap, offset)
  if not gameMap then return end

  offset = offset or {x = 0, y = 0}

  love.graphics.push()
  love.graphics.translate(offset.x, offset.y)

  -- Draw tiles back to front for proper depth sorting
  for y = gameMap.height, 1, -1 do
    for x = 1, gameMap.width do
      local tile = gameMap:getTile(x, y)
      if tile then
        render.drawTile(tile, x, y, gameMap:getTileset())
      end
    end
  end

  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)  -- Reset color
end

return render
