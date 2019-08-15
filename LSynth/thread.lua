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
local floor = math.floor

--== Constants ==--
local pieceSamplesCount = floor((bufferLength*sampleRate)/piecesCount) --The length of buffer pieces in samples.
local bufferSamplesCount = pieceSamplesCount*piecesCount --The length of the buffer in samples.

--== Variables ==--
local channelStore = {} --Stores each channel parameters.
local queuelableSources = {} --Stores each channel queueable source, indexed by 1.

--== Initialize ==--
math.randomseed(love.timer.getTime()) --Set the random seed, for the noise generators to work.

for i=0, channels-1 do
	queuelableSources[i+1] = love.audio.newQueueableSource(sampleRate, bitDepth, 2, piecesCount) --Create the queueable source.

	channelStore[i] = {
		soundDatas = {}, --The sounddata pieces.
		currentSoundData = 0, --The index of the sounddata piece to override next.
	}

	--Create the buffers' sounddata pieces.
	for j=0, piecesCount-1 do
		channelStore[i].soundDatas[j] = love.sound.newSoundData(pieceSamplesCount, sampleRate, bitDepth, 2)
	end
end

--TODO
local period = 1
local freq = 100
local wv = 0
local pstep = 1/(sampleRate/freq)

--== Thread Loop ==--
while true do
	for i=0, channels-1 do
		--Localize channel data
		local queueableSource = queuelableSources[i+1]
		local soundDatas = channelStore[i].soundDatas
		local currentSoundData = channelStore[i].currentSoundData
		
		--Override played sounddatas
		for j=1, queueableSource:getFreeBufferCount() do
			local soundData = soundDatas[currentSoundData]
			currentSoundData = (currentSoundData+1)%piecesCount

			for k=0, pieceSamplesCount-1 do
				if period >= 1 then
					soundData:setSample(k,1,waveforms[wv](0))
					period = 0
				else
					soundData:setSample(k,1,waveforms[wv](period))
				end
				period = period + pstep
			end

			queueableSource:queue(soundData)
		end

		queueableSource:play() --Make sure that the queueableSource is playing.

		--Update value
		channelStore[i].currentSoundData = currentSoundData
	end

	--Play all the channels at the same time, and make sure they are synced.
	love.audio.play(queuelableSources)

	love.timer.sleep(1/60)
end