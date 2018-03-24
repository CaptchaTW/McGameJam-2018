local Entity = require 'entity'
local class = require 'lib.middleclass'
local Timer = require 'lib.timer'
local anim8 = require 'lib.anim8'
local Stateful = require 'lib.stateful'
local Particles = require 'particles'
local Dust = require 'landingdust'
local Projectile = require 'projectile'
local Debris = require 'debris'
local MonsterThree = require 'monster3'

local debris1 = love.graphics.newImage('sprites/debris1.png')
local debris2 = love.graphics.newImage('sprites/debris2.png')
local debris3 = love.graphics.newImage('sprites/debris3.png')

local MonsterTwo = class('MonsterTwo', Entity)
MonsterTwo:include(Stateful)

local width, height = 10, 16
local friction = 0.00005

local hspeed = 20
local haccel = 500

local jumpSpeed = -200

local img = love.graphics.newImage('sprites/secondformattack.png')
local grid = anim8.newGrid(16, 16, img:getWidth(), img:getHeight())
local anim = anim8.newAnimation(grid(1, '1-9'), 0.1, 'pauseAtEnd')

local dmg_img = love.graphics.newImage('sprites/secondformtorpedo.png')
local dmg_grid = anim8.newGrid(16, 16, dmg_img:getWidth(), dmg_img:getHeight())
local dmg_anim = anim8.newAnimation(dmg_grid(1, 1), 0.1, 'pauseAtEnd')

local trs_img = love.graphics.newImage('sprites/secondformtransforming.png')
local trs_grid = anim8.newGrid(32, 57, trs_img:getWidth(), trs_img:getHeight())
local trs_anim = anim8.newAnimation(trs_grid('1-34', 1), 0.1, 'pauseAtEnd')


function MonsterTwo:initialize(game, world, x,y)
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
end

function MonsterTwo:AI(dt)

end

function MonsterTwo:hit()
	self:gotoState('OnHit')
end

function MonsterTwo:applyMovement(dt)

end


function MonsterTwo:checkOnGround(ny)
end

function MonsterTwo:filter(other)
	if other.passable or other.player then 
		return false 
	else
		return 'slide'
	end
end

function MonsterTwo:moveCollision(dt)
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

 		if self.game.player.x > self.x then 
 			self.Sx = -1
 		else
 			self.Sx = 1
 		end

end

function MonsterTwo:update(dt)
	self.particles:update(dt)
	self.timer:update(dt)
	self:AI(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self:moveCollision(dt)
	self.anim:update(dt)
end

function MonsterTwo:draw()
-- 	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	self.particles:draw()
	self.anim:draw(self.img, self.x+5, self.y, 0, self.Sx, self.Sy, 9, self.Oy)
end

local Torpedo = MonsterTwo:addState('Torpedo')

function Torpedo:enteredState()
  self.img = dmg_img 
  self.anim = dmg_anim
  self.anim:gotoFrame(1)
  self.anim:resume()
  self.dy = 200 
  self.dx = 0
  self.damaging = true
  self.timer:tween(0.2, self, {Sy = 1.5}, 'linear')
end

function Torpedo:update(dt)
	local x, y = self:getCenter()
	self.particles:emit(1, x, y)
	self.particles:update(dt)
	self.timer:update(dt)
	self:AI(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self:moveCollision(dt)
	self.anim:update(dt)
end

function Torpedo:checkOnGround(ny, other)
	if ny < 0 then 

			self:gotoState('Prepare')
			boom:play()
			self.game.camera:screenShake(0.1, 5,5)
			local x,y = self:getCenter()
			Dust:new(self.world, x, y, 'impact')
			Projectile:new(self.world, x, y, 8, 8,  100)
			Projectile:new(self.world, x, y, 8, 8, -100)
			self.Sy = 1
	end
end

local Prepare = MonsterTwo:addState('Prepare')

function Prepare:enteredState()
	self.img = img 
  self.anim = anim
  self.anim:gotoFrame(1)
  self.drawOrder = 2
  self.anim:resume()
 	self.timer:after(0.8, function() 
 		if self.game.player.x > self.x then 
 			self.dx = 100 
 		else
 			self.dx = - 100
 		end
 		self.dy = -150 - math.random(0,100)
 	end)
end

function Prepare:checkOnGround(ny)
	if ny < 0 and self.dx ~= 0 then 
		self:gotoState('Torpedo')
	end

	if ny < 0 then 
		self.Sy = 1
	end
end

function Prepare:AI()
 		if math.abs(self.x - self.game.player.x) < 5 and self.y < self.game.player.y then 
 			self:gotoState('Stop')
 		end
end

local Stop = MonsterTwo:addState('Stop')

function Stop:enteredState()
	self.dx = 0
	self.dy = 0 
	self.timer:after(0.2, function() self:gotoState('Torpedo') end)
end

function Stop:applyGravity()
end

local OnHit = MonsterTwo:addState('OnHit')

function OnHit:enteredState()
	local x, y = self:getCenter()
music1:setVolume(0.8)	
	music1:setVolume(0.7)	
	music1:setVolume(0.6)	
	music1:setVolume(0.5)	
	music1:setVolume(0.4)	
	music1:setVolume(0.3)	
	music1:setVolume(0.2)	
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


	self.game.camera:screenShake(0.1, 5,5)
	self.img = dmg_img
	self.anim = dmg_anim
		self.anim:gotoFrame(1)
		self.anim:resume()

		self.dying = true

	self.timer:after(0.5, function() 
		self.img = trs_img 
		self.anim = trs_anim
		self.dx = 0
		self.Oy = 41
		self.anim:gotoFrame(1)
		self.anim:resume()
		self.timer:after(3.4, function()
			MonsterThree:new(self.game, self.world, self.x, self.y)
			music1:stop()
			music1: setVolume(1)
			music2:play()
			music2:setLooping(true)
			self:destroy()
			end)
	  end)
end

return MonsterTwo