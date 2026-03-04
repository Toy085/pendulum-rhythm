local editor = {}
function editor.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Editor Mode - Press 'P' to switch to Play Mode", 10, 10)
    -- Draw editor-specific UI and elements here
end

return editor