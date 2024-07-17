


sub init()
    m.top.functionName = "getNextEpisodeTask"
end sub

sub getNextEpisodeTask()
    m.nextEpisodeData = api_shows_GetEpisodes(m.top.showID, {
        UserId: m.global.session.user.id
        StartItemId: m.top.videoID
        Limit: 2
    })
    m.top.nextEpisodeData = m.nextEpisodeData
end sub