local class = require 'lib.middleclass'
local bump = require 'lib.bump'
local Camera = require 'camera'
local Stateful = require 'lib.stateful'
local Floor = require 'floor'

local Player = require 'player'
local Floor = require 'floor'
<<<<<<< HEAD
local MonsterOne = require 'monster2'
=======
<<<<<<< HEAD
local MonsterOne = require 'monster1'
=======
local MonsterOne = require 'monster0'
>>>>>>> d4acfb4676d304a515fb44c522ff3f3ce36bcfcc
>>>>>>> b740889bce82fcf1591af31c4be4d0d7a110db27

require'sound'
x,y,w,h = -10000, -10000,20000,20000

width, height = 384, 216


local Game = class('Game'):include(Stateful)

function Game:initialize(width, height)
	love.window.setMode(width, height, {resizable = true})
	self:gotoState('Loading')
end

function Game:reset()
	self.world  = bump.newWorld()
  self.camera = Camera:new(self.world, 0,0, width, height)
  self.player = Player:new(self, self.world, 0,0)
<<<<<<< HEAD
  self.monster1 = require 'monster1'
=======
	wall_y =0
	wall_x=-500
	wall_y1=0
	wall_x1=500
	while wall_x ~=-676 do
while wall_y <= 206 do
Floor:new(self.world,wall_x,wall_y)
wall_y = wall_y + 16
end
wall_x = wall_x-16
wall_y =0
end
while  wall_x1 ~= 676 do
while wall_y1 <= 206 do
Floor:new(self.world,wall_x1,wall_y1)
wall_y1 = wall_y1 + 16
end
wall_x1 =wall_x1+16
wall_y1=0
end
  floor_x,floor_y = -1000,222
>>>>>>> b740889bce82fcf1591af31c4be4d0d7a110db27

  while floor_x~=1000 do
  		Floor:new(self.world, floor_x, floor_y)
 	 		floor_x = floor_x+16
  end
  while floor_y~=206 do
  	 	Floor:new(self.world, floor_x, floor_y)
  		floor_y = floor_y-16
  		floor_x = -1000
	end
  while floor_x~=1000 do
  	 Floor:new(self.world, floor_x, floor_y)
  	floor_x =floor_x+16
	end



  self.monster = MonsterOne:new(self, self.world, 100, 100)
  self.backgroundcolor = {r = 162, g = 221, b = 232}
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

	love.graphics.setBackgroundColor(self.backgroundcolor.r, self.backgroundcolor.g, self.backgroundcolor.b)
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








local Loading = Game:addState('Loading')
	
function Loading:draw()
	love.graphics.printf('ad for movement, space for jump, j for roll and k for attack', 0, 0, 384)
end

function Loading:keypressed()

	self:reset()
	self:gotoState(nil)
end

function Loading:resize()
end

function Loading:update()
end

local Death = Game:addState('Death')
	
function Death:enteredState()
	death:play()
	love.graphics.setBackgroundColor(0, 0, 0)
end

function Death:draw()
	love.graphics.printf('you died', 130, 50, 384)
end

function Death:keypressed()
	self:reset()
	self:gotoState(nil)
end

function Death:resize()
end

function Death:update()
end

local End = Game:addState('End')
	
function End:enteredState()
	love.graphics.setBackgroundColor(0, 0, 0)
end

function End:draw()
	love.graphics.printf('Congrats', 130, 50, 384)
end

function End:keypressed(key)
	if key == 'y' then 
		self:reset()
		self:gotoState(nil)
	end
end

function End:resize()
end

function End:update()
end


return Game