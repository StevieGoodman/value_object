local Signal = require(script.Parent.Parent.Signal)
local TableUtil = require(script.Parent.Parent.TableUtil)
local Value = require(script.Parent.Value)

export type Table<T> = {
	Get: (self: Table<T>) -> {T},
	Set: (self: Table<T>, newValue: table) -> nil,
	Insert: (self: Table<T>, value: any, index: number?) -> number,
	Remove: (self: Table<T>, index: number) -> any,
	Clear: (self: Table<T>) -> nil,
	Find: (self: Table<T>, value: any) -> number?,
	Has: (self: Table<T>, value: any) -> boolean,
	Sort: (self: Table<T>, comparator: (a: any, b: any) -> boolean) -> nil,
	ToString: (self: Table<T>, separator: string, startingIndex: number?, endingIndex: number?) -> string,
	Unpack: (self: Table<T>, startingIndex: number?, endingIndex: number?) -> {T},
	Every: (self: Table<T>, callback: (value: any, index: number, tbl: table) -> boolean) -> boolean,
	Some: (self: Table<T>, callback: (value: any, index: number, tbl: table) -> boolean) -> boolean,
	Map: (self: Table<T>, callback: (value: any, index: number, tbl: table) -> any) -> {any},
	Reduce: (self: Table<T>, callback: (accumulator: any, value: any, index: number) -> any, initialValue: any?) -> any,
	Reverse: (self: Table<T>) -> Table<T>,
	Sample: (self: Table<T>, count: number) -> Table<T>,
	Destroy: () -> nil,

	Inserted: RBXScriptSignal,
	Removed: RBXScriptSignal,
	Changed: RBXScriptSignal,
}

local Table = {}

function Table.new<T>(elements: {T}?): Table<T>
	assert(typeof(elements) == "table" or elements == nil, "Table.new() expects a table or nil")
	elements = Value.new(elements or {})
	local self = {
		_table = elements,
		Inserted = Signal.new(),
		Removed = Signal.new(),
		Changed = elements.Changed,
	}
	setmetatable(self, Table)
	return self
end

function Table:Get<T>(): {T}
	return self._table:Get()
end

function Table:Set<T>(newTable: {T}?): Table<T>
	assert(typeof(newTable) == "table" or newTable == nil, "Table:Set() expects a table or nil")
	local oldElements = self:Get()
	self._table:Set(newTable or {})
	local newElements = self:Get()
	for _, oldElement in oldElements do
		local _, oldElementKey = TableUtil.Find(newElements, function(_, element)
			return element == oldElement
		end)
		if oldElementKey ~= nil then
			newElements[oldElementKey] = nil
		else
			self.Removed:Fire(oldElement)
		end
	end
	for _, newElement in self do
		local _, newElementKey = TableUtil.Find(oldElements, function(_, element)
			return element == newElement
		end)
		if newElementKey ~= nil then
			oldElements[newElementKey] = nil
		else
			self.Inserted:Fire(newElement)
		end
	end
end

function Table:GetValue<T>(key: any): any
	return self:Get()[key]
end

function Table:SetValue<T>(key: any, value: any)
	local elements = self:Get()
	elements[key] = value
	self:Set(elements)
end

function Table:Insert<T>(value: any, key: any): number
	local elements = self:Get()
	local newIndex = key or #table + 1
	if key == nil then
		table.insert(elements, value)
	else
		assert(elements[key] == nil, `Table:Insert(): Cannot insert with key {key} because it is already occupied.`)
		elements[key] = value
	end
	self:Set(elements)
	return newIndex
end

function Table:Remove<T>(key: any): any
	local elements = self:Get()
	local value = elements[key]
	elements[key] = nil
	self:Set(elements)
	return value
end

function Table:Clear<T>()
	self:Set({})
end

function Table:Find<T>(value: any): any?
	for key, element in self do
		if element ~= value then continue end
		return key
	end
	return nil
end

function Table:Has<T>(value: any): boolean
	return self:Find(value) ~= nil
end

function Table:Sort<T>(comparator: (a: any, b: any) -> boolean)
	local elements = self:Get()
	table.sort(elements, comparator)
	self:Set(elements)
end

function Table:ToString<T>(separator: string, startingIndex: number?, endingIndex: number?): string
	return table.concat(self:Get(), separator, startingIndex, endingIndex)
end

function Table:Unpack<T>(startingIndex: number?, endingIndex: number?): {T}
	return table.unpack(self:Get(), startingIndex, endingIndex)
end

function Table:Every<T>(callback: (value: any, key: any, tbl: table) -> boolean): boolean
	return TableUtil.Every(self:Get(), callback)
end

function Table:Some<T>(callback: (value: any, key: any, tbl: table) -> boolean): boolean
	return TableUtil.Some(self:Get(), callback)
end

function Table:Map<T>(callback: (value: any, key: any, tbl: table) -> any): {any}
	local elements = self:Get()
	for index, element in elements do
		elements[index] = callback(element, index, elements)
	end
	return elements
end

function Table:Reduce<T>(callback: (accumulator: any, value: any, any: any) -> any, initialValue: any?): any
	return TableUtil.Reduce(self:Get(), callback, initialValue)
end

function Table:Reverse<T>(): Table<T>
	local reversed = TableUtil.Reverse(self:Get())
	self:Set(reversed)
end

function Table:Sample<T>(count: number): Table<T>
	local sampled = TableUtil.Sample(self:Get(), count)
	self:Set(sampled)
end

function Table:Destroy()
	self._table:Destroy()
end

function Table:__concat<T>(other: any): Table<T>
	if typeof(other) ~= "table" then
		other = {other}
	end
	for _, value in other do
		self:Insert(value)
	end
end

function Table:__iter<T>()
	return next, self:Get()
end

function Table:__len<T>()
	return #self:Get()
end

Table.__index = Table

return Table