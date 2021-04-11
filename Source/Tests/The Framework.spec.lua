return function()
    local Framework = require(game.ServerScriptService["The Framework"].Service)
    local Dummy = game.Players:GetPlayers()[1]

    describe("Server should be able to run functionality", function()
        it("Server should be able to load a map", function()
            local loadMap = Framework:LoadMap("Unit")
            expect(loadMap).to.be.ok()
        end)
    end)

    describe("Player should be able to interact with the server", function()
        it("Player should be able to connect", function()
            local Connection = Framework:Connect(Dummy):catch(warn)
            expect(Connection == true).to.be.ok()
        end)

        it("Player should be able to disconnect", function()
            local Connection = Framework:Disconnect(Dummy):catch(warn)
            expect(Connection == true).to.be.ok()
        end)
    end)
end