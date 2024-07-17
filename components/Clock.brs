

sub init()

    if m.global.session.user.settings["ui.design.hideclock"]
        return
    end if
    m.clockTime = m.top.findNode("clockTime")
    m.currentTimeTimer = m.top.findNode("currentTimeTimer")
    m.dateTimeObject = CreateObject("roDateTime")
    m.currentTimeTimer.observeField("fire", "onCurrentTimeTimerFire")
    m.currentTimeTimer.control = "start"

    m.format = "short-h12"

    if LCase(m.global.device.clockFormat) = "24h"
        m.format = "short-h24"
    end if
end sub



sub onCurrentTimeTimerFire()

    m.dateTimeObject.Mark()

    m.dateTimeObject.ToLocalTime()

    m.clockTime.text = m.dateTimeObject.asTimeStringLoc(m.format)
end sub