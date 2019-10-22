# NoHighDPI
Disable High DPI scaling on Android devices.

### How to use

You just need to do this:
```lua
nohdpi = require "nohighdpi"

function love.load()
    --Pass "graphics", "mouse" and/or "touch"
    --as arguments to replace the given modules.
    --If you don't give any arguments, then
    --all modules will be replaced.
    nohdpi.replace()
end
```
Now you can use LÖVE normally.

### Manual Mode

If you don't want to replace the modules, you can use the library manually.
```lua
nohdpi = require "nohighdpi"

function love.load()

end

function love.draw()
    --You can optionally give a custom resolution
    nohdpi.start(800, 600)
    
    --Draw your things here
    love.graphics.circle("line", nohdpi:mouseX(), nohdpi:mouseY(), 5, 100)
    
    local touches = love.touch.getTouches()
    for i, id in pairs(touches) do
        local x, y = nohdpi.touchPosition(id)
        love.graphics.circle("fill", x, y, 8, 100)
    end
    
    --You can also change the resolution
    nohdpi.rescale(1000, 675)
    
    nohdpi.stop()
end

function love.update(dt)

end

function love.mousepressed(x, y, button, isTouch)
    x, y = nohdpi.toResized(x, y)
    
    --Use it normally. The same goes to mousereleased, touchpressed, touchreleased...
end
```


##### Using only the "graphics" manually
```lua
nohdpi = require "nohighdpi"

function love.load()
    nohdpi.replace("mouse", "touch")
end

function love.draw()
    nohdpi.start()

    love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), 5, 100)
 
    nohdpi.stop()
end

function love.update(dt)

end

function love.mousepressed(x, y, button, isTouch)
    
end
```

### Functions
```lua
nohdpi.replace(...)           --Replace "graphics", "mouse" and/or "touch" modules with the following functions

nohdpi.start(width, height)   --Start scaling using the given resolution

nohdpi.stop()                 --Stop scaling

nohdpi.rescale(width, height) --Change resolution

nohdpi.mouseX()               --Scaled X mouse position

nohdpi.mouseY()               --Scaled Y mouse position

nohdpi.mousePosition()        --Scaled X and Y mouse positions

nohdpi.touchPosition(id)      --Scaled X and Y touch positions

nohdpi.toScaled(x, y)         --Convert real coordinates to scaled coordinates

nohdpi.toReal(x, y)           --Convert scaled coordinates to real coordinates
```

## Notes
This library may not work properly if you're using hump gamestate in automatic mode (calling registerEvents), you need to use it manually:

```lua
nohdpi = require "nohighdpi"
gamestate = require "hump.gamestate"

function love.load()
    nohdpi.replace()
    gamestate.switch(something)
end

function love.draw()
    gamestate.draw()
end

function love.update(dt)
    gamestate.update(dt)
end

function love.mousepressed(x, y, button, isTouch)
    gamestate.mousepressed(x, y, button, isTouch)
end
