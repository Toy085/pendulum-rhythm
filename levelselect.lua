local levelselect = {}
local bm = require("beatmap")
local game = require("game")

local isFilePickerOpen = true

function levelselect.load()
    isFilePickerOpen = true
end

function levelselect.update(dt)
    if isFilePickerOpen then
        local Result = Slab.FileDialog({
            Type = 'openfile',
            Filters = {{"*.prbm", "Beatmap Files"}},
            Title = "Select a Beatmap File"
        })

        if Result.Button == "OK" then
            isFilePickerOpen = false
            if Result.Files and #Result.Files > 0 then
                _G.currentMapData = bm.loadBeatmap(Result.Files[1])
                _G.state = "play"
                game.load()
            end
        elseif Result.Button == "Cancel" then
            isFilePickerOpen = false
            local data = bm.loadBeatmap("wei.prbm") 
            if data then
                _G.currentMapData = data
                _G.state = "play"
                game.load()
            else
                _G.state = "menu"
    end
        end
    end
end

function levelselect.draw()

end

function levelselect.keypressed(key)

end

return levelselect