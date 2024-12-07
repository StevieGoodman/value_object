local Value = require(script.Value)
local Table = require(script.Table)
local Number = require(script.Number)

export type Value<T> = Value.Value<T>
export type Table<T> = Table.Table<T>
export type Number = Number.Number

return {
	Value = Value,
	Table = Table,
	Number = Number,
}