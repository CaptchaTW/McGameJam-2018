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

local debris1 = love.graphics.newImage('sprites/debris1.png')
local debris2 = love.graphics.newImage('sprites/debris2.png')
local debris3 = love.graphics.newImage('sprites/debris3.png')


local MonsterFour = class('MonsterFour', Entity)
MonsterFour:include(Stateful)

local width, height = 65, 128
local friction = 0.00005

local hspeed = 20
local haccel = 500

local jumpSpeed = -200

local img = love.graphics.newImage('sprites/fourthformblink.png')
local grid = anim8.newGrid(128, 128, img:getWidth(), img:getHeight())
local anim = anim8.newAnimation(grid(1, '9-1', 1, '1-9'), 0.2, 'pauseAtEnd')

local dmg_img = love.graphics.newImage('sprites/fourthformcrouch.png')
local dmg_grid = anim8.newGrid(128, 128, dmg_img:getWidth(), dmg_img:getHeight())
local dmg_anim = anim8.newAnimation(dmg_grid('1-6', 1), 0.1, 'pauseAtEnd')

local dmg_anim2 = anim8.newAnimation(dmg_grid('6-1', 1), 0.1, 'pauseAtEnd')

function MonsterFour:initialize(game, world, x,y)
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
 	self.Sy = 1
 	local x, y = self:getCenter()
 	self.weakpoint = Weakpoint:new(self.world, self, x, y, 8, 8)
 	self:gotoState('Blink')
end

function MonsterFour:AI(dt)

end

function MonsterFour:hit()
	if self.hittable then 
		self:gotoState('OnHit')
	end
end

function MonsterFour:applyMovement(dt)

end


function MonsterFour:checkOnGround(ny)
end

function MonsterFour:filter(other)

end

function MonsterFour:moveCollision(dt)

end

function MonsterFour:update(dt)
	self.particles:update(dt)
	self.timer:update(dt)
	self:AI(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self.anim:update(dt)
end

function MonsterFour:draw()
 	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	self.particles:draw()
	self.anim:draw(self.img, self.x+5, self.y, 0, self.Sx, self.Sy,32, 0)
end

local Idle = MonsterFour:addState('Idle')

function Idle:enteredState()
	if not self.dying then
		if math.random(1 , 5) > 2   then 
			self.timer:after(math.random(5,13)/10, function() self:gotoState('Attack') end)
		else
			self.timer:after(math.random(5,13)/10, function() self:gotoState('Blink') end)
		end
	end
end

local Blink = MonsterFour:addState('Blink')

function Blink:enteredState()
	eye:play()

	self.img = img 
	self.anim = anim
	self.anim:gotoFrame(1)
	self.anim:resume()
	self.hittable = true 
	local x, y = self:getCenter()
	for i=0, 64 do 

		self.timer:after(0.05*i, function()
			Projectile:new(self.world, x, y, 8, 8, 40*math.cos(i*math.pi/12)+ math.random(0,2) - 1, 40*math.sin(i*math.pi/12) + math.random(0,2) - 1)
		end)
	end


	self.timer:after(3.4, function() self.hittable = false  self:gotoState('Idle') end)
end


local Attack = MonsterFour:addState('Attack')

function Attack:enteredState()
	attack4:play()

		self.img = dmg_img 
	self.anim = dmg_anim
	self.anim:gotoFrame(1)
	self.anim:resume()

	self.timer:after(1, function() 
		self.anim = dmg_anim2 	
		self.anim:gotoFrame(1)
		self.anim:resume()
	end)

	local x, y = self:getCenter()

	for i=0, 20 do 

		self.timer:after(0.2*i, function()
			Projectile:new(self.world, x+10+20*i, y-64, 4, 128, 0, 0, 'vine')
			Projectile:new(self.world, x-10-20*i, y-64, 4, 128, 0, 0, 'vine')
		end)
	end



	self.timer:after(1.8, function() 
		self:gotoState('Idle')
	end)


end


local OnHit = MonsterFour:addState('OnHit')

function OnHit:enteredState()
	local x, y = self:getCenter()

	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris2, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris2, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris2, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris2, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)

	self.game.player.movable = false 
	self.game.player:gotoState(nil)
	self.game.player.timer:after(1, function() self.game.player.movable = true end)
	self.game.player.dy = -200

	if self.x > self.game.player.x then
		self.game.player.dx = -200 
	else 
		self.game.player.dx = 200
	end

	self.game.camera:screenShake(5, 5,5)

	self.timer:after(3, function() self.game:gotoState('End') end)
		self.dying = true

end

function OnHit:update(dt)
	self.particles:update(dt)
	self.timer:update(dt)
	self:AI(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self.anim:update(dt)
	local x,y = self:getCenter()
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris2, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
end

return MonsterFour