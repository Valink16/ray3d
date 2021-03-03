Vector = require "vector"
Matrix = require "matrix"
Canvas = require "canvas"
Sphere = require "sphere"

PI = math.pi

function Lerp(a, b, x)
	return a + (b - a) * x
end

function love.load()
	love.window.setMode(1280, 720, {resizable=true})
	Draw_t = 0

	W, H = love.window.getMode()

	Scale = 4
	Canvas = Canvas(Vector(W / Scale, H / Scale), math.pi * 2 * 90 / 360)

	Objects = {
		Sphere(Vector(-5, 0, 28), 5, {0.5, 0.5, 0.0}),
		Sphere(Vector(5, 0, 32), 5, {0.0, 0.0, 0.5}),
	}

	T = 0

	--print(Objects[1]:dist(Vector()))
end

function love.draw()
	local ds = love.timer.getTime()

	Canvas:draw(Objects)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(tostring(Draw_t))

	Draw_t = love.timer.getTime() - ds
end

function love.update()
	local mx, my = love.mouse.getPosition()
	T = T + (1.0/60.0)

	Objects[1].pos.x = Lerp(-5, 5, math.sin(T))
	Objects[2].pos.x = Lerp(5, -5, math.sin(T))

	Objects[1].pos.z = Lerp(28, 32, math.cos(T))
	Objects[2].pos.z = Lerp(32, 28, math.cos(T))

	-- Objects[1].pos.y = Lerp(5, -5, math.sin(T))
	-- Objects[2].pos.y = Lerp(-5, 5, math.sin(T))
	
end

function love.resize()
	local w, h = love.window.getMode()
	Canvas.real_res = Vector(w, h)
	Canvas.res = Vector(w, h) / Scale
	Canvas:reset_rays()
end
