local Entity = require 'entity'
local class = require 'lib.middleclass'
local Timer = require 'lib.timer'
local anim8 = require 'lib.anim8'
local Stateful = require 'lib.stateful'
local Particles = require 'particles'
local Dust = require 'landingdust'
local Projectile = require 'projectile'
local Weakpoint = require 'weakpoint'
local Debris = require 'debris'
local MonsterFour = require 'monster4'


local debris1 = love.graphics.newImage('sprites/debris1.png')
local debris2 = love.graphics.newImage('sprites/debris2.png')
local debris3 = love.graphics.newImage('sprites/debris3.png')

local MonsterThree = class('MonsterThree', Entity)
MonsterThree:include(Stateful)

local width, height = 10, 56
local friction = 0.00005

local hspeed = 20
local haccel = 500

local jumpSpeed = -200

local img = love.graphics.newImage('sprites/thirdformattack.png')
local grid = anim8.newGrid(38, 56, img:getWidth(), img:getHeight())
local anim = anim8.newAnimation(grid('1-10', 1, 1, 1), 0.1, 'pauseAtEnd')

local dmg_img = love.graphics.newImage('sprites/thirdformcharge.png')
local dmg_grid = anim8.newGrid(40, 56, dmg_img:getWidth(), dmg_img:getHeight())
local dmg_anim = anim8.newAnimation(dmg_grid('1-17', 1), 0.05, 'pauseAtEnd')

local trs_img = love.graphics.newImage('sprites/thirdformtransformation.png')
local trs_grid = anim8.newGrid(128, 128, trs_img:getWidth(), trs_img:getHeight())
local trs_anim = anim8.newAnimation(trs_grid(1, '1-40'), 0.1, 'pauseAtEnd')

function MonsterThree:initialize(game, world, x,y)
  Entity.initialize(self, world, x, y, width, height)

  self.game = game
  self.img = img 
  self.anim = anim
  self.enemy = true
  self.world = world
  self.timer = Timer()
  self.damaging = true
 	self.particles = Particles:new(self.x, self.y)
 	self.dx = 0
 	self:gotoState('Prepare')
 	self.Sy = 1
 	local x, y = self:getCenter()
 	self.weakpoint = Weakpoint:new(self.world, self, x, y, 8, 8)
end

function MonsterThree:AI(dt)

end

function MonsterThree:hit()
end

function MonsterThree:applyMovement(dt)

end


function MonsterThree:checkOnGround(ny)
end

function MonsterThree:filter(other)
	if other.passable or other.player or other.projectile then 
		return false 
	else
		return 'slide'
	end
end

function MonsterThree:moveCollision(dt)
	if self.dying then return false end
	self.onGround = false

	local world = self.world
	local tx = self.x + self.dx * dt
	local ty = self.y + self.dy * dt 

	local rx, ry, cols, len = world:move(self, tx, ty, self.filter)

	for i=1, len do 
		local col = cols[i]
		self:checkOnGround(col.normal.y, col.other) 
		if col.other.player == true then 
			col.other:die()
		end
	end

	self.x, self.y = rx, ry

end

function MonsterThree:update(dt)
	self.particles:update(dt)
	self.timer:update(dt)
	self:AI(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self:moveCollision(dt)
	self.anim:update(dt)
end

function MonsterThree:draw()
-- 	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	self.particles:draw()
	self.anim:draw(self.img, self.x+5, self.y, 0, self.Sx, self.Sy, self.Ox or 16, self.Oy)
end

local Lazer = MonsterThree:addState('Lazer')

function Lazer:enteredState()
 		if self.game.player.x > self.x then 
 			self.Sx = -1
 		else
 			self.Sx = 1
 		end

	self.dx = 0
	self.dy = 0
	if not self.dying then  
		self.img = dmg_img 
	  self.anim = dmg_anim
	  self.anim:gotoFrame(1)
	  self.anim:resume()
	end
  self.timer:after(1.2, function() 
  	if not self.dying then
	  	self:gotoState('Pause') 
	  	self.anim:gotoFrame(1)
	  	self.x = self.x + 5*self.Sx 
	  	self.game.camera:screenShake(0.4, 2,2)
  	end
  end)
  self.timer:after(1, function()
  	if not self.dying then
	  	local x, y = self:getCenter()
	  		Projectile:new(self.world, x, y+10, 1000,  16, 0, 0, 'lazer')
	  		Projectile:new(self.world, x-1000, y+10, 1000,  16, 0, 0, 'lazer')
	  		laser: setPitch(0.9 + math.random()/2)
	  		laser:play()
	  end
  end)
end


local Pause = MonsterThree:addState('Pause')

function Pause:enteredState()
	self.dx = 0
	self.dy= 0
	if not self.dying then
		if math.random(1 , 5) > 2   then 
			self.timer:after(math.random(5,13)/10, function() self:gotoState('Lazer') end)
		else
			self.timer:after(math.random(5,13)/10, function() self:gotoState('Prepare') end)
		end
	end
end

local Prepare = MonsterThree:addState('Prepare')

function Prepare:enteredState()
 		if self.game.player.x > self.x then 
 			self.Sx = -1
 		else
 			self.Sx = 1
 		end

 if not self.dying then 
		self.img = img 
	  self.anim = anim
	  self.anim:gotoFrame(1)
	  self.drawOrder = 2
	end
  self.anim:resume()
 	self.timer:after(0.8, function() 
 		self.game.camera:screenShake(0.4, 2,2)
 		if self.game.player.x > self.x then 
 			self.dx = 200 
 		else
 			self.dx = - 200
 		end
	end)
 self.timer:after(math.random(8, 6)/10, function() if not self.dying then self:gotoState('Pause') end end)

end

function Prepare:checkOnGround(ny)
end

function Prepare:AI()

end

local OnHit = MonsterThree:addState('OnHit')

function OnHit:enteredState()
	hit:play()
	local x, y = self:getCenter()
music3:setVolume(0.8)	
	music3:setVolume(0.7)	
	music3:setVolume(0.6)	
	music3:setVolume(0.5)	
	music3:setVolume(0.4)	
	music3:setVolume(0.3)	
	music3:setVolume(0.2)	
	self.dying = true

	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris2, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)

	Debris:new(self, self.world, self.weakpoint.x, self.weakpoint.y, debris1, 200)
	Debris:new(self, self.world, self.weakpoint.x, self.weakpoint.y, debris1, 200)
	Debris:new(self, self.world, self.weakpoint.x, self.weakpoint.y, debris2, 200)
	Debris:new(self, self.world, self.weakpoint.x, self.weakpoint.y, debris3, 200)
	Debris:new(self, self.world, self.weakpoint.x, self.weakpoint.y, debris3, 200)
	Debris:new(self, self.world, self.weakpoint.x, self.weakpoint.y, debris3, 200)

	self.game.player.movable = false 
	self.game.player:gotoState(nil)
	self.game.player.timer:after(1, function() self.game.player.movable = true end)
	self.game.player.dy = -200

	if self.x > self.game.player.x then
		self.game.player.dx = -220 
	else 
		self.game.player.dx = 220
	end

	self.timer:tween(3.4, self.game.backgroundcolor, {r = 21, g = 18, b = 32}, 'linear')


	self.game.camera:screenShake(0.1, 5,5)

		self.dying = true

	self.timer:after(0, function() 
		self.img = trs_img 
		self.anim = trs_anim
		self.dx = 0
		self.Ox = 40
		self.Oy = 74
		self.anim:gotoFrame(1)
		self.anim:resume()
		self.timer:after(4.2, function()
			MonsterFour:new(self.game, self.world, self.x-50, self.y-74)
			self:destroy()
			music3:stop()
			music3:setVolume(1)
music4:play()
music4:setLooping(true)
			end)
	  end)
end

return MonsterThree