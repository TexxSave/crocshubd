-- 🐊 CROCO DUPE SCRIPT - Steal A Bzh 🐊
-- Auto Dupe + Auto Collect + ESP

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
    autoCollect = false,
    espEnabled = false,
    teleportSpeed = 1,
    dupeAmount = 10,
    farmBrainrot = false,
    autoSell = false
}

-- ========================================
-- FONCTIONS PRINCIPALES
-- ========================================

-- Trouver les Brainrot
local function findBrainrots()
    local brainrots = {}
    
    -- Chercher dans Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("brainrot") or 
           obj.Name:lower():find("item") or 
           obj.Name:lower():find("collectible") then
            if obj:IsA("Model") or obj:IsA("Part") then
                table.insert(brainrots, obj)
            end
        end
    end
    
    return brainrots
end

-- Téléportation rapide
local function teleportTo(position)
    if rootpart then
        rootpart.CFrame = CFrame.new(position)
    end
end

-- Auto Collect
local function autoCollect()
    while settings.autoCollect do
        task.wait(0.1)
        
        local brainrots = findBrainrots()
        
        for _, brainrot in pairs(brainrots) do
            if settings.autoCollect and brainrot:IsDescendantOf(Workspace) then
                pcall(function()
                    local pos = brainrot:IsA("Model") and brainrot:GetPivot().Position or brainrot.Position
                    teleportTo(pos)
                    task.wait(0.1)
                    
                    -- Trigger collection
                    if brainrot:FindFirstChild("ClickDetector") then
                        fireclickdetector(brainrot.ClickDetector)
                    elseif brainrot:FindFirstChild("ProximityPrompt") then
                        fireproximityprompt(brainrot.ProximityPrompt)
                    end
                end)
            end
        end
    end
end

-- Duplication Method 1 : RemoteEvent Spam
local function dupeMethod1()
    pcall(function()
        local Remote = ReplicatedStorage:FindFirstChild("Events") or 
                      ReplicatedStorage:FindFirstChild("Remotes") or
                      ReplicatedStorage:FindFirstChild("NetworkFolder")
        
        if Remote then
            for _, event in pairs(Remote:GetDescendants()) do
                if event:IsA("RemoteEvent") then
                    -- Spam le remote avec différents arguments
                    for i = 1, settings.dupeAmount do
                        pcall(function()
                            event:FireServer("Duplicate")
                            event:FireServer({Action = "Dupe"})
                            event:FireServer("Clone")
                            event:FireServer({Type = "Item", Action = "Clone"})
                        end)
                    end
                end
            end
        end
    end)
end

-- Duplication Method 2 : Inventory Manipulation
local function dupeMethod2()
    pcall(function()
        local inventory = player:FindFirstChild("Inventory") or 
                         player:FindFirstChild("Backpack") or
                         player:FindFirstChild("Items")
        
        if inventory then
            -- Clone tous les items
            for _, item in pairs(inventory:GetChildren()) do
                for i = 1, settings.dupeAmount do
                    pcall(function()
                        local clone = item:Clone()
                        clone.Parent = inventory
                    end)
                end
            end
        end
    end)
end

-- Duplication Method 3 : Server Desync
local function dupeMethod3()
    pcall(function()
        -- Sauvegarder position
        local originalPos = rootpart.CFrame
        
        -- Drop item
        local Remote = ReplicatedStorage:FindFirstChild("Events")
        if Remote then
            for _, event in pairs(Remote:GetDescendants()) do
                if event:IsA("RemoteEvent") and (event.Name:lower():find("drop") or event.Name:lower():find("place")) then
                    -- Drop item
                    event:FireServer()
                    
                    -- Teleport loin
                    task.wait(0.05)
                    teleportTo(originalPos.Position + Vector3.new(1000, 1000, 1000))
                    
                    -- Attendre
                    task.wait(0.1)
                    
                    -- Revenir
                    teleportTo(originalPos.Position)
                    
                    -- Pick up
                    task.wait(0.1)
                end
            end
        end
    end)
end

-- Auto Dupe (essaie toutes les méthodes)
local function autoDupe()
    while settings.autoDupe do
        print("🐊 Attempting duplication...")
        
        -- Méthode 1
        dupeMethod1()
        task.wait(0.5)
        
        -- Méthode 2
        dupeMethod2()
        task.wait(0.5)
        
        -- Méthode 3
        dupeMethod3()
        task.wait(2)
    end
end

-- Auto Sell
local function autoSell()
    while settings.autoSell do
        task.wait(5)
        
        pcall(function()
            -- Trouver le vendeur/shop
            local shop = Workspace:FindFirstChild("Shop") or 
                        Workspace:FindFirstChild("Seller") or
                        Workspace:FindFirstChild("NPC")
            
            if shop then
                local shopPos = shop:IsA("Model") and shop:GetPivot().Position or shop.Position
                teleportTo(shopPos)
                task.wait(0.5)
                
                -- Trigger vente
                local Remote = ReplicatedStorage:FindFirstChild("Events")
                if Remote then
                    for _, event in pairs(Remote:GetDescendants()) do
                        if event:IsA("RemoteEvent") and (event.Name:lower():find("sell") or event.Name:lower():find("trade")) then
                            event:FireServer("SellAll")
                            event:FireServer({Action = "Sell", Amount = "All"})
                        end
                    end
                end
            end
        end)
    end
end

-- ESP pour Brainrot
local highlights = {}
local function updateESP()
    if settings.espEnabled then
        local brainrots = findBrainrots()
        
        for _, brainrot in pairs(brainrots) do
            if not highlights[brainrot] then
                pcall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "CrocoESP"
                    highlight.Adornee = brainrot
                    highlight.FillColor = Color3.fromRGB(255, 215, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 165, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = brainrot
                    highlights[brainrot] = highlight
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
-- GUI
-- ========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrocoDupeGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999

pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 350, 0, 400)
Main.Position = UDim2.new(0.5, -175, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 215, 0)
Stroke.Thickness = 3

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Title.Text = "🐊 CROCO DUPE SCRIPT"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Parent = Main

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame", Title)
TitleFix.Size = UDim2.new(1, 0, 0, 25)
TitleFix.Position = UDim2.new(0, 0, 1, -25)
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
TitleFix.BorderSizePixel = 0

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -42, 0, 7)
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

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 60)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main

local List = Instance.new("UIListLayout", Content)
List.Padding = UDim.new(0, 8)
List.SortOrder = Enum.SortOrder.LayoutOrder

List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
end)

-- ========================================
-- CRÉER BOUTONS
-- ========================================

local function createToggle(text, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -10, 0, 40)
    Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Toggle.BorderSizePixel = 0
    Toggle.Parent = Content
    
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel", Toggle)
    Label.Size = UDim2.new(1, -55, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
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
            BackgroundColor3 = enabled and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50, 50, 55)
        }):Play()
        
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
    end)
end

local function createButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    Btn.AutoButtonColor = false
    Btn.Parent = Content
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -12, 0, 38)}):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        callback()
    end)
end

local function createLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(255, 215, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Content
end

-- ========================================
-- INTERFACE
-- ========================================

createLabel("━━━ DUPLICATION ━━━")

createToggle("Auto Dupe (All Methods)", function(enabled)
    settings.autoDupe = enabled
    if enabled then
        task.spawn(autoDupe)
    end
end)

createButton("🔁 Dupe Method 1 (RemoteSpam)", function()
    dupeMethod1()
    print("🐊 Method 1 executed!")
end)

createButton("📦 Dupe Method 2 (Inventory)", function()
    dupeMethod2()
    print("🐊 Method 2 executed!")
end)

createButton("⚡ Dupe Method 3 (Desync)", function()
    dupeMethod3()
    print("🐊 Method 3 executed!")
end)

createLabel("━━━ AUTO FARM ━━━")

createToggle("Auto Collect Brainrot", function(enabled)
    settings.autoCollect = enabled
    if enabled then
        task.spawn(autoCollect)
    end
end)

createToggle("Auto Sell", function(enabled)
    settings.autoSell = enabled
    if enabled then
        task.spawn(autoSell)
    end
end)

createLabel("━━━ VISUALS ━━━")

createToggle("ESP Brainrot", function(enabled)
    settings.espEnabled = enabled
end)

createButton("🔍 Find All Brainrot", function()
    local brainrots = findBrainrots()
    print("🐊 Found " .. #brainrots .. " brainrots!")
    for i, br in pairs(brainrots) do
        print(i .. ". " .. br.Name .. " at " .. tostring(br.Position or br:GetPivot().Position))
    end
end)

-- ========================================
-- LOOPS
-- ========================================

RunService.Heartbeat:Connect(function()
    updateESP()
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootpart = char:WaitForChild("HumanoidRootPart")
end)

-- ========================================
-- NOTIFICATION
-- ========================================

local function notify(text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🐊 Croco Dupe";
        Text = text;
        Duration = 3;
    })
end

notify("Script loaded! Ready to dupe!")

print("🐊 CROCO DUPE SCRIPT loaded!")
print("━━━━━━━━━━━━━━━━━━━━")
print("Features:")
print("• 3 Dupe Methods")
print("• Auto Collect")
print("• Auto Sell")
print("• ESP Brainrot")
print("━━━━━━━━━━━━━━━━━━━━")
