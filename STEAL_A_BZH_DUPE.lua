-- 🐊 CROCO DUPE V2 - Steal A Bzh (FIXED) 🐊
-- Détection améliorée + Auto Dupe

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
    dupeSpeed = 0.5, -- Vitesse de dupe (plus petit = plus rapide)
    autoCollect = false,
    espEnabled = false,
    notifications = true
}

local dupeCount = 0
local isDuping = false

-- ========================================
-- NOTIFICATION
-- ========================================

local function notify(title, text)
    if not settings.notifications then return end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🐊 " .. title;
        Text = text;
        Duration = 2;
    })
end

-- ========================================
-- DÉTECTION AMÉLIORÉE
-- ========================================

-- Trouver TOUS les Brainrot équipés (méthode améliorée)
local function findEquippedBrainrot()
    -- Méthode 1 : Dans le character
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            return obj
        end
        if obj:IsA("Model") and obj ~= character then
            return obj
        end
    end
    
    -- Méthode 2 : Dans le backpack du joueur
    for _, obj in pairs(player:WaitForChild("Backpack"):GetChildren()) do
        if obj:IsA("Tool") then
            -- Équiper l'outil automatiquement
            humanoid:EquipTool(obj)
            task.wait(0.1)
            return obj
        end
    end
    
    return nil
end

-- Trouver les RemoteEvents
local function findAllRemotes()
    local remotes = {}
    
    -- Chercher PARTOUT
    for _, location in pairs({ReplicatedStorage, Workspace}) do
        for _, obj in pairs(location:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotes, obj)
            end
        end
    end
    
    return remotes
end

-- ========================================
-- DUPLICATION AMÉLIORÉE
-- ========================================

local function duplicateNow()
    if isDuping then return end
    isDuping = true
    
    -- Trouver le Brainrot équipé
    local item = findEquippedBrainrot()
    
    if not item then
        notify("⚠️ Attention", "Prends un Brainrot d'abord!")
        isDuping = false
        return
    end
    
    notify("🔁 Dupe", "Duplication en cours...")
    
    -- Trouver tous les RemoteEvents
    local remotes = findAllRemotes()
    
    -- SPAM TOUS LES REMOTES avec plein d'arguments différents
    for _, remote in pairs(remotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                -- Essayer TOUS les arguments possibles
                remote:FireServer()
                remote:FireServer("Place")
                remote:FireServer("Duplicate")
                remote:FireServer("Clone")
                remote:FireServer({Action = "Duplicate"})
                remote:FireServer({Action = "Place"})
                remote:FireServer({Action = "Clone"})
                remote:FireServer(item)
                remote:FireServer(item.Name)
                remote:FireServer({Item = item})
                remote:FireServer({Item = item.Name})
                remote:FireServer("E") -- Touche Place
                remote:FireServer({Key = "E"})
                remote:FireServer({KeyCode = Enum.KeyCode.E})
                
                -- Positions
                local pos = rootpart.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                remote:FireServer(pos)
                remote:FireServer({Position = pos})
                remote:FireServer("Place", pos)
                remote:FireServer({Action = "Place", Position = pos})
            end
        end)
    end
    
    task.wait(settings.dupeSpeed)
    
    dupeCount = dupeCount + 1
    notify("✅ Succès!", "Dupliqué! Total: " .. dupeCount)
    
    isDuping = false
end

-- Auto Dupe Loop
local function autoDupeLoop()
    while settings.autoDupe do
        duplicateNow()
        task.wait(settings.dupeSpeed + 0.1)
    end
end

-- Auto Collect Money
local function autoCollectMoney()
    while settings.autoCollect do
        task.wait(0.1)
        
        -- Chercher les "Collect" dans le workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Collect" and obj:IsA("Model") then
                pcall(function()
                    -- Téléporter vers le collect
                    local collectPos = obj:GetPivot().Position
                    rootpart.CFrame = CFrame.new(collectPos)
                    task.wait(0.05)
                    
                    -- Trigger collection
                    for _, part in pairs(obj:GetDescendants()) do
                        if part:IsA("ClickDetector") then
                            fireclickdetector(part)
                        elseif part:IsA("ProximityPrompt") then
                            fireproximityprompt(part)
                        end
                    end
                end)
            end
        end
    end
end

-- ESP
local highlights = {}
local function updateESP()
    if settings.espEnabled then
        -- ESP sur les Collect
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Collect" and obj:IsA("Model") and not highlights[obj] then
                pcall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = obj
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = obj
                    highlights[obj] = highlight
                end)
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
-- GUI MODERNE
-- ========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrocoDupeV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999

pcall(function()
    ScreenGui.Parent = gethui and gethui() or CoreGui
end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 380)
Main.Position = UDim2.new(0.5, -160, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 100, 255)
Stroke.Thickness = 3

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(255, 100, 255)
Title.Text = "🐊 CROCO DUPE V2"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 0
Title.Parent = Main

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame", Title)
TitleFix.Size = UDim2.new(1, 0, 0, 25)
TitleFix.Position = UDim2.new(0, 0, 1, -25)
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 100, 255)
TitleFix.BorderSizePixel = 0

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Main

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Stats
local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(1, -30, 0, 50)
Stats.Position = UDim2.new(0, 15, 0, 65)
Stats.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Stats.Text = "💎 Dupliqués: 0"
Stats.Font = Enum.Font.GothamBold
Stats.TextSize = 16
Stats.TextColor3 = Color3.fromRGB(255, 255, 255)
Stats.BorderSizePixel = 0
Stats.Parent = Main

Instance.new("UICorner", Stats).CornerRadius = UDim.new(0, 8)

-- Boutons
local y = 130

local function createButton(text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -30, 0, 45)
    Btn.Position = UDim2.new(0, 15, 0, y)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 15
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.AutoButtonColor = false
    Btn.BorderSizePixel = 0
    Btn.Parent = Main
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(callback)
    
    y = y + 55
    return Btn
end

local function createToggle(text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -30, 0, 40)
    Frame.Position = UDim2.new(0, 15, 0, y)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Frame.BorderSizePixel = 0
    Frame.Parent = Main
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 35, 0, 18)
    Btn.Position = UDim2.new(1, -43, 0.5, -9)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", Btn)
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 2, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local enabled = false
    
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(255, 100, 255) or Color3.fromRGB(50, 50, 55)
        }):Play()
        
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
    end)
    
    y = y + 50
end

-- Interface
createButton("🔁 DUPLIQUER", Color3.fromRGB(255, 100, 255), function()
    duplicateNow()
end)

createToggle("Auto Dupe", function(enabled)
    settings.autoDupe = enabled
    if enabled then
        notify("Auto Dupe", "ACTIVÉ!")
        task.spawn(autoDupeLoop)
    else
        notify("Auto Dupe", "Désactivé")
    end
end)

createToggle("Auto Collect $", function(enabled)
    settings.autoCollect = enabled
    if enabled then
        notify("Auto Collect", "ACTIVÉ!")
        task.spawn(autoCollectMoney)
    else
        notify("Auto Collect", "Désactivé")
    end
end)

createToggle("ESP Money", function(enabled)
    settings.espEnabled = enabled
end)

-- ========================================
-- LOOPS
-- ========================================

RunService.Heartbeat:Connect(function()
    Stats.Text = "💎 Dupliqués: " .. dupeCount
    updateESP()
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootpart = char:WaitForChild("HumanoidRootPart")
end)

-- ========================================
-- KEYBIND
-- ========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Touche E pour dupliquer rapidement
    if input.KeyCode == Enum.KeyCode.E then
        duplicateNow()
    end
end)

-- ========================================
-- INIT
-- ========================================

notify("Croco Dupe V2", "Chargé! Appuie sur E pour dupliquer!")

print("🐊 CROCO DUPE V2 LOADED!")
print("━━━━━━━━━━━━━━━━━━━━━━")
print("• Appuie sur E pour dupliquer")
print("• Active Auto Dupe pour farmer")
print("• Auto Collect pour ramasser l'argent")
print("━━━━━━━━━━━━━━━━━━━━━━")
