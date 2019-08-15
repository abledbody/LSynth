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

--== Load sub modules ==--
local waveforms = require(path..".waveforms")

--== Localize Lua APIs ==--
local floor, min, max = math.floor, math.min, math.max

--== Constants ==--
local pieceSamplesCount = floor((bufferLength*sampleRate)/piecesCount) --The length of buffer pieces in samples.
local bufferSamplesCount = pieceSamplesCount*piecesCount --The length of the buffer in samples.

--== Variables ==--
local channelStore = {} --Stores each channel parameters.
local soundDatas = {} --The generated soundData pieces.
local currentSoundData = 0 --The index of the sounddata piece to override next.
local queueableSource = love.audio.newQueueableSource(sampleRate, bitDepth, 2, piecesCount) --Create the queueable source.

--== Initialize ==--
math.randomseed(love.timer.getTime()) --Set the random seed, for the noise generators to work.

--Create the buffer's sounddata pieces.
for i=0, piecesCount-1 do
	soundDatas[i] = love.sound.newSoundData(pieceSamplesCount, sampleRate, bitDepth, 2)
end

--TODO
local period = 1
local freq = 100
local wv = 0
local pstep = 1/(sampleRate/freq)

--== Thread Loop ==--
while true do
	--Override played sounddatas
	for i=1, queueableSource:getFreeBufferCount() do
		local soundData = soundDatas[currentSoundData]
		currentSoundData = (currentSoundData+1)%piecesCount

		for j=0, pieceSamplesCount-1 do
			if period >= 1 then period = 0 end

			local sample = 0

			for k=0,channels-1 do
				sample = sample + waveforms[wv](period)
			end

			soundData:setSample(j,1,max(min(sample,1),-1))

			period = period + pstep
		end

		queueableSource:queue(soundData)
	end

	queueableSource:play() --Make sure that the queueableSource is playing.

	love.timer.sleep(1/60)
end