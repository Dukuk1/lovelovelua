W = 700
H = 700


BirbW, BirbH = 100, 50                -- sprite size (one place only)
HitW, HitH = BirbW * 0.8, BirbH * 0.8 -- hitbox, a bit smaller than the sprite


GapSize = 170
PipeWidth = 70
pipes = {}

SpawnTimer = 0
SpawnEvery = 3
Score = 0

function love.load()
    love.physics.setMeter(64)
    love.window.setMode(W, H)

    IMG = love.graphics.newImage("birb.png")

    world = love.physics.newWorld(0, 9.81*64, true)

    birb = {}
    birb.body = love.physics.newBody(world, W/2, H/2, "dynamic")
    birb.shape = love.physics.newRectangleShape(HitW, HitH)
    birb.fixtures = love.physics.newFixture(birb.body, birb.shape, 0.1)
    birb.fixtures:setRestitution(0.5)



function SpawnPipe()
    local margin = 60
    local gapY = love.math.random(GapSize/2 + margin, H - GapSize/2 - margin)
    local topH = gapY - GapSize/2
    local botTop = gapY + GapSize/2
    local botH = (H - 4.5) - botTop

    local p = {}
    p.body = love.physics.newBody(world, W + PipeWidth/2, 0, "kinematic")

    p.top = {}
    p.top.shape = love.physics.newRectangleShape(0, topH/2, PipeWidth, topH)
    p.top.fixture = love.physics.newFixture(p.body, p.top.shape)

    p.bot = {}
    p.bot.shape = love.physics.newRectangleShape(0, botTop + botH/2, PipeWidth, botH)
    p.bot.fixture = love.physics.newFixture(p.body, p.bot.shape)

    p.body:setLinearVelocity(-80, 0)
    table.insert(pipes, p)
end
SpawnPipe()




    ground = {}
    ground.body = love.physics.newBody(world, W/2, H, "static")
    ground.shape = love.physics.newRectangleShape(W, 9)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)



end

function restart()
    birb.body:setLinearVelocity(0,0)
    birb.body:setPosition(W/2, H/2)
    for i = #pipes, 1, -1 do
        local p = pipes[i]
            p.body:destroy()
            table.remove(pipes, i)
    end
    SpawnPipe()
    
end


function moveBirb()
    birb.body:setLinearVelocity(0, 0)
    birb.body:applyLinearImpulse(0, -30)
end

function love.keypressed(key)
    if key == 'space' then
        moveBirb()
    end
    if key == 'escape' then
        restart()
    end

end


function love.update(dt)
    SpawnTimer = SpawnTimer + dt

    if SpawnTimer >= SpawnEvery then
        SpawnTimer = SpawnTimer - SpawnEvery
        SpawnPipe()
    end

    for i = #pipes, 1, -1 do
        local p = pipes[i]
        if p.body:getX() < -PipeWidth then
            p.body:destroy()
            table.remove(pipes, i)
        end
    end


world:update(dt)

end



function love.draw()

    love.graphics.setBackgroundColor(love.math.colorFromBytes(99, 155, 255))


    local sx = BirbW / IMG:getWidth()
    local sy = BirbH / IMG:getHeight()


    love.graphics.setColor(1,1,1)

    love.graphics.draw(IMG, birb.body:getX(), birb.body:getY(), birb.body:getAngle(),
                   sx, sy, IMG:getWidth()/2, IMG:getHeight()/2)


    love.graphics.setColor(love.math.colorFromBytes(106, 190, 48))
    for _, p in ipairs(pipes) do
        love.graphics.polygon("fill", p.body:getWorldPoints(p.top.shape:getPoints()))
        love.graphics.polygon("fill", p.body:getWorldPoints(p.bot.shape:getPoints()))

        end


    love.graphics.setColor(love.math.colorFromBytes(1,1,1))

end