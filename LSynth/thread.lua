--The chip thread

--TODO: Make sure the parameters explaination is correct after testing them.

--[[
- path (string): The library require path.
- dir (string): The directory of the library.
- channels (number): (unsigned int) The number of channels to have, by default it's 4.
- sampleRate (number): (unsigned int) The sample rate to operate on, by default it's 44100 on PC, and 22050 on mobile.
- bitDepth (number): (unsigned int) The bitdepth of the generated samples, by default it's 8 (for fantasy reasons).
- bufferLength (number): (unsigned float) The length of the buffer in seconds, by default it's 1/60.
- piecesCount (number): (unsigned int) The number of pieces to divide the buffer into, affects responsivity, by default it's 4.
- inChannel (userdata): (love channel) The input channel, recieves data from the main thread.
]]
local path, dir, channels, sampleRate, bitDepth, bufferLength, piecesCount, inChannel = ...

--Load love modules
require("love.timer")
require("love.sound")
require("love.audio")

--== Localize Lua APIs ==--
local floor = math.floor

--== Constants ==--
local pieceSamplesCount = floor((bufferLength*sampleRate)/piecesCount) --The length of buffer pieces in samples.
local bufferSamplesCount = pieceSamplesCount*piecesCount --The length of the buffer in samples.

--== Variables ==--
local channelStore = {} --Stores each channel parameters.

--== Initialize ==--
math.randomseed(love.timer.getTime()) --Set the random seed, for the noise generators to work.

for i=1, channels do
	channelStore[i] = {
		queueableSource = love.audio.newQueueableSource(sampleRate, bitDepth, 2, piecesCount), --Create the queueable source.
		soundDatas = {}, --The sounddata pieces.
		currentSoundData = 1, --The index of the sounddata piece to override next.
	}

	--Create the buffers' sounddata pieces.
	for j=1, piecesCount do
		channelStore[i].soundDatas[j] = love.sound.newSoundData(pieceSamplesCount, sampleRate, bitDepth, 2)
	end
end