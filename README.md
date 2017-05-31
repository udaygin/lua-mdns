# nodemcu-mdns-clent 

Multicast DNS (mDNS) service client/browser in pure Lua for nodemcu platform. mDNS provides the ability to provide and find DNS names for local devices. For more information on mDNS and DNS Service discovery, see <http://www.dns-sd.org>.

## Background 

I am often presented with the problem of hardcoding _Mqtt broker, Webserver IPs_ in iot-device firmware and nodemcu being my favourite, my lua code has a lot of hardcoded IPs. And this model breaks when server IP changes. So wanted the device to auto discover services by type and started looking for solutions. Finally, zeroconf/mdns looked like the best option for this usecase. While searching for nodemcu modules, I found the work of @mrpace2 at mrpace2/lua-mdns and ported it to work with nodemcu platform network stack and callback style. 

this is only for finding other devices from nodemcu. Instead, if you are looking for a way to make your esp8266 discoverable in local network with out knowing the IP, it is already available in nodemcu firmware as a [module](https://nodemcu.readthedocs.io/en/master/en/modules/mdns/) .  

## Download and Installation

since this is a single module file, I suggest raw file download for [mdnsclient.lua module]( mdnsclient.lua?raw=true ) into your project instead of a repo checkout. This is meant to be used in your project.

## Example 

The code below queries all mqtt brokers available on the local network and prints the IP address and port number for the first one

```lua
    mc = require('mdnsclient')
    local service_to_query = '_mqtt._tcp' --service pattern to search. this is for mqtt brokers
    local query_timeout = 2 -- 2 seconds

    -- handler to do some thing useful with mdns query results
    local query_result_handler  = function(err,query_result)
        if (query_result ~= nil) then
            print("Got Query results")
            local broker_ip,broker_port = mc.extractIpAndPortFromResults(res,1)
            print('Broker '..broker_ip ..":"..broker_port)
        else
            print('no mqtt brokers found in local network. please ensure that they are running and advertising on mdns')
        end
    end
    
    print('Connecting to wifi')
    wifi.setmode(wifi.STATION)
    wifi.sta.config('<SSID>', '<PASSWORD>')
    wifi.sta.getip()
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP)
        mc.mdns_query( service_to_query, query_timeout, T.IP, query_result_handler)
    end)
```
If called without parameters, `query` returns all available services after the default timeout of 2 seconds. Additional examples can be found in the `examples` subdirectory.


## Reference

The only exported function is _query_.

### query

**Usage**
```lua
    mdnsclient = require('mdnsclient')
    result = mdnsclient.query([<service>, <timeout_in_sec>,<esp8266_ip>,<callback>])
```

**Parameters**

_query_ takes up to two parameters:

* **service**: mDNS service name (e.g. \_printers.\_tcp.local). The _.local_ suffix may be omitted. If this parameter is missing or if it evaluates to `nil`, _mdns\_resolve_ queries all available mDNS services by using enumerating the *\_services.\_dns-sd.\_udp.local* service.

* **timeout**: Timeout in seconds waiting for mDNS responses. If this parameter is missing or if it evaluates to `nil`, _mdns\_resolve_ uses the dafault timeout of 2 seconds.

* **own_ip**: Timeout in seconds waiting for mDNS responses. If this parameter is missing or if it evaluates to `nil`, _mdns\_resolve_ uses the dafault timeout of 2 seconds.

* **callback**: If _query_ succeeds, an associateve array of service descriptors is returned as a Lua table to the callback method which should expect two parameters like this `callback(err,result)`. Please note that the array may be empty if there is no mDNS service available on the local network. In case of error, _err_ is populated ad result is nil.


Service descriptors returned by _mdns\_query_ may contain a combination of the following fields:

* **name**: mDNS service name (e.g. _HP Laserjet 4L @ server.example.com_)
* **service**: mDNS service type (e.g. _\_ipps.\_tcp.local_)
* **hostname**: hostname
* **port**: port number
* **ipv4**: IPv4 address
* **ipv6**: IPv6 address

_mdns\_resolve_ returns whatever information the mDNS daemons provide. The presence of certain fields doesn't imply that the system running _lua-mdns_ supports all features. For example, an IPv6 address may be returned even though the LuaSocket library installed on the system may not support IPv6. Resolving such potetial mismatches is beyond the scope of _lua-mdns_.

**Return value** 
nil. 


## License

_nodemcu-mdns-client_ is released under the MIT license.


    Original work Copyright (c) 2015 Frank Edelhaeuser
    Modified work Copyright (c) 2017 Uday G
    
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
