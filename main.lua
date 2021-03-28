Vector = require "vector"
Matrix = require "matrix"
Canvas = require "canvas"
Sphere = require "sphere"
Light = require "light"
util = require "util"

PI = math.pi

Lerp = util.lerp

function love.load()
	love.window.setMode(800, 600, {resizable=true})
	Draw_t = 0

	W, H = love.window.getMode()

	Scale = 2
	Canvas = Canvas(Vector(W / Scale, H / Scale), util.deg_to_rad(90))

	print("Vertical FOV: "..tostring(util.rad_to_deg(Canvas.v_fov)))

	Objects = {
		Sphere(Vector(0, 0, 20), 3, Vector(0.0, 1.0, 0.0, 1.0)),
		Sphere(Vector(0, 0, 15), 1, Vector(0.0, 0.0, 1.0, 1.0)),
		-- Sphere(Vector(0, 10, 32), 3, Vector(0.5, 0.0, 0.0)),
		-- Sphere(Vector(0, -10, 28), 5, Vector(0.0, 1.0, 0.0)),
	}

	Lights = {
		--Light(Vector(-50, 0, 20), Vector(1.0, 1.0, 1.0, 1.0) * 1.0),
		Light(Vector(0, 0, 5), Vector(1.0, 1.0, 1.0, 1.0) * 1.0),
		--Light(Vector(0, 0, 10), Vector(1.0, 1.0, 1.0, 1.0) * 1.0),
	}

	T = 0

	Debug_ray = Canvas.rays[Canvas.res.y / 2][Canvas.res.x / 2]

	--print(Objects[1]:dist(Vector()))
end

function love.draw()
	local ds = love.timer.getTime()

	Canvas:draw(Objects, Lights)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(tostring(Draw_t))
	love.graphics.print("x: "..tostring(Lights[1].pos.x), 0, 12)
	love.graphics.print("z: "..tostring(Lights[1].pos.z), 0, 24)

	Draw_t = love.timer.getTime() - ds

	--print(Debug_ray:get_color(Objects, Lights, true))
end

function love.update()
	local mx, my = love.mouse.getPosition()
	T = T + (1.0/60.0)

	--Objects[2].pos.x = Lerp(-5, 5, math.sin(T * 4))
	-- Objects[2].pos.z = Lerp(27, 37, math.cos(T))

	--Lights[1].pos.z = math.cos(T * 4) * 10 + 18
	Lights[1].pos.x = -math.sin(T * 4) * 30
	
	--[[
	Objects[1].pos.x = Lerp(-5, 5, math.sin(T))
	Objects[2].pos.x = Lerp(5, -5, math.sin(T))

	Objects[1].pos.z = Lerp(25, 35, math.cos(T))
	Objects[2].pos.z = Lerp(35, 25, math.cos(T))
	
	Objects[3].pos.y = Lerp(10, -10, math.sin(T))
	Objects[4].pos.y = Lerp(-10, 10, math.sin(T))

	Objects[3].pos.z = Lerp(25, 35, math.cos(T))
	Objects[4].pos.z = Lerp(35, 25, math.cos(T))

	Objects[1].pos.y = Lerp(5, -5, math.sin(T))
	Objects[2].pos.y = Lerp(-5, 5, math.sin(T))
	]]--
end

function love.resize()
	local w, h = love.window.getMode()
	Canvas.real_res = Vector(w, h)
	Canvas.res = Vector(w, h) / Scale
	Canvas:reset_rays()
end
