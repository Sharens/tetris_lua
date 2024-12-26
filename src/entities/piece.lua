local Piece = {}

function Piece:new(shape, color, x, y)
    local piece = {
        shape = shape,
        color = color,
        x = x,
        y = y
    }
    setmetatable(piece, self)
    self.__index = self
    return piece
end

function Piece:rotate()
    local newShape = {}
    local size = #self.shape
    
    for i = 1, size do
        newShape[i] = {}
        for j = 1, size do
            newShape[i][j] = self.shape[size - j + 1][i]
        end
    end
    
    return newShape
end

return Piece 