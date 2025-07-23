-- MAIN
script_name = "Deny"

-- test track number presence and set to starting value
-- save state in memory to reuse it at a later stage (when the action is called again)
if not reaper.HasExtState(script_name, "joovs_track_index") then
	reaper.SetExtState(script_name, "joovs_track_index", "-3", false)		-- default track number is -3
end

-- get track number, increment it of 4, save it
track_number = tonumber (reaper.GetExtState(script_name, "joovs_track_index"))
track_number = track_number + 4							--	4 tracks per song
reaper.SetExtState(script_name, "joovs_track_index", tostring (track_number), false)

-- select all tracks and unmute and unsolo them
reaper.Main_OnCommand(40340, 0)						-- Unsolo all tracks
reaper.Main_OnCommand(40339, 0)						-- Unmute all tracks

-- select DRUM track (based on track_number + 1)
reaper.Main_OnCommand(40938 + 1 + track_number, 0)	-- Select track; track 1 is 40939

-- set mute for selected track (DRUM)
--reaper.Main_OnCommand(40730, 0)

-- select track (based on track_number)
reaper.Main_OnCommand(40938 + track_number, 0)		-- Select track; track 1 is 40939

-- set solo for selected track
reaper.Main_OnCommand(40728, 0)


