-- Inoreader widget for Awesome WM  3.5 + by fm4d
-- http://wiki.inoreader.com/doku.php?id=api

local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("cjson")



local Ino = {}

-- To allow Ino() instead of Ino:new()
setmetatable(Ino, {
  __call = function (cls, ...)
    return cls:new(...)
  end,
})

function Ino:new(email, password)
    local n= {}
    setmetatable(n, self)
    self.__index = self
    n.email = email
    n.password = password
    return n
end

-- Authorize and set authorization token to self.token
function Ino:authorize()
    local url = "https://www.inoreader.com/accounts/ClientLogin"
    local source = string.format("Email=%s&Passwd=%s", self.email, self.password)
    local sink = {}

    _, code, _, _ = https.request {
        method="POST",
        url=url,
        source=ltn12.source.string(source),
        sink=ltn12.sink.table(sink),
        headers={
                            ["Accept"] = "*/*",
                            ["Accept-Encoding"] = "deflate",
                            ["Accept-Language"] = "en-us",
                            ["Content-Type"] = "application/x-www-form-urlencoded",
                            ["content-length"] = string.len(source)
                       }
    }
    
    assert(code == 200)
    
    self.token = string.match(sink[1], "Auth=(.*)\n")
end

-- Get structure, parse and return total amount of unread articles  
function Ino:unread()
    local url = "https://www.inoreader.com/reader/api/0/unread-count?output=json"
    local sink = {}

    _, code, _, _ = https.request {
        method="POST",
        url=url,
        source=ltn12.source.string(source),
        sink=ltn12.sink.table(sink),
        headers={
                            ["Accept"] = "*/*",
                            ["Accept-Encoding"] = "deflate",
                            ["Accept-Language"] = "en-us",
                            ["Content-Type"] = "application/x-www-form-urlencoded",
                            ["Authorization"] = string.format("GoogleLogin auth=%s", self.token)
                       }
    }

    assert(code == 200)

    res= json.decode(table.concat(sink))

    return res['unreadcounts'][1]['count']
end

-- Handles errors and authorization
function Ino:getUnread()
    if not self.token then 
        if not pcall(self.authorize, self) then
            return "A" end
    end

    local status, result = pcall(self.unread, self)

    if status then 
        return result
    else
        return "E"
    end
end



return {
    Ino=Ino
}



