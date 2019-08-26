local nohdpi = {}

local min, max, floor = math.min, math.max, math.floor

local getWidth = love.graphics.getWidth
local getHeight = love.graphics.getHeight
local fromPixels = love.window.fromPixels
local toPixels = love.window.toPixels
local mousegetX = love.mouse.getX
local mousegetY = love.mouse.getY
local mousegetPosition = love.mouse.getPosition
local touchgetPosition = love.touch.getPosition

local NULL = function()end
local resized = false
local olddraw
local oldmousepressed
local oldmousereleased
local oldmousemoved
local oldtouchpressed
local oldtouchreleased
local oldtouchmoved

local replaced = {["graphics"] = false, ["mouse"] = false, ["touch"] = false}

local scalerW, scalerH = 1, 1

if love.system.getOS() ~= "Android" then
	local func = function(x,y) return x, y end
	
	fromPixels, toPixels = func, func
end

function nohdpi:start(width, height)
	assert(not resized, "Missing \"stop\" function")

	width = width or getWidth()
	height = height or getHeight()
	scalerW, scalerH = width/getWidth(), height/getHeight()
	
	love.graphics.scale(fromPixels(scalerW, scalerH))
	resized = true
end

function nohdpi:stop()
	assert(resized, "Missing \"start\" function")
	love.graphics.scale(toPixels(1/scalerW, 1/scalerH))
	resized = false
end

function nohdpi:toResized(x,y)
	x, y = toPixels(x,y)
	x = x / scalerW
	if y then
		y = y / scalerH
		return x, y
	end
	return x
end

function nohdpi:toReal(x,y)
	x, y = fromPixels(x,y)
	x = x * scalerW
	if y then
		y = y * scalerH
		return x, y
	end
	return x
end

function nohdpi:rescale(width, height)
	if not resized then return end
	self.stop()
	self.start(self,width,height)
end

function nohdpi:mouseX()
	return floor(toPixels(mousegetX()) / scalerW)
end

function nohdpi:mouseY()
	return floor(toPixels(mousegetY()) / scalerH)
end

function nohdpi:mousePosition()
	local x, y = mousegetPosition()
	x, y = floor(toPixels(x) / scalerW), floor(toPixels(y) / scalerH)
	return x, y
end

function nohdpi.touchPosition(id)
	local x, y = touchgetPosition(id)
	x, y = floor(toPixels(x) / scalerW), floor(toPixels(y) / scalerH)
	return x, y
end


function nohdpi:replace(...)
	local modules = {...}
	if #modules == 0 then modules = {"graphics","mouse","touch"} end
	for i, event in ipairs(modules) do
	
		replaced[i] = true
		
		if event == "graphics" and not replaced["graphics"] then
			--draw
			olddraw = love.draw or NULL
			love.draw = function()
				self.start()
				olddraw()
				self.stop()
			end
		end
	
		if event == "mouse" and not replaced["mouse"] then
			love.mouse.getX = self.mouseX
			love.mouse.getY = self.mouseY
			love.mouse.getPosition = self.mousePosition
			
			--mousepressed
			oldmousepressed = love.mousepressed or NULL
			love.mousepressed = function(x,y,button,isTouch,presses)
				x, y = floor(toPixels(x) / scalerW), floor(toPixels(y) / scalerH)
				oldmousepressed(x,y,button,isTouch,presses)
			end
			
			--mousereleased
			oldmousereleased = love.mousereleased or NULL
			love.mousereleased = function(x,y,button,isTouch,presses)
				x, y = floor(toPixels(x) / scalerW), floor(toPixels(y) / scalerH)
				oldmousereleased(x,y,button,isTouch,presses)
			end
			
			--mousemoved
			oldmousemoved = love.mousemoved or NULL
			love.mousemoved = function(x,y,dx,dy,isTouch)
				x, y = floor(toPixels(x) / scalerW), floor(toPixels(y) / scalerH)
				dx, dy = floor(toPixels(dx) / scalerW), floor(toPixels(dy) / scalerH)
				oldmousemoved(x,y,dx,dy,isTouch)
			end
		end
	
		if event == "touch" and not replaced["touch"] then
			love.touch.getPosition = self.touchPosition
			
			--touchpressed
			oldtouchpressed = love.touchpressed or NULL
			love.touchpressed = function(id,x,y,dx,dy,pressure)
				x, y = floor(toPixels(x) / scalerW), floor(toPixels(y) / scalerH)
				dx, dy = floor(toPixels(dx) / scalerW), floor(toPixels(dy) / scalerH)
				oldtouchpressed(id,x,y,dx,dy,pressure)
			end
			
			--touchreleased
			oldtouchreleased = love.touchreleased or NULL
			love.touchreleased = function(id,x,y,dx,dy,pressure)
				x, y = floor(toPixels(x) * scalerW), floor(toPixels(y) / scalerH)
				dx, dy = floor(toPixels(dx) / scalerW), floor(toPixels(dy) / scalerH)
				oldtouchreleased(id,x,y,dx,dy,pressure)
			end
			
			--touchmoved
			oldtouchmoved = love.touchmoved or NULL
			love.touchmoved = function(id,x,y,dx,dy,pressure)
				x, y = floor(toPixels(x) / scalerW), floor(toPixels(y) / scalerH)
				dx, dy = floor(toPixels(dx) / scalerW), floor(toPixels(dy) / scalerH)
				oldtouchmoved(id,x,y,dx,dy,pressure)
			end
		end
	end
end

return nohdpi
