


sub init()
    m.top.functionName = "getShuffleEpisodesTask"
end sub

sub getShuffleEpisodesTask()
    data = api_shows_GetEpisodes(m.top.showID, {
        UserId: m.global.session.user.id
        SortBy: "Random"
        Limit: 200
    })
    m.top.data = data
end sub