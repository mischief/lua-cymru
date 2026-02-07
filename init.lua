--- Team Cymru IP ASN mapping bindings over luv
-- @module cymru

local uv = require("luv")

local host = "v4.whois.cymru.com"

local function parse(ips, chunk)
	local out = {}
	for as, ip, desc in string.gmatch(chunk, "([%d%a]+)%s+|%s+([%d%.]+)%s+|%s+([^\n]+)") do
		out[ip] = { as = as, description = desc }
	end
	return out
end

local M = {}

--- v4_whois translates v4 IPs to ASN numbers.
-- @param ips table of ips or string ip
-- @param callback function(err, table) where table maps IPs to as/description
function M.v4_whois(ips, callback)
	local input
	if type(ips) == "table" then
		input = ips
	elseif type(ips) == "string" then
		input = { ips }
	else
		callback(nil, "input must be table or string")
		return
	end

	local gai = uv.getaddrinfo(host, "whois", {family="inet", protocol="tcp"}, function(err, addrs)
		if err then
			callback(nil, err)
		end

		if #addrs < 1 then
			gai:close()
			callback(nil, "no addresses for " .. host)
		end

		local client = uv.new_tcp()

		client:connect(addrs[1].addr, 43, function(err)
			if err then
				client:close()
				callback(nil, err)
			end

			local req = {}
			table.insert(req, "begin")

			for _, ip in ipairs(input) do
				table.insert(req, ip)
			end

			table.insert(req, "end")

			client:write(table.concat(req, "\n"))

			client:read_start(function(err, chunk)
				client:close()
				if err then
					callback(nil, err)
				end

				if chunk then
					local res = parse(ips, chunk)
					callback(res)
				end
			end)
		end)
	end)
end

return M

