local beatmap = {}

function beatmap.loadBeatmap(filename)
    local file = io.open(filename, "r")
    if not file then
        print("Could not open beatmap file: " .. filename)
        return nil
    end

    local contents = file:read("*a")
    file:close()

    local success, data = pcall(json.decode, contents)

    if success then
        return data
    else
        print("Error parsing beatmap JSON: " .. data)
        return nil
    end
end

function beatmap.saveBeatmap(filename, beatmapData)
    local file = io.open(filename, "w")

    if not file then
        print("Could not open beatmap file for writing: " .. filename)
        return false
    end

    local content = json.encode(beatmapData)

    file:write(content)
    file:close()

    return true
end

function beatmap.createBeatmap(filename)
    local newData = {
        title = "New Song",
        artist = "Unknown Artist",
        mapper = "Unknown Mapper",
        bpm = 120,
        difficulty = "Easy",
        audio = "",
        image = "",
        previewStart = 0,
        previewDuration = 10,
        beatmapVersion = 1,
        beatmap = {}
    }

    if filename and filename ~= "" then
        beatmap.saveBeatmap(filename, newData)
    end

    return newData
end

return beatmap