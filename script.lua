-- [[ 🌌 INFINITY EVO HUB v73.0 - BIGGER UI, REAL SPEED & ZERO-LAG JUMP 🌌 ]] --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local TargetGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui") or lp:WaitForChild("PlayerGui")

local Hub = { Toggles = {}, Tabs = {}, Pages = {} }
local currentTab = nil

-- PLATAFORMA AUXILIAR INVISÍVEL
local antiWater = workspace:FindFirstChild("InfinityAntiWaterFloor")
if not antiWater then
    antiWater = Instance.new("Part")
    antiWater.Name = "InfinityAntiWaterFloor"
    antiWater.Size = Vector3.new(2500, 10, 2500)
    antiWater.Transparency = 1
    antiWater.Anchored = true
    antiWater.CanCollide = true
    antiWater.Position = Vector3.new(0, -5, 0)
    antiWater.Parent = workspace
end

-- ==========================================
-- 🥊 EQUIPAR APENAS MELEE (IGNORA FRUTAS/ESPADAS)
-- ==========================================
local function equipMelee()
    local char = lp.Character
    local backpack = lp:FindFirstChild("Backpack")
    if not char or not backpack then return end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and equipped.ToolTip == "Melee" then
        return equipped
    end

    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == "Melee" then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:EquipTool(tool)
                return tool
            end
        end
    end
    return nil
end

-- ==========================================
-- ⚔️ MOTOR DE ATAQUE REAL (REGISTRA DANO NO SERVIDOR)
-- ==========================================
local function executeRealAttack(targetModel)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return end

    local meleeTool = equipMelee()
    if not meleeTool then return end

    targetRoot.Size = Vector3.new(45, 45, 45)
    targetRoot.CanCollide = false

    pcall(function()
        meleeTool:Activate()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))

        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local net = modules and modules:FindFirstChild("Net")
        if net then
            local regAttack = net:FindFirstChild("RE/RegisterAttack")
            local regHit = net:FindFirstChild("RE/RegisterHit")
            if regAttack and regHit then
                regAttack:FireServer(0.1)
                regHit:FireServer(targetRoot, {{targetModel, targetRoot}})
            end
        end

        local combatScript = lp.PlayerScripts:FindFirstChild("CombatFramework")
        if combatScript then
            local cf = require(combatScript)
            if cf and cf.activeController then
                cf.activeController:attack()
            end
        end
    end)
end

-- ==========================================
-- ✈️ MOVIMENTAÇÃO SUAVE ANTI-KICK
-- ==========================================
local activeTween = nil
local function bypassTweenTo(targetCFrame, speed)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    speed = speed or 240

    if activeTween then activeTween:Cancel() end

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

    hum.PlatformStand = true
    root.Velocity = Vector3.new(0, 0, 0)

    activeTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    activeTween:Play()

    activeTween.Completed:Connect(function()
        if hum then hum.PlatformStand = false end
        if root then root.Velocity = Vector3.new(0, 0, 0) end
    end)
end

-- ==========================================
-- 🖥️ CONSTRUTOR DA INTERFACE (PAINEL MAIOR 580x400 + VISOR DE FPS)
-- ==========================================
function Hub:CreateWindow(config)
    local sg = TargetGui:FindFirstChild("InfinityEvoUI")
    if sg then sg:Destroy() end
    sg = Instance.new("ScreenGui", TargetGui)
    sg.Name = "InfinityEvoUI"
    sg.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", sg)
    MainFrame.Size = UDim2.new(0, 580, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    MainFrame.Active = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Thickness = 2.5
    Stroke.Color = Color3.fromRGB(0, 255, 204)

    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 44)
    TitleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -160, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = config.Title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- VISOR DE FPS NO PAINEL
    local FpsLabel = Instance.new("TextLabel", TitleBar)
    FpsLabel.Size = UDim2.new(0, 70, 0, 26)
    FpsLabel.Position = UDim2.new(1, -118, 0.5, -13)
    FpsLabel.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    FpsLabel.Text = "FPS: 60"
    FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 153)
    FpsLabel.Font = Enum.Font.GothamBold
    FpsLabel.TextSize = 11
    Instance.new("UICorner", FpsLabel).CornerRadius = UDim.new(0, 5)

    local MinButton = Instance.new("TextButton", TitleBar)
    MinButton.Size = UDim2.new(0, 34, 0, 26)
    MinButton.Position = UDim2.new(1, -44, 0.5, -13)
    MinButton.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    MinButton.Text = "[-]"
    MinButton.TextColor3 = Color3.fromRGB(0, 255, 204)
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 12
    Instance.new("UICorner", MinButton).CornerRadius = UDim.new(0, 5)

    local TabContainer = Instance.new("ScrollingFrame", MainFrame)
    TabContainer.Size = UDim2.new(0, 145, 1, -60)
    TabContainer.Position = UDim2.new(0, 10, 0, 52)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 6)

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Size = UDim2.new(1, -175, 1, -60)
    PageContainer.Position = UDim2.new(0, 165, 0, 52)
    PageContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Instance.new("UICorner", PageContainer).CornerRadius = UDim.new(0, 8)

    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local minimized = false
    MinButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TabContainer.Visible = false
            PageContainer.Visible = false
            MainFrame:TweenSize(UDim2.new(0, 290, 0, 44), "Out", "Quad", 0.15, true)
            MinButton.Text = "[+]"
        else
            MainFrame:TweenSize(UDim2.new(0, 580, 0, 400), "Out", "Quad", 0.15, true)
            task.wait(0.15)
            TabContainer.Visible = true
            PageContainer.Visible = true
            MinButton.Text = "[-]"
        end
    end)

    local WindowAPI = { FpsLabel = FpsLabel }
    function WindowAPI:AddTab(tabConfig)
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Size = UDim2.new(1, 0, 0, 38)
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        TabButton.Text = tabConfig.Title
        TabButton.TextColor3 = Color3.fromRGB(170, 170, 170)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 12
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Size = UDim2.new(1, -12, 1, -12)
        Page.Position = UDim2.new(0, 6, 0, 6)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 204)
        local PageList = Instance.new("UIListLayout", Page)
PageList.Padding = UDim.new(0, 7)
PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 12)
end)
TabButton.MouseButton1Click:Connect(function()
for _, p in pairs(PageContainer:GetChildren()) do
if p:IsA("ScrollingFrame") then p.Visible = false end
end
for _, b in pairs(TabContainer:GetChildren()) do
if b:IsA("TextButton") then
b.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
b.TextColor3 = Color3.fromRGB(170, 170, 170)
end
end
TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
TabButton.TextColor3 = Color3.fromRGB(0, 255, 204)
Page.Visible = true
end)
if not currentTab then
TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
TabButton.TextColor3 = Color3.fromRGB(0, 255, 204)
Page.Visible = true
currentTab = true
end
local TabAPI = {}
function TabAPI:AddToggle(text, callback)
local Frame = Instance.new("Frame", Page)
Frame.Size = UDim2.new(1, 0, 0, 46)
Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(1, -65, 1, 0)
Label.Position = UDim2.new(0, 12, 0, 0)
Label.Text = text
Label.TextColor3 = Color3.fromRGB(240, 240, 240)
Label.Font = Enum.Font.Gotham
Label.TextSize = 12
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.BackgroundTransparency = 1
local Btn = Instance.new("TextButton", Frame)
Btn.Size = UDim2.new(0, 48, 0, 24)
Btn.Position = UDim2.new(1, -58, 0.5, -12)
Btn.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
Btn.Text = "OFF"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 10
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
local act = false
Btn.MouseButton1Click:Connect(function()
act = not act
Btn.Text = act and "ON" or "OFF"
Btn.BackgroundColor3 = act and Color3.fromRGB(0, 255, 153) or Color3.fromRGB(235, 60, 60)
Btn.TextColor3 = act and Color3.fromRGB(12, 12, 16) or Color3.fromRGB(255, 255, 255)
callback(act)
end)
end
function TabAPI:AddSelector(labelText, options, callback)
local Frame = Instance.new("Frame", Page)
Frame.Size = UDim2.new(1, 0, 0, 46)
Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(0.55, 0, 1, 0)
Label.Position = UDim2.new(0, 12, 0, 0)
Label.Text = labelText
Label.TextColor3 = Color3.fromRGB(240, 240, 240)
Label.Font = Enum.Font.Gotham
Label.TextSize = 12
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.BackgroundTransparency = 1
local idx = 1
local Btn = Instance.new("TextButton", Frame)
Btn.Size = UDim2.new(0.4, -12, 0, 28)
Btn.Position = UDim2.new(0.6, 0, 0.5, -14)
Btn.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
Btn.Text = "< " .. options[idx] .. " >"
Btn.TextColor3 = Color3.fromRGB(0, 255, 204)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 11
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
callback(options[idx])
Btn.MouseButton1Click:Connect(function()
idx = idx + 1
if idx > #options then idx = 1 end
Btn.Text = "< " .. options[idx] .. " >"
callback(options[idx])
end)
end
return TabAPI
end
return WindowAPI
end
local Window = Hub:CreateWindow({ Title = "INFINITY EVO HUB v73.0" })
_G.AutoFarmMobs = false
_G.InstantKillAura = false
_G.SafeMode = false
_G.AutoRaid = false
_G.RaidKillAura = false
_G.AutoBuyChip = false
_G.SelectedChip = "Flame"
_G.AutoHaki = false
_G.FruitMagnet = false
_G.PlayerESP = false
_G.SuperSpeed = false
_G.FpsBoost = false
_G.BringMobs = false
_G.InfEnergy = false
_G.AutoChests = false
_G.AutoPumpkinEvent = false
_G.AutoSkullEvent = false
local t1 = Window:AddTab({ Title = "⚔️ Main / Farm" })
local t2 = Window:AddTab({ Title = "💀 Combat / Aura" })
local t3 = Window:AddTab({ Title = "🌀 Raid / Dungeon" })
local t4 = Window:AddTab({ Title = "✨ Extras / Util" })
local t5 = Window:AddTab({ Title = "🔥 Apelão / OP" })
local t6 = Window:AddTab({ Title = "🎃 Eventos" })
-- ==========================================
-- 📊 CONTADOR DE FPS EM TEMPO REAL
-- ==========================================
local frames = 0
local lastTime = tick()
RunService.Heartbeat:Connect(function()
frames = frames + 1
local now = tick()
if now - lastTime >= 0.5 then
local fps = math.floor(frames / (now - lastTime))
Window.FpsLabel.Text = "FPS: " .. tostring(fps)
frames = 0
lastTime = now
end
end)
-- ==========================================
-- 🦘 PULO INFINITO POR CFrame (0% IMPACTO NO FPS)
-- ==========================================
local lastJump = 0
UserInputService.JumpRequest:Connect(function()
if _G.InfEnergy then
local now = tick()
if now - lastJump >= 0.18 then
lastJump = now
local char = lp.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
if root then
root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
root.CFrame = root.CFrame + Vector3.new(0, 12, 0)
end
end
end
end)
-- ==========================================
-- 🔎 FUNÇÃO CORRIGIDA PARA LOCALIZAR ILHAS E MOBS DA RAID
-- ==========================================
local function getNextRaidIsland(myPos)
local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
if not locations then return nil end
for i = 5, 1, -1 do
local island = locations:FindFirstChild("Island " .. tostring(i))
if island and (myPos - island.Position).Magnitude < 3500 then
return island
end
end
return nil
end
local function getNearestRaidMob(myPos)
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
local nearest = nil
local shortestDist = 600
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
local eHum = obj.Humanoid
local eRoot = obj.HumanoidRootPart
if eHum.Health > 0 and obj.Name ~= lp.Name and not obj.Name:find("Dealer") and not obj.Name:find("Giver") then
local dist = (myPos - eRoot.Position).Magnitude
if dist < shortestDist then
shortestDist = dist
nearest = obj
end
end
end
end
return nearest
end
-- ==========================================
-- 🔄 LOOP DE PROTEÇÃO FÍSICA, VELOCIDADE REAL, OCEANO CONGELADO E BRING MOBS
-- ==========================================
RunService.RenderStepped:Connect(function()
local char = lp.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if root and hum and hum.Health > 0 then
if _G.InstantKillAura or _G.RaidKillAura or _G.AutoRaid or _G.BringMobs then
pcall(function()
if sethiddenproperty then
sethiddenproperty(lp, "SimulationRadius", math.huge)
end
end)
end
-- Super Velocidade Real (Ignora o bloqueio de WalkSpeed do jogo)
if _G.SuperSpeed and hum.MoveDirection.Magnitude > 0 then
root.CFrame = root.CFrame + (hum.MoveDirection * 2.2)
end
-- Bring Mobs rodando no RenderStepped
if _G.BringMobs then
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
local anchorCFrame = nil
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
if obj.Humanoid.Health > 0 and obj.Name ~= lp.Name and not obj.Name:find("Dealer") and not obj.Name:find("Giver") then
local eRoot = obj.HumanoidRootPart
if (root.Position - eRoot.Position).Magnitude < 300 then
if not anchorCFrame then
anchorCFrame = eRoot.CFrame
else
eRoot.CFrame = anchorCFrame
eRoot.CanCollide = false
eRoot.Velocity = Vector3.new(0, 0, 0)
end
end
end
end
end
end
-- CONGELA O OCEANO DE VERDADE PREENCHENDO O TERRENO COM GELO SOB OS PÉS
if _G.AutoFarmMobs or _G.SafeMode or _G.AutoRaid or _G.RaidKillAura or _G.AutoPumpkinEvent or _G.AutoSkullEvent then
for _, child in pairs(char:GetChildren()) do
if child:IsA("BasePart") then child.CanCollide = false end
end
antiWater.CanCollide = true
antiWater.CFrame = CFrame.new(root.Position.X, 40, root.Position.Z)
else
antiWater.CanCollide = true
antiWater.CFrame = CFrame.new(root.Position.X, -5, root.Position.Z)
if root.Position.Y <= 12 then
pcall(function()
workspace.Terrain:FillBlock(CFrame.new(root.Position.X, -1, root.Position.Z), Vector3.new(26, 2, 26), Enum.Material.Ice)
end)
end
end
end
end)
-- ==========================================
-- 🔋 LOOP LEVE DE ENERGIA INFINITA (1s — ZERO LAG)
-- ==========================================
task.spawn(function()
while task.wait(1) do
if _G.InfEnergy then
local char = lp.Character
if char then
local energy = char:FindFirstChild("Energy")
if energy and energy:IsA("NumberValue") then
energy.Value = energy.MaxValue
end
end
end
end
end)
-- ==========================================
-- 🧵 LOOP PRINCIPAL DE CAÇA, RAIDS, EVENTOS E EXTRAS
-- ==========================================
task.spawn(function()
while task.wait(0.05) do
local char = lp.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
if root then
-- 1. INSTANT KILL AURA
if _G.InstantKillAura then
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
local eHum = obj.Humanoid
local eRoot = obj.HumanoidRootPart
if eHum.Health > 0 and obj.Name ~= lp.Name and (root.Position - eRoot.Position).Magnitude < 150 then
executeRealAttack(eRoot.Parent)
if eHum.Health < eHum.MaxHealth then
eHum.Health = 0
end
end
end
end
end
-- 2. KILL AURA PARA RAID
if _G.RaidKillAura and not _G.AutoRaid then
local raidMob = getNearestRaidMob(root.Position)
if raidMob and raidMob:FindFirstChild("HumanoidRootPart") then
if activeTween then activeTween:Cancel() end
local rRoot = raidMob.HumanoidRootPart
root.Velocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(rRoot.Position + Vector3.new(0, 14, 0), rRoot.Position)
for i = 1, 3 do
executeRealAttack(raidMob)
end
end
end
-- 3. AUTO RAID COMPLETO
if _G.AutoRaid then
local raidMob = getNearestRaidMob(root.Position)
if raidMob and raidMob:FindFirstChild("HumanoidRootPart") then
if activeTween then activeTween:Cancel() end
local rRoot = raidMob.HumanoidRootPart
root.Velocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(rRoot.Position + Vector3.new(0, 14, 0), rRoot.Position)
for i = 1, 3 do
executeRealAttack(raidMob)
end
else
local nextIsland = getNextRaidIsland(root.Position)
if nextIsland then
local targetSpot = CFrame.new(nextIsland.Position + Vector3.new(0, 22, 0))
if (root.Position - targetSpot.Position).Magnitude > 20 then
bypassTweenTo(targetSpot, 250)
end
end
end
end
-- 3.5 AUTO COMPRAR CHIP DE RAID (DISPARO DUPLO DE CONFIRMAÇÃO)
if _G.AutoBuyChip then
local hasChip = false
for _, item in pairs(lp.Backpack:GetChildren()) do
if item.Name:lower():find("chip") then hasChip = true break end
end
if not hasChip then
for _, item in pairs(char:GetChildren()) do
if item.Name:lower():find("chip") then hasChip = true break end
end
end
if not hasChip then
pcall(function()
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local comm = remotes and remotes:FindFirstChild("CommF_")
if comm then
comm:InvokeServer("RaidsNpc", "Select", _G.SelectedChip)
task.wait(0.2)
comm:InvokeServer("RaidsNpc", "Select", _G.SelectedChip)
end
end)
task.wait(1.5)
end
end
-- 4. AUTO FARM MOBS
if _G.AutoFarmMobs and not _G.AutoRaid and not _G.RaidKillAura then
local targetMob = nil
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model") and (obj.Name == "Tide Keeper" or obj.Name == "Water Fighter") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
targetMob = obj
break
end
end
if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
if activeTween then activeTween:Cancel() end
local enemyRoot = targetMob.HumanoidRootPart
root.Velocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(enemyRoot.Position + Vector3.new(0, 14, 0), enemyRoot.Position)
executeRealAttack(targetMob)
else
bypassTweenTo(CFrame.new(-3250, 250, -10500), 240)
end
else
if not _G.AutoRaid and activeTween then activeTween:Cancel() end
end
-- 5. AUTO HAKI
if G.AutoHaki and not char:FindFirstChild("HasBuso") then
pcall(function()
local comm = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF")
if comm then
comm:InvokeServer("Buso")
end
end)
end
-- 6. PUXAR FRUTAS
if _G.FruitMagnet then
for _, obj in pairs(workspace:GetChildren()) do
if obj:IsA("Tool") and (obj.Name:find("Fruit") or obj.Name:find("Fruta")) and obj:FindFirstChild("Handle") then
obj.Handle.CFrame = root.CFrame
end
end
end
-- 7. ESP JOGADORES
for _, plr in pairs(Players:GetPlayers()) do
if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
local pRoot = plr.Character.HumanoidRootPart
local esp = pRoot:FindFirstChild("InfinityBillboardESP")
if _G.PlayerESP then
local dist = math.floor((root.Position - pRoot.Position).Magnitude)
if not esp then
esp = Instance.new("BillboardGui")
esp.Name = "InfinityBillboardESP"
esp.Adornee = pRoot
esp.Size = UDim2.new(0, 160, 0, 40)
esp.StudsOffset = Vector3.new(0, 3.5, 0)
esp.AlwaysOnTop = true
esp.Parent = pRoot
local txt = Instance.new("TextLabel", esp)
txt.Name = "Info"
txt.Size = UDim2.new(1, 0, 1, 0)
txt.BackgroundTransparency = 1
txt.TextColor3 = Color3.fromRGB(0, 255, 204)
txt.TextStrokeTransparency = 0
txt.Font = Enum.Font.GothamBold
txt.TextSize = 11
end
esp.Info.Text = plr.Name .. " [" .. tostring(dist) .. "m]"
else
if esp then esp:Destroy() end
end
end
end
-- 8. AUTO BAÚS
if _G.AutoChests and not _G.AutoFarmMobs and not _G.AutoRaid then
local chestModels = workspace:FindFirstChild("ChestModels") or workspace
for _, v in pairs(chestModels:GetChildren()) do
if not _G.AutoChests then break end
if (v:IsA("BasePart") or v:IsA("Model")) and v.Name:find("Chest") then
local part = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")) or v
if part and part.Transparency < 1 then
root.CFrame = part.CFrame
task.wait(0.15)
end
end
end
end
-- 9. AUTO EVENTO ABÓBORA / DOCES (Ícone 1)
if _G.AutoPumpkinEvent then
for _, obj in pairs(workspace:GetDescendants()) do
if not _G.AutoPumpkinEvent then break end
local n = obj.Name:lower()
if (obj:IsA("BasePart") or obj:IsA("Tool") or obj:IsA("Model")) and (n:find("pumpkin") or n:find("candy") or n:find("abobora") or n:find("halloween")) then
local part = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle") or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
if part and part.Transparency < 1 then
part.CFrame = root.CFrame
root.CFrame = part.CFrame
task.wait(0.1)
end
end
end
end
-- 10. AUTO EVENTO CAVEIRA / OSSOS (Ícone 2)
if _G.AutoSkullEvent then
for _, obj in pairs(workspace:GetDescendants()) do
if not _G.AutoSkullEvent then break end
local n = obj.Name:lower()
if (obj:IsA("BasePart") or obj:IsA("Tool") or obj:IsA("Model")) and (n:find("bone") or n:find("skull") or n:find("cursed") or n:find("caveira") or n:find("soul")) then
local part = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle") or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
if part and part.Transparency < 1 then
part.CFrame = root.CFrame
root.CFrame = part.CFrame
task.wait(0.1)
end
end
end
end
end
end
end)
local raidChips = {"Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand", "Phoenix", "Dough"}
t1:AddToggle("Auto Farm Mobs (Só Melee / Sem Dano)", function(state) _G.AutoFarmMobs = state end)
t1:AddToggle("Proteção Anti-Queda / Noclip", function(state) _G.SafeMode = state end)
t2:AddToggle("Instant Kill Aura (Finaliza Mobs)", function(state) _G.InstantKillAura = state end)
t3:AddToggle("Auto Raid (Atacar e Avançar)", function(state) _G.AutoRaid = state end)
t3:AddToggle("Kill Aura Raid (Só Limpar Ilha)", function(state) _G.RaidKillAura = state end)
t3:AddSelector("Chip da Raid", raidChips, function(val) _G.SelectedChip = val end)
t3:AddToggle("Auto Comprar Chip da Raid", function(state) _G.AutoBuyChip = state end)
t4:AddToggle("Auto Haki (Armamento)", function(state) _G.AutoHaki = state end)
t4:AddToggle("Puxar Frutas (Fruit Magnet)", function(state) _G.FruitMagnet = state end)
t4:AddToggle("ESP Jogadores (Ver no Mapa)", function(state) _G.PlayerESP = state end)
t4:AddToggle("Super Velocidade (WalkSpeed)", function(state) _G.SuperSpeed = state end)
t4:AddToggle("Remover Névoa / FPS Boost", function(state)
_G.FpsBoost = state
if state then
Lighting.FogEnd = 9e9
Lighting.GlobalShadows = false
else
Lighting.FogEnd = 2500
Lighting.GlobalShadows = true
end
end)
t5:AddToggle("Bring Mobs (Juntar Monstros)", function(state) _G.BringMobs = state end)
t5:AddToggle("Energia / Pulo Infinito", function(state) _G.InfEnergy = state end)
t5:AddToggle("Auto Baús (Farmar Beli)", function(state) _G.AutoChests = state end)
t6:AddToggle("Auto Evento Abóbora (Pumpkin/Candy)", function(state) _G.AutoPumpkinEvent = state end)
t6:AddToggle("Auto Evento Caveira (Bones/Cursed)", function(state) _G.AutoSkullEvent = state end)
print("Infinity Evo Hub v73.0 — Painel maior, Super Velocidade real e Pulo Infinito sem lag!")
