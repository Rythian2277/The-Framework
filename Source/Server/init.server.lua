local Framework = require(script.Service)

local TEST = true

if TEST then
    local UnitTesting = require(game.ReplicatedStorage.UnitTesting)
    UnitTesting.TestBootstrap:run(game.ReplicatedStorage.Tests:GetChildren())
end