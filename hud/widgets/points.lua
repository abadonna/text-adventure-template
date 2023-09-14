local richtext = require "richtext.richtext"
local M = {}


M.new = function(data)
	local obj = {
		id = data[2]
	}

	local update = function(value) 
		local text = obj.text:gsub('@', value)
		gui.set_text(obj.node, text)
	end
	
	obj.init = function(words, story) 
		local tagged = richtext.tagged(words, obj.id)[1]
		obj.text = tagged.text
		obj.node = tagged.node
		obj.story = story

		update(story.variables[obj.id])
		story.add_observer(obj.id, update)
	end

	obj.delete = function()
		obj.story.remove_observer(obj.id, update)
	end

	obj.onclick = function()
		
	end
	
	return obj

end


return M