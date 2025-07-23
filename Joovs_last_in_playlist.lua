local script_path = debug.getinfo(1, "S").source:match("@(.*[/\\])")
-- reaper.ShowConsoleMsg("Script Directory: " .. script_path .. "\n")
-- local resource_path = reaper.GetResourcePath()
-- reaper.ShowConsoleMsg("REAPER Resource Path: " .. resource_path .. "\n")

package.path = package.path .. ";" .. script_path .. "/?.lua"
local csvfile = require "simplecsv"

---------------------------------------------------------------------

function getTrackByName(name)
  for trackIndex = 0, reaper.CountTracks(0) - 1 do
    local track = reaper.GetTrack(0, trackIndex)
    local ok, trackName = reaper.GetSetMediaTrackInfo_String(track, 'P_NAME', '', false)

    if ok and trackName == name then
      return track, (trackIndex + 1) -- found it! stopping the search here
    end
  end
end

---------------------------------------------------------------------

-- MAIN
script_name = "Deny"

-- Read playlist file and store to memory
m = csvfile.read(script_path .. '/playlist.txt') -- read file csv1.txt to matrix m

-- set track number in playlist to len(m), save it
reaper.SetExtState(script_name, "joovs_playlist_index", tostring (#m), false)
track_number_in_playlist = #m						-- we set to len(m) as this is the last track in playlist

-- Get first track name and BPM
track_name = m [track_number_in_playlist][1]
track_bpm = m [track_number_in_playlist][2]
track_drum = m [track_number_in_playlist][3]

-- select local track that has the same name as in playlist; track_number is 1-based
local track, track_number = getTrackByName (track_name)

if track then -- if a track named with the right track_name was found

	-- select all tracks and unmute and unsolo them and set BPM
	reaper.Main_OnCommand(40340, 0)						-- Unsolo all tracks
	reaper.Main_OnCommand(40339, 0)						-- Unmute all tracks
	reaper.SetCurrentBPM(0, track_bpm, false)			-- set BPM

	-- select DRUM track (based on track_number + 1)
	reaper.Main_OnCommand(40938 + 1 + track_number, 0)	-- Select track; track 1 is 40939

	-- set mute for selected track (DRUM); only
	if (track_drum ~= "drum") then
		reaper.Main_OnCommand(40730, 0)
	end

	-- select track (based on track_number)
	reaper.Main_OnCommand(40938 + track_number, 0)		-- Select track; track 1 is 40939

	-- set solo for selected track
	reaper.Main_OnCommand(40728, 0)
  
end





