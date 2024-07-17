


sub init()
    m.top.functionName = "loadProgramDetails"
end sub

sub loadProgramDetails()
    channelIndex = m.top.ChannelIndex
    programIndex = m.top.ProgramIndex
    params = {
        UserId: m.global.session.user.id
    }
    url = Substitute("LiveTv/Programs/{0}", m.top.programId)
    resp = APIRequest(url, params)
    data = getJson(resp)
    if data = invalid
        m.top.programDetails = {}
        return
    end if
    program = createObject("roSGNode", "ScheduleProgramData")
    program.json = data
    program.channelIndex = channelIndex
    program.programIndex = programIndex
    program.fullyLoaded = true

    if program.json.TimerId <> invalid and program.json.TimerId <> ""



        program.hdSmallIconUrl = "pkg:/images/red.png"
    else
        program.hdSmallIconUrl = invalid
    end if
    m.top.programDetails = program
end sub