local Entity = require 'entity'
local class = require 'lib.middleclass'
local Timer = require 'lib.timer'
local anim8 = require 'lib.anim8'
local Stateful = require 'lib.stateful'
local Particles = require 'particles'

local MonsterOne = class('MonsterOne', Entity)
MonsterOne:include(Stateful)

local width, height = 10, 5
local friction = 0.00005

local hspeed = 20
local haccel = 500

local jumpSpeed = -200

local img = love.graphics.newImage('sprites/secondformattack.png')
local grid = anim8.newGrid(16, 16, img:getWidth(), img:getHeight())
local anim = anim8.newAnimation(grid(1, '1-9'), 0.2, 'pauseAtEnd')

local dmg_img = love.graphics.newImage('sprites/secondformtorpedo.png')
local dmg_grid = anim8.newGrid(16, 16, dmg_img:getWidth(), dmg_img:getHeight())
local dmg_anim = anim8.newAnimation(dmg_grid(1, 1), 0.1, 'pauseAtEnd')


function MonsterOne:initialize(game, world, x,y)
  Entity.initialize(self, world, x, y, width, height)

  self.game = game
  self.img = img 
  self.anim = anim
  self.enemy = true
  self.world = world
  self.timer = Timer()
 	self.particles = Particles:new(self.x, self.y)
 	self:gotoState('Prepare')
end

function MonsterOne:AI(dt)

end

function MonsterOne:hit()
	self:gotoState('OnHit')
end

function MonsterOne:applyMovement(dt)

end


function MonsterOne:checkOnGround(ny)
end

function MonsterOne:filter(other)
	if other.passable then 
		return false 
	else
		return 'slide'
	end
end

function MonsterOne:moveCollision(dt)

	self.onGround = false

	local world = self.world
	local tx = self.x + self.dx * dt
	local ty = self.y + self.dy * dt 

	local rx, ry, cols, len = world:move(self, tx, ty, self.filter)

	for i=1, len do 
		local col = cols[i]
		self:checkOnGround(col.normal.y) 
	end

	self.x, self.y = rx, ry

end

function MonsterOne:update(dt)
	self.particles:update(dt)
	self.timer:update(dt)
	self:AI(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self:moveCollision(dt)
	self.anim:update(dt)
end

function MonsterOne:draw()
--	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	self.particles:draw()
	self.anim:draw(self.img, self.x+4, self.y, 0, self.Sx, 1, 8, 11)
end

local Torpedo = MonsterOne:addState('Torpedo')

function Torpedo:enteredState()
  self.img = dmg_img 
  self.anim = dmg_anim
  self.anim:gotoFrame(1)
  self.anim:resume()
  self.dy = 100 
  self.dx = 0
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

function Torpedo:checkOnGround(ny)
	if ny < 0 then 
		self:gotoState('Prepare')
		self.game.camera:screenShake(0.1, 5,5)
	end
end

local Prepare = MonsterOne:addState('Prepare')

function Prepare:enteredState()
	self.img = img 
  self.anim = anim
 	self.timer:after(1, function() 
 		if self.game.player.x > self.x then 
 			self.dx = 100 
 		else
 			self.dx = - 100
 		end
 		self.dy = -250
 	end)
end

function Prepare:checkOnGround(ny)
	if ny < 0 and self.dx ~= 0 then 
		self:gotoState('Stop')
	end
end

function Prepare:AI()
 		if math.abs(self.x - self.game.player.x) < 5 then 
 			self:gotoState('Stop')
 		end
end

local Stop = MonsterOne:addState('Stop')

function Stop:enteredState()
	self.dx = 0
	self.dy = 0 
	self.timer:after(0.2, function() self:gotoState('Torpedo') end)
end

function Stop:applyGravity()
end

local OnHit = MonsterOne:addState('OnHit')

function OnHit:enteredState()
	self.img = dmg_img
	self.anim = dmg_anim
	self.timer:after(0.5, function() 
		self.img = trs_img 
		self.anim = trs_anim
		self.timer:after(2.1, function()
			MonsterTwo:new(self.world, self.x, self.y)
			end)
	  end)
end

return MonsterOne