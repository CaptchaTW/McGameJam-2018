local Entity = require 'entity'
local class = require 'lib.middleclass'
local anim8 = require 'lib.anim8'
local Timer = require 'lib.timer'
local Stateful = require 'lib.stateful'

local Dust = require 'landingdust'
local Particles = require 'particles'


local Player = class('Player', Entity)
Player:include(Stateful)

local width, height = 8, 8
local attackW = 20
local friction = 0.00005

local hspeed = 75
local haccel = 500

local rollSpeed = 100

local jumpSpeed = -200
local jumpEndSpeed = -20

--animations
	love.graphics.setDefaultFilter("nearest", "nearest")

	local idle_img = love.graphics.newImage('/sprites/playeridle.png')
	local run_img = love.graphics.newImage('/sprites/playerrun.png')
	local roll_img = love.graphics.newImage('/sprites/playerrolling.png')
	local jump_img = love.graphics.newImage('/sprites/playejump.png')
	local slash_img = love.graphics.newImage('/sprites/slashing.png')

	local idle_grid = anim8.newGrid(16, 18, idle_img:getWidth(), idle_img:getHeight())
	local run_grid = anim8.newGrid(16, 18, run_img:getWidth(), run_img:getHeight())
	local roll_grid = anim8.newGrid(16, 18, roll_img:getWidth(), roll_img:getHeight())
	local jump_grid = anim8.newGrid(16, 18, jump_img:getWidth(), jump_img:getHeight())
	local slash_grid = anim8.newGrid(16, 16, slash_img:getWidth(), slash_img:getHeight())

	local idle_anim = anim8.newAnimation(idle_grid(1, 1), 1, "pauseAtEnd")
	local run_anim = anim8.newAnimation(run_grid(1, '1-7'), 0.1)
	local roll_anim = anim8.newAnimation(roll_grid(1, '1-6'), 0.1)
	local jump_anim = anim8.newAnimation(jump_grid(1, '1-5'), 0.15, "pauseAtEnd")
	local slash_anim = anim8.newAnimation(slash_grid('1-4', 1), 0.1)
	local slash_anim2 = anim8.newAnimation(slash_grid('1-4', 2), 0.1)

function Player:initialize(world, x,y)
  Entity.initialize(self, world, x, y, width, height)
  self.world = world
	self.anim = jump_anim
	self.img = jump_img
	self.timer = Timer()
	self.Sx = 1
	self.particles = Particles:new(self.x, self.y)
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

	if key == 'k' then 
		self:attack()
	end

end

function Player:jump()
end

function Player:roll()
end

function Player:attack()

	if self.attacking then return false end

slash_anim:gotoFrame(1)
self.timer:after(0.2, function() 

	local x, y = self:getCenter()
	local things, len
	if self.Sx > 0 then 
	 	things, len = self.world:queryRect(x, y-9, 16, 12)
	else
		things, len = self.world:queryRect(x-16, y-9, 16, 12)
	end

	for i=1, len do
	 	if things[i].hit then
	 		things[i]:hit()
	 	end
	end


	end)



	self.attacking = true 
	self.timer:after(0.4, function() self.attacking = false end)
end

function Player:keyreleased(key)
	if key == 'space' and self.dy < jumpEndSpeed then 
		self.dy = jumpEndSpeed 
	end
end

function Player:checkOnGround(ny)
  if ny < 0  then 
  	self:gotoState('OnGround')
  end
end

function Player:filter(other)
	if other.passable then 
		return false 
	else
		return 'slide'
	end
end

function Player:moveCollision(dt)

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

	local x, y = self:getCenter()
	self.particles:emit(1, x, y)


	self:input(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self:moveCollision(dt)
	self.timer:update(dt)
	self.anim:update(dt)
	self.particles:update(dt)
	if self.attacking then 
		slash_anim:update(dt)
	end
end

function Player:draw()

	self.particles:draw()

	self.anim:draw(self.img, self.x+4, self.y, 0, self.Sx, 1, 8, 9)

	if self.attacking then 
			slash_anim:draw(slash_img, self.x+4,self.y, 0, self.Sx, 1, 0, 8)
	end

	local x, y = self:getCenter()

--	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
--	love.graphics.rectangle('line', x, y-9, 16, 12)

end

local OnGround = Player:addState('OnGround')

function OnGround:enteredState()
	local x, y = self:getCenter()
	Dust:new(self.world, x, y)

	self.particles:emit(10, x, y + 4)
end

function OnGround:checkOnGround()
end

function OnGround:jump()
		self.dy = jumpSpeed
		self:gotoState(nil)
		self.anim = jump_anim 
		self.img = jump_img 
		self.anim:gotoFrame(1)
		self.anim:resume()
end

function OnGround:roll()
	self:gotoState('Rolling')
end

function OnGround:applyMovement(dt)

			local dx, dy = self.dx, self.dy

			if self.leftKey then
				if dx > -hspeed  then 
					dx = dx - haccel * dt
				end
				self.Sx = -1 
				self.img = run_img 
				self.anim = run_anim
			end
			if self.rightKey then
				if dx < hspeed  then
					dx = dx + haccel * dt
				end
				self.Sx = 1
				self.img = run_img 
				self.anim = run_anim
			end

			self.dx, self.dy = dx, dy


			if not (self.leftKey or self.rightKey) then
				self.dx = self.dx * math.pow(friction, dt)
				self.img = idle_img
				self.anim = idle_anim
			end
	
end



local Rolling = Player:addState('Rolling')

function Rolling:enteredState()
	self.anim = roll_anim
	self.img = roll_img
	self.anim:gotoFrame(1)
	self.timer:after(0.6, function() self:gotoState(nil) end )
end

function Rolling:checkOnGround()
end

function Rolling:jump()
		self.dy = jumpSpeed
		self:gotoState(nil)
		self.anim = jump_anim 
		self.img = jump_img 
		self.anim:gotoFrame(1)
		self.anim:resume()
end

function Rolling:applyMovement()



	if self.Sx == -1 then
		self.dx = -rollSpeed
	end
	if self.Sx == 1 then
		self.dx = rollSpeed
	end 
end


return Player