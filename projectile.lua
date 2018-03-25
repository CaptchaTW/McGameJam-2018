local class = require 'lib.middleclass'
local Entity = require 'entity'
local anim8 = require 'lib.anim8'
local Timer = require 'lib.timer'


local lazerimg = love.graphics.newImage('sprites/lazer.png')
local grid = anim8.newGrid(1000, 60, lazerimg:getWidth(), lazerimg:getHeight())
local lazeranim = anim8.newAnimation(grid(1, '1-4'), 0.1)

local vineimg = love.graphics.newImage('sprites/fourthformvine.png')
local vinegrid = anim8.newGrid(32, 128, vineimg:getWidth(), vineimg:getHeight())
 
local img = love.graphics.newImage('sprites/secondformimpactwave.png')
local grid = anim8.newGrid(16, 16, img:getWidth(), img:getHeight())

local Projectile = class ("Projectile", Entity)


function Projectile:initialize( world, x, y, w, h, dx, dy, type)
  Entity.initialize(self, world, x, y, w, h)
	self.x = x 
	self.y = y
	self.dx = dx or 0
	self.dy = dy or 0
	self.damaging = true
	self.projectile = true
	self.timer = Timer()
	self.type = type

	if self.type == 'lazer' then
		self.timer:after(0.4, function() self:destroy() self.dying = true end)
		self.anim = lazeranim
	elseif self.type == 'vine' then 
		self.damaging = false
		self.anim = anim8.newAnimation(vinegrid('1-11', 1), 0.1)
		self.anim:gotoFrame(1)
		self.timer:after(0.2, function() self.damaging = true self.passable = true end)
		self.timer:after(0.8, function() self.damaging = false self.passable = false end)
		self.timer:after(1.1, function() self:destroy() self.dying = true end)
	else
		self.anim = anim8.newAnimation(grid('1-5', 1), 0.1, 'pauseAtEnd')
		if self.dx > 0 then 
			self.Sx = 1 
		else
			self.Sx = -1 
		end
  	self.timer:after(10, function() self:destroy() self.dying = true end)
  end
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
	if self.anim then self.anim:update(dt) end
end

function Projectile:draw(debug)

	if self.type == 'lazer' then 
		self.anim:draw(lazerimg, self.x, self.y-30)
	elseif self.type == 'vine' then
		self.anim:draw(vineimg, self.x-18, self.y)
	else
		self.anim:draw(img, self.x, self.y, 0, self.Sx, 1)
	end

end

return  Projectile