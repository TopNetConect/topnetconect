


sub init()
    m.top.optionsAvailable = true
    m.top.overhangVisible = false
    m.slideshowTimer = m.top.findNode("slideshowTimer")
    m.slideshowTimer.observeField("fire", "nextSlide")
    m.status = m.top.findNode("status")
    m.textBackground = m.top.findNode("background")
    m.statusTimer = m.top.findNode("statusTimer")
    m.statusTimer.observeField("fire", "statusUpdate")
    m.slideshow = m.global.session.user.settings["photos.slideshow"]
    m.random = m.global.session.user.settings["photos.random"]
    m.showStatusAnimation = m.top.findNode("showStatusAnimation")
    m.hideStatusAnimation = m.top.findNode("hideStatusAnimation")
    itemContentChanged()
end sub

sub itemContentChanged()
    if isValidToContinue(m.top.itemIndex)
        m.LoadLibrariesTask = createObject("roSGNode", "LoadPhotoTask")
        if isValid(m.top.itemsNode)
            if isValid(m.top.itemsNode.content)
                m.LoadLibrariesTask.itemNodeContent = m.top.itemsNode.content.getChild(m.top.itemIndex)
            else if isValidAndNotEmpty(m.top.itemsNode.id)
                m.LoadLibrariesTask.itemNodeContent = m.top.itemsNode
            end if
        else if isValid(m.top.itemsArray)
            itemContent = m.top.itemsArray[m.top.itemIndex]
            m.LoadLibrariesTask.itemArrayContent = itemContent
        else
            return
        end if
        m.LoadLibrariesTask.observeField("results", "onPhotoLoaded")
        m.LoadLibrariesTask.control = "RUN"
    end if
end sub

sub onPhotoLoaded()
    stopLoadingSpinner()
    if m.LoadLibrariesTask.results <> invalid
        photo = m.top.findNode("photo")
        photo.uri = m.LoadLibrariesTask.results
        if m.slideshow = true or m.random = true

            m.slideshowTimer.control = "start"
        end if
    else

        message_dialog("This image type is not supported.")
    end if
end sub

sub nextSlide()
    m.slideshowTimer.control = "stop"
    if m.slideshow = true
        if isValidToContinue(m.top.itemIndex + 1)
            m.top.itemIndex++
            m.slideshowTimer.control = "start"
        end if
    else if m.random = true
        index = invalid
        if isValid(m.top.itemsNode)
            if isValidAndNotEmpty(m.top.itemsNode.content)
                index = rnd(m.top.itemsNode.content.getChildCount() - 1)
            else

                return
            end if
        else if isValid(m.top.itemsArray)
            if m.top.itemsArray.count() > 0
                index = rnd(m.top.itemsArray.count() - 1)
            end if
        end if
        if isValid(index) and isValidToContinue(index)
            m.top.itemIndex = index
            m.slideshowTimer.control = "start"
        end if
    end if
end sub

sub statusUpdate()
    m.statusTimer.control = "stop"
    m.hideStatusAnimation.control = "start"
end sub



sub OnScreenHidden()
    m.slideshowTimer.control = "stop"
    m.statusTimer.control = "stop"
end sub


sub isSlideshowChanged()
    m.slideshow = m.top.isSlideshow
end sub


sub isRandomChanged()
    m.random = m.top.isRandom
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then
        return false
    end if
    if key = "right"
        if isValidToContinue(m.top.itemIndex + 1)
            m.slideshowTimer.control = "stop"
            m.top.itemIndex++
        end if
        return true
    end if
    if key = "left"
        if isValidToContinue(m.top.itemIndex - 1)
            m.slideshowTimer.control = "stop"
            m.top.itemIndex--
        end if
        return true
    end if
    if key = "play"
        if m.slideshowTimer.control = "start"

            m.slideshowTimer.control = "stop"
            m.status.text = tr("Slideshow Paused")
            if m.textBackground.opacity = 0
                m.showStatusAnimation.control = "start"
            end if
            m.statusTimer.control = "start"
        else

            m.status.text = tr("Slideshow Resumed")
            if m.textBackground.opacity = 0
                m.showStatusAnimation.control = "start"
            end if
            m.slideshow = true
            m.statusTimer.control = "start"
            m.slideshowTimer.control = "start"
        end if
        return true
    end if
    if key = "options"

        return true
    end if
    return false
end function

function isValidToContinue(index as integer)
    if isValid(m.top.itemsNode)
        if isValidAndNotEmpty(m.top.itemsNode.content)
            if index >= 0 and index < m.top.itemsNode.content.getChildCount()
                return true
            end if
        else if isValidAndNotEmpty(m.top.itemsNode) and index = 0
            return true
        end if
    else if isValidAndNotEmpty(m.top.itemsArray)
        if index >= 0 and index < m.top.itemsArray.count()
            return true
        end if
    end if
    return false
end function