--[[
    Copyright (c) 2017 Uday G
        
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

--discovers a mqtt broker in the network and connects to it
mc = require('mdnsclient')

--constants
local service_to_query = '_mqtt._tcp' --service pattern to search
local query_timeout = 2 -- seconds
local query_repeat_interval = 10 -- seconds
local query_count_max = 3

local foundBroker = false
local query_count = 0 -- seconds

-- handler to do some thing useful with mdns query results
local result_handler  = function(err,res)
    if (res) then
        print("Got Query results")
        local b_ip, b_port = mc.extractIpAndPortFromResults(res,1)
        if b_ip and b_port then
            foundBroker = true
            m = mqtt.Client("clientid", 120, "user", "password")
            local broker_ip,broker_port,secure = b_ip,b_port,0
            local topic,message,QOS,retain= "/topic", "hello", 0, 0
            print('Connecting to Broker '..broker_ip ..":"..broker_port)
            m:connect(broker_ip, broker_port, secure,
                function(client)
                    client:publish(topic,message,QOS,retain,function(client)
                        m:close();
                    end)
                end)
        else
            print('Browse attempt returned no matching results')
        end
    else
        print('no mqtt brokers found in local network. please ensure that they are running and advertising on mdns')
    end
end

print('Connecting to wifi')
wifi.setmode(wifi.STATION)
wifi.sta.config('SSID', 'PASSWORD')
wifi.sta.getip()

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
            T.netmask.."\n\tGateway IP: "..T.gateway)
    local own_ip = T.IP
    print('Starting mdns discovery')
    query_count = query_count + 1
    mc.query( service_to_query, query_timeout, own_ip,  result_handler)

    tmr.alarm(1,query_repeat_interval * 1000 ,tmr.ALARM_AUTO,function()
        if foundBroker == true then
            tmr.stop(1)
        elseif query_count > query_count_max then
            print("Reached max number of retries. Aborting")
            tmr.stop(1)
        else
            print('Retry mdns discovery - '..query_count)
            query_count = query_count + 1
            mc.query( service_to_query, query_timeout, own_ip,  result_handler)
        end
    end)

end)

