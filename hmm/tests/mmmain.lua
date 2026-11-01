local grid = {}

local function generateNoiseGrid()
	-- Fill each tile in our grid with noise.
	local baseX = 10000 * love.math.random()
	local baseY = 10000 * love.math.random()
	for y = 1, 60 do
		grid[y] = {}
		for x = 1, 60 do
			grid[y][x] = love.math.noise(baseX+.1*x, baseY+.2*y)
		end
	end
end

function love.load()
	generateNoiseGrid()
end
function love.keypressed()
	generateNoiseGrid()
end

function love.draw()
	local tileSize = 8
	for y = 1, #grid do
		for x = 1, #grid[y] do
			love.graphics.setColor(1, 1, 1, grid[y][x])
			love.graphics.rectangle("fill", x*tileSize, y*tileSize, tileSize-1, tileSize-1)
		end
	end
end