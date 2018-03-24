local Entity = require 'entity'
local class = require 'lib.middleclass'


local RedFloor = class('RedFloor', Entity)

local width, height = 100000, 1000 

function RedFloor:initialize(world, x, y)
  Entity.initialize(self, world, x, y, width, height)
  self.world = world
end

function RedFloor:update()
end

function RedFloor:draw()
	love.graphics.setColor(255,0,0, 100)
	love.graphics.rectangle('fill', self.x, self.y, width, height)
	love.graphics.setColor(255,255,255, 255)
end

return RedFloor