-- LÖVE 11.x : Physics joint showcase (self-running, GIF friendly)
--
-- Every demo animates by itself - no input needed.
--   R      reset everything
--   SPACE  pause
--   F      start/stop frame recording (PNG frames -> <save dir>/frames, 30 fps)
--   ESC    quit
-- (You can still drag any body with the mouse.)

local SCALE   = 1      -- window scale factor (use 0.75 if 1280x912 is too big for your screen)

local CELL_W  = 320
local PHYS_H  = 240    -- physics area height of each cell
local HEADER  = 48     -- title strip above the physics area
local CELL_TH = HEADER + PHYS_H
local COLS, ROWS = 4, 3
local METER   = 64
local STEP    = 1 / 60

local world, mouseJoint
local active = {}
local acc, time, paused = 0, 0, false
local recording, frameNo = false, 0
local fontBig, fontTitle, fontText

-- LÖVE scales forces by the meter size internally (force / METER), so a "1000 N per kg"
-- force has to be multiplied by METER to actually behave like 1000 m/s^2.
local function grabForce(body) return 1000 * body:getMass() * METER end

local C = {
  blue   = {0.30, 0.55, 0.95}, orange = {0.98, 0.60, 0.25},
  green  = {0.40, 0.80, 0.50}, pink   = {0.95, 0.45, 0.65},
  purple = {0.65, 0.50, 0.95}, yellow = {0.95, 0.85, 0.35},
  teal   = {0.30, 0.80, 0.80}, gray   = {0.60, 0.62, 0.68},
}

----------------------------------------------------------------------
-- Helper class: builds bodies in cell-local coordinates and keeps the
-- cells isolated from each other (collision categories + masks).
----------------------------------------------------------------------
local Demo = {}
Demo.__index = Demo

function Demo:pt(x, y) return self.ox + x, self.oy + y end

function Demo:tag(fixture)
  fixture:setCategory(self.id)
  local others = {}
  for i = 1, 16 do if i ~= self.id then others[#others + 1] = i end end
  fixture:setMask(unpack(others))
end

function Demo:body(x, y, kind, color)
  local b = love.physics.newBody(world, self.ox + x, self.oy + y, kind or "dynamic")
  b:setUserData({ color = color or C.gray })
  self.bodies[#self.bodies + 1] = b
  return b
end

function Demo:box(x, y, w, h, kind, color, density)
  local b = self:body(x, y, kind, color)
  local f = love.physics.newFixture(b, love.physics.newRectangleShape(w, h), density or 1)
  self:tag(f)
  return b, f
end

function Demo:circle(x, y, r, kind, color, density)
  local b = self:body(x, y, kind, color)
  local f = love.physics.newFixture(b, love.physics.newCircleShape(r), density or 1)
  self:tag(f)
  return b, f
end

-- fixture-less static body: the "ground" end of a joint
function Demo:anchor(x, y) return self:body(x, y, "static", C.gray) end

function Demo:walls()
  local b = self:body(0, 0, "static", C.gray)
  local m = 3
  local f = love.physics.newFixture(b, love.physics.newChainShape(true,
    m, m, CELL_W - m, m, CELL_W - m, PHYS_H - m, m, PHYS_H - m))
  f:setFriction(0.8)
  self:tag(f)
end

-- (Re)start this demo from its initial state
function Demo:start()
  for _, b in ipairs(self.bodies or {}) do
    if not b:isDestroyed() then b:destroy() end -- also destroys attached joints
  end
  self.bodies, self.update, self.cursor = {}, nil, nil
  self.t0 = time
  if self.def.setup then
    self:walls()
    self.def.setup(self)
  end
end

----------------------------------------------------------------------
-- The demos.  d.update(t) gets the demo-local time (seconds since start).
-- def.period = restart the demo every N seconds (omit for endless demos)
----------------------------------------------------------------------
local demos = {}

-- 1 ---------------------------------------------------------------
demos[1] = { name = "Distance Joint", period = 8,
  setup = function(d)
    local a = d:anchor(80, 45)
    local b = d:box(135, 95, 36, 36, "dynamic", C.orange)
    local j = love.physics.newDistanceJoint(a, b, a:getX(), a:getY(), b:getX(), b:getY(), false)
    j:setLength(110)
    j:setFrequency(1.5)
    j:setDampingRatio(0.05)

    local a2 = d:anchor(235, 45)
    local b2 = d:circle(285, 95, 14, "dynamic", C.blue)
    love.physics.newDistanceJoint(a2, b2, a2:getX(), a2:getY(), b2:getX(), b2:getY(), false)
  end }

-- 2 ---------------------------------------------------------------
demos[2] = { name = "Revolute Joint", period = 7,
  setup = function(d)
    local a = d:anchor(90, 55)
    local bar = d:box(140, 55, 100, 12, "dynamic", C.green)
    local j = love.physics.newRevoluteJoint(a, bar, a:getX(), a:getY(), false)
    j:setLimitsEnabled(true)
    j:setLimits(-0.6, 1.8)

    local a2 = d:anchor(240, 150)
    local paddle = d:box(240, 150, 80, 10, "dynamic", C.pink)
    local j2 = love.physics.newRevoluteJoint(a2, paddle, a2:getX(), a2:getY(), false)
    j2:setMotorEnabled(true)
    j2:setMotorSpeed(2.5)
    j2:setMaxMotorTorque(1000)
  end }

-- 3 ---------------------------------------------------------------
demos[3] = { name = "Prismatic Joint",
  setup = function(d)
    local g = d:anchor(190, 60)
    local slider = d:box(190, 60, 50, 28, "dynamic", C.green)
    local ax, ay = g:getPosition()
    local j = love.physics.newPrismaticJoint(g, slider, ax, ay, 1, 0, false)
    j:setLimitsEnabled(true)
    j:setLimits(-95, 95)
    j:setMotorEnabled(true)
    j:setMaxMotorForce(500)
    j:setMotorSpeed(80)

    local g2 = d:anchor(40, 110)
    local piston = d:box(40, 110, 28, 28, "dynamic", C.yellow)
    local bx, by = piston:getPosition()
    local j2 = love.physics.newPrismaticJoint(g2, piston, bx, by, 0, 1, false)
    j2:setLimitsEnabled(true)
    j2:setLimits(-40, 90)
    j2:setMaxMotorForce(25 * METER)

    d.update = function(t)
      local tr = j:getJointTranslation()
      if tr > 90 then j:setMotorSpeed(-80) elseif tr < -90 then j:setMotorSpeed(80) end
      if math.floor(t / 3) % 2 == 0 then
        j2:setMotorEnabled(false)         -- falls under gravity
      else
        j2:setMotorEnabled(true)          -- motor lifts it
        j2:setMotorSpeed(-60)
      end
    end
  end }

-- 4 ---------------------------------------------------------------
demos[4] = { name = "Weld Joint", period = 4.5,
  setup = function(d)
    local prev, px = d:anchor(30, 120), 30
    for i = 1, 3 do
      local seg = d:box(px + 30, 120, 60, 20, "dynamic", C.purple)
      local j = love.physics.newWeldJoint(prev, seg, d.ox + px, d.oy + 120, false)
      j:setFrequency(5)
      j:setDampingRatio(0.3)
      prev, px = seg, px + 60
    end
    local _, f = d:circle(105, 30, 12, "dynamic", C.orange, 3)
    f:setRestitution(0.5)
  end }

-- 5 ---------------------------------------------------------------
demos[5] = { name = "Wheel Joint", period = 14,
  setup = function(d)
    for _, bx in ipairs({ 120, 200 }) do
      local b = d:body(bx, PHYS_H - 3, "static", C.gray)
      local f = love.physics.newFixture(b, love.physics.newPolygonShape(-25, 0, 0, -13, 25, 0))
      d:tag(f)
    end

    local chassis = d:box(100, 160, 90, 22, "dynamic", C.blue)
    local joints = {}
    for _, wx in ipairs({ 70, 130 }) do
      local w, f = d:circle(wx, 185, 14, "dynamic", C.orange, 1.2)
      f:setFriction(1.2)
      local ax, ay = w:getPosition()
      local j = love.physics.newWheelJoint(chassis, w, ax, ay, 0, 1, false)
      j:setSpringFrequency(4)
      j:setSpringDampingRatio(0.5)
      j:setMotorEnabled(true)
      j:setMaxMotorTorque(40)
      j:setMotorSpeed(12)
      joints[#joints + 1] = j
    end

    local dir = 1
    d.update = function()
      local x = chassis:getX() - d.ox
      if x > 265 then dir = -1 elseif x < 55 then dir = 1 end
      for _, j in ipairs(joints) do j:setMotorSpeed(dir * 12) end
    end
  end }

-- 6 ---------------------------------------------------------------
demos[6] = { name = "Rope Joint", period = 5,
  setup = function(d)
    local a = d:anchor(90, 30)
    local ball, f = d:circle(55, 90, 14, "dynamic", C.orange)
    f:setRestitution(0.4)
    local ax, ay = a:getPosition()
    local bx, by = ball:getPosition()
    love.physics.newRopeJoint(a, ball, ax, ay, bx, by, 80, false)
    ball:setLinearVelocity(240, -120)

    local a2 = d:anchor(240, 30)
    local crate = d:box(250, 70, 30, 30, "dynamic", C.teal)
    local cx, cy = crate:getPosition()
    ax, ay = a2:getPosition()
    love.physics.newRopeJoint(a2, crate, ax, ay, cx, cy, 80, false)
    crate:setLinearVelocity(-120, -150)
  end }

-- 7 ---------------------------------------------------------------
demos[7] = { name = "Pulley Joint",
  setup = function(d)
    local HALF = 18 -- half the block size; the rope is tied to the TOP of each block

    -- ledges the blocks come to rest on (keeps both blocks away from the pulleys)
    for _, lx in ipairs({ 110, 210 }) do
      local _, f = d:box(lx, 200, 70, 10, "static", C.gray)
      f:setFriction(0.5)
    end

    local A, fA = d:box(110, 130, 36, 36, "dynamic", C.pink, 3)
    local B, fB = d:box(210, 130, 36, 36, "dynamic", C.blue, 1)
    for _, b in ipairs({ A, B }) do
      b:setFixedRotation(true)   -- stay upright
      b:setLinearDamping(0.3)    -- calm any sideways swinging
      b:setSleepingAllowed(false) -- changing density does NOT wake a sleeping body
    end

    local g1x, g1y = d:pt(110, 25)
    local g2x, g2y = d:pt(210, 25)
    love.physics.newPulleyJoint(A, B, g1x, g1y, g2x, g2y,
      A:getX(), A:getY() - HALF, B:getX(), B:getY() - HALF, 1, false)

    -- Swap which block is heavy so the demo keeps running forever.
    -- (Density is changed on the fixture, then the body's mass is recomputed.)
    local phase = 0
    d.update = function(t)
      local p = math.floor(t / 2) % 2
      if p ~= phase then
        phase = p
        fA:setDensity(p == 0 and 3 or 1)
        fB:setDensity(p == 0 and 1 or 3)
        A:resetMassData(); B:resetMassData()
        A:setAwake(true); B:setAwake(true)
        A:getUserData().color = p == 0 and C.pink or C.blue
        B:getUserData().color = p == 0 and C.blue or C.pink
      end
    end
  end }

-- 8 ---------------------------------------------------------------
demos[8] = { name = "Gear Joint",
  setup = function(d)
    local r1, r2 = 50, 28
    local g1 = d:anchor(95, 120)
    local g2 = d:anchor(95 + r1 + r2, 120)
    local w1, f1 = d:circle(95, 120, r1, "dynamic", C.yellow)
    local w2, f2 = d:circle(95 + r1 + r2, 120, r2, "dynamic", C.purple)
    f1:setSensor(true); f2:setSensor(true) -- the wheels touch; keep them from colliding

    local j1 = love.physics.newRevoluteJoint(g1, w1, g1:getX(), g1:getY(), false)
    local j2 = love.physics.newRevoluteJoint(g2, w2, g2:getX(), g2:getY(), false)
    j1:setMotorEnabled(true)
    j1:setMotorSpeed(1.5)
    j1:setMaxMotorTorque(500)

    -- angle1 + ratio * angle2 = const  ->  ratio = r2 / r1 for meshing gears
    love.physics.newGearJoint(j1, j2, r2 / r1, false)
  end }

-- 9 ---------------------------------------------------------------
demos[9] = { name = "Friction Joint",
  setup = function(d)
    local ground = d:anchor(160, 120)
    local box, f = d:box(160, 120, 50, 30, "dynamic", C.teal)
    f:setRestitution(0.3)
    box:setGravityScale(0) -- we are looking down from above
    local j = love.physics.newFrictionJoint(ground, box, ground:getX(), ground:getY(), false)
    j:setMaxForce(0.4)
    j:setMaxTorque(0.04)
    box:setLinearVelocity(200, 120)
    box:setAngularVelocity(4)

    d.update = function()
      local vx, vy = box:getLinearVelocity()
      if vx * vx + vy * vy < 100 and math.abs(box:getAngularVelocity()) < 0.2 then
        local a = math.random() * math.pi * 2
        box:setLinearVelocity(math.cos(a) * 260, math.sin(a) * 260)
        box:setAngularVelocity((math.random() - 0.5) * 8)
      end
    end
  end }

-- 10 --------------------------------------------------------------
demos[10] = { name = "Motor Joint",
  setup = function(d)
    local ground = d:anchor(160, 120)
    local box = d:box(160, 120, 60, 30, "dynamic", C.orange)
    local j = love.physics.newMotorJoint(ground, box, 0.3, false)
    j:setMaxForce(300 * METER)
    j:setMaxTorque(50 * METER)

    d.update = function(t)
      j:setLinearOffset(math.cos(t) * 95, math.sin(t * 2) * 55)
      j:setAngularOffset(math.sin(t) * 1.0)
    end
  end }

-- 11 --------------------------------------------------------------
demos[11] = { name = "Mouse Joint",
  setup = function(d)
    local list = {}
    local cols = { C.blue, C.pink, C.green, C.yellow, C.purple }
    for i = 1, 5 do
      local b, f
      if i % 2 == 0 then
        b, f = d:circle(40 + i * 42, 190, 16, "dynamic", cols[i], 0.4)
      else
        b, f = d:box(40 + i * 42, 190, 34, 34, "dynamic", cols[i], 0.4)
      end
      f:setRestitution(0.4)
      b:setSleepingAllowed(false)
      list[#list + 1] = b
    end

    local CYCLE, DRAG = 2.2, 1.0
    local cycle, grab, sx, sy, gx, gy = -1
    d.update = function(t)
      local c = math.floor(t / CYCLE)
      local u = (t % CYCLE) / DRAG
      if c ~= cycle then                       -- pick the next body and "click" it
        cycle = c
        local b = list[c % #list + 1]
        sx, sy = b:getPosition()
        gx = d.ox + 160 + 110 * math.sin(c * 2.3 + 1)
        gy = d.oy + 70
        grab = love.physics.newMouseJoint(b, sx, sy)
        grab:setMaxForce(grabForce(b))
        b:setAwake(true)
      end
      if grab and not grab:isDestroyed() then
        if u < 1 then                          -- accelerate toward the goal, then let go = fling
          local s = u * u
          local tx, ty = sx + (gx - sx) * s, sy + (gy - sy) * s
          grab:setTarget(tx, ty)
          d.cursor = { x = tx, y = ty }
        else
          grab:destroy()
          grab, d.cursor = nil, nil
        end
      end
    end
  end }

-- 12 (title card, no physics) -------------------------------------
demos[12] = { name = "title", info = true }

----------------------------------------------------------------------
-- World construction
----------------------------------------------------------------------
local function build()
  if world then world:destroy() end
  mouseJoint = nil
  active = {}
  acc, time = 0, 0
  world = love.physics.newWorld(0, 9.81 * METER, true)

  for i, def in ipairs(demos) do
    local col, row = (i - 1) % COLS, math.floor((i - 1) / COLS)
    local d = setmetatable({
      id = i, def = def, name = def.name, info = def.info,
      period = def.period, bodies = {}, t0 = 0,
      cx = col * CELL_W, cy = row * CELL_TH,           -- whole cell
      ox = col * CELL_W, oy = row * CELL_TH + HEADER,  -- physics area
    }, Demo)
    active[i] = d
    d:start()
  end
end

function love.load()
  love.window.setTitle("LÖVE2D - Physics Joints Showcase")
  love.window.setMode(CELL_W * COLS * SCALE, CELL_TH * ROWS * SCALE)
  love.physics.setMeter(METER)
  fontBig = love.graphics.newFont(26)
  fontTitle = love.graphics.newFont(26)
  fontText = love.graphics.newFont(10)
  love.filesystem.createDirectory("frames")
  math.randomseed(os.time())
  build()
end

----------------------------------------------------------------------
-- Update
----------------------------------------------------------------------
local function stepPhysics()
  time = time + STEP
  for _, d in ipairs(active) do
    if d.period and time - d.t0 >= d.period then d:start() end
    if d.update then d.update(time - d.t0) end
  end
  world:update(STEP)
end

function love.update(dt)
  if not paused then
    if recording then
      stepPhysics(); stepPhysics()      -- 2 physics steps per frame = 30 fps real-time capture
    else
      acc = acc + math.min(dt, 0.05)
      while acc >= STEP do
        stepPhysics()
        acc = acc - STEP
      end
    end
  end
  if mouseJoint and mouseJoint:isDestroyed() then mouseJoint = nil end
  if mouseJoint then
    local mx, my = love.mouse.getPosition()
    mouseJoint:setTarget(mx / SCALE, my / SCALE)
  end
end

----------------------------------------------------------------------
-- Input
----------------------------------------------------------------------
function love.mousepressed(x, y, button)
  if button ~= 1 or mouseJoint then return end
  x, y = x / SCALE, y / SCALE
  for _, b in ipairs(world:getBodies()) do
    if b:getType() == "dynamic" then
      for _, f in ipairs(b:getFixtures()) do
        if f:testPoint(x, y) then
          mouseJoint = love.physics.newMouseJoint(b, x, y)
          mouseJoint:setMaxForce(grabForce(b))
          b:setAwake(true)
          return
        end
      end
    end
  end
end

function love.mousereleased(_, _, button)
  if button == 1 and mouseJoint then
    if not mouseJoint:isDestroyed() then mouseJoint:destroy() end
    mouseJoint = nil
  end
end

function love.keypressed(key)
  if key == "r" then build()
  elseif key == "space" then paused = not paused
  elseif key == "f" then
    recording = not recording
    if recording then frameNo = 1 end
  elseif key == "escape" then love.event.quit() end
end

----------------------------------------------------------------------
-- Drawing
----------------------------------------------------------------------
local function drawFixture(body, fixture, color)
  local shape = fixture:getShape()
  local t = shape:getType()

  if t == "circle" then
    local x, y = body:getWorldPoint(shape:getPoint())
    local r, a = shape:getRadius(), body:getAngle()
    love.graphics.setColor(color[1], color[2], color[3], 0.85)
    love.graphics.circle("fill", x, y, r)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.circle("line", x, y, r)
    love.graphics.line(x, y, x + math.cos(a) * r, y + math.sin(a) * r) -- shows rotation

  elseif t == "polygon" then
    local pts = { body:getWorldPoints(shape:getPoints()) }
    love.graphics.setColor(color[1], color[2], color[3], 0.85)
    love.graphics.polygon("fill", pts)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.polygon("line", pts)

  else -- edge / chain
    local pts = { body:getWorldPoints(shape:getPoints()) }
    love.graphics.setColor(0.55, 0.58, 0.68)
    love.graphics.setLineWidth(2)
    if #pts >= 4 then love.graphics.line(pts) end
    if t == "chain" and #pts >= 6 then
      love.graphics.line(pts[#pts - 1], pts[#pts], pts[1], pts[2])
    end
  end
end

local function dot(x, y) love.graphics.circle("fill", x, y, 3) end

local function drawJoint(j)
  local t = j:getType()
  love.graphics.setLineWidth(2)
  love.graphics.setColor(1, 1, 1, 0.9)

  if t == "pulley" then
    local gx1, gy1, gx2, gy2 = j:getGroundAnchors()
    local x1, y1, x2, y2 = j:getAnchors()
    love.graphics.line(x1, y1, gx1, gy1, gx2, gy2, x2, y2)
    love.graphics.circle("line", gx1, gy1, 6)
    love.graphics.circle("line", gx2, gy2, 6)

  elseif t == "gear" then
    local a, b = j:getBodies()
    love.graphics.setColor(1, 1, 1, 0.35)
    love.graphics.line(a:getX(), a:getY(), b:getX(), b:getY())

  elseif t == "motor" then
    local a = j:getBodies()
    local lx, ly = j:getLinearOffset()
    local gx, gy = a:getWorldPoint(lx, ly)
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.circle("line", gx, gy, 7)
    love.graphics.line(a:getX(), a:getY(), gx, gy)

  elseif t == "prismatic" then
    local x1, y1, x2, y2 = j:getAnchors()
    local ax, ay = j:getAxis()
    local lo, hi = j:getLowerLimit(), j:getUpperLimit()
    love.graphics.setColor(1, 1, 1, 0.35)
    love.graphics.line(x1 + ax * lo, y1 + ay * lo, x1 + ax * hi, y1 + ay * hi)
    love.graphics.setColor(1, 1, 1, 0.9)
    dot(x2, y2)

  elseif t == "rope" then
    local x1, y1, x2, y2 = j:getAnchors()
    local len = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    if len >= j:getMaxLength() - 1 then love.graphics.setColor(1, 0.3, 0.3) end
    love.graphics.line(x1, y1, x2, y2)
    dot(x1, y1); dot(x2, y2)

  elseif t == "mouse" then
    local x1, y1, x2, y2 = j:getAnchors()
    love.graphics.setColor(1, 0.4, 0.4, 0.9)
    love.graphics.line(x1, y1, x2, y2)
    dot(x1, y1)

  elseif t == "distance" then
    local x1, y1, x2, y2 = j:getAnchors()
    love.graphics.line(x1, y1, x2, y2)
    dot(x1, y1); dot(x2, y2)

  else -- revolute, weld, wheel, friction
    local x1, y1 = j:getAnchors()
    love.graphics.circle("line", x1, y1, 5)
    dot(x1, y1)
  end
end

local function drawCursor(x, y)
  local pts = { 0, 0, 0, 16, 4, 12.5, 7.5, 19, 10.5, 17.5, 7, 11, 12, 11 }
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.setColor(1, 1, 1)
  love.graphics.polygon("fill", pts)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(1)
  love.graphics.polygon("line", pts)
  love.graphics.pop()
end

local function drawTitleCard(d)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(fontBig)
  love.graphics.printf("LÖVE2D", d.cx, d.cy + 50, CELL_W, "center")
  love.graphics.printf("Physics Joints", d.cx, d.cy + 82, CELL_W, "center")
  love.graphics.setFont(fontText)
  love.graphics.setColor(0.7, 0.72, 0.8)

  love.graphics.setColor(0.5, 0.52, 0.6)
  love.graphics.printf("[R] reset   [SPACE] pause   [F] record frames",
    d.cx + 10, d.cy + CELL_TH - 28, CELL_W - 20, "center")
  if paused then
    love.graphics.setColor(1, 1, 0.4)
    love.graphics.printf("PAUSED", d.cx, d.cy + 200, CELL_W, "center")
  end
  if recording then
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.printf("● REC  frame " .. frameNo, d.cx, d.cy + 200, CELL_W, "center")
  end
end

function love.draw()
  love.graphics.push()
  love.graphics.scale(SCALE)

  -- cell backgrounds + header text
  for i, d in ipairs(active) do
    local col, row = (i - 1) % COLS, math.floor((i - 1) / COLS)
    local shade = (col + row) % 2 == 0 and 0.11 or 0.14
    love.graphics.setColor(shade, shade + 0.01, shade + 0.04)
    love.graphics.rectangle("fill", d.cx, d.cy, CELL_W, CELL_TH)

    if d.info then
      drawTitleCard(d)
    else
      love.graphics.setColor(0.07, 0.08, 0.10)
      love.graphics.rectangle("fill", d.cx, d.cy, CELL_W, HEADER)
      love.graphics.setFont(fontTitle)
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(d.name, d.cx, d.cy + (HEADER - fontTitle:getHeight()) / 2, CELL_W, "center")
    end
  end

  -- bodies
  for _, b in ipairs(world:getBodies()) do
    local ud = b:getUserData() or {}
    local color = ud.color or C.gray
    local fixtures = b:getFixtures()
    if #fixtures == 0 then
      love.graphics.setColor(0.7, 0.7, 0.75)
      love.graphics.rectangle("fill", b:getX() - 4, b:getY() - 4, 8, 8)
    else
      for _, f in ipairs(fixtures) do drawFixture(b, f, color) end
    end
  end

  -- joints
  for _, j in ipairs(world:getJoints()) do drawJoint(j) end

  -- scripted cursor (MouseJoint demo)
  for _, d in ipairs(active) do
    if d.cursor then drawCursor(d.cursor.x, d.cursor.y) end
  end

  -- borders + header separators
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0.3, 0.32, 0.4)
  for i, d in ipairs(active) do
    love.graphics.rectangle("line", d.cx, d.cy, CELL_W, CELL_TH)
    if not d.info then
      love.graphics.line(d.cx, d.cy + HEADER, d.cx + CELL_W, d.cy + HEADER)
    end
  end

  love.graphics.pop()

  if recording then
    love.graphics.captureScreenshot(string.format("frames/%05d.png", frameNo))
    frameNo = frameNo + 1
  end
  love.graphics.setColor(1, 1, 1)
end