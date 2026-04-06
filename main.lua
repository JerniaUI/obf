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
		-- Sandbox environment
		local env = {
			game = game,
			workspace = workspace,
			Players = game:GetService("Players"),
			RunService = game:GetService("RunService"),
			ReplicatedStorage = game:GetService("ReplicatedStorage"),
			HttpService = game:GetService("HttpService"),
			-- Optional HTTP shortcuts
			HttpGet = function(url)
				return game:GetService("HttpService"):GetAsync(url)
			end,
			HttpPost = function(url, data)
				return game:GetService("HttpService"):PostAsync(url, data)
			end,
			print = print,
			warn = warn,
			tostring = tostring,
			tonumber = tonumber,
			math = math,
			table = table,
			string = string,
			coroutine = coroutine,
		}

		local fn = loadstring(code)
		setfenv(fn, env) -- For Lua 5.1; use _ENV for 5.2+
		fn()
	end)

	if not success then
		warn("Wrong key or error: ", err)
	end
end

return slf
