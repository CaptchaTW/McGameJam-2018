local class = require 'lib.middleclass'
local Entity = require 'entity'
local Timer = require 'lib.timer'

local Weakpoint = class ("Weakpoint", Entity)


function Weakpoint:initialize( world, parent, x, y, w, h)
  Entity.initialize(self, world, x, y, w, h)
	self.x = x 
	self.y = y
	self.parent = parent
	self.dx = dx or 0
	self.dy = dy or 0
	self.weakpoint = true
	self.passable = true
	self.timer = Timer()
end

function Weakpoint:update(dt)
	self.timer:update(dt)
		local x, y = self.parent:getCenter()
	if self.parent.Sx == 1 then
		self.x = x + 10
		self.y = self.parent.y +20
	else
		self.x = x - 20
		self.y = self.parent.y +20
	end
	self.world:update(self, self.x, self.y)
end

function Weakpoint:draw(dt)
	--love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
end

function Weakpoint:hit()
	self.parent:gotoState('OnHit')
end


return  Weakpoint