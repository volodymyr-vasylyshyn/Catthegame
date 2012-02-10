-- initialize physics
require("physics")
physics.start()

-- local variables
local lime = require("lime") -- initialize lime
map = lime.loadMap("assets\\maps\\level1a.tmx")
physicsData = (require "assets\\physics\\physics").physicsData() -- Add physics objects created in PhysicsEditor
layer_hightlight = map:getTileLayer("hightlight")
player = nil

display.newRect(0, 0, display.contentWidth, display.contentHeight):setFillColor(165, 210, 255)  -- Create a background colour just to make the map look a little nicer

require("items")

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
