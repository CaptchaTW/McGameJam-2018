local class = require 'lib.middleclass'

local Bump = require 'lib.bump'


local Game = class('Game')

function Game:initialize()
  self.world  = Bump.newWorld()
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

end

function Game:keyreleased(key)

end

return Game