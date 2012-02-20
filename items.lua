require("physics")

-- local variables
local draged_object = nil
local objectsLayer = map:getTileLayer("windows")
local bounceSound = audio.loadSound("assets\\audio\\bounce.mp3")
local crashSound = audio.loadSound("assets\\audio\\crash.mp3")

-- fix for issue with lost draged item focu
local globalTouchListener = function( event ) 
	if event.phase == "moved" and draged_object ~= nil then
	  local x = (event.x - event.xStart) + draged_object.markX
	  local y = (event.y - event.yStart) + draged_object.markY			
	  draged_object.x, draged_object.y = x, y    -- move object based on calculations above
	end
end 
Runtime:addEventListener( "touch", globalTouchListener )

-- initialize objects from map on it creating
local onObject = function(object)
	if object.type == "Player" then
		init_player(object)
	end
	if object.type == "mouse" then
		init_mouse(object)
	end	
	if object.type == "MovableItem" then
		initFactory(object)
	end
end
map:addObjectListener("Player", onObject)
map:addObjectListener("MovableItem", onObject)
map:addObjectListener("mouse", onObject)

function init_player(object)
	player = display.newImage(objectsLayer.group, "assets\\images\\cat.png")
	player.x, player.y  = object.x - 16, object.y
	player.start_x, player.start_y  = object.x - 16, object.y
	physics.addBody(player, { density = 100.0, friction = 30.0, bounce = 0.0, radius = 7 } )
	player.bodyType = "static"
	function player:touch(event)	
		if ( event.phase == "began" ) then
			player.bodyType = "dynamic"			
			player:applyLinearImpulse(0, 1, player.x, player.y)
		end
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
			-- here game is over
			-- life --
			if event.other.isGround then
				audio.play(crashSound)
				physics.pause()				
			end
			
			if event.other.movableType == "matraz" then
				event.other:prepare("collision")  
				--event.other.currentFrame = 2
				--event.other:play()
				audio.play(bounceSound)
			end
		elseif event.phase == "ended" then
			if event.other.movableType == "matraz" then
				event.other:prepare("normal")
			end
		end
		
	end		
	player:addEventListener("touch", player)
	player:addEventListener( "collision", player )	
end
function init_mouse(object)
	local mouse = display.newImage(objectsLayer.group, "assets\\images\\mouse.png")
	mouse.x, mouse.y  = object.x, object.y
	physics.addBody(mouse, { radius = 9 } )
	mouse.HasBody = true
	mouse.IsPickup = true
	mouse.bodyType = "static"
	mouse.isSensor = true
	mouse.pickupType = "mouse"
	mouse.scoreValue = 50		
end
function initFactory(object)
	local imagePath = "assets\\images\\" .. object.movableType .. ".png" 	
	local spritePath = "assets\\sprites\\" .. object.movableType .. ".png" 
	if object.kind ~= nil then
		imagePath = "assets\\images\\" .. object.movableType .. "_" .. object.kind .. ".png" 	
		spritePath = "assets\\sprites\\" .. object.movableType .. "_" .. object.kind .. ".png" 	
	end
	local factory = display.newImage(objectsLayer.group, imagePath)
	factory.x, factory.y = object.x, object.y
	factory.countLeft = object.itemsCount -- should be value from map
	factory.countText = display.newText(factory.countLeft, factory.x-8, factory.y-8, native.systemFont, 12)
	factory.countText:setTextColor(255, 255, 255)
	factory.isBodyActive = false
	-- movableType: tube, antena, batut
	-- this value should indicate which class instance need to be created
	factory.movableType = object.movableType-- should be value from map
	factory.kind = object.kind
	factory.imagePath = imagePath
	factory.spritePath = spritePath
	function factory:touch(event)
		if draged_object == nil then
			if object.movableType == "tube" then
				TubeItem:new ({factory = self, parentEvent = event})
			end
			if object.movableType == "matraz" then
				Matraz:new ({factory = self, parentEvent = event})
			end
			if object.movableType == "antenna" then
				Antenna:new ({factory = self, parentEvent = event})
			end
		end
	end
	factory:addEventListener("touch", factory)
end

-- MovableItem
MovableItem = {kind = "", factory = nil}
function MovableItem:initialize()
  self.tapRotateAngle = 45   
  self.canTap = true
  self.imagePath = self.factory.imagePath
  self.hightlight_layer = layer_hightlight_1
  self.physicsType = self.factory.kind
  local sheet1 = sprite.newSpriteSheet( self.factory.spritePath, 32, 32 )
  self.spriteSet1 = sprite.newSpriteSet(sheet1, 1, 1)
  sprite.add( self.spriteSet1, "normal", 1, 1, 1000, 0 ) -- play 8 frames every 1000 ms
end
function MovableItem:initializeOverride()
end
function MovableItem:new(o)
	o = o or {}
	if o.factory ~= nil and o.factory.countLeft > 0 then	
		local factory = o.factory		
		self.factory = factory	
		self.kind = factory.kind
		
		self:initialize()
		self:initializeOverride()	
		
		local movableItem = sprite.newSprite( self.spriteSet1 )
		movableItem:prepare("normal")		
		--local movableItem = display.newImage(objectsLayer.group, factory.imagePath)
		movableItem.x, movableItem.y = factory.x, factory.y
		movableItem.movableType = factory.movableType
		factory.countLeft = factory.countLeft - 1		
		factory.countText.text = factory.countLeft
		physics.addBody(movableItem, "static", physicsData:get(self.physicsType))
		local parent = self
		function movableItem:touch(event)
			if event.phase == "began" and draged_object == nil then
				self.markX = self.x    -- store x location of object
				self.markY = self.y    -- store y location of object
				self.isBodyActive = false					
				parent.hightlight_layer:show()
				draged_object = self					
				event.target:toFront()
				--event.target:toBack()
				local position = { column = (self.x + 16) / 32, row = (self.y + 16) / 32}
				local tile = parent.hightlight_layer:getTileAt( position )		
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
				local tile = parent.hightlight_layer:getTileAt( position )
				if (self.x == factory.x and self.y == factory.y) or tile == nil or tile.isBusy == true  then
					factory.countLeft = factory.countLeft + 1		
					factory.countText.text = factory.countLeft
					self:removeSelf()
				end			
				if tile ~= nil then
					tile.isBusy = true
				end
				draged_object = nil					
				parent.hightlight_layer:hide()
			end
			return true
		end		
		if self.canTap then
			-- local movableItem = movableItem
			movableItem.tapRotateAngle = self.tapRotateAngle
			function movableItem:tap(event)
				self:rotate(self.tapRotateAngle)                        
			end		 
			movableItem:addEventListener( "tap", movableItem)	
		end					
		movableItem:addEventListener("touch", movableItem)
		if o.parentEvent ~= nil then
			movableItem:touch(o.parentEvent)		   
		end
		
		self.movableItem = movableItem
		setmetatable(o, self)
		self.__index = self
		return self
	end 
	setmetatable(o, self)
	self.__index = self
	return o
end
-- TubeItem is inheritance of MovableItem
TubeItem = MovableItem:new()	
function TubeItem:initializeOverride()  
  self.imagePath = self.factory.imagePath
  self.spritePath = self.factory.spritePath
  self.physicsType = self.factory.movableType .. "_" .. self.factory.kind
  self.tapRotateAngle = 90  
  self.hightlight_layer = layer_hightlight_1
  self.canTap = true
end

-- Matraz is inheritance of MovableItem
Matraz = MovableItem:new()
function Matraz:initializeOverride() 
  self.imagePath = self.factory.imagePath
  self.spritePath = self.factory.spritePath
  self.physicsType = self.factory.movableType
  self.tapRotateAngle = 90 
  self.hightlight_layer = layer_hightlight_2
  self.canTap = false
  
  sprite.add( self.spriteSet1, "collision", 2, 1, 1000, 0 ) -- play 8 frames every 1000 ms
end

-- Antenna is inheritance of MovableItem
Antenna = MovableItem:new()
function Antenna:initializeOverride() 
  self.imagePath = self.factory.imagePath
  self.spritePath = self.factory.spritePath
  self.physicsType = self.factory.movableType
  self.tapRotateAngle = 45 
  self.hightlight_layer = layer_hightlight_3
  self.canTap = true
end