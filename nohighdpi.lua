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

local NULL = function(...) return ... end
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
local scaledWidth, scaledHeight

if love.system.getOS() ~= "Android" then
	fromPixels, toPixels = NULL, NULL
end

function nohdpi.start(width, height)
	assert(not resized, "Missing \"stop\" function")
	
	scaledWidth, scaledHeight = width, height
	width = width and fromPixels(width) or getWidth()
	height = height and fromPixels(height) or getHeight()
	scalerW, scalerH = width/getWidth(), height/getHeight()
	
	love.graphics.scale(fromPixels(scalerW, scalerH))
	resized = true
end

function nohdpi.stop()
	assert(resized, "Missing \"start\" function")
	love.graphics.scale(toPixels(1/scalerW, 1/scalerH))
	resized = false
end

function nohdpi.toResized(x,y)
	x, y = toPixels(x,y)
	x = x / scalerW
	if y then
		y = y / scalerH
		return floor(x), floor(y)
	end
	return floor(x)
end

function nohdpi.toReal(x,y)
	x, y = fromPixels(x,y)
	x = x * scalerW
	if y then
		y = y * scalerH
		return floor(x), floor(y)
	end
	return floor(x)
end

function nohdpi.rescale(width, height)
	if resized then
		nohdpi.stop()
		nohdpi.start(width,height)
	end
end

function nohdpi.mouseX()
	return floor(toPixels(mousegetX()) / scalerW)
end

function nohdpi.mouseY()
	return floor(toPixels(mousegetY()) / scalerH)
end

function nohdpi.mousePosition()
	return nohdpi.toResized(mousegetPosition())
end

function nohdpi.touchPosition(id)
	return nohdpi.toResized(touchgetPosition(id))
end


function nohdpi.replace(...)
	local modules = {...}
	if #modules == 0 then modules = {"graphics","mouse","touch"} end
	for i, event in ipairs(modules) do
		
		if event == "graphics" and not replaced["graphics"] then
			--draw
			olddraw = love.draw or NULL
			love.draw = function()
				nohdpi.start()
				olddraw()
				nohdpi.stop()
			end
		end
	
		if event == "mouse" and not replaced["mouse"] then
			love.mouse.getX = nohdpi.mouseX
			love.mouse.getY = nohdpi.mouseY
			love.mouse.getPosition = nohdpi.mousePosition
			
			--mousepressed
			oldmousepressed = love.mousepressed or NULL
			love.mousepressed = function(x,y,button,isTouch,presses)
				x, y = nohdpi.toResized(x, y)
				oldmousepressed(x,y,button,isTouch,presses)
			end
			
			--mousereleased
			oldmousereleased = love.mousereleased or NULL
			love.mousereleased = function(x,y,button,isTouch,presses)
				x, y = nohdpi.toResized(x, y)
				oldmousereleased(x,y,button,isTouch,presses)
			end
			
			--mousemoved
			oldmousemoved = love.mousemoved or NULL
			love.mousemoved = function(x,y,dx,dy,isTouch)
				x, y = nohdpi.toResized(x, y)
				dx, dy = nohdpi.toResized(dx, dy)
				oldmousemoved(x,y,dx,dy,isTouch)
			end
		end
	
		if event == "touch" and not replaced["touch"] then
			love.touch.getPosition = nohdpi.touchPosition
			
			--touchpressed
			oldtouchpressed = love.touchpressed or NULL
			love.touchpressed = function(id,x,y,dx,dy,pressure)
				x, y = nohdpi.toResized(x, y)
				dx, dy = nohdpi.toResized(dx, dy)
				oldtouchpressed(id,x,y,dx,dy,pressure)
			end
			
			--touchreleased
			oldtouchreleased = love.touchreleased or NULL
			love.touchreleased = function(id,x,y,dx,dy,pressure)
				x, y = nohdpi.toResized(x, y)
				dx, dy = nohdpi.toResized(dx, dy)
				oldtouchreleased(id,x,y,dx,dy,pressure)
			end
			
			--touchmoved
			oldtouchmoved = love.touchmoved or NULL
			love.touchmoved = function(id,x,y,dx,dy,pressure)
				x, y = nohdpi.toResized(x, y)
				dx, dy = nohdpi.toResized(dx, dy)
				oldtouchmoved(id,x,y,dx,dy,pressure)
			end
		end
		replaced[i] = true
	end
end

return nohdpi
