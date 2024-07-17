


sub init()
    m.top.functionName = "getFiltersTask"
end sub

sub getFiltersTask()
    m.filters = api_items_GetFilters(m.top.params)
    m.top.filters = m.filters
end sub