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
tile1 = love.graphics.newImage("Tile1.png")
tile2 = love.graphics.newImage("tile2.png")
function Floor:draw()
	love.graphics.setColor(222, 236, 216)
	love.graphics.rectangle('fill', self.x, self.y, width, height)

	love.graphics.setColor(255, 255, 255)
if self.y==2 then
		love.graphics.draw(tile2,self.x,self.y)
	else 
		love.graphics.draw(tile1,self.x,self.y)
	end
end

return Floor