# AppsFlyer Roku Integration

## **Getting started with AppsFlyer Roku Integration**

AppsFlyer empowers marketers and helps them make better decisions.

This is done by providing marketers with powerful tools that solve real pain points. These include cross-platform attribution, mobile and web analytics, deep linking, fraud detection, privacy management and preservation, and much more.

With this sample app, we will be able to demonstrate basic integration which includes the first open/sessions and in-app events (i.e purchase events).

AppsFlyer requires the game to report activities within it like app open. In order to do that, the app communicate with the AppsFlyer APIs over HTTPS - the sample app includes the code that does that.
you may use this sample app as a reference for integrating AppsFlyer into your Roku channel.

<hr/>


## **AppsFlyerRokuSDK - Interface**

"AppsFlyerRokuSDK.brs", which is include in the "source/appsflyer-integration-files" folder, contains the required code and logic to connect to our servers and report events.

<br/>

#### AppsFlyer().start("DEV_KEY", "APP_ID")

This method receives your api key and app id, and initializes the AppsFlyer Module (and sends “first open/session” request to AppsFlyer).

##### <span style="text-decoration:underline;">Usage:</span>

```
AppsFlyer().start("DEV_KEY", "APP_ID")
```

##### App-Details

* DEV_KEY - retrieve the Dev key from the marketer or the [AppsFlyer HQ](https://support.appsflyer.com/hc/en-us/articles/211719806-App-settings-#general-app-settings).
* APP_ID - you may find your app id via [ifAppInfo](https://developer.roku.com/docs/references/brightscript/interfaces/ifappinfo.md).

<br/>

#### AppsFlyer().logEvent(eventName, trackEventValues)

This method receives an event name and json object and sends an in-app event to AppsFlyer.


##### <span style="text-decoration:underline;">Usage:</span>

```
trackEventValues = CreateObject("roAssociativeArray")
trackEventValues = {"af_revenue": 24.22, "af_currency":"ILS", "freeHandParam": "freeHandValue"}

AppsFlyer().logEvent("af_purchase", trackEventValues)
```

<hr>

## Running the Sample App 

1. Open "appsflyer-sample-app" folder in VSCode
3. In "source/main.brs" replace the following parameters with [your own](#app-details):
```
devkey = "DEV_KEY"
appid = "APP_ID"
```
3. Deploy the channel ([this plugin](https://marketplace.visualstudio.com/items?itemName=mjmcaulay.roku-deploy-vscode) makes it easier)
4. After the app loads:
 - press OK in order to see the details of the [start](#appsflyerstartdev_key-app_id) event
 - press the options button (*) and then OK again in order to see the [logEvent](#appsflyerlogeventeventname-trackeventvalues) event
<hr/>

## **Implementing AppsFlyer into your own Roku channel**

### Set Up
1. Copy the files from the "appsflyer-integration-files" folder into your project
2. Add the following code to your main.brs file and [Initialize](#appsflyerstartdev_key-app_id) the AppsFlyer integration:
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
3. Report [in-app events](#appsflyerlogeventeventname-trackeventvalues)