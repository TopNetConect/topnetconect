


sub init()
    m.itemPoster = m.top.findNode("itemPoster")
    m.posterText = m.top.findNode("posterText")
    m.title = m.top.findNode("title")
    m.posterText.font.size = 30
    m.title.font.size = 25
    m.backdrop = m.top.findNode("backdrop")
    m.itemPoster.observeField("loadStatus", "onPosterLoadStatusChanged")

    m.topParent = m.top.GetParent().GetParent()
    m.title.visible = false

    if m.topParent.imageDisplayMode <> invalid
        m.itemPoster.loadDisplayMode = m.topParent.imageDisplayMode
    end if
end sub

sub itemContentChanged()
    m.backdrop.blendColor = "#101010"
    m.title.visible = false
    if isValid(m.topParent.showItemTitles)
        if LCase(m.topParent.showItemTitles) = "showalways"
            m.title.visible = true
        end if
    end if
    itemData = m.top.itemContent
    if not isValid(itemData) then
        return
    end if
    m.itemPoster.uri = itemData.PosterUrl
    m.posterText.text = itemData.title
    m.title.text = itemData.title

    if m.itemPoster.loadStatus <> "ready"
        m.backdrop.visible = true
        m.posterText.visible = true
    end if
end sub

sub focusChanged()
    if m.top.itemHasFocus = true
        m.title.repeatCount = -1
    else
        m.title.repeatCount = 0
    end if
    if isValid(m.topParent.showItemTitles)
        if LCase(m.topParent.showItemTitles) = "showonhover"
            m.title.visible = m.top.itemHasFocus
        end if
    end if
end sub


sub onPosterLoadStatusChanged()
    if m.itemPoster.loadStatus = "ready"
        m.backdrop.visible = false
        m.posterText.visible = false
    end if
end sub