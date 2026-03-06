local game = require("game")
local editor = require("editor")
Slab = require("Slab")

local menuOptions = {"Start Game", "Options", "Exit"}
local selected = 1

state = "menu" -- Can be "menu", "play", or "edit"

function love.load()
    Slab.Initialize()
    love.window.setTitle("Pendulum Rhythm")
    if state == "play" then
        game.load()
    elseif state == "edit" then
        editor.load()
    end
end

function love.update(dt)
    Slab.Update(dt)
    if state == "play" then
        game.update(dt)
    elseif state == "edit" then
        editor.update(dt)
    end
end

function love.draw()
    if state == "menu" then
        drawMenu()
    elseif state == "play" then
        game.draw()
    elseif state == "edit" then
        editor.draw()
    end
    Slab.Draw()
end

function love.keypressed(key)
    if state =="menu" then 
        if key == "up" then
            selected = selected - 1
            if selected < 1 then selected = #menuOptions end
        elseif key == "down" then
            selected = selected + 1
            if selected > #menuOptions then selected = 1 end
        elseif key == "return" or key == "space" then
            handleMenuSelection()
        end

        if key == "escape" then
            love.event.quit()
        end
    elseif state == "play" then
        game.keypressed(key)
    elseif state == "edit" then
        editor.keypressed(key)
    end
end

function drawMenu()
    love.window.setTitle("Pendulum Rhythm")
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    -- Title
    love.graphics.setFont(love.graphics.newFont(40))
    love.graphics.printf("PENDULUM RHYTHM", 0, height/4, width, "center")

    -- Menu Options
    love.graphics.setFont(love.graphics.newFont(20))
    for i, option in ipairs(menuOptions) do
        if i == selected then
            love.graphics.setColor(1, 0.2, 0.9) -- Pink for selected
            love.graphics.print("> " .. option, width/2 - 50, height/2 + (i * 30))
        else
            love.graphics.setColor(1, 1, 1) -- White for others
            love.graphics.print(option, width/2 - 50, height/2 + (i * 30))
        end
    end
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function handleMenuSelection()
    if selected == 1 then -- Start Game
        state = "play"
        game.load()
    elseif selected == 2 then -- Options
        state = "edit" -- CHANGE  THIS TO "options" WHEN YOU IMPLEMENT OPTIONS
        editor.load() -- REMOVE THIS LINE WHEN YOU IMPLEMENT OPTIONS
    elseif selected == 3 then -- "Exit"
        love.event.quit()
    end
end