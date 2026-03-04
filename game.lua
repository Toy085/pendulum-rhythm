local game = {}
function game.load()
    centerX = love.graphics.getWidth() / 2
    centerY = love.graphics.getHeight() / 2

    px = 0
    py = 0

    radius = 200
    angle = 0
    playerSpeed = 1.5
    playerDirection = 1

    playerCircleSize = 20

    songTimeAtLastFlip = 0
    angleAtLastFlip = 0

    clickSound = love.audio.newSource("osu-hit-sound.mp3", "static")
    music = love.audio.newSource("song.mp3", "stream")
    music:play()

    beatmap = {
        {time = 5.8},
        {time = 7.0},
        {time = 8.5},
        {time = 9.5},
        {time = 10.0},
        {time = 10.25},
        {time = 11.0},
        {time = 12.0},
        {time = 13.0},
        {time = 15.0},
    }

    score = 0
    combo = 0
    hitWindow = 0.1

    feedbackText = "..."
    feedbackScale = 0
    feedbackAlpha = 0
end

function game.update(dt)
    local currentTime = music:tell()
    local timeSinceFlip = currentTime - songTimeAtLastFlip

    for i = #beatmap, 1, -1 do
        if currentTime > beatmap[i].time + hitWindow then
            table.remove(beatmap, i)
            combo = 0
            feedbackText = "Miss!"
            feedbackScale = 2.5
            feedbackAlpha = 1
        end
    end
    
    angle = angleAtLastFlip + (timeSinceFlip * playerSpeed * playerDirection)

    px = centerX + math.cos(angle) * radius
    py = centerY + math.sin(angle) * radius

    if playerCircleSize > 20 then
        playerCircleSize = playerCircleSize - dt * 40
        if playerCircleSize < 20 then
            playerCircleSize = 20
        end
    end
    if feedbackAlpha > 0 then
        -- Shrink the scale back toward 1
        if feedbackScale > 1 then
            feedbackScale = feedbackScale - dt * 5
        end
        -- Fade out the alpha
        feedbackAlpha = feedbackAlpha - dt * 2 
    end 
end

function game.keypressed(key)
    if key == "escape" then
        if music then music:stop() end
        state = "menu"
    end
    if key == "space" then
        local currentTime = music:tell()
        local hitSomething = false
        local noteIndex = -1

        for i, note in ipairs(beatmap) do
            local timeDifference = math.abs(currentTime - note.time)
            if timeDifference <= hitWindow then
                hitSomething = true
                noteIndex = i
                break
            end
        end

        if hitSomething then
            table.remove(beatmap, noteIndex)
        
            angleAtLastFlip = angle
            songTimeAtLastFlip = music:tell()

            playerDirection = -playerDirection

            score = score + 100
            combo = combo + 1
            feedbackText = "Great!"
            feedbackScale = 2.5
            feedbackAlpha = 1

            local sound = clickSound:clone()
            sound:play()
            playerCircleSize = 25
        else
            combo = 0
            feedbackText = "Too Early!"
            feedbackScale = 2.5
            feedbackAlpha = 1
        end
    end
end

function game.draw()
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

    -- UI
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Combo: " .. combo, 10, 30)
    if feedbackAlpha > 0 then
        love.graphics.setColor(1, 1, 1, feedbackAlpha)
        
        local font = love.graphics.getFont()
        local textWidth = centerX * 2
        local textHeight = font:getHeight()

        -- printf(text, x, y, limit, align, r, sx, sy, ox, oy)
        love.graphics.printf(feedbackText, 0, centerY - 100, textWidth / feedbackScale, "center", 0, feedbackScale, feedbackScale, 0, textHeight / 2)
    end

    -- Notes
    love.graphics.setColor(1, 1, 0) -- Yellow notes
    for i, note in ipairs(beatmap) do
        local timeRemaining = note.time - music:tell()
    
        -- Draw note if it is coming soon (1.5 seconds)
        if timeRemaining > 0 and timeRemaining < 1.5 then
            local noteAngle = angle + (timeRemaining * playerSpeed * playerDirection)
            local nx = centerX + math.cos(noteAngle) * radius
            local ny = centerY + math.sin(noteAngle) * radius

            local alpha = 1 - (timeRemaining / 1.5)
            love.graphics.setColor(1, 1, 0, alpha)
        
            love.graphics.circle("fill", nx, ny, 10)
            love.graphics.setColor(1, 1, 1)
        end
    end
end
return game