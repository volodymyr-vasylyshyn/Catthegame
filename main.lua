-- requires
require("physics")

physics.start()
-- local variables
local lime = require("lime")
local map = lime.loadMap("assets\\maps\\level1a.tmx")
local physicsData = (require "assets\\physics\\physics").physicsData() -- Add physics objects created in PhysicsEditor
local layer_hightlight = map:getTileLayer("hightlight")
local player = nil
local draged_object = nil

display.newRect(0, 0, display.contentWidth, display.contentHeight):setFillColor(165, 210, 255)  -- Create a background colour just to make the map look a little nicer

local onObject = function(object)
	local layer = map:getTileLayer("windows")
	if object.type == "Player" then
		player = display.newImage(layer.group, "assets\\images\\cat.png")
		player.x, player.y  = object.x - 16, object.y
		player.start_x, player.start_y  = object.x - 16, object.y
		physics.addBody(player, { density = 1.0, friction = 0.3, bounce = 0.2, radius = 7 } )
		player.bodyType = "static"
		function player:touch(event)
			player.bodyType = "dynamic"			
			player:applyLinearImpulse(0, 1, player.x, player.y)
		end		
		player:addEventListener("touch", player)		
	end
	if object.type == "tube" then
		init_tube(object, layer)
	end
end

map:addObjectListener("Player", onObject)
map:addObjectListener("tube", onObject)

function init_tube(object, layer)
	local tube_type = "tube_" .. object.tube_type
	local imagePath = "assets\\images\\" .. tube_type .. "_p.png" 
	
	local tube = display.newImage(layer.group, imagePath)
	tube.x, tube.y = object.x, object.y
	tube.countLeft = 10	
	tube.scoreText = display.newText(tube.countLeft, tube.x-8, tube.y-8, native.systemFont, 12)
	tube.scoreText:setTextColor(255, 255, 255)
	tube.isBodyActive = false
	tube.type = object.tube_type
	function tube:touch(event)
		local parent = self
		if parent.countLeft > 0 then
			local tube_child = display.newImage(layer.group, imagePath)	
			tube_child.type = "tube"
			tube_child.x, tube_child.y = object.x, object.y
			tube_child.parent = parent
			parent.countLeft = parent.countLeft - 1		
			parent.scoreText.text = parent.countLeft
			physics.addBody(tube_child, "static", physicsData:get(tube_type .. "_p"))
			function tube_child:touch(event)
				if event.phase == "began" then
					self.markX = self.x    -- store x location of object
					self.markY = self.y    -- store y location of object
					self.isBodyActive = false					
					layer_hightlight:show()
					draged_object = self
				elseif event.phase == "moved" then
					local x = (event.x - event.xStart) + self.markX
					local y = (event.y - event.yStart) + self.markY			
					self.x, self.y = x, y    -- move object based on calculations above
				elseif event.phase == "ended" then
					local x = (event.x - event.xStart) + self.markX
					local y = (event.y - event.yStart) + self.markY			
					self.x, self.y = x + 16 - x%32, y + 16 - y%32    -- move object based on calculations above			
					self.isBodyActive = true
					local position = { column = (self.x + 16) / 32, row = (self.y + 16) / 32}
					local tile = layer_hightlight:getTileAt( position )
					if (self.x == parent.x and self.y == parent.y) or tile == nil  then
						parent.countLeft = parent.countLeft + 1		
						parent.scoreText.text = parent.countLeft
						self:removeSelf()
					end			
					draged_object = nil					
					layer_hightlight:hide()
				elseif event.phase == "cancelled" then
					print("cancelled")
				end
				return true
			end
			tube_child:addEventListener("touch", tube_child)
			tube_child:touch(event)
		end
	end
	tube:addEventListener("touch", tube)
end

local visual = lime.createVisual(map)  -- Create the visual
local physical = lime.buildPhysical(map)  -- Build the physical
--physics.setDrawMode("hybrid")

layer_hightlight:hide() -- hide hightlight layer
-- add A button
local onButtonAPress = function(event)
	player.x, player.y  = player.start_x, player.start_y 
	player.bodyType = "static"
end
local buttonA = ui.newButton{
        default = "assets\\images\\buttonA.png",
        over = "assets\\images\\buttonA_over.png",
        onPress = onButtonAPress
}
buttonA.x = display.contentWidth - buttonA.width / 2 - 10
buttonA.y = display.contentHeight - buttonA.height / 2 - 10
buttonA.alpha = 1.0

local myListener = function( event ) 
	if event.phase == "moved" and draged_object ~= nil then
	  local x = (event.x - event.xStart) + draged_object.markX
	  local y = (event.y - event.yStart) + draged_object.markY			
	  draged_object.x, draged_object.y = x, y    -- move object based on calculations above
	end
end 
Runtime:addEventListener( "touch", myListener )


local function onCollision(self, event )

 	if ( event.phase == "began" ) then
		print(event.other.type)
		--player = display.newImage(layer.group, "assets\\images\\cat.png")
		print(player.path)
		if event.other.type == "tube" then
			player = display.newImage(layer.group, "assets\\images\\cat_in_tube.png")
		elseif event.other.IsPickup then
			
			local item = event.other
			
			local onTransitionEnd = function(transitionEvent)
				if transitionEvent["removeSelf"] then
					transitionEvent:removeSelf()
				end
			end
					
			-- Fade out the item
			transition.to(item, {time = 500, alpha = 0, onComplete=onTransitionEnd})
		end
	elseif ( event.phase == "ended" ) then
		if event.other.type == "tube"  then
			player = display.newImage(layer.group, "assets\\images\\cat.png")
		end
	end
end

player.collision = onCollision
player:addEventListener( "collision", player )