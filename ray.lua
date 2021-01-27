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
local function new(dir)
	return setmetatable({dir=dir or Vector.new()}, ray)
end

-- check if an object is a matrix
local function isray(t)
	return getmetatable(t) == ray
end

-- returns a copy of a matrix
function ray:clone()
	return new(self.dir:clone())
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
return setmetatable(module, {__call = function(_,...) return new(...) end})
