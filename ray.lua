local module = {
	_version = "rays v0.1",
	_description = "A class for raymarching",
}

Vector = require "vector"
Matrix = require "matrix"

-- create the module
local ray = {}
ray.__index = ray

-- get a random function from Love2d or base lua, in that order.
local rand = math.random
if love and love.math then rand = love.math.random end

-- makes a new ray with a direction vector
local function new(dir, pos)
	return setmetatable({dir=dir or Vector(), pos=Vector()}, ray)
end

-- check if an object is a matrix
local function isray(t)
	return getmetatable(t) == ray
end

-- returns a copy of a matrix
function ray:clone()
	return new(self.dir:clone())
end

function ray:get_color(objects)
	local grad_d = math.huge
	local min_dist = math.huge
	local closest_o = nil

	for i, o in ipairs(objects) do
		local col = o:collide(self)
		if col[1] ~= nil then
			local d = (col[1] - self.pos):magSq()
			if d < min_dist then
				min_dist = d
				closest_o = o
			end
		elseif col[2] < grad_d then
			grad_d = col[2]
		end
	end

	if min_dist ~= math.huge then
		return closest_o.c
	else
		return {0.0, 0.0, 0.0}
	end
end

function ray:get_color_march(objects)
	local current = self.pos
	local super_min = math.huge
	local last_o = nil
	repeat
		local min_dist = math.huge
		-- Find the closest object
		for i, o in ipairs(objects) do
			local dist = o:dist(current)
			if dist < min_dist then	
				min_dist = dist
				last_o = o
			end
		end

		if min_dist < super_min then super_min = min_dist end
		
		-- Translate the ray on it's direction by min_dist
		current = current + (self.dir * min_dist)
		--print(min_dist)
		if min_dist < 0.1 then -- impact
			return last_o.c
		end
	until (min_dist > 1000)

	local grad = 1 / super_min
	return {grad, grad, grad}
end


-- meta function to check if rays have the same values
function ray.__eq(a,b)
	assert(isray(a) and isray(b), "eq: wrong argument types (expected <matrix> and <matrix>)")
	return a.dir == b.dir
end

function ray:__tostring()
	return tostring(self.dir)
end

-- pack up and return module
module.new = new
module.isray = isray
return setmetatable(module, {__call = function(_,...) return new(...) end})
