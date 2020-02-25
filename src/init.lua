local http = game:GetService("HttpService")
local Promise = require(script.Promise)
local httpRequest = {}

local function noop(...) return ... end

httpRequest.__index = httpRequest
httpRequest._default = {
	baseUrl = "", -- Can be used to set a domain or route to request from.
	url = "", -- Will be appended to "baseUrl" if specified.
	method = "GET", -- The HTTP method to use in the request.
	json = true, -- Automatically decode response body from JSON format.
	resolveWithFullResponse = false, -- Whether only the response body should be returned. **Async only!**
	body = nil, -- Usually a string to pass as the request body.
	headers = nil, -- A dictionary of headers to send with the request.
}

local function cloneTable(source)
	if (type(source) == "table") then
		local cloned = {}

		for key, value in next, source do
			cloned[cloneTable(key)] = cloneTable(value)
		end

		return cloned
	end

	return source
end

local function mergeTables(source, ...)
	local tables = {...}

	for _, nextTable in next, tables do
		if (type(nextTable) == "table") then
			for key, value in next, nextTable do
				if (type(source[key]) == "table" and type(value) == "table") then
					source[key] = mergeTables(source[key], value)
				else
					source[key] = value
				end
			end
		end
	end

	return source
end

function httpRequest.toJSON(data)
	return http:JSONEncode(data)
end

function httpRequest.fromJSON(str)
	return http:JSONDecode(str)
end

function httpRequest.default(options)
	local self = setmetatable({}, httpRequest)
	self.__index = self

	self._default = mergeTables(self._default, options)

	return self
end

function httpRequest:__call(options, callback)
	if (type(callback) ~= "function") then callback = noop end
	if (type(options) == "string") then options = { url = options } end

	local requestOpts = mergeTables(cloneTable(self._default), options)
	local isJSON = requestOpts.json

	if (isJSON and requestOpts.Body) then
		-- Set "Content-Type" to "application/json" for JSON requests.
		if (type(requestOpts.headers) == "table") then
			local contentTypeHeader = "Content-Type"

			for key, _ in next, requestOpts.headers do
				if (string.lower(key) == "content-type") then
					contentTypeHeader = key
					break
				end
			end

			requestOpts.headers = mergeTables({
				[contentTypeHeader] = "application/json"
			}, requestOpts.headers)
		else
			requestOpts.headers = {
				["Content-Type"] = "application/json"
			}
		end
	end

	-- Wrapped to prevent "HTTP Requests are not enabled!" spam.
	coroutine.wrap(function()
		local body = (type(requestOpts.body) == "table" and isJSON) and httpRequest.toJSON(requestOpts.body) or requestOpts.body
		local requestBegin = os.time()

		local ok, data = pcall(function()
			return http:RequestAsync({
				Url = requestOpts.baseUrl .. requestOpts.url,
				Method = requestOpts.method,
				Headers = requestOpts.headers,
				Body = body
			})
		end)

		if (not ok) then return callback(data) end

		data.ResponseTime = (os.time() - requestBegin)
		if (isJSON) then data.Body = httpRequest.fromJSON(data.Body) end

		return callback(nil, data, data.Body)
	end)()
end

function httpRequest:async(options)
	if (type(options) == "string") then options = { url = options } end
	options = (type(options) == "table") and options or {}

	return Promise.new(function(resolve, reject)
		self(options, function(err, response, body)
			if (err) then return reject(err) end

			if (options.resolveWithFullResponse) then
				return resolve(response, body)
			end

			return resolve(body)
		end)
	end)
end

return setmetatable({}, httpRequest)
