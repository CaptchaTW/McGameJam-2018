local Entity = require 'entity'
local class = require 'lib.middleclass'
local Timer = require 'lib.timer'
local anim8 = require 'lib.anim8'
local Stateful = require 'lib.stateful'
local Debris = require 'debris'

local debris1 = love.graphics.newImage('sprites/debris1.png')
local debris2 = love.graphics.newImage('sprites/debris2.png')
local debris3 = love.graphics.newImage('sprites/debris3.png')

local MonsterOne = require 'monster1'

local MonsterZero = class('MonsterZero', Entity)
MonsterZero:include(Stateful)

local width, height = 10, 5
local friction = 0.00005

local hspeed = 20
local haccel = 500

local jumpSpeed = -200

local img = love.graphics.newImage('sprites/formzero.png')
local grid = anim8.newGrid(16, 16, img:getWidth(), img:getHeight())
local anim = anim8.newAnimation(grid('1-5', 1), 0.1)

local trs_img = love.graphics.newImage('sprites/formzerotransforming.png')
local trs_grid = anim8.newGrid(18, 16, trs_img:getWidth(), trs_img:getHeight())
local trs_anim = anim8.newAnimation(trs_grid('1-21', 1), 0.1, 'pauseAtEnd')

function MonsterZero:initialize(game, world, x,y)
  Entity.initialize(self, world, x, y, width, height)

  self.type = typee

  self.game = game
  self.img = img 
  self.anim = anim
  self.enemy = true
  self.damaging = true
  self.world = world
 	self.drawOrder = 2
  self.timer = Timer()
  self.leftKey = true
  self.timer:every(4, function() 
  	self.leftKey = true 
  	self.rightKey = false
  	self.timer:after(2, function()
  		self.leftKey = false 
  		self.rightKey = true
  	end) 
  end)
end

function MonsterZero:AI(dt)

end

function MonsterZero:hit()
	self:gotoState('OnHit')
end

function MonsterZero:applyMovement(dt)

	local dx, dy = self.dx, self.dy

		if self.leftKey then
			if dx > -hspeed  then 
				dx = dx - haccel * dt
			end
			self.Sx = 1 
		end
		if self.rightKey then
			if dx < hspeed  then
				dx = dx + haccel * dt
			end
			self.Sx = -1
		end

		self.dx, self.dy = dx, dy

		if not (self.leftKey or self.rightKey) then
			self.dx = self.dx * math.pow(friction, dt)
		end

end


function MonsterZero:checkOnGround(ny)
  if ny < 0  then 
  	self.onGround = true
  end
end

function MonsterZero:filter(other)
	if other.passable then 
		return false 
	else
		return 'slide'
	end
end

function MonsterZero:moveCollision(dt)

	self.onGround = false

	local world = self.world
	local tx = self.x + self.dx * dt
	local ty = self.y + self.dy * dt 

	local rx, ry, cols, len = world:move(self, tx, ty, self.filter)



	for i=1, len do 
		local col = cols[i]
		self:checkOnGround(col.normal.y) 

	if col.other.player == true then 
		col.other:die()
	end
end

	self.x, self.y = rx, ry
end

function MonsterZero:update(dt)
	self.timer:update(dt)
	self:AI(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self:moveCollision(dt)
	self.anim:update(dt)
end

function MonsterZero:draw()
--	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	self.anim:draw(self.img, self.x+4, self.y, 0, self.Sx, 1, 8, 11)
end

local OnHit = MonsterZero:addState('OnHit')

function OnHit:enteredState()
	local x, y = self:getCenter()
		
	music:setVolume(0.8)	
	music:setVolume(0.7)	
	music:setVolume(0.6)	
	music:setVolume(0.5)	
	music:setVolume(0.4)	
	music:setVolume(0.3)	
	music:setVolume(0.2)	
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

	self.timer:tween(2.1, self.game.backgroundcolor, {r = 125, g = 123, b = 143}, 'linear')

	self.timer:after(0, function() 
		self.img = trs_img 
		self.anim = trs_anim
		self.anim:gotoFrame(1)
		music:stop()
			music1:play()
		self.anim:resume()
		self.timer:after(2.1, function()
			MonsterOne:new(self.game, self.world, self.x, self.y)
			music:setVolume(1)
			music1:setLooping(true)
			self:destroy()
			end)
	  end)
end

function OnHit:moveCollision()
	end

return MonsterZero