-- wait function: wait for media item recording to be finalized; as soon it is finalized, go to endprocess()
function wait_for_item()

	itm = reaper.GetTrackMediaItem(sel_track, 0)
	if not itm then
		reaper.defer(wait_for_item)
	else
		endprocess ()
		return
	end

end

-- copy media item to the end of the track
function endprocess ()

	--get first and only media item in the track
	item = reaper.GetTrackMediaItem(sel_track, 0)


	-- Compute beginning and end (in sec) of the recorded item
	local first_sel_pos = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
	local last_sel_end = reaper.GetMediaItemInfo_Value(item, 'D_POSITION') + reaper.GetMediaItemInfo_Value(item, 'D_LENGTH')
	local length = last_sel_end-first_sel_pos
	-- str = "beg:" .. tostring (first_sel_pos) .. " end: " .. tostring (last_sel_end) .. "lg : " .. tostring (length)
	-- reaper.ShowConsoleMsg(str)

	
	reaper.Main_OnCommand(40939 + track_number, 0)		-- Select track
	reaper.Main_OnCommand(40421, 0)						-- Select all items in selected track
	duration = last_sel_end								-- end time of the first item
	while (duration < 240.0) do							-- copy item so it reaches 240 sec (4 min)
		reaper.Main_OnCommand(41295, 0)					-- Duplicate items
		duration = duration + length
	end

	return

end


-- MAIN
-- Recording track 1
track_number = 1
trk_number = tostring (track_number)
script_name = "Deny"
rec_toggle_state = "rec_toggle_state" .. trk_number
rec_start_bar = "rec_start_bar" .. trk_number
rec_end_bar = "rec_end_bar" .. trk_number

-- test toggle state and set to starting value
if not reaper.HasExtState(script_name, rec_toggle_state) then
	reaper.SetExtState(script_name, rec_toggle_state, "true", false)
end

-- test whether this is record ON or OFF
if reaper.GetExtState(script_name, rec_toggle_state) == "true" then
-- Record ON

	-- delete any item in the track
	-- (to do later: delete items that are after position)
	sel_track = reaper.GetTrack(0, track_number)
	media_items = reaper.CountTrackMediaItems(sel_track)
	for i = 0, media_items do
		item = reaper.GetTrackMediaItem(sel_track, 0)
		if item then
			reaper.DeleteTrackMediaItem(sel_track, item)
		end
	end

	--[[
	-- determine if playing or not to determine start bar
	if (reaper.GetPlayState () == 0) then
		cur_pos = reaper.GetCursorPosition()	-- not playing: get bar from cursor position
	else
		cur_pos = reaper.GetPlayPosition()		-- playing : get bar from playing position
	end
	retval, bar, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats(0, cur_pos)
	bar = bar + 1
	reaper.SetExtState(script_name, rec_start_bar, tostring (bar), false)
	]]

	-- start recording
	reaper.ClearAllRecArmed() 							-- clear all armed tracks
	reaper.Main_OnCommand(25 + (track_number * 8), 0)	-- Arm track for recording
	reaper.Main_OnCommand(40003, 0) 					-- Start/stop recording at next measure
	reaper.SetExtState(script_name, rec_toggle_state, "false", false)


else
-- Record OFF

	--[[
	-- determine end position (end bar)
	cur_pos = reaper.GetPlayPosition()	-- get current bar
	retval, bar, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats(0, cur_pos)
	bar = bar + 1
	reaper.SetExtState(script_name, rec_end_bar, tostring (bar), false)
	]]

	-- stop recording
	reaper.Main_OnCommand(40003, 0)			-- Start/stop recording at next measure
	reaper.SetExtState(script_name, rec_toggle_state, "true", false)

	 -- check if recording is finish	
	sel_track = reaper.GetTrack(0, track_number)
	wait_for_item()
	-- end of the process is done in endprocess() function
	-- copy media item to the end of the track
	return
end
