function timecode_to_seconds(timecode)
    local hh, mm, ss, ff = timecode:match("(%d+):(%d+):(%d+):(%d+)")
    return tonumber(hh) * 3600 + tonumber(mm) * 60 + tonumber(ss) + tonumber(ff) / 100
end

function read_file(filename)
    local f = assert(io.open(filename, "r"))
    local content = f:read("*all")
    f:close()
    return content
end

local function process_lines(lines)
    for _, line in ipairs(lines) do
        local marker_name, start_time, end_time = line:match("^(%w*)%s*(%d+:%d+:%d+:%d+)%s*(%d+:%d+:%d+:%d+)*")
        if marker_name and start_time then
            start_time = timecode_to_seconds(start_time)
            if end_time then
                end_time = timecode_to_seconds(end_time)
                reaper.AddProjectMarker2(0, true, start_time, end_time, marker_name, -1, 0)
            else
                reaper.AddProjectMarker(0, false, start_time, marker_name, -1, 0)
            end
        end
    end
end

local retval, file_path = reaper.GetUserFileNameForRead("", "Select RX marker list file", ".txt")
if retval then
    local file_content = read_file(file_path)
    local lines = {}
    for line in file_content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    process_lines(lines)
end
