-- MAIN
script_name = "Deny"

-- set track number to 1, save it
reaper.SetExtState(script_name, "joovs_track_index", "1", false)
track_number = 1					-- we set to 1 as this is the first track in playlist

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


