-- Flappy Birb (no love.physics) for LÖVE 11.x

local W, H = 700, 700
local GROUND_H = 40
local GROUND_Y = H - GROUND_H

-- Tunables
local GRAVITY       = 1400   -- px/s^2
local FLAP_SPEED    = -420   -- px/s (negative = up)
local PIPE_W        = 70
local PIPE_SPEED    = 180    -- px/s
local GAP_SIZE      = 170
local SPAWN_EVERY   = 1.5    -- seconds
local GAP_MARGIN    = 60     -- min distance between gap edge and ceiling/ground

local birb, pipes, timer, score, best, state, img

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------

-- Circle vs axis-aligned rectangle
local function circleHitsRect(cx, cy, r, rx, ry, rw, rh)
    local nx = math.max(rx, math.min(cx, rx + rw))
    local ny = math.max(ry, math.min(cy, ry + rh))
    local dx, dy = cx - nx, cy - ny
    return dx * dx + dy * dy <= r * r
end

local function spawnPipe()
    local minY = GAP_MARGIN + GAP_SIZE / 2
    local maxY = GROUND_Y - GAP_MARGIN - GAP_SIZE / 2
    table.insert(pipes, {
        x = W,
        gapY = love.math.random(minY, maxY), -- center of the gap
        scored = false,
    })
end

local function reset()
    birb = { x = 160, y = H / 2, vy = 0, r = 14 }
    pipes = {}
    timer = 0
    score = 0
    state = "ready"   -- "ready" -> "play" -> "dead"
end

local function flap()
    if state == "ready" then
        state = "play"
    end
    if state == "play" then
        birb.vy = FLAP_SPEED
    elseif state == "dead" then
        reset()
    end
end

---------------------------------------------------------------------
-- LÖVE callbacks
---------------------------------------------------------------------

function love.load()
    love.window.setMode(W, H)
    love.window.setTitle("Flappy Birb")
    love.graphics.setBackgroundColor(love.math.colorFromBytes(99, 155, 255))

    -- Use birb.png if it exists, otherwise draw a yellow circle
    if love.filesystem.getInfo("birb.png") then
        img = love.graphics.newImage("birb.png")
    end

    best = 0
    reset()
end

function love.keypressed(key)
    if key == "space" then
        flap()
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed()
    flap()
end

function love.update(dt)
    if state ~= "play" then return end

    -- Birb movement
    birb.vy = birb.vy + GRAVITY * dt
    birb.y = birb.y + birb.vy * dt

    -- Ceiling clamp
    if birb.y - birb.r < 0 then
        birb.y = birb.r
        birb.vy = 0
    end

    -- Spawn pipes on a timer
    timer = timer + dt
    if timer >= SPAWN_EVERY then
        timer = timer - SPAWN_EVERY
        spawnPipe()
    end

    -- Move pipes, score, collide, cull (iterate backwards so removal is safe)
    for i = #pipes, 1, -1 do
        local p = pipes[i]
        p.x = p.x - PIPE_SPEED * dt

        -- Score once when the pipe passes the birb
        if not p.scored and p.x + PIPE_W < birb.x then
            p.scored = true
            score = score + 1
            if score > best then best = score end
        end

        -- Top and bottom rectangles
        local gapTop = p.gapY - GAP_SIZE / 2
        local gapBottom = p.gapY + GAP_SIZE / 2

        if circleHitsRect(birb.x, birb.y, birb.r, p.x, 0, PIPE_W, gapTop)
        or circleHitsRect(birb.x, birb.y, birb.r, p.x, gapBottom, PIPE_W, GROUND_Y - gapBottom) then
            state = "dead"
        end

        -- Off-screen: remove
        if p.x + PIPE_W < 0 then
            table.remove(pipes, i)
        end
    end

    -- Ground collision
    if birb.y + birb.r >= GROUND_Y then
        birb.y = GROUND_Y - birb.r
        state = "dead"
    end
end

function love.draw()
    -- Pipes
    love.graphics.setColor(love.math.colorFromBytes(106, 190, 48))
    for _, p in ipairs(pipes) do
        local gapTop = p.gapY - GAP_SIZE / 2
        local gapBottom = p.gapY + GAP_SIZE / 2
        love.graphics.rectangle("fill", p.x, 0, PIPE_W, gapTop)
        love.graphics.rectangle("fill", p.x, gapBottom, PIPE_W, GROUND_Y - gapBottom)
    end

    -- Ground
    love.graphics.setColor(love.math.colorFromBytes(222, 184, 135))
    love.graphics.rectangle("fill", 0, GROUND_Y, W, GROUND_H)

    -- Birb (tilt based on vertical speed)
    love.graphics.setColor(1, 1, 1)
    local angle = math.max(-0.5, math.min(1.2, birb.vy / 600))
    if img then
        local sw, sh = birb.r * 3.4, birb.r * 2.4
        love.graphics.draw(img, birb.x, birb.y, angle,
            sw / img:getWidth(), sh / img:getHeight(),
            img:getWidth() / 2, img:getHeight() / 2)
    else
        love.graphics.setColor(1, 0.85, 0.2)
        love.graphics.circle("fill", birb.x, birb.y, birb.r)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", birb.x + 5, birb.y - 4, 2.5)
    end

    -- UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(tostring(score), 0, 30, W, "center")
    love.graphics.printf("Best: " .. best, 0, 60, W, "center")

    if state == "ready" then
        love.graphics.printf("Press SPACE or click to flap", 0, H / 2 + 60, W, "center")
    elseif state == "dead" then
        love.graphics.printf("Game over! Press SPACE or click to restart", 0, H / 2 + 60, W, "center")
    end
end