-- MAIN
-- MAKE SURE THE MIDI IS IN TOGGLE MODE (NOT MOMENTORY MODE)

script_name = "Rewind"
-- flag&1: script will auto-terminate if re-launched while already running
-- flag&2: if (flag&1) is set, script will re-launch after auto-terminating. otherwise, re-launch is ignored.
reaper.set_action_options(3)


-- Rewind by "bar_number" only after the current bar is finished in REAPER
function rewind_loop()
	-- current play position
	local pos = reaper.GetPlayPosition()
	-- read the other parameters to from persistant memory 
	local bar_number = tonumber (reaper.GetExtState(script_name, "bar_number"))
	local bar_length_sec = tonumber (reaper.GetExtState(script_name, "bar_length_sec"))
	local bar_start_sec = tonumber (reaper.GetExtState(script_name, "bar_start_sec"))
	local next_bar_start_sec = tonumber (reaper.GetExtState(script_name, "next_bar_start_sec"))
	
	if pos < next_bar_start_sec then
		-- Current bar not finished yet, do nothing or optionally notify
		-- You can print a message or simply skip rewinding
		-- reaper.ShowConsoleMsg("Current bar not finished yet, rewind skipped.")
		reaper.defer(rewind_loop) -- avoid script from closing immediately
	else
		-- Current bar finished or at end; rewind by "bar_number" full bars
		reaper.DeleteExtState(script_name, "bar_number", false)		-- delete number of bars to rewind
		local new_pos = bar_start_sec - (bar_length_sec * bar_number)

		if new_pos < 0 then new_pos = 0 end -- Don't go before start of timeline
		reaper.SetEditCurPos(new_pos, true, true) -- move play cursor and seek play position
	end
end


-- test "number of bars" presence and set to starting value
if not reaper.HasExtState(script_name, "bar_number") then

	-- compute start of current bar, and time for a bar
	local bar_number = 0
	local pos = reaper.GetPlayPosition()

	-- Get current time signature and tempo at play position
	local ts_num, ts_denom = reaper.TimeMap_GetTimeSigAtTime(0, pos)
	local tempo = reaper.Master_GetTempo() -- bpm

	-- Calculate beats per bar, convert to quarter notes duration
	local beats_per_bar = ts_num * (4 / ts_denom)
	local beat_length_sec = 60 / tempo  -- duration of quarter note in seconds
	local bar_length_sec = beats_per_bar * beat_length_sec

	-- Calculate the start of the current bar
	-- TimeMap_QNToTime converts quarter notes (QN) to seconds
	-- We first get the current quarter note position, then find the bar start

	local qn_pos = reaper.TimeMap2_timeToQN(0, pos)
	local qn_bar_start = math.floor(qn_pos / beats_per_bar) * beats_per_bar
	local bar_start_sec = reaper.TimeMap2_QNToTime(0, qn_bar_start)
	local next_bar_start_sec = bar_start_sec + bar_length_sec

	-- save state in memory to reuse it at a later stage (when the action is called again)
	reaper.SetExtState(script_name, "bar_number", tostring (bar_number), false)
	reaper.SetExtState(script_name, "bar_length_sec", tostring (bar_length_sec), false)
	reaper.SetExtState(script_name, "bar_start_sec", tostring (bar_start_sec), false)
	reaper.SetExtState(script_name, "next_bar_start_sec", tostring (next_bar_start_sec), false)
	
else
	local bar_number = tonumber (reaper.GetExtState(script_name, "bar_number"))
	bar_number = bar_number + 1
	-- save state in memory to reuse it at a later stage (when the action is called again)
	reaper.SetExtState(script_name, "bar_number", tostring (bar_number), false)

end

rewind_loop ()

reaper.atexit(function()
	-- debug only
	-- reaper.ShowConsoleMsg("atexit ()\n")
end)
