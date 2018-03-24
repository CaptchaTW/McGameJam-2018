local class = require 'lib.middleclass'
local bump = require 'lib.bump'
local Camera = require 'camera'

local Floor = require 'floor'

local Player = require 'player'
local Floor = require 'floor'
local MonsterOne = require 'monster1'

require'sound'
x,y,w,h = -10000, -10000,20000,20000

width, height = 384, 216


local Game = class('Game')

function Game:initialize(width, height)
	love.window.setMode(width, height, {resizable = true})
	self:reset()
end

function Game:reset()
	self.world  = bump.newWorld()
  self.camera = Camera:new(self.world, 0,0, width, height)
  self.player = Player:new(self, self.world, 0,0)

  floor_x,floor_y = -10000,225

  while floor_x~=10000 do
  		Floor:new(self.world, floor_x, floor_y)
 	 		floor_x = floor_x+16
  end
  while floor_y~=210 do
  	 	Floor:new(self.world, floor_x, floor_y)
  		floor_y = floor_y-15
  		floor_x = -10000
	end
  while floor_x~=10000 do
  	self.floor = Floor:new(self.world, floor_x, floor_y)
  	floor_x =floor_x+16
	end

  self.monster = MonsterOne:new(self, self.world, 100, 100)
  music:play()
  music:setLooping(true)

music:play()
music:setLooping(true)
  self.camera:resize(love.graphics.getWidth(), love.graphics.getHeight())
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
	self.camera:update(dt)

	if self.player.x - targetx > 20 then 
		targetx = targetx +  (self.player.x -22 - targetx) * 0.999 * dt
	end

	if self.player.x - targetx < -20 then 
		targetx = targetx + (self.player.x +22 - targetx) * 0.999 *dt
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