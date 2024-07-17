





sub init()
    m.log = log_Logger("Settings")
    m.top.optionsAvailable = false
    m.userLocation = []
    m.settingsMenu = m.top.findNode("settingsMenu")
    m.settingDetail = m.top.findNode("settingDetail")
    m.settingDesc = m.top.findNode("settingDesc")
    m.path = m.top.findNode("path")
    m.boolSetting = m.top.findNode("boolSetting")
    m.integerSetting = m.top.findNode("integerSetting")
    m.radioSetting = m.top.findNode("radioSetting")
    m.integerSetting.observeField("submit", "onKeyGridSubmit")
    m.integerSetting.observeField("escape", "onKeyGridEscape")
    m.settingsMenu.setFocus(true)
    m.settingsMenu.observeField("itemFocused", "settingFocused")
    m.settingsMenu.observeField("itemSelected", "settingSelected")
    m.boolSetting.observeField("checkedItem", "boolSettingChanged")
    m.radioSetting.observeField("checkedItem", "radioSettingChanged")
    m.postTask = createObject("roSGNode", "PostTask")

    m.configTree = GetConfigTree()
    LoadMenu({
        children: m.configTree
    })
end sub

sub onKeyGridSubmit()
    selectedSetting = m.userLocation.peek().children[m.settingsMenu.itemFocused]
    set_user_setting(selectedSetting.settingName, m.integerSetting.text)
    m.settingsMenu.setFocus(true)
end sub

sub onKeyGridEscape()
    if m.integerSetting.escape = "left" or m.integerSetting.escape = "back"
        m.settingsMenu.setFocus(true)
    end if
end sub

sub LoadMenu(configSection)
    if configSection.children = invalid

        m.userLocation.pop()
        configSection = m.userLocation.peek()
    else
        if m.userLocation.Count() > 0 then
            m.userLocation.peek().selectedIndex = m.settingsMenu.itemFocused
        end if
        m.userLocation.push(configSection)
    end if
    result = CreateObject("roSGNode", "ContentNode")
    for each item in configSection.children
        listItem = result.CreateChild("ContentNode")
        listItem.title = tr(item.title)
        listItem.Description = tr(item.description)
        listItem.id = item.id
    end for
    m.settingsMenu.content = result
    if configSection.selectedIndex <> invalid and configSection.selectedIndex > -1
        m.settingsMenu.jumpToItem = configSection.selectedIndex
    end if

    m.path.text = tr("Settings")
    for each level in m.userLocation
        if level.title <> invalid then
            m.path.text += " / " + tr(level.title)
        end if
    end for
end sub

sub settingFocused()
    selectedSetting = m.userLocation.peek().children[m.settingsMenu.itemFocused]
    m.settingDesc.text = tr(selectedSetting.Description)
    m.top.overhangTitle = tr(selectedSetting.Title)

    m.boolSetting.visible = false
    m.integerSetting.visible = false
    m.radioSetting.visible = false
    if selectedSetting.type = invalid
        return
    else if selectedSetting.type = "bool"
        m.boolSetting.visible = true
        if m.global.session.user.settings[selectedSetting.settingName] = true
            m.boolSetting.checkedItem = 1
        else
            m.boolSetting.checkedItem = 0
        end if
    else if selectedSetting.type = "integer"
        integerValue = m.global.session.user.settings[selectedSetting.settingName].ToStr()
        if isValid(integerValue)
            m.integerSetting.text = integerValue
        end if
        m.integerSetting.visible = true
    else if LCase(selectedSetting.type) = "radio"
        selectedValue = m.global.session.user.settings[selectedSetting.settingName]
        radioContent = CreateObject("roSGNode", "ContentNode")
        itemIndex = 0
        for each item in m.userLocation.peek().children[m.settingsMenu.itemFocused].options
            listItem = radioContent.CreateChild("ContentNode")
            listItem.title = tr(item.title)
            listItem.id = item.id
            if selectedValue = item.id
                m.radioSetting.checkedItem = itemIndex
            end if
            itemIndex++
        end for
        m.radioSetting.content = radioContent
        m.radioSetting.visible = true
    else
        
    end if
end sub

sub settingSelected()
    selectedItem = m.userLocation.peek().children[m.settingsMenu.itemFocused]
    if selectedItem.type <> invalid ' Show setting
        if selectedItem.type = "bool"
            m.boolSetting.setFocus(true)
        end if
        if selectedItem.type = "integer"
            m.integerSetting.setFocus(true)
        end if
        if (selectedItem.type) = "radio"
            m.radioSetting.setFocus(true)
        end if
    else if selectedItem.children <> invalid and selectedItem.children.Count() > 0 ' Show sub menu
        LoadMenu(selectedItem)
        m.settingsMenu.setFocus(true)
    else
        return
    end if
    m.settingDesc.text = m.settingsMenu.content.GetChild(m.settingsMenu.itemFocused).Description
end sub

sub boolSettingChanged()
    if m.boolSetting.focusedChild = invalid then
        return
    end if
    selectedSetting = m.userLocation.peek().children[m.settingsMenu.itemFocused]
    if m.boolSetting.checkedItem
        session_user_settings_Save(selectedSetting.settingName, "true")
        if Left(selectedSetting.settingName, 7) = "global."


            set_setting(selectedSetting.settingName, "true")

            if selectedSetting.settingName = "global.rememberme"
                print "m.global.session.user.id=", m.global.session.user.id
                set_setting("active_user", m.global.session.user.id)
            end if
        else


            set_user_setting(selectedSetting.settingName, "true")
        end if
    else
        session_user_settings_Save(selectedSetting.settingName, "false")
        if Left(selectedSetting.settingName, 7) = "global."


            set_setting(selectedSetting.settingName, "false")

            if selectedSetting.settingName = "global.rememberme"
                unset_setting("active_user")
            end if
        else


            set_user_setting(selectedSetting.settingName, "false")
        end if
    end if
end sub

sub radioSettingChanged()
    if m.radioSetting.focusedChild = invalid then
        return
    end if
    selectedSetting = m.userLocation.peek().children[m.settingsMenu.itemFocused]
    set_user_setting(selectedSetting.settingName, m.radioSetting.content.getChild(m.radioSetting.checkedItem).id)
end sub




sub OnScreenHidden()
    m.postTask.arrayData = getDeviceCapabilities()
    m.postTask.apiUrl = "/Sessions/Capabilities/Full"
    m.postTask.control = "RUN"
    m.postTask.observeField("responseCode", "postFinished")
end sub



sub postFinished()
    m.postTask.unobserveField("responseCode")
    m.postTask.callFunc("empty")
end sub


function isFormInFocus() as boolean
    if isValid(m.settingDetail.focusedChild) or m.radioSetting.hasFocus() or m.boolSetting.hasFocus() or m.integerSetting.hasFocus()
        return true
    end if
    return false
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then
        return false
    end if
    if (key = "back" or key = "left") and m.settingsMenu.focusedChild <> invalid and m.userLocation.Count() > 1
        LoadMenu({})
        return true
    else if (key = "back" or key = "left") and isFormInFocus()
        m.settingsMenu.setFocus(true)
        return true
    end if
    if key = "options"
        m.global.sceneManager.callFunc("popScene")
        return true
    end if
    if key = "right"
        settingSelected()
    end if
    return false
end function