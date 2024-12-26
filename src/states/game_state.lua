local GameState = {}

function GameState:new()
    local state = {
        score = 0,
        dropTimer = 0,
        keyTimer = 0,
        lineClearAnimation = {
            active = false,
            lines = {},
            timer = 0
        }
    }
    setmetatable(state, self)
    self.__index = self
    return state
end

return GameState 