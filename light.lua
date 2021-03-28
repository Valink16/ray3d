local module = {
	_description = "A class representing lights",
}

Vector = require "vector"
Matrix = require "matrix"

-- create the module
local light = {}
light.__index = light

local rand = math.random
if love and love.math then rand = love.math.random end

-- makes a new light with at pos with color c
local function new(pos, c) -- c is a vector, norm of c represents the light intensity
	return setmetatable({pos=pos or Vector(), c=c or Vector}, light)
end

-- check if an object is a light
local function islight(t)
	return getmetatable(t) == light
end

-- returns a copy of a light
function light:clone()
	return new(self.pos:clone(), self.c:clone())
end

-- meta function to check if lights have the same values
function light.__eq(a,b)
	assert(islight(a) and islight(b), "eq: wrong argument types (expected <matrix> and <matrix>)")
	return a.dir == b.dir
end

function light:__tostring()
	return tostring(self.pos, self.c)
end

-- pack up and return module
module.new = new
module.islight = islight
return setmetatable(module, {__call = function(_,...) return new(...) end})
