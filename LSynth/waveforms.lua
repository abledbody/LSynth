--Waveforms samples generators
local waveforms = {}

--[[
Supported waveforms:
--------------------

0 Sine
1 Triangle
2 Half-Rectified Sine
3 Square
4 Pulse
5 Saw
6 Noise
7 Custom

About Waveform data argument:
-----------------------------
Contains custom data for the waveform, used for the custom waveform ONLY.
]]

--== Localized Lua APIs ==--
local sin, random = math.sin, math.random

--== Shared Constants ==--
local pi, pi2 = math.pi, math.pi*2

--Sine
waveforms[0] = function(period)
	return sin(period*pi2)
end

--Triangle
waveforms[1] = function(period)
	return period < 0.5 and period*4-1 or 1-(period-0.5)*4
end

--Half-Rectified Sine
waveforms[2] = function(period)
	return period < 0.5 and 0 or sin(period*pi2)
end

--Square
waveforms[3] = function(period)
	return period < 0.5 and 1 or -1
end

--Pulse
waveforms[4] = function(period)
	return period < 0.25 and 1 or -1
end

--Saw
waveforms[5] = function(period)
	return period*2-1
end

--== Noise Variables ==--
local noiseRateModifier = 2 --Defines how many times the sample value will change in each noise cylce
local noiseValue = 0
local noisePeriodOffset = 0

--Noise
waveforms[6] = function(period)
	if period == 0 then noisePeriodOffset = 0 end --Reset at each new cycle

	period = period*noiseRateModifier - noisePeriodOffset

	if period >= 0 then
		noiseValue = random()*2-1 --New random value
		noisePeriodOffset = noisePeriodOffset+floor(period)+1 --Update the offset
	end

	return noiseValue
end

--== Custom Variables ==--
local currentData = {}
local dataSamplesCount = 0

--Custom
waveforms[7] = function(period,data)
	if currentData ~= data then
		currentData = data --Update the current data
		dataSamplesCount = #data --Update data samples count
	end

	return data[1+floor(period*dataSamplesCount)]
end

return waveforms