local utf8 = require("utf8")
local text = ""
local font
local box = { x = 20, y = 50, w = 200, h = 40 }
local isFocused = true
local squares = {}
local bounds = nil          
local animProgress = 0
local animDuration = 2.0   
local MAX_N = 30

function fib(n)
    local a, b = 1, 1
    local fibs = {}
    for i = 1, n do
        table.insert(fibs, a)
        a, b = b, a + b
    end
    return fibs
end


function buildSquares(n)
    squares = {}
    local sizes = fib(n)

    local minX, minY = 0, 0
    local maxX, maxY = sizes[1], sizes[1]
    squares[1] = { x = 0, y = 0, s = sizes[1], dir = 3 }

    for i = 2, #sizes do
        local s = sizes[i]
        local dir = (i - 2) % 4
        local x, y

        if dir == 0 then x, y = maxX, minY        -- right
        elseif dir == 1 then x, y = minX, minY - s    -- top
        elseif dir == 2 then x, y = minX - s, minY    -- left
        else x, y = minX, maxY        -- bottom
        end

        squares[i] = { x = x, y = y, s = s, dir = dir }

        minX = math.min(minX, x)
        minY = math.min(minY, y)
        maxX = math.max(maxX, x + s)
        maxY = math.max(maxY, y + s)
    end

    bounds = { minX = minX, minY = minY, maxX = maxX, maxY = maxY }
    animProgress = 0
end

function process(str)
    local num = string.match(str, "(%d+)")
    return num and tonumber(num, 10) or nil
end

function love.mousepressed(x, y, button)
    if button == 1 then
        isFocused = x >= box.x and x <= box.x + box.w
                and y >= box.y and y <= box.y + box.h
    end
end

function love.textinput(t)
    if isFocused and t:match("^%d$") then   -- digits only
        text = text .. t
    end
end

function love.keypressed(key)
    if not isFocused then return end

    if key == "backspace" then
        local byteoffset = utf8.offset(text, -1)
        if byteoffset then
            text = string.sub(text, 1, byteoffset - 1)
        end
    elseif key == "return" then
        local n = process(text)
        if n and n >= 1 then
            n = math.min(n, MAX_N)
            buildSquares(n)
            isFocused = false
        else
            
        end
    end
end

function love.load()
    love.window.setTitle("Fibonacci Rectangle Animation")
    love.window.setMode(1300, 1300)
    love.keyboard.setKeyRepeat(true)
    font = love.graphics.getFont()
end

function love.update(dt)
    if bounds and not isFocused and love.keyboard.isDown("space") then
        animProgress = math.min(1, animProgress + dt / animDuration)
    else
        animProgress = math.max(0, animProgress - dt / animDuration * 2)
    end
end

function love.draw()
    -- input box
    love.graphics.setColor(0.15, 0.15, 0.15, 1)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)

    if isFocused then
        love.graphics.setColor(0.2, 0.6, 1, 1)
    else
        love.graphics.setColor(0.4, 0.4, 0.4, 1)
    end
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)

    love.graphics.setScissor(box.x + 2, box.y + 2, box.w - 4, box.h - 4)
    love.graphics.setColor(1, 1, 1, 1)
    local textY = box.y + (box.h - font:getHeight()) / 2
    love.graphics.print(text, box.x + 10, textY)
    love.graphics.setScissor()

    if not bounds then return end

    local sw, sh = love.graphics.getDimensions()
    local bw = bounds.maxX - bounds.minX
    local bh = bounds.maxY - bounds.minY

    local scale = math.min(sw / bw, sh / bh) * 0.9
    local ox = (sw - bw * scale) / 2
    local oy = (sh - bh * scale) / 2

    local totalSquares = #squares
    local currentVisible = animProgress * totalSquares

    for i = totalSquares, 1, -1 do
        local rank = totalSquares - i + 1

        if rank <= currentVisible + 1 then
            local sq = squares[i]
            local px = ox + (sq.x - bounds.minX) * scale
            local py = oy + (sq.y - bounds.minY) * scale
            local size = sq.s * scale
            local dir = sq.dir

            love.graphics.setColor(1, 0.8, 0.2)

            local cx, cy, a1, a2
            if dir == 1 then
                cx, cy = px, py + size
                a1, a2 = math.pi * 1.5, math.pi * 2
            elseif dir == 0 then
                cx, cy = px, py
                a1, a2 = 0, math.pi * 0.5
            elseif dir == 3 then
                cx, cy = px + size, py
                a1, a2 = math.pi * 0.5, math.pi
            else
                cx, cy = px + size, py + size
                a1, a2 = math.pi, math.pi * 1.5
            end

            love.graphics.arc("line", "open", cx, cy, size, a1, a2)
            love.graphics.rectangle("line", px, py, size, size)
                love.graphics.printf(sq.s, px, py + size / 2 - font:getHeight() / 2, size, "center")
        end
    end

    love.graphics.setLineWidth(3)
    love.graphics.setColor(1, 0.8, 0.2)
    love.graphics.rectangle("line", ox, oy, bw * scale, bh * scale)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("FPS: " .. tostring(love.timer.getFPS()), 20, 20, 200, "left")
end