' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
Function Main(args as Dynamic) as Void
    showAppsflyerChannelSGScreen(args)
End Function

sub showAppsflyerChannelSGScreen(args as Dynamic)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)    
    scene = screen.CreateScene("AppsFlyerScene")
    screen.show()
    devkey = "DEV_KEY"
    appid = "APP_ID"
    AppsFlyer().start(devkey, appid)
    AppsFlyer().enableDebugLogs(true) ' same as AppsFlyer().setLogLevel("debug")
    
    if args.Lookup("contentId") <> invalid then
        AppsFlyer().trackDeeplink(args)
    else
        AppsFlyer().trackAppLaunch()
    endif            
    
    ' ConversionData response arrives here
    while true
        msg = Wait(0, m.port)
        ?"MESSAGE RECEIVED: "msg.GetData()
        msgType = Type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then
                return
            end if
        end if
    end while
end sub