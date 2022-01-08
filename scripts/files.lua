-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function file_exists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
end
  
-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function read_lines(file)
	if not file_exists(file) then error("file does not exist") end
	lines = {}
	for line in io.lines(file) do 
		lines[#lines + 1] = line
	end
	return lines
end
