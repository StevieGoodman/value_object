local Value = require(script.Parent.Value)

export type Number = {
	Get: (self: Number) -> number,
	Set: (self: Number, newValue: number) -> nil,
    SetClamp: (self: Number, lowerClamp: number?, upperClamp: number?) -> nil,

	Destroy: () -> nil,

	Changed: RBXScriptSignal,
}

export type NumberType = "Number" | "Integer" | "Percentage"

local Number = {}

function Number.new(value: number?, type: NumberType): Number
	assert(typeof(value) == "number", "Number.new() expects a number or nil for value")
	value = Value.new()
	local self = {
		_value = value,
        _type = type or "Number",
		Changed = value.Changed,
	}
	setmetatable(self, Number)
    self:Set(value or 0)
	return self
end

function Number:Get(): number
	return self._value:Get()
end

function Number:Set(newValue: number): number
    if self._lowerClamp ~= nil then
        newValue = math.max(newValue, self._lowerClamp)
    end
    if self._upperClamp ~= nil then
        newValue = math.min(newValue, self._upperClamp)
    end
    if self._type == "Integer" then
        newValue = math.round(newValue)
    elseif self._type == "Percentage" then
        newValue = math.clamp(newValue, 0, 1)
    end
	self._value:Set(newValue)
    return newValue
end

function Number:SetClamp(lowerClamp: number?, upperClamp: number?): number
    self._lowerClamp = lowerClamp
    self._upperClamp = upperClamp
    self:Set(self:Get())
end

function Number:Destroy()
	self._table:Destroy()
end

function Number:__add(other: number): number
    return self:Get() + other
end

function Number:__sub(other: number): number
    return self:Get() - other
end

function Number:__mul(other: number): number
    return self:Get() * other
end

function Number:__div(other: number): number
    return self:Get() / other
end

function Number:__mod(other: number): number
    return self:Get() % other
end

function Number:__pow(other: number): number
    return self:Get() ^ other
end

function Number:__unm(): number
    return -self:Get()
end

function Number:__eq(other: number): boolean
    return self:Get() == other
end

function Number:__lt(other: number): boolean
    return self:Get() < other
end

function Number:__le(other: number): boolean
    return self:Get() <= other
end

function Number:__tostring(): string
    if self._type == "Number" or self._type == "Integer" then
        local unprocessed = tostring(self:Get())
        local processed = ""
        local decimalIndex = string.find(string.reverse(unprocessed), ".")
        for index, character in string.reverse(unprocessed) do
            local pastDecimal = index > decimalIndex
            local numbersPastDecimal = index - decimalIndex
            if numbersPastDecimal + 1 % 3 == 0 and numbersPastDecimal ~= 1 and pastDecimal then
                processed = `,{processed}`
            end
            processed = `{character}{processed}`
        end
        return processed
    elseif self._type == "Percentage" then
        return `{math.round(self:Get() * 100)}%`
    end
end

function Number:__len()
	return #tostring(self:Get())
end

Number.__index = Number

return Number