

function love.load()
    love.physics.setMeter(64)


    birdImg = love.graphics.newImage("birb.png")
    world = love.physics.newWorld(0, 9.81*64, true) --brave new world
    w = 1000
    h = 1000

    obj = {}

    obj.bird = {}

    obj.bird.body = love.physics.newBody(world, w/2, h/2, "dynamic")
    obj.bird.shape = love.physics.newCircleShape(52)
    obj.bird.f = love.physics.newFixture(obj.bird.body, obj.bird.shape, 0)
    obj.bird.f:setUserData("bird")

    obj.pipe = {}
    obj.pipe.width = 100
    obj.pipe.gapSize = 200
    obj.pipe.body = love.physics.newBody(world, 1100, 0, "kinematic")
    obj.pipe.body:setLinearVelocity(-200, 0)

    function resetPipe()

        if obj.pipe.topFix then obj.pipe.topFix:destroy() end
        if obj.pipe.bottomFix then obj.pipe.bottomFix:destroy() end


        obj.pipe.gapY = love.math.random(200, 800)

        obj.pipe.body:setPosition(1150, 0)

        -- Create top pipe fixture
        obj.pipe.topShape = love.physics.newRectangleShape(0, (obj.pipe.gapY - obj.pipe.gapSize/2) / 2, obj.pipe.width, obj.pipe.gapY - obj.pipe.gapSize/2)
        obj.pipe.topFix = love.physics.newFixture(obj.pipe.body, obj.pipe.topShape)
        obj.pipe.topFix:setUserData("pipe")

        local botH = h - (obj.pipe.gapY + obj.pipe.gapSize/2)
        obj.pipe.bottomShape = love.physics.newRectangleShape(0, obj.pipe.gapY + obj.pipe.gapSize/2 + botH/2, obj.pipe.width, botH)
        obj.pipe.bottomFix = love.physics.newFixture(obj.pipe.body, obj.pipe.bottomShape)
        obj.pipe.bottomFix:setUserData("pipe")
    end

    resetPipe()



    obj.groundBody = love.physics.newBody(world, w/2, h - 25, "static")
    obj.groundShape = love.physics.newRectangleShape(w, 50)
    obj.groundFix = love.physics.newFixture(obj.groundBody, obj.groundShape)
    obj.groundFix:setUserData("ground")

    local r, g, b = love.math.colorFromBytes(89, 169, 249)
    love.graphics.setBackgroundColor(r, g, b)
    love.window.setMode(w, h)
    
end


function beginContact(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()

    if (u1=="bird" and (u2 =="pipe" or u2== "ground")) or 
       (u2 == "bird" and (u1 == "pipe" or u1 == "ground")) then
        print("Game Over! The bird crashed.")
    end
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)
    
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
   
end

function love.update(dt)
    world:update(dt) 
    if love.keyboard.isDown("space") then
        obj.bird.body:setLinearVelocity(0, 0)
        obj.bird.body:applyLinearImpulse(0, -400)
    end

    local px, py = obj.pipe.body:getPosition()
    if px < -150 then
        resetPipe()
    end

    
end

function love.draw()
   
    local bx = obj.bird.body:getX()
    local by = obj.bird.body:getY()
    local angle = obj.bird.body:getAngle()
    
   
    local ox = birdImg:getWidth() / 2
    local oy = birdImg:getHeight() / 2
    
    
    local scaleX = (52 * 2) / birdImg:getWidth()
    local scaleY = (52 * 2) / birdImg:getHeight()

    love.graphics.draw(birdImg, bx, by, angle, scaleX, scaleY, ox, oy)


    love.graphics.setColor(0.1, 0.8, 0.1) 
    for _, fixture in ipairs({obj.pipe.topFix, obj.pipe.bottomFix}) do
        local shape = fixture:getShape()
        local px, py = obj.pipe.body:getPosition()
        
        love.graphics.polygon("fill", obj.pipe.body:getWorldPoints(shape:getPoints()))
    end
    love.graphics.setColor(1, 1, 1)

end