--LSynth Demo
local LSynth = require("LSynth")

function love.load()
	LSynth:initialize(4)
end

function love.draw()

end

function love.update(dt)
	LSynth:update(dt)
end

function love.keypressed(key,isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end

function love.threaderror(thread, errorstr)
	error("Thread error ("..tostring(thread).."): "..tostring(errorstr))
end