local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KattHub | Blox Fruits",
   Icon = 129406512764319,
   LoadingTitle = "KattHub",
   LoadingSubtitle = "Welcome",
   ShowText = "KattHub",
   Theme = "Default",
   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = true,
      Invite = "9uRWRnmNyF",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "Katthub Key System",
      Subtitle = "Key in Discord",
      Note = "Join Discord Server for Key",
      FileName = "KatthubSystem",
      SaveKey = false,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/AkahKMG9"}
   }
})

local MainTab = Window:CreateTab("Home", "house")
local TeleportTab = Window:CreateTab("Teleports", "map")
local AutofarmTab = Window:CreateTab("Autofarm", "coins")

MainTab:CreateSection("Simple Exploits")
TeleportTab:CreateSection("Tween To Islands")
AutofarmTab:CreateSection("Chest Farming")

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local TweenEnabled = false
local SelectedCFrame = nil
local CurrentTween = nil
local StopTween = false

local ChestFarmEnabled = false
local ChestFarmThread = nil

MainTab:CreateSlider({
   Name = "Set WalkSpeed",
   Range = {0, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "Slider1",
   Callback = function(Value)
       local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
       if hum then hum.WalkSpeed = Value end
   end
})

local PlaceId = game.PlaceId
local CurrentSea =
    PlaceId == 2753915549 and "Sea 1" or
    PlaceId == 4442272183 and "Sea 2" or
    PlaceId == 7449423635 and "Sea 3" or
    "Unknown"

local Islands = {
    ["Sea 1"] = {
        ["Starter Island"] = CFrame.new(1071,16,1426),
        ["Middle Town"] = CFrame.new(-655,7,1587),
        ["Jungle"] = CFrame.new(-1249,11,341),
        ["Pirate Village"] = CFrame.new(-1122,4,3855),
        ["Desert"] = CFrame.new(1094,7,4352),
        ["Frozen Village"] = CFrame.new(1347,97,-1325),
        ["Marineford"] = CFrame.new(-4500,20,4260),
        ["Colosseum"] = CFrame.new(-1428,7,-279),
        ["Sky Island"] = CFrame.new(-4600,730,-900),
        ["Prison"] = CFrame.new(4850,5,740),
        ["Magma Village"] = CFrame.new(-5230,8,846),
        ["Underwater City"] = CFrame.new(61163,5,1819),
        ["Fountain City"] = CFrame.new(5132,5,4036),
    },

    ["Sea 2"] = {
        ["Kingdom Of Rose"] = CFrame.new(-388,73,302),
        ["Cafe"] = CFrame.new(-380,75,330),
        ["Green Zone"] = CFrame.new(-2448,73,-3150),
        ["Graveyard"] = CFrame.new(-5380,9,-710),
        ["Snow Mountain"] = CFrame.new(561,401,-5290),
        ["Hot And Cold"] = CFrame.new(-6020,15,-5000),
        ["Cursed Ship"] = CFrame.new(923,126,32885),
        ["Ice Castle"] = CFrame.new(5400,28,-6230),
        ["Forgotten Island"] = CFrame.new(-3050,238,-10150),
        ["Usoap Island"] = CFrame.new(4816,8,2860),
        ["Dark Arena"] = CFrame.new(3780,9,515),
        ["Factory"] = CFrame.new(430,211,-432),
    },

    ["Sea 3"] = {
        ["Port Town"] = CFrame.new(-290,7,5300),
        ["Hydra Island"] = CFrame.new(5225,602,-345),
        ["Great Tree"] = CFrame.new(2300,25,-6400),
        ["Floating Turtle"] = CFrame.new(-11500,331,-10650),
        ["Castle On The Sea"] = CFrame.new(-5075,315,-3150),
        ["Haunted Castle"] = CFrame.new(-9515,142,5535),
        ["Sea Of Treats"] = CFrame.new(-1200,20,-10200),
        ["Peanut Island"] = CFrame.new(-2060,50,-10250),
        ["Ice Cream Island"] = CFrame.new(-800,50,-10900),
        ["Cake Island"] = CFrame.new(-2200,50,-11150),
        ["Chocolate Island"] = CFrame.new(-50,50,-11200),
        ["Candy Island"] = CFrame.new(1250,50,-11000),
        ["Tiki Outpost"] = CFrame.new(-16200,9,420),
    }
}

local function TweenTo(cf)
    StopTween = false
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local maxStep = 180
    local studsPerSecond = 135
    local targetPos = cf.Position

    while not StopTween and (hrp.Position - targetPos).Magnitude > 5 do
        local delta = targetPos - hrp.Position
        local step = math.min(maxStep, delta.Magnitude)
        local tweenTime = step / studsPerSecond
        local nextPos = hrp.Position + delta.Unit * step

        CurrentTween = TweenService:Create(
            hrp,
            TweenInfo.new(tweenTime, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(nextPos)}
        )

        CurrentTween:Play()
        CurrentTween.Completed:Wait()
    end
end

local Options = {}
for name in pairs(Islands[CurrentSea] or {}) do
    table.insert(Options, name)
end

TeleportTab:CreateDropdown({
    Name = "Select Island",
    Options = Options,
    Callback = function(opt)
        local selected = typeof(opt) == "table" and opt[1] or opt
        SelectedCFrame = Islands[CurrentSea][selected]
        if TweenEnabled and SelectedCFrame then
            TweenTo(SelectedCFrame)
        end
    end
})

TeleportTab:CreateToggle({
    Name = "Start Tweening",
    CurrentValue = false,
    Callback = function(Value)
        TweenEnabled = Value
        if not Value then
            StopTween = true
            if CurrentTween then CurrentTween:Cancel() end
        elseif SelectedCFrame then
            TweenTo(SelectedCFrame)
        end
    end
})

local CachedChests = {}

local function CacheChests()
    table.clear(CachedChests)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("chest") then
            table.insert(CachedChests, obj)
        end
    end
end

local function StartChestFarm()
    if ChestFarmThread then return end

    ChestFarmThread = task.spawn(function()
        CacheChests()

        while ChestFarmEnabled do
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.2) continue end

            table.sort(CachedChests, function(a, b)
                return (a.Position - hrp.Position).Magnitude <
                       (b.Position - hrp.Position).Magnitude
            end)

            for _, chest in ipairs(CachedChests) do
                if not ChestFarmEnabled then break end
                if chest and chest.Parent then
                    TweenTo(chest.CFrame * CFrame.new(0,3,0))
                    task.wait(0.1)
                end
            end

            task.wait(1)
            CacheChests()
        end

        ChestFarmThread = nil
    end)
end

AutofarmTab:CreateToggle({
    Name = "Enable Chest Autofarm",
    CurrentValue = false,
    Callback = function(Value)
        ChestFarmEnabled = Value
        if not Value then
            StopTween = true
            if CurrentTween then CurrentTween:Cancel() end
        else
            StartChestFarm()
        end
    end
})


Rayfield:Notify({
    Title = "KattHub",
    Content = "Loaded successfully (" .. CurrentSea .. ")",
    Duration = 3
})

local VisualsTab = Window:CreateTab("Visuals", "eye")
AutofarmTab:CreateSection("Combat Farms")
VisualsTab:CreateSection("ESP Options")

local VirtualUser = game:GetService("VirtualUser")

local AutoLevel = false
local AutoBoss = false
local AutoRaid = false

local WeaponType = "Melee"

AutofarmTab:CreateDropdown({
    Name = "Weapon Select",
    Options = {"Melee", "Fruit", "Sword", "Gun"},
    CurrentOption = "Melee",
    Callback = function(opt)
        WeaponType = typeof(opt) == "table" and opt[1] or opt
    end
})

local function EquipWeapon()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = LP:FindFirstChild("Backpack")
    if not hum or not bp then return end

    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            if WeaponType == "Melee" and tool.ToolTip == "Melee" then hum:EquipTool(tool) return end
            if WeaponType == "Sword" and tool.ToolTip == "Sword" then hum:EquipTool(tool) return end
            if WeaponType == "Gun" and tool.ToolTip == "Gun" then hum:EquipTool(tool) return end
            if WeaponType == "Fruit" and tool.ToolTip == "Blox Fruit" then hum:EquipTool(tool) return end
        end
    end
end

local function AttackEnemy(enemy)
    if not enemy
    or not enemy:FindFirstChild("Humanoid")
    or not enemy:FindFirstChild("HumanoidRootPart")
    or enemy.Humanoid.Health <= 0 then return end

    EquipWeapon()

    TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 6))

    VirtualUser:Button1Down(Vector2.new(0,0))
    task.wait(0.06)
    VirtualUser:Button1Up(Vector2.new(0,0))
end

AutofarmTab:CreateToggle({
    Name = "Auto Level / Money",
    CurrentValue = false,
    Callback = function(v)
        AutoLevel = v
        task.spawn(function()
            while AutoLevel do
                pcall(function()
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid")
                        and enemy.Humanoid.Health > 0 then
                            AttackEnemy(enemy)
                        end
                    end
                end)
                task.wait(0.15)
            end
        end)
    end
})

AutofarmTab:CreateToggle({
    Name = "Auto Boss Farm",
    CurrentValue = false,
    Callback = function(v)
        AutoBoss = v
        task.spawn(function()
            while AutoBoss do
                pcall(function()
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy.Name:lower():find("boss")
                        and enemy:FindFirstChild("Humanoid")
                        and enemy.Humanoid.Health > 0 then
                            AttackEnemy(enemy)
                        end
                    end
                end)
                task.wait(0.2)
            end
        end)
    end
})

AutofarmTab:CreateToggle({
    Name = "Auto Raid (Fragments/Beli)",
    CurrentValue = false,
    Callback = function(v)
        AutoRaid = v
        task.spawn(function()
            while AutoRaid do
                pcall(function()
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid")
                        and enemy.Humanoid.Health > 0 then
                            AttackEnemy(enemy)
                        end
                    end
                end)
                task.wait(0.12)
            end
        end)
    end
})

local ESPObjects = {}
local function CreateESP(part, text, color)
    if not part or ESPObjects[part] then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP"
    gui.Adornee = part
    gui.Size = UDim2.new(0, 120, 0, 40)
    gui.AlwaysOnTop = true
    gui.Parent = part

    local lbl = Instance.new("TextLabel", gui)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.new(1,1,1)
    lbl.TextStrokeTransparency = 0

    ESPObjects[part] = gui
end

local function ClearESP()
    for part, gui in pairs(ESPObjects) do
        if gui then gui:Destroy() end
        ESPObjects[part] = nil
    end
end


VisualsTab:CreateToggle({
    Name = "Player ESP",
    Callback = function(v)
        ClearESP()
        if not v then return end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                CreateESP(p.Character.Head, p.Name, Color3.fromRGB(0,255,255))
            end
        end
    end
})

VisualsTab:CreateToggle({
    Name = "NPC ESP",
    Callback = function(v)
            ClearESP()
            if not v then return end
            
        for _, npc in pairs(workspace.Enemies:GetChildren()) do
            if npc:FindFirstChild("Head") and v then
                CreateESP(npc.Head, npc.Name, Color3.fromRGB(255,0,0))
            end
        end
    end
})

VisualsTab:CreateToggle({
    Name = "Chest ESP",
    Callback = function(v)
            ClearESP()
            if not v then return end
            
        for _, c in pairs(workspace:GetDescendants()) do
            if c:IsA("BasePart") and c.Name:lower():find("chest") and v then
                CreateESP(c, "Chest", Color3.fromRGB(255,215,0))
            end
        end
    end
})

VisualsTab:CreateToggle({
    Name = "Fruit ESP",
    Callback = function(v)
            ClearESP()
            if not v then return end
            
        for _, f in pairs(workspace:GetDescendants()) do
            if f.Name:lower():find("fruit") and f:IsA("Tool") and f:FindFirstChild("Handle") and v then
                CreateESP(f.Handle, f.Name, Color3.fromRGB(0,255,0))
            end
        end
    end
})
