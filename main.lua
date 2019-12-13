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

		LSynth:setPanning(0, 0)
		LSynth:setAmplitude(0, 1)
		LSynth:setFrequency(0, 200)
		LSynth:setWaveform(0,0)
		LSynth:enable(0)
		for i=0, 200 do
			LSynth:wait(0,0.125)
			LSynth:setFrequency(0, 250 + i*10)
			LSynth:setPanning(0, i%3-1)
		end
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