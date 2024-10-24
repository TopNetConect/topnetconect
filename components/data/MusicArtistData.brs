



sub setFields()
    json = m.top.json
    m.top.id = json.id
    m.top.favorite = json.UserData.isFavorite
    m.top.Type = "MusicArtist"
    setPoster()
    m.top.title = json.name
end sub

sub setPoster()
    if m.top.image <> invalid
        m.top.posterURL = m.top.image.url
    else

        if m.top.json.ImageTags.Primary <> invalid
            imgParams = {
                "maxHeight": 440
                "maxWidth": 440
            }
            m.top.posterURL = ImageURL(m.top.json.id, "Primary", imgParams)
        else if m.top.json.BackdropImageTags[0] <> invalid
            imgParams = {
                "maxHeight": 440
            }
            m.top.posterURL = ImageURL(m.top.json.id, "Backdrop", imgParams)
        else if m.top.json.ParentThumbImageTag <> invalid and m.top.json.ParentThumbItemId <> invalid
            imgParams = {
                "maxHeight": 440
                "maxWidth": 440
            }
            m.top.posterURL = ImageURL(m.top.json.ParentThumbItemId, "Thumb", imgParams)
        end if

        if m.top.json.BackdropImageTags[0] <> invalid
            imgParams = {
                "maxHeight": 720
                "maxWidth": 1280
            }
            m.top.backdropURL = ImageURL(m.top.json.id, "Backdrop", imgParams)
        end if
    end if
end sub