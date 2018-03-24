local class = require 'lib.middleclass'
local bump = require 'lib.bump'

local Floor = require 'floor'

local Player = require 'player'
local Floor = require 'floor'
local RedFloor = require 'redfloor'


x,y,w,h = 0,0,10000,10000

local Game = class('Game')

function Game:initialize()
  self.world  = bump.newWorld()
  self.player = Player:new(self.world, 0,0)
  self.floor = Floor:new(self.world, 0, 500)
end


function Game:log(...)
	print(...)
end

function Game:exit()
	self:log("Goodbye!")
	love.event.push('quit')
end

function Game:resize(w, h)
end

function Game:update(dt)


  local visibleThings, len = self.world:queryRect(x,y,w,h)

  for i=1, len do
    visibleThings[i]:update(dt)
  end

end

function Game:draw(debug)


	local visibleThings, len = self.world:queryRect(x,y,w,h)

  for i=1, len do
    visibleThings[i]:draw(dt)
  end

end

function Game:keypressed(key)
	if key == 'escape' then 
		self:exit()
	end

	self.player:keypressed(key)

end

function Game:keyreleased(key)

end

return Game