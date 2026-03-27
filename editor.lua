local game = require("game")
local editor = {}
local bm = require("beatmap")

local isFilePickerOpen = false
local showSongInfoWindow = false

local menuOptions = {"Load Beatmap", "Create Beatmap", "Back to Menu"}
local selected = 1
local width = love.graphics.getWidth()
local height = love.graphics.getHeight()

function editor.load()
    -- Load editor-specific assets here
    love.window.setTitle("Pendulum Rhythm - Editor Mode")
end

function editor.update(dt)
    -- File picker for loading beatmaps
    if isFilePickerOpen then
        local Result = Slab.FileDialog({
            Type = 'openfile',
            Filters = {{"*.prbm", "Beatmap Files"}},
            Title = "Select a Beatmap File"
        })

        if Result.Button == "OK" then
            isFilePickerOpen = false
            if Result.Files and #Result.Files > 0 then
                _G.currentBeatmap = bm.loadBeatmap(Result.Files[1])
            end
        elseif Result.Button == "Cancel" then
            isFilePickerOpen = false
        end
    end
    if isFilePickerOpenSave then
        local Result = Slab.FileDialog({
            Type = 'savefile',
            Filters = {{"*.prbm", "Beatmap Files"}},
            Title = "Create a Beatmap File"
        })

        if Result.Button == "OK" then
            isFilePickerOpenSave = false
            if Result.Files and #Result.Files > 0 then
                showSongInfoWindow = true
            end
        elseif Result.Button == "Cancel" then
            isFilePickerOpenSave = false
        end
    end
end

function editor.handleMenuSelection()
    if selected == 1 then
        isFilePickerOpen = true
    elseif selected == 2 then
        -- isFilePickerOpenSave = true
        showSongInfoWindow = true
    elseif selected == 3 then -- "Exit"
        _G.state = "menu"
    end
end

function editor.keypressed(key)
    if key == "p" then
        _G.state = "play"
        game.load()
    end
    if key == "up" then
            selected = selected - 1
            if selected < 1 then selected = #menuOptions end
        elseif key == "down" then
            selected = selected + 1
            if selected > #menuOptions then selected = 1 end
        elseif key == "return" or key == "space" then
            editor.handleMenuSelection()
        end
end


function editor.draw()
     love.graphics.setFont(love.graphics.newFont(20))
    for i, option in ipairs(menuOptions) do
        if i == selected then
            love.graphics.setColor(1, 0.2, 0.9) -- Pink for selected
            love.graphics.print("> " .. option, width/2, height/2 + (i * 30))
        else
            love.graphics.setColor(1, 1, 1) -- White for others
            love.graphics.print(option, width/2, height/2 + (i * 30))
        end
    end

    if showSongInfoWindow then
        drawEditorSongInfo()
    end
end

function drawEditorUI()
    if not centerX then 
        game.load()
        love.window.setTitle("Pendulum Rhythm - Editor Mode")
        return
    end
    love.graphics.setColor(1, 1, 1) -- Reset color
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Editor Mode - Press 'P' to switch to Play Mode", 10, 10)
    
    -- Orbit circle
    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", centerX, centerY, radius)

    -- Player
    love.graphics.setColor(1, 0, 0, 0.85)
    love.graphics.circle("fill", px, py, playerCircleSize)

    -- Pendulum arm
    love.graphics.setLineWidth(5)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.line(centerX, centerY, px, py)
    -- Reset line width
    love.graphics.setLineWidth(1)
end

function drawEditorSongInfo()
    Slab.BeginWindow("Song Info", {Title = "Song Information", AutoSizeWindow = true, Draggable = true, Resizable = true})
    Slab.Input("Song Name", {Text = _G.currentBeatmap and _G.currentBeatmap.title or ""})
    Slab.Input("Artist", {Text = _G.currentBeatmap and _G.currentBeatmap.artist or ""})
    Slab.Input("Difficulty", {Text = _G.currentBeatmap and _G.currentBeatmap.difficulty or ""})
    Slab.EndWindow()
end

return editor