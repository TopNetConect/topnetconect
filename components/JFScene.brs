

sub init()
    m.top.backgroundColor = "#262626" '"#101010"
    m.top.backgroundURI = ""
    m.spinner = m.top.findNode("spinner")
end sub


sub isLoadingChanged()
    m.spinner.visible = m.top.isLoading
end sub


sub disableRemoteChanged()
    if m.top.disableRemote
        dialog = createObject("roSGNode", "ProgressDialog")
        dialog.id = "invisibiledialog"
        dialog.visible = false
        dialog.opacity = 0
        m.top.dialog = dialog
    else
        if isValid(m.top.dialog)
            m.top.dialog.close = true
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then
        return false
    end if
    if key = "back"
        m.global.sceneManager.callFunc("popScene")
        return true
    else if key = "options"
        group = m.global.sceneManager.callFunc("getActiveScene")
        if isValid(group) and isValid(group.optionsAvailable) and group.optionsAvailable
            group.lastFocus = group.focusedChild
            panel = group.findNode("options")
            panel.visible = true
            panel.findNode("panelList").setFocus(true)
        end if
        return true
    end if
    return false
end function