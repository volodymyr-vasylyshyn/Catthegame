-- Project: Lime
--
-- Date: 09-Feb-2011
--
-- Version: 3.4
--
-- File name: lime-property.lua
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
----									CLASS METATABLE											----
----------------------------------------------------------------------------------------------------

Property = {}
Property_mt = { __index = Property }

----------------------------------------------------------------------------------------------------
----									CLASS VARIABLES											----
----------------------------------------------------------------------------------------------------

Property.version = 3.4

----------------------------------------------------------------------------------------------------
----									LOCALISED VARIABLES										----
----------------------------------------------------------------------------------------------------

local utils = lime.utils
local decodeJsonSafely = utils.decodeJsonSafely
local getValueFromSeed = utils.getValueFromSeed
local isPropertyASeed = utils.isPropertyASeed

----------------------------------------------------------------------------------------------------
----									PUBLIC METHODS											----
----------------------------------------------------------------------------------------------------

---Create a new instance of a Property object.
-- @param name The name of the Property.
-- @param value The value of the Property.
-- @return The newly created property instance.
function Property:new(name, value)

    local self = {}    -- the new instance
    
    setmetatable( self, Property_mt ) -- all instances share the same metatable
    
    self.name = name
    
    -- First try to get a value from a seed.
    -- If the property is not a seed then
    -- it will just be returned untouched
    -- as a string.
    
    if isPropertyASeed(value) then
    	self.value = getValueFromSeed(value)
    else
    	self.value = decodeJsonSafely(value)
    end	
	
    return self
    
end

--- Gets the name of the Property. 
-- @return The name of the Property.
function Property:getName()
	return self.name
end

--- Gets the value of the Property. 
-- @return The value of the Property.
function Property:getValue()	
	return self.value
end

--- Sets the value of the Property. 
-- @param value The new value.
function Property:setValue(value)
	self.value = decodeJsonSafely(value)
end
