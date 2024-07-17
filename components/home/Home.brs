
sub carregarDados()
    ' Exemplo de carregamento de dados
    m.bannerRotativo.uri = "http://exemplo.com/banner.jpg"

    ' Carregar dados para as seções
    m.continueWatching.content = [
        { uri: "http://exemplo.com/thumb1.jpg", title: "Título 1" },
        { uri: "http://exemplo.com/thumb2.jpg", title: "Título 2" }
    ]
    m.recommended.content = [
        { uri: "http://exemplo.com/thumb3.jpg", title: "Título 3" },
        { uri: "http://exemplo.com/thumb4.jpg", title: "Título 4" }
    ]
    m.newReleases.content = [
        { uri: "http://exemplo.com/thumb5.jpg", title: "Título 5" },
        { uri: "http://exemplo.com/thumb6.jpg", title: "Título 6" }
    ]
end sub

sub init()
    m.isFirstRun = true
    m.top.overhangTitle = "Home"
    m.top.optionsAvailable = true
    m.postTask = createObject("roSGNode", "PostTask")
    m.homeRows = m.top.findNode("homeRows")
    m.fadeInFocusBitmap = m.top.findNode("fadeInFocusBitmap")
    if m.global.session.user.settings["ui.home.splashBackground"] = true
        m.backdrop = m.top.findNode("backdrop")
        m.backdrop.uri = buildURL("/Branding/Splashscreen?format=jpg&foregroundLayer=0.15&fillWidth=1280&width=1280&fillHeight=720&height=720&tag=splash")
    end if
end sub

sub refresh()
    m.homeRows.focusBitmapBlendColor = "0xFFFFFFFF"
    m.homeRows.callFunc("updateHomeRows")
end sub

sub loadLibraries()
    m.homeRows.focusBitmapBlendColor = "0xFFFFFF00"
    m.homeRows.callFunc("loadLibraries")
    m.fadeInFocusBitmap.control = "start"
end sub



sub OnScreenShown()
    if isValid(m.top.lastFocus)
        m.top.lastFocus.setFocus(true)
    else
        m.top.setFocus(true)
    end if
    if not m.isFirstRun
        refresh()
    end if

    if m.isFirstRun
        m.isFirstRun = false
        m.postTask.arrayData = getDeviceCapabilities()
        m.postTask.apiUrl = "/Sessions/Capabilities/Full"
        m.postTask.control = "RUN"
        m.postTask.observeField("responseCode", "postFinished")
    end if
end sub



sub postFinished()
    m.postTask.unobserveField("responseCode")
    m.postTask.callFunc("empty")
end sub