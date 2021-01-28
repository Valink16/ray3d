Vector = require "vector"
Matrix = require "matrix"
Canvas = require "canvas"

PI = math.pi

function love.load()
	Canvas = Canvas(Vector(200, 200), math.pi / 2)
	Draw_t = 0
	love.window.setMode(800, 600, {resizable=true})
end

function love.draw()
	local ds = love.timer.getTime()

	Canvas:draw()

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(tostring(Draw_t))

	Draw_t = love.timer.getTime() - ds
end

function love.resize()
	local w, h = love.window.getMode()
	Canvas.real_res = Vector(w, h)
end