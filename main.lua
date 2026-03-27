local game = require("game")
local editor = require("editor")
Slab = require("Slab")
json = require ("json")
local levelselect = require("levelselect")

local menuOptions = {"Start Game", "Options", "Edit Map", "Exit"}
local selected = 1

state = "menu" -- Can be "menu", "play", or "edit"

function love.load()
    Slab.Initialize()
    love.window.setTitle("Pendulum Rhythm")
    if state == "play" then
        game.load()
    elseif state == "edit" then
        editor.load()
    elseif state == "levelselect" then
        levelselect.load()
    end
end

function love.update(dt)
    Slab.Update(dt)
    if state == "play" then
        game.update(dt)
    elseif state == "levelselect" then
        levelselect.update(dt)
    elseif state == "edit" then
        editor.update(dt)
    end
end

function love.draw()
    if state == "menu" then
        drawMenu()
    elseif state == "play" then
        game.draw()
    elseif state == "levelselect" then
        levelselect.draw()
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
    elseif state == "levelselect" then
        levelselect.keypressed(key)
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
        levelselect.load()
        state = "levelselect"
    elseif selected == 2 then
        -- Add options 
    elseif selected == 3 then
        state = "edit" 
        editor.load()
    elseif selected == 4 then -- "Exit"
        love.event.quit()
    end
end