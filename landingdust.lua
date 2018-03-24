local class = require 'lib.middleclass'
local Entity = require 'entity'
local anim8 = require 'lib.anim8'
local Timer = require 'lib.timer'

local Dust = class ("Dust", Entity)

local img = love.graphics.newImage("sprites/landingdust.png")

local w = 16
local h = 16

function Dust:initialize( world, x, y)
  Entity.initialize(self, world, x, y, w, h)
	self.x = x 
	self.y = y
	self.passable = true
	self.timer = Timer()

	local grid = anim8.newGrid(16, 16, img:getWidth(), img:getHeight())
	self.anim = anim8.newAnimation(grid('1-8', 1), 0.05, "pauseAtEnd")
  self.timer:after(0.5, function() self:destroy() end)
end

function Dust:update(dt)
	self.timer:update(dt)
	self.anim:update(dt)
end

function Dust:draw(debug)
	self.anim:draw(img, self.x, self.y, 0, 1, 1, w/2, 8)
end

return Dust