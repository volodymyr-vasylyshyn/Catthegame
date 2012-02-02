-- Project: Lime
--
-- Date: 18-Feb-2011
--
-- Version: 3.4
--
-- File name: lime-interface.lua
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

module(..., package.seeall)

----------------------------------------------------------------------------------------------------
----									MODULE VARIABLES										----
----------------------------------------------------------------------------------------------------

version = 3.4
defaultTextColour = {0, 0, 0, 255}

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

local utils = lime.utils

----------------------------------------------------------------------------------------------------
----									REQUIRED MODULES										----
----------------------------------------------------------------------------------------------------

local ui = utils.loadModuleSafely("ui")

----------------------------------------------------------------------------------------------------
----									PRIVATE METHODS											----
----------------------------------------------------------------------------------------------------

local onButtonObject = function(object)
	
	-- Force full alpha if none present
	if object.textColour then
		if not object.textColour[4] then
			object.textColour[4] = 255
		end
	else
		object.textColour = defaultTextColour
	end
	
	object.sprite = ui.newButton
	{
        default = object.default,
        over = object.over,
      --  onEvent = buttonHandler,
        text = object.text or object.name or "",
        font = object.font,
        textColor = object.textColour,
        size = object.size,
        emboss = object.emboss
	}
	
	utils.copyPropertiesToObject(object, object.sprite, {"width", "height"})
	
	object.sprite.x = object.sprite.x + object.sprite.width / 2
	object.sprite.y = object.sprite.y + object.sprite.height / 2

	object.objectLayer.group:insert(object.sprite)  
end

local onWebPopupObject = function(object)

	local baseDir = object.baseDirectory
	
	if baseDir then
		if string.tolower(baseDir) == "documents" or "docs" then
			baseDir = system.DocumentsDirectory
		elseif string.tolower(baseDir) == "temp" or "tmp" then
			baseDir = system.ResourceDirectory
		else
			baseDir = system.TempDirectory
		end	
	end
	
	if lime.isSimulator then
		object.sprite = display.newRect(object.objectLayer.group, object.x, object.y, object.width or 1, object.height or 1)
		object.sprite:setFillColor(255, 255, 255, 255)
		object.sprite.strokeWidth = 3
		object.sprite:setStrokeColor(255, 0, 0, 255)
	else
		native.showWebPopup( object.x, object.y, object.width, object.height, object.url or "http://www.justaddli.me", { baseDirectory = baseDir, hasBackground = object.hasBackground } )
	end
end

local onTextField = function(object)

	if lime.isSimulator then
		object.sprite = display.newRect(object.objectLayer.group, object.x, object.y, object.width or 1, object.height or 1)
		object.sprite:setFillColor(255, 255, 255, 255)
		object.sprite.strokeWidth = 3
		object.sprite:setStrokeColor(255, 0, 0, 255)
	else
	
		-- Force full alpha if none present
		if object.textColour then
			if not object.textColour[4] then
				object.textColour[4] = 255
			end
		else
			object.textColour = defaultTextColour
		end
		
		object.sprite = native.newTextField(object.x, object.y, object.width or 1, object.height or 1)
		object.sprite.align = object.align
		object.sprite.font = object.font
		object.sprite.isSecure = object.isSecure
		object.sprite.size = object.size
		object.sprite.text = object.text or ""
		object.sprite.inputType = object.inputType
		
		if textColour then
			object.sprite:setTextColor(object.textColour[1], object.textColour[2], object.textColour[3], object.textColour[4])
		end
		
	end
	
end

local onTextBox = function(object)

	if lime.isSimulator then
		object.sprite = display.newRect(object.objectLayer.group, object.x, object.y, object.width or 1, object.height or 1)
		object.sprite:setFillColor(255, 255, 255, 255)
		object.sprite.strokeWidth = 3
		object.sprite:setStrokeColor(255, 0, 0, 255)
	else
	
		-- Force full alpha if none present
		if object.textColour then
			if not object.textColour[4] then
				object.textColour[4] = 255
			end
		else
			object.textColour = defaultTextColour
		end
		
		object.sprite = native.newTextBox(object.x, object.y, object.width or 1, object.height or 1)
		object.sprite.align = object.align
		object.sprite.font = object.font
		object.sprite.size = object.size
		object.sprite.text = object.text or ""
		object.sprite.hasBackground = object.hasBackground
		
		if textColour then
			object.sprite:setTextColor(object.textColour[1], object.textColour[2], object.textColour[3], object.textColour[4])
		end
		
	end
	
end

local onLabelObject = function(object)

	-- Force full alpha if none present
	if object.textColour then
		if not object.textColour[4] then
			object.textColour[4] = 255
		end
	else
		object.textColour = defaultTextColour
	end
	
	object.sprite = ui.newLabel
	{
    	textColor = object.textColour,
        bounds = { object.x, object.y, object.width or 1, object.height or 1 },
        text = object.text or object.name or "",
        align = object.align,
        size = object.size,
        font = object.font,
        offset = object.offset
    }
 	
 	utils.copyPropertiesToObject(object, object.sprite, {"width", "height", "x", "y"})
 	
    object.objectLayer.group:insert(object.sprite)    
end

local onText = function(object)

	-- Force full alpha if none present
	if object.textColour then
		if not object.textColour[4] then
			object.textColour[4] = 255
		end
	else
		object.textColour = defaultTextColour
	end

	object.sprite = display.newText(object.objectLayer.group, object.text or object.name or "", 0, 0, object.font, object.size or 50)
	
	if object.textColour then
		object.sprite:setTextColor(object.textColour[1], object.textColour[2], object.textColour[3], object.textColour[4])
	end
  
  	utils.copyPropertiesToObject(object, object.sprite, {"width", "height", "x", "y"})
 	
 	object.sprite.x = object.x + object.sprite.width / 2
	object.sprite.y = object.y + object.sprite.height / 2 
end

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

--- Register a map object so that an interface will be created from it. 
-- @param map - The map object. 
function register(map)

	if ui then
	
		map:addObjectListener("UILabel", onLabelObject)
		map:addObjectListener("UIButton", onButtonObject)
		map:addObjectListener("UIWebPopup", onWebPopupObject)
		map:addObjectListener("UITextField", onTextField)
		map:addObjectListener("UITextBox", onTextBox)
		map:addObjectListener("UIText", onText)
		
	end
	
end
