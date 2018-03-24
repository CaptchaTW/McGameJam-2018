local Entity = require 'entity'
local class = require 'lib.middleclass'
local Timer = require 'lib.timer'
local anim8 = require 'lib.anim8'
local Stateful = require 'lib.stateful'
local Particles = require 'particles'
local Dust = require 'landingdust'
local Projectile = require 'projectile'

local MonsterTwo = class('MonsterTwo', Entity)
MonsterTwo:include(Stateful)

local width, height = 10, 56
local friction = 0.00005

local hspeed = 20
local haccel = 500

local jumpSpeed = -200

local img = love.graphics.newImage('sprites/thirdformattack.png')
local grid = anim8.newGrid(38, 56, img:getWidth(), img:getHeight())
local anim = anim8.newAnimation(grid('1-10', 1), 0.1, 'pauseAtEnd')

local dmg_img = love.graphics.newImage('sprites/thirdformcharge.png')
local dmg_grid = anim8.newGrid(40, 56, dmg_img:getWidth(), dmg_img:getHeight())
local dmg_anim = anim8.newAnimation(dmg_grid('1-17', 1), 0.1, 'pauseAtEnd')


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
 	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	self.particles:draw()
	self.anim:draw(self.img, self.x+5, self.y, 0, self.Sx, self.Sy, 16, 0)
end

local Lazer = MonsterTwo:addState('Lazer')

function Lazer:enteredState()
	self.dx = 0
	self.dy = 0
	self.img = dmg_img 
  self.anim = dmg_anim
  self.anim:gotoFrame(1)
  self.timer:after(1.7, function() self:gotoState('Pause') self.x = self.x + 2*self.Sx end)
end


local Pause = MonsterTwo:addState('Pause')

function Pause:enteredState()
	self.dx = 0
	self.dy= 0
	if math.random() > 0.5 then 
		self.timer:after(math.random(1,4), function() self:gotoState('Lazer') end)
	else
		self.timer:after(math.random(1,4), function() self:gotoState('Prepare') end)
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
 			self.dx = 200 
 		else
 			self.dx = - 200
 		end
	end)
 self.timer:after(math.random(10, 15)/10, function() self:gotoState('Pause') end)

end

function Prepare:checkOnGround(ny)
end

function Prepare:AI()

end

local OnHit = MonsterTwo:addState('OnHit')

function OnHit:enteredState()
	self.img = dmg_img
	self.anim = dmg_anim
	self.timer:after(0.5, function() 
--		self.img = trs_img 
--		self.anim = trs_anim
		self.timer:after(2.1, function()
			MonsterTwo:new(self.game, self.world, self.x, self.y)
			self:destroy()
			end)
	  end)
end

return MonsterTwo