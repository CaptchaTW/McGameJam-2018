local Timer = require 'lib.timer'
local class = require 'lib.middleclass'


local Camera = class("Camera")


function Camera:initialize(world, x, y, w, h)
	self.world = world
	self.x = x 
	self.y = y 
	self.w = w
	self.h = h
	self.Ox = 0 
	self.Oy = 0
	self.Gx = 0
	self.Gy = 0
	self.Wx = 0
	self.Wy = 0
	self.WScale = 1 
	self.scale = 1
end


function Camera:adjustPosition()
		self.Gx = self.x 
		self.Gy = self.y 
end

function Camera:setPosition(x, y)
	self.x = x 
	self.y = y
	self:adjustPosition()
end

function Camera:getPosition()
	return self.x, self.y 
end

function Camera:setScale(scale)
	self.scale = scale
end

function Camera:getScale()
	return self.scale 
end

function Camera:setCenter(x, y)
	local x = -x + self.w/2
	local y = -y + self.h/2

	self:setPosition(x, y)

end

function Camera:getCenter()
	return -self.Gx + self.w/2 , -self.Gy + self.h/2
end

function Camera:getAspectRatioScale(wx, wy)
	local sfx, sfy
  if wx > self.w and wy > self.h then 
    sfx = wx / self.w
    sfy = wy / self.h

    if sfx > sfy then sfx = sfy end
    if sfy > sfx then sfy = sfx end
  end
  return sfx or 1
end

function Camera:resize(w, h)

	self.WScale = self:getAspectRatioScale(w, h)

	local new_w = self.w*self.WScale
	local new_h = self.h*self.WScale
	local new_x = (love.graphics.getWidth() - new_w) / 2
	local new_y = (love.graphics.getHeight() - new_h) / 2 

	self.Wx = new_x 
	self.Wy = new_y 

end

function Camera:getScreenInfo()
	return self.Wx, self.Wy, self.WScale
end

function Camera:screenShake(duration, xmagnitude, ymagnitude)
	self.timer:during(duration, function() 
		local dx = love.math.random(-xmagnitude, xmagnitude)
		local dy = love.math.random(-ymagnitude, ymagnitude)
		self.Ox = dx 
		self.Oy = dy
		end, function() 
		self.Ox = 0
		self.Oy = 0
		end)

end


function Camera:update(dt)
	self.timer:update(dt)
	self.ambientParticles:update(dt)
end


local tempcanvas = love.graphics.newCanvas()
function Camera:draw( entities, lights, debug)
	lg = love.graphics
	local current_canvas = lg.getCanvas()

	lg.setCanvas(tempcanvas)
	lg.clear()
	lg.setBlendMode("alpha")
	-- Scale map to 1.0 to draw onto canvas, this fixes tearing issues
	-- Map is translated to correct position so the right section is drawn
	lg.push()

	lg.translate(self.Gx, self.Gy)
	
	local visibleThings, len = self.world:queryRect(x,y,w,h)
  for i=1, len do
    visibleThings[i]:draw(dt)
  end

  lg.pop()

	-- Draw canvas at 0,0; this fixes scissoring issues
	-- Map is scaled to correct scale so the right section is shown
	lg.push()
	lg.origin()
	lg.translate(self.Wx, self.Wy)
	lg.scale(self.WScale or 1, self.WScale or 1)
	lg.setCanvas(current_canvas)
	lg.draw(tempcanvas)

	lg.pop()

end

return Camera