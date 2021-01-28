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
	c.v_fov = fov / (res.x / res.y) -- Deduce vertical FOV using aspect ratio

	-- Rays generation
	local slice = {} -- "Slice" if rays, represents a line of rays(aligned of the x axis) 
	for i = 0, c.res.x - 1 do
		local a = i * (c.h_fov / c.res.x) - (c.h_fov / 2)
		table.insert(slice, Vector(
			math.sin(a),
			0,
			math.cos(a)
		))
	end
	
	-- The single slice gets rotated many times to get all the rows of rays
	c.rays = {}
	for i = c.res.y - 1, 0 , -1 do -- Go in reverse so the first generated slices are from the top
		local a = i * (c.v_fov / c.res.y ) - (c.v_fov / 2) 
		local rot_mat = Matrix({ -- Rotation matrix around the x axis
			Vector(1, 0, 0),
			Vector(0, math.sin(PI/2+a), math.cos(PI/2+a)),
			Vector(0, math.sin(a), math.cos(a))
		})

		local new_slice = {}
		for _, v in ipairs(slice) do -- Apply the matrix to each vector of the slice
			table.insert(new_slice, Ray(rot_mat:vecmul(v)))
		end
		table.insert(c.rays, new_slice)
	end

	return setmetatable(c, canvas)
end

-- Main function to draw pixels using cast rays
function canvas:draw(scale)
	-- Draws a surface on screen with scale vector, if nil the surface is ajusted to fit the whole screen
	local s = scale or Vector(self.real_res.x / self.res.x, self.real_res.y / self.res.y)
	local pix_mode = (s.x == 1) and (s.y == 1)
	for y, line in ipairs(self.rays) do
		for x, ray in ipairs(line) do
			love.graphics.setColor(math.random(), math.random(), math.random())
			if pix_mode then
				love.graphics.points(x - 0.5, y - 0.5)
			else
				love.graphics.rectangle("fill", (x - 1) * s.x, (y - 1) * s.y, s.x, s.y)
			end
		end
	end
end

-- returns a copy of a matrix
function canvas:clone()
	return new(self.res, self.h_fov)
end

-- pack up and return module
module.new = new
return setmetatable(module, {__call = function(_,...) return new(...) end})
