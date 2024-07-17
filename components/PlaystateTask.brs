


sub init()
    m.top.functionName = "PlaystateUpdate"
end sub

sub PlaystateUpdate()
    if m.top.status = "start"
        url = "Sessions/Playing"
    else if m.top.status = "stop"
        url = "Sessions/Playing/Stopped"
    else if m.top.status = "update"
        url = "Sessions/Playing/Progress"
    else

        return
    end if
    params = PlaystateDefaults(m.top.params)
    resp = APIRequest(url)
    postJson(resp, params)
end sub

function PlaystateDefaults(params = {} as object)
    new_params = {









        "IsPaused": false

        "PositionTicks": 0








    }
    paramsArray = params.items()
    for i = 0 to paramsArray.count() - 1
        item = paramsArray[i]
        new_params[item.key] = item.value
    end for
    return FormatJson(new_params)
end function