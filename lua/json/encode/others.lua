--[[
	Licensed according to the included 'LICENSE' document
	Author: Thomas Harning Jr <harningt@gmail.com>
]]
local tostring = tostring

local assert = assert
local jsonutil = require("json.util")
local util_merge = require("json.util").merge
local type = type

local is_52 = _VERSION == "Lua 5.2"
local _G = _G

if is_52 then
	_ENV = nil
end

-- Shortcut that works
local encodeBoolean = tostring

local defaultOptions = {
	allowUndefined = true,
	null = jsonutil.null,
	undefined = jsonutil.undefined
}

local default = nil -- Let the buildCapture optimization take place
local strict = {
	allowUndefined = false
}

local function getEncoder(options)
	options = options and util_merge({}, defaultOptions, options) or defaultOptions
	local function encodeOthers(value, state)
		if value == options.null then
			return 'null'
		elseif value == options.undefined then
			assert(options.allowUndefined, "Invalid value: Unsupported 'Undefined' parameter")
			return 'undefined'
		else
			return false
		end
	end
	local function encodeBoolean(value, state)
		return value and 'true' or 'false'
	end
	local nullType = type(options.null)
	local undefinedType = options.undefined and type(options.undefined)
	-- Make sure that all of the types handled here are handled
	local ret = {
		boolean = encodeBoolean,
		['nil'] = function() return 'null' end,
		[nullType] = encodeOthers
	}
	if undefinedType then
		ret[undefinedType] = encodeOthers
	end
	return ret
end

local others = {
	encodeBoolean = encodeBoolean,
	default = default,
	strict = strict,
	getEncoder = getEncoder
}

if not is_52 then
	_G.json = _G.json or {}
	_G.json.encode = _G.json.encode or {}
	_G.json.encode.others = others
end

return others
