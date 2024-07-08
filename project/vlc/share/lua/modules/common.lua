--[[ This code is public domain (since it really isn't very interesting) ]]--

local common = {}

-- Iterate over a table in the keys' alphabetical order
function common.pairs_sorted(t)
    local s = {}
    for k,_ in pairs(t) do table.insert(s,k) end
    table.sort(s)
    local i = 0
    return function () i = i + 1; return s[i], t[s[i]] end
end

-- Return a function such as skip(foo)(a,b,c) = foo(b,c)
function common.skip(foo)
    return function(discard,...) return foo(...) end
end

-- Return a function such as setarg(foo,a)(b,c) = foo(a,b,c)
function common.setarg(foo,a)
    return function(...) return foo(a,...) end
end

-- Trigger a hotkey
function common.hotkey(arg)
    local id = vlc.misc.action_id( arg )
    if id ~= nil then
        vlc.var.set( vlc.object.libvlc(), "key-action", id )
        return true
    else
        return false
    end
end

-- Take a video snapshot
function common.snapshot()
    local vout = vlc.object.vout()
    if not vout then return end
    vlc.var.set(vout,"video-snapshot",nil)
end

-- Naive (non recursive) table copy
function common.table_copy(t)
    c = {}
    for i,v in pairs(t) do c[i]=v end
    return c
end

-- tonumber() for decimals number, using a dot as decimal separator
-- regardless of the system locale 
function common.us_tonumber(str)
    local s, i, d = string.match(str, "^([+-]?)(%d*)%.?(%d*)$")
    if not s or not i or not d then
        return nil
    end

    if s == "-" then
        s = -1
    else
        s = 1
    end
    if i == "" then
        i = "0"
    end
    if d == nil or d == "" then
        d = "0"
    end
    return s * (tonumber(i) + tonumber(d)/(10^string.len(d)))
end

-- tostring() for decimals number, using a dot as decimal separator
-- regardless of the system locale 
function common.us_tostring(n)
    s = tostring(n):gsub(",", ".", 1)
    return s
end

-- strip leading and trailing spaces
function common.strip(str)
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

-- print a table (recursively)
function common.table_print(t,prefix)
    local prefix = prefix or ""
    if not t then
        print(prefix.."/!\\ nil")
        return
    end
    for a,b in common.pairs_sorted(t) do
        print(prefix..tostring(a),b)
        if type(b)==type({}) then
            common.table_print(b,prefix.."\t")
        end
    end
end

-- print the list of callbacks registered in lua
-- useful for debug purposes
function common.print_callbacks()
    print "callbacks:"
    common.table_print(vlc.callbacks)
end 

-- convert a duration (in seconds) to a string
function common.durationtostring(duration)
    return string.format("%02d:%02d:%02d",
                         math.floor(duration/3600),
                         math.floor(duration/60)%60,
                         math.floor(duration%60))
end

-- realpath
-- this is for URL paths - do not use for file paths as this has
-- no support for Windows '\' directory separators
function common.realpath(path)
    -- detect URLs to extract and process the path component
    local s, p, qf = string.match(path, "^([a-zA-Z0-9+%-%.]-://[^/]-)(/[^?#]*)(.*)$")
    if not s then
        s = ""
        p = path
        qf = ""
    end

    local n
    repeat
        p, n = p:gsub("//","/", 1)
    until n == 0

    repeat
        p, n = p:gsub("/%./","/", 1)
    until n == 0
    p = p:gsub("/%.$", "/", 1)

    -- resolving ".." without an absolute path would be troublesome
    if p:match("^/") then
        repeat
            p, n = p:gsub("^/%.%./","/", 1)
            if n == 0 then
                p, n = p:gsub("/[^/]+/%.%./","/", 1)
            end
        until n == 0
        p = p:gsub("^/%.%.$","/", 1)
        p = p:gsub("/[^/]+/%.%.$","/", 1)
    end

    return s..p..qf
end

-- parse the time from a string and return the seconds
-- time format: [+ or -][<int><H or h>:][<int><M or m or '>:][<int><nothing or S or s or ">]
function common.parsetime(timestring)
    local seconds = 0
    local hourspattern = "(%d+)[hH]"
    local minutespattern = "(%d+)[mM']"
    local secondspattern = "(%d+)[sS\"]?$"

    local _, _, hoursmatch = string.find(timestring, hourspattern)
    if hoursmatch ~= nil then
        seconds = seconds + tonumber(hoursmatch) * 3600
    end
    local _, _, minutesmatch = string.find(timestring, minutespattern)
    if minutesmatch ~= nil then
        seconds = seconds + tonumber(minutesmatch) * 60
    end
    local _, _, secondsmatch = string.find(timestring, secondspattern)
    if secondsmatch ~= nil then
        seconds = seconds + tonumber(secondsmatch)
    end

    if string.sub(timestring,1,1) == "-" then
        seconds = seconds * -1
    end

    return seconds
end

-- seek
function common.seek(value)
    if value ~= nil then
        if string.sub(value,-1) == "%" then
            local number = common.us_tonumber(string.sub(value,1,-2))
            if number ~= nil then
                local posPercent = number/100
                if string.sub(value,1,1) == "+" or string.sub(value,1,1) == "-" then
                    vlc.player.seek_by_pos_relative(posPercent);
                else
                    vlc.player.seek_by_pos_absolute(posPercent);
                end
            end
        else
            local posTime = common.parsetime(value) * 1000000 -- secs to usecs
            if string.sub(value,1,1) == "+" or string.sub(value,1,1) == "-" then
                vlc.player.seek_by_time_relative(posTime)
            else
                vlc.player.seek_by_time_absolute(posTime)
            end
        end
    end
end

function common.volume(value)
    if type(value)=="string" and string.sub(value,1,1) == "+" or string.sub(value,1,1) == "-" then
        vlc.volume.set(vlc.volume.get()+tonumber(value))
    else
        vlc.volume.set(tostring(value))
    end
end

_G.common = common
return common
