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
    initializeGrid()
    
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
    currentPieceIndex = 1
    score = 0
    
    -- Załaduj efekt dźwiękowy
    clickSound = love.audio.newSource("src/sfx/click.mp3", "static")
    
    spawnNewPiece()
    
    -- Dodaj zmienną dla opóźnienia powtarzania klawiszy
    keyRepeatDelay = 0.15  -- czas w sekundach
    keyTimer = 0
end

function initializeGrid()
    for y = 1, gridHeight do
        grid[y] = {}
        colors[y] = {}
        for x = 1, gridWidth do
            grid[y][x] = 0
            colors[y][x] = {0, 0, 0}
        end
    end
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
    
    -- Rysowanie informacji o sterowaniu
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Sterowanie:", 10, 10)
    love.graphics.print("Strzałki - poruszanie", 10, 30)
    love.graphics.print("S - zapisz grę", 10, 50)
    love.graphics.print("L - wczytaj grę", 10, 70)
end

function spawnNewPiece()
    currentPieceIndex = love.math.random(#tetrominoes)
    currentPiece = tetrominoes[currentPieceIndex]
    currentPieceColor = pieceColors[currentPieceIndex]
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
    
    -- Odtwórz dźwięk lądowania
    clickSound:play()
end

function clearLines()
    local linesCleared = 0
    for y = gridHeight, 1, -1 do
        local complete = true
        for x = 1, gridWidth do
            if grid[y][x] == 0 then
                complete = false
                break
            end
        end
        
        if complete then
            linesCleared = linesCleared + 1
            -- Przesuń wszystkie wiersze w dół
            for moveY = y, 2, -1 do
                for x = 1, gridWidth do
                    grid[moveY][x] = grid[moveY-1][x]
                    colors[moveY][x] = colors[moveY-1][x]
                end
            end
            -- Wyczyść górny wiersz
            for x = 1, gridWidth do
                grid[1][x] = 0
                colors[1][x] = {0, 0, 0}
            end
            y = y + 1  -- Sprawdź ten sam wiersz ponownie
        end
    end
    
    if linesCleared > 0 then
        score = score + (linesCleared * 100)  -- Dodaj punkty za wyczyszczone linie
    end
end

function rotatePiece()
    local newPiece = {}
    local size = #currentPiece
    
    -- Stwórz nową tablicę dla obroconego klocka
    for i = 1, size do
        newPiece[i] = {}
        for j = 1, size do
            newPiece[i][j] = currentPiece[size - j + 1][i]
        end
    end
    
    -- Sprawdź, czy obrócony klocek nie koliduje z innymi
    local originalPiece = currentPiece
    currentPiece = newPiece
    
    if not canMove(currentX, currentY) then
        currentPiece = originalPiece  -- Jeśli koliduje, cofnij obrót
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

function saveGame()
    local saveData = {
        grid = grid,
        colors = colors,
        currentPiece = currentPiece,
        currentX = currentX,
        currentY = currentY,
        currentPieceColor = currentPieceColor,
        currentPieceIndex = currentPieceIndex,
        score = score
    }
    
    local serializedData = serialize(saveData)
    love.filesystem.write("tetris_save.dat", serializedData)
end

function loadGame()
    if love.filesystem.getInfo("tetris_save.dat") then
        local content = love.filesystem.read("tetris_save.dat")
        local saveData = deserialize(content)
        
        if saveData then
            -- Przywracanie stanu gry
            grid = saveData.grid
            colors = saveData.colors
            currentPiece = saveData.currentPiece
            currentX = saveData.currentX
            currentY = saveData.currentY
            currentPieceColor = saveData.currentPieceColor
            currentPieceIndex = saveData.currentPieceIndex
            score = saveData.score
            return true
        end
    end
    return false
end

function serialize(data)
    local serialized = "return {"
    
    -- Zapisz planszę
    serialized = serialized .. "grid={"
    for y = 1, #data.grid do
        serialized = serialized .. "{"
        for x = 1, #data.grid[y] do
            serialized = serialized .. data.grid[y][x] .. ","
        end
        serialized = serialized .. "},"
    end
    serialized = serialized .. "},"
    
    -- Zapisz kolory
    serialized = serialized .. "colors={"
    for y = 1, #data.colors do
        serialized = serialized .. "{"
        for x = 1, #data.colors[y] do
            serialized = serialized .. "{"
            for i = 1, 3 do
                serialized = serialized .. data.colors[y][x][i] .. ","
            end
            serialized = serialized .. "},"
        end
        serialized = serialized .. "},"
    end
    serialized = serialized .. "},"
    
    -- Zapisz aktualny klocek
    serialized = serialized .. "currentPiece={"
    for y = 1, #data.currentPiece do
        serialized = serialized .. "{"
        for x = 1, #data.currentPiece[y] do
            serialized = serialized .. data.currentPiece[y][x] .. ","
        end
        serialized = serialized .. "},"
    end
    serialized = serialized .. "},"
    
    -- Zapisz pozostałe dane
    serialized = serialized .. string.format(
        "currentX=%d,currentY=%d,currentPieceColor={%f,%f,%f},currentPieceIndex=%d,score=%d",
        data.currentX, data.currentY,
        data.currentPieceColor[1], data.currentPieceColor[2], data.currentPieceColor[3],
        data.currentPieceIndex,
        data.score or 0
    )
    
    serialized = serialized .. "}"
    return serialized
end

function deserialize(str)
    local chunk = load(str)
    if chunk then
        return chunk()
    end
    return nil
end

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
    elseif key == 's' then
        saveGame()
    elseif key == 'l' then
        loadGame()
    end
end