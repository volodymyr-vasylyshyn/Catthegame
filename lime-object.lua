-- Project: Lime
--
-- Date: 09-Feb-2011
--
-- Version: 3.4
--
-- File name: lime-object.lua
--
-- Author: Graham Ranson 
--
-- Support: www.justaddli.me
--
-- Copyright (C) 2011 MonkeyDead Studios Limited. All Rights Reserved.

----------------------------------------------------------------------------------------------------
----									POLITE NOTICE / PSA										----
----------------------------------------------------------------------------------------------------
----																							----
----	I have put a lot of work into this library and plan to support it for a very, very		---- 
----	long time so please don't give the code to anyone else. I doubt that anyone would as	----
----	we are all developers in the same boat but I just thougt I would put this here in 		----
----	case any one wondered if it was ok to share.											----
----																							----
----	If you did get this code through less than legitimate means then please consider		----
----	buying it legally, it is (I think) affordably priced and you will get free updates		----
----	and support	for life.																	----
----																							----
----	I hope you enjoy using it as much as I have enjoyed writing it and I also hope that		----
----    you will support me and the development of Lime by telling your friends about it etc	----
----	although naturally I don't require any link backs of any kind, it is completely up		----
----	to you.																					----
----																							----
----	If you have any additions or fixes that you would like included in the main releases	----
----	please contact me via the forums or email - graham@grahamranson.co.uk					----
----																							----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----									CLASS METATABLE											----
----------------------------------------------------------------------------------------------------

Object = {}
Object_mt = { __index = Object }

----------------------------------------------------------------------------------------------------
----									CLASS VARIABLES											----
----------------------------------------------------------------------------------------------------

Object.version = 3.4

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

local utils = lime.utils
local calculateViewpoint = utils.calculateViewpoint
local isometricToWorldPosition = utils.isometricToWorldPosition
local worldToIsometricPosition = utils.worldToIsometricPosition
local round = utils.round
local clampPosition = utils.clampPosition
local moveObject = utils.moveObject
local dragObject = utils.dragObject
local readInConfigFile = utils.readInConfigFile
local addObjectToGroup = utils.addObjectToGroup
local copyPropertiesToObject = utils.copyPropertiesToObject
local stringToBool = utils.stringToBool
local addPropertiesToBody = utils.addPropertiesToBody
local addCollisionFilterToBody = utils.addCollisionFilterToBody
local applyPhysicalParametersToBody = utils.applyPhysicalParametersToBody
local splitString = utils.splitString

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

--- Create a new instance of an Object object.
-- @param data The XML data.
-- @param map The current Map object.
-- @param objectLayer The ObjectLayer the the Object resides on.
-- @return The newly created object instance.
function Object:new(data, map, objectLayer)

    local self = {}    -- the new instance
    
    setmetatable( self, Object_mt ) -- all instances share the same metatable
    
    self.properties = {}
    self.map = map
    self.objectLayer = objectLayer
    
    -- Extract header info, name, x, y, width, height	
	for key, value in pairs(data['Attributes']) do
		self:setProperty(key, value)
	end
	
	local node = nil
	local attributes = nil
	
	-- Loop through all the child nodes
	for i=1, #data["ChildNodes"], 1 do
		
		node = data["ChildNodes"][i]
		
		if node.Name == "properties" then
		
			-- Loop through all the child nodes
			for j=1, #node["ChildNodes"], 1 do
				
				-- Each child node is a property, the attributes are the name and value
				attributes = node["ChildNodes"][j]["Attributes"]
				
				if attributes then	
					if attributes.name == "configFile" then
						readInConfigFile(attributes.value, self)	
					else
						property = self:setProperty(attributes.name, attributes.value)
					end
				end
				
			end
			
		end
		
	end

    return self
    
end

--- Sets the position of the Object.
-- @param x The new X position of the Object.
-- @param y The new Y position of the Object.
function Object:setPosition(x, y)

	self.x = x
	self.y = y

	if self.sprite then
		self.sprite.x = x
		self.sprite.y = y
	end
	
	if self.debugImage then
		self.debugImage.x = x
		self.debugImage.y = y
	end

end

--- Gets the position of the Object.
-- @return The X position of the Object.
-- @return The Y position of the Object.
function Object:getPosition()
	return self.x, self.y
end

--- Sets the value of a Property of the Object. Will create a new Property if none found.
-- @param name The name of the Property.
-- @param value The new value.
-- @return
function Object:setProperty(name, value)
		
	local property = self:getProperty(name)

	if property then
		return property:setValue(value)
	else
		self:addProperty(Property:new(name, value))
	end
	
	self[name] = self:getPropertyValue(name)
end

--- Gets a Property of the Object.
-- @param name The name of the Property.
-- @return The Property. nil if no Property found.
function Object:getProperty(name)
	return self.properties[name]
end

--- Gets the value of a Property of the Object.
-- @param name The name of the Property.
-- @return The Property value. nil if no Property found.
function Object:getPropertyValue(name)
	
	local property = self:getProperty(name)
	
	if property then
		return property:getValue()
	end
	
end

--- Gets a list of all Properties of the Object.
-- @return The list of Properties.
function Object:getProperties()
	return self.properties
end

--- Gets the value of a property on a tile object.
--	Originally created by FrankS - http://developer.anscamobile.com/forum/2011/02/19/additional-convenience-functions-navigate-lime-world-tree
-- @param name The name of the property to look for.
-- @return The value of the property. Nil if none found.
function Object:getObjectTilePropertyValue(name)

	if name then
	
		if self[name] then -- local object property
		
			return self[name]
			
		else  -- return the associated tile property value (if it exists)
		
			return self.map:getTilePropertyValueForGID(self.gid, name)
			
		end
	end
	
end

--- Gets a count of how many properties the Object has.
-- @return The Property count.
function Object:getPropertyCount()

	local count = 0
	
	for _k, _v in pairs(self.properties) do
		count = count + 1
	end

	return count
end

--- Checks whether the Object has a certain Property.
-- @param name The name of the property to check for.
-- @return True if the Object has the Property, false if not.
function Object:hasProperty(name)
	return self:getProperty(name) ~= nil
end

--- Adds a Property to the Object. 
-- @param property The Property to add.
-- @return The added Property.
function Object:addProperty(property)
	self.properties[property:getName()] = property
	
	self[property:getName()] = property:getValue()
	
	return property
end

--- Removes a Property from the Object. 
-- @param name The name of the Property to remove.
function Object:removeProperty(name)
	self.properties[name] = nil
end

--- Moves the Object.
-- @param x The amount to move the Object along the X axis.
-- @param y The amount to move the Object along the Y axis.
function Object:move(x, y)
	moveObject(self, x, y)
	
	if self.body then moveObject(self.body, x, y) end
	if self.debugImage then moveObject(self.debugImage, x, y) end	
end

--- Drags the Object.
-- @param The Touch event.
function Object:drag(event)
	dragObject(self, event)
	
	if self.body then dragObject(self.body, event) end
	if self.debugImage then dragObject(self.debugImage, event) end
end

--- Shows the Object.
function Object:show()

	if self.debugImage then
		self.debugImage.isVisible = true
	end
	
	if self.sprite then
		self.sprite.isVisible = true
	end
	
end

--- Hides the Object.
function Object:hide()
	
	if self.debugImage then
		self.debugImage.isVisible = false
	end
	
	if self.sprite then
		self.sprite.isVisible = false
	end
	
end

--- Gets the Object visual.
function Object:getVisual()
	return self.group
end

--- Sets the rotation of the Object.
-- @param The new rotation.
function Object:setRotation(angle)

	if self.debugImage then
		self.debugImage.rotation = angle
	end
	
	if self.body then
		self.body.rotation = angle
	end
	
end

--- Rotates the Object.
-- @param The angle to rotate by
function Object:rotate(angle)

	if self.debugImage then
		self.debugImage.rotation = self.debugImage.rotation + angle
	end
	
	if self.body then
		self.body.rotation = self.body.rotation + angle
	end
	
end

--- Shows the debug image of this Object.
function Object:showDebugImage()
	
	if self.debugImage then
		self.debugImage.isVisible = true
	end
	
end

--- Hides the debug image of this Object.
function Object:hideDebugImage()

	if self.debugImage then
		self.debugImage.isVisible = false
	end
	
end

--- Checks if the debug image of this Object is visible or not.
-- @return True if it is, false if not.
function Object:isDebugImageVisible()

	if self.debugImage then
		return self.debugImage.isVisible
	end
	
end

--- Toggles the visibility of the debug image of this Object.
function Object:toggleDebugImageVisibility()
	
	if self.debugImage then
		
		if self:isDebugImageVisible() then
			self:hideDebugImage()
		else
			self:showDebugImage()
		end
		
	end
	
end	

--- Creates the visual debug representation of the Object.
function Object:create()

	-- If an object has a GID then it is one of the new TileObjects brought into Tiled version 0.6.0
	if self:hasProperty("gid") then
		
		-- Get the correct tileset using the GID
		self.tileSet = self.map:getTileSetFromGID( self:getPropertyValue("gid") )
		
		if self.tileSet then
		
			-- Create the actual Corona sprite object
			self.sprite = sprite.newSprite(self.tileSet.spriteSet)
			
			-- Set the sprites frame to the current tile in the tileset
			self.sprite.currentFrame = self.gid - (self.tileSet.firstgid) + 1
			
			-- Copy over the properties to the sprite
			copyPropertiesToObject(self, self.sprite)
			 
			-- Add the sprite to the group
			self.objectLayer.group:insert(self.sprite)
			
			if(self.map.orientation == "orthogonal" ) then

				-- Place this tile in the right X position
				self.sprite.x = self.x + ( self.sprite.width * 0.5 )
				
				-- Place this tile in the right Y position
				self.sprite.y = self.y - ( self.sprite.height * 0.5 )
			
			elseif(self.map.orientation == "isometric") then

				local isoPosition = isometricToWorldPosition( self.map, self.sprite )
				
				self.sprite.x = isoPosition.x
				self.sprite.y = isoPosition.y - ( self.sprite.height / 2 )
				
				self.sprite.z = isoPosition.y
				
			end
			
		end
					
	else
	
		if self.image then
		
			if self["imageWidth"] and self["imageHeight"] then
				
				self.sprite = display.newImageRect(self.objectLayer.group, self.image, self["imageWidth"], self["imageHeight"])
			else
				self.sprite = display.newImage(self.objectLayer.group, self.image)
			end
			
			local position = isometricToWorldPosition( self.map, self )
			self.sprite.x = position.x
			self.sprite.y = position.y
			self.sprite.z = position.y
			
		end
		
		if self.width and self.height then -- Create a rounded rectangle for the debug image
			
			if(self.map.orientation == "orthogonal" ) then

				self.debugImage = display.newRoundedRect(self.objectLayer.group, self.x, self.y, self.width, self.height, 5)
	
			elseif(self.map.orientation == "isometric") then
				
				local points = {}
			
				points[1] = isometricToWorldPosition( self.map, { x = self.x, y = self.y } )
				points[2] = isometricToWorldPosition( self.map, { x = self.x + self.width, y = self.y } )
				points[3] = isometricToWorldPosition( self.map, { x = self.x + self.width, y = self.y + self.height } )
				points[4] = isometricToWorldPosition( self.map, { x = self.x, y = self.y + self.height } )
				
				self.debugImage = display.newLine( self.objectLayer.group, points[1].x, points[1].y, points[2].x, points[2].y )
				self.debugImage:append( points[3].x, points[3].y )
				self.debugImage:append( points[4].x, points[4].y )
				self.debugImage:append( points[1].x, points[1].y )
				
				self.debugImage:setColor( self.objectLayer.color.r, self.objectLayer.color.g, self.objectLayer.color.b )
				self.debugImage.width = 3
			
			end
			
			self.debugImage.z = 1
		
		else -- Create a circle
		
			local position = isometricToWorldPosition( self.map, self )
			
			self.debugImage = display.newCircle( self.objectLayer.group, position.x, position.y, 10 )
		
			self.debugImage.z = 1
			
		end
		
		self.debugImage.strokeWidth = 2
		
		if self.debugImage["setFillColor"] then
			self.debugImage:setFillColor( self.objectLayer.color.r, self.objectLayer.color.g, self.objectLayer.color.b, 50 )
		end
		
		if self.debugImage["setStrokeColor"] then
			self.debugImage:setStrokeColor( self.objectLayer.color.r, self.objectLayer.color.g, self.objectLayer.color.b )
		end
		
		self.debugImage.isVisible = false
		
		if self.map["Objects:DisplayDebug"] then
			if stringToBool(self.map["Objects:DisplayDebug"]) == true then
				self.debugImage.isVisible = true
			end
		end
	end
	
	self.map:fireObjectListener(self)
		
	for key, value in pairs(self.properties) do
		self.map:firePropertyListener(self.properties[key], "object", self)
	end
	
end

--- Builds the physical representation of the Object.
function Object:build()
	
	local body = nil
	
	if not self.map.world then
		self.map.world = display.newGroup()
	end
	
	if not self.objectLayer.group then
		self.objectLayer.group = display.newGroup()
	end
	
	if self.sprite then
		
		body = self.sprite

	elseif(self.radius) then
	
		body = display.newCircle( self.objectLayer.group, self.x, self.y, self.radius )
	
	elseif(self.points) then			
		
		local pointObjectNames = nil
		
		if type(self.points) == "string" then
			pointObjectNames = splitString(self.points, ",")
			
			local jsonVersion = "[ "
			
			for i = 1, #pointObjectNames, 1 do
				jsonVersion = jsonVersion .. "\"" .. pointObjectNames[i] .. "\""
				
				if i < #pointObjectNames then
					jsonVersion = jsonVersion .. ", "
				end
			end
			
			jsonVersion = jsonVersion .. " ]"
			
			print("Lime-Banana: Using strings to define the points of Object bodies is currently depreceated as Lime 3.0 and beyond is moving over to Json values for properties. The Json equivalent for this property is - " .. jsonVersion)
			
		elseif type(self.points) == "table" then
			pointObjectNames = self.points
		end
		
		if pointObjectNames then
	
			local objects = {}
			self.shape = {}
			
			for i=1, #pointObjectNames, 1 do
				local pointObject = self.objectLayer:getObject(pointObjectNames[i])
				
				if pointObject then
					objects[#objects + 1] = pointObject
				end
			end
			
			-- Make sure there are enough points (2 entries for each point)
			if(#objects > 1) then
	
				body = display.newLine( self.objectLayer.group, objects[1].x, objects[1].y, objects[2].x, objects[2].y )
	
				if(body) then
					for i=3, #objects, 1 do
						body:append( objects[i].x, objects[i].y )	
					end
				end
			end
			
			-- Rejoin the shape
			if objects[1] ~= objects[#objects] then
				body:append( objects[1].x, objects[1].y )
			end
					
			body.width = 3 
			body:setColor( 0, 2.6, 0 )
			
			
			for i=1, #objects, 1 do
				local pointObject = objects[i]
				
				-- Add the shape points and make sure to offset it so that it is created in the right place
				if pointObject then
					self.shape[#self.shape + 1] = pointObject.x - body.x
					self.shape[#self.shape + 1] = pointObject.y	- body.y
				end
				
			end
			
			self.shapeObjects = objects
		end
	
	elseif(self.shape) then	
	
		if type(self.shape) == "table" then
		
			body = display.newRect( self.objectLayer.group, self.x, self.y, self.width or 1, self.height or 1 ) 
			
		elseif type(self.shape) == "string" or type(self.shape) == "number" then
			
			local jsonVersion = "[0,-37,37,-10,23,34,-23,34,-37,-10]"			
			print("Lime-Banana: Using strings to define the shapes of Object bodies is currently depreceated as Lime 3.0 and beyond is moving over to Json values for properties. Instead, define it similar to this - " .. jsonVersion)
			
			
			--[[
            local splitShape = splitString(self.shape, ",")
            
            
            if #splitShape > 1 then
   
                local shape = {}
                
                for i = 1, #splitShape, 1 do
                	shape[#shape + 1] = tonumber(splitShape[i])
                end
               
               	body = display.newRect( self.map.world, self.x, self.y, self.width or 1, self.height or 1 ) 
              	
              	self.shape = shape
              	
            end
            --]]
        end		
        
	else	
		body = display.newRect( self.objectLayer.group, self.x, self.y, self.width or 1, self.height or 1 ) 
	end

	if(body) then

		addPropertiesToBody(body, self)
		
		body.isVisible = false
		
		if self.gid or self.sprite then
			body.isVisible = true
		end
					
		addCollisionFilterToBody( self )		
				
		physics.addBody( body, self )

		applyPhysicalParametersToBody(body, self)
		
		self.rotation = self.rotation or 0
		
		body.type = self.type
		body.name = self.name
		
		if not self.shape then
			body.x = body.x + body.width * 0.5
			body.y = body.y + body.height * 0.5
		end
		
		self.body = body

	end
		
end

--- Completely removes all visual and physical objects associated with the Object.
function Object:destroy()

	if self.debugImage and self.debugImage["removeSelf"] then
		self.debugImage:removeSelf()
	end
	
	self.debugImage = nil
	
	if self.body and self.body["removeSelf"]  then
		self.body:removeSelf()
	end
	
	self.body = nil

end
