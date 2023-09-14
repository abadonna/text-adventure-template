local richtext = require "richtext.richtext"
local M = {}

local color = vmath.vector4(0, 0, 0, 1)
local color_hover = vmath.vector4(0.2, 0.2, 0.2, 1)
local color_border = vmath.vector4(0.4, 0.4, 0.4, 1)
local color_border_hover = vmath.vector4(1, 1, 1, 1)

M.new = function(data)
	local obj = {
		id = tostring(math.random(1, 1000000)),
		name = data[2],
		handle = 666
	}

	local cursor = "_"
	local function update()
		gui.set_text(obj.nodes.ti_value, obj.value .. cursor)
		cursor = cursor == "" and "_" or ""
	end
	
	obj.init = function(words, story) 
		obj.story = story
		local word = nil
		local offset = 0
		for _, tagged in ipairs(richtext.tagged(words, "textinput")) do
			if tagged.tags["textinput"] == obj.id then
				word = tagged
			end

			if  tagged.metrics.width > offset then
				offset = tagged.metrics.width
			end
		end

		obj.title = word.text
		obj.value = story.variables[obj.name]
		obj.nodes = gui.clone_tree(gui.get_node("textinput"))
		gui.set_parent(obj.nodes.textinput, word.node, false)
		gui.set_text(obj.nodes.ti_title, word.text)
		gui.set_text(obj.nodes.ti_value, obj.value)
		gui.set_position(obj.nodes.textinput, vmath.vector3(offset + 130,0,0))

		gui.set_text(word.node, "")
	end

	obj.delete = function()
		timer.cancel(obj.handle)
		gui.delete_node(obj.nodes.textinput)
	end

	obj.onclick = function(action)
		if gui.pick_node(obj.nodes.ti_value, action.x, action.y) then
			obj.active = true
			obj.handle = timer.delay(0.5, true, update)
		else
			timer.cancel(obj.handle)
			cursor = ""
			update()
			
			obj.active = false
			if obj.story.variables[obj.name] ~= obj.value then
				obj.story.assign_value(obj.name, obj.value)
			end
		end
	end

	obj.ontext = function(text)
		if obj.active then 
			if text then
				obj.value = obj.value .. text
			else
				obj.value = obj.value:sub(1, obj.value:len() - 1)
			end
			gui.set_text(obj.nodes.ti_value, obj.value)
		end
	end

	local function restore_hover()
		if obj.hover then
			gui.animate(obj.nodes.ti_box, "color", color, gui.EASING_LINEAR, 0.2)
			gui.animate(obj.nodes.ti_border, "color", color_border, gui.EASING_LINEAR, 0.2)
			obj.hover = false
		end
	end

	obj.onhover = function(action)
		if gui.pick_node(obj.nodes.ti_box, action.x, action.y) then
			if not obj.hover then
				restore_hover()
				obj.hover = true
				gui.animate(obj.nodes.ti_box, "color", color_hover, gui.EASING_LINEAR, 0.2)
				gui.animate(obj.nodes.ti_border, "color", color_border_hover, gui.EASING_LINEAR, 0.2)
			end
			return
		end
		restore_hover()
	end

	return obj

end


return M