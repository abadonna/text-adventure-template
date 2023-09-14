local richtext = require "richtext.richtext"
local M = {}


M.new = function(data)
	local obj = {
		id = hash_to_hex(hash(data[2])),
		expression = data[2]
	}

	obj.init = function(words, story) 
		obj.nodes = {}
		for _, tagged in ipairs(richtext.tagged(words, "condition")) do
			if tagged.tags["condition"] == obj.id then
				table.insert(obj.nodes, tagged.node)
				gui.set_alpha(tagged.node, 0)
			end
		end


		local update = function()
			if #obj.nodes == 0 then return end
			local value = story.eval(obj.expression)

			if value and gui.get_alpha(obj.nodes[1]) == 0 then
				for _, node in ipairs(obj.nodes) do
					gui.animate(node, "color.w", 1, gui.EASING_LINEAR, 0.5)
				end
			elseif not value and gui.get_alpha(obj.nodes[1]) == 1 then
				for _, node in ipairs(obj.nodes) do
					gui.animate(node, "color.w", 0, gui.EASING_LINEAR, 0.5)
				end
			end
		end
		
		update()
		obj.handle = timer.delay(0.5, true, update)
	end

	obj.delete = function()
		obj.nodes = {}
		timer.cancel(obj.handle)
	end

	obj.onclick = function()
		
	end
	
	return obj

end


return M