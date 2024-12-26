local config = require('src.constants.config')
local Grid = require('src.entities.grid')
local GameState = require('src.states.game_state')
local Serialization = require('src.utils.serialization')
local Renderer = require('src.systems.renderer')
local GameManager = require('src.systems.game_manager')

local gameState
local grid
local gameManager
local renderer

function love.load()
    gameState = GameState:new()
    grid = Grid:new()
    grid:initialize(config.GRID_WIDTH, config.GRID_HEIGHT)
    
    renderer = Renderer:new()
    gameManager = GameManager:new(grid, gameState)
    gameManager:spawnNewPiece()
end

function love.update(dt)
    if gameState.lineClearAnimation.active then
        gameState.lineClearAnimation.timer = gameState.lineClearAnimation.timer + dt
        
        if gameState.lineClearAnimation.timer >= config.ANIMATION_DURATION then
            gameManager:finishLineClearAnimation()
        end
        return
    end

    gameState.dropTimer = gameState.dropTimer + dt
    if gameState.dropTimer >= config.DROP_INTERVAL then
        gameState.dropTimer = 0
        if gameManager:canMove(gameManager.currentPiece.x, gameManager.currentPiece.y + 1) then
            gameManager.currentPiece.y = gameManager.currentPiece.y + 1
        else
            gameManager:lockPiece()
        end
    end
    
    gameState.keyTimer = gameState.keyTimer + dt
end

function love.draw()
    local offsetX = (love.graphics.getWidth() - config.GRID_WIDTH * config.BLOCK_SIZE) / 2
    local offsetY = 20
    
    renderer:drawGrid(grid, gameState, offsetX, offsetY)
    renderer:drawPiece(gameManager.currentPiece, offsetX, offsetY)
    renderer:drawUI(gameState.score)
end

function love.keypressed(key)
    if gameState.keyTimer < config.KEY_REPEAT_DELAY then
        return
    end
    gameState.keyTimer = 0
    
    if key == 'left' and gameManager:canMove(gameManager.currentPiece.x - 1, gameManager.currentPiece.y) then
        gameManager.currentPiece.x = gameManager.currentPiece.x - 1
    elseif key == 'right' and gameManager:canMove(gameManager.currentPiece.x + 1, gameManager.currentPiece.y) then
        gameManager.currentPiece.x = gameManager.currentPiece.x + 1
    elseif key == 'down' and gameManager:canMove(gameManager.currentPiece.x, gameManager.currentPiece.y + 1) then
        gameManager.currentPiece.y = gameManager.currentPiece.y + 1
    elseif key == 'up' then
        local rotatedShape = gameManager.currentPiece:rotate()
        local originalShape = gameManager.currentPiece.shape
        gameManager.currentPiece.shape = rotatedShape
        if not gameManager:canMove(gameManager.currentPiece.x, gameManager.currentPiece.y) then
            gameManager.currentPiece.shape = originalShape
        end
    elseif key == 's' then
        saveGame()
    elseif key == 'l' then
        loadGame()
    end
end

function saveGame()
    local saveData = {
        grid = grid.cells,
        colors = grid.colors,
        currentPiece = gameManager.currentPiece,
        score = gameState.score
    }
    love.filesystem.write("tetris_save.dat", Serialization.serialize(saveData))
end

function loadGame()
    if love.filesystem.getInfo("tetris_save.dat") then
        local content = love.filesystem.read("tetris_save.dat")
        local saveData = Serialization.deserialize(content)
        
        if saveData then
            grid.cells = saveData.grid
            grid.colors = saveData.colors
            gameManager.currentPiece = saveData.currentPiece
            gameState.score = saveData.score
            return true
        end
    end
    return false
end