local class = require 'lib.middleclass'

local bump = require 'lib.bump'


local Game = class('Game')

function Game:initialize()

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
end

function Game:draw(debug)
end

function Game:keypressed(key)
	if key == 'escape' then 
		self:exit()
	end

end

function Game:keyreleased(key)

end

return Game