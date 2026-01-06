-- WingX - LOVR Hello World
-- This is a minimal LOVR application that displays "Hello World"

function lovr.draw(pass)
  -- Draw "Hello World" text in 3D space
  pass:text('Hello World', 0, 1.7, -3, 0.5)

  -- Optional: Draw a simple cube to make the scene more interesting
  pass:cube(0, 1.7, -3, 0.1)
end

function lovr.load()
  print('WingX LOVR application started!')
  print('Hello World from the console!')
end
