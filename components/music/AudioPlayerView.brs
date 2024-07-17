




sub init()
    m.top.optionsAvailable = false
    setupAudioNode()
    setupAnimationTasks()
    setupButtons()
    setupInfoNodes()
    setupDataTasks()
    setupScreenSaver()
    m.playlistTypeCount = m.global.queueManager.callFunc("getQueueUniqueTypes").count()
    m.buttonCount = m.buttons.getChildCount()
    m.screenSaverTimeout = 300
    m.LoadScreenSaverTimeoutTask.observeField("content", "onScreensaverTimeoutLoaded")
    m.LoadScreenSaverTimeoutTask.control = "RUN"
    m.di = CreateObject("roDeviceInfo")

    WriteAsciiFile("tmp:/scene.temp", "nowplaying")
    MoveFile("tmp:/scene.temp", "tmp:/scene")
    loadButtons()
    pageContentChanged()
    setShuffleIconState()
    setLoopButtonImage()
end sub

sub onScreensaverTimeoutLoaded()
    data = m.LoadScreenSaverTimeoutTask.content
    m.LoadScreenSaverTimeoutTask.unobserveField("content")
    if isValid(data)
        m.screenSaverTimeout = data
    end if
end sub

sub setupScreenSaver()
    m.screenSaverBackground = m.top.FindNode("screenSaverBackground")

    m.screenSaverAlbumCover = m.top.FindNode("screenSaverAlbumCover")
    m.screenSaverAlbumAnimation = m.top.findNode("screenSaverAlbumAnimation")
    m.screenSaverAlbumCoverFadeIn = m.top.findNode("screenSaverAlbumCoverFadeIn")

    m.PosterOne = m.top.findNode("PosterOne")
    m.PosterOne.uri = "pkg:/images/logo.png"
    m.BounceAnimation = m.top.findNode("BounceAnimation")
    m.PosterOneFadeIn = m.top.findNode("PosterOneFadeIn")
end sub

sub setupAnimationTasks()
    m.displayButtonsAnimation = m.top.FindNode("displayButtonsAnimation")
    m.playPositionAnimation = m.top.FindNode("playPositionAnimation")
    m.playPositionAnimationWidth = m.top.FindNode("playPositionAnimationWidth")
    m.bufferPositionAnimation = m.top.FindNode("bufferPositionAnimation")
    m.bufferPositionAnimationWidth = m.top.FindNode("bufferPositionAnimationWidth")
    m.screenSaverStartAnimation = m.top.FindNode("screenSaverStartAnimation")
end sub


sub setupDataTasks()

    m.LoadMetaDataTask = CreateObject("roSGNode", "LoadItemsTask")
    m.LoadMetaDataTask.itemsToLoad = "metaData"

    m.LoadBackdropImageTask = CreateObject("roSGNode", "LoadItemsTask")
    m.LoadBackdropImageTask.itemsToLoad = "backdropImage"

    m.LoadAudioStreamTask = CreateObject("roSGNode", "LoadItemsTask")
    m.LoadAudioStreamTask.itemsToLoad = "audioStream"
    m.LoadScreenSaverTimeoutTask = CreateObject("roSGNode", "LoadScreenSaverTimeoutTask")
end sub


sub setupAudioNode()
    m.global.audioPlayer.observeField("state", "audioStateChanged")
    m.global.audioPlayer.observeField("position", "audioPositionChanged")
    m.global.audioPlayer.observeField("bufferingStatus", "bufferPositionChanged")
end sub


sub setupButtons()
    m.buttons = m.top.findNode("buttons")
    m.top.observeField("selectedButtonIndex", "onButtonSelectedChange")
    m.previouslySelectedButtonIndex = 1
    m.top.selectedButtonIndex = 2
end sub


sub onButtonSelectedChange()

    selectedButton = m.buttons.getChild(m.previouslySelectedButtonIndex)
    selectedButton.uri = selectedButton.uri.Replace("-selected", "-default")

    selectedButton = m.buttons.getChild(m.top.selectedButtonIndex)
    selectedButton.uri = selectedButton.uri.Replace("-default", "-selected")
end sub

sub setupInfoNodes()
    m.albumCover = m.top.findNode("albumCover")
    m.backDrop = m.top.findNode("backdrop")
    m.playPosition = m.top.findNode("playPosition")
    m.bufferPosition = m.top.findNode("bufferPosition")
    m.seekBar = m.top.findNode("seekBar")
    m.shuffleIndicator = m.top.findNode("shuffleIndicator")
    m.loopIndicator = m.top.findNode("loopIndicator")
    m.positionTimestamp = m.top.findNode("positionTimestamp")
    m.totalLengthTimestamp = m.top.findNode("totalLengthTimestamp")
end sub

sub bufferPositionChanged()
    if not isValid(m.global.audioPlayer.bufferingStatus)
        bufferPositionBarWidth = m.seekBar.width
    else
        bufferPositionBarWidth = m.seekBar.width * m.global.audioPlayer.bufferingStatus.percentage
    end if

    if bufferPositionBarWidth > m.seekBar.width
        bufferPositionBarWidth = m.seekBar.width
    end if

    m.bufferPositionAnimationWidth.keyValue = [
        m.bufferPosition.width
        bufferPositionBarWidth
    ]
    m.bufferPositionAnimation.control = "start"
end sub

sub audioPositionChanged()
    if m.global.audioPlayer.position = 0
        m.playPosition.width = 0
    end if
    if not isValid(m.global.audioPlayer.position)
        playPositionBarWidth = 0
    else if not isValid(m.songDuration)
        playPositionBarWidth = 0
    else
        songPercentComplete = m.global.audioPlayer.position / m.songDuration
        playPositionBarWidth = m.seekBar.width * songPercentComplete
    end if

    if playPositionBarWidth > m.seekBar.width
        playPositionBarWidth = m.seekBar.width
    end if

    m.playPositionAnimationWidth.keyValue = [
        m.playPosition.width
        playPositionBarWidth
    ]
    m.playPositionAnimation.control = "start"

    if isValid(m.global.audioPlayer.position)
        m.positionTimestamp.text = secondsToHuman(m.global.audioPlayer.position, false)
    else
        m.positionTimestamp.text = "0:00"
    end if

    if m.screenSaverTimeout > 0
        if m.di.TimeSinceLastKeypress() >= m.screenSaverTimeout - 2
            if not screenSaverActive()
                startScreenSaver()
            end if
        end if
    end if
end sub

function screenSaverActive() as boolean
    return m.screenSaverBackground.visible or m.screenSaverAlbumCover.opacity > 0 or m.PosterOne.opacity > 0
end function

sub startScreenSaver()
    m.screenSaverBackground.visible = true
    m.top.overhangVisible = false
    if m.albumCover.uri = ""

        m.PosterOne.visible = true
        m.PosterOneFadeIn.control = "start"
        m.BounceAnimation.control = "start"
    else

        m.screenSaverAlbumCoverFadeIn.control = "start"
        m.screenSaverAlbumAnimation.control = "start"
    end if
end sub

sub endScreenSaver()
    m.PosterOneFadeIn.control = "pause"
    m.screenSaverAlbumCoverFadeIn.control = "pause"
    m.screenSaverAlbumAnimation.control = "pause"
    m.BounceAnimation.control = "pause"
    m.screenSaverBackground.visible = false
    m.screenSaverAlbumCover.opacity = 0
    m.PosterOne.opacity = 0
    m.top.overhangVisible = true
end sub

sub audioStateChanged()

    if m.global.audioPlayer.state = "finished"

        if m.global.audioPlayer.loopMode = "one"
            playAction()
            return
        end if
        if m.global.queueManager.callFunc("getPosition") < m.global.queueManager.callFunc("getCount") - 1
            m.top.state = "finished"
        else


            if m.global.audioPlayer.loopMode = "all"
                m.global.queueManager.callFunc("setPosition", -1)
                LoadNextSong()
                return
            end if

            m.top.state = "finished"
        end if
    end if
end sub

function playAction() as boolean
    if m.global.audioPlayer.state = "playing"
        m.global.audioPlayer.control = "pause"

        WriteAsciiFile("tmp:/scene.temp", "nowplaying-paused")
        MoveFile("tmp:/scene.temp", "tmp:/scene")
    else if m.global.audioPlayer.state = "paused"
        m.global.audioPlayer.control = "resume"

        WriteAsciiFile("tmp:/scene.temp", "nowplaying")
        MoveFile("tmp:/scene.temp", "tmp:/scene")
    else if m.global.audioPlayer.state = "finished"
        m.global.audioPlayer.control = "play"

        WriteAsciiFile("tmp:/scene.temp", "nowplaying")
        MoveFile("tmp:/scene.temp", "tmp:/scene")
    end if
    return true
end function

function previousClicked() as boolean
    if m.playlistTypeCount > 1 then
        return false
    end if
    if m.global.queueManager.callFunc("getPosition") = 0 then
        return false
    end if
    if m.global.audioPlayer.state = "playing"
        m.global.audioPlayer.control = "stop"
    end if

    if m.global.audioPlayer.loopMode = "one"
        resetLoopModeToDefault()
    end if
    m.global.queueManager.callFunc("moveBack")
    pageContentChanged()
    return true
end function

sub resetLoopModeToDefault()
    m.global.audioPlayer.loopMode = ""
    setLoopButtonImage()
end sub

function loopClicked() as boolean
    if m.global.audioPlayer.loopMode = ""
        m.global.audioPlayer.loopMode = "all"
    else if m.global.audioPlayer.loopMode = "all"
        m.global.audioPlayer.loopMode = "one"
    else
        m.global.audioPlayer.loopMode = ""
    end if
    setLoopButtonImage()
    return true
end function

sub setLoopButtonImage()
    if m.global.audioPlayer.loopMode = "all"
        m.loopIndicator.opacity = "1"
        m.loopIndicator.uri = m.loopIndicator.uri.Replace("-off", "-on")
    else if m.global.audioPlayer.loopMode = "one"
        m.loopIndicator.uri = m.loopIndicator.uri.Replace("-on", "1-on")
    else
        m.loopIndicator.uri = m.loopIndicator.uri.Replace("1-on", "-off")
    end if
end sub

function nextClicked() as boolean
    if m.playlistTypeCount > 1 then
        return false
    end if

    if m.global.audioPlayer.loopMode = "one"
        resetLoopModeToDefault()
    end if
    if m.global.queueManager.callFunc("getPosition") < m.global.queueManager.callFunc("getCount") - 1
        LoadNextSong()
    end if
    return true
end function

sub toggleShuffleEnabled()
    m.global.queueManager.callFunc("toggleShuffle")
end sub

function findCurrentSongIndex(songList) as integer
    if not isValidAndNotEmpty(songList) then
        return 0
    end if
    for i = 0 to songList.count() - 1
        if songList[i].id = m.global.queueManager.callFunc("getCurrentItem").id
            return i
        end if
    end for
    return 0
end function

function shuffleClicked() as boolean
    currentSongIndex = findCurrentSongIndex(m.global.queueManager.callFunc("getUnshuffledQueue"))
    toggleShuffleEnabled()
    if not m.global.queueManager.callFunc("getIsShuffled")
        m.shuffleIndicator.opacity = ".4"
        m.shuffleIndicator.uri = m.shuffleIndicator.uri.Replace("-on", "-off")
        m.global.queueManager.callFunc("setPosition", currentSongIndex)
        setTrackNumberDisplay()
        return true
    end if
    m.shuffleIndicator.opacity = "1"
    m.shuffleIndicator.uri = m.shuffleIndicator.uri.Replace("-off", "-on")
    setTrackNumberDisplay()
    return true
end function

sub setShuffleIconState()
    if m.global.queueManager.callFunc("getIsShuffled")
        m.shuffleIndicator.opacity = "1"
        m.shuffleIndicator.uri = m.shuffleIndicator.uri.Replace("-off", "-on")
    end if
end sub

sub setTrackNumberDisplay()
    setFieldTextValue("numberofsongs", "Track " + stri(m.global.queueManager.callFunc("getPosition") + 1) + "/" + stri(m.global.queueManager.callFunc("getCount")))
end sub

sub LoadNextSong()
    if m.global.audioPlayer.state = "playing"
        m.global.audioPlayer.control = "stop"
    end if

    m.playPosition.width = 0
    m.global.queueManager.callFunc("moveForward")
    pageContentChanged()
end sub


sub pageContentChanged()

    m.bufferPosition.width = 0
    useMetaTask = false
    currentItem = m.global.queueManager.callFunc("getCurrentItem")
    if not isValid(currentItem.RunTimeTicks)
        useMetaTask = true
    end if
    if not isValid(currentItem.AlbumArtist)
        useMetaTask = true
    end if
    if not isValid(currentItem.name)
        useMetaTask = true
    end if
    if not isValid(currentItem.Artists)
        useMetaTask = true
    end if
    if useMetaTask
        m.LoadMetaDataTask.itemId = currentItem.id
        m.LoadMetaDataTask.observeField("content", "onMetaDataLoaded")
        m.LoadMetaDataTask.control = "RUN"
    else
        if isValid(currentItem.ParentBackdropItemId)
            setBackdropImage(ImageURL(currentItem.ParentBackdropItemId, "Backdrop", {
                "maxHeight": "720"
                "maxWidth": "1280"
            }))
        end if
        setPosterImage(ImageURL(currentItem.id, "Primary", {
            "maxHeight": 500
            "maxWidth": 500
        }))
        setScreenTitle(currentItem)
        setOnScreenTextValues(currentItem)
        m.songDuration = currentItem.RunTimeTicks / 10000000.0

        m.totalLengthTimestamp.text = ticksToHuman(currentItem.RunTimeTicks)
    end if
    m.LoadAudioStreamTask.itemId = currentItem.id
    m.LoadAudioStreamTask.observeField("content", "onAudioStreamLoaded")
    m.LoadAudioStreamTask.control = "RUN"
end sub


sub loadButtons()

    if m.playlistTypeCount > 1 then
        return
    end if
    if m.global.queueManager.callFunc("getCount") > 1
        m.shuffleIndicator.opacity = ".4"
        m.loopIndicator.opacity = ".4"
        m.displayButtonsAnimation.control = "start"
        setLoopButtonImage()
    end if
end sub

sub onAudioStreamLoaded()
    stopLoadingSpinner()
    data = m.LoadAudioStreamTask.content[0]
    m.LoadAudioStreamTask.unobserveField("content")
    if data <> invalid and data.count() > 0
        m.global.audioPlayer.content = data
        m.global.audioPlayer.control = "none"
        m.global.audioPlayer.control = "play"
    end if
end sub

sub onBackdropImageLoaded()
    data = m.LoadBackdropImageTask.content[0]
    m.LoadBackdropImageTask.unobserveField("content")
    if isValid(data) and data <> ""
        setBackdropImage(data)
    end if
end sub

sub onMetaDataLoaded()
    data = m.LoadMetaDataTask.content[0]
    m.LoadMetaDataTask.unobserveField("content")
    if isValid(data) and data.count() > 0 and isValid(data.json)

        if isValid(data.json.ArtistItems) and isValid(data.json.ArtistItems[0]) and isValid(data.json.ArtistItems[0].id)
            m.LoadBackdropImageTask.itemId = data.json.ArtistItems[0].id
            m.LoadBackdropImageTask.observeField("content", "onBackdropImageLoaded")
            m.LoadBackdropImageTask.control = "RUN"
        end if
        setPosterImage(data.posterURL)
        setScreenTitle(data.json)
        setOnScreenTextValues(data.json)
        if isValid(data.json.RunTimeTicks)
            m.songDuration = data.json.RunTimeTicks / 10000000.0

            m.totalLengthTimestamp.text = ticksToHuman(data.json.RunTimeTicks)
        end if
    end if
end sub


sub setPosterImage(posterURL)
    if isValid(posterURL)
        if m.albumCover.uri <> posterURL
            m.albumCover.uri = posterURL
            m.screenSaverAlbumCover.uri = posterURL
        end if
    end if
end sub


sub setScreenTitle(json)
    newTitle = ""
    if isValid(json)
        if isValid(json.AlbumArtist)
            newTitle = json.AlbumArtist
        end if
        if isValid(json.AlbumArtist) and isValid(json.name)
            newTitle = newTitle + " / "
        end if
        if isValid(json.name)
            newTitle = newTitle + json.name
        end if
    end if
    if m.top.overhangTitle <> newTitle
        m.top.overhangTitle = newTitle
    end if
end sub


sub setOnScreenTextValues(json)
    if isValid(json)
        if m.playlistTypeCount = 1
            setTrackNumberDisplay()
        end if
        setFieldTextValue("artist", json.Artists[0])
        setFieldTextValue("song", json.name)
    end if
end sub


sub setBackdropImage(data)
    if isValid(data)
        if m.backDrop.uri <> data
            m.backDrop.uri = data
        end if
    end if
end sub


function onKeyEvent(key as string, press as boolean) as boolean

    if press

        if screenSaverActive()
            endScreenSaver()
            return true
        end if
        if key = "play"
            return playAction()
        else if key = "back"
            m.global.audioPlayer.control = "stop"
            m.global.audioPlayer.loopMode = ""
        else if key = "rewind"
            return previousClicked()
        else if key = "fastforward"
            return nextClicked()
        else if key = "left"
            if m.global.queueManager.callFunc("getCount") = 1 then
                return false
            end if
            if m.top.selectedButtonIndex > 0
                m.previouslySelectedButtonIndex = m.top.selectedButtonIndex
                m.top.selectedButtonIndex = m.top.selectedButtonIndex - 1
            end if
            return true
        else if key = "right"
            if m.global.queueManager.callFunc("getCount") = 1 then
                return false
            end if
            m.previouslySelectedButtonIndex = m.top.selectedButtonIndex
            if m.top.selectedButtonIndex < m.buttonCount - 1 then
                m.top.selectedButtonIndex = m.top.selectedButtonIndex + 1
            end if
            return true
        else if key = "OK"
            if m.buttons.getChild(m.top.selectedButtonIndex).id = "play"
                return playAction()
            else if m.buttons.getChild(m.top.selectedButtonIndex).id = "previous"
                return previousClicked()
            else if m.buttons.getChild(m.top.selectedButtonIndex).id = "next"
                return nextClicked()
            else if m.buttons.getChild(m.top.selectedButtonIndex).id = "shuffle"
                return shuffleClicked()
            else if m.buttons.getChild(m.top.selectedButtonIndex).id = "loop"
                return loopClicked()
            end if
        end if
    end if
    return false
end function

sub OnScreenHidden()

    WriteAsciiFile("tmp:/scene.temp", "")
    MoveFile("tmp:/scene.temp", "tmp:/scene")
end sub