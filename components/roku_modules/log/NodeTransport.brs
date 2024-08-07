



function Init() as void
    m.top.observeField("__updateNow", "log_updateLogOutput")
    m.top.observeField("__clear", "log_clearLog")
    m.items = []
end function

function log_clearLog() as void
    m.items = []
    m.top._rawItems = []
    m.top._logText = ""
    m.top._logOutput = []
    m.top._jsonOutput = ""
end function

function log_updateLogOutput() as void
    index = m.items.count() - 1
    loggedTexts = []
    logText = ""
    jsonTexts = []
    if m.top.ascending = true
        startIndex = 0
        endIndex = m.items.count() - 1
        direction = 1
    else
        startIndex = m.items.count() - 1
        endIndex = 0
        direction = - 1
    end if
    for index = startIndex to endIndex step direction
        item = m.items[index]
        loggedTexts.push(item.text)
        jsonTexts.push(item.text)
        logText += chr(10) + "\n" + item.text
    end for
    m.top._rawItems = m.items
    m.top._logText = logText
    m.top._logOutput = loggedTexts
    m.top._jsonOutput = formatJson(jsonTexts)
end function

function logItem(name, levelNum, text)
    if m.items.count() > m.top.maxItems
        m.items.delete(0)
    end if
    item = {
        "level": levelNum
        "text": text
        "name": name
    }
    m.items.push(item)
end function '//# sourceMappingURL=./NodeTransport.bs.map