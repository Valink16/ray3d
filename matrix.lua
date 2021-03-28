local module = {
	_description = "A simple class for matrix operations",
}

Vector = require "vector"

-- create the module
local matrix = {}
matrix.__index = matrix

-- get a random function from Love2d or base lua, in that order.
local rand = math.random
if love and love.math then rand = love.math.random end

-- makes a new n*m matrix where n are the columns(#vecs[1]) and m are the rows(#vecs), row-major
local function new(vecs)
	return setmetatable(vecs, matrix)
end

-- check if an object is a matrix
local function ismatrix(t)
	return getmetatable(t) == matrix
end

-- returns a copy of a matrix
function matrix:clone()
	return new(unpack(self))
end

-- meta function to multiply matrices with matrices for compositions(vf = a(b(vi))) or vectors
function matrix.__mul(a,b)
	local vecs = {}

	if type(a) == 'number' and ismatrix(b) then
		for i, v in ipairs(b) do
			table.insert(vecs, v * a)
		end
	elseif type(b) == 'number' and ismatrix(a) then
		for i, v in ipairs(a) do
			table.insert(vecs, v * b)
		end
	else
		assert(ismatrix(a) and ismatrix(b),  "mul: wrong argument types: (expected <matrix>, <matrix> or <matrix>, <vector> or <matrix>, <number>)")
		for i, bv in ipairs(b) do -- Matrix composition
			table.insert(vecs, a:vecmul(bv))
		end
	end

	return new(vecs)
end

-- meta function to check if matrices have the same values
function matrix.__eq(a,b)
	assert(ismatrix(a) and ismatrix(b), "eq: wrong argument types (expected <matrix> and <matrix>)")
	if #a == #b then
		for i, v in ipairs(a) do
			if v ~= b[i] then return false end
		end
	else
		return false
	end
	return true
end

-- meta function to change how vectors appear as string
-- ex: print(vector(2,8)) - this prints '(2,8)'
function matrix:__tostring()
	local s = ""
	for _, v in ipairs(self) do
		s = s..tostring(v)
	end
	return s
end

-- return x and y of vector, unpacked from table
function matrix:unpack()
	return unpack(self)
end


-- Multiplies the vectpr v using this matrix, returns a vector
function matrix:vecmul(v)
	assert(Vector.isvector(v), "eq: wrong argument type (expected <vector>)")
	local new_v = Vector.new()
	local arr = v:array()
	for i, bv in ipairs(self) do
		new_v = new_v + bv * arr[i]
	end
	return new_v
end

-- pack up and return module
module.new = new
return setmetatable(module, {__call = function(_,...) return new(...) end})
