local class = require 'lib.middleclass'
local Entity = require 'entity'
local anim8 = require 'lib.anim8'
local Timer = require 'lib.timer'

local Projectile = class ("Projectile", Entity)


local w = 8
local h = 8

function Projectile:initialize( world, x, y, dx, dy, type)
  Entity.initialize(self, world, x, y, w, h)
	self.x = x 
	self.y = y
	self.dx = dx or 0
	self.dy = dy or 0
	self.timer = Timer()

  self.timer:after(10, function() self:destroy() self.dying = true end)
end

function Projectile:moveCollision(dt)

	if self.dying then return false end 
	
	local world = self.world
	local tx = self.x + self.dx * dt
	local ty = self.y + self.dy * dt 

	self.passable = true

	local rx, ry, cols, len = world:move(self, tx, ty, function() return 'cross' end)

	for i=1, len do 
		local col = cols[i]

		if col.other.player then 
			
		end 
	end

	self.x, self.y = rx, ry
end

function Projectile:update(dt)
	self.timer:update(dt)
	self:moveCollision(dt)
end

function Projectile:draw(debug)
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

return  Projectile