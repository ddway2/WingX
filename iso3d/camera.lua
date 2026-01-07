-- iso3d.camera - Camera management functions
-- Handles rotation and coordinate transformations

local camera = {}

-- Reference to parent config (will be set by init.lua)
camera.config = nil

-- Apply rotation transformation to grid coordinates
-- rotation: 0 (north), 1 (east), 2 (south), 3 (west)
function camera.applyRotation(x, y, mapWidth, mapHeight, rotation)
  rotation = rotation or 0

  if rotation == 0 then
    -- No rotation (north view)
    return x, y
  elseif rotation == 1 then
    -- 90° clockwise (east view)
    return mapHeight - y + 1, x
  elseif rotation == 2 then
    -- 180° (south view)
    return mapWidth - x + 1, mapHeight - y + 1
  elseif rotation == 3 then
    -- 270° clockwise / 90° counter-clockwise (west view)
    return y, mapWidth - x + 1
  else
    error(string.format('Invalid rotation: %d (must be 0-3)', rotation))
  end
end

-- Apply inverse rotation transformation (screen to world)
function camera.applyInverseRotation(x, y, mapWidth, mapHeight, rotation)
  rotation = rotation or 0

  if rotation == 0 then
    return x, y
  elseif rotation == 1 then
    -- Inverse of 90° clockwise = 270° clockwise
    return y, mapHeight - x + 1
  elseif rotation == 2 then
    -- Inverse of 180° = 180°
    return mapWidth - x + 1, mapHeight - y + 1
  elseif rotation == 3 then
    -- Inverse of 270° clockwise = 90° clockwise
    return mapWidth - y + 1, x
  else
    error(string.format('Invalid rotation: %d (must be 0-3)', rotation))
  end
end

-- Get the draw order iterator for proper depth sorting based on rotation
-- Returns: startY, endY, stepY, startX, endX, stepX
function camera.getDrawOrder(mapWidth, mapHeight, rotation)
  rotation = rotation or 0

  if rotation == 0 then
    -- North: back to front (y high to low, x low to high)
    return mapHeight, 1, -1, 1, mapWidth, 1
  elseif rotation == 1 then
    -- East: rotate perspective
    return mapWidth, 1, -1, 1, mapHeight, 1
  elseif rotation == 2 then
    -- South: opposite of north
    return 1, mapHeight, 1, mapWidth, 1, -1
  elseif rotation == 3 then
    -- West: rotate perspective
    return 1, mapWidth, 1, mapHeight, 1, -1
  else
    error(string.format('Invalid rotation: %d (must be 0-3)', rotation))
  end
end

return camera
