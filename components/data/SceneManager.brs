


sub init()
    m.log = log_Logger("SceneManager")
    m.groups = []
    m.scene = m.top.getScene()
    m.content = m.scene.findNode("content")
    m.overhang = m.scene.findNode("overhang")
end sub



sub pushScene(newGroup)
    currentGroup = m.groups.peek()
    if newGroup <> invalid
        if currentGroup <> invalid

            if currentGroup.focusedChild <> invalid
                focused = currentGroup.focusedChild
                while focused.hasFocus() = false
                    focused = focused.focusedChild
                end while
                currentGroup.lastFocus = focused
                currentGroup.setFocus(false)
            else
                currentGroup.setFocus(false)
            end if
            if currentGroup.isSubType("JFGroup")
                unregisterOverhangData(currentGroup)
            end if
            currentGroup.visible = false
            if currentGroup.isSubType("JFScreen")
                currentGroup.callFunc("OnScreenHidden")
            end if
        end if
        m.groups.push(newGroup)
        if currentGroup <> invalid
            m.content.replaceChild(newGroup, 0)
        else
            m.content.appendChild(newGroup)
        end if
        if newGroup.isSubType("JFScreen")
            newGroup.callFunc("OnScreenShown")
        end if

        if newGroup.isSubType("JFGroup")
            registerOverhangData(newGroup)


            if newGroup.isInFocusChain() = false
                newGroup.setFocus(true)
            end if
        else if newGroup.isSubType("JFVideo")
            newGroup.setFocus(true)
            newGroup.control = "play"
            m.overhang.visible = false
        end if
    else
        currentGroup.focusedChild.setFocus(true)
    end if
end sub



sub popScene()
    group = m.groups.pop()
    if group <> invalid
        if group.isSubType("JFGroup")
            unregisterOverhangData(group)
        else if group.isSubType("JFVideo")

            group.control = "stop"
        end if
        group.visible = false
        if group.isSubType("JFScreen")
            group.callFunc("OnScreenHidden")
        end if
    else

        m.scene.exit = true
    end if
    group = m.groups.peek()
    if group <> invalid
        registerOverhangData(group)
        group.visible = true
        m.content.replaceChild(group, 0)
        if group.isSubType("JFScreen")
            group.callFunc("OnScreenShown")
        else

            if group.lastFocus <> invalid
                group.lastFocus.setFocus(true)
            else
                if group.focusedChild <> invalid
                    group.focusedChild.setFocus(true)
                else
                    group.setFocus(true)
                end if
            end if
        end if
    else

        m.scene.exit = true
    end if
    stopLoadingSpinner()
end sub



function getActiveScene() as object
    return m.groups.peek()
end function



sub clearScenes()
    if m.content <> invalid then
        m.content.removeChildrenIndex(m.content.getChildCount(), 0)
    end if
    for each group in m.groups
        if LCase(group.subtype()) = "jfscreen"
            group.callFunc("OnScreenHidden")
        end if
    end for
    m.groups = []
end sub



sub clearPreviousScene()
    m.groups.pop()
end sub



sub deleteSceneAtIndex(index = 1)
    m.groups.Delete(index)
end sub



sub settings()
    settingsScreen = createObject("roSGNode", "Settings")
    pushScene(settingsScreen)
end sub



sub registerOverhangData(group)
    if group.isSubType("JFGroup")
        if group.overhangTitle <> invalid then
            m.overhang.title = group.overhangTitle
        end if
        if group.optionsAvailable
            m.overhang.showOptions = true
        else
            m.overhang.showOptions = false
        end if
        group.observeField("optionsAvailable", "updateOptions")
        group.observeField("overhangTitle", "updateOverhangTitle")
        if group.overhangVisible
            m.overhang.visible = true
        else
            m.overhang.visible = false
        end if
        group.observeField("overhangVisible", "updateOverhangVisible")
    else if group.isSubType("JFVideo")
        m.overhang.visible = false
    else
        
    end if
end sub



sub unregisterOverhangData(group)
    group.unobserveField("overhangTitle")
end sub



sub updateOverhangTitle(msg)
    m.overhang.title = msg.getData()
end sub



sub updateOptions(msg)
    m.overhang.showOptions = msg.getData()
end sub



sub updateOverhangVisible(msg)
    m.overhang.visible = msg.getData()
end sub



sub updateUser()

    if m.overhang <> invalid then
        m.overhang.currentUser = m.top.currentUser
    end if
end sub



sub resetTime()

    m.overhang.callFunc("resetTime")
end sub



sub userMessage(title as string, message as string)
    dialog = createObject("roSGNode", "StandardMessageDialog")
    dialog.title = title
    dialog.message = message
    dialog.buttons = [
        tr("OK")
    ]
    dialog.observeField("buttonSelected", "dismissDialog")
    m.scene.dialog = dialog
end sub



sub standardDialog(title, message)
    dialog = createObject("roSGNode", "StandardDialog")
    dlgPalette = createObject("roSGNode", "RSGPalette")
    dlgPalette.colors = {
        DialogBackgroundColor: "0x262828FF"
        DialogFocusColor: "0xcececeFF"
        DialogFocusItemColor: "0x202020FF"
        DialogSecondaryTextColor: "0xf8f8f8ff"
        DialogSecondaryItemColor: "#00a4dcFF"
        DialogTextColor: "0xeeeeeeFF"
    }
    dialog.palette = dlgPalette
    dialog.observeField("buttonSelected", "dismissDialog")
    dialog.title = title
    dialog.contentData = message
    dialog.buttons = [
        tr("OK")
    ]
    m.scene.dialog = dialog
end sub



sub radioDialog(title, message)
    dialog = createObject("roSGNode", "RadioDialog")
    dlgPalette = createObject("roSGNode", "RSGPalette")
    dlgPalette.colors = {
        DialogBackgroundColor: "0x262828FF"
        DialogFocusColor: "0xcececeFF"
        DialogFocusItemColor: "0x202020FF"
        DialogSecondaryTextColor: "0xf8f8f8ff"
        DialogSecondaryItemColor: "#00a4dcFF"
        DialogTextColor: "0xeeeeeeFF"
    }
    dialog.palette = dlgPalette
    dialog.observeField("buttonSelected", "dismissDialog")
    dialog.title = title
    dialog.contentData = message
    dialog.buttons = [
        tr("OK")
    ]
    m.scene.dialog = dialog
end sub



sub optionDialog(title, message, buttons)
    m.top.dataReturned = false
    m.top.returnData = invalid
    m.userselection = false
    dialog = createObject("roSGNode", "StandardMessageDialog")
    dlgPalette = createObject("roSGNode", "RSGPalette")
    dlgPalette.colors = {
        DialogBackgroundColor: "0x262828FF"
        DialogFocusColor: "0xcececeFF"
        DialogFocusItemColor: "0x202020FF"
        DialogSecondaryTextColor: "0xf8f8f8ff"
        DialogSecondaryItemColor: "#00a4dcFF"
        DialogTextColor: "0xeeeeeeFF"
    }
    dialog.palette = dlgPalette
    dialog.observeField("buttonSelected", "optionSelected")
    dialog.observeField("wasClosed", "optionClosed")
    dialog.title = title
    dialog.message = message
    dialog.buttons = buttons
    m.scene.dialog = dialog
end sub



sub optionClosed()
    if m.userselection then
        return
    end if
    m.top.returnData = {
        indexSelected: -1
        buttonSelected: ""
    }
    m.top.dataReturned = true
end sub



sub optionSelected()
    m.userselection = true
    m.top.returnData = {
        indexSelected: m.scene.dialog.buttonSelected
        buttonSelected: m.scene.dialog.buttons[m.scene.dialog.buttonSelected]
    }
    m.top.dataReturned = true
    dismissDialog()
end sub



sub dismissDialog()
    m.scene.dialog.close = true
end sub



function isDialogOpen() as boolean
    return m.scene.dialog <> invalid
end function