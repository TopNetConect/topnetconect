







sub init()
    m.hold = []
    m.queue = []
    m.originalQueue = []
    m.queueTypes = []
    m.isPlaying = false

    m.isPrerollActive = m.global.session.user.settings["playback.cinemamode"]
    m.position = 0
    m.shuffleEnabled = false
end sub


sub clear()
    m.isPlaying = false
    m.queue = []
    m.queueTypes = []
    m.isPrerollActive = m.global.session.user.settings["playback.cinemamode"]
    setPosition(0)
end sub


sub clearHold()
    m.hold = []
end sub


sub deleteAtIndex(index)
    m.queue.Delete(index)
    m.queueTypes.Delete(index)
end sub


function getCount()
    return m.queue.count()
end function


function getCurrentItem()
    return getItemByIndex(m.position)
end function


function getHold()
    return m.hold
end function


function getIsShuffled()
    return m.shuffleEnabled
end function


function getItemByIndex(index)
    return m.queue[index]
end function


function getPosition()
    return m.position
end function


sub hold(newItem)
    m.hold.push(newItem)
end sub


sub moveBack()
    m.position--
end sub


sub moveForward()
    m.position++
end sub


function getQueue()
    return m.queue
end function


function getQueueTypes()
    return m.queueTypes
end function


function getQueueUniqueTypes()
    itemTypes = []
    for each item in getQueueTypes()
        if not inArray(itemTypes, item)
            itemTypes.push(item)
        end if
    end for
    return itemTypes
end function


function peek()
    return m.queue.peek()
end function


sub playQueue()
    m.isPlaying = true
    nextItem = getCurrentItem()
    if not isValid(nextItem) then
        return
    end if
    nextItemMediaType = getItemType(nextItem)
    if nextItemMediaType = "" then
        return
    end if
    if nextItemMediaType = "audio"
        CreateAudioPlayerView()
        return
    end if
    if nextItemMediaType = "musicvideo"
        CreateVideoPlayerView()
        return
    end if
    if nextItemMediaType = "video"
        CreateVideoPlayerView()
        return
    end if
    if nextItemMediaType = "movie"
        CreateVideoPlayerView()
        return
    end if
    if nextItemMediaType = "episode"
        CreateVideoPlayerView()
        return
    end if
    if nextItemMediaType = "trailer"
        CreateVideoPlayerView()
        return
    end if
end sub


sub pop()
    m.queue.pop()
    m.queueTypes.pop()
end sub


function isPrerollActive() as boolean
    return m.isPrerollActive
end function


sub setPrerollStatus(newStatus as boolean)
    m.isPrerollActive = newStatus
end sub


sub push(newItem)
    m.queue.push(newItem)
    m.queueTypes.push(getItemType(newItem))
end sub


sub setPosition(newPosition)
    m.position = newPosition
end sub


sub resetShuffle()
    m.shuffleEnabled = false
end sub


sub toggleShuffle()
    m.shuffleEnabled = not m.shuffleEnabled
    if m.shuffleEnabled
        shuffleQueueItems()
        return
    end if
    resetQueueItemOrder()
end sub


sub resetQueueItemOrder()
    set(m.originalQueue)
end sub


function getUnshuffledQueue()
    return m.originalQueue
end function


sub shuffleQueueItems()

    m.originalQueue = m.global.queueManager.callFunc("getQueue")
    itemIDArray = getQueue()
    temp = invalid
    if m.isPlaying

        temp = getCurrentItem()

        itemIDArray.Delete(m.position)
    end if

    itemIDArray = shuffleArray(itemIDArray)
    if m.isPlaying

        itemIDArray.Unshift(temp)
    end if
    set(itemIDArray)
end sub


function top()
    return getItemByIndex(0)
end function


sub set(items)
    clear()
    m.queue = items
    for each item in items
        m.queueTypes.push(getItemType(item))
    end for
end sub


sub setTopStartingPoint(positionTicks)
    m.queue[0].startingPoint = positionTicks
end sub

function getItemType(item) as string
    if isValid(item) and isValid(item.json) and isValid(item.json.mediatype) and item.json.mediatype <> ""
        return LCase(item.json.mediatype)
    else if isValid(item) and isValid(item.type) and item.type <> ""
        return LCase(item.type)
    end if
    return ""
end function