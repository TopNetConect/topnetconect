



function Init() as void
    m.top.transports = []
    m.top.includeFilters = {}
    m.top.excludeFilters = {}
    m.top.observeFieldScoped("transportTypes", "log_onTransportsChange")
    m.top.observeFieldScoped("includeDate", "log_log_onIncludeDate")
    m.top.transportTypes = [
        "log_PrintTransport"
    ]
    m.date = createObject("roDateTime")
    m.date.toLocalTime()
    m.dateTimer = createObject("roSGNode", "Timer")
    m.dateTimer.repeat = true
    m.dateTimer.duration = 0.01
    m.dateTimer.observeFieldScoped("fire", "log_log_onDateTimerFire")
end function

function log_onTransportsChange(event)
    if m.transports = invalid
        m.transports = []
    end if
    for each transport in m.transports
        parent = transport.getParent()
        if parent <> invalid
            parent.removeChild(transport)
        end if
    end for
    transports = []
    isPrinting = false
    if m.top.transportTypes <> invalid
        transportTypes = m.top.transportTypes
    else
        transportTypes = []
    end if
    for each transportType in m.top.transportTypes
        if transportType = "log_PrintTransport"
            isPrinting = true
        else
            transport = m.top.getScene().createChild(transportType)
            if transport <> invalid
                transports.push(transport)
            else
                print "ERROR - could not create Log transport with type "; transportType
            end if
        end if
    end for
    m.top.transports = transports
    if m.top.transports.count() > 0
        if isPrinting
            m.top.logMode = 3
        else
            m.top.logMode = 2
        end if
    else if isPrinting
        m.top.logMode = 1
    else
        m.top.logMode = 0
    end if
end function

function log_log_onDateTimerFire()
    m.date.mark()
    hours = m.date.getHours().toStr()
    minutes = m.date.getMinutes().toStr()
    seconds = m.date.getSeconds().toStr()
    if len(hours) = 1
        hours = "0" + hours
    end if
    if len(minutes) = 1
        minutes = "0" + minutes
    end if
    if len(seconds) = 1
        seconds = "0" + seconds
    end if
    timeText = hours + ":" + minutes + ":" + seconds
    m.top.dateText = timeText
end function

function log_log_onIncludeDate()
    if m.top.includeDate
        m.dateTimer.control = "start"
    else
        m.dateTimer.control = "stop"
    end if
end function '//# sourceMappingURL=./Log.bs.map