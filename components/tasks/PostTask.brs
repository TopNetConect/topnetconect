


sub init()
    m.top.functionName = "postItems"
end sub





sub postItems()
    if m.top.apiUrl = ""
        print "ERROR in PostTask. Invalid API URL provided"
        return
    end if
    if m.top.arrayData.count() > 0 and m.top.stringData = ""
        print "PostTask Started - Posting array to " + m.top.apiUrl
        req = APIRequest(m.top.apiUrl)
        req.SetRequest("POST")
        httpResponse = asyncPost(req, FormatJson(m.top.arrayData))
        m.top.responseCode = httpResponse
        print "PostTask Finished. " + m.top.apiUrl + " Response = " + httpResponse.toStr()
    else if m.top.arrayData.count() = 0 and m.top.stringData <> ""
        print "PostTask Started - Posting string(" + m.top.stringData + ") to " + m.top.apiUrl
        req = APIRequest(m.top.apiUrl)
        req.SetRequest("POST")
        httpResponse = asyncPost(req, m.top.stringData)
        m.top.responseCode = httpResponse
        print "PostTask Finished. " + m.top.apiUrl + " Response = " + httpResponse.toStr()
    else
        print "ERROR processing data for PostTask"
    end if
end sub


function asyncPost(req, data = "" as string) as integer

    respCode = 0
    req.setMessagePort(CreateObject("roMessagePort"))
    req.AddHeader("Content-Type", "application/json")
    req.AsyncPostFromString(data)


    resp = wait(m.top.timeoutSeconds * 1000, req.GetMessagePort())
    respString = resp.GetString()
    if isValidAndNotEmpty(respString)
        m.top.responseBody = ParseJson(respString)
        print "m.top.responseBody=", m.top.responseBody
    end if
    respCode = resp.GetResponseCode()
    if respCode < 0

        m.top.failureReason = resp.GetFailureReason()
    else if respCode >= 200 and respCode < 300

        m.top.responseHeaders = resp.GetResponseHeaders()
    end if
    return respCode
end function


sub empty()

    m.top.apiUrl = ""
    m.top.timeoutSeconds = 30
    m.top.arrayData = {}
    m.top.stringData = ""
    m.top.responseCode = invalid
    m.top.responseBody = {}
    m.top.responseHeaders = {}
    m.top.failureReason = ""
end sub