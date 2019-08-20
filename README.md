# NoHighDPI
Disable High DPI scaling on Android devices.

### How to use

```lua
nohdpi = require "nohighdpi"

function love.load()
    --Pass "graphics", "mouse" and/or "touch"
    --as arguments to replace the given modules.
    --If you don't give any arguments, then
    --all modules will be replaced.
    nohighdpi:replace()
end
```

### Manual Mode
```lua
nohdpi = require "nohighdpi"

function love.load()

end

function love.draw()
    --You can optionally give a custom resolution
    nohdpi:start(800, 600)
    
    --Draw your things here
    love.graphics.circle("line", nohdpi:mouseX(), nohdpi:mouseY(), 5, 100)

    --You can also change the resolution
    nohdpi:rescale(1000, 675)
    
    nohdpi:stop()
end

function love.update(dt)

end

function love.mousepressed(x, y, button, isTouch)
    x, y = nohdpi:toResized(x, y)
    
    --Use it normally. The same goes to mousereleased, touchpressed, touchreleased...
end
```


##### Using only the "graphics" manually
```lua
nohdpi = require "nohighdpi"

function love.load()
    nohdpi:replace("mouse", "touch")
end

function love.draw()
    nohdpi:start()

    love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), 5, 100)
 
    nohdpi:stop()
end

function love.update(dt)

end

function love.mousepressed(x, y, button, isTouch)
    
end
```
