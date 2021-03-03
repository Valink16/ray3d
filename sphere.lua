local module = {
	_version = "objects v0.1",
	_description = "A class to implement raytracing on spheres",
}

Vector = require "vector"

-- create the module
local sphere = {}
sphere.__index = sphere

local function new(pos, r, c)
	return setmetatable({pos=pos or Vector(), r=r, c=c}, sphere)
end

-- check if an object is a sphere
local function issphere(t)
	return getmetatable(t) == sphere
  end

function sphere:dist(from)
	local dx = self.pos.x - from.x
	local dy = self.pos.y - from.y
	local dz = self.pos.z - from.z
	return math.sqrt(dx*dx + dy*dy + dz*dz) - self.r
end

function sphere:collide(ray) -- Returns the collision points with a ray
	-- a, b, c coefficients of a quadratic formula
	local a = ray.dir.x*ray.dir.x + ray.dir.y*ray.dir.y + ray.dir.z*ray.dir.z
	local b = 2 * ((ray.dir.x*ray.pos.x + ray.dir.y*ray.pos.y + ray.dir.z*ray.pos.z) - (ray.dir.x*self.pos.x + ray.dir.y*self.pos.y + ray.dir.z*self.pos.z))
	local c = (self.pos.x*self.pos.x + self.pos.y*self.pos.y + self.pos.z*self.pos.z) - 2*(ray.pos.x*self.pos.x + ray.pos.y*self.pos.y + ray.pos.z*self.pos.z) + (ray.pos.x*ray.pos.x + ray.pos.y*ray.pos.y + ray.pos.z*ray.pos.z) - self.r*self.r
	local delta = b*b - 4*a*c
	local mt = (-b) / (2*a)
	
	if delta < 0 then
		return {nil, a*mt*mt + b*mt + c}
	elseif delta == 0 then return {ray.pos + ray.dir * (-b / (2 * a)), 0} end

	--[[
	local sq_delta = math.sqrt(delta)
	local t1 = (-b-sq_delta) / (2*a)
	local t2 = (-b+sq_delta) / (2*a)
	--]]

	--[[
	return {
		ray.pos + ray.dir * t1,
		ray.pos + ray.dir * t2,
	}
	--]]

	local t = (-b-math.sqrt(delta)) / (2*a)

	return {
		ray.pos + ray.dir * t,
		0
	}
end

-- pack up and return module
module.new = new
module.issphere = issphere
return setmetatable(module, {__call = function(_,...) return new(...) end})