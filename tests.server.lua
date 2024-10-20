local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.DevPackages.TableUtil)
local TestEZ = require(ReplicatedStorage.DevPackages.TestEZ)

local package = ReplicatedStorage.Package
local testFiles = TableUtil.Filter(package:GetChildren(), function(v)
    return string.match(v.Name, ".spec") ~= nil
end)

TestEZ.TestBootstrap:run(testFiles)