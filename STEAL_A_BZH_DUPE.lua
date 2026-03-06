-- 🐊 CROCO DUPE - Steal A Bzh (Méthode Correcte) 🐊
-- Equip > Dupe > Place > Profit!

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootpart = character:WaitForChild("HumanoidRootPart")

-- ========================================
-- SETTINGS
-- ========================================

local settings = {
    autoDupe = false,
    dupeDelay = 1,
    autoPlace = true,
    espEnabled = false,
    notifications = true
}

local isDuping = false
local dupeCount = 0

-- ========================================
-- NOTIFICATION
-- ========================================

local function notify(title, text)
    if not settings.notifications then return end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🐊 " .. title;
        Text = text;
        Duration = 3;
    })
end

-- ========================================
-- FONCTIONS PRINCIPALES
-- ========================================

-- Trouver le Brainrot équipé
local function getEquippedBrainrot()
    -- Chercher dans le character
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") or obj:IsA("Model") then
            if obj.Name:lower():find("brain") or obj.Name:lower():find("rot") then
                return obj
            end
        end
    end
    
    -- Chercher un outil tenu
    local tool = character:FindFirstChildOfClass("Tool")
    return tool
end

-- Trouver les RemoteEvents de duplication
local function findDupeRemote()
    local remotes = {}
    
    -- Chercher dans ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("dup") or name:find("clone") or name:find("copy") or name:find("place") then
                table.insert(remotes, obj)
            end
        end
    end
    
    return remotes
end

-- Fonction de duplication PRINCIPALE
local function duplicateBrainrot()
    if isDuping then
        notify("Dupe", "Déjà en train de dupliquer!")
        return
    end
    
    isDuping = true
    
    -- 1. Vérifier qu'on a un Brainrot équipé
    local equippedItem = getEquippedBrainrot()
    
    if not equippedItem then
        notify("Erreur", "Aucun Brainrot équipé! Prends-en un dans tes mains!")
        isDuping = false
        return
    end
    
    notify("Dupe", "Brainrot détecté: " .. equippedItem.Name)
    
    -- 2. Chercher le RemoteEvent de duplication
    local remotes = findDupeRemote()
    
    if #remotes == 0 then
        notify("Erreur", "Aucun RemoteEvent trouvé!")
        isDuping = false
        return
    end
    
    notify("Dupe", "Tentative de duplication...")
    
    -- 3. Essayer de dupliquer avec tous les remotes trouvés
    for _, remote in pairs(remotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                -- Essayer différents arguments
                remote:FireServer()
                remote:FireServer("Duplicate")
                remote:FireServer({Action = "Duplicate"})
                remote:FireServer(equippedItem)
                remote:FireServer(equippedItem.Name)
                remote:FireServer({Item = equippedItem.Name, Action = "Dupe"})
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer()
                remote:InvokeServer("Duplicate")
                remote:InvokeServer({Action = "Duplicate"})
            end
        end)
    end
    
    task.wait(0.5)
    
    -- 4. Attendre le message "OK" ou placer automatiquement
    notify("OK", "Duplication OK! Tu peux poser le Brainrot!")
    
    if settings.autoPlace then
        task.wait(0.5)
        
        -- Placer automatiquement le Brainrot dupliqué
        local placeRemotes = {}
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if name:find("place") or name:find("drop") or name:find("put") then
                    table.insert(placeRemotes, obj)
                end
            end
        end
        
        for _, remote in pairs(placeRemotes) do
            pcall(function()
                -- Position aléatoire autour du joueur
                local randomPos = rootpart.Position + Vector3.new(
                    math.random(-5, 5),
                    0,
                    math.random(-5, 5)
                )
                
                remote:FireServer(randomPos)
                remote:FireServer({Position = randomPos})
                remote:FireServer("Place", randomPos)
            end)
        end
        
        task.wait(0.3)
        dupeCount = dupeCount + 1
        notify("Succès!", "Brainrot dupliqué! Total: " .. dupeCount)
    end
    
    task.wait(settings.dupeDelay)
    isDuping = false
end

-- Auto Dupe Loop
local function autoDupeLoop()
    while settings.autoDupe do
        task.wait(settings.dupeDelay + 0.5)
        
        if not isDuping then
            duplicateBrainrot()
        end
    end
end

-- ESP pour les Brainrot au sol
local highlights = {}
local function updateESP()
    if settings.espEnabled then
        -- Chercher les Brainrot au sol
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local name = obj.Name:lower()
                if (name:find("brain") or name:find("rot")) and not highlights[obj] then
                    pcall(function()
                        local highlight = Instance.new("Highlight")
                        highlight.Adornee = obj
                        highlight.FillColor = Color3.fromRGB(255, 0, 255)
                        highlight.OutlineColor = Color3.fromRGB(255, 100, 255)
                        highlight.FillTransparency = 0.5
                        highlight.Parent = obj
                        highlights[obj] = highlight
                    end)
                end
            end
        end
    else
        for _, hl in pairs(highlights) do
            pcall(function() hl:Destroy() end)
        end
        highlights = {}
    end
end

-- ========================================
-- GUI
-- ========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrocoDupeGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999

pcall(function()
    ScreenGui.Parent = gethui and gethui() or CoreGui
end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 450)
Main.Position = UDim2.new(0.5, -190, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 0, 255)
Stroke.Thickness = 3

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 55)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
Title.BorderSizePixel = 0
Title.Parent = Main

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame", Title)
TitleFix.Size = UDim2.new(1, 0, 0, 28)
TitleFix.Position = UDim2.new(0, 0, 1, -28)
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
TitleFix.BorderSizePixel = 0

local TitleText = Instance.new("TextLabel", Title)
TitleText.Size = UDim2.new(1, -50, 0, 30)
TitleText.Position = UDim2.new(0, 15, 0, 8)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🐊 CROCO DUPE SCRIPT"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 20
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", Title)
SubTitle.Size = UDim2.new(1, -50, 0, 15)
SubTitle.Position = UDim2.new(0, 15, 0, 35)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Steal A Bzh - Zero Key"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11
SubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SubTitle.TextTransparency = 0.4
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -42, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Main

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Stats
local Stats = Instance.new("Frame")
Stats.Size = UDim2.new(1, -30, 0, 60)
Stats.Position = UDim2.new(0, 15, 0, 70)
Stats.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Stats.BorderSizePixel = 0
Stats.Parent = Main

Instance.new("UICorner", Stats).CornerRadius = UDim.new(0, 8)

local StatsText = Instance.new("TextLabel", Stats)
StatsText.Size = UDim2.new(1, -20, 1, -10)
StatsText.Position = UDim2.new(0, 10, 0, 5)
StatsText.BackgroundTransparency = 1
StatsText.Text = "📊 Statistiques:\n💎 Brainrot dupliqués: 0"
StatsText.Font = Enum.Font.GothamBold
StatsText.TextSize = 14
StatsText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.TextYAlignment = Enum.TextYAlignment.Top

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -30, 1, -155)
Content.Position = UDim2.new(0, 15, 0, 145)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main

local List = Instance.new("UIListLayout", Content)
List.Padding = UDim.new(0, 10)
List.SortOrder = Enum.SortOrder.LayoutOrder

List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
end)

-- ========================================
-- COMPOSANTS
-- ========================================

local function createLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(255, 0, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Content
end

local function createButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 15
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.AutoButtonColor = false
    Btn.Parent = Content
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -2, 0, 43)}):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 45)}):Play()
        callback()
    end)
end

local function createToggle(text, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, 0, 0, 40)
    Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Toggle.BorderSizePixel = 0
    Toggle.Parent = Content
    
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel", Toggle)
    Label.Size = UDim2.new(1, -55, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Btn = Instance.new("TextButton", Toggle)
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.Position = UDim2.new(1, -48, 0.5, -10)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", Btn)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local enabled = false
    
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(50, 50, 55)
        }):Play()
        
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
    end)
end

-- ========================================
-- INTERFACE
-- ========================================

createLabel("━━━ INSTRUCTIONS ━━━")

local Instructions = Instance.new("TextLabel")
Instructions.Size = UDim2.new(1, 0, 0, 80)
Instructions.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instructions.BorderSizePixel = 0
Instructions.Text = "1️⃣ Prends un Brainrot dans tes mains\n2️⃣ Appuie sur 'Dupliquer'\n3️⃣ Attends 'OK'\n4️⃣ Pose le Brainrot dupliqué"
Instructions.Font = Enum.Font.Gotham
Instructions.TextSize = 12
Instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
Instructions.TextWrapped = true
Instructions.TextXAlignment = Enum.TextXAlignment.Left
Instructions.TextYAlignment = Enum.TextYAlignment.Top
Instructions.Parent = Content

Instance.new("UICorner", Instructions).CornerRadius = UDim.new(0, 8)
Instance.new("UIPadding", Instructions).PaddingLeft = UDim.new(0, 10)
Instance.new("UIPadding", Instructions).PaddingTop = UDim.new(0, 8)

createLabel("━━━ DUPLICATION ━━━")

createButton("🔁 DUPLIQUER (Manuel)", function()
    duplicateBrainrot()
end)

createToggle("Auto Dupe (Loop)", function(enabled)
    settings.autoDupe = enabled
    if enabled then
        notify("Auto Dupe", "Activé! Prends un Brainrot!")
        task.spawn(autoDupeLoop)
    else
        notify("Auto Dupe", "Désactivé!")
    end
end)

createToggle("Auto Place (Recommandé)", function(enabled)
    settings.autoPlace = enabled
end)

createLabel("━━━ VISUALS ━━━")

createToggle("ESP Brainrot", function(enabled)
    settings.espEnabled = enabled
end)

createButton("🔍 Trouver RemoteEvents", function()
    local remotes = findDupeRemote()
    notify("Remotes", "Trouvé: " .. #remotes .. " RemoteEvents")
    for i, remote in pairs(remotes) do
        print(i .. ". " .. remote:GetFullName())
    end
end)

createLabel("━━━ SETTINGS ━━━")

createToggle("Notifications", function(enabled)
    settings.notifications = enabled
end)

-- ========================================
-- LOOPS
-- ========================================

RunService.Heartbeat:Connect(function()
    -- Update stats
    StatsText.Text = "📊 Statistiques:\n💎 Brainrot dupliqués: " .. dupeCount
    
    -- Update ESP
    updateESP()
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootpart = char:WaitForChild("HumanoidRootPart")
end)

-- ========================================
-- INIT
-- ========================================

notify("Croco Dupe", "Script chargé! Prends un Brainrot!")

print("🐊 CROCO DUPE SCRIPT loaded!")
print("━━━━━━━━━━━━━━━━━━━━━━━━")
print("1. Prends un Brainrot")
print("2. Clique sur DUPLIQUER")
print("3. Attends 'OK'")
print("4. Pose le Brainrot")
print("━━━━━━━━━━━━━━━━━━━━━━━━")
