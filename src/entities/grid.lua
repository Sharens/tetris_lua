local Grid = {}

function Grid:new()
    local grid = {
        cells = {},
        colors = {}
    }
    setmetatable(grid, self)
    self.__index = self
    return grid
end

function Grid:initialize(width, height)
    for y = 1, height do
        self.cells[y] = {}
        self.colors[y] = {}
        for x = 1, width do
            self.cells[y][x] = 0
            self.colors[y][x] = {0, 0, 0}
        end
    end
end

function Grid:isLineFull(y)
    for x = 1, #self.cells[y] do
        if self.cells[y][x] == 0 then
            return false
        end
    end
    return true
end

return Grid 