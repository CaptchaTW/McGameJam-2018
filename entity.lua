local class = require 'lib.middleclass'

local Entity = class('Entity')

local gravity = 400
local maxSpeed = 150

function Entity:initialize(world, x,y,w,h)
  self.world, self.x, self.y, self.w, self.h = world, x,y,w,h
  self.world:add(self, x,y,w,h)
  self.dx = 0 
  self.dy = 0
end

function Entity:getCenter()
  return self.x + self.w / 2,
         self.y + self.h / 2
end

function Entity:destroy()
  self.world:remove(self)
end

function Entity:applyGravity(dt)
  if self.dy < maxSpeed then 
    self.dy = self.dy + gravity * dt
  end
end

function Entity:getDrawOrder()
  return self.drawOrder or 10000
end

return Entity