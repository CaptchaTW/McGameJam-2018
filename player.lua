local Entity = require 'entity'
local class = require 'lib.middleclass'
local anim8 = require 'lib.anim8'


local Player = class('Player', Entity)

local width, height = 4, 16
local attackW = 20
local friction = 0.00005

local hspeed = 75
local haccel = 500

local jumpSpeed = -200

function Player:initialize(world, x,y)
  Entity.initialize(self, world, x, y, width, height)
  self.world = world

end


function Player:input()
	self.leftKey = love.keyboard.isDown('a') 
	self.rightKey = love.keyboard.isDown('d')
	self.upKey = love.keyboard.isDown('w')
	self.downKey = love.keyboard.isDown('s')
	self.jumpKey = love.keyboard.isDown('space')
	self.rollKey = love.keyboard.isDown('j')
end


function Player:applyMovement(dt)

	local dx, dy = self.dx, self.dy

		if self.leftKey then
			if dx > -hspeed  then 
				dx = dx - haccel * dt
			end
			self.Sx = -1 
		end
		if self.rightKey then
			if dx < hspeed  then
				dx = dx + haccel * dt
			end
			self.Sx = 1
		end

		self.dx, self.dy = dx, dy

		if not (self.leftKey or self.rightKey) then
			self.dx = self.dx * math.pow(friction, dt)
		end

end


function Player:keypressed(key)
	if key == 'space' then 
		self:jump()
	end

	if key == 'j' then
		self:roll()
	end
end

function Player:jump()
	if self.onGround then
		self.dy = jumpSpeed
	end
end

function Player:roll()
	self.rolling = true 
	self.timer:after(0.5, function() self.rolling = false end)
end

function Player:attack()
	 local things, len = self.world:queryRect(self.x-attackW, self.y, attackW*2, self.h)

	 for i=1, len do
	 	if things[i].hit then
	 		things[i]:hit()
	 	end
	end
end

function Player:keyreleased(key)

end

function Player:checkOnGround(ny)
  if ny < 0  then 
  	self.onGround = true
  end
end

function Player:moveCollision(dt)

	self.onGround = false

	local world = self.world
	local tx = self.x + self.dx * dt
	local ty = self.y + self.dy * dt 

	local rx, ry, cols, len = world:move(self, tx, ty, self.filter)

	for i=1, len do 
		local col = cols[i]

		if col.other.damaging then 
		end

		self:checkOnGround(col.normal.y) 
	end

	self.x, self.y = rx, ry
end

function Player:update(dt)
	self:input(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self:moveCollision(dt)
end

function Player:draw()
	love.graphics.rectangle('fill', self.x, self.y, width, height)
end

return Player