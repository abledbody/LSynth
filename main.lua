--LSynth Demo
local LSynth = require("LSynth")

local speed = 4

function love.load()
	
end

function love.draw()

end

function moreData()
	LSynth:setPanningSlide(0, 1*speed, 1)
	LSynth:wait(0,2/speed)
	LSynth:request(0)
	LSynth:setPanningSlide(0, -1*speed, -1)
	LSynth:wait(0,2/speed)
end

function love.update(dt)
	if LSynth.initialized then LSynth:update(dt) end

	if love.keyboard.isDown("space") and not LSynth.initialized then
		LSynth:initialize(moreData, 2)

		LSynth:forceSetPanning(0, -1)
		LSynth:setAmplitude(0, 1)
		LSynth:setFrequency(0, 20)
		LSynth:setFrequencySlide(0, 100, 500)
		LSynth:setWaveform(0,2)
		LSynth:enable(0)
		
		moreData()

	elseif LSynth.initialized and not love.keyboard.isDown("space") then
		love.event.quit()
	end
end

function love.keypressed(key,isrepeat)
	if key == "escape" then
		love.event.quit()
	elseif key == "m" then --Mute
		for i=0, LSynth.channels-1 do
			LSynth:interrupt(i)
			LSynth:setAmplitude(i, 0)
		end
	end
end

function love.threaderror(thread, errorstr)
	error("Thread error ("..tostring(thread).."): "..tostring(errorstr))
end