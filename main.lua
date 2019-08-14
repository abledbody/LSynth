--LSynth Demo
local LSynth = require("LSynth")

function love.load()

end

function love.draw()

end

function love.update(dt)
	LSynth:update(dt)
end

function love.threaderror(thread, errorstr)
	error("Thread error ("..tostring(thread).."): "..tostring(errorstr))
end