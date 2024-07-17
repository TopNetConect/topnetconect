





sub setupNodes()
    m.options = m.top.findNode("options")
    m.itemGrid = m.top.findNode("itemGrid")
    m.voiceBox = m.top.findNode("voiceBox")
    m.backdrop = m.top.findNode("backdrop")
    m.newBackdrop = m.top.findNode("backdropTransition")
    m.emptyText = m.top.findNode("emptyText")
    m.selectedMovieName = m.top.findNode("selectedMovieName")
    m.selectedMovieOverview = m.top.findNode("selectedMovieOverview")
    m.selectedMovieProductionYear = m.top.findNode("selectedMovieProductionYear")
    m.selectedMovieOfficialRating = m.top.findNode("selectedMovieOfficialRating")
    m.movieLogo = m.top.findNode("movieLogo")
    m.swapAnimation = m.top.findNode("backroundSwapAnimation")
    m.Alpha = m.top.findNode("AlphaMenu")
    m.AlphaSelected = m.top.findNode("AlphaSelected")
    m.micButton = m.top.findNode("micButton")
    m.micButtonText = m.top.findNode("micButtonText")
    m.communityRatingGroup = m.top.findNode("communityRatingGroup")
    m.criticRatingIcon = m.top.findNode("criticRatingIcon")
    m.criticRatingGroup = m.top.findNode("criticRatingGroup")
    m.overhang = m.top.getScene().findNode("overhang")
    m.genreList = m.top.findNode("genrelist")
    m.infoGroup = m.top.findNode("infoGroup")
    m.star = m.top.findNode("star")
end sub

sub init()
    setupNodes()
    m.overhang.isVisible = false
    m.showItemCount = m.global.session.user.settings["itemgrid.showItemCount"]
    m.swapAnimation.observeField("state", "swapDone")
    m.loadedRows = 0
    m.loadedItems = 0
    m.data = CreateObject("roSGNode", "ContentNode")
    m.itemGrid.content = m.data
    m.genreData = CreateObject("roSGNode", "ContentNode")
    m.genreList.observeField("itemSelected", "onGenreItemSelected")
    m.genreList.content = m.genreData
    m.itemGrid.observeField("itemFocused", "onItemFocused")
    m.itemGrid.observeField("itemSelected", "onItemSelected")
    m.itemGrid.observeField("alphaSelected", "onItemalphaSelected")

    m.voiceBox.voiceEnabled = true
    m.voiceBox.active = true
    m.voiceBox.observeField("text", "onvoiceFilter")

    m.voiceBox.hintText = tr("Use voice remote to search")

    m.newBackdrop.observeField("loadStatus", "newBGLoaded")

    m.queuedBGUri = ""

    m.sortField = "SortName"
    m.sortAscending = true
    m.filter = "All"
    m.filterOptions = {}
    m.favorite = "Favorite"
    m.loadItemsTask = createObject("roSGNode", "LoadItemsTask2")
    m.loadLogoTask = createObject("roSGNode", "LoadItemsTask2")
    m.getFiltersTask = createObject("roSGNode", "GetFiltersTask")

    m.loadItemsTask.totalRecordCount = 0

    m.resetGrid = m.global.session.user.settings["itemgrid.reset"]

    if m.global.device.hasVoiceRemote = false
        m.micButton.visible = false
        m.micButtonText.visible = false
    end if
end sub

sub OnScreenHidden()
    if not m.overhang.isVisible
        m.overhang.disableMoveAnimation = true
        m.overhang.isVisible = true
        m.overhang.disableMoveAnimation = false
    end if
end sub

sub OnScreenShown()
    m.overhang.isVisible = false
    if m.top.lastFocus <> invalid
        m.top.lastFocus.setFocus(true)
    else
        m.top.setFocus(true)
    end if
end sub



sub loadInitialItems()
    m.loadItemsTask.control = "stop"
    startLoadingSpinner(false)
    if m.top.parentItem.json.Type = "CollectionFolder"
        m.top.HomeLibraryItem = m.top.parentItem.Id
    end if
    if m.top.parentItem.backdropUrl <> invalid
        SetBackground(m.top.parentItem.backdropUrl)
    else
        SetBackground("")
    end if
    m.sortField = m.global.session.user.settings["display." + m.top.parentItem.Id + ".sortField"]
    m.filter = m.global.session.user.settings["display." + m.top.parentItem.Id + ".filter"]
    m.filterOptions = m.global.session.user.settings["display." + m.top.parentItem.Id + ".filterOptions"]
    m.view = m.global.session.user.settings["display." + m.top.parentItem.Id + ".landing"]
    m.sortAscending = m.global.session.user.settings["display." + m.top.parentItem.Id + ".sortAscending"]

    if not isValid(m.view)
        m.view = m.global.session.user.settings["itemgrid.movieDefaultView"]
    end if
    if not isValid(m.sortField) then
        m.sortField = "SortName"
    end if
    if not isValid(m.filter) then
        m.filter = "All"
    end if
    if not isValid(m.filterOptions) then
        m.filterOptions = "{}"
    end if
    if not isValid(m.view) then
        m.view = "Movies"
    end if
    if not isValid(m.sortAscending) then
        m.sortAscending = true
    end if
    m.filterOptions = ParseJson(m.filterOptions)
    if m.top.parentItem.json.type = "Studio"
        m.loadItemsTask.studioIds = m.top.parentItem.id
        m.loadItemsTask.itemId = m.top.parentItem.parentFolder
        m.loadItemsTask.genreIds = ""
    else if m.top.parentItem.json.type = "Genre"
        m.loadItemsTask.genreIds = m.top.parentItem.id
        m.loadItemsTask.itemId = m.top.parentItem.parentFolder
        m.loadItemsTask.studioIds = ""
    else if m.view = "Movies" or m.options.view = "Movies"
        m.loadItemsTask.studioIds = ""
        m.loadItemsTask.genreIds = ""
    else
        m.loadItemsTask.itemId = m.top.parentItem.Id
    end if
    m.loadItemsTask.nameStartsWith = m.top.alphaSelected
    m.loadItemsTask.searchTerm = m.voiceBox.text
    m.emptyText.visible = false
    m.loadItemsTask.sortField = m.sortField
    m.loadItemsTask.sortAscending = m.sortAscending
    m.loadItemsTask.filter = m.filter
    m.loadItemsTask.filterOptions = m.filterOptions
    m.loadItemsTask.startIndex = 0

    if getCollectionType() = "movies"
        m.loadItemsTask.itemType = "Movie"
        m.loadItemsTask.itemId = m.top.parentItem.Id
    end if

    m.loadItemsTask.studioIds = ""
    m.loadItemsTask.view = "Movies"
    m.itemGrid.translation = "[96, 650]"
    m.itemGrid.itemSize = "[230, 310]"
    m.itemGrid.rowHeights = "[310]"
    m.itemGrid.numRows = "2"
    m.selectedMovieOverview.visible = true
    m.infoGroup.visible = true
    m.top.showItemTitles = "hidealways"
    if m.options.view = "Studios" or m.view = "Studios"
        m.itemGrid.translation = "[96, 60]"
        m.itemGrid.numRows = "3"
        m.loadItemsTask.view = "Networks"
        m.top.imageDisplayMode = "scaleToFit"
        m.selectedMovieOverview.visible = false
        m.infoGroup.visible = false
    else if LCase(m.options.view) = "moviesgrid" or LCase(m.view) = "moviesgrid"
        m.itemGrid.translation = "[96, 60]"
        m.itemGrid.numRows = "3"
        m.selectedMovieOverview.visible = false
        m.infoGroup.visible = false
        m.top.showItemTitles = m.global.session.user.settings["itemgrid.gridTitles"]
        if LCase(m.top.showItemTitles) = "hidealways"
            m.itemGrid.itemSize = "[230, 315]"
            m.itemGrid.rowHeights = "[315]"
        else
            m.itemGrid.itemSize = "[230, 350]"
            m.itemGrid.rowHeights = "[350]"
        end if
    else if m.options.view = "Genres" or m.view = "Genres"
        m.loadItemsTask.StudioIds = m.top.parentItem.Id
        m.loadItemsTask.view = "Genres"
        m.movieLogo.visible = false
        m.selectedMovieName.visible = false
        m.selectedMovieOverview.visible = false
        m.infoGroup.visible = false
    end if
    m.loadItemsTask.observeField("content", "ItemDataLoaded")
    m.loadItemsTask.control = "RUN"
    m.getFiltersTask.observeField("filters", "FilterDataLoaded")
    m.getFiltersTask.params = {
        userid: m.global.session.user.id
        parentid: m.top.parentItem.Id
        includeitemtypes: "Movie"
    }
    m.getFiltersTask.control = "RUN"
end sub


sub setMoviesOptions(options)
    options.views = [
        {
            "Title": tr("Movies (Presentation)")
            "Name": "Movies"
        }
        {
            "Title": tr("Movies (Grid)")
            "Name": "MoviesGrid"
        }
        {
            "Title": tr("Studios")
            "Name": "Studios"
        }
        {
            "Title": tr("Genres")
            "Name": "Genres"
        }
    ]
    if m.top.parentItem.json.type = "Genre"
        options.views = [
            {
                "Title": tr("Movies (Presentation)")
                "Name": "Movies"
            }
            {
                "Title": tr("Movies (Grid)")
                "Name": "MoviesGrid"
            }
        ]
    end if
    options.sort = [
        {
            "Title": tr("TITLE")
            "Name": "SortName"
        }
        {
            "Title": tr("IMDB_RATING")
            "Name": "CommunityRating"
        }
        {
            "Title": tr("CRITIC_RATING")
            "Name": "CriticRating"
        }
        {
            "Title": tr("DATE_ADDED")
            "Name": "DateCreated"
        }
        {
            "Title": tr("DATE_PLAYED")
            "Name": "DatePlayed"
        }
        {
            "Title": tr("OFFICIAL_RATING")
            "Name": "OfficialRating"
        }
        {
            "Title": tr("PLAY_COUNT")
            "Name": "PlayCount"
        }
        {
            "Title": tr("RELEASE_DATE")
            "Name": "PremiereDate"
        }
        {
            "Title": tr("RUNTIME")
            "Name": "Runtime"
        }
    ]
    options.filter = [
        {
            "Title": tr("All")
            "Name": "All"
        }
        {
            "Title": tr("Favorites")
            "Name": "Favorites"
        }
        {
            "Title": tr("Played")
            "Name": "Played"
        }
        {
            "Title": tr("Unplayed")
            "Name": "Unplayed"
        }
        {
            "Title": tr("Resumable")
            "Name": "Resumable"
        }
    ]
    if m.options.view = "Genres" or m.view = "Genres"
        options.sort = [
            {
                "Title": tr("TITLE")
                "Name": "SortName"
            }
        ]
        options.filter = []
    end if
    if m.options.view = "Studios" or m.view = "Studios"
        options.sort = [
            {
                "Title": tr("TITLE")
                "Name": "SortName"
            }
            {
                "Title": tr("DATE_ADDED")
                "Name": "DateCreated"
            }
        ]
        options.filter = [
            {
                "Title": tr("All")
                "Name": "All"
            }
            {
                "Title": tr("Favorites")
                "Name": "Favorites"
            }
        ]
    end if
end sub


function getCollectionType() as string
    if m.top.parentItem.collectionType = invalid
        return m.top.parentItem.Type
    else
        return m.top.parentItem.CollectionType
    end if
end function


function inStringArray(array, searchValue) as boolean
    for each item in array
        if lcase(item) = lcase(searchValue) then
            return true
        end if
    end for
    return false
end function


sub setSelectedOptions(options)

    for each o in options.views
        if o.Name = m.view
            o.Selected = true
            o.Ascending = m.sortAscending
            m.options.view = o.Name
        end if
    end for

    for each o in options.sort
        if o.Name = m.sortField
            o.Selected = true
            o.Ascending = m.sortAscending
            m.options.sortField = o.Name
        end if
    end for

    for each o in options.filter
        if o.Name = m.filter
            o.Selected = true
            m.options.filter = o.Name
        end if

        if isValid(o.options) and isValid(m.filterOptions)
            if o.options.Count() > 0 and m.filterOptions.Count() > 0
                if LCase(o.Name) = LCase(m.filterOptions.keys()[0])
                    selectedFilterOptions = m.filterOptions[m.filterOptions.keys()[0]].split(o.delimiter)
                    checkedState = []
                    for each availableFilterOption in o.options
                        matchFound = false
                        for each selectedFilterOption in selectedFilterOptions
                            if LCase(toString(availableFilterOption).trim()) = LCase(selectedFilterOption.trim())
                                matchFound = true
                            end if
                        end for
                        checkedState.push(matchFound)
                    end for
                    o.checkedState = checkedState
                end if
            end if
        end if
    end for
    m.options.options = options
end sub



sub FilterDataLoaded(msg)
    options = {}
    options.filter = []
    options.favorite = []
    setMoviesOptions(options)
    data = msg.GetData()
    m.getFiltersTask.unobserveField("filters")
    if not isValid(data) then
        return
    end if

    if LCase(m.loadItemsTask.view) = "movies"
        if isValid(data.genres)
            options.filter.push({
                "Title": tr("Genres")
                "Name": "Genres"
                "Options": data.genres
                "Delimiter": "|"
                "CheckedState": []
            })
        end if
        if isValid(data.OfficialRatings)
            options.filter.push({
                "Title": tr("Parental Ratings")
                "Name": "OfficialRatings"
                "Options": data.OfficialRatings
                "Delimiter": "|"
                "CheckedState": []
            })
        end if
        if isValid(data.Years)
            options.filter.push({
                "Title": tr("Years")
                "Name": "Years"
                "Options": data.Years
                "Delimiter": ","
                "CheckedState": []
            })
        end if
    end if
    setSelectedOptions(options)
    m.options.options = options
end sub



sub LogoImageLoaded(msg)
    data = msg.GetData()
    m.loadLogoTask.unobserveField("content")
    m.loadLogoTask.content = []
    if data.Count() > 0
        m.movieLogo.uri = data[0]
        m.movieLogo.visible = true
    else
        m.selectedMovieName.visible = true
    end if
end sub



sub ItemDataLoaded(msg)
    m.top.alphaActive = false
    itemData = msg.GetData()
    m.loadItemsTask.unobserveField("content")
    m.loadItemsTask.content = []
    if itemData = invalid
        m.Loading = false
        return
    end if
    if m.loadItemsTask.view = "Genres"

        m.genreData.removeChildren(m.genreData.getChildren(-1, 0))
        for each item in itemData
            m.genreData.appendChild(item)
        end for
        m.itemGrid.opacity = "0"
        m.genreList.opacity = "1"
        m.itemGrid.setFocus(false)
        m.genreList.setFocus(true)
        m.loading = false
        stopLoadingSpinner()

        if m.options.visible
            m.options.setFocus(true)
        end if
        return
    end if
    m.itemGrid.opacity = "1"
    m.genreList.opacity = "0"
    m.itemGrid.setFocus(true)
    m.genreList.setFocus(false)
    if m.data.getChildCount() = 0
        m.itemGrid.jumpToItem = 0
    end if
    for each item in itemData
        m.data.appendChild(item)
    end for

    m.loadedItems = m.itemGrid.content.getChildCount()
    m.loadedRows = m.loadedItems / m.itemGrid.numColumns
    m.Loading = false

    if m.loadedItems = 0
        m.selectedMovieOverview.visible = false
        m.infoGroup.visible = false
        m.movieLogo.visible = false
        m.movieLogo.uri = ""
        m.selectedMovieName.visible = false
        SetName("")
        SetOverview("")
        SetOfficialRating("")
        SetProductionYear("")
        setFieldText("runtime", "")
        setFieldText("communityRating", "")
        setFieldText("criticRatingLabel", "")
        m.criticRatingIcon.uri = ""
        m.star.uri = ""
        m.emptyText.text = tr("NO_ITEMS").Replace("%1", m.top.parentItem.Type)
        m.emptyText.visible = true
    end if
    stopLoadingSpinner()

    if m.options.visible
        m.options.setFocus(true)
    end if
end sub



sub SetName(movieName as string)
    m.selectedMovieName.text = movieName
end sub



sub SetOverview(movieOverview as string)
    m.selectedMovieOverview.text = movieOverview
end sub



sub SetOfficialRating(movieOfficialRating as string)
    m.selectedMovieOfficialRating.text = movieOfficialRating
end sub



sub SetProductionYear(movieProductionYear)
    m.selectedMovieProductionYear.text = movieProductionYear
end sub



sub SetBackground(backgroundUri as string)
    if backgroundUri = ""
        m.backdrop.opacity = 0
    end if

    if m.swapAnimation.state <> "stopped" or m.newBackdrop.loadStatus = "loading"
        m.queuedBGUri = backgroundUri
        return
    end if
    m.newBackdrop.uri = backgroundUri
end sub



sub onItemFocused()
    focusedRow = m.itemGrid.currFocusRow
    itemInt = m.itemGrid.itemFocused

    if itemInt = -1
        return
    end if
    m.movieLogo.visible = false
    m.selectedMovieName.visible = false

    if focusedRow >= m.loadedRows - 5 and m.loadeditems < m.loadItemsTask.totalRecordCount
        loadMoreData()
    end if
    m.selectedFavoriteItem = getItemFocused()
    m.communityRatingGroup.visible = false
    m.criticRatingGroup.visible = false
    if not isValid(m.selectedFavoriteItem)
        return
    end if
    if LCase(m.options.view) = "studios" or LCase(m.view) = "studios"
        return
    else if LCase(m.options.view) = "moviesgrid" or LCase(m.view) = "moviesgrid"
        return
    end if
    itemData = m.selectedFavoriteItem.json
    m.star.uri = "pkg:/images/sharp_star_white_18dp.png"
    if isValid(itemData.communityRating)
        setFieldText("communityRating", int(itemData.communityRating * 10) / 10)
        m.communityRatingGroup.visible = true
    end if
    if isValid(itemData.CriticRating)
        setFieldText("criticRatingLabel", itemData.criticRating)
        tomato = "pkg:/images/rotten.png"
        if itemData.CriticRating > 60
            tomato = "pkg:/images/fresh.png"
        end if
        m.criticRatingIcon.uri = tomato
        m.criticRatingGroup.visible = true
    end if
    if isValid(itemData.Name)
        SetName(itemData.Name)
    else
        SetName("")
    end if
    if isValid(itemData.Overview)
        SetOverview(itemData.Overview)
    else
        SetOverview("")
    end if
    if isValid(itemData.ProductionYear)
        SetProductionYear(str(itemData.ProductionYear))
    else
        SetProductionYear("")
    end if
    if type(itemData.RunTimeTicks) = "LongInteger"
        setFieldText("runtime", stri(getRuntime(itemData.RunTimeTicks)) + " mins")
    else
        setFieldText("runtime", "")
    end if
    if isValid(itemData.OfficialRating)
        SetOfficialRating(itemData.OfficialRating)
    else
        SetOfficialRating("")
    end if
    m.loadLogoTask.itemId = itemData.id
    m.loadLogoTask.itemType = "LogoImage"
    m.loadLogoTask.observeField("content", "LogoImageLoaded")
    m.loadLogoTask.control = "RUN"

    SetBackground(m.selectedFavoriteItem.backdropUrl)
end sub

function getRuntime(runTimeTicks) as integer
    return round(runTimeTicks / 600000000.0)
end function

function round(f as float) as integer


    m = int(f)
    n = m + 1
    x = abs(f - m)
    y = abs(f - n)
    if y > x
        return m
    else
        return n
    end if
end function

sub setFieldText(field, value)
    node = m.top.findNode(field)
    if node = invalid or value = invalid then
        return
    end if

    if type(value) = "roInt" or type(value) = "Integer"
        value = str(value)
    else if type(value) = "roFloat" or type(value) = "Float"
        value = str(value)
    else if type(value) <> "roString" and type(value) <> "String"
        value = ""
    end if
    node.text = value
end sub



sub newBGLoaded()

    if m.newBackdrop.loadStatus = "ready"
        m.swapAnimation.control = "start"
    end if
end sub



sub swapDone()
    if m.swapAnimation.state = "stopped"

        m.backdrop.uri = m.newBackdrop.uri
        m.backdrop.opacity = 1
        m.newBackdrop.opacity = 0

        if m.newBackdrop.uri <> m.queuedBGUri and m.queuedBGUri <> ""
            SetBackground(m.queuedBGUri)
            m.queuedBGUri = ""
        end if
    end if
end sub



sub loadMoreData()
    if m.Loading = true then
        return
    end if
    startLoadingSpinner(false)
    m.Loading = true
    m.loadItemsTask.startIndex = m.loadedItems
    m.loadItemsTask.observeField("content", "ItemDataLoaded")
    m.loadItemsTask.control = "RUN"
end sub



sub onItemSelected()
    m.top.selectedItem = m.itemGrid.content.getChild(m.itemGrid.itemSelected)
end sub



function getItemFocused()
    if m.itemGrid.isinFocusChain() and isValid(m.itemGrid.itemFocused)
        return m.itemGrid.content.getChild(m.itemGrid.itemFocused)
    else if m.genreList.isinFocusChain() and isValid(m.genreList.rowItemFocused)
        return m.genreList.content.getChild(m.genreList.rowItemFocused[0]).getChild(m.genreList.rowItemFocused[1])
    end if
    return invalid
end function



sub onGenreItemSelected()
    m.top.selectedItem = m.genreList.content.getChild(m.genreList.rowItemSelected[0]).getChild(m.genreList.rowItemSelected[1])
end sub

sub onItemalphaSelected()
    if m.top.alphaSelected <> ""
        m.loadedRows = 0
        m.loadedItems = 0
        m.data = CreateObject("roSGNode", "ContentNode")
        m.itemGrid.content = m.data
        m.genreData = CreateObject("roSGNode", "ContentNode")
        m.genreList.content = m.genreData
        m.loadItemsTask.searchTerm = ""
        m.VoiceBox.text = ""
        m.loadItemsTask.nameStartsWith = m.alpha.itemAlphaSelected
        loadInitialItems()
    end if
end sub

sub onvoiceFilter()
    if m.VoiceBox.text <> ""
        m.loadedRows = 0
        m.loadedItems = 0
        m.data = CreateObject("roSGNode", "ContentNode")
        m.itemGrid.content = m.data
        m.top.alphaSelected = ""
        m.loadItemsTask.NameStartsWith = " "
        m.loadItemsTask.searchTerm = m.voiceBox.text
        m.loadItemsTask.recursive = true
        loadInitialItems()
    end if
end sub



sub optionsClosed()
    reload = false
    if m.options.sortField <> m.sortField or m.options.sortAscending <> m.sortAscending
        m.sortField = m.options.sortField
        m.sortAscending = m.options.sortAscending
        reload = true
        sortAscendingStr = "true"

        if not m.sortAscending
            sortAscendingStr = "false"
        end if
        set_user_setting("display." + m.top.parentItem.Id + ".sortField", m.sortField)
        set_user_setting("display." + m.top.parentItem.Id + ".sortAscending", sortAscendingStr)
    end if
    if m.options.filter <> m.filter
        m.filter = m.options.filter
        reload = true
        set_user_setting("display." + m.top.parentItem.Id + ".filter", m.options.filter)
    end if
    if not isValid(m.options.filterOptions)
        m.filterOptions = {}
    end if
    if not AssocArrayEqual(m.options.filterOptions, m.filterOptions)
        m.filterOptions = m.options.filterOptions
        reload = true
        set_user_setting("display." + m.top.parentItem.Id + ".filterOptions", FormatJson(m.options.filterOptions))
    end if
    m.view = m.global.session.user.settings["display." + m.top.parentItem.Id + ".landing"]
    if m.options.view <> m.view
        m.view = m.options.view
        set_user_setting("display." + m.top.parentItem.Id + ".landing", m.view)

        m.top.alphaSelected = ""
        m.loadItemsTask.NameStartsWith = " "
        m.loadItemsTask.searchTerm = ""
        m.filter = "All"
        m.filterOptions = {}
        m.sortField = "SortName"
        m.sortAscending = true

        set_user_setting("display." + m.top.parentItem.Id + ".sortField", m.sortField)
        set_user_setting("display." + m.top.parentItem.Id + ".sortAscending", "true")
        set_user_setting("display." + m.top.parentItem.Id + ".filter", m.filter)
        set_user_setting("display." + m.top.parentItem.Id + ".filterOptions", FormatJson(m.filterOptions))
        reload = true
    end if
    if reload
        m.loadedRows = 0
        m.loadedItems = 0
        m.data = CreateObject("roSGNode", "ContentNode")
        m.itemGrid.content = m.data
        loadInitialItems()
    end if
    m.itemGrid.setFocus(m.itemGrid.opacity = 1)
    m.genreList.setFocus(m.genreList.opacity = 1)
end sub

sub onChannelSelected(msg)
    node = msg.getRoSGNode()
    m.top.lastFocus = lastFocusedChild(node)
    if node.watchChannel <> invalid

        m.top.selectedItem = node.watchChannel.clone(false)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then
        return false
    end if
    if key = "left" and m.voiceBox.isinFocusChain()
        m.itemGrid.setFocus(m.itemGrid.opacity = 1)
        m.genreList.setFocus(m.genreList.opacity = 1)
        m.voiceBox.setFocus(false)
    end if
    if key = "options"
        if m.options.visible = true
            m.options.visible = false
            m.top.removeChild(m.options)
            optionsClosed()
        else
            itemSelected = m.selectedFavoriteItem
            if itemSelected <> invalid
                m.options.selectedFavoriteItem = itemSelected
            end if
            m.options.visible = true
            m.top.appendChild(m.options)
            m.options.setFocus(true)
        end if
        return true
    else if key = "back"
        if m.options.visible = true
            m.options.visible = false
            optionsClosed()
            return true
        else
            m.global.sceneManager.callfunc("popScene")
            m.loadItemsTask.control = "stop"
            return true
        end if
    else if key = "play"
        itemToPlay = getItemFocused()
        if itemToPlay <> invalid
            m.top.quickPlayNode = itemToPlay
            return true
        end if
    else if key = "left"
        if m.itemGrid.isinFocusChain()
            m.top.alphaActive = true
            m.itemGrid.setFocus(false)
            alpha = m.alpha.getChild(0).findNode("Alphamenu")
            alpha.setFocus(true)
            return true
        else if m.genreList.isinFocusChain()
            m.top.alphaActive = true
            m.genreList.setFocus(false)
            alpha = m.alpha.getChild(0).findNode("Alphamenu")
            alpha.setFocus(true)
            return true
        end if
    else if key = "right" and m.Alpha.isinFocusChain()
        m.top.alphaActive = false
        m.Alpha.setFocus(false)
        m.Alpha.visible = true
        m.itemGrid.setFocus(m.itemGrid.opacity = 1)
        m.genreList.setFocus(m.genreList.opacity = 1)
        return true
    else if key = "replay" and m.itemGrid.isinFocusChain()
        if m.resetGrid = true
            m.itemGrid.animateToItem = 0
        else
            m.itemGrid.jumpToItem = 0
        end if
        return true
    else if key = "replay" and m.genreList.isinFocusChain()
        if m.resetGrid = true
            m.genreList.animateToItem = 0
        else
            m.genreList.jumpToItem = 0
        end if
        return true
    end if
    if key = "replay"
        m.loadItemsTask.searchTerm = ""
        m.loadItemsTask.nameStartsWith = ""
        m.voiceBox.text = ""
        m.top.alphaSelected = ""
        m.loadItemsTask.filter = "All"
        m.filter = "All"
        m.filterOptions = {}
        m.data = CreateObject("roSGNode", "ContentNode")
        m.itemGrid.content = m.data
        loadInitialItems()
        return true
    end if
    return false
end function