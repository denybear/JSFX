-- MAIN
script_name = "Deny"

-- NEED TO RUN MULTIPLE INSTANCES OF THE SCRIPT UPON MIDI PRESS: HOW TO DO???
-- test "number of bars" presence and set to starting value
if not reaper.HasExtState(script_name, "rwd_number_of_bars") then
	bar_number = 0
else
	bar_number = tonumber (reaper.GetExtState(script_name, "rwd_number_of_bars"))
	bar_number = bar_number + 1
	-- if more than 4 bars to rewind, then reset number of bars to 0 (to make sure we don't go into infinite loop)
	if (bar_number > 4) then
		bar_number = 0
	end
end

-- save state in memory to reuse it at a later stage (when the action is called again)
reaper.SetExtState(script_name, "rwd_number_of_bars", tostring (bar_number), false)

-- if rewind is pressed multiple times (multiple instances), only the first instance counts; the other instances are stopped
if (bar_number > 0) then
	goto exit
end

local pos = reaper.GetPlayPosition()

-- Get current time signature and tempo at play position
local ts_num, ts_denom = reaper.TimeMap_GetTimeSigAtTime(0, pos)
local tempo = reaper.Master_GetTempo() -- bpm

-- Calculate beats per bar, convert to quarter notes duration
local beats_per_bar = ts_num * (4 / ts_denom)
local beat_length_sec = 60 / tempo  -- duration of quarter note in seconds
bar_length_sec = beats_per_bar * beat_length_sec

-- Calculate the start of the current bar
-- TimeMap_QNToTime converts quarter notes (QN) to seconds
-- We first get the current quarter note position, then find the bar start

local qn_pos = reaper.TimeMap2_timeToQN(0, pos)
local qn_bar_start = math.floor(qn_pos / beats_per_bar) * beats_per_bar
bar_start_sec = reaper.TimeMap2_QNToTime(0, qn_bar_start)
next_bar_start_sec = bar_start_sec + bar_length_sec


-- Rewind by "bar_number" only after the current bar is finished in REAPER
function rewind_loop()
	-- current play position
	local pos = reaper.GetPlayPosition()
	-- rewind of bar_number bars
	local bar_number = tonumber (reaper.GetExtState(script_name, "rwd_number_of_bars"))

	
	if pos < next_bar_start_sec then
		-- Current bar not finished yet, do nothing or optionally notify
		-- You can print a message or simply skip rewinding
		-- reaper.ShowConsoleMsg("Current bar not finished yet, rewind skipped.")
		reaper.defer(rewind_loop) -- avoid script from closing immediately
	else
		-- Current bar finished or at end; rewind by "bar_number" full bars
		reaper.DeleteExtState(script_name, "rwd_number_of_bars", false)		-- delete number of bars to rewind
		local new_pos = bar_start_sec - (bar_length_sec * bar_number)

		if new_pos < 0 then new_pos = 0 end -- Don't go before start of timeline
		reaper.SetEditCurPos(new_pos, true, true) -- move play cursor and seek play position
	end
end

rewind_loop ()

-- terminate script
:: exit ::

