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




function love.load()
	local img = love.graphics.newImage('image.png')

	psystem = love.graphics.newParticleSystem(img, 32)
	psystem:setParticleLifetime(3, 6) -- Particles live at least 2s and at most 5s.
	psystem:setEmissionRate(10)
	psystem:setSizeVariation(1)
    psystem:setSpin(math.rad(0), math.rad(360))
	psystem:setLinearAcceleration(-30, -20, 30, 20) -- Random movement in all directions.
	psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.
end

function love.draw()
	-- Draw the particle system at the center of the game window.
	love.graphics.draw(psystem, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
end

function love.update(dt)
	psystem:update(dt)
end