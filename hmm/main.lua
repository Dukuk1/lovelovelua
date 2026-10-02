


local squares = {}
local bounds = {}

function fib(n)
    local a, b = 1, 1
    local fibs = {}
    for i = 1, n do
        table.insert(fibs, a)
        a, b = b, a + b
    end
    return fibs
end

function love.load()
    love.window.setTitle("Fibonacci Rectangle")
    love.window.setMode(1300, 1300)

    local sizes = fib(10)

    -- first square at the origin
    local minX, minY = 0, 0
    local maxX, maxY = sizes[1], sizes[1]
    squares[1] = { x = 0, y = 0, s = sizes[1], dir = 3 }


    for i = 2, #sizes do
        local s = sizes[i]
        local dir = (i - 2) % 4
        local x, y
        local d = 0

        if dir == 0 then 
            x, y = maxX, minY
            d = 0 --right
        elseif dir == 1 then   
            x, y = minX, minY - s
            d = 1 --top
        elseif dir == 2 then  
            x, y = minX - s, minY
            d = 2--left
        else                   
            x, y = minX, maxY
            d = 3-- bottom
        end

        squares[i] = { x = x, y = y, s = s, dir = d }

        minX = math.min(minX, x)
        minY = math.min(minY, y)
        maxX = math.max(maxX, x + s)
        maxY = math.max(maxY, y + s)
    end

    bounds = { minX = minX, minY = minY, maxX = maxX, maxY = maxY }
end

function love.draw()
    local sw, sh = love.graphics.getDimensions()
    local bw = bounds.maxX - bounds.minX
    local bh = bounds.maxY - bounds.minY

    -- scale to fit the window with a margin, then center 
    local scale = math.min(sw / bw, sh / bh) * 0.9
    local ox = (sw - bw * scale) / 2
    local oy = (sh - bh * scale) / 2

    local font = love.graphics.getFont()

    for _, sq in ipairs(squares) do
        local px = ox + (sq.x - bounds.minX) * scale
        local py = oy + (sq.y - bounds.minY) * scale
        local size = sq.s * scale
        local dir = sq.dir

        love.graphics.setColor(1, 0.8, 0.2)
        
        -- if dir == 0 then 
        --     love.graphics.line(px, py+size, px+size, py)--right
        -- elseif dir == 1 then   
        --     love.graphics.line(px, py, px+size, py+size)--top
        -- elseif dir == 2 then  
        --     love.graphics.line(px, py+size, px+size, py)--left
        -- else                   
        --      love.graphics.line(px, py, px+size, py+size) -- bottom
        -- end

        local cx, cy, a1, a2
        if dir == 0 then
            cx, cy = px, py + size
            a1, a2 = math.pi * 1.5, math.pi * 2
        elseif dir == 3 then
            cx, cy = px, py
            a1, a2 = 0, math.pi * 0.5
        elseif dir == 2 then
            cx, cy = px + size, py
            a1, a2 = math.pi * 0.5, math.pi
        elseif dir == 1 then
            cx, cy = px + size, py + size
            a1, a2 = math.pi, math.pi * 1.5
        end

        -- Draw the quarter-circle arc
        love.graphics.arc("line", "open", cx, cy, size, a1, a2)


        love.graphics.rectangle("line", px, py, size, size)

        love.graphics.printf(sq.s, px, py + size / 2 - font:getHeight() / 2, size, "center")
        love.graphics.printf(dir, px, py + size / 2 - font:getHeight() / 2, size, "left")
    end

    love.graphics.setLineWidth(3)
    love.graphics.setColor(1, 0.8, 0.2)
    love.graphics.rectangle("line", ox, oy, bw * scale, bh * scale)
    love.graphics.setLineWidth(1)
end