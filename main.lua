-- WingX - Love2D Hello World
-- This is a minimal Love2D application that displays "Hello World"

function love.load()
  print('WingX Love2D application started!')
  print('Hello World from the console!')

  -- Set window title
  love.window.setTitle('WingX - Hello World')

  -- Variables for animation
  time = 0
end

function love.update(dt)
  -- Update animation time
  time = time + dt
end

function love.draw()
  -- Set background color (dark blue)
  love.graphics.clear(0.1, 0.1, 0.2)

  -- Draw "Hello World" text in the center
  love.graphics.setColor(1, 1, 1)
  local font = love.graphics.newFont(48)
  love.graphics.setFont(font)

  local text = "Hello World"
  local textWidth = font:getWidth(text)
  local textHeight = font:getHeight()
  local x = (love.graphics.getWidth() - textWidth) / 2
  local y = (love.graphics.getHeight() - textHeight) / 2

  love.graphics.print(text, x, y)

  -- Draw a pulsing circle below the text
  love.graphics.setColor(0.3, 0.7, 1)
  local radius = 50 + math.sin(time * 2) * 10
  love.graphics.circle('fill', love.graphics.getWidth() / 2, y + textHeight + 80, radius)
end
