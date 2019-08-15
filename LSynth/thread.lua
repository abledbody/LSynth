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
waveforms.noiseInit(channels)

--Create the buffer's sounddata pieces.
for i=0, piecesCount-1 do
	soundDatas[i] = love.sound.newSoundData(pieceSamplesCount, sampleRate, bitDepth, 2)
end

--TODO
local period = 1
local freq = 600
local wv = 6
local pstep = 1/(sampleRate/freq)
local panning = 0 --[-1]: Left, [+1]: Right, [0]: Center

--== Thread Loop ==--
while true do
	--Override played sounddatas
	for i=1, queueableSource:getFreeBufferCount() do
		local soundData = soundDatas[currentSoundData] --The sounddata to override
		currentSoundData = (currentSoundData+1)%piecesCount --The id of the next sounddata to override

		--Loop for each sample in this sounddata
		for j=0, pieceSamplesCount-1 do
			if period >= 1 then period = period - floor(period) end --Reset the period once it reaches 1

			local sample = 0 --Holds the sum of the all channels

			for k=0,channels-1 do
				sample = sample + waveforms[wv](period, k) --Sum the channel value
			end

			sample = max(min(sample,1),-1) --Clamp the sum

			--Set the sample
			soundData:setSample(j,1,sample*(1-(panning+1)*0.5)) --Left
			soundData:setSample(j,2,sample*((panning+1)*0.5)) --Right

			period = period + pstep --Increase the period
		end

		queueableSource:queue(soundData) --Queue the overridden sounddata
	end

	queueableSource:play() --Make sure that the queueableSource is playing.

	--TODO: The sleep time should be dynamic
	love.timer.sleep(1/60) --Give the CPU some reset
end