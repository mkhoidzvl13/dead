local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mkhoidzvl13/dead/refs/heads/main/lib.lua", true))()

-- Create the window for both tabs
local Window = Library:Main("GRAYX HUB")

-- Create the first tab: Main (this will appear above the other tabs)
local MainTab = Window:NewTab("Main")
local ESPTab = Window:NewTab("ESP Settings")
local AimTab = Window:NewTab("Aim Settings")

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local ESPEnabled = false
local autoDriveEnabled = true
local espBoxes = {}
local aimEnabled = false
local aimTarget = nil
local aimFOV = 100

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.Visible = false
fovCircle.Radius = aimFOV
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Vật phẩm cần ESP
local objectsToTrack = {
    "GoldBar", "Barrel", "Teapot", "SilverPocketWatch", "Molotov", "Chair", "GoldStatue",
    "SilverBar", "Wheel", "Painting", "WantedPoster", "Revolver", "GoldPocketWatch",
    "RifleAmmo", "RevolverAmmo", "Left Arm_Armor", "TurretAmmo", "Shotgun", "SilverCup",
    "Right Arm_Armor", "MaximGun", "Statue", "Torch", "Coal", "GoldPainting", "VaseTwo",
    "Bond", "Crucifix", "Holy", "Vase", "BarbedWire", "Bandage", "Book", "Newspaper", "Helmet",
    "Left Shoulder Armor", "Right Shoulder Armor", "Chestplate", "Banjo", "Brain In Jar","Gold Cup",
    "Gold Nugget", "Gold Painting", "Gold Plate", "Gold Statue", "Gold Watch", "Money Bag", "Silver Bar",
    "Silver Cup", "Silver Nugget", "Silver Painting", "Silver Plate", "Silver Statue", "Silver Watch", "Strange Mask",
    "Wooden Painting", "Barbed Wire", "Camera", "Lantern", "Lightning Rod", "Sheet Metal", "Snake Oil", "Saddle",
    "Horse Cart", "Torch", "Jade Tablet", "Shovel", "Tomahawk"
}

-- Mob cần ESP
local mobsToTrack = {
    "Zombie", "Outlaws", "Vampire", "Nikola Tesla", "Runner Zombie", "Banker Zombie", "Ironclad Zombie", "Dynamite Zombie", "Sheriff Zombie",
    "Zombie Soldier", "Captain Prescott", "Lab Zombie", "Wolf", "Werewolf", "Skeleton"
}

-- Tạo ESP box và text
local function CreateESP(color, name)
    local box = Drawing.new("Square")
    box.Color = color or Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    box.Visible = false

    local label = Drawing.new("Text")
    label.Text = name or "?"
    label.Color = color or Color3.fromRGB(255, 0, 0)
    label.Size = 14
    label.Center = true
    label.Outline = true
    label.Visible = false

    return {Box = box, Label = label}
end

-- Cập nhật vị trí ESP
-- Cập nhật các mob được theo dõi và hiển thị ESP cho chúng
local function TrackMobs()
    -- Quét qua tất cả mob trong workspace
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and table.find(mobsToTrack, descendant.Name) then
            local rootPart = descendant:FindFirstChild("HumanoidRootPart") or descendant.PrimaryPart
            -- Kiểm tra nếu rootPart của mob đã được tạo ESP
            if rootPart and not espBoxes[descendant] then
                espBoxes[descendant] = CreateESP(Color3.fromRGB(255, 0, 0), descendant.Name)
            end
        end
    end
end

-- Cập nhật và hiển thị ESP cho mob trong vòng lặp
local function UpdateESP()
    if not ESPEnabled then
        for _, tbl in pairs(espBoxes) do
            tbl.Box.Visible = false
            tbl.Label.Visible = false
        end
        return
    end

    for obj, tbl in pairs(espBoxes) do
        if obj and obj.Parent then
            local position
            if obj:IsA("Model") then
                -- Kiểm tra nếu obj là mob và có phần "HumanoidRootPart"
                if obj.PrimaryPart then
                    position = obj.PrimaryPart.Position
                elseif obj:FindFirstChild("HumanoidRootPart") then
                    position = obj.HumanoidRootPart.Position
                end
            elseif obj:IsA("BasePart") then
                position = obj.Position
            end

            if position then
                local screenPos, onScreen = Camera:WorldToViewportPoint(position)
                if onScreen then
                    local distance = (Camera.CFrame.Position - position).Magnitude
                    local size = math.clamp(3000 / distance, 20, 100)
                    tbl.Box.Size = Vector2.new(size, size * 1.5)
                    tbl.Box.Position = Vector2.new(screenPos.X - size / 2, screenPos.Y - size / 2)
                    tbl.Box.Visible = true

                    tbl.Label.Position = Vector2.new(screenPos.X, screenPos.Y + size / 1.1)
                    tbl.Label.Visible = true
                else
                    tbl.Box.Visible = false
                    tbl.Label.Visible = false
                end
            else
                tbl.Box.Visible = false
                tbl.Label.Visible = false
            end
        else
            tbl.Box.Visible = false
            tbl.Label.Visible = false
        end
    end
end


-- Quét item và mob
local function TrackObjects()
    local parent = workspace:FindFirstChild("RuntimeItems")
    if not parent then return end

    for _, obj in ipairs(parent:GetChildren()) do
        if table.find(objectsToTrack, obj.Name) and not espBoxes[obj] then
            espBoxes[obj] = CreateESP(Color3.fromRGB(0, 255, 0), obj.Name)
        end
    end
end



-- Aimbot
local function GetZombieHead(zombie)
    return zombie:FindFirstChild("Head")
end

local function GetClosestTarget()
    local closest, closestDist = nil, aimFOV
    for mob, _ in pairs(espBoxes) do
        if table.find(mobsToTrack, mob.Name) then
            local head = GetZombieHead(mob)
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = mob
                    end
                end
            end
        end
    end
    return closest
end

local function TrackTargets()
    if aimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        aimTarget = GetClosestTarget()
        if aimTarget then
            local character = LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            local targetHead = GetZombieHead(aimTarget)

            if humanoidRootPart and targetHead then
                local targetPosition = targetHead.Position
                local direction = (targetPosition - humanoidRootPart.Position).unit
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + direction)
            end
        end
    else
        aimTarget = nil
    end
end

-- Giao diện
ESPTab:NewToggle("Enable ESP", function(state)
    ESPEnabled = state
end, ESPEnabled)

AimTab:NewToggle("Enable Aim", function(state)
    aimEnabled = state
end, aimEnabled)

AimTab:NewSlider("Aim FOV", 10, 200, aimFOV, function(value)
    aimFOV = value
end)

ESPTab:NewToggle("Toggle Auto Drive", function()
    autoDriveEnabled = not autoDriveEnabled
    if autoDriveEnabled then
        print("Auto Drive Enabled")
    else
        print("Auto Drive Disabled")
    end
end)

-- Vòng lặp chính
RunService.RenderStepped:Connect(function()
    TrackObjects()
    TrackMobs()
    UpdateESP()
    TrackTargets()

    -- Auto drive
    if autoDriveEnabled then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
        if humanoid and humanoid.SeatPart then
            keypress(0x57)
        end
    end

    -- Vẽ vòng FOV
    fovCircle.Visible = aimEnabled
    fovCircle.Radius = aimFOV
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Tab chính
MainTab:NewLabel("Welcome to Grayx Hub!")
MainTab:NewLabel("Created by: _nguyenminhkhoi")

MainTab:NewButton("Discord: Link (Click to Copy)", function()
    setclipboard("https://discord.gg/NY2ZDU7QGf")
    print("Discord link copied to clipboard!")
end)


