local Entity = require 'entity'
local class = require 'lib.middleclass'


local Floor = class('Floor', Entity)

local width, height = 100000, 1000 

function Floor:initialize(world, x, y)
  Entity.initialize(self, world, -50000, y, width, height)
  self.world = world
end

function Floor:update()
end

function Floor:draw()
	love.graphics.rectangle('fill', self.x, self.y, width, height)
end

return Floor