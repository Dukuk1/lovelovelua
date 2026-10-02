






local img, pos


function love.load(args)

   img = love.graphics.newImage("img1.jpg")
   img2 = love.graphics.newImage("img2.jpg")


   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 9.81*64, true) --brave new world
   world:setCallbacks(beginContact, endContact, preSolve, postSolve)
   w = 1300
   h = 1300
   pos = {
       x = 50,
       y = 50,
   }

   objects = {} 
  
   objects.ground = {} 
   objects.ground.body = love.physics.newBody(world, w/2, h-50/2)
   objects.ground.shape = love.physics.newRectangleShape(w, 50) 
   objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) 
   
   objects.ball = {}
   objects.ball.body = love.physics.newBody(world, w/2, h/2, "dynamic") 
   objects.ball.shape = love.physics.newCircleShape( 20) 
   objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1)
   objects.ball.fixture:setRestitution(0.9) --bouncy bouncy
   objects.ball.fixture:setUserData("ball")

 
   objects.block1 = {}
   objects.block1.body = love.physics.newBody(world, 200, 550, "dynamic")
   objects.block1.shape = love.physics.newRectangleShape(0, 0, 50, 100)
   objects.block1.fixture = love.physics.newFixture(objects.block1.body, objects.block1.shape, 1) 
   objects.block1.fixture:setRestitution(0.8)
   objects.block1.fixture:setFriction(0.7)
   objects.block1.fixture:setUserData("neco")

 
   objects.block2 = {}
   objects.block2.body = love.physics.newBody(world, 200, 400, "dynamic")
   objects.block2.shape = love.physics.newRectangleShape(0, 0, 100, 50)
   objects.block2.fixture = love.physics.newFixture(objects.block2.body, objects.block2.shape, 2)
   objects.block2.fixture:setRestitution(0.8)
   objects.block2.fixture:setFriction(0.7)

   objects.wall1 = {}
   objects.wall1.body = love.physics.newBody(world, 0, h/2)
   objects.wall1.shape = love.physics.newRectangleShape(1, h)
   objects.wall1.fixture = love.physics.newFixture(objects.wall1.body, objects.wall1.shape)

   objects.wall2 = {}
   objects.wall2.body = love.physics.newBody(world, w, h/2)
   objects.wall2.shape = love.physics.newRectangleShape(1, h)
   objects.wall2.fixture = love.physics.newFixture(objects.wall2.body, objects.wall2.shape)

   objects.ceiling = {} 
   objects.ceiling.body = love.physics.newBody(world, w/2, 1) 
   objects.ceiling.shape = love.physics.newRectangleShape(w, 1) 
   objects.ceiling.fixture = love.physics.newFixture(objects.ceiling.body, objects.ceiling.shape) 
   

   love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
   love.window.setMode(w, h)


   dummy = {}
   dummy.obj = {}
  for i = 1, 5, 1 do
    local block = {}
    block.body = love.physics.newBody(world, w / 2, 550 - (i * 60), "dynamic")
    block.shape = love.physics.newRectangleShape(50, 100)
    block.fixture = love.physics.newFixture(block.body, block.shape, 1)
    block.fixture:setRestitution(0.8)
    block.fixture:setFriction(0.7)
    table.insert(dummy.obj, block)
  end

  Text = " "
end

function is_position_inside_area(position, area)
	local x,y = position.x,position.y
	local x1, x2 = area.x, area.x+area.width
	local y1, y2 = area.y, area.y+area.height
--	return (x1<x)and(x<x2)and(y1<y)and(y<y2) and true or false
	return (x1<x)and(x<x2)and(y1<y)and(y<y2)
end

function beginContact(a, b, coll)
  x,y = coll:getNormal()
  Text = Text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
  
	
end

function endContact(a, b, coll)
	
end

function preSolve(a, b, coll)
	
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
	
end

function love.update(dt)
        world:update(dt) 
        
        if love.keyboard.isDown("right") then 
          objects.ball.body:applyForce(400, 0)

        elseif love.keyboard.isDown("left") then 
          objects.ball.body:applyForce(-400, 0)

        elseif love.keyboard.isDown("up") then
            objects.ball.body:applyForce(0, -400)

        elseif love.keyboard.isDown("space") then 
          objects.ball.body:setPosition(650/2, 650/2)
          objects.ball.body:setLinearVelocity(0, 0)
          objects.block1.body:setPosition(200, 550)
          objects.block2.body:setPosition(200, 400)
          for _, block in ipairs(dummy.obj) do
            block.body:setPosition(love.math.random(2, w), love.math.random(2, h))
        end

        elseif love.keyboard.isDown("down") then
            local ang = math.deg(objects.block1.body:getAngle()) + 10
            objects.block1.body:setAngle(math.rad(ang))

          elseif love.mouse.isDown(1) then
            local minx, miny, maxx, maxy = objects.block1.fixture:getBoundingBox()
            local blockArea = {
            x = minx,
            y = miny,
            width = maxx - minx,
            height = maxy - miny
        }

        if is_position_inside_area({x = xm, y = ym}, blockArea) then
            objects.block1.body:setPosition(xm, ym)
            objects.block1.body:setLinearVelocity(0, 0)
            end

          end
        
        end



function love.draw()

    xm = love.mouse.getX()
    ym = love.mouse.getY()

    local s = string.format("x = %d \n y = %d", xm, ym)
    love.graphics.print(s, pos.x, pos.y)

    love.graphics.setColor(0.28, 0.63, 0.05) 
    love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))

    love.graphics.setColor(0.76, 0.18, 0.05)
  love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())


  love.graphics.setColor(0.20, 0.20, 0.20) 
  -- love.graphics.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
  love.graphics.polygon("fill", objects.block2.body:getWorldPoints(objects.block2.shape:getPoints()))

  bx1, by1, bx2, by2 = objects.block1.fixture:getBoundingBox()

  bw = math.abs(bx1-bx2)
  bh = math.abs(by1-by2)

  love.graphics.push()
    love.graphics.translate(objects.block1.body:getX(), objects.block1.body:getY())
    love.graphics.rotate(objects.block1.body:getAngle())
    love.graphics.draw(img2, 0, 0, 0, bw / w, bh / h, w/2, h/2)
    love.graphics.pop()

  local c = string.format("X: %d\nY: %d", objects.block1.body:getX(), objects.block1.body:getY())
  love.graphics.print(c)
  local c1 = string.format("X1: %d\nY1: %d\nX2: %d\nY2: %d", objects.block1.fixture:getBoundingBox())
  love.graphics.print(c1, 100, 100)

  love.graphics.setColor(0.29, 0.10, 0.70) -- set the drawing color to grey for the blocks
  love.graphics.polygon("fill", objects.wall1.body:getWorldPoints(objects.wall1.shape:getPoints()))
  love.graphics.polygon("fill", objects.wall2.body:getWorldPoints(objects.wall2.shape:getPoints()))

  love.graphics.setColor(0.30, 0.40, 0.40)


  for _, block in ipairs(dummy.obj) do
      love.graphics.polygon("fill", block.body:getWorldPoints(block.shape:getPoints()))
  end

  love.graphics.print(Text, 10, 10)
  
end