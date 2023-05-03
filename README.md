---
title: Roku (Brighscript)
category: 6446526dddf659006c7ea807
order: 7
hidden: false
slug: roku-brighscript
---

> Link to repository  
> [GitHub](https://github.com/AppsFlyerSDK/appsflyer-roku-sample-app)

# AppsFlyer Roku SDK integration

AppsFlyer empowers gaming marketers to make better decisions by providing powerful tools that solve real pain points, including cross-platform attribution, mobile and web analytics, deep linking, fraud detection, privacy management and preservation, and more.

Game attribution requires the game to communicate with AppsFlyer APIs over HTTPS and report user activities like first opens, consecutive sessions, and in-app events. For example, purchase events.
We recommend you use this sample app as a reference for integrating AppsFlyer into your Roku channel

<hr/>

## AppsFlyerRokuSDK - Interface

`AppsFlyerRokuSDK.brs`, included in the `source/appsflyer-integration-files` folder, contains the required code and logic to connect to AppsFlyer servers and report events.

### `AppsFlyer().start("DEV_KEY", "APP_ID")`

This method receives your API key and app ID and initializes the AppsFlyer Module that sends first open and session requests to AppsFlyer.

**Usage**:

```
AppsFlyer().start("DEV_KEY", "APP_ID")
```

<span id="app-details">**Arguments**:</span>

- `APP_ID`: Found via [ifAppInfo](https://developer.roku.com/docs/references/brightscript/interfaces/ifappinfo.md).
- `DEV_KEY`: Get from the marketer or [AppsFlyer HQ](https://support.appsflyer.com/hc/en-us/articles/211719806-App-settings-#general-app-settings).

### `AppsFlyer().logEvent(eventName, trackEventValues)`

This method receives an event name and JSON object and sends in-app events to AppsFlyer.

**Usage**:

```
trackEventValues = CreateObject("roAssociativeArray")
trackEventValues = {"af_revenue": 24.22, "af_currency":"ILS", "freeHandParam": "freeHandValue"}

AppsFlyer().logEvent("af_purchase", trackEventValues)
```

## Running the sample app

1. Open the `appsflyer-sample-app` folder in VSCode.
2. In `source/main.brs`, replace the following parameters with [your own](#app-details):

```
devkey = "DEV_KEY"
appid = "APP_ID"
```

3. Deploy the channel. ([Using this plugin](https://marketplace.visualstudio.com/items?itemName=mjmcaulay.roku-deploy-vscode) makes it easier)
4. After the app loads:

   1. Click **OK** to see the [start](#appsflyerstartdev_key-app_id) event details.
   2. Click the options button (\*) and then **OK** to see the [logEvent](#appsflyerlogeventeventname-trackeventvalues).

## Implementing AppsFlyer in your Roku channel

### Setup

1. Copy the files from the `appsflyer-integration-files` folder into your project.
2. Add the following code to your `main.brs` file and [Initialize](#appsflyerstartdev_key-app_id) the AppsFlyer integration:

```
Function Main(args as Dynamic) as Void
    ...
    showAppsflyerChannelSGScreen(args)
    ...
End Function

sub showAppsflyerChannelSGScreen(args as Dynamic)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("AppsFlyerScene")
    screen.show()

    ' Initialize the AppsFlyer integration (send first-open/session event)
    AppsFlyer().start(DEV_KEY, APP_ID)
    ' Enable debugging if necessary
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
```

3. Report [in-app events](#appsflyerlogeventeventname-trackeventvalues).
