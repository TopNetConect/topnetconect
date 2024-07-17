

sub init()
    m.videoControls = m.top.findNode("videoControls")
    m.optionControls = m.top.findNode("optionControls")
    m.inactivityTimer = m.top.findNode("inactivityTimer")
    m.itemTitle = m.top.findNode("itemTitle")
    m.videoPlayPause = m.top.findNode("videoPlayPause")
    m.videoPositionTime = m.top.findNode("videoPositionTime")
    m.videoRemainingTime = m.top.findNode("videoRemainingTime")
    m.progressBar = m.top.findNode("progressBar")
    m.progressBarBackground = m.top.findNode("progressBarBackground")
    m.top.observeField("visible", "onVisibleChanged")
    m.top.observeField("hasFocus", "onFocusChanged")
    m.top.observeField("progressPercentage", "onProgressPercentageChanged")
    m.top.observeField("playbackState", "onPlaybackStateChanged")
    m.top.observeField("itemTitleText", "onItemTitleTextChanged")
    m.defaultButtonIndex = 1
    m.focusedButtonIndex = 1
    m.videoControls.buttonFocused = m.defaultButtonIndex
    m.optionControls.buttonFocused = m.optionControls.getChildCount() - 1
    m.videoControls.getChild(m.defaultButtonIndex).focus = true
    m.deviceInfo = CreateObject("roDeviceInfo")
end sub



sub onProgressPercentageChanged()
    m.videoPositionTime.text = secondsToHuman(m.top.positionTime, true)
    m.videoRemainingTime.text = secondsToHuman(m.top.remainingPositionTime, true)
    m.progressBar.width = m.progressBarBackground.width * m.top.progressPercentage
end sub



sub onPlaybackStateChanged()
    if LCase(m.top.playbackState) = "playing"
        m.videoPlayPause.icon = "pkg:/images/icons/pause.png"
        return
    end if
    m.videoPlayPause.icon = "pkg:/images/icons/play.png"
end sub



sub onItemTitleTextChanged()
    m.itemTitle.text = m.top.itemTitleText
end sub



sub resetFocusToDefaultButton()

    for each child in m.videoControls.getChildren(-1, 0)
        if isValid(child.focus)
            child.focus = false
        end if
    end for
    for each child in m.optionControls.getChildren(-1, 0)
        if isValid(child.focus)
            child.focus = false
        end if
    end for
    m.optionControls.setFocus(false)

    m.videoControls.setFocus(true)
    m.focusedButtonIndex = m.defaultButtonIndex
    m.videoControls.getChild(m.defaultButtonIndex).focus = true
    m.videoControls.buttonFocused = 1
    m.optionControls.buttonFocused = m.optionControls.getChildCount() - 1
end sub



sub onVisibleChanged()
    if m.top.visible
        resetFocusToDefaultButton()
        m.inactivityTimer.observeField("fire", "inactiveCheck")
        m.inactivityTimer.control = "start"
        return
    end if
    m.inactivityTimer.unobserveField("fire")
    m.inactivityTimer.control = "stop"
end sub



sub onFocusChanged()
    if m.top.hasfocus
        focusedButton = m.optionControls.getChild(m.focusedButtonIndex)
        if focusedButton.focus
            m.optionControls.setFocus(true)
            return
        end if
        m.videoControls.setFocus(true)
    end if
end sub



sub inactiveCheck()

    if m.global.sceneManager.callFunc("isDialogOpen")
        return
    end if
    if m.deviceInfo.timeSinceLastKeypress() >= m.top.inactiveTimeout
        m.top.action = "hide"
    end if
end sub



sub onButtonSelected()
    if m.optionControls.isInFocusChain()
        buttonGroup = m.optionControls
    else
        buttonGroup = m.videoControls
    end if
    selectedButton = buttonGroup.getChild(m.focusedButtonIndex)
    if LCase(selectedButton.id) = "chapterlist"
        m.top.showChapterList = not m.top.showChapterList
    end if
    m.top.action = selectedButton.id
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then
        return false
    end if
    if key = "OK"
        onButtonSelected()
        return true
    end if
    if key = "play"
        m.top.action = "videoplaypause"
        return true
    end if
    if key = "right"
        if m.optionControls.isInFocusChain()
            buttonGroup = m.optionControls
        else
            buttonGroup = m.videoControls
        end if
        if m.focusedButtonIndex + 1 >= buttonGroup.getChildCount()
            return true
        end if
        focusedButton = buttonGroup.getChild(m.focusedButtonIndex)
        focusedButton.focus = false

        for i = m.focusedButtonIndex + 1 to buttonGroup.getChildCount()
            m.focusedButtonIndex = i
            focusedButton = buttonGroup.getChild(m.focusedButtonIndex)
            if isValid(focusedButton.focus)
                buttonGroup.buttonFocused = m.focusedButtonIndex
                focusedButton.focus = true
                exit for
            end if
        end for
        return true
    end if
    if key = "left"
        if m.focusedButtonIndex = 0
            return true
        end if
        if m.optionControls.isInFocusChain()
            buttonGroup = m.optionControls
        else
            buttonGroup = m.videoControls
        end if
        focusedButton = buttonGroup.getChild(m.focusedButtonIndex)
        focusedButton.focus = false

        for i = m.focusedButtonIndex - 1 to 0 step -1
            m.focusedButtonIndex = i
            focusedButton = buttonGroup.getChild(m.focusedButtonIndex)
            if isValid(focusedButton.focus)
                buttonGroup.buttonFocused = m.focusedButtonIndex
                focusedButton.focus = true
                exit for
            end if
        end for
        return true
    end if
    if key = "up"
        if m.videoControls.isInFocusChain()
            focusedButton = m.videoControls.getChild(m.focusedButtonIndex)
            focusedButton.focus = false
            m.videoControls.setFocus(false)
            m.focusedButtonIndex = m.optionControls.buttonFocused
            focusedButton = m.optionControls.getChild(m.focusedButtonIndex)
            focusedButton.focus = true
            m.optionControls.setFocus(true)
        end if
        return true
    end if
    if key = "down"
        if m.optionControls.isInFocusChain()
            focusedButton = m.optionControls.getChild(m.focusedButtonIndex)
            focusedButton.focus = false
            m.optionControls.setFocus(false)
            m.focusedButtonIndex = m.videoControls.buttonFocused
            focusedButton = m.videoControls.getChild(m.focusedButtonIndex)
            focusedButton.focus = true
            m.videoControls.setFocus(true)
        end if
        return true
    end if

    m.top.action = "hide"
    return true
end function