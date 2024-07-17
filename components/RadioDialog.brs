

sub init()
    m.contentArea = m.top.findNode("contentArea")
    m.radioOptions = m.top.findNode("radioOptions")
    m.scrollBarColumn = []
    m.top.observeField("contentData", "onContentDataChanged")
    m.top.observeFieldScoped("buttonSelected", "onButtonSelected")
    m.radioOptions.observeField("focusedChild", "onItemFocused")
    m.top.id = "OKDialog"
    m.top.height = 900
end sub


sub onButtonSelected()
    if m.top.buttonSelected = 0
        m.global.sceneManager.returnData = m.top.contentData.data[m.radioOptions.selectedIndex]
    end if
end sub


sub onItemFocused()
    focusedChild = m.radioOptions.focusedChild
    if not isValid(focusedChild) then
        return
    end if
    moveScrollBar()

    if m.scrollBarColumn.count() <> 0
        hightedButtonTranslation = m.radioOptions.focusedChild.translation
        m.radioOptions.translation = [
            m.radioOptions.translation[0]
            -1 * hightedButtonTranslation[1]
        ]
    end if
end sub


sub moveScrollBar()

    if m.scrollBarColumn.count() = 0
        scrollBar = findNodeBySubtype(m.contentArea, "StdDlgScrollbar")
        if scrollBar.count() = 0 or not isValid(scrollBar[0]) or not isValid(scrollBar[0].node)
            return
        end if
        m.scrollBarColumn = findNodeBySubtype(scrollBar[0].node, "Poster")
        if m.scrollBarColumn.count() = 0 or not isValid(m.scrollBarColumn[0]) or not isValid(m.scrollBarColumn[0].node)
            return
        end if
        m.scrollBarThumb = findNodeBySubtype(m.scrollBarColumn[0].node, "Poster")
        if m.scrollBarThumb.count() = 0 or not isValid(m.scrollBarThumb[0]) or not isValid(m.scrollBarThumb[0].node)
            return
        end if
        m.scrollBarThumb[0].node.blendColor = "#444444"

        scrollBar[0].node.observeField("focusedChild", "onScrollBarFocus")

        m.scrollBarColumn[0].node.uri = ""

        scrollbarBackground = createObject("roSGNode", "Rectangle")
        scrollbarBackground.color = "#101010"
        scrollbarBackground.opacity = "0.3"
        scrollbarBackground.width = "30"
        scrollbarBackground.height = m.contentArea.clippingRect.height
        scrollbarBackground.translation = [
            0
            0
        ]
        scrollBar[0].node.insertChild(scrollbarBackground, 0)

        m.scrollAmount = (m.contentArea.clippingRect.height - int(m.scrollBarThumb[0].node.height)) / m.radioOptions.getChildCount()
        m.scrollAmount += m.scrollAmount / m.radioOptions.getChildCount()
    end if
    if not isvalid(m.radioOptions.focusedChild.id) then
        return
    end if
    m.scrollBarColumn[0].node.translation = [
        0
        val(m.radioOptions.focusedChild.id) * m.scrollAmount
    ]
end sub


sub onScrollBarFocus()
    m.radioOptions.setFocus(true)

    m.scrollBarThumb[0].node.blendColor = "#353535"
end sub


sub onItemSelected()
    buttonArea = findNodeBySubtype(m.top, "StdDlgButtonArea")
    if buttonArea.count() <> 0 and isValid(buttonArea[0]) and isValid(buttonArea[0].node)
        buttonArea[0].node.setFocus(true)
    end if
end sub

sub onContentDataChanged()
    i = 0
    for each item in m.top.contentData.data
        cardItem = m.radioOptions.CreateChild("StdDlgActionCardItem")
        cardItem.iconType = "radiobutton"
        cardItem.id = i
        if isValid(item.selected)
            m.radioOptions.selectedIndex = i
        end if
        textLine = cardItem.CreateChild("SimpleLabel")
        textLine.text = item.track.description
        cardItem.observeField("selected", "onItemSelected")
        i++
    end for
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if key = "right"


        return true
    end if
    if not press then
        return false
    end if
    if key = "up"


        if not m.radioOptions.isinFocusChain()
            m.radioOptions.setFocus(true)
            return true
        end if
    end if
    return false
end function