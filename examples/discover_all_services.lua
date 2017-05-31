--[[

    Copyright (c) 2015 Frank Edelhaeuser
    Modified work Copyright (c) 2017 Uday G

    This file is part of lua-mdns.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

]]--

mc = require('../mdnsclient')

-- constants
local service_to_query = '' --service pattern to search
local query_timeout = 2 -- seconds

-- handler to do some thing useful with mdns query results
local result_handler  = function(err,res)
    if (res) then
        print('Results:')
        for k,v in pairs(res) do
            print(k)
            for k1,v1 in pairs(v) do
                print('  '..k1..': '..v1)
            end
        end
    else
        print('no result')
    end
end

print('Connecting to wifi')
wifi.setmode(wifi.STATION)
wifi.sta.config('SSID', 'PASSWORD')
wifi.sta.getip()

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    local own_ip = T.IP
    print('Starting mdns discovery')
    mc.query( service_to_query, query_timeout, own_ip,  result_handler)
end)
