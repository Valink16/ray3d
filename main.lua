Vector = require "vector"
Matrix = require "matrix"

function fc(...)
	for _, a in ipairs(arg) do
		print(a)
	end
end

function love.load()
	fc(1, 2, 3)

	WIDTH, HEIGHT = love.window.getMode()

	H_FOV = math.pi / 2

	-- Rays generation
	slice = {}
	for a = -H_FOV / 2, H_FOV / 2, H_FOV / 10 do
		table.insert(slice, Vector.new(
			-math.sin(a),
			0,
			math.cos(a)
		))
	end

	--for _, v in ipairs(slice) do
	--	print(v, v:mag())
	--end

	local m1 = Matrix.new({
		Vector.new(2, 0, 0),
		Vector.new(0, 2, 0),
		Vector.new(0, 0, 2)
	})

	local m2 = Matrix.new({
		Vector.new(1, 0, 0),
		Vector.new(0, 1, 0),
		Vector.new(0, 0, 1)
	}) * 2

	print(m1 == m2)
end

function love.draw()
	love.graphics.print("Hello, world !", WIDTH / 2, HEIGHT / 2, love.timer.getTime(), nil, nil, 35, 6)
end