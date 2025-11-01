print('3')
task.defer(function()
    repeat
        task.wait()
    until UI and UI.Tabs and UI.Tabs.AutoFarm
function Sperma.Init(UI, Core, notify)
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
                        return require(
                            ReplicatedStorage.Modules.Game.ItemTypes.Gun
                        )
                    end)

                    if success and GunModule then
                        local originalApplyRecoil = GunModule.apply_recoil
                        GunModule.apply_recoil = function(gun)
                            return
                        end

                        GunModule.class.hook(function(gunObj)
                            gunObj.states.fire_rate.set(3000)
                            gunObj.states.accuracy.set(100)
                            gunObj.states.reload_time.set(0.1)
                            gunObj.states.last_shot.set(-999999)
                            gunObj.instance:SetAttribute('Recoil', 0)

                            local originalLastShot = gunObj.states.last_shot.get
                            gunObj.states.last_shot.get = function()
                                return 0
                            end

                            return function() end
                        end)
                    end
                end

                applyGunMods()

                local localPlayer = Players.LocalPlayer
                localPlayer.CharacterAdded:Connect(function()
                    task.wait(0.1)
                    applyGunMods()
                end)

                local heartbeatConnection
                heartbeatConnection = RunService.Heartbeat:Connect(function()
                    applyGunMods()
                end)

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
end)
return Sperma


