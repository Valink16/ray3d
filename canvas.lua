local module = {
	_version = "canvas v0.1",
	_description = "Class that links the screen output with rays",
}

Vector = require "vector"
Matrix = require "matrix"
Ray = require "ray"

PI = math.pi

-- create the module
local canvas = {}
canvas.__index = canvas

-- get a random function from Love2d or base lua, in that order.
local rand = math.random
if love and love.math then rand = love.math.random end

-- Creates a canvas with a size given by res, generates rays automatically in function of the FOV(Horizontal)
local function new(res, fov)
	local c = {}
	c.res = res -- res is a 2d vector
	local w, h = love.window.getMode()
	c.real_res = Vector(w, h)
	c.h_fov = fov -- Horizontal field of view

	local c = setmetatable(c, canvas)
	c:reset_rays()
	return c
end

-- Main function to draw pixels using cast rays
function canvas:draw(objects, scale)
	-- Draws a surface on screen with scale vector, if nil the surface is ajusted to fit the whole screen
	local s = scale or Vector(self.real_res.x / self.res.x, self.real_res.y / self.res.y)
	local pix_mode = (s.x == 1) and (s.y == 1)

	local avg_get_color_t = 0

	for y, line in ipairs(self.rays) do
		for x, ray in ipairs(line) do
			local ts = love.timer.getTime()
			local c = ray:get_color(objects)
			avg_get_color_t = avg_get_color_t + (love.timer.getTime() - ts)

			love.graphics.setColor(c)
			if pix_mode then
				love.graphics.points(x - 0.5, y - 0.5)
			else
				love.graphics.rectangle("fill", (x - 1) * s.x, (y - 1) * s.y, s.x, s.y)
			end
		end
	end

	-- print(avg_get_color_t / (#self.rays * #self.rays[1]))
end

-- returns a copy of a matrix
function canvas:clone()
	return new(self.res, self.h_fov)
end

function canvas:reset_rays()
	self.v_fov = self.h_fov / (self.res.x / self.res.y) -- Deduce vertical FOV using aspect ratio

	local rays_create_s = love.timer.getTime()
	-- Rays generation
	local depth_w = (math.cos(self.h_fov / 2) * self.res.x) / (2 * math.sin(self.h_fov / 2))

	self.rays = {}
	for y = -self.res.y / 2, self.res.y / 2 - 1 do
		local slice = {} -- "Slice" if rays, represents a line of rays(aligned of the x axis) 
		for x = -self.res.x / 2, self.res.x / 2 - 1 do
			local dir = Vector(x, y, depth_w):norm()
			table.insert(slice, Ray(dir, Vector()))
		end
		table.insert(self.rays, slice)
	end
	

	-- The single slice gets rotated many times to get all the rows of rays

	print("Generated "..tostring(#self.rays * #self.rays[1]).." rays in "..tostring(love.timer.getTime() - rays_create_s).."s")
end

-- pack up and return module
module.new = new
return setmetatable(module, {__call = function(_,...) return new(...) end})
