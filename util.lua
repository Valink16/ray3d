local module = {
	_version = "util v0.1",
	_description = "Module with useful general function",
}

function module.lerp(a, b, x)
	return a + x * (b - a)
end

function module.rad_to_deg(r)
	return (r / (2 * math.pi)) * 360
end

function module.deg_to_rad(d)
	return math.pi * 2 * d / 360
end

return module