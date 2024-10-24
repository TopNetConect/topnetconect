



function init()
    m.lines = []
    m.texts = []
    m.timeSpan = createObject("roTimeSpan")
end function

function logItem(name, levelNum, text)
    m.texts.push(text)
    if m.top.sendAutomatically = true
        if m.texts.count() > m.top.maxLinesBeforeSending or (m.timeSpan.TotalSeconds() > m.top.maxSecondsBeforeSending and m.texts.count() > 0)
            m.timeSpan.mark()
            sendLogsNow()
            m.texts = []
        end if
    else if m.texts.count() >= m.top.maxLinesBeforeSending
        m.texts.shift()
    end if
end function

function sendLogsNow(args = invalid)


    m.requestTask = createObject("roSGNode", "mc_RequestTask")
    m.requestTask.args = {
        method: "POST"
        url: m.top.url
        otherArgs: {
            json: {
                lines: m.texts
            }
        }
    }
    m.requestTask.control = "RUN"
    m.texts = []
end function '//# sourceMappingURL=./HTTPTransport.bs.map