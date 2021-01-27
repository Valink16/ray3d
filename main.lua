Vector = require "vector"
Matrix = require "matrix"
Canvas = require "canvas"

PI = math.pi

function love.load()

	WIDTH, HEIGHT = love.window.getMode()

	local canvas = Canvas(Vector(10, 10), math.pi / 2)

	print(#canvas.rays)
end

function love.draw()
	local s = "Hello, world !"
	love.graphics.print(s, WIDTH / 2, HEIGHT / 2, love.timer.getTime(), nil, nil, #s * 2.5, 5)
end