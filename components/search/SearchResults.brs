





sub init()
    m.top.optionsAvailable = false
    m.searchSelect = m.top.findnode("searchSelect")
    m.searchTask = CreateObject("roSGNode", "SearchTask")

    m.searchHelpText = m.top.findNode("SearchHelpText")
    m.searchHelpText.text = tr("You can search for Titles, People, Live TV Channels and more")
end sub

sub searchMedias()
    query = m.top.searchAlpha

    if query.len() = 0
        stopLoadingSpinner()
    end if

    m.searchTask.control = "stop"
    if query <> invalid and query <> ""
        startLoadingSpinner(false)
    end if
    m.searchTask.observeField("results", "loadResults")
    m.searchTask.query = query
    m.top.overhangTitle = tr("Search") + ": " + query
    m.searchTask.control = "RUN"
end sub

sub loadResults()
    m.searchTask.unobserveField("results")
    stopLoadingSpinner()
    m.searchSelect.itemdata = m.searchTask.results
    m.searchSelect.query = m.top.SearchAlpha
    m.searchHelpText.visible = false
    if m.searchTask.results.TotalRecordCount = 0

        if m.searchSelect.isinFocusChain()
            m.searchAlphabox.setFocus(true)
        end if
        return
    end if
    m.searchAlphabox = m.top.findnode("searchResults")
    m.searchAlphabox.translation = "[470, 85]"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    m.searchAlphabox = m.top.findNode("search_Key")
    if m.searchAlphabox.textEditBox.hasFocus()
        m.searchAlphabox.textEditBox.translation = "[0, -150]"
    else
        m.searchAlphabox.textEditBox.translation = "[0, 0]"
    end if
    if key = "left" and m.searchSelect.isinFocusChain()
        m.searchAlphabox.setFocus(true)
        return true
    else if key = "right" and m.searchSelect.content <> invalid and m.searchSelect.content.getChildCount() > 0
        m.searchSelect.setFocus(true)
        return true
    else if key = "play" and m.searchSelect.isinFocusChain() and m.searchSelect.rowItemFocused.count() > 0
        print "play was pressed from search results"
        if m.searchSelect.rowItemFocused <> invalid
            selectedContent = m.searchSelect.content.getChild(m.searchSelect.rowItemFocused[0])
            if selectedContent <> invalid
                selectedItem = selectedContent.getChild(m.searchSelect.rowItemFocused[1])
                if selectedItem <> invalid
                    m.top.quickPlayNode = selectedItem
                    return true
                end if
            end if
        end if
    end if
    return false
end function