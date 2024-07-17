



sub init()
    m.log = log_Logger("GridItem")
    m.posterMask = m.top.findNode("posterMask")
    m.itemPoster = m.top.findNode("itemPoster")
    m.itemIcon = m.top.findNode("itemIcon")
    m.posterText = m.top.findNode("posterText")
    m.itemText = m.top.findNode("itemText")
    m.backdrop = m.top.findNode("backdrop")
    m.itemPoster.observeField("loadStatus", "onPosterLoadStatusChanged")
    m.unplayedCount = m.top.findNode("unplayedCount")
    m.unplayedEpisodeCount = m.top.findNode("unplayedEpisodeCount")
    m.itemText.translation = [
        0
        m.itemPoster.height + 7
    ]
    m.gridTitles = m.global.session.user.settings["itemgrid.gridTitles"]
    m.itemText.visible = m.gridTitles = "showalways"

    if m.itemText.visible then
        m.itemText.maxWidth = 250
    end if

    m.topParent = m.top.GetParent().GetParent()

    if isValid(m.topParent.imageDisplayMode)
        m.itemPoster.loadDisplayMode = m.topParent.imageDisplayMode
    end if
end sub

sub itemContentChanged()

    posterBackgrounds = m.global.constants.poster_bg_pallet
    m.backdrop.blendColor = posterBackgrounds[rnd(posterBackgrounds.count()) - 1]
    itemData = m.top.itemContent
    if itemData = invalid then
        return
    end if
    if itemData.type = "Movie"
        m.itemPoster.uri = itemData.PosterUrl
        m.itemIcon.uri = itemData.iconUrl
        m.itemText.text = itemData.Title
    else if itemData.type = "Series"
        if m.global.session.user.settings["ui.tvshows.disableUnwatchedEpisodeCount"] = false
            if isValid(itemData.json) and isValid(itemData.json.UserData) and isValid(itemData.json.UserData.UnplayedItemCount)
                if itemData.json.UserData.UnplayedItemCount > 0
                    m.unplayedCount.visible = true
                    m.unplayedEpisodeCount.text = itemData.json.UserData.UnplayedItemCount
                else
                    m.unplayedCount.visible = false
                    m.unplayedEpisodeCount.text = ""
                end if
            end if
        end if
        m.itemPoster.uri = itemData.PosterUrl
        m.itemIcon.uri = itemData.iconUrl
        m.itemText.text = itemData.Title
    else if itemData.type = "Boxset"
        m.itemPoster.uri = itemData.PosterUrl
        m.itemIcon.uri = itemData.iconUrl
        m.itemText.text = itemData.Title
    else if itemData.type = "TvChannel"
        m.itemPoster.uri = itemData.PosterUrl
        m.itemIcon.uri = itemData.iconUrl
        m.itemText.text = itemData.Title
    else if itemData.type = "Folder"
        m.itemPoster.uri = itemData.PosterUrl

        m.itemText.text = itemData.Title
        m.itemPoster.loadDisplayMode = m.topParent.imageDisplayMode
    else if itemData.type = "Video"
        m.itemPoster.uri = itemData.PosterUrl
        m.itemIcon.uri = itemData.iconUrl
        m.itemText.text = itemData.Title
    else if itemData.type = "Playlist"
        m.itemPoster.uri = itemData.PosterUrl
        m.itemIcon.uri = itemData.iconUrl
        m.itemText.text = itemData.Title
    else if itemData.type = "Photo"
        m.itemPoster.uri = itemData.PosterUrl
        m.itemIcon.uri = itemData.iconUrl
        m.itemText.text = itemData.Title
    else if itemData.type = "Episode"
        m.itemPoster.uri = itemData.PosterUrl
        m.itemIcon.uri = itemData.iconUrl
        if isValid(itemData.json) and isValid(itemData.json.SeriesName)
            m.itemText.text = itemData.json.SeriesName + " - " + itemData.Title
        else
            m.itemText.text = itemData.Title
        end if
    else if itemData.type = "MusicArtist"
        m.itemPoster.uri = itemData.PosterUrl
        m.itemText.text = itemData.Title
        m.itemPoster.height = 290
        m.itemPoster.width = 290
        m.itemText.translation = [
            0
            m.itemPoster.height + 7
        ]
        m.backdrop.height = 290
        m.backdrop.width = 290
        m.posterText.height = 200
        m.posterText.width = 280
    else if isValid(itemData.json.type) and itemData.json.type = "MusicAlbum"
        m.itemPoster.uri = itemData.PosterUrl
        m.itemText.text = itemData.Title
        m.itemPoster.height = 290
        m.itemPoster.width = 290
        m.itemText.translation = [
            0
            m.itemPoster.height + 7
        ]
        m.backdrop.height = 290
        m.backdrop.width = 290
        m.posterText.height = 200
        m.posterText.width = 280
    else
        
    end if

    if m.itemPoster.loadStatus <> "ready"
        m.backdrop.visible = true
        m.posterText.visible = true
    end if
    m.posterText.text = m.itemText.text
end sub



sub focusChanging()
    scaleFactor = 0.85 + (m.top.focusPercent * 0.15)
    m.posterMask.scale = [
        scaleFactor
        scaleFactor
    ]
end sub



sub focusChanged()
    if m.top.itemHasFocus = true
        m.itemText.repeatCount = -1
        m.posterMask.scale = [
            1
            1
        ]
    else
        m.itemText.repeatCount = 0
        if m.topParent.alphaActive = true
            m.posterMask.scale = [
                0.85
                0.85
            ]
        end if
    end if
    if m.gridTitles = "showonhover"
        m.itemText.visible = m.top.itemHasFocus
    end if
end sub


sub onPosterLoadStatusChanged()
    if m.itemPoster.loadStatus = "ready"
        m.backdrop.visible = false
        m.posterText.visible = false
    end if
end sub