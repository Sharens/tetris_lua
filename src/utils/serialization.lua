local Serialization = {}

function Serialization.serialize(o)
    if type(o) == "number" then
        return tostring(o)
    elseif type(o) == "string" then
        return string.format("%q", o)
    elseif type(o) == "boolean" then
        return tostring(o)
    elseif type(o) == "table" then
        local result = "{"
        for k, v in pairs(o) do
            if type(k) == "number" then
                result = result .. "[" .. k .. "]=" .. Serialization.serialize(v) .. ","
            else
                result = result .. "[" .. string.format("%q", k) .. "]=" .. Serialization.serialize(v) .. ","
            end
        end
        return result .. "}"
    else
        error("cannot serialize a " .. type(o))
    end
end

function Serialization.deserialize(str)
    local f = load("return " .. str)
    if f then
        return f()
    end
    return nil
end

return Serialization 