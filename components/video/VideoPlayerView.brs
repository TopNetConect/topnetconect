


sub init()

    m.top.getScene().findNode("overhang").visible = false
    m.currentItem = m.global.queueManager.callFunc("getCurrentItem")
    m.top.id = m.currentItem.id
    m.top.seekMode = "accurate"
    m.playbackEnum = {
        null: -10
    }

    m.LoadMetaDataTask = CreateObject("roSGNode", "LoadVideoContentTask")
    m.LoadMetaDataTask.itemId = m.currentItem.id
    m.LoadMetaDataTask.itemType = m.currentItem.type
    m.LoadMetaDataTask.selectedAudioStreamIndex = m.currentItem.selectedAudioStreamIndex
    m.LoadMetaDataTask.observeField("content", "onVideoContentLoaded")
    m.LoadMetaDataTask.control = "RUN"
    m.chapterList = m.top.findNode("chapterList")
    m.chapterMenu = m.top.findNode("chapterMenu")
    m.chapterContent = m.top.findNode("chapterContent")
    m.osd = m.top.findNode("osd")
    m.osd.observeField("action", "onOSDAction")
    m.playbackTimer = m.top.findNode("playbackTimer")
    m.bufferCheckTimer = m.top.findNode("bufferCheckTimer")
    m.top.observeField("state", "onState")
    m.top.observeField("content", "onContentChange")
    m.top.observeField("selectedSubtitle", "onSubtitleChange")

    m.top.observeField("allowCaptions", "onAllowCaptionsChange")
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
    m.top.retrievingBar.filledBarBlendColor = m.global.constants.colors.blue
    m.top.bufferingBar.filledBarBlendColor = m.global.constants.colors.blue
    m.top.trickPlayBar.filledBarBlendColor = m.global.constants.colors.blue
end sub



sub handleChapterSkipAction(action as string)
    if not isValidAndNotEmpty(m.chapters) then
        return
    end if
    currentChapter = getCurrentChapterIndex()
    if action = "chapternext"
        gotoChapter = currentChapter + 1

        if gotoChapter > m.chapters.count() - 1 then
            return
        end if
        m.top.seek = m.chapters[gotoChapter].StartPositionTicks / 10000000#
        return
    end if
    if action = "chapterback"
        gotoChapter = currentChapter - 1

        if gotoChapter < 0 then
            gotoChapter = 0
        end if
        m.top.seek = m.chapters[gotoChapter].StartPositionTicks / 10000000#
        return
    end if
end sub





sub handleHideAction(resume as boolean)
    m.osd.visible = false
    m.chapterList.visible = false
    m.osd.showChapterList = false
    m.chapterList.setFocus(false)
    m.osd.hasFocus = false
    m.osd.setFocus(false)
    m.top.setFocus(true)
    if resume
        m.top.control = "resume"
    end if
end sub



sub handleChapterListAction()
    m.chapterList.visible = m.osd.showChapterList
    if not m.chapterList.visible then
        return
    end if
    m.chapterMenu.jumpToItem = getCurrentChapterIndex()
    m.osd.hasFocus = false
    m.osd.setFocus(false)
    m.chapterMenu.setFocus(true)
end sub





function getCurrentChapterIndex() as integer
    if not isValidAndNotEmpty(m.chapters) then
        return 0
    end if


    currentPosition = m.top.position + 15
    currentChapter = 0
    for i = m.chapters.count() - 1 to 0 step -1
        if currentPosition >= (m.chapters[i].StartPositionTicks / 10000000#)
            currentChapter = i
            exit for
        end if
    end for
    return currentChapter
end function



sub handleVideoPlayPauseAction()

    if m.top.state = "paused"
        handleHideAction(true)
        return
    end if

    m.top.control = "pause"
end sub



sub handleShowSubtitleMenuAction()
    m.top.selectSubtitlePressed = true
end sub



sub handleShowVideoInfoPopupAction()
    m.top.selectPlaybackInfoPressed = true
end sub



sub onOSDAction()
    action = LCase(m.osd.action)
    if action = "hide"
        handleHideAction(false)
        return
    end if
    if action = "play"
        handleHideAction(true)
        return
    end if
    if action = "chapterback" or action = "chapternext"
        handleChapterSkipAction(action)
        return
    end if
    if action = "chapterlist"
        handleChapterListAction()
        return
    end if
    if action = "videoplaypause"
        handleVideoPlayPauseAction()
        return
    end if
    if action = "showsubtitlemenu"
        handleShowSubtitleMenuAction()
        return
    end if
    if action = "showvideoinfopopup"
        handleShowVideoInfoPopupAction()
        return
    end if
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
    m.top.observeField("subtitleTrack", "loadCaption")
    m.top.observeField("globalCaptionMode", "toggleCaption")
    if m.global.session.user.settings["playback.subs.custom"]
        m.top.suppressCaptions = true
        toggleCaption()
    else
        m.top.suppressCaptions = false
    end if
end sub


sub loadCaption()
    if m.top.suppressCaptions
        m.captionTask.url = m.top.subtitleTrack
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


sub onSubtitleChange()

    m.global.queueManager.callFunc("setTopStartingPoint", int(m.top.position) * 10000000&)
    m.top.control = "stop"
    m.LoadMetaDataTask.selectedSubtitleIndex = m.top.SelectedSubtitle
    m.LoadMetaDataTask.itemId = m.currentItem.id
    m.LoadMetaDataTask.observeField("content", "onVideoContentLoaded")
    m.LoadMetaDataTask.control = "RUN"
end sub

sub onPlaybackErrorDialogClosed(msg)
    sourceNode = msg.getRoSGNode()
    sourceNode.unobserveField("buttonSelected")
    sourceNode.unobserveField("wasClosed")
    m.global.sceneManager.callFunc("popScene")
end sub

sub onPlaybackErrorButtonSelected(msg)
    sourceNode = msg.getRoSGNode()
    sourceNode.close = true
end sub

sub showPlaybackErrorDialog(errorMessage as string)
    dialog = createObject("roSGNode", "Dialog")
    dialog.title = tr("Error During Playback")
    dialog.buttons = [
        tr("OK")
    ]
    dialog.message = errorMessage
    dialog.observeField("buttonSelected", "onPlaybackErrorButtonSelected")
    dialog.observeField("wasClosed", "onPlaybackErrorDialogClosed")
    m.top.getScene().dialog = dialog
end sub

sub onVideoContentLoaded()
    m.LoadMetaDataTask.unobserveField("content")
    m.LoadMetaDataTask.control = "STOP"
    videoContent = m.LoadMetaDataTask.content
    m.LoadMetaDataTask.content = []
    stopLoadingSpinner()

    if not isValid(videoContent)
        showPlaybackErrorDialog(tr("There was an error retrieving the data for this item from the server."))
        return
    end if
    if not isValid(videoContent[0])
        showPlaybackErrorDialog(tr("There was an error retrieving the data for this item from the server."))
        return
    end if
    m.top.content = videoContent[0].content
    m.top.PlaySessionId = videoContent[0].PlaySessionId
    m.top.videoId = videoContent[0].id
    m.top.container = videoContent[0].container
    m.top.mediaSourceId = videoContent[0].mediaSourceId
    m.top.fullSubtitleData = videoContent[0].fullSubtitleData
    m.top.audioIndex = videoContent[0].audioIndex
    m.top.transcodeParams = videoContent[0].transcodeparams
    m.chapters = videoContent[0].chapters
    m.osd.itemTitleText = m.top.content.title
    populateChapterMenu()
    if m.LoadMetaDataTask.isIntro

        m.top.enableTrickPlay = false
    else

        m.top.allowCaptions = true
    end if
    if isValid(m.top.audioIndex)
        m.top.audioTrack = (m.top.audioIndex + 1).toStr()
    else
        m.top.audioTrack = "2"
    end if
    m.top.setFocus(true)
    m.top.control = "play"
end sub



sub populateChapterMenu()

    m.chapterContent.clear()
    if not isValidAndNotEmpty(m.chapters)
        chapterItem = CreateObject("roSGNode", "ContentNode")
        chapterItem.title = tr("No Chapter Data Found")
        chapterItem.playstart = m.playbackEnum.null
        m.chapterContent.appendChild(chapterItem)
        return
    end if
    for each chapter in m.chapters
        chapterItem = CreateObject("roSGNode", "ContentNode")
        chapterItem.title = chapter.Name
        chapterItem.playstart = chapter.StartPositionTicks / 10000000#
        m.chapterContent.appendChild(chapterItem)
    end for
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
    if m.osd.visible then
        return
    end if
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

    if m.top.trickPlayBar.visible then
        return
    end if
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

    m.osd.progressPercentage = m.top.position / m.top.duration
    m.osd.positionTime = m.top.position
    m.osd.remainingPositionTime = m.top.duration - m.top.position
    if isValid(m.captionTask)
        m.captionTask.currentPos = Int(m.top.position * 1000)
    end if

    m.dialog = m.top.getScene().findNode("dialogBackground")
    if not isValid(m.dialog)

        if not m.LoadMetaDataTask.isIntro
            checkTimeToDisplayNextEpisode()
        end if
    end if
end sub



sub onState(msg)
    if isValid(m.captionTask)
        m.captionTask.playerState = m.top.state + m.top.globalCaptionMode
    end if

    m.osd.playbackState = m.top.state

    if m.top.state = "buffering" and m.bufferCheckTimer <> invalid

        m.bufferCheckTimer.control = "start"
        m.bufferCheckTimer.ObserveField("fire", "bufferCheck")
    else if m.top.state = "error"
        if not m.playReported and m.top.transcodeAvailable
            m.top.retryWithTranscoding = true ' If playback was not reported, retry with transcoding
        else

            showPlaybackErrorDialog(tr("Error During Playback"))
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

            showPlaybackErrorDialog(tr("There was an error retrieving the data for this item from the server."))

            m.top.control = "stop"
            m.top.backPressed = true
        end if
    end if
end sub




function stateAllowsOSD() as boolean
    validStates = [
        "playing"
        "paused"
        "stopped"
    ]
    return inArray(validStates, m.top.state)
end function

function onKeyEvent(key as string, press as boolean) as boolean

    if m.chapterMenu.hasFocus()
        if not press then
            return false
        end if
        if key = "OK"
            focusedChapter = m.chapterMenu.itemFocused
            selectedChapter = m.chapterMenu.content.getChild(focusedChapter)
            seekTime = selectedChapter.playstart

            if seekTime = m.playbackEnum.null then
                return true
            end if
            m.top.seek = seekTime
            return true
        end if
        if key = "back" or key = "replay"
            m.chapterList.visible = false
            m.osd.showChapterList = false
            m.chapterMenu.setFocus(false)
            m.osd.hasFocus = true
            m.osd.setFocus(true)
            return true
        end if
        if key = "play"
            handleVideoPlayPauseAction()
        end if
        return true
    end if
    if key = "OK" and m.nextEpisodeButton.hasfocus() and not m.top.trickPlayBar.visible
        m.top.control = "stop"
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
    if key = "down" and not m.top.trickPlayBar.visible
        if not m.LoadMetaDataTask.isIntro

            if not stateAllowsOSD() then
                return true
            end if
            m.osd.visible = true
            m.osd.hasFocus = true
            m.osd.setFocus(true)
            return true
        end if
    else if key = "up" and not m.top.trickPlayBar.visible
        if not m.LoadMetaDataTask.isIntro

            if not stateAllowsOSD() then
                return true
            end if
            m.osd.visible = true
            m.osd.hasFocus = true
            m.osd.setFocus(true)
            return true
        end if
    else if key = "OK" and not m.top.trickPlayBar.visible
        if not m.LoadMetaDataTask.isIntro

            if not stateAllowsOSD() then
                return true
            end if

            m.osd.visible = true
            m.osd.hasFocus = true
            m.osd.setFocus(true)
            return true
        end if
        return false
    end if

    if not m.LoadMetaDataTask.isIntro
        if key = "play" and not m.top.trickPlayBar.visible

            if not stateAllowsOSD() then
                return true
            end if

            if m.top.state = "paused"
                m.top.control = "resume"
                return true
            end if

            m.top.control = "pause"
            m.osd.visible = true
            m.osd.hasFocus = true
            m.osd.setFocus(true)
            return true
        end if
    end if
    if key = "back"
        m.top.control = "stop"
    end if
    return false
end function