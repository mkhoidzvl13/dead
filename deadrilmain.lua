local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local Window = WindUI:CreateWindow({
    Title = "Shinichi Library",
    Icon = "circle-user",
    Author = "Beta",
    Folder = "shinicu",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = false,
})
Window:EditOpenButton({
    Title = "Open Gay UI",
    Icon = "circle-user",
    CornerRadius = UDim.new(0,10),
    StrokeThickness = 2,
    Color = ColorSequence.new( 
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),

    Draggable = true,
})




local Tabs = {
    InfoTab = Window:Tab({ Title = "Info", Icon = "info", Desc = "Discord and developer information" }),
    ButtonTab = Window:Tab({ Title = "Misc", Icon = "mouse-pointer-2", Desc = "Contains interactive buttons for various actions." }),
    MainTab = Window:Tab({ Title = "Main", Icon = "car", Desc = "Main features and automation." }),
    AimTab = Window:Tab({ Title = "Aim", Icon = "target", Desc = "Aim features and automation." }),
    FarmingTab = Window:Tab({ Title = "Farming", Icon = "bot", Desc = "Automatic farming features" }),
}

Window:SelectTab(1)
Tabs.InfoTab:Section({ Title = "Discord" })
Tabs.InfoTab:Button({
    Title = "Copy Discord Link",
    Icon = "link-2",
    Callback = function()
        setclipboard("https://discord.gg/CB663BRHef")
        WindUI:Notify({
            Title = "Thông báo",
            Content = "Copy Thành Công",
            Icon = "check",
            Duration = 5,
        })
    end
})

Tabs.InfoTab:Section({ Title = "Developers" })
Tabs.InfoTab:Button({
    Title = "Shinichi Gay",
    Icon = "user",
    Callback = function()
        setclipboard("Shinichi")
        WindUI:Notify({
            Title = "Thông báo",
            Content = "Copy Thành Công",
            Icon = "check",
            Duration = 5,
        })
    end
})

Tabs.InfoTab:Button({
    Title = "Darkz Gay",
    Icon = "user",
    Callback = function()
        setclipboard("Darkz")
        WindUI:Notify({
            Title = "Thông báo",
            Content = "Copy Thành Công",
            Icon = "check",
            Duration = 5,
        })
    end
})
Tabs.InfoTab:Button({
    Title = "Grayx Dz",
    Icon = "user",
    Callback = function()
        setclipboard("Grayx")
        WindUI:Notify({
            Title = "Thông báo",
            Content = "Copy Thành Công",
            Icon = "check",
            Duration = 5,
        })
    end
})


Tabs.ButtonTab:Button({
    Title = "Unlock ThirdPerson",
    Icon = "camera",
    Callback = function()
        WindUI:Notify({
            Title = "Thông báo",
            Content = " Unlock ThirdPerson.",
            Icon = "check",
            Duration = 5,
        })
        
        local player = game.Players.LocalPlayer

        player.CameraMaxZoomDistance = 99999
        player.CameraMode = Enum.CameraMode.Classic
    end
})

Tabs.ButtonTab:Button({
    Title = "Remove Proximity Prompt Delay",
    Icon = "clock",
    Callback = function()
        WindUI:Notify({
            Title = "Thông báo",
            Content = "Remove Proximity Prompt Delay.",
            Icon = "check",
            Duration = 5,
        })
        
        for _, prompt in pairs(game:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.MaxActivationDistance = math.huge
                prompt.HoldDuration = 0
                prompt.Enabled = true
            end
        end
    end
})
local isReloadFasterEnabled = false

Tabs.ButtonTab:Toggle({
    Title = "Giảm Thời Gian Reload",
    Icon = "timer",
    Default = false,
    Callback = function(state)
        if state then

            isReloadFasterEnabled = true
            WindUI:Notify({
                Title = "Thông báo",
                Content = "Đã Bật Giảm Thời Gian Reload.",
                Icon = "check",
                Duration = 5,
            })


            spawn(function()
                while isReloadFasterEnabled do
                    local tool = player.Backpack:FindFirstChildOfClass("Tool")
                    if tool then
                        local fireDelay = tool:FindFirstChild("WeaponConfiguration") and tool.WeaponConfiguration:FindFirstChild("FireDelay")
                        if fireDelay then
                            local originalDelay = fireDelay.Value
                            fireDelay.Value = fireDelay.Value * 0.1 


                            task.wait(0.1)
                            fireDelay.Value = originalDelay
                        else
                            WindUI:Notify({
                                Title = "Thông báo",
                                Content = "Không tìm thấy thuộc tính FireDelay trong vũ khí.",
                                Icon = "alert-triangle",
                                Duration = 5,
                            })
                        end
                    else
                        WindUI:Notify({
                            Title = "Thông báo",
                            Content = "Không có vũ khí trang bị.",
                            Icon = "alert-triangle",
                            Duration = 5,
                        })
                    end
                    task.wait(0.1)
                end
            end)
        else

            isReloadFasterEnabled = false
            WindUI:Notify({
                Title = "Thông báo",
                Content = "Đã Tắt Giảm Thời Gian Reload.",
                Icon = "check",
                Duration = 5,
            })
        end
    end
})




local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local cameraFollowEnabled = false
local lastHadTarget = false
local currentTarget = nil
local selectedCameraView = "Behind"


local mobsList = {
    ["Runner"] = true, ["Outlaws"] = true, ["Vampire"] = true, ["Nikola Tesla"] = true,
    ["Runner Zombie"] = true, ["Banker Zombie"] = true, ["Ironclad Zombie"] = true,
    ["Dynamite Zombie"] = true, ["Sheriff Zombie"] = true, ["Zombie Soldier"] = true,
    ["Captain Prescott"] = true, ["Lab Zombie"] = true, ["Wolf"] = true,
    ["Werewolf"] = true, ["Skeleton"] = true, ["Horse"] = true,
    ["ShotgunOutlaw"] = true, ["RifleOutlaw"] = true, ["Walker"] = true, ["Banker"] = true,
    ["RevolverOutlaw"] = true, ["TurretOutlaw"] = true
}

local function resetCamera()
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
end

local function findValidMob()
    local closestMob = nil
    local shortestDistance = math.huge
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and mobsList[obj.Name] then
            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            local part = obj:FindFirstChild("Head") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
            if hum and hum.Health > 0 and root and part then
                local dist = (root.Position - part.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestMob = obj
                end
            end
        end
    end

    return closestMob
end


local function getCameraOffset(viewType)
    if viewType == "Top" then
        return Vector3.new(0, 5, 0) 
    elseif viewType == "Side" then
        return Vector3.new(6, 2.5, 0) 
    elseif viewType == "Behind" then
        return Vector3.new(0, 2.5, 5) 
    else 
        return Vector3.new(0, 2.5, -6) 
    end
end




local selectedCameraView = "Top"  

local function updateCameraToTarget(target)
    if not target then return end
    local part = target:FindFirstChild("Head") or target.PrimaryPart or target:FindFirstChildOfClass("BasePart")
    if part then
        camera.CameraType = Enum.CameraType.Scriptable
        local offset = getCameraOffset(selectedCameraView) 
        local camPos = part.Position + offset
        camera.CFrame = CFrame.new(camPos, part.Position)
    end
end

local cameraToggle
cameraToggle = Tabs.AimTab:Toggle({
    Title = "View Mob Camera",
    Default = false,
    Callback = function(state)
        cameraFollowEnabled = state

        if state then
            RunService:BindToRenderStep("CameraFollowNPC", Enum.RenderPriority.Camera.Value + 1, function()
                if not cameraFollowEnabled then return end

                local hasTarget = false
                local hum = currentTarget and currentTarget:FindFirstChildWhichIsA("Humanoid")

                if not currentTarget or not currentTarget.Parent or (hum and hum.Health <= 0) then
                    currentTarget = findValidMob()
                end

                if currentTarget then
                    updateCameraToTarget(currentTarget)
                    hasTarget = true
                end

                if hasTarget then
                    lastHadTarget = true
                elseif lastHadTarget then
                    resetCamera()
                    lastHadTarget = false
                end
            end)

        else
            RunService:UnbindFromRenderStep("CameraFollowNPC")
            resetCamera()
            currentTarget = nil
        end
    end
})

local FinalPosition = Vector3.new(-424.00, 23, -49041.00)

Tabs.FarmingTab:Section({ Title = "Auto Farming" })

Tabs.FarmingTab:Button({
    Title = "AutoWin",
    Icon = "trophy",
    Desc = "Wait 10 Minutes",
    Callback = function()

        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")


        WindUI:Notify({
            Title = "Thông báo",
            Content = "Đang Dịch Chuyển.",
            Icon = "alert-circle",
            Duration = 5,
        })


        local startTime = tick()
        local duration = 15
        while tick() - startTime < duration do
            humanoidRootPart.CFrame = CFrame.new(FinalPosition)
            wait(0.1)
        end


        startAimLock()


        WindUI:Notify({
            Title = "Thông báo",
            Content = "Vui Lòng Bắn Quái.",
            Icon = "target",
            Duration = 5,
        })
    end
})




Tabs.ButtonTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        getgenv().NoclipEnabled = Value
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")

        local function noclip()
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end

        local lastY = nil

        RunService.Stepped:Connect(function()
            if getgenv().NoclipEnabled then
                local player = Players.LocalPlayer
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    noclip()
                    local hrp = char.HumanoidRootPart
                    if not lastY then
                        lastY = hrp.Position.Y
                    end
                    if hrp.Velocity.Y < -50 then
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.CFrame = CFrame.new(hrp.Position.X, lastY, hrp.Position.Z)
                    else
                        lastY = hrp.Position.Y
                    end
                end
            end
        end)
    end
})


local autoDriveConnection = nil
local seat = nil

Tabs.MainTab:Toggle({
    Title = "Auto Drive",
    Default = false,
    Callback = function(enabled)
        getgenv().AutoDrive = enabled
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer


        local function findClosestSeat()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local closest = nil
            local shortestDist = math.huge

            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("VehicleSeat") then
                    local dist = (v.Position - hrp.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = v
                    end
                end
            end
            return closest
        end


        local function sitInSeat(targetSeat)
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            if hrp and targetSeat then
                local seatPos = targetSeat.Position
                local offset = Vector3.new(0, 1.25, 0) 
                hrp.CFrame = CFrame.new(seatPos + offset)
            end
        end


        local function leaveSeat()
            local character = LocalPlayer.Character
            if character and character:FindFirstChildOfClass("Humanoid") then
                character:FindFirstChildOfClass("Humanoid").Sit = false
            end
        end

        if enabled then
            seat = findClosestSeat()
            if seat then
                sitInSeat(seat)
                autoDriveConnection = RunService.Heartbeat:Connect(function()
                    if getgenv().AutoDrive and seat and seat:IsDescendantOf(workspace) then
                        local character = LocalPlayer.Character
                        if seat.Occupant and character and seat.Occupant == character:FindFirstChildOfClass("Humanoid") then
                            seat.Throttle = 1
                        else
                            sitInSeat(seat)
                        end
                    end
                end)
            else
                warn("Không tìm thấy VehicleSeat gần nhân vật!")
            end
        else
            leaveSeat()
            if autoDriveConnection then
                autoDriveConnection:Disconnect()
                autoDriveConnection = nil
            end
        end
    end
})

local ESPEnabled = false
local Drawings = {}

local itemsList = {
    ["GoldBar"] = true, ["Barrel"] = true, ["Teapot"] = true, ["SilverPocketWatch"] = true, ["Molotov"] = true,
    ["Chair"] = true, ["GoldStatue"] = true, ["SilverBar"] = true, ["Wheel"] = true, ["Painting"] = true,
    ["WantedPoster"] = true, ["Revolver"] = true, ["GoldPocketWatch"] = true, ["RifleAmmo"] = true,
    ["RevolverAmmo"] = true, ["Left Arm_Armor"] = true, ["TurretAmmo"] = true, ["Shotgun"] = true,
    ["SilverCup"] = true, ["Right Arm_Armor"] = true, ["MaximGun"] = true, ["Statue"] = true, ["Torch"] = true,
    ["Coal"] = true, ["GoldPainting"] = true, ["VaseTwo"] = true, ["Bond"] = true, ["Crucifix"] = true,
    ["Holy"] = true, ["Vase"] = true, ["BarbedWire"] = true, ["Bandage"] = true, ["Book"] = true,
    ["Newspaper"] = true, ["Helmet"] = true, ["Left Shoulder Armor"] = true, ["Right Shoulder Armor"] = true,
    ["Chestplate"] = true, ["Banjo"] = true, ["Brain In Jar"] = true, ["Gold Cup"] = true, ["Gold Nugget"] = true,
    ["Gold Painting"] = true, ["Gold Plate"] = true, ["Gold Statue"] = true, ["Gold Watch"] = true,
    ["Money Bag"] = true, ["Silver Bar"] = true, ["Silver Cup"] = true, ["Silver Nugget"] = true,
    ["Silver Painting"] = true, ["Silver Plate"] = true, ["Silver Statue"] = true, ["Silver Watch"] = true,
    ["Strange Mask"] = true, ["Wooden Painting"] = true, ["Barbed Wire"] = true, ["Camera"] = true,
    ["Lantern"] = true, ["Lightning Rod"] = true, ["Sheet Metal"] = true, ["Snake Oil"] = true,
    ["Saddle"] = true, ["Horse Cart"] = true, ["Torch"] = true, ["Jade Tablet"] = true, ["Shovel"] = true,
    ["Tomahawk"] = true, ["SilverOre"] = true, ["JadeTablet1"] = true, ["JadeTablet2"] = true, ["JadeTablet4"] = true
}

local mobsList = {
    ["Runner"] = true, ["Outlaws"] = true, ["Vampire"] = true, ["Nikola Tesla"] = true, ["Runner Zombie"] = true,
    ["Banker Zombie"] = true, ["Ironclad Zombie"] = true, ["Dynamite Zombie"] = true, ["Sheriff Zombie"] = true,
    ["Zombie Soldier"] = true, ["Captain Prescott"] = true, ["Lab Zombie"] = true, ["Wolf"] = true,
    ["Werewolf"] = true, ["Skeleton"] = true, ["Horse"] = true, ["ShotgunOutlaw"] = true, ["RifleOutlaw"] = true,
    ["Walker"] = true, ["Banker"] = true, ["RevolverOutlaw"] = true, ["TurretOutlaw"] = true
}

local MAX_DISTANCE = 400
local LAST_UPDATE_TIME = tick()  
local ESP_UPDATE_INTERVAL = 0.2  


Tabs.MainTab:Toggle({
    Title = "ESP - Items & Mobs",  
    Default = false,               
    Callback = function(state)
        ESPEnabled = state
        if not state then
            for _, d in pairs(Drawings) do
                d:Remove()
            end
            table.clear(Drawings)
        end
    end
})

RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end

    if tick() - LAST_UPDATE_TIME < ESP_UPDATE_INTERVAL then return end
    LAST_UPDATE_TIME = tick()

    local camPos = camera.CFrame.Position

    for _, obj in pairs(workspace:GetDescendants()) do
        local isItem = itemsList[obj.Name]
        local isMob = mobsList[obj.Name]

        if isItem or isMob then
            local part = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
            if part then
                local distance = (camPos - part.Position).Magnitude


                if distance <= MAX_DISTANCE then
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        if not Drawings[obj] then
                            local text = Drawing.new("Text")
                            text.Size = 14
                            text.Center = true
                            text.Outline = true
                            Drawings[obj] = text
                        end
                        

                        local drawing = Drawings[obj]
                        drawing.Text = ("%s [%.1fm]"):format(obj.Name, distance)
                        drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                        drawing.Visible = true
                        drawing.Color = isItem and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    elseif Drawings[obj] then

                        Drawings[obj].Visible = false
                    end
                elseif Drawings[obj] then

                    if not obj.Parent then

                        Drawings[obj]:Remove()
                        Drawings[obj] = nil
                    end
                end
            end
        end
    end
end)

Tabs.ButtonTab:Button({
    Title = "Full Bright",
    Icon = "sun",
    Callback = function()
        WindUI:Notify({
            Title = "Thông báo",
            Content = "Đã bật Full Bright.",
            Icon = "check",
            Duration = 5,
        })
        local Light = game:GetService("Lighting")
        Light.Ambient = Color3.new(1, 1, 1)
        Light.ColorShift_Bottom = Color3.new(1, 1, 1)
        Light.ColorShift_Top = Color3.new(1, 1, 1)
    end
})


Tabs.FarmingTab:Toggle({
    Title = "Equip Revolver",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        isRevolverEquipped = state

        if state then

            local revolver = player.Backpack:FindFirstChild("Revolver") or character:FindFirstChild("Revolver")
            if not revolver then

                revolver = player.Backpack:FindFirstChild("Revolver")
            end

            print("Revolver found: ", revolver) 

            if revolver then

                if revolver.Parent ~= character then
                    humanoid:EquipTool(revolver)
                    print("Revolver equipped") 
                end
                WindUI:Notify({
                    Title = "Notification",
                    Content = "Revolver equipped or already in hand!",
                    Icon = "check",
                    Duration = 5,
                })


                game:GetService("RunService").Heartbeat:Connect(function()
                    if isRevolverEquipped then
                        local revolverInHand = character:FindFirstChild("Revolver")

                        if not revolverInHand then
                            revolver = player.Backpack:FindFirstChild("Revolver") 
                            if revolver then
                                humanoid:EquipTool(revolver)
                                print("Revolver re-equipped")
                            end
                        end


                        local closestMob = getClosestMob(50) 
                        if closestMob then

                            shootAtMob(revolver, closestMob)
                        end
                    end
                end)

            else
                WindUI:Notify({
                    Title = "Notification",
                    Content = "Revolver not found in Backpack or Character!",
                    Icon = "alert-triangle",
                    Duration = 5,
                })
                isRevolverEquipped = false
                return
            end
        else
            
            local revolver = character:FindFirstChild("Revolver")
            if revolver then
                humanoid:UnequipTools()
                WindUI:Notify({
                    Title = "Notification",
                    Content = "Revolver unequipped!",
                    Icon = "check",
                    Duration = 5,
                })
            end
            if isAutoShootEnabled then
                isAutoShootEnabled = false
                if autoShootConnection then
                    autoShootConnection:Disconnect()
                    autoShootConnection = nil
                end
                WindUI:Notify({
                    Title = "Notification",
                    Content = "Auto Shoot disabled due to unequipping Revolver!",
                    Icon = "alert-circle",
                    Duration = 5,
                })
            end
        end
    end
})


function getClosestMob(maxDistance)
    local closestMob = nil
    local shortestDist = maxDistance or math.huge
    local character = game.Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, mob in pairs(workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChildOfClass("Humanoid") then
            local humanoid = mob:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = mob:FindFirstChild("Head") or mob:FindFirstChild("HumanoidRootPart")
                if head then
                    local dist = (root.Position - head.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestMob = mob
                    end
                end
            end
        end
    end
    return closestMob
end


function shootAtMob(revolver, mob)
    local fireEvent = revolver:FindFirstChild("FireEvent")
    if fireEvent then
        local head = mob:FindFirstChild("Head") or mob:FindFirstChild("HumanoidRootPart")
        if head then
            fireEvent:FireServer(head.Position)
            print("Firing at mob!")
        end
    else
        print("FireEvent not found!")
    end
end


Tabs.AimTab:Toggle({
    Title = "Auto Fire",
    Default = false,
    Callback = function(state)
        getgenv().AutoFireEnabled = state
        local player = game.Players.LocalPlayer
        local RunService = game:GetService("RunService")
        local cooldowns = {}


        local function getClosestMob(maxDistance)
            local closest, shortestDist = nil, maxDistance or math.huge
            local character = player.Character or player.CharacterAdded:Wait()
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return nil end
            
            for _, mob in pairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mobsList[mob.Name] then
                    local humanoid = mob:FindFirstChildOfClass("Humanoid")
                    local head = mob:FindFirstChild("Head") or mob:FindFirstChild("HumanoidRootPart")
                    if humanoid and humanoid.Health > 0 and head then
                        local dist = (root.Position - head.Position).Magnitude
                        if dist < shortestDist then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterDescendantsInstances = {character}
                            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                            local result = workspace:Raycast(root.Position, (head.Position - root.Position), rayParams)
                            
                            if not result or result.Instance:IsDescendantOf(mob) then
                                shortestDist = dist
                                closest = mob
                            end
                        end
                    end
                end
            end
            return closest
        end
        

        local function setCooldown(weapon)
            if not weapon:FindFirstChild("WeaponConfiguration") then return end
            
            cooldowns[weapon] = true
            local fireDelay = weapon.WeaponConfiguration:FindFirstChild("FireDelay")
            local delay = (fireDelay and fireDelay.Value or 0.3) * 0.3 

            task.delay(delay, function()
                cooldowns[weapon] = false
            end)
        end
        

        local function shoot(weapon, target)
            if not target or cooldowns[weapon] then return end


            local part = target:FindFirstChild("Head") or target.PrimaryPart
            if not part then return end
            local humanoid = target:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            local fireEvent = weapon:FindFirstChild("FireEvent")
            local shootRemote = game:GetService("ReplicatedStorage").Remotes and 
                               game:GetService("ReplicatedStorage").Remotes.Weapon and
                               game:GetService("ReplicatedStorage").Remotes.Weapon.Shoot
            
            if fireEvent then
                fireEvent:FireServer(part.Position)
                setCooldown(weapon)
            elseif shootRemote then
                local hits = {}
                local pelletsPerBullet = weapon:FindFirstChild("WeaponConfiguration") and 
                                        weapon.WeaponConfiguration:FindFirstChild("PelletsPerBullet")
                
                local pelletCount = pelletsPerBullet and pelletsPerBullet.Value or 1
                for i = 1, pelletCount do
                    hits[tostring(i)] = humanoid
                end


                shootRemote:FireServer(
                    workspace:GetServerTimeNow(), 
                    weapon, 
                    CFrame.lookAt(part.Position + (part.CFrame.LookVector * 10), part.Position), 
                    hits
                )
                setCooldown(weapon)
            end
        end
        

        local function reload(weapon)
            local reloadRemote = game:GetService("ReplicatedStorage").Remotes and 
                                game:GetService("ReplicatedStorage").Remotes.Weapon and
                                game:GetService("ReplicatedStorage").Remotes.Weapon.Reload
            
            if reloadRemote and weapon:FindFirstChild("WeaponConfiguration") then
                reloadRemote:FireServer(workspace:GetServerTimeNow(), weapon)
            end
        end
        
        if state then
            getgenv().AutoFireConnection = RunService.Heartbeat:Connect(function()
                if not player.Character then return end
                
                local weapon = player.Character:FindFirstChildOfClass("Tool")
                if not weapon or not weapon:FindFirstChild("WeaponConfiguration") then return end
                
                local currentAmmo = weapon:FindFirstChild("ServerWeaponState") and 
                                   weapon.ServerWeaponState:FindFirstChild("CurrentAmmo")
                
                if currentAmmo and currentAmmo.Value <= 0 then
                    reload(weapon)
                    return
                end
                
                local maxRange = 600 
                local target = getClosestMob(maxRange)
                if target then
                    shoot(weapon, target)
                end
            end)
        else
            if getgenv().AutoFireConnection then
                getgenv().AutoFireConnection:Disconnect()
                getgenv().AutoFireConnection = nil
            end
        end
    end
})


WindUI:Notify({
    Title = "10 Minute Countdown",
    Content = "Should Turn On Auto Win After 10 Minutes!",
    Icon = "clock",
    Duration = 600,
})

WindUI:Notify({
    Title = "Beta | Dead Rails",
    Content = "Loaded Successful!",
    Icon = "check-circle",
    Duration = 10,
})