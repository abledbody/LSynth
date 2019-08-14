--The chip thread

--[[
- channels (number): (unsigned int)
- sampleRate (number): (unsigned int) The sample rate to operate on, note that SFXR mode only supports 44100 and 22050.
	By default it's 44100 on PC, and 22050 on mobile.
- bufferLength (number): (unsigned float) The length of the buffer in seconds, by defaults it's 1/60.
- piecesCount (number): (unsigned int) The number of pieces to divide the buffer into, affects responsivity, by default it's 4.
- inChannel (userdata): (love channel) The input channel, recieves data from the main thread.
]]
local channels, sampleRate, bufferLength, piecesCount, inChannel = ...

--Load love modules
require("love.timer")
require("love.sound")
require("love.audio")