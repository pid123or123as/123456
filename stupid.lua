local Nigger = {}

function Nigger.Init(UI, Core, notify)
    -- Ждём UI один раз
    task.spawn(function()
        repeat task.wait() until UI and UI.Tabs and UI.Tabs.AutoFarm

        -- === Underground Killer ===
        if UI.Sections.Snap then
            UI.Sections.Snap:Header({ Name = 'Underground Kill' })

            local Players = game:GetService('Players')
            local RunService = game:GetService('RunService')
            local TweenService = game:GetService('TweenService')

            local player = Players.LocalPlayer
            local snapConn, snapped = nil, false
            local offsetValue = 5.80
            local baseY, lockedY = nil, nil
            local tweenConn

            local function startSnap()
                local char = player.Character or player.CharacterAdded:Wait()
                local hrp = char:WaitForChild('HumanoidRootPart', 5)
                if not hrp then return end

                if snapConn then snapConn:Disconnect() end

                baseY = hrp.Position.Y
                lockedY = baseY - offsetValue
                snapped = true

                snapConn = RunService.Heartbeat:Connect(function()
                    if not (char and char.Parent and hrp and hrp.Parent) then
                        snapped = false
                        if snapConn then snapConn:Disconnect() end
                        return
                    end

                    local pos = hrp.Position
                    local target = Vector3.new(pos.X, lockedY, pos.Z)
                    char:PivotTo(CFrame.new(target, target + hrp.CFrame.LookVector))
                end)
            end

            local function stopSnap()
                if snapConn then snapConn:Disconnect() end
                snapped = false
            end

            player.CharacterAdded:Connect(function(char)
                if snapped then
                    char:WaitForChild('HumanoidRootPart', 5)
                    task.delay(0.5, function()
                        if snapped then startSnap() end
                    end)
                end
            end)

            UI.Sections.Snap:Toggle({
                Name = 'Underground Killer',
                Default = false,
                Callback = function(state)
                    if state then startSnap() else stopSnap() end
                end
            }, 'SnapToggle')

            UI.Sections.Snap:Slider({
                Name = 'Y Offset',
                Default = offsetValue,
                Minimum = 5.80,
                Maximum = 50,
                DisplayMethod = 'Number',
                Precision = 0,
                Callback = function(Value)
                    offsetValue = Value
                    if snapped and baseY then
                        local newY = baseY - offsetValue
                        if tweenConn then tweenConn:Cancel() end

                        local fake = Instance.new('NumberValue')
                        fake.Value = lockedY or newY

                        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                        tweenConn = TweenService:Create(fake, tweenInfo, { Value = newY })

                        fake:GetPropertyChangedSignal('Value'):Connect(function()
                            lockedY = fake.Value
                        end)

                        tweenConn:Play()
                    end
                end
            }, 'SnapSlider')
        end

        -- === Gun Mods ===
        if UI.Sections.Gunmods then
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

                            GunModule.apply_recoil = function() end

                            GunModule.class.hook(function(gunObj)
                                gunObj.states.fire_rate.set(3000)
                                gunObj.states.accuracy.set(100)
                                gunObj.states.reload_time.set(0.1)
                                gunObj.states.last_shot.set(-999999)
                                gunObj.instance:SetAttribute('Recoil', 0)

                                local oldGet = gunObj.states.last_shot.get
                                gunObj.states.last_shot.get = function() return 0 end

                                return function() end
                            end)
                        end

                        applyGunMods()

                        Players.LocalPlayer.CharacterAdded:Connect(function()
                            task.wait(0.1)
                            applyGunMods()
                        end)

                        local conn = RunService.Heartbeat:Connect(applyGunMods)
                        _G.GunModsHeartbeat = conn
                    else
                        if _G.GunModsHeartbeat then
                            _G.GunModsHeartbeat:Disconnect()
                            _G.GunModsHeartbeat = nil
                        end
                    end
                end
            })
        end
    end)
end

return Nigger
