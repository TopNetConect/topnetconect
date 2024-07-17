




sub init()
    m.top.functionName = "loadItems"
end sub

sub loadItems()
    params = {
        maxHeight: 1080
        maxWidth: 1920
    }
    if isValid(m.top.itemNodeContent)
        item = m.top.itemNodeContent
        m.top.results = ImageURL(item.Id, "Primary", params)
    else if isValid(m.top.itemArrayContent)
        item = m.top.itemArrayContent
        m.top.results = ImageURL(item.Id, "Primary", params)
    else
        m.top.results = invalid
    end if
end sub