local config = require('src.constants.config')
local Piece = require('src.entities.piece')

local GameManager = {}

function GameManager:new(grid, gameState)
    local manager = {
        grid = grid,
        gameState = gameState,
        currentPiece = nil,
        clickSound = love.audio.newSource("src/sfx/click.mp3", "static")
    }
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function GameManager:spawnNewPiece()
    local pieceIndex = love.math.random(#config.TETROMINOES)
    self.currentPiece = Piece:new(
        config.TETROMINOES[pieceIndex],
        config.PIECE_COLORS[pieceIndex],
        math.floor(config.GRID_WIDTH / 2) - 1,
        1
    )
    
    if not self:canMove(self.currentPiece.x, self.currentPiece.y) then
        love.event.quit()
    end
end

function GameManager:canMove(newX, newY)
    for y = 1, #self.currentPiece.shape do
        for x = 1, #self.currentPiece.shape[y] do
            if self.currentPiece.shape[y][x] == 1 then
                local gridX = newX + x - 1
                local gridY = newY + y - 1
                
                if gridX < 1 or gridX > config.GRID_WIDTH or
                   gridY < 1 or gridY > config.GRID_HEIGHT or
                   self.grid.cells[gridY][gridX] == 1 then
                    return false
                end
            end
        end
    end
    return true
end

function GameManager:lockPiece()
    for y = 1, #self.currentPiece.shape do
        for x = 1, #self.currentPiece.shape[y] do
            if self.currentPiece.shape[y][x] == 1 then
                local gridY = self.currentPiece.y + y - 1
                local gridX = self.currentPiece.x + x - 1
                self.grid.cells[gridY][gridX] = 1
                self.grid.colors[gridY][gridX] = self.currentPiece.color
            end
        end
    end
    
    self.clickSound:play()
    
    if not self:checkLines() then
        self:spawnNewPiece()
    end
end

function GameManager:checkLines()
    local linesToClear = {}
    for y = config.GRID_HEIGHT, 1, -1 do
        if self.grid:isLineFull(y) then
            table.insert(linesToClear, y)
        end
    end
    
    if #linesToClear > 0 then
        self.gameState.lineClearAnimation.active = true
        self.gameState.lineClearAnimation.lines = linesToClear
        self.gameState.lineClearAnimation.timer = 0
        return true
    end
    return false
end

function GameManager:finishLineClearAnimation()
    self.gameState.lineClearAnimation.active = false
    
    local linesCleared = #self.gameState.lineClearAnimation.lines
    for _, lineY in ipairs(self.gameState.lineClearAnimation.lines) do
        for moveY = lineY, 2, -1 do
            for x = 1, config.GRID_WIDTH do
                self.grid.cells[moveY][x] = self.grid.cells[moveY-1][x]
                self.grid.colors[moveY][x] = self.grid.colors[moveY-1][x]
            end
        end
        for x = 1, config.GRID_WIDTH do
            self.grid.cells[1][x] = 0
            self.grid.colors[1][x] = {0, 0, 0}
        end
    end
    
    self.gameState.score = self.gameState.score + (linesCleared * 100)
    self:spawnNewPiece()
end

return GameManager 