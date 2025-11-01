local Sperma = {}

-- Ждём UI, но НЕ внутри функции Init
task.defer(function()
    repeat task.wait() until UI and UI.Tabs and UI.Tabs.AutoFarm
    Sperma:Init(UI, Core, notify)  -- manual idk for what
end)

function Sperma.Init(UI, Core, notify)
    if not (UI and UI.Sections and UI.Sections.Gunmods) then
        warn("stupid")
        return
    end

    UI.Sections.Gunmods:Header({ Name = 'Gun Modification' })

    UI.Sections.Gunmods:Toggle({
        Name = 'Fast Shoot',
        Default = false,
        Callback = function(state)
            if state then
                local ReplicatedStorage = game:GetService('ReplicatedStorage')
                local Players = game:GetService('Players')
                local RunService = game:GetService('RunService')

                local function applyGunMods()
                    local success, GunModule = pcall(function()
                        return require(ReplicatedStorage.Modules.Game.ItemTypes.Gun)
                    end)

                    if not success or not GunModule then return end

                    -- Отключаем отдачу
                    local originalApplyRecoil = GunModule.apply_recoil
                    GunModule.apply_recoil = function() end

                    -- Хукаем класс
                    GunModule.class.hook(function(gunObj)
                        gunObj.states.fire_rate.set(3000)
                        gunObj.states.accuracy.set(100)
                        gunObj.states.reload_time.set(0.1)
                        gunObj.states.last_shot.set(-999999)
                        gunObj.instance:SetAttribute('Recoil', 0)

                        local oldGet = gunObj.states.last_shot.get
                        gunObj.states.last_shot.get = function()
                            return 0
                        end

                        return function() end
                    end)
                end

                applyGunMods()

                local localPlayer = Players.LocalPlayer
                localPlayer.CharacterAdded:Connect(function()
                    task.wait(0.1)
                    applyGunMods()
                end)

                local heartbeatConnection = RunService.Heartbeat:Connect(applyGunMods)
                _G.GunModsHeartbeat = heartbeatConnection
            else
                if _G.GunModsHeartbeat then
                    _G.GunModsHeartbeat:Disconnect()
                    _G.GunModsHeartbeat = nil
                end
            end
        end,
    })
end

return Sperma
