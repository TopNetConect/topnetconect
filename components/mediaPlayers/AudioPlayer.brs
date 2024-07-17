

sub init()
    m.playReported = false
    m.top.observeField("state", "audioStateChanged")
end sub


sub audioStateChanged()
    currentState = LCase(m.top.state)
    reportedPlaybackState = "update"
    m.top.disableScreenSaver = (currentState = "playing")
    if currentState = "playing" and not m.playReported
        reportedPlaybackState = "start"
        m.playReported = true
    else if currentState = "stopped" or currentState = "finished"
        reportedPlaybackState = "stop"
        m.playReported = false
    end if
    ReportPlayback(reportedPlaybackState)
end sub


sub ReportPlayback(state as string)
    if not isValid(m.top.position) then
        return
    end if
    params = {
        "ItemId": m.global.queueManager.callFunc("getCurrentItem").id
        "PlaySessionId": m.top.content.id
        "PositionTicks": int(m.top.position) * 10000000& 'Ensure a LongInteger is used
        "IsPaused": (LCase(m.top.state) = "paused")
    }

    playstateTask = m.global.playstateTask
    playstateTask.setFields({
        status: state
        params: params
    })
    playstateTask.control = "RUN"
end sub