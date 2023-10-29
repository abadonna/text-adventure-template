local M = {}

M.set_cursor = function()
	local system_name = sys.get_sys_info().system_name

	if system_name == "Darwin" then
		defos.set_cursor(defos.load_cursor({
			image = resource.load("/images/cursor.tiff"),
			hot_spot_x = 1,
			hot_spot_y = 1,
		}))
	end

	if system_name == "Windows" then
		local appname = sys.get_config("project.title")

		local resbuff = resource.load("/images/cursor.cur")
		local raw_bytes = buffer.get_bytes(resbuff, hash("data"))
		local path = sys.get_save_file(appname, "cursor.cur")
		local f = io.open(path, "wb")
		f:write(raw_bytes)
		f:flush()
		f:close()
		
		defos.set_cursor(defos.load_cursor(path))
	end
end

return M