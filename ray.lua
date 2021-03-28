local Util = require "util"
local module = {
	_description = "A class for raytracing",
}

Vector = require "vector"
Matrix = require "matrix"
Util = require "util"

-- create the module
local ray = {}
ray.__index = ray

-- get a random function from Love2d or base lua, in that order.
local rand = math.random
if love and love.math then rand = love.math.random end

-- makes a new ray with a direction vector
local function new(pos, dir)
	return setmetatable({dir=dir or Vector(), pos=pos or Vector()}, ray)
end

-- check if an object is a ray
local function isray(t)
	return getmetatable(t) == ray
end

-- returns a copy of a ray
function ray:clone()
	return new(self.pos:clone(), self.dir:clone())
end

function ray:get_color(objects, lights, deb)
	local min_dist = math.huge
	local closest_o = nil
	local closest_p = nil

	for i, o in ipairs(objects) do
		local col = o:collide(self)
		if col[2] ~= nil then
			if col[1] < min_dist then
				min_dist = col[1]
				closest_p = col[2]
				closest_o = o
			end
		end
	end

	if min_dist ~= math.huge then
		-- local l = self:light(closest_p + (closest_p - closest_o.pos):norm() / 10, objects, lights, deb) -- shift outside the spehre a bit
		local l = self:light(closest_p, objects, lights, deb) -- shift outside the spehre a bit
		return l - (Vector(1.0, 1.0, 1.0, 1.0) - closest_o.c) -- Lighting, the seen color of an object is the color left after the object absorbs the other colors from the light
		
	else
		return Vector(0.0, 0.0, 0.0, 1.0)
	end
end

function ray:get_color_march(objects, deb)
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
		
		-- Translate the ray on it's direction by `min_dist`
		current = current + (self.dir * min_dist)
		--print(min_dist)
		if min_dist < 0.1 then -- impact
			return last_o.c
		end
	until (min_dist > 1000)

	local grad = 1 / super_min
	return Vector(grad, grad, grad, grad)
end

function ray:light(from, objects, lights, deb)
	--[[ 
		args:
			- from : point which the lights are checked for, should be shifted a bit to the "outside", so shadows are correctly detected
	--]]
	local c = Vector(0.0, 0.0, 0.0, 1.0)

	for _, l in ipairs(lights) do
		local tc = nil
		local light_ray = Ray(from, (l.pos - from):norm()) -- Fire a ray to check if it can reach the light
		for _, o in ipairs(objects) do
			local col = o:is_collide(light_ray)
			if col ~= nil then
				if math.max(col[2], col[1]) > 0.001 then -- If the biggest of the roots is positive, the new ray collides with an object which is not the object it bounced off
					--print("Shadow "..tostring(light_ray.dir).." "..tostring(col[1]).." "..tostring(col[2]))
					tc = Vector(0.0, 0.0, 0.0, 1.0)
					goto endpoint
				end
			end
		end

		do 
			-- We'll be at this point if there is direct line of sight to the light
			local a = math.acos(
				light_ray.dir:dot(-self.dir) / (light_ray.dir:mag() * (-self.dir):mag())
			)

			if a > PI then a = a - PI end
			
			--print("DOT: "..tostring(light_ray.dir:dot(self.dir)).." A: "..tostring(Util.rad_to_deg(a)))
			--local cf = Util.clamp(Util.flerp(1.0, 0.0, a / math.pi, Util.east_out), 0.0, 1.0) -- light color coefficient
			local cf = Util.flerp(1.0, 0.0, a / math.pi, Util.east_out) -- light color coefficient
			tc = l.c * cf
		end
		
		::endpoint::
		c = c + tc
	end

	return c
end

-- meta function to check if rays have the same values
function ray.__eq(a, b)
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