

sub init()
    m.rows = m.top.findNode("tvEpisodeRow")
    m.tvListOptions = m.top.findNode("tvListOptions")
    m.rows.observeField("doneLoading", "rowsDoneLoading")
end sub

sub setupRows()
    objects = m.top.objects
    m.rows.objects = objects
end sub

sub rowsDoneLoading()
    m.top.doneLoading = true
end sub


sub SetUpVideoOptions(streams as object)
    videos = []
    for i = 0 to streams.Count() - 1
        if LCase(streams[i].VideoType) = "videofile"

            videos.push({
                "Title": streams[i].Name
                "Description": tr("Video")
                "Selected": m.top.objects.items[m.currentSelected].selectedVideoStreamId = streams[i].id
                "StreamID": streams[i].id
                "video_codec": streams[i].mediaStreams[0].displayTitle
            })
        end if
    end for
    if videos.count() >= 1
        options = {}
        options.videos = videos
        m.tvListOptions.options = options
    end if
end sub


sub SetUpAudioOptions(streams as object)
    tracks = []
    for i = 0 to streams.Count() - 1
        if streams[i].Type = "Audio"
            tracks.push({
                "Title": streams[i].displayTitle
                "Description": streams[i].Title
                "Selected": m.top.objects.items[m.currentSelected].selectedAudioStreamIndex = i
                "StreamIndex": i
            })
        end if
    end for
    if tracks.count() >= 1
        options = {}
        if isValid(m.tvListOptions.options) and isValid(m.tvListOptions.options.videos)
            options.videos = m.tvListOptions.options.videos
        end if
        options.audios = tracks
        m.tvListOptions.options = options
    end if
end sub

sub audioOptionsClosed()
    if m.currentSelected <> invalid



        m.top.objects.items[m.currentSelected].selectedAudioStreamIndex = (function(__bsCondition, m)
                if __bsCondition then
                    return 1
                else
                    return m.tvListOptions.audioStreamIndex
                end if
            end function)(m.tvListOptions.audioStreamIndex = 0, m)
    end if
end sub

sub videoOptionsClosed()
    if m.tvListOptions.videoStreamId <> m.top.objects.items[m.currentSelected].selectedVideoStreamId
        m.rows.objects.items[m.currentSelected].selectedVideoStreamId = m.tvListOptions.videoStreamId
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then
        return false
    end if
    if key = "options" and isValid(m.rows.focusedChild) and isValid(m.rows.focusedChild.rowItemFocused)
        m.currentSelected = m.rows.focusedChild.rowItemFocused[0]
        mediaStreams = m.rows.objects.items[m.currentSelected].json.MediaStreams
        mediaSources = m.rows.objects.items[m.currentSelected].json.MediaSources
        if m.rows.objects.items[m.currentSelected].selectedVideoStreamId <> ""
            for each source in mediaSources
                if source.id = m.rows.objects.items[m.currentSelected].selectedVideoStreamId
                    mediaStreams = source.MediaStreams
                    exit for
                end if
            end for
        end if
        if isValid(mediaSources)
            SetUpVideoOptions(mediaSources)
        end if
        if isValid(mediaStreams)
            SetUpAudioOptions(mediaStreams)
        end if
        if isValid(m.tvListOptions.options)
            m.tvListOptions.visible = true
            m.tvListOptions.setFocus(true)
        end if
        return true
    else if m.tvListOptions.visible = true and key = "back" or key = "options"
        m.tvListOptions.setFocus(false)
        m.tvListOptions.visible = false
        m.rows.setFocus(true)
        videoOptionsClosed()
        audioOptionsClosed()
        return true
    else if key = "up" and m.rows.hasFocus() = false
        m.rows.setFocus(true)
    else if key = "down" and m.rows.hasFocus() = false
        m.rows.setFocus(true)
    end if
    return false
end function