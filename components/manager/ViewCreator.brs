
sub CreateAudioPlayerView()
    m.view = CreateObject("roSGNode", "AudioPlayerView")
    m.view.observeField("state", "onStateChange")
    m.global.sceneManager.callFunc("pushScene", m.view)
end sub


sub CreateVideoPlayerView()
    m.playbackData = {}
    m.selectedSubtitle = {}
    m.view = CreateObject("roSGNode", "VideoPlayerView")
    m.view.observeField("state", "onStateChange")
    m.view.observeField("selectPlaybackInfoPressed", "onSelectPlaybackInfoPressed")
    m.view.observeField("selectSubtitlePressed", "onSelectSubtitlePressed")
    mediaSourceId = m.global.queueManager.callFunc("getCurrentItem").mediaSourceId
    if not isValid(mediaSourceId) or mediaSourceId = ""
        mediaSourceId = m.global.queueManager.callFunc("getCurrentItem").id
    end if
    m.getPlaybackInfoTask = createObject("roSGNode", "GetPlaybackInfoTask")
    m.getPlaybackInfoTask.videoID = mediaSourceId
    m.getPlaybackInfoTask.observeField("data", "onPlaybackInfoLoaded")
    m.global.sceneManager.callFunc("pushScene", m.view)
end sub





sub onSelectSubtitlePressed()

    subtitleData = {
        data: [
            {
                "Index": -1
                "IsExternal": false
                "Track": {
                    "description": "None"
                }
                "Type": "subtitleselection"
            }
        ]
    }
    for each item in m.view.fullSubtitleData
        item.type = "subtitleselection"
        if m.view.selectedSubtitle <> -1

            if item.index = m.view.selectedSubtitle
                item.selected = true
            end if
        else

            availableSubtitleTrackIndex = availSubtitleTrackIdx(item.track.TrackName)
            if availableSubtitleTrackIndex <> -1

                subtitleFullTrackName = m.view.availableSubtitleTracks[availableSubtitleTrackIndex].TrackName
                if subtitleFullTrackName = m.view.subtitleTrack
                    item.selected = true
                end if
            end if
        end if
        subtitleData.data.push(item)
    end for
    m.global.sceneManager.callFunc("radioDialog", tr("Select Subtitles"), subtitleData)
    m.global.sceneManager.observeField("returnData", "onSelectionMade")
end sub


sub onSelectionMade()
    m.global.sceneManager.unobserveField("returnData")
    if not isValid(m.global.sceneManager.returnData) then
        return
    end if
    if not isValid(m.global.sceneManager.returnData.type) then
        return
    end if
    if LCase(m.global.sceneManager.returnData.type) = "subtitleselection"
        processSubtitleSelection()
    end if
end sub

sub processSubtitleSelection()
    m.selectedSubtitle = m.global.sceneManager.returnData

    if m.view.selectedSubtitle <> -1 or m.selectedSubtitle.index <> -1
        if m.view.selectedSubtitle = m.selectedSubtitle.index then
            return
        end if
    end if

    m.playbackData = invalid
    if LCase(m.selectedSubtitle.track.description) = "none"
        m.view.globalCaptionMode = "Off"
        m.view.subtitleTrack = ""
        if m.view.selectedSubtitle <> -1
            m.view.selectedSubtitle = -1
        end if
        return
    end if
    if m.selectedSubtitle.IsEncoded
        m.view.globalCaptionMode = "Off"
    else
        m.view.globalCaptionMode = "On"
    end if
    if m.selectedSubtitle.IsExternal
        availableSubtitleTrackIndex = availSubtitleTrackIdx(m.selectedSubtitle.Track.TrackName)
        if availableSubtitleTrackIndex = -1 then
            return
        end if
        m.view.subtitleTrack = m.view.availableSubtitleTracks[availableSubtitleTrackIndex].TrackName
    else
        m.view.selectedSubtitle = m.selectedSubtitle.Index
    end if
end sub


sub onSelectPlaybackInfoPressed()

    if isValid(m.playbackData) and isValid(m.playbackData.playbackinfo)
        m.global.sceneManager.callFunc("standardDialog", tr("Playback Info"), m.playbackData.playbackinfo)
        return
    end if
    m.getPlaybackInfoTask.control = "RUN"
end sub


sub onPlaybackInfoLoaded()
    m.playbackData = m.getPlaybackInfoTask.data

    if isValid(m.playbackData) and isValid(m.playbackData.playbackinfo)
        m.global.sceneManager.callFunc("standardDialog", tr("Playback Info"), m.playbackData.playbackinfo)
    end if
end sub


sub onStateChange()
    if LCase(m.view.state) = "finished"

        if m.global.sceneManager.callFunc("isDialogOpen")
            m.global.sceneManager.callFunc("dismissDialog")
        end if

        if m.global.queueManager.callFunc("getPosition") < m.global.queueManager.callFunc("getCount") - 1
            m.global.sceneManager.callFunc("clearPreviousScene")
            m.global.queueManager.callFunc("moveForward")
            m.global.queueManager.callFunc("playQueue")
            return
        end if

        m.global.sceneManager.callFunc("popScene")
        m.global.audioPlayer.loopMode = ""
    end if
end sub





function availSubtitleTrackIdx(tracknameToFind as string) as integer
    idx = 0
    for each availTrack in m.view.availableSubtitleTracks



        if Instr(1, availTrack.TrackName, tracknameToFind)
            return idx
        end if
        idx = idx + 1
    end for
    return -1
end function