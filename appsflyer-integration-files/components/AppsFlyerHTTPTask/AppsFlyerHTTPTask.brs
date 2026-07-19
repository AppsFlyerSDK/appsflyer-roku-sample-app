sub init()
    AppsFlyerLogger().debug("Initializing AppsFlyerHTTPTask")
    m.top.functionName = "sendHttps"
    m.top.observeField("httpresonseCode", "getConversionData")
end sub


sub sendHttps()
    httpresponse = 0
    reqUrl = m.top.reqUrl
    json = m.top.json
    ' Guard: never attempt to sign/send an empty payload.
    if json = invalid or json = "" then
        AppsFlyerLogger().error("Aborting request: empty payload, nothing to send. reqUrl: " + reqUrl)
        m.top.httpresponse = ""
        m.top.httpresonseCode = "-1"
        return
    end if

    AppsFlyerLogger().debug("Request data: " + json)
    AppsFlyerLogger().debug("Request reqUrl: " + reqUrl)

    hmac = CreateObject("roHMAC")
    signature_key = CreateObject("roByteArray")
    signature_key.fromAsciiString(AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.DEVKEY))
    result = invalid
    if hmac.setup("sha256", signature_key) = 0
        message = CreateObject("roByteArray")
        message.fromAsciiString(json)
        result = hmac.process(message)
        ' AppsFlyerLogger().debug("auth: " + LCase(result.ToHexString()))
    end if

    ' Guard: do not dereference an Invalid HMAC result.
    if result = invalid then
        AppsFlyerLogger().error("Aborting request: failed to generate HMAC signature. reqUrl: " + reqUrl)
        m.top.httpresponse = ""
        m.top.httpresonseCode = "-1"
        return
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

    code = 0
    if responseCode <> invalid then
        code = responseCode.ToInt()
    end if
    isSuccess = (code >= 200 and code < 300)

    cachedResponse = AppsFlyerRegistry().get("conversionData")

    if Instr(0, endpoint, AppsFlyerConstants().SESSIONS_ENDPOINT) <> 0 and isSuccess then
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
    else if Instr(0, endpoint, AppsFlyerConstants().CONVERSION_ENDPOINT) <> 0 then
        if isSuccess then
            AppsFlyerLogger().info("ConversionData Response: " + response)
            AppsFlyerRegistry().set("conversionData", response)
            resolveFirstOpen()
            executeCallbacks(response, false)
        else if code = 400 or code = 401 or code = 403 then
            AppsFlyerLogger().error("first_open definitively rejected (code " + responseCode + "); advancing state so sessions can proceed.")
            resolveFirstOpen()
        end if
    end if
end function

' Advance the persisted first-open state exactly once.
function resolveFirstOpen() as void
    currentCounter = AppsFlyerRegistry().get(AppsFlyerConstants().RegistryConstants.SESSIONCOUNTER)
    if currentCounter = invalid or currentCounter = "0" then
        AppsFlyerRegistry().set(AppsFlyerConstants().RegistryConstants.SESSIONCOUNTER, "1")
    end if
end function

function executeCallbacks(response as string, isCache as boolean) as void
    if isCache then
        AppsFlyerLogger().debug("ConversionData exists in cache, returning cached response: " + response)
    end if
    if response = invalid or response = "" then
        m.top.callbackData = invalid
        return
    end if
    callbackData = parseJSON(response)
    m.top.callbackData = callbackData
    '    ?"mtopCallbackData :"m.top.callbackData
end function