-- iso3d - Isometric rendering library for Love2D
-- Version: 0.4.0

local iso3d = {
  _VERSION = '0.4.0',
  _DESCRIPTION = 'Isometric rendering library for Love2D',
  _LICENSE = 'MIT'
}

-- Module configuration
iso3d.config = {
  tileWidth = 64,
  tileHeight = 32,
  debug = false,
  zoom = 1.0  -- Zoom level (1.0 = normal, 2.0 = 2x zoom, 0.5 = zoom out)
}

-- Load submodules
local modulePath = (...):gsub('%.init$', '')
iso3d.map = require(modulePath .. '.map')
iso3d.tileset = require(modulePath .. '.tileset')

local projection = require(modulePath .. '.projection')
local render = require(modulePath .. '.render')
local debug = require(modulePath .. '.debug')

-- Inject config references into submodules
projection.config = iso3d.config
render.config = iso3d.config
render.projection = projection
debug.config = iso3d.config
debug.projection = projection
debug.version = iso3d._VERSION

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

-- Set zoom level
function iso3d.setZoom(zoom)
  if type(zoom) ~= 'number' or zoom <= 0 then
    error('Zoom must be a positive number')
  end
  iso3d.config.zoom = zoom
end

-- Get current zoom level
function iso3d.getZoom()
  return iso3d.config.zoom
end

-- Export projection functions
iso3d.toScreen = projection.toScreen
iso3d.toWorld = projection.toWorld

-- Export render functions
iso3d.drawTileDiamond = render.drawTileDiamond
iso3d.drawTileSprite = render.drawTileSprite
iso3d.drawTile = render.drawTile
iso3d.drawMap = render.drawMap

-- Export debug functions
iso3d.drawPoint = debug.drawPoint
iso3d.drawLine = debug.drawLine
iso3d.debug = debug.printInfo

return iso3d
