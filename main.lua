display.setStatusBar( display.HiddenStatusBar )

-- Create a background colour just to make the map look a little nicer
local back = display.newRect(0, 0, display.contentWidth, display.contentHeight)
back:setFillColor(165, 210, 255)

require("physics")

physics.start()
-- Load Lime
local lime = require("lime")

-- Load your map
local map = lime.loadMap("level1.tmx")
-- Add physics objects created in PhysicsEditor
local physicsData = (require "phisics").physicsData()

local physicsData2 = (require "phisics2").physicsData()

local onPlayerSpawnObject = function(object)
	local layer = map:getTileLayer("windows")
	if object.type == "Player" then
		local player = display.newImage(layer.group, "cat.png")
		player.x = object.x + 10
		player.y = object.y
		
		physics.addBody(player, physicsData:get("cat"))
		player.isFixedRotation = true	
	end
	if object.type == "tube" then
		local tube_type = "tube_" .. object.tube_type
		local imagePath = tube_type .. ".png" 
		local tube = display.newImage(layer.group, imagePath)
		-- tube:setReferencePoint( display.BottomRightReferencePoint )
		tube.x = object.x
		tube.y = object.y
		
		physics.addBody(tube, "static", physicsData:get(tube_type))
		tube.isFixedRotation = true
		
		function tube:touch(event)
			if event.phase == "began" then

				self.markX = self.x    -- store x location of object
				self.markY = self.y    -- store y location of object

			elseif event.phase == "moved" then

				local x = (event.x - event.xStart) + self.markX
				local y = (event.y - event.yStart) + self.markY
				
				self.x, self.y = x, y    -- move object based on calculations above
			end
			return true
		end
		
		tube:addEventListener("touch", tube)
		
	end
end

map:addObjectListener("Player", onPlayerSpawnObject)

map:addObjectListener("tube", onPlayerSpawnObject)


-- Create the visual
local visual = lime.createVisual(map)

-- Build the physical
local physical = lime.buildPhysical(map)
local objectLayer = map:getObjectLayer( "player" )
local object = objectLayer:getObject("myCat", "cat")

physics.addBody(map.world, "static", physicsData2:get("level1"))
--physics.setDrawMode("hybrid")

