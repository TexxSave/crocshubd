-- 🐊 CROCO DUPE V3 - STEALTH MODE 🐊
-- Anti-detect + Bypass anticheat

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
-- ANTI-DETECT SETTINGS
-- ========================================

local settings = {
    autoDupe = false,
    dupeDelay = 2, -- Délai entre chaque dupe (IMPORTANT pour éviter le kick)
    safeMode = true, -- Mode sécurisé
    autoCollect = false,
    espEnabled = false
}

local dupeCount = 0
local lastDupeTime = 0
local isDuping = false

-- ========================================
-- ANTI-KICK PROTECTION
-- ========================================

-- Bloquer les kicks
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Bloquer les kicks
    if method == "Kick" then
        return
    end
    
    -- Bloquer les teleports (qui peuvent kick)
    if method == "TeleportToPlaceInstance" or method == "Teleport" then
        return
    end
    
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- ========================================
-- NOTIFICATION
-- ========================================

local function notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🐊 " .. title;
        Text = text;
        Duration = 2;
    })
end

-- ========================================
-- DÉTECTION SAFE
-- ========================================

local function findEquippedTool()
    -- Chercher dans le character seulement (safe)
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            return obj
        end
    end
    return nil
end

-- ========================================
-- DUPLICATION SAFE (Méthode Client-Side)
-- ========================================

local function safeDuplicate()
    -- Vérifier le cooldown (IMPORTANT!)
    local currentTime = tick()
    if currentTime - lastDupeTime < settings.dupeDelay then
        notify("⏳ Cooldown", "Attends " .. math.ceil(settings.dupeDelay - (currentTime - lastDupeTime)) .. "s")
        return
    end
    
    if isDuping then return end
    isDuping = true
    
    local tool = findEquippedTool()
    
    if not tool then
        notify("⚠️ Attention", "Équipe un Brainrot!")
        isDuping = false
        return
    end
    
    notify("🔁 Dupe", "Duplication...")
    
    task.spawn(function()
        -- MÉTHODE SAFE : Clone client-side puis synchronise
        pcall(function()
            -- 1. Clone le tool
            local clone = tool:Clone()
            
            -- 2. Attendre un peu (pour éviter l'anticheat)
            task.wait(0.3)
            
            -- 3. Mettre le clone dans le backpack
            clone.Parent = player.Backpack
            
            task.wait(0.2)
            
            -- 4. Équiper le clone
            humanoid:EquipTool(clone)
            
            task.wait(0.2)
            
            -- 5. Essayer de "placer" via le RemoteEvent (UNE SEULE FOIS!)
            local placed = false
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if not placed and remote:IsA("RemoteEvent") then
                    local name = remote.Name:lower()
                    if name:find("place") or name:find("drop") then
                        -- Une seule tentative, pas de spam!
                        pcall(function()
                            local pos = rootpart.Position + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
                            remote:FireServer(pos)
                        end)
                        placed = true
                        break
                    end
                end
            end
            
            task.wait(0.5)
        end)
        
        dupeCount = dupeCount + 1
        lastDupeTime = tick()
        notify("✅ OK!", "Dupliqué! Total: " .. dupeCount)
        
        isDuping = false
    end)
end

-- ========================================
-- AUTO DUPE SAFE
-- ========================================

local function autoDupeLoop()
    while settings.autoDupe do
        task.wait(settings.dupeDelay + 1) -- Délai safe
        
        if not isDuping then
            safeDuplicate()
        end
    end
end

-- ========================================
-- AUTO COLLECT (VERSION SAFE)
-- ========================================

local function safeCollect()
    while settings.autoCollect do
        task.wait(0.5) -- Pas trop rapide
        
        pcall(function()
            -- Chercher les "Collect" proches seulement
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj.Name == "Collect" and obj:IsA("Model") then
                    local dist = (rootpart.Position - obj:GetPivot().Position).Magnitude
                    
                    if dist < 50 then -- Seulement les proches
                        -- Téléport smooth (pas instantané)
                        local targetPos = obj:GetPivot().Position
                        
                        for i = 0, 1, 0.2 do
                            if not settings.autoCollect then break end
                            rootpart.CFrame = rootpart.CFrame:Lerp(CFrame.new(targetPos), i)
                            task.wait(0.05)
                        end
                        
                        task.wait(0.3)
                    end
                end
            end
        end)
    end
end

-- ========================================
-- ESP SAFE
-- ========================================

local highlights = {}
local function updateESP()
    if settings.espEnabled then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj.Name == "Collect" and obj:IsA("Model") and not highlights[obj] then
                pcall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = obj
                    highlight.FillColor = Color3.fromRGB(255, 215, 0)
                    highlight.OutlineColor = Color3.fromRGB(200, 150, 0)
                    highlight.FillTransparency = 0.6
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
-- GUI DISCRET
-- ========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrocoStealthGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999

pcall(function()
    ScreenGui.Parent = gethui and gethui() or CoreGui
end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 320)
Main.Position = UDim2.new(0.5, -140, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(100, 200, 100)
Stroke.Thickness = 2

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
Title.Text = "🐊 STEALTH DUPE"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.BorderSizePixel = 0
Title.Parent = Main

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local TitleFix = Instance.new("Frame", Title)
TitleFix.Size = UDim2.new(1, 0, 0, 23)
TitleFix.Position = UDim2.new(0, 0, 1, -23)
TitleFix.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
TitleFix.BorderSizePixel = 0

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -35, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Main

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 7)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 45)
Status.Position = UDim2.new(0, 10, 0, 55)
Status.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Status.Text = "🔒 Mode Stealth ACTIVÉ\n💎 Dupliqués: 0"
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.TextColor3 = Color3.fromRGB(100, 200, 100)
Status.BorderSizePixel = 0
Status.Parent = Main

Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 8)

-- Boutons
local y = 110

local function createButton(text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Position = UDim2.new(0, 10, 0, y)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.AutoButtonColor = false
    Btn.BorderSizePixel = 0
    Btn.Parent = Main
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(callback)
    
    y = y + 48
    return Btn
end

local function createToggle(text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 35)
    Frame.Position = UDim2.new(0, 10, 0, y)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = Main
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -45, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 32, 0, 16)
    Btn.Position = UDim2.new(1, -38, 0.5, -8)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", Btn)
    Circle.Size = UDim2.new(0, 12, 0, 12)
    Circle.Position = UDim2.new(0, 2, 0.5, -6)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local enabled = false
    
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(50, 50, 55)
        }):Play()
        
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        }):Play()
    end)
    
    y = y + 43
end

-- Interface
createButton("🔁 DUPLIQUER (Safe)", Color3.fromRGB(100, 200, 100), function()
    safeDuplicate()
end)

createToggle("Auto Dupe", function(enabled)
    settings.autoDupe = enabled
    if enabled then
        notify("Auto Dupe", "Mode Stealth activé!")
        task.spawn(autoDupeLoop)
    end
end)

createToggle("Auto Collect", function(enabled)
    settings.autoCollect = enabled
    if enabled then
        task.spawn(safeCollect)
    end
end)

createToggle("ESP Money", function(enabled)
    settings.espEnabled = enabled
end)

-- ========================================
-- LOOPS
-- ========================================

RunService.Heartbeat:Connect(function()
    Status.Text = "🔒 Mode Stealth ACTIVÉ\n💎 Dupliqués: " .. dupeCount
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
    
    if input.KeyCode == Enum.KeyCode.F then
        safeDuplicate()
    end
end)

-- ========================================
-- INIT
-- ========================================

notify("Stealth Dupe", "Mode Anti-Detect activé! Appuie F!")

print("🐊 STEALTH DUPE V3 LOADED!")
print("━━━━━━━━━━━━━━━━━━━━")
print("✅ Anti-Kick Protection")
print("⏱️ Cooldown: 2s (safe)")
print("🔑 Appuie sur F pour dupliquer")
print("━━━━━━━━━━━━━━━━━━━━")
