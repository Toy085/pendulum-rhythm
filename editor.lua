local game = require("game")
local editor = {}

function editor.load()
    -- Load editor-specific assets here
    love.window.setTitle("Pendulum Rhythm - Editor Mode")
end

function editor.update(dt)
    -- editor logic here
end

function editor.keypressed(key)
    if key == "p" then
        state = "play"
        game.load()
    end
    -- Handle editor-specific key presses here
end

function editor.draw()
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

return editor