--The chip thread

--TODO: Make sure the parameters explaination is correct after testing them.

--[[
- path (string): The library require path.
- dir (string): The directory of the library.
- channels (number): (unsigned int) The number of channels to have, by default it's 4.
- sampleRate (number): (unsigned int) The sample rate to operate on, by default it's 44100 on PC, and 22050 on mobile.
- bitDepth (number): (unsigned int) The bitdepth of the generated samples, by default it's 8 (for fantasy reasons).
- bufferLength (number): (unsigned float) The length of the buffer in seconds, affects responsivity and pops/clicks, by default it's 1/15.
- piecesCount (number): (unsigned int) The number of pieces to divide the buffer into, affects pops/clicks, by default it's 4.
- inChannel (userdata): (love channel) The input channel, recieves data from the main thread.
]]
local path, dir, channels, sampleRate, bitDepth, bufferLength, piecesCount, inChannel = ...

--Load love modules
require("love.timer")
require("love.sound")
require("love.audio")

--== Load sub modules ==--
local waveforms = love.filesystem.load(dir.."/waveforms.lua")(channels)

--== Localize Lua APIs ==--
local floor, min, max = math.floor, math.min, math.max

--== Constants ==--
local pieceSamplesCount = floor((bufferLength*sampleRate)/piecesCount) --The length of buffer pieces in samples.
local bufferSamplesCount = pieceSamplesCount*piecesCount --The length of the buffer in samples.
--Please note that the bufferSamplesCount is not the same of (bufferLength*sampleRate),
--The buffersSamplesCount makes sure that the buffer is perfect multiplication of the pieceSamplesCount.

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

--Setup the initial channels states
for i=0, channels-1 do
	channelStore[i] = {
		waveform = 3,
		panning = 0, --[-1]: Left, [+1]: Right, [0]: Center
		frequency = 100,
		period = 0,
		periodStep = 1/(sampleRate/40000)
	}
end

--== Parameters Controller ==--

--Return the parameters for the next sample to generate.
--Parameters: The chunnel ID.
--Returns: period, waveform, panning.
local function nextParameters(channelID)
	local channelData = channelStore[channelID]

	local waveform = channelData.waveform
	local panning = channelData.panning
	local period = channelData.period
	local reset = channelData.reset

	channelData.reset = false

	local nextPeriod = period + channelData.periodStep
	if nextPeriod >= 1 then --Reset the period once it reaches 1
		nextPeriod = nextPeriod-floor(nextPeriod)
		channelData.reset = true
	end
	channelData.period = nextPeriod

	return period, reset, waveform, panning
end

--== Thread Loop ==--
while true do
	--Override played sounddatas
	for i=1, queueableSource:getFreeBufferCount() do
		local soundData = soundDatas[currentSoundData] --The sounddata to override
		currentSoundData = (currentSoundData+1)%piecesCount --The id of the next sounddata to override

		--Loop for each sample in this sounddata
		for j=0, pieceSamplesCount-1 do
			local leftSample, rightSample = 0, 0 --Holds the sum of all the channels for each side

			for k=0, channels-1 do --K is the current channel we're generating
				--Get the parameters
				local period, reset, waveform, panning = nextParameters(k)

				--Sum the channel values
				leftSample = leftSample + waveforms[waveform](period, reset, k)*(1-(panning+1)*0.5)
				rightSample = rightSample + waveforms[waveform](period, reset, k)*((panning+1)*0.5)
			end

			leftSample = max(min(leftSample,1),-1) --Clamp the sum
			rightSample = max(min(rightSample,1),-1) --Clamp the sum

			--Set the samples
			soundData:setSample(j,1,leftSample) --Left
			soundData:setSample(j,2,rightSample) --Right
		end

		queueableSource:queue(soundData) --Queue the overridden sounddata
	end

	queueableSource:play() --Make sure that the queueableSource is playing.

	--TODO: The sleep time should be dynamic
	love.timer.sleep(bufferLength/4) --Give the CPU some reset
end