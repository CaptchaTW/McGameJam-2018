local Entity = require 'entity'
local class = require 'lib.middleclass'


local Floor = class('Floor', Entity)


local width, height = 16, 16

function Floor:initialize(world, x, y)
  Entity.initialize(self, world, x, y, width, height)
  self.world = world
  self.drawOrder = 5
end

function Floor:update()
end

function Floor:draw()
	love.graphics.setColor(222, 236, 216)
	love.graphics.rectangle('fill', self.x, self.y, width, height)
	love.graphics.setColor(255, 255, 255)
end

return Floor