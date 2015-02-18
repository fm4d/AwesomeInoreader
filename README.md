# AwesomeInoreader
Widget for AwesomeWM to display total amount of unread articles.


Requirements
------------
```
luarocks install luasec
luarocks install lua-cjson
```

Usage
-----
Put ```ino.lua``` in your awesome folder (```~/.config/awesome/```).

Import with ```local ino = require("ino")``` 

Create widget with
```
inowidget = wibox.widget.textbox()
inohandler = ino.Ino("your@email.com", "YourPassword")
inotimer = timer({ timeout = 15 })
inotimer:connect_signal("timeout", function() inowidget:set_text(inohandler:getUnread()) end)
inowidget:set_text("...")
inotimer:start()
```
Timeout means how often you want to fetch unread count from Inoreader server.

This widget will only display number of unread articles or error code:  
"A" - unable to authorize  
"E" - unable to get data about unread articles

Auth token actually lasts 30 days, but I am too lazy to store it.

