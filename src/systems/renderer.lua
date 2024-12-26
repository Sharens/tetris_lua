utf8 = require("utf8")

local config = require('src.constants.config')

local Renderer = {}

function Renderer:new()
    local renderer = {}
    setmetatable(renderer, self)
    self.__index = self
    return renderer
end

function Renderer:drawGrid(grid, gameState, offsetX, offsetY)
    for y = 1, config.GRID_HEIGHT do
        for x = 1, config.GRID_WIDTH do
            if grid.cells[y][x] == 1 then
                local isAnimatedLine = self:isLineInAnimation(y, gameState)
                
                if isAnimatedLine then
                    local flash = math.sin(gameState.lineClearAnimation.timer * 15) > 0
                    love.graphics.setColor(flash and {1,1,1} or grid.colors[y][x])
                else
                    love.graphics.setColor(grid.colors[y][x])
                end
                
                love.graphics.rectangle('fill', 
                    offsetX + (x-1)*config.BLOCK_SIZE, 
                    offsetY + (y-1)*config.BLOCK_SIZE, 
                    config.BLOCK_SIZE-1, config.BLOCK_SIZE-1)
            end
            
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle('line', 
                offsetX + (x-1)*config.BLOCK_SIZE, 
                offsetY + (y-1)*config.BLOCK_SIZE, 
                config.BLOCK_SIZE-1, config.BLOCK_SIZE-1)
        end
    end
end

function Renderer:drawPiece(piece, offsetX, offsetY)
    love.graphics.setColor(piece.color)
    for y = 1, #piece.shape do
        for x = 1, #piece.shape[y] do
            if piece.shape[y][x] == 1 then
                love.graphics.rectangle('fill', 
                    offsetX + (piece.x + x - 2) * config.BLOCK_SIZE,
                    offsetY + (piece.y + y - 2) * config.BLOCK_SIZE,
                    config.BLOCK_SIZE-1, config.BLOCK_SIZE-1)
            end
        end
    end
end

function Renderer:drawUI(score)
    local texts = {
        {text = "Sterowanie", x = 10, y = 10},
        {text = "Strzalki - poruszanie", x = 10, y = 30},
        {text = "S - zapisz gre", x = 10, y = 50},
        {text = "L - wczytaj gre", x = 10, y = 70},
        {text = "Wynik: " .. score, x = 10, y = 90}
    }
    
    love.graphics.setColor(1, 1, 1)
    for _, item in ipairs(texts) do
        love.graphics.print(item.text, item.x, item.y)
    end
end

function Renderer:isLineInAnimation(y, gameState)
    if gameState.lineClearAnimation.active then
        for _, lineY in ipairs(gameState.lineClearAnimation.lines) do
            if y == lineY then
                return true
            end
        end
    end
    return false
end

return Renderer 