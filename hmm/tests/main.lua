-- local utf8 = require("utf8")

-- local text = ""
-- local font
-- local box = { x = 100, y = 200, w = 300, h = 40 }
-- local isFocused = false
-- Pass = false
-- function love.load()
--     love.window.setMode(500, 500)
--     love.keyboard.setKeyRepeat(true)
--     font = love.graphics.getFont()
-- end

-- function love.mousepressed(x, y, button)
--     if button == 1 then
--         if x >= box.x and x <= box.x + box.w and y >= box.y and y <= box.y + box.h then
--             isFocused = true
--         else
--             isFocused = false
--         end
--     end
-- end

-- function love.textinput(t)
--     if isFocused then
--         text = text .. t
--     end
-- end

-- function love.keypressed(key)
--     Pass = false
--     if not isFocused then return end

--     if key == "backspace" then
--         local byteoffset = utf8.offset(text, -1)
--         if byteoffset then
--             text = string.sub(text, 1, byteoffset - 1)
--         end
--     end
--     if key == "return" then
--         Pass = true
--     end

-- end

-- function process(text)

--     local _, _, n1, o, n2 = string.find(text, "(%d+)([%+%-&/%*])(%d+)")

--     n1 = tonumber(n1, 10)
--     n2 = tonumber(n2, 10)
 
--     if o =="+" then return n1+n2
--     elseif o =="-" then return n1-n2
--     elseif o =="/" then return n1/n2
--     elseif o =="*" then return n1*n2
--     end

-- end

-- function love.draw()
--     love.graphics.setColor(0.15, 0.15, 0.15, 1)
--     love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)

--     if isFocused then
--         love.graphics.setColor(0.2, 0.6, 1, 1)
--     else
--         love.graphics.setColor(0.4, 0.4, 0.4, 1)
--     end
--     love.graphics.rectangle("line", box.x, box.y, box.w, box.h)

    
--     love.graphics.setScissor(box.x + 2, box.y + 2, box.w - 4, box.h - 4)

--     love.graphics.setColor(1, 1, 1, 1)
--     local padding = 10
--     local textY = box.y + (box.h - font:getHeight()) / 2
--     love.graphics.print(text, box.x + padding, textY)

--     love.graphics.setScissor()

--     if Pass then
--         love.graphics.setColor(0.34, 0.1, 1, 1)
--         love.graphics.print(text .. " = "..tostring(process(text)), 100, 100)
--     end
-- end



-- function love.load()
-- 	local img = love.graphics.newImage('image.png')

-- 	psystem = love.graphics.newParticleSystem(img, 32)
-- 	psystem:setParticleLifetime(3, 6) -- Particles live at least 2s and at most 5s.
-- 	psystem:setEmissionRate(10)
-- 	psystem:setSizeVariation(1)
--     psystem:setSpin(math.rad(0), math.rad(360))
-- 	psystem:setLinearAcceleration(-30, -20, 30, 20) -- Random movement in all directions.
-- 	psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.
-- end

-- function love.draw()
-- 	-- Draw the particle system at the center of the game window.
-- 	love.graphics.draw(psystem, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
-- end

-- function love.update(dt)
-- 	psystem:update(dt)
-- end









-- Sprites drift around like a particle system, then fly into a golden spiral
-- drawn inside a golden rectangle.  Press SPACE to replay, ESC to quit.

local phi = (1 + math.sqrt(5)) / 2

local STEPS      = 10    -- how many squares to subdivide the rectangle into
local PER_ARC    = 13    -- sprites placed on each quarter-turn of the spiral
local DRIFT_TIME = 1    -- seconds of free drifting before they gather
local GATHER_DUR = 3    -- seconds each sprite takes to reach its spot
local STAGGER    = 1.5  -- big sprites leave first, small ones up to this much later

local img, iw, ih
local squares, spiral, sprites
local clock, finishTime

local function lerp(a, b, t) return a + (b - a) * t end
local function clamp01(v) return math.max(0, math.min(1, v)) end

-- Builds the golden rectangle subdivision, the spiral polyline and the target
-- spots for the sprites. Squares are cut off left -> top -> right -> bottom,
-- and each square gets a quarter-circle arc centred on its inner corner.
local function buildGeometry(rx, ry, rw, rh)
    squares, spiral = {}, {}
    local targets = {}
    local x, y, w, h = rx, ry, rw, rh
    local pi = math.pi

    for i = 0, STEPS - 1 do
        local d = i % 4
        local s, cx, cy, a0, a1, sq

        if d == 0 then       -- square on the left
            s = h; sq = { x, y, s }
            cx, cy, a0, a1 = x + s, y + s, pi, 1.5 * pi
            x, w = x + s, w - s
        elseif d == 1 then   -- square on top
            s = w; sq = { x, y, s }
            cx, cy, a0, a1 = x, y + s, 1.5 * pi, 2 * pi
            y, h = y + s, h - s
        elseif d == 2 then   -- square on the right
            s = h; sq = { x + w - s, y, s }
            cx, cy, a0, a1 = x + w - s, y, 0, 0.5 * pi
            w = w - s
        else                 -- square on the bottom
            s = w; sq = { x, y + h - s, s }
            cx, cy, a0, a1 = x + w, y + h - s, 0.5 * pi, pi
            h = h - s
        end

        squares[#squares + 1] = sq

        -- smooth polyline for drawing the arc
        local segs = 24
        for k = 0, segs do
            local a = lerp(a0, a1, k / segs)
            spiral[#spiral + 1] = cx + s * math.cos(a)
            spiral[#spiral + 1] = cy + s * math.sin(a)
        end

        -- sprite spots along the arc, sized relative to the square
        for k = 0, PER_ARC - 1 do
            local a = lerp(a0, a1, (k + 0.5) / PER_ARC)
            targets[#targets + 1] = {
                x = cx + s * math.cos(a),
                y = cy + s * math.sin(a),
                scale = (s * 0.28) / iw,
            }
        end
    end
    return targets
end

local function reset()
    local sw, sh = love.graphics.getDimensions()

    -- golden rectangle: width = phi * height, centred in the window
    local rh = math.min(sh * 0.8, sw * 0.8 / phi)
    local rw = rh * phi
    local rx, ry = (sw - rw) / 2, (sh - rh) / 2

    local targets = buildGeometry(rx, ry, rw, rh)

    sprites = {}
    for i, t in ipairs(targets) do
        local ang, speed = math.random() * 2 * math.pi, 20 + math.random() * 40
        sprites[i] = {
            x = sw / 2, y = sh / 2,
            vx = math.cos(ang) * speed, vy = math.sin(ang) * speed,
            ax = (math.random() * 2 - 1) * 30,        -- random drift like
            ay = (math.random() * 2 - 1) * 20,        -- setLinearAcceleration
            rot = math.random() * 2 * math.pi,
            spin = (math.random() * 2 - 1) * math.pi,
            scale = (20 + math.random() * 50) / iw,   -- like setSizeVariation
            spawn = math.random() * 2,
            delay = (i - 1) / (#targets - 1) * STAGGER,
            tx = t.x, ty = t.y, tscale = t.scale,
        }
    end

    clock = 0
    finishTime = DRIFT_TIME + STAGGER + GATHER_DUR
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest") -- keep the pixel art crisp
    img = love.graphics.newImage('image.png')
    iw, ih = img:getDimensions()
    reset()
end

function love.update(dt)
    clock = clock + dt

    for _, p in ipairs(sprites) do
        local gatherStart = DRIFT_TIME + p.delay

        if clock < gatherStart then
            if clock >= p.spawn then
                p.vx, p.vy = p.vx + p.ax * dt, p.vy + p.ay * dt
                p.x, p.y = p.x + p.vx * dt, p.y + p.vy * dt
                p.rot = p.rot + p.spin * dt
            end
        else
            if not p.sx then -- remember where the flight starts
                p.sx, p.sy, p.sscale = p.x, p.y, p.scale
                p.srot = p.rot % (2 * math.pi)
            end
            local u = clamp01((clock - gatherStart) / GATHER_DUR)
            local e = u * u * (3 - 2 * u) -- smoothstep
            p.x = lerp(p.sx, p.tx, e)
            p.y = lerp(p.sy, p.ty, e)
            p.scale = lerp(p.sscale, p.tscale, e)
            p.rot = p.srot * (1 - e)      -- untwist to upright
        end
    end
end

function love.draw()
    love.graphics.clear(0.05, 0.05, 0.08)

    -- golden rectangle, its squares and the spiral fade in as sprites arrive
    local a = clamp01((clock - (finishTime - 0.5)) / 1.5)
    if a > 0 then
        love.graphics.setColor(1, 0.84, 0.3, a * 0.35)
        love.graphics.setLineWidth(1)
        for _, sq in ipairs(squares) do
            love.graphics.rectangle("line", sq[1], sq[2], sq[3], sq[3])
        end

        -- outer golden rectangle
        local s1, sN = squares[1], squares[2]
        love.graphics.setColor(1, 0.84, 0.3, a)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", s1[1], s1[2], s1[3] * phi, s1[3])

        love.graphics.setLineWidth(3)
        love.graphics.line(spiral)
    end

    -- sprites (big ones first so small ones sit on top)
    love.graphics.setLineWidth(1)
    for _, p in ipairs(sprites) do
        if clock >= p.spawn then
            local alpha = clamp01((clock - p.spawn) / 0.5)
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.draw(img, p.x, p.y, p.rot, p.scale, p.scale, iw / 2, ih / 2)
        end
    end
end

function love.keypressed(key)
    if key == "space" or key == "r" then reset() end
    if key == "escape" then love.event.quit() end
end