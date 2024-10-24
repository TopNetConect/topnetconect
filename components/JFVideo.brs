


sub init()
    m.playbackTimer = m.top.findNode("playbackTimer")
    m.bufferCheckTimer = m.top.findNode("bufferCheckTimer")
    m.top.observeField("state", "onState")
    m.top.observeField("content", "onContentChange")
    m.playbackTimer.observeField("fire", "ReportPlayback")
    m.bufferPercentage = 0 ' Track whether content is being loaded
    m.playReported = false
    m.top.transcodeReasons = []
    m.bufferCheckTimer.duration = 30
    if m.global.session.user.settings["ui.design.hideclock"] = true
        clockNode = findNodeBySubtype(m.top, "clock")
        if clockNode[0] <> invalid then
            clockNode[0].parent.removeChild(clockNode[0].node)
        end if
    end if

    m.nextEpisodeButton = m.top.findNode("nextEpisode")
    m.nextEpisodeButton.text = tr("Next Episode")
    m.nextEpisodeButton.setFocus(false)
    m.nextupbuttonseconds = m.global.session.user.settings["playback.nextupbuttonseconds"].ToInt()
    m.showNextEpisodeButtonAnimation = m.top.findNode("showNextEpisodeButton")
    m.hideNextEpisodeButtonAnimation = m.top.findNode("hideNextEpisodeButton")
    m.checkedForNextEpisode = false
    m.getNextEpisodeTask = createObject("roSGNode", "GetNextEpisodeTask")
    m.getNextEpisodeTask.observeField("nextEpisodeData", "onNextEpisodeDataLoaded")
    m.top.observeField("allowCaptions", "onAllowCaptionsChange")
end sub

sub onAllowCaptionsChange()
    if not m.top.allowCaptions then
        return
    end if
    m.captionGroup = m.top.findNode("captionGroup")
    m.captionGroup.createchildren(9, "LayoutGroup")
    m.captionTask = createObject("roSGNode", "captionTask")
    m.captionTask.observeField("currentCaption", "updateCaption")
    m.captionTask.observeField("useThis", "checkCaptionMode")
    m.top.observeField("currentSubtitleTrack", "loadCaption")
    m.top.observeField("globalCaptionMode", "toggleCaption")
    if m.global.session.user.settings["playback.subs.custom"] = false
        m.top.suppressCaptions = false
    else
        m.top.suppressCaptions = true
        toggleCaption()
    end if
end sub

sub loadCaption()
    if m.top.suppressCaptions
        m.captionTask.url = m.top.currentSubtitleTrack
    end if
end sub

sub toggleCaption()
    m.captionTask.playerState = m.top.state + m.top.globalCaptionMode
    if LCase(m.top.globalCaptionMode) = "on"
        m.captionTask.playerState = m.top.state + m.top.globalCaptionMode + "w"
        m.captionGroup.visible = true
    else
        m.captionGroup.visible = false
    end if
end sub

sub updateCaption()
    m.captionGroup.removeChildrenIndex(m.captionGroup.getChildCount(), 0)
    m.captionGroup.appendChildren(m.captionTask.currentCaption)
end sub


sub onContentChange()
    if not isValid(m.top.content) then
        return
    end if
    m.top.observeField("position", "onPositionChanged")
end sub

sub onNextEpisodeDataLoaded()
    m.checkedForNextEpisode = true
    m.top.observeField("position", "onPositionChanged")
end sub



sub showNextEpisodeButton()
    if m.top.content.contenttype <> 4 then
        return
    end if ' only display when content is type "Episode"
    if m.nextupbuttonseconds = 0 then
        return
    end if ' is the button disabled?
    if m.nextEpisodeButton.opacity = 0 and m.global.session.user.configuration.EnableNextEpisodeAutoPlay
        m.nextEpisodeButton.visible = true
        m.showNextEpisodeButtonAnimation.control = "start"
        m.nextEpisodeButton.setFocus(true)
    end if
end sub



sub updateCount()
    nextEpisodeCountdown = Int(m.top.duration - m.top.position)
    if nextEpisodeCountdown < 0
        nextEpisodeCountdown = 0
    end if
    m.nextEpisodeButton.text = tr("Next Episode") + " " + nextEpisodeCountdown.toStr()
end sub



sub hideNextEpisodeButton()
    m.hideNextEpisodeButtonAnimation.control = "start"
    m.nextEpisodeButton.setFocus(false)
    m.top.setFocus(true)
end sub


sub checkTimeToDisplayNextEpisode()
    if m.top.content.contenttype <> 4 then
        return
    end if ' only display when content is type "Episode"
    if m.nextupbuttonseconds = 0 then
        return
    end if ' is the button disabled?
    if isValid(m.top.duration) and isValid(m.top.position)
        nextEpisodeCountdown = Int(m.top.duration - m.top.position)
        if nextEpisodeCountdown < 0 and m.nextEpisodeButton.opacity = 0.9
            hideNextEpisodeButton()
            return
        else if nextEpisodeCountdown > 1 and int(m.top.position) >= (m.top.duration - m.nextupbuttonseconds - 1)
            updateCount()
            if m.nextEpisodeButton.opacity = 0
                showNextEpisodeButton()
            end if
            return
        end if
    end if
    if m.nextEpisodeButton.visible or m.nextEpisodeButton.hasFocus()
        m.nextEpisodeButton.visible = false
        m.nextEpisodeButton.setFocus(false)
    end if
end sub


sub onPositionChanged()
    if isValid(m.captionTask)
        m.captionTask.currentPos = Int(m.top.position * 1000)
    end if

    m.dialog = m.top.getScene().findNode("dialogBackground")
    if not isValid(m.dialog)
        checkTimeToDisplayNextEpisode()
    end if
end sub



sub onState(msg)
    if isValid(m.captionTask)
        m.captionTask.playerState = m.top.state + m.top.globalCaptionMode
    end if

    if m.top.state = "buffering" and m.bufferCheckTimer <> invalid

        m.bufferCheckTimer.control = "start"
        m.bufferCheckTimer.ObserveField("fire", "bufferCheck")
    else if m.top.state = "error"
        if not m.playReported and m.top.transcodeAvailable
            m.top.retryWithTranscoding = true ' If playback was not reported, retry with transcoding
        else

            dialog = createObject("roSGNode", "PlaybackDialog")
            dialog.title = tr("Error During Playback")
            dialog.buttons = [
                tr("OK")
            ]
            dialog.message = tr("An error was encountered while playing this item.")
            m.top.getScene().dialog = dialog
        end if

        m.top.control = "stop"
        m.top.backPressed = true
    else if m.top.state = "playing"

        if isValid(m.top.showID)
            if m.top.showID <> "" and not m.checkedForNextEpisode and m.top.content.contenttype = 4
                m.getNextEpisodeTask.showID = m.top.showID
                m.getNextEpisodeTask.videoID = m.top.id
                m.getNextEpisodeTask.control = "RUN"
            end if
        end if
        if m.playReported = false
            ReportPlayback("start")
            m.playReported = true
        else
            ReportPlayback()
        end if
        m.playbackTimer.control = "start"
    else if m.top.state = "paused"
        m.playbackTimer.control = "stop"
        ReportPlayback()
    else if m.top.state = "stopped"
        m.playbackTimer.control = "stop"
        ReportPlayback("stop")
        m.playReported = false
    end if
end sub



sub ReportPlayback(state = "update" as string)
    if m.top.position = invalid then
        return
    end if
    params = {
        "ItemId": m.top.id
        "PlaySessionId": m.top.PlaySessionId
        "PositionTicks": int(m.top.position) * 10000000& 'Ensure a LongInteger is used
        "IsPaused": (m.top.state = "paused")
    }
    if m.top.content.live
        params.append({
            "MediaSourceId": m.top.transcodeParams.MediaSourceId
            "LiveStreamId": m.top.transcodeParams.LiveStreamId
        })
        m.bufferCheckTimer.duration = 30
    end if

    playstateTask = m.global.playstateTask
    playstateTask.setFields({
        status: state
        params: params
    })
    playstateTask.control = "RUN"
end sub



sub bufferCheck(msg)
    if m.top.state <> "buffering"

        m.bufferCheckTimer.control = "stop"
        m.bufferCheckTimer.unobserveField("fire")
        return
    end if
    if m.top.bufferingStatus <> invalid

        if m.top.bufferingStatus["percentage"] > m.bufferPercentage
            m.bufferPercentage = m.top.bufferingStatus["percentage"]
        else if m.top.content.live = true
            m.top.callFunc("refresh")
        else

            dialog = createObject("roSGNode", "PlaybackDialog")
            dialog.title = tr("Error Retrieving Content")
            dialog.buttons = [
                tr("OK")
            ]
            dialog.message = tr("There was an error retrieving the data for this item from the server.")
            m.top.getScene().dialog = dialog

            m.top.control = "stop"
            m.top.backPressed = true
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if key = "OK" and m.nextEpisodeButton.hasfocus() and not m.top.trickPlayBar.visible
        m.top.state = "finished"
        hideNextEpisodeButton()
        return true
    else

        if m.nextEpisodeButton.opacity > 0 or m.nextEpisodeButton.hasFocus()
            m.nextEpisodeButton.opacity = 0
            m.nextEpisodeButton.setFocus(false)
            m.top.setFocus(true)
        end if
    end if
    if not press then
        return false
    end if
    if key = "down"
        m.top.selectSubtitlePressed = true
        return true
    else if key = "up"
        m.top.selectPlaybackInfoPressed = true
        return true
    else if key = "OK"
        if m.nextEpisodeButton.hasfocus() and not m.top.trickPlayBar.visible
            m.top.state = "finished"
            hideNextEpisodeButton()
            return true
        else if m.top.state = "paused"


            m.top.control = "resume"
            return false
        else if m.top.state = "playing"
            m.top.control = "pause"
            return false
        end if
    end if
    return false
end function