---Please put csv2rx_action.py in your reascript directory before use.

local function find_python_path()
    local python_path = nil

    if reaper.file_exists("/usr/local/bin/python") then
        python_path = "/usr/local/bin/python"
    elseif reaper.file_exists("/usr/bin/python") then
        python_path = "/usr/bin/python"
    end

    return python_path
end

local reaper_scripts_path = reaper.GetResourcePath() .. "/Scripts/"
local output_file_path = reaper_scripts_path .. "temp.csv"
local file = io.open(output_file_path, "w")
file:write("#,Name,Start,End,Length\n")

local _, num_markers, num_regions = reaper.CountProjectMarkers(0)

for i = 0, num_markers + num_regions - 1 do

  local _, isrgn, pos, rgnend, name, _, color = reaper.EnumProjectMarkers3(0, i)
  local type = isrgn and "R" or "M"
  local length = isrgn and (rgnend - pos) or ""
  local pos_formatted = reaper.format_timestr_pos(pos, "", 5)
  local rgnend_formatted = isrgn and reaper.format_timestr_pos(rgnend, "", 5) or ""
  local length_formatted = isrgn and reaper.format_timestr_pos(length, "", 5) or ""

  file:write(string.format("%s%d,\"%s\",%s,%s,%s\n", type, i + 1, name, pos_formatted, rgnend_formatted, length_formatted))
end

file:close()

local csv2rx_action_path = reaper_scripts_path .. "csv2rx_action.py"

local python_command
if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
  -- Set the Python path for Windows
  local username = os.getenv("USERNAME")
  python_command = "C:\\Users\\" .. username .. "\\AppData\\Local\\Programs\\Python\\Python39\\python.exe"
else
  -- Set the Python path for macOS or Linux
  python_command = find_python_path()
end

if not python_command then
  reaper.ShowMessageBox("Python not found in the system PATH.", "Error", 0)
  return
end

local command = python_command .. " \"" .. csv2rx_action_path .. "\" -i \"" .. output_file_path .. "\""

if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
  local cmd = "cmd.exe /C cd \"" .. reaper_scripts_path .. "\" && " .. command
  os.execute(cmd)
else
  os.execute(command)
end

os.remove(output_file_path)

reaper.ShowMessageBox("🤘", "Aww Yeah!", 0)
