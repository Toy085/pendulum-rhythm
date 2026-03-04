local game = {}
function game.load()
    centerX = love.graphics.getWidth() / 2
    centerY = love.graphics.getHeight() / 2

    radius = 200
    angle = 0
    speed = 1.5
    
    playerDirection = 1

    clickSound = love.audio.newSource("osu-hit-sound.mp3", "static")
    music = love.audio.newSource("song.mp3", "stream")
    music:play()

    beatmap = {
        {time = 5.0},
        {time = 7.5},
    }

    score = 0
    combo = 0
    hitWindow = 0.3
end

function game.update(dt)
    -- Update game logic here
end

function game.keypressed(key)
    -- Handle game-specific key presses here
end

function game.draw()
    love.graphics.circle("fill", centerX, centerY, 50)
    -- Draw game-specific UI and elements here
end
return game