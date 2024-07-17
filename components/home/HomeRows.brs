



sub init()
    m.top.itemComponentName = "HomeItem"

    m.top.numRows = 2
    m.top.rowFocusAnimationStyle = "fixedFocusWrap"
    m.top.vertFocusAnimationStyle = "fixedFocus"
    m.top.showRowLabel = [
        true
    ]
    m.top.rowLabelOffset = [
        0
        20
    ]

    m.top.showRowCounter = [
        false
    ]
    m.top.content = CreateObject("roSGNode", "ContentNode")
    m.loadingTimer = createObject("roSGNode", "Timer")
    m.loadingTimer.duration = 2
    m.loadingTimer.observeField("fire", "loadingTimerComplete")
    updateSize()
    m.top.setfocus(true)
    m.top.observeField("rowItemSelected", "itemSelected")

    m.LoadLibrariesTask = createObject("roSGNode", "LoadItemsTask")
    m.LoadLibrariesTask.observeField("content", "onLibrariesLoaded")

    m.LoadContinueWatchingTask = createObject("roSGNode", "LoadItemsTask")
    m.LoadContinueWatchingTask.itemsToLoad = "continue"
    m.LoadNextUpTask = createObject("roSGNode", "LoadItemsTask")
    m.LoadNextUpTask.itemsToLoad = "nextUp"
    m.LoadOnNowTask = createObject("roSGNode", "LoadItemsTask")
    m.LoadOnNowTask.itemsToLoad = "onNow"
    m.LoadFavoritesTask = createObject("roSGNode", "LoadItemsTask")
    m.LoadFavoritesTask.itemsToLoad = "favorites"
end sub

sub loadLibraries()
    m.LoadLibrariesTask.control = "RUN"
end sub

sub updateSize()
    m.top.translation = [
        111
        180
    ]
    itemHeight = 330

    m.top.itemSize = [
        1703
        itemHeight
    ]

    m.top.itemSpacing = [
        0
        105
    ]

    m.top.rowItemSpacing = [
        20
        0
    ]

    m.top.rowItemSize = ([
        464
        331
    ])
    m.top.visible = true
end sub



sub processUserSections()
    m.expectedRowCount = 1 ' the favorites row is hardcoded to always show atm
    m.processedRowCount = 0

    for i = 0 to 6
        sectionName = LCase(m.global.session.user.settings["homesection" + i.toStr()])
        if sectionName = "latestmedia"

            m.filteredLatest = filterNodeArray(m.libraryData, "id", m.global.session.user.configuration.LatestItemsExcludes)
            for each latestLibrary in m.filteredLatest
                if latestLibrary.collectionType <> "boxsets" and latestLibrary.collectionType <> "livetv" and latestLibrary.json.CollectionType <> "Program"
                    m.expectedRowCount++
                end if
            end for
        else if sectionName <> "none"
            m.expectedRowCount++
        end if
    end for

    loadedSections = 0
    for i = 0 to 6
        sectionName = LCase(m.global.session.user.settings["homesection" + i.toStr()])
        sectionLoaded = false
        if sectionName <> "none"
            sectionLoaded = addHomeSection(sectionName)
        end if

        if sectionLoaded then
            loadedSections++
        end if

        if not m.global.app_loaded
            if loadedSections = 2 or i = 6
                m.top.signalBeacon("AppLaunchComplete") ' Roku Performance monitoring
                m.global.app_loaded = true
            end if
        end if
    end for

    addHomeSection("favorites")

    m.loadingTimer.control = "start"
end sub



sub onLibrariesLoaded()

    m.libraryData = m.LoadLibrariesTask.content
    m.LoadLibrariesTask.unobserveField("content")
    m.LoadLibrariesTask.content = []
    processUserSections()
end sub






function getOriginalSectionIndex(sectionName as string) as integer
    searchSectionName = LCase(sectionName).Replace(" ", "")
    sectionIndex = 0
    indexLatestMediaSection = 0
    for i = 0 to 6
        settingSectionName = LCase(m.global.session.user.settings["homesection" + i.toStr()])
        if settingSectionName = "latestmedia"
            indexLatestMediaSection = i
        end if
        if settingSectionName = searchSectionName
            sectionIndex = i
        end if
    end for

    addLatestMediaSectionCount = (indexLatestMediaSection < sectionIndex)
    if addLatestMediaSectionCount
        for i = sectionIndex to m.top.content.getChildCount() - 1
            sectionToTest = m.top.content.getChild(i)
            if LCase(Left(sectionToTest.title, 6)) = "latest"
                sectionIndex++
            end if
        end for
    end if
    return sectionIndex
end function




sub removeHomeSection(sectionTitleToRemove as string)
    if not isValid(sectionTitleToRemove) then
        return
    end if
    sectionTitle = LCase(sectionTitleToRemove).Replace(" ", "")
    if not sectionExists(sectionTitle) then
        return
    end if
    sectionIndexToRemove = getSectionIndex(sectionTitle)
    m.top.content.removeChildIndex(sectionIndexToRemove)
    setRowItemSize()
end sub



sub setRowItemSize()
    if not isValid(m.top.content) then
        return
    end if
    homeSections = m.top.content.getChildren(-1, 0)
    newSizeArray = CreateObject("roArray", homeSections.count(), false)
    for i = 0 to homeSections.count() - 1
        newSizeArray[i] = (function(__bsCondition, homeRowItemSizes, homeSections, i)
                if __bsCondition then
                    return homeSections[i].cursorSize
                else
                    return ([
                        464
                        331
                    ])
                end if
            end function)(isValid(homeSections[i].cursorSize), homeRowItemSizes, homeSections, i)
    end for
    m.top.rowItemSize = newSizeArray

    if m.expectedRowCount = m.processedRowCount
        m.loadingTimer.control = "stop"
        loadingTimerComplete()
    end if
end sub



sub loadingTimerComplete()
    if not m.top.showRowCounter[0]

        m.top.showRowCounter = [
            true
        ]
    end if
end sub





function addHomeSection(sectionType as string) as boolean

    if sectionType = "livetv"
        createLiveTVRow()
        return true
    end if

    if sectionType = "smalllibrarytiles"
        createLibraryRow()
        return true
    end if

    if sectionType = "resume"
        createContinueWatchingRow()
        return true
    end if

    if sectionType = "nextup"
        createNextUpRow()
        return true
    end if

    if sectionType = "latestmedia"
        createLatestInRows()
        return true
    end if

    if sectionType = "favorites"
        createFavoritesRow()
        return true
    end if


    m.processedRowCount++
    return false
end function



sub createLibraryRow()
    m.processedRowCount++

    if not isValidAndNotEmpty(m.libraryData) then
        return
    end if
    sectionName = tr("My Media")

    if sectionExists(sectionName)
        return
    end if
    row = CreateObject("roSGNode", "HomeRow")
    row.title = sectionName
    row.imageWidth = ([
        464
        331
    ])[0]
    row.cursorSize = ([
        464
        331
    ])
    filteredMedia = filterNodeArray(m.libraryData, "id", m.global.session.user.configuration.MyMediaExcludes)
    for each item in filteredMedia
        row.appendChild(item)
    end for

    m.top.content.insertChild(row, getOriginalSectionIndex("smalllibrarytiles"))
    setRowItemSize()
end sub



sub createLatestInRows()

    if not isValidAndNotEmpty(m.libraryData) then
        return
    end if

    for each lib in m.filteredLatest
        if lib.collectionType <> "boxsets" and lib.collectionType <> "livetv" and lib.json.CollectionType <> "Program"
            loadLatest = createObject("roSGNode", "LoadItemsTask")
            loadLatest.itemsToLoad = "latest"
            loadLatest.itemId = lib.id
            metadata = {
                "title": lib.name
            }
            metadata.Append({
                "contentType": lib.json.CollectionType
            })
            loadLatest.metadata = metadata
            loadLatest.observeField("content", "updateLatestItems")
            loadLatest.control = "RUN"
        end if
    end for
end sub






function sectionExists(sectionTitle as string) as boolean
    if not isValid(sectionTitle) then
        return false
    end if
    if not isValid(m.top.content) then
        return false
    end if
    searchSectionTitle = LCase(sectionTitle).Replace(" ", "")
    homeSections = m.top.content.getChildren(-1, 0)
    for each section in homeSections
        if LCase(section.title).Replace(" ", "") = searchSectionTitle
            return true
        end if
    end for
    return false
end function






function getSectionIndex(sectionTitle as string) as integer
    if not isValid(sectionTitle) then
        return false
    end if
    if not isValid(m.top.content) then
        return false
    end if
    searchSectionTitle = LCase(sectionTitle).Replace(" ", "")
    homeSections = m.top.content.getChildren(-1, 0)
    sectionIndex = homeSections.count()
    i = 0
    for each section in homeSections
        if LCase(section.title).Replace(" ", "") = searchSectionTitle
            sectionIndex = i
            exit for
        end if
        i++
    end for
    return sectionIndex
end function



sub createLiveTVRow()
    m.LoadOnNowTask.observeField("content", "updateOnNowItems")
    m.LoadOnNowTask.control = "RUN"
end sub



sub createContinueWatchingRow()

    m.LoadContinueWatchingTask.observeField("content", "updateContinueWatchingItems")
    m.LoadContinueWatchingTask.control = "RUN"
end sub



sub createNextUpRow()
    sectionName = tr("Next Up") + ">"
    if not sectionExists(sectionName)
        nextUpRow = m.top.content.CreateChild("HomeRow")
        nextUpRow.title = sectionName
        nextUpRow.imageWidth = ([
            464
            331
        ])[0]
        nextUpRow.cursorSize = ([
            464
            331
        ])
    end if

    m.LoadNextUpTask.observeField("content", "updateNextUpItems")
    m.LoadNextUpTask.control = "RUN"
end sub



sub createFavoritesRow()

    m.LoadFavoritesTask.observeField("content", "updateFavoritesItems")
    m.LoadFavoritesTask.control = "RUN"
end sub



sub updateHomeRows()

    m.top.showRowCounter = [
        false
    ]
    processUserSections()
end sub



sub updateFavoritesItems()
    m.processedRowCount++
    itemData = m.LoadFavoritesTask.content
    m.LoadFavoritesTask.unobserveField("content")
    m.LoadFavoritesTask.content = []
    sectionName = tr("Favorites")
    if not isValidAndNotEmpty(itemData)
        removeHomeSection(sectionName)
        return
    end if

    row = CreateObject("roSGNode", "HomeRow")
    row.title = sectionName
    row.imageWidth = ([
        464
        331
    ])[0]
    row.cursorSize = ([
        464
        331
    ])
    for each item in itemData
        usePoster = true
        if lcase(item.type) = "episode" or lcase(item.type) = "audio" or lcase(item.type) = "musicartist"
            usePoster = false
        end if
        item.usePoster = usePoster
        item.imageWidth = row.imageWidth
        row.appendChild(item)
    end for
    if sectionExists(sectionName)
        m.top.content.replaceChild(row, getSectionIndex(sectionName))
        setRowItemSize()
        return
    end if
    m.top.content.insertChild(row, getSectionIndex(sectionName))
    setRowItemSize()
end sub



sub updateContinueWatchingItems()
    m.processedRowCount++
    itemData = m.LoadContinueWatchingTask.content
    m.LoadContinueWatchingTask.unobserveField("content")
    m.LoadContinueWatchingTask.content = []
    sectionName = tr("Continue Watching")
    if not isValidAndNotEmpty(itemData)
        removeHomeSection(sectionName)
        return
    end if
    sectionName = tr("Continue Watching")

    row = CreateObject("roSGNode", "HomeRow")
    row.title = sectionName
    row.imageWidth = ([
        464
        331
    ])[0]
    row.cursorSize = ([
        464
        331
    ])
    for each item in itemData
        if isValid(item.json) and isValid(item.json.UserData) and isValid(item.json.UserData.PlayedPercentage)
            item.PlayedPercentage = item.json.UserData.PlayedPercentage
        end if
        item.usePoster = row.usePoster
        item.imageWidth = row.imageWidth
        row.appendChild(item)
    end for

    if sectionExists(sectionName)
        m.top.content.replaceChild(row, getSectionIndex(sectionName))
        setRowItemSize()
        return
    end if

    m.top.content.insertChild(row, getOriginalSectionIndex("resume"))
    setRowItemSize()
end sub



sub updateNextUpItems()
    m.processedRowCount++
    itemData = m.LoadNextUpTask.content
    m.LoadNextUpTask.unobserveField("content")
    m.LoadNextUpTask.content = []
    m.LoadNextUpTask.control = "STOP"
    sectionName = tr("Next Up") + " >"
    if not isValidAndNotEmpty(itemData)
        removeHomeSection(sectionName)
        return
    end if

    row = CreateObject("roSGNode", "HomeRow")
    row.title = tr("Next Up") + " >"
    row.imageWidth = ([
        464
        331
    ])[0]
    row.cursorSize = ([
        464
        331
    ])
    for each item in itemData
        item.usePoster = row.usePoster
        item.imageWidth = row.imageWidth
        row.appendChild(item)
    end for

    if sectionExists(sectionName)
        m.top.content.replaceChild(row, getSectionIndex(sectionName))
        setRowItemSize()
        return
    end if

    m.top.content.insertChild(row, getSectionIndex(sectionName))
    setRowItemSize()
end sub




sub updateLatestItems(msg)
    m.processedRowCount++
    itemData = msg.GetData()
    node = msg.getRoSGNode()
    node.unobserveField("content")
    node.content = []
    sectionName = tr("Latest in") + " " + node.metadata.title + " >"
    if not isValidAndNotEmpty(itemData)
        removeHomeSection(sectionName)
        return
    end if
    imagesize = ([
        464
        331
    ])
    if isValid(node.metadata.contentType)
        if LCase(node.metadata.contentType) = "movies"
            imagesize = ([
                180
                331
            ])
        else if LCase(node.metadata.contentType) = "music"
            imagesize = ([
                261
                331
            ])
        end if
    end if

    row = CreateObject("roSGNode", "HomeRow")
    row.title = sectionName
    row.imageWidth = imagesize[0]
    row.cursorSize = imagesize
    row.usePoster = true
    for each item in itemData
        item.usePoster = row.usePoster
        item.imageWidth = row.imageWidth
        row.appendChild(item)
    end for
    if sectionExists(sectionName)

        m.top.content.replaceChild(row, getSectionIndex(sectionName))
        setRowItemSize()
        return
    end if
    m.top.content.insertChild(row, getOriginalSectionIndex("latestmedia"))
    setRowItemSize()
end sub



sub updateOnNowItems()
    m.processedRowCount++
    itemData = m.LoadOnNowTask.content
    m.LoadOnNowTask.unobserveField("content")
    m.LoadOnNowTask.content = []
    sectionName = tr("On Now")
    if not isValidAndNotEmpty(itemData)
        removeHomeSection(sectionName)
        return
    end if

    row = CreateObject("roSGNode", "HomeRow")
    row.title = tr("On Now")
    row.imageWidth = ([
        464
        331
    ])[0]
    row.cursorSize = ([
        464
        331
    ])
    for each item in itemData
        row.usePoster = false
        if (not isValid(item.thumbnailURL) or item.thumbnailURL = "") and isValid(item.json) and isValid(item.json.imageURL)
            item.thumbnailURL = item.json.imageURL
            row.usePoster = true
            row.imageWidth = ([
                180
                331
            ])[0]
            row.cursorSize = ([
                180
                331
            ])
        end if
        item.usePoster = row.usePoster
        item.imageWidth = row.imageWidth
        row.appendChild(item)
    end for

    if sectionExists(sectionName)
        m.top.content.replaceChild(row, getSectionIndex(sectionName))
        setRowItemSize()
        return
    end if

    m.top.content.insertChild(row, getOriginalSectionIndex("livetv"))
    setRowItemSize()
end sub

sub itemSelected()
    m.selectedRowItem = m.top.rowItemSelected
    m.top.selectedItem = m.top.content.getChild(m.top.rowItemSelected[0]).getChild(m.top.rowItemSelected[1])

    m.top.selectedItem = invalid
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        if key = "play"
            print "play was pressed from homerow"
            itemToPlay = m.top.content.getChild(m.top.rowItemFocused[0]).getChild(m.top.rowItemFocused[1])
            if isValid(itemToPlay)
                m.top.quickPlayNode = itemToPlay
            end if
            return true
        else if key = "replay"
            m.top.jumpToRowItem = [
                m.top.rowItemFocused[0]
                0
            ]
            return true
        end if
    end if
    return false
end function

function filterNodeArray(nodeArray as object, nodeKey as string, excludeArray as object) as object
    if excludeArray.IsEmpty() then
        return nodeArray
    end if
    newNodeArray = []
    for each node in nodeArray
        excludeThisNode = false
        for each exclude in excludeArray
            if node[nodeKey] = exclude
                excludeThisNode = true
            end if
        end for
        if excludeThisNode = false
            newNodeArray.Push(node)
        end if
    end for
    return newNodeArray
end function