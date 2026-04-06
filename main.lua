local slf = {}

local function toHex(str)
	return (str:gsub(".", function(c)
		return string.format("%02X", string.byte(c))
	end))
end

local function fromHex(hex)
	return (hex:gsub("..", function(cc)
		return string.char(tonumber(cc, 16))
	end))
end

function slf:key(str, key)
	local t = {}
	for i = 1, #str do
		local c = string.byte(str, i)
		local k = string.byte(key, 1 + ((i-1) % #key))
		t[i] = string.char(bit32.bxor(c, k))
	end
	return toHex(table.concat(t))
end

function slf:deobfuscate(hex, key)
	local gibberish = fromHex(hex)
	local t = {}
	for i = 1, #gibberish do
		local c = string.byte(gibberish, i)
		local k = string.byte(key, 1 + ((i-1) % #key))
		t[i] = string.char(bit32.bxor(c, k))
	end
	local code = table.concat(t)

	local success, err = pcall(function()
		local env = {
		    game = game,
		    workspace = workspace,
		    Players = game:GetService("Players"),
		    ReplicatedStorage = game:GetService("ReplicatedStorage"),
		    ServerStorage = game:GetService("ServerStorage"),
		    StarterGui = game:GetService("StarterGui"),
		    StarterPack = game:GetService("StarterPack"),
		    Lighting = game:GetService("Lighting"),
		    RunService = game:GetService("RunService"),
		    UserInputService = game:GetService("UserInputService"),
		    HttpService = game:GetService("HttpService"),
		    TweenService = game:GetService("TweenService"),
		    ContextActionService = game:GetService("ContextActionService"),
		    CollectionService = game:GetService("CollectionService"),
		    Debris = game:GetService("Debris"),
		    Players = game:GetService("Players"),
		    
		    -- Roblox constructors
		    Instance = Instance,
		    CFrame = CFrame,
		    Vector3 = Vector3,
		    Vector2 = Vector2,
		    Color3 = Color3,
		    BrickColor = BrickColor,
		    NumberRange = NumberRange,
		    NumberSequence = NumberSequence,
		    UDim = UDim,
		    UDim2 = UDim2,
		    Ray = Ray,
		    Enum = Enum,
		    
		    -- Core Lua
		    print = print,
		    warn = warn,
		    error = error,
		    assert = assert,
		    pcall = pcall,
		    xpcall = xpcall,
		    tonumber = tonumber,
		    tostring = tostring,
		    type = type,
		    unpack = unpack or table.unpack,
		    next = next,
		    pairs = pairs,
		    ipairs = ipairs,
		    select = select,
		    coroutine = coroutine,
		    math = math,
		    table = table,
		    string = string,
		    tick = tick,
		    os = os,
		    
		    -- HTTP helpers
		    HttpGet = function(url)
		        return game:GetService("HttpService"):GetAsync(url)
		    end,
		    HttpPost = function(url, data)
		        return game:GetService("HttpService"):PostAsync(url, data)
		    end,
		}

		local fn = loadstring(code)
		setfenv(fn, env) 
		fn()
	end)

	if not success then
		warn("Wrong key or error: ", err)
	end
end

return slf
