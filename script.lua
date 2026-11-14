-- [[ INFINITY EVO HUB v97.0 - INSTANT KILL AURA, LAB RAID ENTER, KEY TIMER & AFK MODE ]] --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TargetGui = (gethui and gethui())
    or (CoreGui:FindFirstChild("RobloxGui") and CoreGui)
    or lp:WaitForChild("PlayerGui")

-- ESTADO INTERNO COMPARTILHADO
local State = {
    AutoFarmMobs = false,
    AutoFarmLevelQuest = false,
    AutoFarmNoClickFruit = false,
    AutoFarmBosses = false,
    InstantKillAura = false,
    AutoEquipCombat = false,
    SkillAimbot = false,
    BigHitbox = false,
    SafeMode = false,
    AutoRaid = false,
    AutoStartRaid = false,
    RaidKillAura = false,
    RaidAllIslandsKillAura = false,
    AutoBuyChip = false,
    SelectedChip = "Flame",
    AutoHaki = false,
    AutoKenHaki = false,
    AutoStats = false,
    SelectedStat = "Melee",
    FruitMagnet = false,
    AutoRandomFruit = false,
    PlayerESP = false,
    SuperSpeed = false,
    FpsBoost = false,
    BringMobs = false,
    InfEnergy = false,
    AutoChests = false,
    FreezeWorld = false,
    BypassDefense = false,
    ObliterateTarget = false,
    MultiplyCurrency = false,
    AutoPumpkinEvent = false,
    AutoSkullEvent = false,
    SelectedStyle = "Dark Step",
    AutoGetStyle = false,
    SelectedSea1 = "Starter Pirate",
    TpSea1 = false,
    SelectedSea2 = "Kingdom of Rose",
    TpSea2 = false,
    SelectedSea3 = "Port Town",
    TpSea3 = false,
    AfkMode = false,
    AutoRejoin = false
}

local Hub = {}
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
-- EQUIPAR ARMA (MELEE / SWORD / QUALQUER TOOL)
-- ==========================================
local function equipWeapon()
    local char = lp.Character
    local backpack = lp:FindFirstChild("Backpack")
    if not char or not backpack then return nil end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and (equipped.ToolTip == "Melee" or equipped.ToolTip == "Sword") then
        return equipped
    end

    for idx, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == "Melee" then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(tool) return tool end
        end
    end

    for idx, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == "Sword" then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(tool) return tool end
        end
    end

    if not equipped then
        local firstTool = backpack:FindFirstChildOfClass("Tool")
        if firstTool and not firstTool.Name:lower():find("chip") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(firstTool) return firstTool end
        end
    end

    return equipped
end

-- ==========================================
-- EQUIPAR BLOX FRUIT (PARA GANHAR MAESTRIA)
-- ==========================================
local function equipFruitTool()
    local char = lp.Character
    local backpack = lp:FindFirstChild("Backpack")
    if not char or not backpack then return nil end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and (equipped.ToolTip == "Blox Fruit" or equipped.Name:find("Fruit") or equipped.Name:find("-")) then
        return equipped
    end

    for idx, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.ToolTip == "Blox Fruit" or tool.Name:find("Fruit") or tool.Name:find("-")) then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(tool) return tool end
        end
    end
    return nil
end

-- ==========================================
-- DISPARAR QUALQUER SKILL DA FRUTA (Z, X, C, V, F)
-- ==========================================
local lastFruitSkill = 0
local skillIndex = 1
local fruitKeys = {
    Enum.KeyCode.Z,
    Enum.KeyCode.X,
    Enum.KeyCode.C,
    Enum.KeyCode.V,
    Enum.KeyCode.F
}

local function castFruitSkillAt(targetRoot)
    local fruit = equipFruitTool()
    if not fruit then return end
    if tick() - lastFruitSkill < 0.25 then return end
    lastFruitSkill = tick()

    local keyToPress = fruitKeys[skillIndex]
    skillIndex = skillIndex + 1
    if skillIndex > #fruitKeys then skillIndex = 1 end

    pcall(function()
        targetRoot.Size = Vector3.new(60, 60, 60)
        targetRoot.CanCollide = false
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(root.Position, targetRoot.Position)
        end
        VirtualInputManager:SendKeyEvent(true, keyToPress, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, keyToPress, false, game)
    end)
end

-- ==========================================
-- MOTOR DE ATAQUE REAL E ELIMINAÇÃO INSTANTÂNEA
-- ==========================================
local lastAttackTime = 0
local function executeRealAttack(targetModel)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return end

    local weapon = equipWeapon()

    pcall(function()
        targetRoot.Size = Vector3.new(60, 60, 60)
        targetRoot.CanCollide = false
    end)

    if tick() - lastAttackTime < 0.05 then return end
    lastAttackTime = tick()

    pcall(function()
        if weapon then
            weapon:Activate()
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(640, 360))
    end)

    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local net = modules and modules:FindFirstChild("Net")
        if net then
            local regAttack = net:FindFirstChild("RE/RegisterAttack")
            local regHit = net:FindFirstChild("RE/RegisterHit")
            if regAttack and regHit then
                regAttack:FireServer(0)
                regHit:FireServer(targetRoot, {{targetModel, targetRoot}})
            end
        end
    end)
end

local function executeInstantObliterateAura(myPos, radius)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(lp, "SimulationRadius", math.huge)
        end
        if setsimulationradius then
            setsimulationradius(math.huge, math.huge)
        end
    end)

    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    local hitList = {}
    local mainTargetRoot = nil

    for idx, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj:IsA("Model")
            and obj.Name ~= lp.Name
            and not obj.Name:find("Dealer")
            and not obj.Name:find("Giver")
        then
            local eHum = obj:FindFirstChildOfClass("Humanoid")
            local eRoot = obj:FindFirstChild("HumanoidRootPart")
            if eHum and eRoot and eHum.Health > 0 then
                if (myPos - eRoot.Position).Magnitude <= radius then
                    eRoot.Size = Vector3.new(70, 70, 70)
                    eRoot.CanCollide = false
                    if not mainTargetRoot then
                        mainTargetRoot = eRoot
                    end
                    table.insert(hitList, {obj, eRoot})

                    -- Quebra instantânea de HP
                    pcall(function()
                        eHum.Health = 0
                        eHum:ChangeState(Enum.HumanoidStateType.Dead)
                    end)
                end
            end
        end
    end

    if #hitList == 0 or not mainTargetRoot then return false end

    local weapon = equipWeapon()
    pcall(function()
        if weapon then
            weapon:Activate()
        end
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local net = modules and modules:FindFirstChild("Net")
        if net then
            local regAttack = net:FindFirstChild("RE/RegisterAttack")
            local regHit = net:FindFirstChild("RE/RegisterHit")
            if regAttack and regHit then
                for burst = 1, 6 do
                    regAttack:FireServer(0)
                    regHit:FireServer(mainTargetRoot, hitList)
                end
            end
        end
    end)

    return true
end

-- ==========================================
-- MOVIMENTO SUAVE QUADRO A QUADRO
-- ==========================================
local function moveSmoothStep(root, targetCFrame, dt, speed)
    speed = speed or 290
    local currentPos = root.Position
    local targetPos = targetCFrame.Position
    local diff = targetPos - currentPos
    local dist = diff.Magnitude

    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
root.Velocity = Vector3.new(0, 0, 0)
if dist <= 14 then
root.CFrame = targetCFrame
return true
else
local step = math.min(dist, speed * dt)
local nextPos = currentPos + (diff.Unit * step)
root.CFrame = CFrame.new(nextPos, targetPos)
return false
end
end
-- ==========================================
-- ÚLTIMA ILHA DE CADA SEA (DETECÇÃO PELO MAPA)
-- ==========================================
local function getCurrentSea()
local map = workspace:FindFirstChild("Map")
local wo = workspace:FindFirstChild("_WorldOrigin")
local locs = wo and wo:FindFirstChild("Locations")
if (map and (map:FindFirstChild("Dressrosa") or map:FindFirstChild("ForgottenIsland") or map:FindFirstChild("GreenBit")))
or (locs and (locs:FindFirstChild("Kingdom of Rose") or locs:FindFirstChild("Forgotten Island")))
or game.PlaceId == 4442272183
then
return 2
elseif (map and (map:FindFirstChild("Turtle") or map:FindFirstChild("PortTown") or map:FindFirstChild("TikiOutpost")))
or (locs and (locs:FindFirstChild("Port Town") or locs:FindFirstChild("Floating Turtle") or locs:FindFirstChild("Tiki Outpost")))
or game.PlaceId == 7449423635
then
return 3
end
return 1
end
local function getLastIslandQuestBySea()
local sea = getCurrentSea()
if sea == 1 then
return "FountainQuest", 2, {"Galley Captain", "Capitão da Galera", "Capitao da Galera"},
CFrame.new(5259, 38, 4050), CFrame.new(5441, 42, 4950)
elseif sea == 2 then
return "ForgottenQuest", 2, {"Water Fighter", "Lutador de Água", "Lutador de Agua", "Guerreiro"},
CFrame.new(-3054, 236, -10142), CFrame.new(-3352, 285, -10534)
else
return "TikiQuest2", 2, {"Isle Champion", "Campeão da ilha", "Campeao da ilha"},
CFrame.new(-16539, 55, 1051), CFrame.new(-16634, 85, 1106)
end
end
-- ==========================================
-- EFEITO VISUAL DE CLIQUE NEON
-- ==========================================
local function triggerClickEffect(parentObj, clickColor)
pcall(function()
local flash = Instance.new("Frame", parentObj)
flash.Size = UDim2.new(0, 10, 0, 10)
flash.Position = UDim2.new(0.5, -5, 0.5, -5)
flash.BackgroundColor3 = clickColor or Color3.fromRGB(0, 255, 220)
flash.BackgroundTransparency = 0.35
flash.BorderSizePixel = 0
flash.ZIndex = parentObj.ZIndex + 5
Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 8)
local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(flash, tInfo, {
Size = UDim2.new(1, 0, 1, 0),
Position = UDim2.new(0, 0, 0, 0),
BackgroundTransparency = 1
})
tween:Play()
tween.Completed:Connect(function()
flash:Destroy()
end)
end)
end
-- ==========================================
-- CONSTRUTOR DA INTERFACE
-- ==========================================
function Hub:CreateWindow(config)
local sg = TargetGui:FindFirstChild("InfinityEvoUI")
if sg then sg:Destroy() end
sg = Instance.new("ScreenGui", TargetGui)
sg.Name = "InfinityEvoUI"
sg.ResetOnSpawn = false
local OuterSmoke = Instance.new("Frame", sg)
OuterSmoke.Size = UDim2.new(0, 604, 0, 424)
OuterSmoke.Position = UDim2.new(0.5, -302, 0.5, -212)
OuterSmoke.BackgroundColor3 = Color3.fromRGB(0, 255, 204)
OuterSmoke.BackgroundTransparency = 0.88
OuterSmoke.BorderSizePixel = 0
Instance.new("UICorner", OuterSmoke).CornerRadius = UDim.new(0, 18)
local MainFrame = Instance.new("Frame", sg)
MainFrame.Size = UDim2.new(0, 580, 0, 400)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
MainFrame.ClipsDescendants = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 2.8
Stroke.Color = Color3.fromRGB(0, 255, 220)
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
TitleBar.ZIndex = 2
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -160, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = config.Title
Title.TextColor3 = Color3.fromRGB(0, 255, 220)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 3
local FpsLabel = Instance.new("TextLabel", TitleBar)
FpsLabel.Size = UDim2.new(0, 70, 0, 26)
FpsLabel.Position = UDim2.new(1, -118, 0.5, -13)
FpsLabel.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
FpsLabel.Text = "FPS: 60"
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.TextSize = 11
FpsLabel.ZIndex = 3
Instance.new("UICorner", FpsLabel).CornerRadius = UDim.new(0, 5)
local MinButton = Instance.new("TextButton", TitleBar)
MinButton.Size = UDim2.new(0, 34, 0, 26)
MinButton.Position = UDim2.new(1, -44, 0.5, -13)
MinButton.BackgroundColor3 = Color3.fromRGB(22, 26, 40)
MinButton.Text = "[-]"
MinButton.TextColor3 = Color3.fromRGB(0, 255, 220)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 12
MinButton.ZIndex = 3
Instance.new("UICorner", MinButton).CornerRadius = UDim.new(0, 5)
local TabContainer = Instance.new("ScrollingFrame", MainFrame)
TabContainer.Size = UDim2.new(0, 145, 1, -60)
TabContainer.Position = UDim2.new(0, 10, 0, 52)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 0
TabContainer.ZIndex = 2
local TabList = Instance.new("UIListLayout", TabContainer)
TabList.Padding = UDim.new(0, 6)
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 10)
end)
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -175, 1, -60)
PageContainer.Position = UDim2.new(0, 165, 0, 52)
PageContainer.BackgroundColor3 = Color3.fromRGB(14, 16, 25)
PageContainer.BackgroundTransparency = 0.15
PageContainer.ZIndex = 2
Instance.new("UICorner", PageContainer).CornerRadius = UDim.new(0, 8)
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
local isClick = input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
if isClick then
dragging = true
dragStart = input.Position
startPos = MainFrame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
TitleBar.InputChanged:Connect(function(input)
local isMove = input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
if isMove then
dragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
local delta = input.Position - dragStart
local newPos = UDim2.new(
startPos.X.Scale, startPos.X.Offset + delta.X,
startPos.Y.Scale, startPos.Y.Offset + delta.Y
)
MainFrame.Position = newPos
OuterSmoke.Position = UDim2.new(
newPos.X.Scale, newPos.X.Offset - 12,
newPos.Y.Scale, newPos.Y.Offset - 12
)
end
end)
local minimized = false
MinButton.MouseButton1Click:Connect(function()
triggerClickEffect(MinButton, Color3.fromRGB(0, 255, 220))
minimized = not minimized
if minimized then
TabContainer.Visible = false
PageContainer.Visible = false
MainFrame.Size = UDim2.new(0, 290, 0, 44)
OuterSmoke.Size = UDim2.new(0, 314, 0, 68)
MinButton.Text = "[+]"
else
MainFrame.Size = UDim2.new(0, 580, 0, 400)
OuterSmoke.Size = UDim2.new(0, 604, 0, 424)
TabContainer.Visible = true
PageContainer.Visible = true
MinButton.Text = "[-]"
end
end)
local WindowAPI = { FpsLabel = FpsLabel }
function WindowAPI:AddTab(tabConfig)
local TabButton = Instance.new("TextButton", TabContainer)
TabButton.Size = UDim2.new(1, 0, 0, 38)
TabButton.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
TabButton.Text = tabConfig.Title
TabButton.TextColor3 = Color3.fromRGB(170, 180, 195)
TabButton.Font = Enum.Font.GothamSemibold
TabButton.TextSize = 12
TabButton.ClipsDescendants = true
TabButton.ZIndex = 3
Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
local Page = Instance.new("ScrollingFrame", PageContainer)
Page.Size = UDim2.new(1, -12, 1, -12)
Page.Position = UDim2.new(0, 6, 0, 6)
Page.BackgroundTransparency = 1
Page.ScrollBarThickness = 2
Page.Visible = false
Page.ZIndex = 3
Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 204)
local PageList = Instance.new("UIListLayout", Page)
PageList.Padding = UDim.new(0, 7)
PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 12)
end)
TabButton.MouseButton1Click:Connect(function()
triggerClickEffect(TabButton, Color3.fromRGB(0, 255, 220))
for idx, p in ipairs(PageContainer:GetChildren()) do
if p:IsA("ScrollingFrame") then p.Visible = false end
end
for idx, b in ipairs(TabContainer:GetChildren()) do
if b:IsA("TextButton") then
b.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
b.TextColor3 = Color3.fromRGB(170, 180, 195)
end
end
TabButton.BackgroundColor3 = Color3.fromRGB(24, 32, 48)
TabButton.TextColor3 = Color3.fromRGB(0, 255, 220)
Page.Visible = true
end)
if not currentTab then
TabButton.BackgroundColor3 = Color3.fromRGB(24, 32, 48)
TabButton.TextColor3 = Color3.fromRGB(0, 255, 220)
Page.Visible = true
currentTab = true
end
local TabAPI = {}
function TabAPI:AddInfoCard(titleText, valueText)
local Frame = Instance.new("Frame", Page)
Frame.Size = UDim2.new(1, 0, 0, 54)
Frame.BackgroundColor3 = Color3.fromRGB(20, 26, 40)
Frame.ZIndex = 4
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
local TopLbl = Instance.new("TextLabel", Frame)
TopLbl.Size = UDim2.new(1, -24, 0, 22)
TopLbl.Position = UDim2.new(0, 12, 0, 5)
TopLbl.Text = titleText
TopLbl.TextColor3 = Color3.fromRGB(165, 180, 200)
TopLbl.Font = Enum.Font.Gotham
TopLbl.TextSize = 11
TopLbl.TextXAlignment = Enum.TextXAlignment.Left
TopLbl.BackgroundTransparency = 1
TopLbl.ZIndex = 5
local ValLbl = Instance.new("TextLabel", Frame)
ValLbl.Size = UDim2.new(1, -24, 0, 24)
ValLbl.Position = UDim2.new(0, 12, 0, 25)
ValLbl.Text = valueText
ValLbl.TextColor3 = Color3.fromRGB(0, 255, 180)
ValLbl.Font = Enum.Font.GothamBold
ValLbl.TextSize = 13
ValLbl.TextXAlignment = Enum.TextXAlignment.Left
ValLbl.BackgroundTransparency = 1
ValLbl.ZIndex = 5
return {
SetText = function(newVal)
ValLbl.Text = newVal
end
}
end
function TabAPI:AddToggle(text, callback)
local Frame = Instance.new("Frame", Page)
Frame.Size = UDim2.new(1, 0, 0, 46)
Frame.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
Frame.ClipsDescendants = true
Frame.ZIndex = 4
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(1, -65, 1, 0)
Label.Position = UDim2.new(0, 12, 0, 0)
Label.Text = text
Label.TextColor3 = Color3.fromRGB(240, 245, 255)
Label.Font = Enum.Font.Gotham
Label.TextSize = 12
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.BackgroundTransparency = 1
Label.ZIndex = 5
local Btn = Instance.new("TextButton", Frame)
Btn.Size = UDim2.new(0, 48, 0, 24)
Btn.Position = UDim2.new(1, -58, 0.5, -12)
Btn.BackgroundColor3 = Color3.fromRGB(235, 55, 75)
Btn.Text = "OFF"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 10
Btn.ZIndex = 5
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
local act = false
local function setState(val)
act = val
triggerClickEffect(
Frame,
act and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(235, 55, 75)
)
Btn.Text = act and "ON" or "OFF"
Btn.BackgroundColor3 = act
and Color3.fromRGB(0, 255, 170)
or Color3.fromRGB(235, 55, 75)
Btn.TextColor3 = act
and Color3.fromRGB(10, 12, 18)
or Color3.fromRGB(255, 255, 255)
callback(act)
end
Btn.MouseButton1Click:Connect(function()
setState(not act)
end)
return { Set = setState }
end
function TabAPI:AddSelector(labelText, options, callback)
local Frame = Instance.new("Frame", Page)
Frame.Size = UDim2.new(1, 0, 0, 46)
Frame.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
Frame.ClipsDescendants = true
Frame.ZIndex = 4
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(0.55, 0, 1, 0)
Label.Position = UDim2.new(0, 12, 0, 0)
Label.Text = labelText
Label.TextColor3 = Color3.fromRGB(240, 245, 255)
Label.Font = Enum.Font.Gotham
Label.TextSize = 12
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.BackgroundTransparency = 1
Label.ZIndex = 5
local idx = 1
local Btn = Instance.new("TextButton", Frame)
Btn.Size = UDim2.new(0.4, -12, 0, 28)
Btn.Position = UDim2.new(0.6, 0, 0.5, -14)
Btn.BackgroundColor3 = Color3.fromRGB(28, 36, 54)
Btn.Text = "< " .. options[idx] .. " >"
Btn.TextColor3 = Color3.fromRGB(0, 255, 220)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 11
Btn.ZIndex = 5
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
callback(options[idx])
Btn.MouseButton1Click:Connect(function()
triggerClickEffect(Frame, Color3.fromRGB(0, 255, 220))
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
local Window = Hub:CreateWindow({ Title = "INFINITY EVO HUB v97.0" })
local t1 = Window:AddTab({ Title = "Main / Farm" })
local t2 = Window:AddTab({ Title = "Combat / Aura" })
local t3 = Window:AddTab({ Title = "Raid / Dungeon" })
local t4 = Window:AddTab({ Title = "Extras / Util" })
local t5 = Window:AddTab({ Title = "Apelao / OP" })
local t6 = Window:AddTab({ Title = "Eventos" })
local t7 = Window:AddTab({ Title = "Estilos de Luta" })
local t8 = Window:AddTab({ Title = "Teleporte" })
local t9 = Window:AddTab({ Title = "Key / Status" })
-- ==========================================
-- COORDENADAS DAS ILHAS (SEA 1, 2 E 3)
-- ==========================================
local Sea1Coords = {
["Starter Pirate"] = CFrame.new(1071, 16, 1426),
["Starter Marine"] = CFrame.new(-2573, 7, 2046),
["Jungle"] = CFrame.new(-1249, 11, 341),
["Pirate Village"] = CFrame.new(-1122, 4, 3855),
["Desert"] = CFrame.new(1094, 6, 4192),
["Frozen Village"] = CFrame.new(1198, 27, -1211),
["Marineford"] = CFrame.new(-4505, 20, 4260),
["Skylands"] = CFrame.new(-4970, 717, -2622),
["Prison"] = CFrame.new(4854, 5, 740),
["Colosseum"] = CFrame.new(-1428, 7, -3014),
["Magma Village"] = CFrame.new(-5231, 8, 8467),
["Underwater City"] = CFrame.new(61163, 11, 1819),
["Fountain City"] = CFrame.new(5132, 4, 4037)
}
local Sea2Coords = {
["Kingdom of Rose"] = CFrame.new(-394, 73, 298),
["Cafe"] = CFrame.new(-380, 73, 298),
["Green Zone"] = CFrame.new(-2448, 73, -3210),
["Graveyard"] = CFrame.new(-5411, 48, -721),
["Snow Mountain"] = CFrame.new(609, 401, -5372),
["Hot and Cold"] = CFrame.new(-5924, 15, -5096),
["Cursed Ship"] = CFrame.new(923, 125, 32885),
["Ice Castle"] = CFrame.new(5400, 28, -6236),
["Forgotten Island"] = CFrame.new(-3054, 236, -10142),
["Dark Arena"] = CFrame.new(3780, 22, -3498)
}
local Sea3Coords = {
["Port Town"] = CFrame.new(-290, 6, 5343),
["Hydra Island"] = CFrame.new(5229, 603, 345),
["Great Tree"] = CFrame.new(2681, 1682, -7190),
["Floating Turtle"] = CFrame.new(-13274, 332, -7769),
["Castle on the Sea"] = CFrame.new(-5074, 314, -3155),
["Haunted Castle"] = CFrame.new(-9515, 142, 5535),
["Sea of Treats"] = CFrame.new(-2110, 53, -12371),
["Tiki Outpost"] = CFrame.new(-16220, 9, 439),
["Submerged Island"] = CFrame.new(-16269, 25, 1371)
}
-- ==========================================
-- PULO INFINITO SUAVE
-- ==========================================
local lastJump = 0
UserInputService.JumpRequest:Connect(function()
if State.InfEnergy then
local now = tick()
if now - lastJump >= 0.16 then
lastJump = now
local char = lp.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if root and hum then
hum:ChangeState(Enum.HumanoidStateType.Jumping)
root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 55, root.AssemblyLinearVelocity.Z)
end
end
end
end)
-- ==========================================
-- ANTI-AFK AUTOMÁTICO & AUTO REJOIN
-- ==========================================
lp.Idled:Connect(function()
if State.AfkMode then
pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new(0, 0))
end)
end
end)
game:GetService("CoreGui").DescendantAdded:Connect(function(desc)
if State.AutoRejoin and desc.Name == "ErrorPrompt" then
task.wait(2)
pcall(function()
TeleportService:Teleport(game.PlaceId, lp)
end)
end
end)
-- ==========================================
-- AUXILIAR DE BUSCA DE INIMIGOS VIVOS
-- ==========================================
local function findNearestEnemy(myPos, maxRange, bossOnly)
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
local bestEnemy = nil
local bestDist = maxRange or 8000
for idx, obj in ipairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj.Name ~= lp.Name
and not obj.Name:find("Dealer")
and not obj.Name:find("Giver")
then
local eHum = obj:FindFirstChildOfClass("Humanoid")
local eRoot = obj:FindFirstChild("HumanoidRootPart")
if eHum and eRoot and eHum.Health > 0 then
local isBoss = obj.Name:find("Boss") or eHum.MaxHealth >= 25000
if (not bossOnly) or isBoss then
local dist = (myPos - eRoot.Position).Magnitude
if dist < bestDist then
bestDist = dist
bestEnemy = obj
end
end
end
end
end
return bestEnemy
end
local tp1Toggle, tp2Toggle, tp3Toggle
-- ==========================================
-- LOOP PRINCIPAL HEARTBEAT (100% ATIVO)
-- ==========================================
local frames = 0
local lastFpsTick = tick()
local lastSlowTick = 0
RunService.Heartbeat:Connect(function(dt)
frames = frames + 1
local now = tick()
if now - lastFpsTick >= 0.5 then
Window.FpsLabel.Text = "FPS: " .. tostring(math.floor(frames / (now - lastFpsTick)))
frames = 0
lastFpsTick = now
end
local char = lp.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not root or not hum or hum.Health <= 0 then return end
-- 1. SUPER VELOCIDADE
if State.SuperSpeed and hum.MoveDirection.Magnitude > 0 then
root.CFrame = root.CFrame + (hum.MoveDirection * 2.2)
end
-- 2. NOCLIP & ANTI-QUEDA
local movingActive = State.AutoFarmMobs
or State.AutoFarmLevelQuest
or State.AutoFarmNoClickFruit
or State.AutoFarmBosses
or State.SafeMode
or State.AutoRaid
or State.AutoStartRaid
or State.RaidKillAura
or State.RaidAllIslandsKillAura
or State.AutoPumpkinEvent
or State.AutoSkullEvent
or State.TpSea1
or State.TpSea2
or State.TpSea3
or State.AfkMode
if movingActive then
for idx, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") then part.CanCollide = false end
end
antiWater.CanCollide = true
antiWater.CFrame = CFrame.new(root.Position.X, 40, root.Position.Z)
else
antiWater.CFrame = CFrame.new(root.Position.X, -5, root.Position.Z)
end
-- 3. TELEPORTE ILHAS SEA 1, 2 E 3
if State.TpSea1 or State.TpSea2 or State.TpSea3 then
local dest = nil
if State.TpSea1 then dest = Sea1Coords[State.SelectedSea1]
elseif State.TpSea2 then dest = Sea2Coords[State.SelectedSea2]
elseif State.TpSea3 then dest = Sea3Coords[State.SelectedSea3] end
if dest then
local arrived = moveSmoothStep(root, dest, dt, 290)
if arrived then
if State.TpSea1 and tp1Toggle then tp1Toggle.Set(false) end
if State.TpSea2 and tp2Toggle then tp2Toggle.Set(false) end
if State.TpSea3 and tp3Toggle then tp3Toggle.Set(false) end
end
end
return
end
-- 4. AUTO FARM MOBS (QUALQUER SEA)
if State.AutoFarmMobs then
local target = findNearestEnemy(root.Position, 9000, false)
if target and target:FindFirstChild("HumanoidRootPart") then
local eRoot = target.HumanoidRootPart
local hoverCF = CFrame.new(eRoot.Position + Vector3.new(0, 12, 0), eRoot.Position)
local arrived = moveSmoothStep(root, hoverCF, dt, 290)
if arrived or (root.Position - eRoot.Position).Magnitude <= 28 then
executeRealAttack(target)
end
elseif getCurrentSea() == 2 then
moveSmoothStep(root, CFrame.new(-3250, 250, -10500), dt, 290)
end
end
-- 5. AUTO FARM LEVEL (PEGA A QUEST E ATACA OS NPCS DA QUEST QUE PEGOU)
if State.AutoFarmLevelQuest then
local qName, qIdx, mobNames, npcCF, mobSpawnCF = getLastIslandQuestBySea()
local pGui = lp:FindFirstChild("PlayerGui")
local mainGui = pGui and pGui:FindFirstChild("Main")
local questGui = mainGui and mainGui:FindFirstChild("Quest")
local hasQuest = questGui and questGui.Visible
if not hasQuest then
local arrived = moveSmoothStep(root, npcCF, dt, 295)
if arrived then
pcall(function()
ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", qName, qIdx)
end)
end
else
local activeQuestMob = ""
pcall(function()
local titleObj = questGui.Container.QuestTitle.Title
if titleObj and titleObj.Text then
activeQuestMob = titleObj.Text:gsub("%d+", ""):gsub("Defeat", ""):gsub("Derrote", ""):gsub("^%s+", ""):gsub("%s+$", "")
end
end)
local target = nil
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
local bestDist = 6000
for idx, obj in ipairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model") and obj.Name ~= lp.Name and not obj.Name:find("Dealer") and not obj.Name:find("Giver") then
local eHum = obj:FindFirstChildOfClass("Humanoid")
local eRoot = obj:FindFirstChild("HumanoidRootPart")
if eHum and eRoot and eHum.Health > 0 then
local matched = false
if activeQuestMob ~= "" and obj.Name:lower():find(activeQuestMob:lower(), 1, true) then
matched = true
end
if not matched then
for j, nameOpt in ipairs(mobNames) do
if obj.Name:find(nameOpt, 1, true) then
matched = true
break
end
end
end
if matched or (eRoot.Position - mobSpawnCF.Position).Magnitude < 1500 then
local d = (root.Position - eRoot.Position).Magnitude
if d < bestDist then
bestDist = d
target = obj
end
end
end
end
end
if target and target:FindFirstChild("HumanoidRootPart") then
local eRoot = target.HumanoidRootPart
local hoverCF = CFrame.new(eRoot.Position + Vector3.new(0, 10, 0), eRoot.Position)
local arrived = moveSmoothStep(root, hoverCF, dt, 295)
if arrived or (root.Position - eRoot.Position).Magnitude <= 30 then
executeRealAttack(target)
end
else
moveSmoothStep(root, mobSpawnCF, dt, 295)
end
end
end
-- 6. AUTO FARM FRUTA (SEM CLICK + USA QUALQUER SKILL Z, X, C, V, F NO GOLPE FINAL)
if State.AutoFarmNoClickFruit then
local target = findNearestEnemy(root.Position, 5000, false)
if target and target:FindFirstChild("HumanoidRootPart") then
local eRoot = target.HumanoidRootPart
local eHum = target:FindFirstChildOfClass("Humanoid")
local hoverCF = CFrame.new(eRoot.Position + Vector3.new(0, 11, 0), eRoot.Position)
local arrived = moveSmoothStep(root, hoverCF, dt, 290)
if (arrived or (root.Position - eRoot.Position).Magnitude <= 28) and eHum then
if eHum.Health > eHum.MaxHealth * 0.35 then
executeRealAttack(target)
else
castFruitSkillAt(eRoot)
end
end
end
end
-- 7. AUTO FARM BOSSES
if State.AutoFarmBosses then
local boss = findNearestEnemy(root.Position, 15000, true)
if boss and boss:FindFirstChild("HumanoidRootPart") then
local bRoot = boss.HumanoidRootPart
local hoverCF = CFrame.new(bRoot.Position + Vector3.new(0, 12, 0), bRoot.Position)
local arrived = moveSmoothStep(root, hoverCF, dt, 290)
if arrived or (root.Position - bRoot.Position).Magnitude <= 28 then
executeRealAttack(boss)
end
end
end
-- 8. INSTANT KILL AURA & RAID KILL AURA (ELIMINAÇÃO INSTANTÂNEA APELONA)
if State.InstantKillAura then
executeInstantObliterateAura(root.Position, 450)
end
if State.RaidKillAura then
local didHit = executeInstantObliterateAura(root.Position, 1500)
if didHit then
local target = findNearestEnemy(root.Position, 1500, false)
if target and target:FindFirstChild("HumanoidRootPart") then
local eRoot = target.HumanoidRootPart
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(eRoot.Position + Vector3.new(0, 14, 0), eRoot.Position)
end
end
end
if State.RaidAllIslandsKillAura or State.AutoRaid then
executeInstantObliterateAura(root.Position, 2500)
local target = findNearestEnemy(root.Position, 2500, false)
if target and target:FindFirstChild("HumanoidRootPart") then
local eRoot = target.HumanoidRootPart
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(eRoot.Position + Vector3.new(0, 12, 0), eRoot.Position)
else
local wo = workspace:FindFirstChild("_WorldOrigin")
local locs = wo and wo:FindFirstChild("Locations")
if locs then
for i = 5, 1, -1 do
local isl = locs:FindFirstChild("Island " .. tostring(i))
if isl and (root.Position - isl.Position).Magnitude < 4500 then
moveSmoothStep(root, CFrame.new(isl.Position + Vector3.new(0, 22, 0)), dt, 300)
break
end
end
end
end
end
if State.ObliterateTarget then
executeInstantObliterateAura(root.Position, 600)
end
-- 8.5 NOVAS FUNÇÕES COMBAT / AURA
if State.AutoEquipCombat then
equipWeapon()
end
if State.SkillAimbot then
local target = findNearestEnemy(root.Position, 600, false)
if target and target:FindFirstChild("HumanoidRootPart") then
local eRoot = target.HumanoidRootPart
root.CFrame = CFrame.new(root.Position, Vector3.new(eRoot.Position.X, root.Position.Y, eRoot.Position.Z))
end
end
-- 9. BRING MOBS / FREEZE / BYPASS / BIG HITBOX
if State.BringMobs or State.FreezeWorld or State.BypassDefense or State.BigHitbox then
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
local anchorCF = nil
for idx, obj in ipairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model") and obj.Name ~= lp.Name and not obj.Name:find("Dealer") then
local eHum = obj:FindFirstChildOfClass("Humanoid")
local eRoot = obj:FindFirstChild("HumanoidRootPart")
if eHum and eRoot and eHum.Health > 0 and (root.Position - eRoot.Position).Magnitude < 350 then
if State.BringMobs then
if not anchorCF then
anchorCF = eRoot.CFrame
else
eRoot.CFrame = anchorCF
end
end
if State.FreezeWorld then
eHum.WalkSpeed = 0
eRoot.Anchored = true
end
if State.BypassDefense or State.BigHitbox then
eRoot.Size = Vector3.new(75, 75, 75)
eRoot.CanCollide = false
end
end
end
end
end
-- 10. EVENTOS (ABÓBORA / CAVEIRA)
if State.AutoPumpkinEvent or State.AutoSkullEvent then
local target = findNearestEnemy(root.Position, 3000, false)
if target and target:FindFirstChild("HumanoidRootPart") then
local eRoot = target.HumanoidRootPart
local hoverCF = CFrame.new(eRoot.Position + Vector3.new(0, 12, 0), eRoot.Position)
if moveSmoothStep(root, hoverCF, dt, 290) then
executeRealAttack(target)
end
end
end
-- TAREFAS PERIÓDICAS (A CADA 0.6s)
if now - lastSlowTick >= 0.6 then
lastSlowTick = now
if State.AutoHaki and not char:FindFirstChild("HasBuso") then
pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end)
end
if State.AutoKenHaki then
pcall(function()
if not char:FindFirstChild("HasKen") then
ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
end
end)
end
if State.AutoStats then
pcall(function()
local data = lp:FindFirstChild("Data")
local pts = data and data:FindFirstChild("Points")
if pts and pts.Value > 0 then
ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", State.SelectedStat, pts.Value)
end
end)
end
if State.InfEnergy then
local energy = char:FindFirstChild("Energy")
if energy and energy:IsA("NumberValue") then energy.Value = energy.MaxValue end
end
if State.FruitMagnet then
for idx, obj in ipairs(workspace:GetChildren()) do
if obj:IsA("Tool") and (obj.Name:find("Fruit") or obj.Name:find("Fruta")) and obj:FindFirstChild("Handle") then
obj.Handle.CFrame = root.CFrame
end
end
end
if State.AutoRandomFruit then
pcall(function()
ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
end)
end
if State.AutoChests or State.MultiplyCurrency then
local chests = workspace:FindFirstChild("ChestModels") or workspace
for idx, v in ipairs(chests:GetChildren()) do
if v.Name:find("Chest") then
local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
if part and part.Transparency < 1 then
if State.MultiplyCurrency then
part.CFrame = root.CFrame
else
root.CFrame = part.CFrame
break
end
end
end
end
end
if State.AutoBuyChip then
pcall(function()
ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", State.SelectedChip)
ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Buy")
end)
end
-- AUTO ENTRAR / INICIAR RAID (VAI ATÉ A CÁPSULA, EQUIPA CHIP E PRESSIONA O BOTÃO DA RAID)
if State.AutoStartRaid then
pcall(function()
local sea = getCurrentSea()
local labPos = (sea == 2 and Vector3.new(-6438, 250, -4501))
or (sea == 3 and Vector3.new(-5017, 314, -2823))
or Vector3.new(-6438, 250, -4501)
local chipTool = nil
for idx, item in ipairs(lp.Backpack:GetChildren()) do
if item:IsA("Tool") and item.Name:lower():find("chip") then
chipTool = item
break
end
end
if not chipTool then
for idx, item in ipairs(char:GetChildren()) do
if item:IsA("Tool") and item.Name:lower():find("chip") then
chipTool = item
break
end
end
end
local comm = ReplicatedStorage.Remotes.CommF_
if not chipTool then
comm:InvokeServer("RaidsNpc", "Select", State.SelectedChip)
comm:InvokeServer("RaidsNpc", "Buy")
return
end
if chipTool.Parent == lp.Backpack then
hum:EquipTool(chipTool)
end
-- Posiciona o jogador exatamente dentro da capsula de inicio da Raid
if (root.Position - labPos).Magnitude > 22 then
root.CFrame = CFrame.new(labPos)
task.wait(0.25)
end
comm:InvokeServer("RaidsNpc", "Select", State.SelectedChip)
comm:InvokeServer("RaidsNpc", "Start", State.SelectedChip)
comm:InvokeServer("RaidsNpc", "Start")
-- Aciona o ClickDetector do botao verde do laboratorio
local map = workspace:FindFirstChild("Map")
local lab = map and (map:FindFirstChild("CircleIsland") or map:FindFirstChild("Boat Castle"))
if lab then
for idx, desc in ipairs(lab:GetDescendants()) do
if desc:IsA("ClickDetector") then
if fireclickdetector then
fireclickdetector(desc)
end
end
end
end
end)
end
if State.AutoGetStyle then
pcall(function()
local comm = ReplicatedStorage.Remotes.CommF_
local s = State.SelectedStyle
if s == "Dark Step" then comm:InvokeServer("BuyBlackLeg")
elseif s == "Electro" then comm:InvokeServer("BuyElectro")
elseif s == "Water Kung Fu" then comm:InvokeServer("BuyFishmanKarate")
elseif s == "Superhuman" then comm:InvokeServer("BuySuperhuman")
elseif s == "Death Step" then comm:InvokeServer("BuyDeathStep")
elseif s == "Sharkman Karate" then comm:InvokeServer("BuySharkmanKarate")
elseif s == "Electric Claw" then comm:InvokeServer("BuyElectricClaw")
elseif s == "Dragon Talon" then comm:InvokeServer("BuyDragonTalon")
elseif s == "Godhuman" then comm:InvokeServer("BuyGodhuman")
elseif s == "Sanguine Art" then comm:InvokeServer("BuySanguineArt") end
end)
end
for idx, plr in ipairs(Players:GetPlayers()) do
if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
local pRoot = plr.Character.HumanoidRootPart
local esp = pRoot:FindFirstChild("InfinityBillboardESP")
if State.PlayerESP then
local dist = math.floor((root.Position - pRoot.Position).Magnitude)
if not esp then
esp = Instance.new("BillboardGui", pRoot)
esp.Name = "InfinityBillboardESP"
esp.Adornee = pRoot
esp.Size = UDim2.new(0, 160, 0, 40)
esp.StudsOffset = Vector3.new(0, 3.5, 0)
esp.AlwaysOnTop = true
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
elseif esp then
esp:Destroy()
end
end
end
end
end)
-- ==========================================
-- LISTAS E CONTROLES DA INTERFACE
-- ==========================================
local raidChips = {
"Flame", "Ice", "Quake", "Light", "Dark", "Spider",
"Rumble", "Magma", "Buddha", "Sand", "Phoenix", "Dough"
}
local statOptions = {
"Melee", "Defense", "Sword", "Gun", "Blox Fruit"
}
local fightingStyles = {
"Dark Step", "Electro", "Water Kung Fu", "Dragon Breath",
"Superhuman", "Death Step", "Sharkman Karate",
"Electric Claw", "Dragon Talon", "Godhuman", "Sanguine Art"
}
local sea1List = {
"Starter Pirate", "Starter Marine", "Jungle", "Pirate Village",
"Desert", "Frozen Village", "Marineford", "Skylands", "Prison",
"Colosseum", "Magma Village", "Underwater City", "Fountain City"
}
local sea2List = {
"Kingdom of Rose", "Cafe", "Green Zone", "Graveyard",
"Snow Mountain", "Hot and Cold", "Cursed Ship", "Ice Castle",
"Forgotten Island", "Dark Arena"
}
local sea3List = {
"Port Town", "Hydra Island", "Great Tree", "Floating Turtle",
"Castle on the Sea", "Haunted Castle", "Sea of Treats",
"Tiki Outpost", "Submerged Island"
}
t1:AddToggle("Auto Farm Mobs (Original)", function(v) State.AutoFarmMobs = v end)
t1:AddToggle("Auto Farm Level (Ultima Ilha Quest)", function(v) State.AutoFarmLevelQuest = v end)
t1:AddToggle("Auto Farm Fruta (Sem Click)", function(v) State.AutoFarmNoClickFruit = v end)
t1:AddToggle("Auto Farm Bosses (Todos do Mapa)", function(v) State.AutoFarmBosses = v end)
t1:AddToggle("Protecao Anti-Queda / Noclip", function(v) State.SafeMode = v end)
t2:AddToggle("Instant Kill Aura", function(v) State.InstantKillAura = v end)
t2:AddToggle("Auto Equipar Melhor Arma (Melee/Sword)", function(v) State.AutoEquipCombat = v end)
t2:AddToggle("Aimbot Skills (Mirar no Alvo)", function(v) State.SkillAimbot = v end)
t2:AddToggle("Hitbox Gigante (Alcance Maximo)", function(v) State.BigHitbox = v end)
t3:AddToggle("Auto Entrar/Iniciar Raid (Qualquer Lugar)", function(v) State.AutoStartRaid = v end)
t3:AddToggle("Auto Raid (Atacar e Avancar)", function(v) State.AutoRaid = v end)
t3:AddToggle("Kill Aura Raid (Limpar Ilha)", function(v) State.RaidKillAura = v end)
t3:AddToggle("Kill Aura Todas Ilhas (HitKill)", function(v) State.RaidAllIslandsKillAura = v end)
t3:AddSelector("Chip da Raid", raidChips, function(v) State.SelectedChip = v end)
t3:AddToggle("Auto Comprar Chip da Raid", function(v) State.AutoBuyChip = v end)
t4:AddToggle("Auto Haki (Armamento)", function(v) State.AutoHaki = v end)
t4:AddToggle("Auto Instinto (Observation Haki)", function(v) State.AutoKenHaki = v end)
t4:AddSelector("Atributo Auto Stats", statOptions, function(v) State.SelectedStat = v end)
t4:AddToggle("Auto Upar Status (Auto Stats)", function(v) State.AutoStats = v end)
t4:AddToggle("Puxar Frutas (Fruit Magnet)", function(v) State.FruitMagnet = v end)
t4:AddToggle("Auto Girar Fruta (Random Fruit)", function(v) State.AutoRandomFruit = v end)
t4:AddToggle("ESP Jogadores (Ver no Mapa)", function(v) State.PlayerESP = v end)
t4:AddToggle("Super Velocidade (WalkSpeed)", function(v) State.SuperSpeed = v end)
t4:AddToggle("Remover Nevoa / FPS Boost", function(v)
State.FpsBoost = v
Lighting.FogEnd = v and 9e9 or 2500
Lighting.GlobalShadows = not v
end)
t5:AddToggle("Bring Mobs (Juntar Monstros)", function(v) State.BringMobs = v end)
t5:AddToggle("Energia / Pulo Infinito", function(v) State.InfEnergy = v end)
t5:AddToggle("Auto Baus (Farmar Beli)", function(v) State.AutoChests = v end)
t5:AddToggle("FreezeWorld (Congelar NPCs)", function(v)
State.FreezeWorld = v
if not v then
local ef = workspace:FindFirstChild("Enemies") or workspace
for idx, obj in ipairs(ef:GetChildren()) do
if obj:FindFirstChild("HumanoidRootPart") then obj.HumanoidRootPart.Anchored = false end
end
end
end)
t5:AddToggle("BypassDefense (Ignorar Defesa)", function(v) State.BypassDefense = v end)
t5:AddToggle("ObliterateTarget (Aniquilar Alvo)", function(v) State.ObliterateTarget = v end)
t5:AddToggle("MultiplyCurrency (Puxar Baus)", function(v) State.MultiplyCurrency = v end)
t6:AddToggle("Auto Evento Abobora", function(v) State.AutoPumpkinEvent = v end)
t6:AddToggle("Auto Evento Caveira", function(v) State.AutoSkullEvent = v end)
t7:AddSelector("Estilo de Luta", fightingStyles, function(v) State.SelectedStyle = v end)
t7:AddToggle("Auto Pegar Estilo", function(v) State.AutoGetStyle = v end)
t8:AddSelector("Ilha Sea 1", sea1List, function(v) State.SelectedSea1 = v end)
tp1Toggle = t8:AddToggle("Teleportar Sea 1", function(v) State.TpSea1 = v end)
t8:AddSelector("Ilha Sea 2", sea2List, function(v) State.SelectedSea2 = v end)
tp2Toggle = t8:AddToggle("Teleportar Sea 2", function(v) State.TpSea2 = v end)
t8:AddSelector("Ilha Sea 3", sea3List, function(v) State.SelectedSea3 = v end)
tp3Toggle = t8:AddToggle("Teleportar Sea 3", function(v) State.TpSea3 = v end)
-- ==========================================
-- ABA 9: KEY / STATUS & MODO AFK
-- ==========================================
local savedKeyStr = "Nao encontrada"
pcall(function()
if isfile and readfile and isfile("infinity_evo_key.txt") then
savedKeyStr = readfile("infinity_evo_key.txt"):gsub("%s+", "")
end
end)
local keyStatusText = "Key Ativa: " .. savedKeyStr
local keyTimeText = "Tempo Restante: Verificando..."
pcall(function()
if savedKeyStr ~= "Nao encontrada" then
if _G.PandaKeyExpire and type(_G.PandaKeyExpire) == "number" then
local diff = _G.PandaKeyExpire - os.time()
if diff > 0 then
local dias = math.floor(diff / 86400)
local horas = math.floor((diff % 86400) / 3600)
keyTimeText = string.format("Faltam %d dias e %d horas para expirar", dias, horas)
else
keyTimeText = "Key Expirada"
end
else
keyTimeText = "Status: Ativa (24h Gratuito ou Lifetime VIP)"
end
else
keyTimeText = "Nenhuma key salva localmente"
end
end)
t9:AddInfoCard("Chave Autenticada (Panda Auth)", keyStatusText)
local timeCard = t9:AddInfoCard("Validade / Tempo Restante da Key", keyTimeText)
t9:AddToggle("Modo AFK (Anti-Kick + Flutuar Seguro)", function(v)
State.AfkMode = v
end)
t9:AddToggle("Auto Rejoin (Reconectar se Cair)", function(v)
State.AutoRejoin = v
end)
-- Atualiza contador regressivo se houver timestamp
task.spawn(function()
while task.wait(60) do
pcall(function()
if _G.PandaKeyExpire and type(_G.PandaKeyExpire) == "number" then
local diff = _G.PandaKeyExpire - os.time()
if diff > 0 then
local dias = math.floor(diff / 86400)
local horas = math.floor((diff % 86400) / 3600)
timeCard.SetText(string.format("Faltam %d dias e %d horas para expirar", dias, horas))
else
timeCard.SetText("Key Expirada - Gere uma nova")
end
end
end)
end
end)
print("Infinity Evo Hub v97.0 carregado com sucesso!")
