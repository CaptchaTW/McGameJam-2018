local class = require 'lib.middleclass'
local bump = require 'lib.bump'
local Camera = require 'camera'

local Floor = require 'floor'

local Player = require 'player'
local Floor = require 'floor'
local MonsterOne = require 'monster1'


x,y,w,h = -10000, -10000,20000,20000

width, height = 192, 108

local Game = class('Game')

function Game:initialize(width, height)
	love.window.setMode(width, height, {resizable = true})

  self.world  = bump.newWorld()
  self.camera = Camera:new(self.world, 0,0, width, height)
  self.player = Player:new(self.world, 0,0)
  self.floor = Floor:new(self.world, 0, 150)
  self.monster = MonsterOne:new(self.world, 100, 100)
end


function Game:log(...)
	print(...)
end

function Game:exit()
	self:log("Goodbye!")
	love.event.push('quit')
end

function Game:resize(w, h)
	self.camera:resize(w,h)
end

local targetx = 0 


function Game:update(dt)

	if self.player.x - targetx > 20 then 
		targetx = targetx +  (self.player.x -22 - targetx) * 0.99 * dt
	end

	if self.player.x - targetx < -20 then 
		targetx = targetx + (self.player.x +22 - targetx) * 0.99 *dt
	end


	self.camera:setCenter(targetx, 130)

  local visibleThings, len = self.world:queryRect(x,y,w,h)

  for i=1, len do
    visibleThings[i]:update(dt)
  end

end

function Game:draw(debug)
	self.camera:draw()
end

function Game:keypressed(key)
	if key == 'escape' then 
		self:exit()
	end

	self.player:keypressed(key)

end

function Game:keyreleased(key)
	self.player:keyreleased(key)
end

return Game