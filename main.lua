display.setStatusBar( display.HiddenStatusBar )

-- Create a background colour just to make the map look a little nicer
local back = display.newRect(0, 0, display.contentWidth, display.contentHeight)
back:setFillColor(165, 210, 255)

require("physics")
physics.start()
-- Load Lime
local lime = require("lime")

-- Load your map
local map = lime.loadMap("level1a.tmx")
-- Add physics objects created in PhysicsEditor
local physicsData = (require "phisics").physicsData()

--local physicsData2 = (require "phisics2").physicsData()

local onObject = function(object)
	local layer = map:getTileLayer("windows")
	if object.type == "Player" then
		local player = display.newImage(layer.group, "cat.png")
		player.x = object.x - 16
		player.y = object.y
		physics.addBody(player, { density = 1.0, friction = 0.3, bounce = 0.2, radius = 7 } )
		--player.isFixedRotation = true	
		player.bodyType = "static"
		function player:touch(event)
			player.bodyType = "dynamic"			
			player:applyLinearImpulse(0, 1, player.x, player.y)
		end		
		player:addEventListener("touch", player)		
	end
	if object.type == "tube" then
		for i = 1, 1, 1 do
			init_tube(object, layer)
		end
	end
end

map:addObjectListener("Player", onObject)
map:addObjectListener("tube", onObject)

function init_tube(object, layer)
	local tube_type = "tube_" .. object.tube_type
	local imagePath = tube_type .. "_p.png" 
	
	local tube = display.newImage(layer.group, imagePath)
	tube.x = object.x
	tube.y = object.y
	tube.countLeft = 10
	
	tube.scoreText = display.newText(tube.countLeft, tube.x-8, tube.y-8, native.systemFont, 12)
	tube.scoreText:setTextColor(0, 255, 0)
	tube.isBodyActive = false

	function tube:touch(event)
		local tube_child = display.newImage(layer.group, imagePath)	
		tube_child.x = object.x
		tube_child.y = object.y
		self.countLeft = self.countLeft - 1		
		self.scoreText.text = self.countLeft

		physics.addBody(tube_child, "static", physicsData:get(tube_type .. "_p"))

		function tube_child:touch(event)
			if event.phase == "began" then
				self.markX = self.x    -- store x location of object
				self.markY = self.y    -- store y location of object
				self.isBodyActive = false
			elseif event.phase == "moved" and self.isBodyActive == false then
				local x = (event.x - event.xStart) + self.markX
				local y = (event.y - event.yStart) + self.markY			
				self.x, self.y = x, y    -- move object based on calculations above
			elseif event.phase == "ended" and self.isBodyActive == false then
				local x = (event.x - event.xStart) + self.markX
				local y = (event.y - event.yStart) + self.markY			
				self.x, self.y = x + 16 - x%32, y + 16 - y%32    -- move object based on calculations above			
				self.isBodyActive = true
			end
			return true
		end
		tube_child:addEventListener("touch", tube_child)
		tube_child:touch(event)
	end
	tube:addEventListener("touch", tube)
	
	-- local tube_type = "tube_" .. object.tube_type
	-- local imagePath = tube_type .. "_p.png" 
	
	-- local tube = display.newImage(layer.group, imagePath)
	-- tube.x = object.x
	-- tube.y = object.y

	-- physics.addBody(tube, "static", physicsData:get(tube_type .. "_p"))
	-- --tube.isFixedRotation = true
	-- tube.isBodyActive = false

	-- function tube:touch(event)
		-- if event.phase == "began" then
			-- self.markX = self.x    -- store x location of object
			-- self.markY = self.y    -- store y location of object
			-- self.isBodyActive = false
		-- elseif event.phase == "moved" and self.isBodyActive == false then
			-- local x = (event.x - event.xStart) + self.markX
			-- local y = (event.y - event.yStart) + self.markY			
			-- self.x, self.y = x, y    -- move object based on calculations above
		-- elseif event.phase == "ended" and self.isBodyActive == false then
			-- local x = (event.x - event.xStart) + self.markX
			-- local y = (event.y - event.yStart) + self.markY			
			-- self.x, self.y = x + 16 - x%32, y + 16 - y%32    -- move object based on calculations above			
			-- self.isBodyActive = true
		-- end
		-- return true
	-- end
	-- tube:addEventListener("touch", tube)
end

-- Create the visual
local visual = lime.createVisual(map)

-- Build the physical
local physical = lime.buildPhysical(map)
physics.pause()
--physics.addBody(map.world, "static", physicsData2:get("level1"))
--physics.setDrawMode("hybrid")

local onButtonAPress = function(event)
	physics.start()
end

local buttonA = ui.newButton{
        default = "buttonA.png",
        over = "buttonA_over.png",
        onPress = onButtonAPress
}
buttonA.x = display.contentWidth - buttonA.width / 2 - 10
buttonA.y = display.contentHeight - buttonA.height / 2 - 10
buttonA.alpha = 1.0