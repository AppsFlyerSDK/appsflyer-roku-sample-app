function AppsFlyer() as object
    if (GetGlobalAA().AppsFlyer = invalid) then
        afInstance = {
            start: function(appsFlyerDevKey as string, appsFlyerAppId as string) : AppsFlyerCore().af_init_sdk(appsFlyerDevKey, appsFlyerAppId) : end function
            trackAppLaunch: function() : AppsFlyerCore().af_trackAppLaunch(invalid) : end function
            trackDeepLink: function(deeplinkArgs as dynamic) : AppsFlyerCore().af_trackAppLaunch(deeplinkArgs) : end function
            logEvent: function(eventName as string, eventValues as object) : AppsFlyerCore().af_trackEvent(eventName, eventValues) : end function
            enableDebugLogs: function(isDebug as boolean) : AppsFlyerLogger().setLevel("debug") : end function
            setLogLevel: function(logLevel as string) : AppsFlyerLogger().setLevel(logLevel) : end function
        }
        GetGlobalAA()["AppsFlyer"] = afInstance
    end if
    return GetGlobalAA().AppsFlyer
end function

function AppsFlyerConstants() as object
    SDK_VERSION = "1.12.0" ' 1.12 = MIN VERSION REQUIRED FOR DEEPLINKING ON ANDROID ENDPOINT - CHECK WITH RTA (if this can be changed)

    SESSIONS_ENDPOINT = "https://events.appsflyer.com/v1.0/c2s/session/app/roku/"
    EVENTS_ENDPOINT = "https://events.appsflyer.com/v1.0/c2s/inapp/app/roku/"
    CONVERSION_ENDPOINT = "https://events.appsflyer.com/v1.0/c2s/first_open/app/roku/"

    APP_ID_PREFIX = "roku."

    RegistryConstants = {
        REGPREFIX: "AppsFlyerRegistry."
        UID: "AppsFlyerUserId"
        SESSIONCOUNTER: "AppsFlyerCounter"
        IAECOUNTER: "AppsFlyerIAECounter"
        DEVKEY: "AppsFlyerDevKey"
        AFAPPID: "AppsFlyerAppID"
        LOGLEVEL: "AppsFlyerLogLevel"
        FIRSTLAUNCHDATE: "AppsFlyerFirstLaunchDate"
        TIMESINCELAUNCH: "AppsFlyerTimePassedSincePrevLaunch"
    }

    LoggerConstants = {
        ERROR: "error"
        INFO: "info"
        DEBUG: "debug"
    }

    CallbackTypes = {
        CONVERSION: "onConversionDataReceived"
        ONAPPOPENATTR: "onAppOpenAttribution"
    }

    return {
        APP_ID_PREFIX: APP_ID_PREFIX,
        SDK_VERSION: SDK_VERSION,
        SESSIONS_ENDPOINT: SESSIONS_ENDPOINT,
        EVENTS_ENDPOINT: EVENTS_ENDPOINT,
        CONVERSION_ENDPOINT: CONVERSION_ENDPOINT,
        RegistryConstants: RegistryConstants,
        LoggerConstants: LoggerConstants,
        CallbackTypes: CallbackTypes
    }
end function

function AppsFlyerCore() as object
    if (GetGlobalAA().AppsFlyer = invalid) then
        ?"AppsFlyer: Cannot use AppsFlyerCore outside of AppsFlyer() API"
        return {}
    end if

    if (GetGlobalAA().AppsFlyer.AppsFlyerCore = invalid) then
        coreInstance = {
            deviceInfo: CreateObject("roDeviceInfo")
            appInfo: CreateObject("roAppInfo")
            appsFlyerGlobals: {}

            af_init_sdk: function(appsFlyerDevKey as string, appsFlyerAppId as string) as void
                AppsFlyerRegistry().init(appsFlyerDevKey, appsFlyerAppId)
                m.af_init_globals()
                AppsFlyerLogger().info("AppsFlyer SDK Initialized")
                '                                    testCachefs() ' Test code - remove before deploy
            end function

            af_trackAppLaunch: function(deeplinkArgs as dynamic) as void
                didInit = true
                if m.appsFlyerGlobals.IsEmpty() then
                    didInit = m.af_init_globals()
                end if

                if didInit then
                    m.appsFlyerGlobals.counter = AppsFlyerUtils().incrementCounter(m.appsFlyerGlobals.counter)
                    AppsFlyerRegistry().set("AppsFlyerCounter", m.appsFlyerGlobals.counter)
                    this = {}
                    this.launchEvent = m.af_commonFields()
                    this.launchEvent.AddReplace("event_name", "Launched")
                    this.launchEvent.AddReplace("event_parameters", "")

                    if deeplinkArgs <> invalid
                        this.launchEvent = m.af_addDLParams(this.launchEvent, deeplinkArgs)
                    end if

                    if m.appsFlyerGlobals.counter = "0" or m.appsFlyerGlobals.counter = "1" or m.appsFlyerGlobals.counter = "2"
                        handleRequest(this.launchEvent, m.appsFlyerGlobals.kAFConversionURL, m.appsFlyerGlobals)
                    else
                        handleRequest(this.launchEvent, m.appsFlyerGlobals.kAppFlyerURL, m.appsFlyerGlobals)
                    end if
                else return
                end if
            end function

            af_trackEvent: function(eventName as string, eventValues as object) as void
                didInit = true
                if m.appsFlyerGlobals.IsEmpty() then
                    didInit = m.af_init_globals()
                end if

                if didInit then
                    m.appsFlyerGlobals.iaecounter = AppsFlyerUtils().incrementCounter(m.appsFlyerGlobals.iaecounter)
                    AppsFlyerRegistry().set("AppsFlyerIAECounter", m.appsFlyerGlobals.iaecounter)

                    this = {}
                    this.trackEvent = m.af_commonFields()
                    this.trackEvent.AddReplace("event_name", eventName)
                    this.trackEvent.AddReplace("event_parameters", eventValues)

                    handleRequest(this.trackEvent, m.appsFlyerGlobals.kAFInAppEventsURL, invalid)
                else return
                end if
            end function

            af_init_globals: function() as boolean
                _appsFlyerGlobals = {}
                devKey = AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.DEVKEY)
                if devKey <> invalid then
                    _appsFlyerGlobals.appsFlyerDevKey = devKey
                else
                    ?"AppsFlyer [ERROR] Cannot initialize the AppsFlyer SDK without setting the DevKey, to initialize AppsFlyer use the AppsFlyer.init(DevKey as String, AppId as String) API"
                    return false
                end if

                afappid = AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.AFAPPID)
                if afappid <> invalid then
                    _appsFlyerGlobals.appsFlyerAppId = afappid
                else
                    ?"AppsFlyer [ERROR] Cannot initialize the AppsFlyer SDK without setting the AppID, to initialize AppsFlyer use the AppsFlyer.init(DevKey as String, AppId as String) API"
                    return false
                end if

                _appsFlyerGlobals.SDKVersion = AppsFlyerConstants().SDK_VERSION
                _appsFlyerGlobals.appsFlyerId = AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.UID)
                _appsFlyerGlobals.counter = AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.SESSIONCOUNTER)
                _appsFlyerGlobals.iaecounter = AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.IAECOUNTER)
                _appsFlyerGlobals.firstLaunchDate = AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.FIRSTLAUNCHDATE)
                _appsFlyerGlobals.advertiserId = m.deviceInfo.GetRIDA()
                _appsFlyerGlobals.appId = AppsFlyerConstants().APP_ID_PREFIX + m.appInfo.GetID()
                _appsFlyerGlobals.appVersion = m.appInfo.GetVersion()

                _appsFlyerGlobals.kAppFlyerURL = AppsFlyerConstants().SESSIONS_ENDPOINT + _appsFlyerGlobals.appsFlyerAppId
                _appsFlyerGlobals.kAFInAppEventsURL = AppsFlyerConstants().EVENTS_ENDPOINT + _appsFlyerGlobals.appsFlyerAppId
                _appsFlyerGlobals.kAFConversionURL = AppsFlyerConstants().CONVERSION_ENDPOINT + _appsFlyerGlobals.appsFlyerAppId
                ' _appsFlyerGlobals.kAppFlyerURL       = AppsFlyerConstants().SESSIONS_ENDPOINT + _appsFlyerGlobals.appId
                ' _appsFlyerGlobals.kAFInAppEventsURL  = AppsFlyerConstants().EVENTS_ENDPOINT + _appsFlyerGlobals.appId
                ' _appsFlyerGlobals.kAFConversionURL   = AppsFlyerConstants().CONVERSION_ENDPOINT + _appsFlyerGlobals.appsFlyerId
                ' _appsFlyerGlobals.kAFConversionURL   = AppsFlyerConstants().CONVERSION_ENDPOINT + _appsFlyerGlobals.appId +"?devkey="+ _appsFlyerGlobals.appsFlyerDevKey +"&device_id="+ _appsFlyerGlobals.appsFlyerId

                m.appsFlyerGlobals = _appsFlyerGlobals
                AppsFlyerLogger().info("AppsFlyer Globals Initialized")
                return true
            end function

            af_addDLParams: function(params as object, deeplinkArgs as dynamic) as object
                if deeplinkArgs <> invalid then
                    dpValue = "roku://?af_deeplink=true&is_retargeting=true&pid=rokuTesting&c=Internal"
                    for each key in deeplinkArgs
                        dpValue += "&" + key.toStr() + "=" + deeplinkArgs[key].toStr() ' TODO how do we parse the string? after private testing...
                    end for
                    '                                        encodedValue = AppsFlyerUtils().httpEncode(dpValue) 'TODO check if can be avoided
                    params.AddReplace("af_deeplink", dpValue)
                    return params
                end if
                return params
            end function

            af_commonFields: function() as object

                rida = m.deviceInfo.GetRIDA()
                device_ver = m.deviceInfo.GetVersion()
                regex = CreateObject("roRegex", "[A-Za-z]", "")
                device_ver = regex.ReplaceAll(device_ver, "")

                isAdvertiserIdEnabled = (m.deviceInfo.IsRIDADisabled() <> true).ToStr()
                model = m.deviceInfo.GetModelDetails().VendorName + " " + m.deviceInfo.GetModelDetails().ModelNumber
                requestId = AppsFlyerUtils().generateGUID()

                m.deviceInfo.GetRIDA()

                if m.deviceInfo.IsRIDADisabled() = true then
                    common = {
                        device_ids: [{ "type": "custom", value: m.appsFlyerGlobals.appsFlyerId }],
                        timestamp: AppsFlyerUtils().getAFTimestamp(),
                        request_id: requestId,
                        device_os_version: device_ver,
                        device_model: model,
                        limit_ad_tracking: true,
                        app_version: m.appsFlyerGlobals.appVersion
                    }
                else
                    common = {
                        device_ids: [{ "type": "custom", value: m.appsFlyerGlobals.appsFlyerId }, { "type": "rida", value: m.deviceInfo.GetRIDA() }],
                        timestamp: AppsFlyerUtils().getAFTimestamp(),
                        request_id: requestId,
                        device_os_version: device_ver,
                        device_model: model,
                        limit_ad_tracking: false,
                        app_version: m.appsFlyerGlobals.appVersion
                    }
                end if

                AppsFlyerLogger().debug("buildCommonEventFields")
                common.addReplace("isFirstCall", (common.counter = "1").ToStr())

                ' common.addReplace("firstLaunchDate", m.appsFlyerGlobals.firstLaunchDate)
                ' common.AddReplace("installDate", m.appsFlyerGlobals.firstLaunchDate)
                ' common.AddReplace("timepassedsincelastlaunch", AppsFlyerUtils().getTimeSinceLaunch().ToStr())
                ' common.AddReplace("buildnumber", m.appsFlyerGlobals.SDKVersion)
                ' common.AddReplace("currentCountrycode",m.deviceInfo.GetCountryCode())
                ' common.AddReplace("lang_code", m.deviceInfo.GetCurrentLocale())
                '                                    common.AddReplace("lang", AppsFlyerUtils().getLangFromCode(common.lang_code)) Irrelevant - no Fingerprinting (validate)
                ' common.AddReplace("platformextension", "Roku")
                ' common.AddReplace("wifi", (m.deviceInfo.GetConnectionType() = "WiFiConnection").toStr())
                ' common.AddReplace("model", m.deviceInfo.GetModelDetails().VendorName + ", " + m.deviceInfo.GetModelDetails().ModelNumber)

                return common
            end function
        }

        GetGlobalAA().AppsFlyer["AppsFlyerCore"] = coreInstance
    end if

    return GetGlobalAA().AppsFlyer.AppsFlyerCore
end function

function AppsFlyerRegistry() as object
    afRegistry = {
        appInfo: CreateObject("roAppInfo")
        init: function(appsFlyerDevKey as string, appsFlyerAppId as string)
            if m.get(AppsFlyerConstants().RegistryConstants.DEVKEY) = invalid then
                if appsFlyerDevKey <> invalid then
                    m.set(AppsFlyerConstants().RegistryConstants.DEVKEY, appsFlyerDevKey)
                end if
            end if

            if m.get(AppsFlyerConstants().RegistryConstants.AFAPPID) = invalid then
                if appsFlyerAppId <> invalid then
                    m.set(AppsFlyerConstants().RegistryConstants.AFAPPID, appsFlyerAppId)
                end if
            end if

            if AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.LOGLEVEL) = invalid then
                m.set(AppsFlyerConstants().RegistryConstants.LOGLEVEL, AppsFlyerConstants().LoggerConstants.ERROR)
            end if

            if m.get(AppsFlyerConstants().RegistryConstants.UID) = invalid then
                appsFlyerId = LCASE(AppsFlyerUtils().generateAppsFlyerId())
                m.set(AppsFlyerConstants().RegistryConstants.UID, appsFlyerId)
            end if

            if m.get(AppsFlyerConstants().RegistryConstants.SESSIONCOUNTER) = invalid then
                counter = 0
                m.set(AppsFlyerConstants().RegistryConstants.SESSIONCOUNTER, counter.ToStr())
            end if

            if m.get(AppsFlyerConstants().RegistryConstants.IAECOUNTER) = invalid then
                iaeCounter = 0
                m.set(AppsFlyerConstants().RegistryConstants.IAECOUNTER, iaeCounter.ToStr())
            end if

            if m.get(AppsFlyerConstants().RegistryConstants.FIRSTLAUNCHDATE) = invalid then
                firstLaunchDate = AppsFlyerDateUtils().buildDate()
                m.set(AppsFlyerConstants().RegistryConstants.FIRSTLAUNCHDATE, firstLaunchDate)
            end if

            if m.get(AppsFlyerConstants().RegistryConstants.TIMESINCELAUNCH) = invalid then
                date = CreateObject("roDateTime")
                seconds = date.asSeconds()
                m.set(AppsFlyerConstants().RegistryConstants.TIMESINCELAUNCH, seconds.ToStr())
            end if

            if m.get(AppsFlyerConstants().RegistryConstants.TIMESINCELAUNCH) = invalid then
                date = CreateObject("roDateTime")
                seconds = date.asSeconds()
                m.set(AppsFlyerConstants().RegistryConstants.TIMESINCELAUNCH, seconds.ToStr())
            end if
        end function

        get: function(key as string) as dynamic
            regId = AppsFlyerConstants().RegistryConstants.REGPREFIX + AppsFlyerConstants().APP_ID_PREFIX + m.appInfo.GetID()
            sec = CreateObject("roRegistrySection", regId)
            if sec.Exists(key)
                return sec.Read(key)
            end if
            '                        AppsFlyerLogger().error("AppsFlyer_ "+key+" not found") 'TODO EXLUDE FROM LOGGER
            return invalid
        end function

        set: function(key as string, value as object) as void
            regId = AppsFlyerConstants().RegistryConstants.REGPREFIX + AppsFlyerConstants().APP_ID_PREFIX + m.appInfo.GetID()
            sec = CreateObject("roRegistrySection", regId)
            sec.Write(key, value)
            sec.Flush()
            '                    AppsFlyerLogger().debug("SetToRegistry key=" + key + " written to storage") 'TODO EXLUDE FROM LOGGER
        end function
    }
    return afRegistry
end function

function AppsFlyerUtils() as object
    afUtils = {
        incrementCounter: function(counterRef as object) as string
            counter = counterRef.ToInt()
            counter++
            return counter.toStr()
        end function

        getTimeSinceLaunch: function() as integer
            timeInterval = -1
            date = CreateObject("roDateTime")
            seconds = date.asSeconds()
            if AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.TIMESINCELAUNCH) <> invalid then
                timeInterval = seconds - AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.TIMESINCELAUNCH).ToInt()
            end if

            AppsFlyerRegistry().set(AppsFlyerConstants().RegistryConstants.TIMESINCELAUNCH, seconds.ToStr())
            return timeInterval
        end function

        generateAppsFlyerId: function() as string
            return "" + m.getRandomHexString(8) + "-" + m.getRandomHexString(4) + "-" + m.getRandomHexString(4) + "-" + m.getRandomHexString(4) + "-" + m.getRandomHexString(12) + ""
            ' return "" + m.getAFTimestamp() + "-" + m.getRandomHexString(18) + ""
        end function
        generateGUID: function() as string
            return LCASE("" + m.getRandomHexString(8) + "-" + m.getRandomHexString(4) + "-" + m.getRandomHexString(4) + "-" + m.getRandomHexString(4) + "-" + m.getRandomHexString(12) + "")
        end function
        getRandomHexString: function(length as integer) as string
            hexChars = "0123456789ABCDEF"
            hexString = ""
            for i = 1 to length
                hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
            next
            return hexString
        end function

        getAFTimestamp: function() as string
            date = CreateObject("roDateTime")
            tsSeconds = date.AsSeconds()
            tsMSeconds = date.GetMilliseconds()
            return tsSeconds.toStr() + tsMSeconds.toStr()
        end function

        '        getLangFromCode     : function (code as string) as string
        '                                helperStruct = {
        '                                    "en_US" : "English",
        '                                    "en_GB" : "English",
        '                                    "fr_CA" : "French",
        '                                    "es_ES" : "Spanish",
        '                                    "de_DE" : "German",
        '                                    "it_IT" : "Italian"
        '                                }
        '                                if helperStruct.Lookup(code) <> invalid then
        '                                    return helperStruct.Lookup(code)
        '                                else
        '                                    AppsFlyerLogger().error("Unable to map code to language: "+code)
        '                                    return "English"
        '                            end function
        '                                endif

        httpEncode: function(toEncode as string) as string
            obj = CreateObject("roUrlTransfer")
            return obj.Escape(toEncode)
        end function

        ' todo: remove before releasing!!!
        getV1: function(ts as string, uid as string, dKey as string) as string
            digest = CreateObject("roEVPDigest")
            ba1 = CreateObject("roByteArray")
            digest.setup("sha1")
            stringing = Mid(dKey, 0, 7) + Mid(uid, 0, 7) + Mid(ts, 7, ts.Len())
            ba1.FromAsciiString(stringing)
            digest.Update(ba1)
            return digest.Final()
        end function

        getV2: function(ts as string, uid as string, idate as string, counter as string, iaeCounter as string, dKey as string) as string
            sDigest = CreateObject("roEVPDigest")
            mDigest = CreateObject("roEVPDigest")
            sDigest.setup("sha1")
            mDigest.setup("md5")
            ba1 = CreateObject("roByteArray")
            ba2 = CreateObject("roByteArray")
            stringing = dKey + ts + uid + idate + counter + iaeCounter
            ba1.FromAsciiString(stringing)
            mDigest.Update(ba1)
            preResult = mDigest.Final()
            ba2.FromAsciiString(preResult)
            sDigest.Update(ba2)
            return sDigest.Final()
        end function
        ' end remove before releasing
    }
    return afUtils
end function

function AppsFlyerDateUtils() as object
    afDate = {
        date: CreateObject("roDateTime")

        appendZeroOnDate: function(value as integer) as string
            if (value < 10) then
                return "0" + value.toStr()
            end if
            return value.toStr()
        end function

        appendTZOnDate: function(value as integer) as string
            buffer = ""
            hours = value / 60
            if hours < 0 then
                hours *= (-1)
                buffer += "+"
            else
                buffer += "-"
            end if
            if (hours < 10) then
                buffer += "0"
            end if
            buffer += hours.toStr()
            buffer += "00"
            return buffer
        end function

        buildDate: function() as string
            dateNew = ""
            dateNew += m.appendZeroOnDate(m.date.GetYear())
            dateNew += "-"
            dateNew += m.appendZeroOnDate(m.date.getMonth())
            dateNew += "-"
            dateNew += m.appendZeroOnDate(m.date.getDayOfMonth())
            dateNew += "_"
            dateNew += m.appendZeroOnDate(m.date.getHours())
            dateNew += m.appendZeroOnDate(m.date.getMinutes())
            dateNew += m.appendZeroOnDate(m.date.getSeconds())
            dateNew += m.appendTZOnDate(m.date.GetTimeZoneOffset())
            return dateNew
        end function

        getCurrentTime: function() as string
            logDate = m.appendZeroOnDate(m.date.getHours()) + ":"
            logDate += m.appendZeroOnDate(m.date.getMinutes()) + ":"
            logDate += m.appendZeroOnDate(m.date.getSeconds()) + ":"
            logDate += m.appendZeroOnDate(m.date.GetMilliseconds())
            return logDate
        end function
    }
    return afDate
end function

function AppsFlyerLogger() as object
    afLogger = {
        PREFIX: "AppsFlyer"
        ENUMS: { error: 0, info: 1, debug: 2 }

        debug: function(msg as string) 'highest level - logs debug, info and error
            m.logMsg(msg, AppsFlyerConstants().LoggerConstants.DEBUG)
        end function

        info: function(msg as string) 'mid level - logs info and error
            m.logMsg(msg, AppsFlyerConstants().LoggerConstants.INFO)
        end function

        error: function(msg as string) 'lowest level - logs errors only
            m.logMsg(msg, AppsFlyerConstants().LoggerConstants.ERROR)
        end function

        logMsg: function(msg as string, logLevel as string)
            givenLevel = m.ENUMS.Lookup(logLevel)
            setLevel = m.ENUMS.Lookup(m.getLevel())
            if (givenLevel <= setLevel) then
                ?tab(0)m.PREFIX + " [" + UCase(logLevel) + "] "tab(18) + AppsFlyerDateUtils().getCurrentTime()tab(30)" : "tab(32)msg

                ' Temp file text code - Remove before release

                formatedText = "" + m.PREFIX + " [" + UCase(logLevel) + "] " + AppsFlyerDateUtils().getCurrentTime() + " : " + msg
                isLogExists = MatchFiles("tmp:/", "aflog.txt")
                if isLogExists.Count() = 0
                    afText = ""
                else
                    afText = ReadAsciiFile("tmp:/aflog.txt")
                end if

                if afText <> invalid and afText <> "" then
                    afText = afText + chr(10) + chr(10) + formatedText
                else
                    afText = formatedText
                end if

                WriteAsciiFile("tmp:/aflog.txt", afText)

                'End temp write code
            end if
        end function

        getLevel: function() as string
            if AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.LOGLEVEL) <> invalid then
                return AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.LOGLEVEL)
            else
                return AppsFlyerConstants().LoggerConstants.ERROR
            end if
        end function

        setLevel: function(level as string)
            _level = LCase(level)
            if (AppsFlyerConstants().LoggerConstants.DoesExist(_level)) then
                AppsFlyerRegistry().set(AppsFlyerConstants().RegistryConstants.LOGLEVEL, _level)
            else
                allowedString = "" : for each key in AppsFlyerConstants().LoggerConstants : allowedString += " " + UCase(key) : end for
                m.error("Could not set log level to:" + Chr(34) + _level + Chr(34) + ", Allowed log levels are:" + allowedString)
            end if
        end function
    }
    return afLogger
end function

function handleRequest(json as object, reqUrl as string, commons as object) as void
    m.HttpsTaskContent = createObject("RoSGNode", "AppsFlyerHTTPTask")
    if (m.port <> invalid) then
        '        ?"MPORT: "m.port
        m.HttpsTaskContent.observeField("callbackData", m.port)
    end if

    if commons <> invalid then
        m.HttpsTaskContent.conReqUrl = commons.kAFConversionURL
    end if

    m.HttpsTaskContent.reqUrl = reqUrl
    m.HttpsTaskContent.json = FormatJson(json, 0)
    m.HttpsTaskContent.control = "RUN"
end function

' Test code - remove before deploy
'Function testCachefs() as void
'     cnt = 0
'     counterFile = ReadAsciiFile("cachefs:/cntTest.txt")
'     if counterFile <> invalid and counterFile <> "" then
'       cnt = counterFile.toInt()
'       cnt++
'       cntStr = cnt.ToStr()
'       AppsFlyerLogger().info("COUNTER IN FILE: "+cntStr)
'       WriteAsciiFile("cachefs:/cntTest.txt", cntStr)
'    else
'       cntStr = cnt.ToStr()
'       AppsFlyerLogger().info("COUNTER IN FILE: "+cntStr)
'       WriteAsciiFile("cachefs:/cntTest.txt", cntStr)
'    endif
'End Function
