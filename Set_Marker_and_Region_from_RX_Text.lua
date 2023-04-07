function parse_file(file_path)
    local markers = {}
    local regions = {}
    local file = io.open(file_path, "r")
    if not file then return nil end

    for line in file:lines() do
        local time_start, time_end = line:match("(%d+:%d+%.%d+)%s*(%d*:?%d*%.?%d*)")
        if time_end == "" or time_end == nil then
            table.insert(markers, time_start)
        else
            table.insert(regions, {time_start, time_end})
        end
    end
    file:close()
    return markers, regions
end

function add_markers_and_regions(markers, regions)
    local color = reaper.ColorToNative(255, 0, 0) -- Set color to red
    for i, marker_time in ipairs(markers) do
        local position = reaper.parse_timestr_pos(marker_time, 2) -- 2 for Time format
        reaper.AddProjectMarker(0, false, position, 0, "Marker " .. i, -1, color)
    end
    for i, region in ipairs(regions) do
        local start_pos = reaper.parse_timestr_pos(region[1], 2)
        local end_pos = reaper.parse_timestr_pos(region[2], 2)
        reaper.AddProjectMarker(0, true, start_pos, end_pos, "Region " .. i, -1, color)
    end
end

local retval, file_path = reaper.GetUserFileNameForRead("", "Select a text file with markers and regions", ".txt")
if retval then
    local markers, regions = parse_file(file_path)
    if markers and regions then
        reaper.Undo_BeginBlock()
        add_markers_and_regions(markers, regions)
        reaper.Undo_EndBlock("Import markers and regions from text file", -1)
    else
        reaper.ShowMessageBox("Failed to read the file", "Error", 0)
    end
else
    reaper.ShowMessageBox("No file selected", "Cancelled", 0)
end
