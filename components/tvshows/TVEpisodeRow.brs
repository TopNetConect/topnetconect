sub init()
    m.top.itemComponentName = "TVListDetails"
    m.top.content = setData()
    m.top.vertFocusAnimationStyle = "fixedFocusWrap"
    m.top.showRowLabel = [
        false
    ]
    updateSize()
    m.top.setFocus(true)
end sub

sub updateSize()
    m.top.translation = [
        450
        180
    ]
    itemWidth = 1360
    itemHeight = 300
    m.top.visible = true

    m.top.itemSize = [
        itemWidth
        itemHeight
    ]

    m.top.itemSpacing = [
        0
        40
    ]

    m.top.rowItemSize = [
        itemWidth
        itemHeight
    ]

    m.top.rowItemSpacing = [
        20
        0
    ]
end sub

sub setupRows()
    updateSize()
    objects = m.top.objects
    m.top.numRows = objects.items.count()
    m.top.content = setData()
end sub

function setData()
    data = CreateObject("roSGNode", "ContentNode")
    if m.top.objects = invalid

        return data
    end if
    for each item in m.top.objects.items
        row = data.CreateChild("ContentNode")
        row.appendChild(item)
    end for
    m.top.doneLoading = true
    return data
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then
        return false
    end if
    return false
end function