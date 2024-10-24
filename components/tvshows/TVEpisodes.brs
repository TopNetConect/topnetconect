





sub init()
    m.top.optionsAvailable = false
    m.rows = m.top.findNode("picker")
    m.poster = m.top.findNode("seasonPoster")
    m.shuffle = m.top.findNode("shuffle")
    m.extras = m.top.findNode("extras")
    m.tvEpisodeRow = m.top.findNode("tvEpisodeRow")
    m.unplayedCount = m.top.findNode("unplayedCount")
    m.unplayedEpisodeCount = m.top.findNode("unplayedEpisodeCount")
    m.rows.observeField("doneLoading", "updateSeason")
end sub

sub setSeasonLoading()
    m.top.overhangTitle = tr("Loading...")
end sub


sub setExtraButtonVisibility()
    if isValid(m.top.extrasObjects) and isValidAndNotEmpty(m.top.extrasObjects.items)
        m.extras.visible = true
    end if
end sub

sub updateSeason()
    if m.global.session.user.settings["ui.tvshows.disableUnwatchedEpisodeCount"] = false
        if isValid(m.top.seasonData) and isValid(m.top.seasonData.UserData) and isValid(m.top.seasonData.UserData.UnplayedItemCount)
            if m.top.seasonData.UserData.UnplayedItemCount > 0
                m.unplayedCount.visible = true
                m.unplayedEpisodeCount.text = m.top.seasonData.UserData.UnplayedItemCount
            end if
        end if
    end if
    imgParams = {
        "maxHeight": 450
        "maxWidth": 300
    }
    m.poster.uri = ImageURL(m.top.seasonData.Id, "Primary", imgParams)
    m.shuffle.visible = true
    m.top.overhangTitle = m.top.seasonData.SeriesName + " - " + m.top.seasonData.name
end sub


function getFocusedItem() as dynamic
    if not isValid(m.top.focusedChild) or not isValid(m.top.focusedChild.focusedChild)
        return invalid
    end if
    focusedChild = m.top.focusedChild.focusedChild
    if not isValid(focusedChild.content) then
        return invalid
    end if
    m.top.lastFocus = focusedChild
    if isValidAndNotEmpty(focusedChild.rowItemFocused)
        itemToPlay = focusedChild.content.getChild(focusedChild.rowItemFocused[0]).getChild(0)
        if isValid(itemToPlay) and isValidAndNotEmpty(itemToPlay.id)
            return itemToPlay
        end if
    end if
    return invalid
end function


function onKeyEvent(key as string, press as boolean) as boolean
    if key = "left" and m.tvEpisodeRow.hasFocus()
        m.shuffle.setFocus(true)
        return true
    end if
    if key = "right" and (m.shuffle.hasFocus() or m.extras.hasFocus())
        m.tvEpisodeRow.setFocus(true)
        return true
    end if
    if m.extras.visible and key = "up" and m.extras.hasFocus()
        m.shuffle.setFocus(true)
        return true
    end if
    if m.extras.visible and key = "down" and m.shuffle.hasFocus()
        m.extras.setFocus(true)
        return true
    end if
    if key = "OK"
        if m.tvEpisodeRow.isInFocusChain()
            focusedItem = getFocusedItem()
            if isValid(focusedItem)
                m.top.selectedItem = focusedItem
            end if
            return true
        end if
        if m.shuffle.hasFocus()
            episodeList = m.rows.getChild(0).objects.items
            for i = 0 to episodeList.count() - 1
                j = Rnd(episodeList.count() - 1)
                temp = episodeList[i]
                episodeList[i] = episodeList[j]
                episodeList[j] = temp
            end for
            m.global.queueManager.callFunc("set", episodeList)
            m.global.queueManager.callFunc("playQueue")
            return true
        end if
        if m.extras.visible and m.extras.hasFocus()
            if LCase(m.extras.text.trim()) = LCase(tr("Extras"))
                m.extras.text = tr("Episodes")
                m.top.objects = m.top.extrasObjects
            else
                m.extras.text = tr("Extras")
                m.top.objects = m.top.episodeObjects
            end if
        end if
    end if
    if key = "play"
        focusedItem = getFocusedItem()
        if isValid(focusedItem)
            m.top.quickPlayNode = focusedItem
        end if
        return true
    end if
    return false
end function