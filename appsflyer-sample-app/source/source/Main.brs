' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********
function Main(args as dynamic) as void
    showAppsflyerChannelSGScreen(args)
end function

sub showAppsflyerChannelSGScreen(args as dynamic)
    ' temp delete registry
    ' deleteReg("AppsFlyerRegistry.roku.dev")

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
    end if

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


function deleteReg(keySection as string) as void
    print "Starting Delete Registry"
    Registry = CreateObject("roRegistry")
    i = 0

    if keySection <> "" then
        RegistrySection = CreateObject("roRegistrySection", keySection)
        for each key in RegistrySection.GetKeyList()
            i = i + 1
            print "Deleting " keySection + ":" key
            RegistrySection.Delete(key)
        end for
        RegistrySection.flush()
    else

        for each section in Registry.GetSectionList()
            RegistrySection = CreateObject("roRegistrySection", section)
            for each key in RegistrySection.GetKeyList()
                i = i + 1
                print "Deleting " section + ":" key
                RegistrySection.Delete(key)
            end for
            RegistrySection.flush()
        end for

    end if

    print i.toStr() " Registry Keys Deleted"
end function