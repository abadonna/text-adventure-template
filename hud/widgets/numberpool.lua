local richtext = require "richtext.richtext"
local M = {}

local color = vmath.vector4(0.2, 0.33, 0.67, 1)
local color_hover = vmath.vector4(0.33, 0.47, 0.8, 1)

M.new = function(data)
	local obj = {
		id = tostring(math.random(1, 1000000)),
		points = data[2],
		min = tonumber(data[3]),
		max = tonumber(data[4]),
		name = data[5],
		expression = data[6],
		maxexp = tonumber(data[7])
	}

	obj.update = function(value)
		if not value then return end
		gui.set_text(obj.nodes.value, value)
		
		if obj.expression then
			if obj.words then
				for _, word in ipairs(obj.words) do
					gui.delete_node(word.node)
				end
			end

			gui.set_text(obj.nodes.title, "")
			local exp = obj.story.eval(obj.expression)
			
			obj.words = richtext.create(obj.title:gsub('@', '<a> </a>'), 'main', 
			{
				combine_words = true, 
				parent = obj.nodes.title,
				align = richtext.ALIGN_RIGHT,
				position = vmath.vector3(0,20,0)
			})
			
			local tagged = richtext.tagged(obj.words, "a")[1].node
			
			richtext.create(tostring(exp), 'main', 
			{
				combine_words = true, 
				parent = tagged,
				align = richtext.ALIGN_CENTER
			})
		end
	end
	
	obj.init = function(words, story) 
		obj.story = story
		local word = nil
		local offset = 0
		for _, tagged in ipairs(richtext.tagged(words, "numberpool")) do
			if tagged.tags["numberpool"] == obj.id then
				word = tagged
			end

			if  tagged.metrics.width > offset then
				offset = tagged.metrics.width
			end
		end

		obj.title = word.text
		obj.nodes = gui.clone_tree(gui.get_node("numberpool"))
		gui.set_parent(obj.nodes.numberpool, word.node, false)
		gui.set_text(obj.nodes.title, word.text)
		gui.set_position(obj.nodes.numberpool, vmath.vector3(offset + 130,0,0))

		obj.update(story.variables[obj.name])
		story.add_observer(obj.name, obj.update)
		
		gui.set_text(word.node, "")
		obj.buttons = {obj.nodes.plus, obj.nodes.minus}
	end

	obj.delete = function()
		obj.story.remove_observer(obj.name, obj.update)
		gui.delete_node(obj.nodes.numberpool)
	end

	local function restore_hover()
		if obj.hover then
			gui.animate(obj.hover, "color", color, gui.EASING_LINEAR, 0.2)
			obj.hover = nil
		end
	end
	
	obj.onhover = function(action)
		for _, node in ipairs(obj.buttons) do
			if gui.pick_node(node, action.x, action.y) then
				if obj.hover ~= node then
					restore_hover()
					obj.hover = node
					gui.animate(node, "color", color_hover, gui.EASING_LINEAR, 0.2)
				end
				return
			end
		end
		restore_hover()
	end

	obj.onclick = function(action)
		if gui.pick_node(obj.nodes.plus, action.x, action.y) then
			sound.play("/sound#button")
			if obj.expression then
				local exp = obj.story.eval(obj.expression)
				if exp == obj.maxexp then return end
			end
			
			local value = obj.story.variables[obj.name]
			local points = obj.story.variables[obj.points]
			
			if points > 0 and value < obj.max then
				obj.story.assign_value(obj.name, value + 1)
				obj.story.assign_value(obj.points, points - 1)
			end
			
		elseif gui.pick_node(obj.nodes.minus, action.x, action.y) then
			sound.play("/sound#button")
			local value = obj.story.variables[obj.name]
			local points = obj.story.variables[obj.points]
			if value > obj.min then
				obj.story.assign_value(obj.name, value - 1)
				obj.story.assign_value(obj.points, points + 1)
			end
		end
	end

	return obj

end


return M