export type ValueObject<T> = {
	Get: (self: ValueObject<T>) -> T,
	Set: (self: ValueObject<T>, newValue: T) -> nil,
	Changed: RBXScriptSignal,
	Destroy: () -> nil,
}

local Signal = require(script.Parent.Signal)

local ValueObject = {}

function ValueObject.new<T>(value: T): ValueObject<T>
	local self = {
		_value = value,
		Changed = Signal.new(),
	}
	setmetatable(self, { __index = ValueObject })
	return self
end

function ValueObject:Get<T>(): T
	return self._value
end

function ValueObject:Set<T>(newValue: T): nil
	local oldValue = self._value
	self._value = newValue
	if self._value == oldValue then return end
	self.Changed:Fire(self._value, oldValue)
end

function ValueObject:Destroy()
	self.Changed:Destroy()
end

return ValueObject