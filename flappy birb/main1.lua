
W = 500
H = 500
Jump = false

function love.load()
    love.physics.setMeter(64)
    img = love.graphics.newImage("birb.png")
    world = love.physics.newWorld(0, 9.81*64, true)

    Birb = {}
    Birb.pos = {x = 100, y = 100}
    Birb.body = love.physics.newBody(world, Birb.pos.x, Birb.pos.y, "dynamic")
    Birb.shape = love.physics.newCircleShape(21)
    Birb.fix = love.physics.newFixture(Birb.body, Birb.shape, 0)


    love.window.setMode(W, H)
end

function love.keypressed(key)
    if key == "space" then
        Jump = true
    end
    
end

function love.update(dt)
    world:update(dt)
    if Jump then
            Birb.body:setLinearVelocity(0, 0)
            Birb.body:applyLinearImpulse(0, -300)
            Jump = false
       end
    end


function love.draw()
    local bx = Birb.body:getX()
    local by = Birb.body:getY()
    local angle = Birb.body:getAngle()
    
   
    local ox = img:getWidth() / 2
    local oy = img:getHeight() / 2

    
    local scaleX = (21 * 2) / img:getWidth()
    local scaleY = (21 * 2) / img:getHeight()

    love.graphics.draw(img, bx, by, angle, scaleX, scaleY, ox, oy)

    love.graphics.print(Birb.body:getX(), 0, 200)
    love.graphics.print(Birb.body:getY(), 0, 300)

    
end