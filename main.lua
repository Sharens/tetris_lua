function love.load()
    -- Zwiększone wymiary planszy i bloków
    blockSize = 35
    gridWidth = 12
    gridHeight = 22
    grid = {}
    colors = {}  -- Przechowuje kolory bloków na planszy
    
    -- Timer dla automatycznego opadania
    dropTimer = 0
    dropInterval = 0.5  -- Czas w sekundach między automatycznym opadaniem
    
    -- Kolory dla różnych klocków
    pieceColors = {
        {1, 0, 0},    -- Czerwony
        {0, 1, 0},    -- Zielony
        {0, 0, 1},    -- Niebieski
        {1, 1, 0}     -- Żółty
    }
    
    -- Inicjalizacja pustej planszy
    for y = 1, gridHeight do
        grid[y] = {}
        colors[y] = {}
        for x = 1, gridWidth do
            grid[y][x] = 0
            colors[y][x] = {0, 0, 0}
        end
    end
    
    -- Definicje klocków (tetrimino)
    tetrominoes = {
        -- I-klocek
        {
            {0,0,0,0},
            {1,1,1,1},
            {0,0,0,0},
            {0,0,0,0}
        },
        -- L-klocek
        {
            {1,0,0},
            {1,1,1},
            {0,0,0}
        },
        -- Kwadrat
        {
            {1,1},
            {1,1}
        },
        -- T-klocek
        {
            {0,1,0},
            {1,1,1},
            {0,0,0}
        }
    }
    
    -- Aktualny klocek
    currentPiece = nil
    currentX = 4
    currentY = 1
    
    currentPieceColor = {1, 0, 0}
    spawnNewPiece()
    
    -- Dodaj zmienną dla opóźnienia powtarzania klawiszy
    keyRepeatDelay = 0.15  -- czas w sekundach
    keyTimer = 0
end 

function love.update(dt)
    -- Dodanie timera dla automatycznego opadania
    dropTimer = dropTimer + dt
    if dropTimer >= dropInterval then
        dropTimer = 0
        if canMove(currentX, currentY + 1) then
            currentY = currentY + 1
        else
            lockPiece()
            clearLines()
            spawnNewPiece()
        end
    end
    
    -- Aktualizacja timera klawiszy
    keyTimer = keyTimer + dt
end 

function love.draw()
    -- Przesunięcie planszy na środek ekranu
    local offsetX = (love.graphics.getWidth() - gridWidth * blockSize) / 2
    local offsetY = 20
    
    -- Rysowanie siatki i zablokowanych klocków
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            if grid[y][x] == 1 then
                love.graphics.setColor(colors[y][x])
                love.graphics.rectangle('fill', 
                    offsetX + (x-1)*blockSize, 
                    offsetY + (y-1)*blockSize, 
                    blockSize-1, blockSize-1)
            end
            -- Rysowanie siatki
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle('line', 
                offsetX + (x-1)*blockSize, 
                offsetY + (y-1)*blockSize, 
                blockSize-1, blockSize-1)
        end
    end
    
    -- Rysowanie aktualnego klocka
    love.graphics.setColor(currentPieceColor)
    drawPiece(offsetX, offsetY)
end 

-- Funkcje pomocnicze
function spawnNewPiece()
    local pieceIndex = love.math.random(#tetrominoes)
    currentPiece = tetrominoes[pieceIndex]
    currentPieceColor = pieceColors[pieceIndex]
    currentX = math.floor(gridWidth / 2) - 1
    currentY = 1
    
    if not canMove(currentX, currentY) then
        love.event.quit()
    end
end

function canMove(newX, newY)
    for y = 1, #currentPiece do
        for x = 1, #currentPiece[y] do
            if currentPiece[y][x] == 1 then
                local gridX = newX + x - 1
                local gridY = newY + y - 1
                
                if gridX < 1 or gridX > gridWidth or
                   gridY < 1 or gridY > gridHeight or
                   grid[gridY][gridX] == 1 then
                    return false
                end
            end
        end
    end
    return true
end

function lockPiece()
    for y = 1, #currentPiece do
        for x = 1, #currentPiece[y] do
            if currentPiece[y][x] == 1 then
                local gridY = currentY + y - 1
                local gridX = currentX + x - 1
                grid[gridY][gridX] = 1
                colors[gridY][gridX] = currentPieceColor
            end
        end
    end
end

function clearLines()
    for y = gridHeight, 1, -1 do
        local complete = true
        for x = 1, gridWidth do
            if grid[y][x] == 0 then
                complete = false
                break
            end
        end
        
        if complete then
            for moveY = y, 2, -1 do
                for x = 1, gridWidth do
                    grid[moveY][x] = grid[moveY-1][x]
                end
            end
            -- Wyczyść górny wiersz
            for x = 1, gridWidth do
                grid[1][x] = 0
            end
        end
    end
end

function drawPiece(offsetX, offsetY)
    for y = 1, #currentPiece do
        for x = 1, #currentPiece[y] do
            if currentPiece[y][x] == 1 then
                love.graphics.rectangle('fill', 
                    offsetX + (currentX + x - 2) * blockSize,
                    offsetY + (currentY + y - 2) * blockSize,
                    blockSize-1, blockSize-1)
            end
        end
    end
end 

-- Dodaj nową funkcję dla obsługi pojedynczego wciśnięcia klawisza
function love.keypressed(key)
    if keyTimer < keyRepeatDelay then
        return
    end
    keyTimer = 0
    
    if key == 'left' then
        if canMove(currentX - 1, currentY) then
            currentX = currentX - 1
        end
    elseif key == 'right' then
        if canMove(currentX + 1, currentY) then
            currentX = currentX + 1
        end
    elseif key == 'down' then
        if canMove(currentX, currentY + 1) then
            currentY = currentY + 1
        end
    elseif key == 'up' then
        rotatePiece()
    end
end 