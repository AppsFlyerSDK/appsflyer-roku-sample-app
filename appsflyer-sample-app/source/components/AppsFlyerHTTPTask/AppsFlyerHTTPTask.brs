sub init()
    AppsFlyerLogger().debug("Initializing AppsFlyerHTTPTask")
    m.top.functionName = "sendHttps"
    m.top.observeField("httpresonseCode", "getConversionData")
end sub


sub sendHttps()
    httpresponse = 0
    reqUrl = m.top.reqUrl
    json = m.top.json
    if (json <> "") then
        AppsFlyerLogger().debug("Request data: " + json)
        AppsFlyerLogger().debug("Request reqUrl: " + reqUrl)
    end if

    hmac = CreateObject("roHMAC")
    signature_key = CreateObject("roByteArray")
    signature_key.fromAsciiString(AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.DEVKEY))
    if hmac.setup("sha256", signature_key) = 0
        message = CreateObject("roByteArray")
        message.fromAsciiString(json)
        result = hmac.process(message)
        ' AppsFlyerLogger().debug("auth: " + LCase(result.ToHexString()))
    end if

    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetMessagePort(port)
    request.EnableEncodings(true)
    request.AddHeader("Accept", "application/json")
    request.AddHeader("Content-Type", "application/json")
    request.AddHeader("Authorization", LCase(result.ToHexString()))
    request.setCertificatesFile("common:/certs/ca-bundle.crt")
    request.initClientCertificates()
    request.SetUrl(reqUrl)

    if (request.AsyncPostFromString(json))
        while (true)
            msg = wait(5000, port)
            if (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                if code <> invalid then
                    httpresponse = msg.GetString()
                    httpresonseCode = code.toStr()
                    AppsFlyerLogger().info("Response: " + code.ToStr())
                    AppsFlyerLogger().info("Response body: " + httpresponse.ToStr())
                    exit while
                else
                    AppsFlyerLogger().error("Could not send data to server")
                    request.AsyncCancel()
                end if
            end if
        end while
    end if

    m.top.httpresponse = httpresponse
    m.top.httpresonseCode = httpresonseCode
end sub

function getConversionData() as void
    responseCode = m.top.httpresonseCode
    response = m.top.httpresponse
    endpoint = m.top.reqUrl

    cachedResponse = AppsFlyerRegistry().get("conversionData")

    ' if Instr(0, endpoint, AppsFlyerConstants().SESSIONS_ENDPOINT) <> 0 and responseCode = "200" then
    if Instr(0, endpoint, AppsFlyerConstants().SESSIONS_ENDPOINT) <> 0 and responseCode = "200" then
        if cachedResponse = invalid then
            m.HttpsTaskContent = createObject("RoSGNode", "AppsFlyerHTTPTask")
            m.HttpsTaskContent.observeField("httpresonseCode", "getConversionData") ' only passes the port this way (when commented out only on 2nd luanch), why?
            m.HttpsTaskContent.reqUrl = m.top.conReqUrl
            m.HttpsTaskContent.json = ""
            m.HttpsTaskContent.control = "RUN"
        else
            '            ?"fromCache"
            executeCallbacks(cachedResponse, true)
        end if
    else if Instr(0, endpoint, AppsFlyerConstants().CONVERSION_ENDPOINT) <> 0 and responseCode = "200" then
        AppsFlyerLogger().info("ConversionData Response: " + response)
        AppsFlyerRegistry().set("conversionData", response)
        '        ?"NOTfromCache: "response
        executeCallbacks(response, false)
    end if
end function

function executeCallbacks(response as string, isCache as boolean) as void
    if isCache then
        AppsFlyerLogger().debug("ConversionData exists in cache, returning cached response: " + response)
    end if
    callbackData = parseJSON(response)
    m.top.callbackData = callbackData
    '    ?"mtopCallbackData :"m.top.callbackData
end function