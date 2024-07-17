

sub init()


    _rLog = log_initializeLogManager([
        "log_PrintTransport"
    ], 5) 'bs:disable-line
end sub




sub OnScreenShown()
    if m.top.lastFocus <> invalid
        m.top.lastFocus.setFocus(true)
    else
        m.top.setFocus(true)
    end if
end sub




sub OnScreenHidden()
end sub