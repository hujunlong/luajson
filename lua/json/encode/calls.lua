--[[
	Licensed according to the included 'LICENSE' document
	Author: Thomas Harning Jr <harningt@gmail.com>
]]
local jsonutil = require("json.util")

local table = require("table")
local table_concat = table.concat

local select = select
local getmetatable, setmetatable = getmetatable, setmetatable
local assert = assert

local util = require("json.util")

local util_merge, isCall, decodeCall = util.merge, util.isCall, util.decodeCall

local is_52 = _VERSION == "Lua 5.2"
local _G = _G

if is_52 then
	_ENV = nil
end

local defaultOptions = {
}

-- No real default-option handling needed...
local default = nil
local strict = nil


--[[
	Encodes 'value' as a function call
	Must have parameters in the 'callData' field of the metatable
		name == name of the function call
		parameters == array of parameters to encode
]]
local function getEncoder(options)
	options = options and util_merge({}, defaultOptions, options) or defaultOptions
	local function encodeCall(value, state)
		if not isCall(value) then
			return false
		end
		local encode = state.encode
		local name, params = decodeCall(value)
		local compositeEncoder = state.outputEncoder.composite
		local valueEncoder = [[
		for i = 1, (composite.n or #composite) do
			local val = composite[i]
			PUTINNER(i ~= 1)
			val = encode(val, state)
			val = val or ''
			if val then
				PUTVALUE(val)
			end
		end
		]]
		return compositeEncoder(valueEncoder, name .. '(', ')', ',', params, encode, state)
	end
	return {
		table = encodeCall,
		['function'] = encodeCall
	}
end

local calls = {
	default = default,
	strict = strict,
	getEncoder = getEncoder
}

if not is_52 then
	_G.json = _G.json or {}
	_G.json.encode = _G.json.encode or {}
	_G.json.encode.calls = calls
end
return calls
