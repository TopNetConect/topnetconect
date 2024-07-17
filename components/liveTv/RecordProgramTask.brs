



sub init()
    m.log = log_Logger("RecordProgramTask")
    m.top.functionName = "RecordOrCancelProgram"
end sub

sub RecordOrCancelProgram()
    if m.top.programDetails <> invalid

        TimerId = invalid
        if m.top.programDetails.json.TimerId <> invalid and m.top.programDetails.json.TimerId <> ""
            TimerId = m.top.programDetails.json.TimerId
        end if
        if TimerId = invalid

            programId = m.top.programDetails.Id

            url = "LiveTv/Timers/Defaults"
            params = {
                programId: programId
            }
            resp = APIRequest(url, params)
            data = getJson(resp)
            if data <> invalid

                if m.top.recordSeries = true
                    url = "LiveTv/SeriesTimers"
                else
                    url = "LiveTv/Timers"
                end if
                resp = APIRequest(url)
                postJson(resp, FormatJson(data))
                m.top.programDetails.hdSmallIconUrl = "pkg:/images/red.png"
            else

                
            end if
        else

            if m.top.recordSeries = true
                TimerId = m.top.programDetails.json.SeriesTimerId
                url = Substitute("LiveTv/SeriesTimers/{0}", TimerId)
            else
                url = Substitute("LiveTv/Timers/{0}", TimerId)
            end if
            resp = APIRequest(url)
            deleteVoid(resp)
            m.top.programDetails.hdSmallIconUrl = invalid
        end if
    end if
    m.top.recordOperationDone = true
end sub