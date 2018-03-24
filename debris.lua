
local class   = require 'lib.middleclass'
local Entity  = require 'entity'
local Timer = require 'lib.timer'

local Debris = class('Debris', Entity)

local minTime = 4
local maxTime = 5
local maxSpin = 2
local friction = 30


function Debris:initialize(parent, world, x, y, img, vel)

  local w, h = img:getWidth()-1, img:getHeight()-1

  Entity.initialize(self, world, x, y, w, h)
  self.drawOrder = math.random(-20, -1)
  self.img = img
  self.dx = math.random(-vel, vel)
  self.dy = math.random(-vel, vel)
  local Gx, Gy = self:getCenter()
  self.Ox = Gx - self.x
  self.Oy = Gy - self.y -2
  self.Sx = 1 
  self.Sy = 1
  self.r = 0
  self.drawOrder = 1
  self.passable = true
  self.timer = Timer()

end

function Debris:filter(other)
  if  other.passable or other.player or other.damaging then return false else return "slide" end
end

function Debris:checkOnGround(ny, other, dt)
  if ny < 0 then 
    self.dx = self.dx * (friction) *dt
  end
end

function Debris:moveCollision(dt)
  if self.isDying then return false end
  local world = self.world
  local tx = self.x + self.dx * dt
  local ty = self.y + self.dy * dt 

  local rx, ry, cols, len = world:move(self, tx, ty, self.filter)

  for i=1, len do 
    local col = cols[i]
    self:checkOnGround(col.normal.y, col.other, dt)


  end
    self.x = rx 
    self.y = ry 
end

function Debris:update(dt)
    self.timer:update(dt)
    self:applyGravity(dt)
    self:moveCollision(dt)
end

function Debris:die()
end

function Debris:draw()

  local Gx, Gy = self:getCenter()
  love.graphics.draw(self.img, Gx, Gy, self.r, self.Sx, self.Sy, self.Ox, self.Oy)
end

return Debris
