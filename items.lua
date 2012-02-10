require("physics")
draged_object = nil
-- initialize objects from map on it creating
local globalTouchListener = function( event ) 
	if event.phase == "moved" and draged_object ~= nil then
	  local x = (event.x - event.xStart) + draged_object.markX
	  local y = (event.y - event.yStart) + draged_object.markY			
	  draged_object.x, draged_object.y = x, y    -- move object based on calculations above
	end
end 
Runtime:addEventListener( "touch", globalTouchListener )
local onObject = function(object)
	local layer = map:getTileLayer("windows")
	if object.type == "Player" then
		init_player(object, layer)
	end
	if object.type == "mouse" then
		init_mouse(object, layer)
	end	
	if object.type == "tube" then
		init_tube(object, layer)
	end
end
map:addObjectListener("Player", onObject)
map:addObjectListener("tube", onObject)
map:addObjectListener("mouse", onObject)

function init_player(object, layer)
	player = display.newImage(layer.group, "assets\\images\\cat.png")
	player.x, player.y  = object.x - 16, object.y
	player.start_x, player.start_y  = object.x - 16, object.y
	physics.addBody(player, { density = 1.0, friction = 30.0, bounce = 0.0, radius = 7 } )
	player.bodyType = "static"
	function player:touch(event)
		player.bodyType = "dynamic"			
		player:applyLinearImpulse(0, 1, player.x, player.y)
	end	
	function player:collision(event)
		if ( event.phase == "began" ) then
			if event.other.IsPickup then
				local item = event.other
				
				local onTransitionEnd = function(transitionEvent)
					if transitionEvent["removeSelf"] then
						transitionEvent:removeSelf()
					end
				end
						
				-- Fade out the item
				transition.to(item, {time = 500, alpha = 0, onComplete=onTransitionEnd})
				
				local text = nil
				
				if item.pickupType == "mouse" then				
					--text = display.newText( item.scoreValue .. " Points!", 0, 0, "Helvetica", 50 )		
					text = display.newText("Mouse is dead!", 0, 0, "Helvetica", 50 )		
				end
				
				if text then
					text:setTextColor(0, 0, 0, 255)
					text.x = display.contentCenterX
					text.y = text.height / 2
					
					transition.to(text, {time = 2000, alpha = 0, onComplete=onTransitionEnd})
				end
			end
		end
	end		
	player:addEventListener("touch", player)
	player:addEventListener( "collision", player )	
end
function init_mouse(object, layer)
	local mouse = display.newImage(layer.group, "assets\\images\\mouse.png")
	mouse.x, mouse.y  = object.x, object.y
	physics.addBody(mouse, { radius = 9 } )
	mouse.HasBody = true
	mouse.IsPickup = true
	mouse.bodyType = "static"
	mouse.isSensor = true
	mouse.pickupType = "mouse"
	mouse.scoreValue = 50		
end
function init_tube(object, layer)
	local tube_type = "tube_" .. object.tube_type
	local imagePath = "assets\\images\\" .. tube_type .. "_p.png" 	
	local factory = display.newImage(layer.group, imagePath)
	factory.x, factory.y = object.x, object.y
	factory.countLeft = 10	
	factory.countText = display.newText(factory.countLeft, factory.x-8, factory.y-8, native.systemFont, 12)
	factory.countText:setTextColor(255, 255, 255)
	factory.isBodyActive = false
	factory.kind = tube_type
	factory.group = layer.group
	factory.imagePath = imagePath
	function factory:touch(event)
		if draged_object == nil then
			TubeItem:new ({factory = self, event = event})
		end
	end
	factory:addEventListener("touch", factory)
end

MovableItem = {kind = "", factory = nil}
function MovableItem:initialize()
  self.tapRotateAngle = 45  
end
function MovableItem:new (o)
	o = o or {}
	if o.factory ~= nil and o.factory.countLeft > 0 then	
		local factory = o.factory
		movableItem = display.newImage(factory.group, factory.imagePath)
		movableItem.x, movableItem.y = factory.x, factory.y
		movableItem.factory = factory		
		self:initialize()
		factory.countLeft = factory.countLeft - 1		
		factory.countText.text = factory.countLeft
		physics.addBody(movableItem, "static", physicsData:get(factory.kind .. "_p"))
		function movableItem:touch(event)
			if event.phase == "began" and draged_object == nil then
				self.markX = self.x    -- store x location of object
				self.markY = self.y    -- store y location of object
				self.isBodyActive = false					
				layer_hightlight:show()
				draged_object = self					
				event.target:toFront()
				local position = { column = (self.x + 16) / 32, row = (self.y + 16) / 32}
				local tile = layer_hightlight:getTileAt( position )		
				if tile ~= nil then
					tile.isBusy = false
				end						
			elseif event.phase == "moved" and draged_object == self then
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
				if (self.x == factory.x and self.y == factory.y) or tile == nil or tile.isBusy == true  then
					factory.countLeft = factory.countLeft + 1		
					factory.countText.text = factory.countLeft
					self:removeSelf()
				end			
				if tile ~= nil then
					tile.isBusy = true
				end
				draged_object = nil					
				layer_hightlight:hide()
			end
			return true
		end
		
		local function onTap( event )
			movableItem:rotate(self.tapRotateAngle)                        
		end
		 
		movableItem:addEventListener( "tap", onTap)		
		movableItem:addEventListener("touch", movableItem)
		movableItem:touch(o.event)		   
		--setmetatable(movableItem, self)
		self.__index = self
		return movableItem
	end 
	setmetatable(o, self)
	self.__index = self
	return o
end
TubeItem = MovableItem:new()
function TubeItem:initialize()
  self.kind = "tube"
  self.tapRotateAngle = 90  
end