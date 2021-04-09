--[[
    ███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
    ██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
    █████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝
    ██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗
    ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
    █████████████████████████████████████████████████████████████████████████████╗
    ╚════════════════════════════════════════════════════════════════════════════╝
                ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗
                ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
                ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
                ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
                ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
                ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
    █████████████████████████████████████████████████████████████████████████████╗
    ╚════════════════════════════════════════════════════════════════════════════╝

    SERVICE: Framework {
        PROPERTIES {
            ConnectedPlayers: Collection[Player],
            PlayersShouldRespawn: Boolean[true],
            CurrentMap: String,
        }

        METHODS {
            LoadMap(mapName: String): Boolean,
            Reload(forceReload: Boolean[false]): Boolean,
            Connect(player): Promise[Connected: Boolean],
            Disconnect(player): Promise[Disconnected: Boolean],
        }

        SIGNALS {
            PlayerJoined: Player,
            PlayerDied: Player, Murderer,
            PlayerLeft: Player,
        }
    }
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = require(3908178708)
local Collection = require(6371713921)
local Promise = require(4815792109)

local CLIENT = Instance.new("RemoteEvent")
CLIENT.Parent = ReplicatedStorage
CLIENT.Name = "F_A_E_O_K"

local FrameworkAnimations = require(script.AnimationHandler)

local function fastSpawn(fn)
    local _e = Event()
    _e:Connect(fn)
    _e:Fire()
    _e:Destroy()
end

local Framework = {
    ConnectedPlayers = Collection(),
    PlayersShouldRespawn = true,
    CurrentMap = "",

    PlayerJoined = Event(),
    PlayerDied = Event(),
    PlayerLeft = Event(),
} do
    function Framework:INTERNAL_FireClients()
        for _,v in ipairs(Players:GetPlayers()) do
            if self.ConnectedPlayers:Get(v) == true then
                CLIENT:FireClient(v, {
                    Instruction = "Update",
                    Map = self.CurrentMap,
                    Players = self.ConnectedPlayers:Array()
                })
            end
        end
    end

    function Framework:LoadMap(mapName)
        local map = ReplicatedStorage.Framework:FindFirstChild(mapName)
        assert(map, string.format("Map '%s' can not be found.", mapName)) --// Make sure that the map exists.
        self.CurrentMap = mapName
        self:INTERNAL_FireClients()
    end

    function Framework:Connect(player)
        local _P
        _P = Promise.new(function(resolve, reject, onCancel)
            fastSpawn(function()
                wait(60)
                reject("Timeout")
            end)
            FrameworkAnimations:Connect(self, player)
            self.ConnectedPlayers:Set(player, true)
            CLIENT:FireClient(player, "Connect")
            self:INTERNAL_FireClients()
            resolve(true)
            onCancel(function()
                self:Disconnect(player)
            end)
        end)
        return _P
    end

    function Framework:Disconnect(player)
        local _P
        _P = Promise.new(function(resolve, reject, onCancel)
            fastSpawn(function()
                wait(60)
                reject("Timeout")
            end)
            self.ConnectedPlayers:Set(player, false)
            FrameworkAnimations:Disconnect(self, player)
            CLIENT:FireClient(player, "Disconnect")
            self:INTERNAL_FireClients()
            resolve(true)
            onCancel(function()
                self:Connect(player)
            end)
        end)
        return _P
    end
end