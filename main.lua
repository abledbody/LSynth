--LSynth Demo
local LSynth = require("LSynth")

function love.load()
	
end

function love.draw()

end

function love.update(dt)
	if LSynth.initialized then LSynth:update(dt) end

	if love.keyboard.isDown("space") and not LSynth.initialized then
		LSynth:initialize(2)
	elseif LSynth.initialized and not love.keyboard.isDown("space") then
		love.event.quit()
	end
end

function love.keypressed(key,isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end

function love.threaderror(thread, errorstr)
	error("Thread error ("..tostring(thread).."): "..tostring(errorstr))
end