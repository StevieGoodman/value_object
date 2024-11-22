export type Value<T> = {
	Get: (self: Value<T>) -> T,
	Set: (self: Value<T>, newValue: T) -> nil,
	Changed: RBXScriptSignal,
	Destroy: () -> nil,
}

local Signal = require(script.Parent.Parent.Signal)

local Value = {}

Value.__index = Value

function Value.new<T>(value: T): Value<T>
	local self = {
		_value = value,
		Changed = Signal.new(),
	}
	setmetatable(self, Value)
	return self
end

function Value:Get<T>(): T
	return
		if typeof(self._value) == "table"
		then table.clone(self._value)
		else self._value
end

function Value:Set<T>(newValue: T): nil
	local oldValue = self._value
	self._value = newValue
	if self._value == oldValue then return end
	self.Changed:Fire(self._value, oldValue)
end

function Value:Destroy()
	self.Changed:Destroy()
end

return Value