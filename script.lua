-- [[ INFINITY EVO HUB v92.2 - FULL SEA 2 & ISOLATED LOOP FIX ]] --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TargetGui = (gethui and gethui())
    or (CoreGui:FindFirstChild("RobloxGui") and CoreGui)
    or lp:WaitForChild("PlayerGui")

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
-- EQUIPAR MELEE OU ARMA DISPONÍVEL
-- ==========================================
local function equipMelee()
    local char = lp.Character
    local backpack = lp:FindFirstChild("Backpack")
    if not char or not backpack then return nil end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and (equipped.ToolTip == "Melee" or equipped.ToolTip == "Sword") then
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

    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == "Sword" then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:EquipTool(tool)
                return tool
            end
        end
    end

    return equipped
end

-- ==========================================
-- EQUIPAR BLOX FRUIT
-- ==========================================
local function equipFruitTool()
    local char = lp.Character
    local backpack = lp:FindFirstChild("Backpack")
    if not char or not backpack then return nil end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then
        local isFruit = equipped.ToolTip == "Blox Fruit"
            or equipped.Name:find("Fruit")
            or equipped.Name:find("-")
        if isFruit then return equipped end
    end

    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local isFruit = tool.ToolTip == "Blox Fruit"
                or tool.Name:find("Fruit")
                or tool.Name:find("-")
            if isFruit then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(tool)
                    return tool
                end
            end
        end
    end
    return nil
end

-- ==========================================
-- MOTOR DE ATAQUE REAL
-- ==========================================
local function executeRealAttack(targetModel)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return end

    local meleeTool = equipMelee()

    targetRoot.Size = Vector3.new(45, 45, 45)
    targetRoot.CanCollide = false

    pcall(function()
        if meleeTool then
            meleeTool:Activate()
        end
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
-- ÚLTIMA ILHA DE CADA SEA (MAIOR XP E BELI)
-- ==========================================
local function getLastIslandQuestBySea()
    local pid = game.PlaceId
    if pid == 2753915549 then
        return "FountainQuest", 2, "Galley Captain",
            CFrame.new(5259, 38, 4050), CFrame.new(5441, 42, 4950)
    elseif pid == 4442272183 then
        return "ForgottenQuest", 2, "Water Fighter",
            CFrame.new(-3054, 236, -10142), CFrame.new(-3352, 285, -10534)
    else
        return "TikiQuest2", 2, "Isle Champion",
            CFrame.new(-16539, 55, 1051), CFrame.new(-16634, 85, 1106)
    end
end

-- ==========================================
-- MOVIMENTAÇÃO SUAVE ANTI-KICK
-- ==========================================
local activeTween = nil
local function bypassTweenTo(targetCFrame, speed)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    speed = speed or 250

    if activeTween then
        pcall(function() activeTween:Cancel() end)
    end

    local distance = (root.Position - targetCFrame.Position).Magnitude
    if distance < 5 then
        root.CFrame = targetCFrame
        return
    end

    local duration = math.max(distance / speed, 0.05)
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
-- EFEITO VISUAL DE CLIQUE NEON (RIPPLE)
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

        local tInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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
-- CONSTRUTOR DA INTERFACE (NEON + FUMAÇA NAS BORDAS)
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

    local StrokeGrad = Instance.new("UIGradient", Stroke)
    StrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 220)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 220))
    })

    local function createEdgeSmoke(size, pos, rot)
        local smoke = Instance.new("Frame", MainFrame)
        smoke.Size = size
        smoke.Position = pos
        smoke.BackgroundColor3 = Color3.fromRGB(0, 230, 200)
        smoke.BackgroundTransparency = 0.72
        smoke.BorderSizePixel = 0
        smoke.ZIndex = 1

        local grad = Instance.new("UIGradient", smoke)
        grad.Rotation = rot
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 220)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 50, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 10, 16))
        })
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.25),
            NumberSequenceKeypoint.new(0.6, 0.75),
            NumberSequenceKeypoint.new(1, 1)
})
return smoke
end
local smokeTop = createEdgeSmoke(UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 0), 90)
local smokeBot = createEdgeSmoke(UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 1, -28), 270)
local smokeLeft = createEdgeSmoke(UDim2.new(0, 22, 1, 0), UDim2.new(0, 0, 0, 0), 0)
local smokeRight = createEdgeSmoke(UDim2.new(0, 22, 1, 0), UDim2.new(1, -22, 0, 0), 180)
task.spawn(function()
local rotAngle = 0
while MainFrame and MainFrame.Parent do
rotAngle = (rotAngle + 3) % 360
StrokeGrad.Rotation = rotAngle
local pulse = 0.76 + (math.sin(tick() * 2.5) * 0.14)
smokeTop.BackgroundTransparency = pulse
smokeBot.BackgroundTransparency = pulse
smokeLeft.BackgroundTransparency = pulse + 0.05
smokeRight.BackgroundTransparency = pulse + 0.05
OuterSmoke.BackgroundTransparency = 0.85 + (math.cos(tick() * 2.5) * 0.08)
task.wait(0.04)
end
end)
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
local fpsStroke = Instance.new("UIStroke", FpsLabel)
fpsStroke.Thickness = 1
fpsStroke.Color = Color3.fromRGB(0, 255, 170)
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
local minStroke = Instance.new("UIStroke", MinButton)
minStroke.Thickness = 1
minStroke.Color = Color3.fromRGB(0, 255, 220)
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
local pageStroke = Instance.new("UIStroke", PageContainer)
pageStroke.Thickness = 1.2
pageStroke.Color = Color3.fromRGB(0, 200, 190)
pageStroke.Transparency = 0.45
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
MainFrame:TweenSize(UDim2.new(0, 290, 0, 44), "Out", "Quad", 0.15, true)
OuterSmoke:TweenSize(UDim2.new(0, 314, 0, 68), "Out", "Quad", 0.15, true)
MinButton.Text = "[+]"
else
MainFrame:TweenSize(UDim2.new(0, 580, 0, 400), "Out", "Quad", 0.15, true)
OuterSmoke:TweenSize(UDim2.new(0, 604, 0, 424), "Out", "Quad", 0.15, true)
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
TabButton.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
TabButton.Text = tabConfig.Title
TabButton.TextColor3 = Color3.fromRGB(170, 180, 195)
TabButton.Font = Enum.Font.GothamSemibold
TabButton.TextSize = 12
TabButton.ClipsDescendants = true
TabButton.ZIndex = 3
Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
local tabStroke = Instance.new("UIStroke", TabButton)
tabStroke.Thickness = 1
tabStroke.Color = Color3.fromRGB(0, 255, 220)
tabStroke.Transparency = 0.85
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
for _, p in pairs(PageContainer:GetChildren()) do
if p:IsA("ScrollingFrame") then p.Visible = false end
end
for _, b in pairs(TabContainer:GetChildren()) do
if b:IsA("TextButton") then
b.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
b.TextColor3 = Color3.fromRGB(170, 180, 195)
local st = b:FindFirstChildOfClass("UIStroke")
if st then st.Transparency = 0.85 end
end
end
TabButton.BackgroundColor3 = Color3.fromRGB(24, 32, 48)
TabButton.TextColor3 = Color3.fromRGB(0, 255, 220)
tabStroke.Transparency = 0.2
Page.Visible = true
end)
if not currentTab then
TabButton.BackgroundColor3 = Color3.fromRGB(24, 32, 48)
TabButton.TextColor3 = Color3.fromRGB(0, 255, 220)
tabStroke.Transparency = 0.2
Page.Visible = true
currentTab = true
end
local TabAPI = {}
function TabAPI:AddToggle(text, callback)
local Frame = Instance.new("Frame", Page)
Frame.Size = UDim2.new(1, 0, 0, 46)
Frame.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
Frame.ClipsDescendants = true
Frame.ZIndex = 4
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
local fStroke = Instance.new("UIStroke", Frame)
fStroke.Thickness = 1
fStroke.Color = Color3.fromRGB(0, 255, 204)
fStroke.Transparency = 0.8
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
fStroke.Transparency = act and 0.25 or 0.8
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
local fStroke = Instance.new("UIStroke", Frame)
fStroke.Thickness = 1
fStroke.Color = Color3.fromRGB(0, 255, 204)
fStroke.Transparency = 0.8
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
local bStroke = Instance.new("UIStroke", Btn)
bStroke.Thickness = 1
bStroke.Color = Color3.fromRGB(0, 255, 220)
bStroke.Transparency = 0.4
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
local Window = Hub:CreateWindow({ Title = "INFINITY EVO HUB v92.2" })
_G.AutoFarmMobs = false
_G.AutoFarmLevelQuest = false
_G.AutoFarmNoClickFruit = false
_G.AutoFarmBosses = false
_G.InstantKillAura = false
_G.SafeMode = false
_G.AutoRaid = false
_G.RaidKillAura = false
_G.RaidAllIslandsKillAura = false
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
_G.FreezeWorld = false
_G.BypassDefense = false
_G.ObliterateTarget = false
_G.MultiplyCurrency = false
_G.AutoPumpkinEvent = false
_G.AutoSkullEvent = false
_G.SelectedStyle = "Dark Step"
_G.AutoGetStyle = false
_G.SelectedSea1 = "Starter Pirate"
_G.TpSea1 = false
_G.SelectedSea2 = "Kingdom of Rose"
_G.TpSea2 = false
_G.SelectedSea3 = "Port Town"
_G.TpSea3 = false
local t1 = Window:AddTab({ Title = "Main / Farm" })
local t2 = Window:AddTab({ Title = "Combat / Aura" })
local t3 = Window:AddTab({ Title = "Raid / Dungeon" })
local t4 = Window:AddTab({ Title = "Extras / Util" })
local t5 = Window:AddTab({ Title = "Apelao / OP" })
local t6 = Window:AddTab({ Title = "Eventos" })
local t7 = Window:AddTab({ Title = "Estilos de Luta" })
local t8 = Window:AddTab({ Title = "Teleporte" })
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
-- CONTADOR DE FPS EM TEMPO REAL
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
-- PULO INFINITO POR CFrame
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
-- FUNÇÕES DE LOCALIZAÇÃO DE RAID
-- ==========================================
local function getNextRaidIsland(myPos)
local wo = workspace:FindFirstChild("_WorldOrigin")
local locations = wo and wo:FindFirstChild("Locations")
if not locations then return nil end
for i = 5, 1, -1 do
local island = locations:FindFirstChild("Island " .. tostring(i))
if island and (myPos - island.Position).Magnitude < 3500 then
return island
end
end
return nil
end
local function getActiveRaidIslandPos(myPos)
local wo = workspace:FindFirstChild("_WorldOrigin")
local locations = wo and wo:FindFirstChild("Locations")
if locations then
for i = 5, 1, -1 do
local isl = locations:FindFirstChild("Island " .. tostring(i))
if isl and (myPos - isl.Position).Magnitude < 1200 then
return isl.Position
end
end
end
local map = workspace:FindFirstChild("Map")
local raidFolder = map and map:FindFirstChild("Raid")
if raidFolder then
for i = 5, 1, -1 do
local isl = raidFolder:FindFirstChild("Island " .. tostring(i))
if isl then
local pos = isl:IsA("Model") and isl:GetPivot().Position
or (isl:IsA("BasePart") and isl.Position)
if pos and (myPos - pos).Magnitude < 1200 then
return pos
end
end
end
end
return nil
end
local function getNearestRaidMob(myPos)
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
local nearest = nil
local shortestDist = 600
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
local eHum = obj.Humanoid
local eRoot = obj.HumanoidRootPart
if eHum.Health > 0
and obj.Name ~= lp.Name
and not obj.Name:find("Dealer")
and not obj.Name:find("Giver")
then
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
-- LOOP DE PROTEÇÃO FÍSICA, VELOCIDADE E GELO
-- ==========================================
RunService.RenderStepped:Connect(function()
pcall(function()
local char = lp.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if root and hum and hum.Health > 0 then
local needsSim = _G.InstantKillAura
or _G.RaidKillAura
or _G.AutoRaid
or _G.BringMobs
or _G.RaidAllIslandsKillAura
or _G.ObliterateTarget
or _G.AutoFarmNoClickFruit
or _G.AutoFarmLevelQuest
or _G.AutoFarmBosses
or _G.AutoFarmMobs
if needsSim then
if sethiddenproperty then
sethiddenproperty(lp, "SimulationRadius", math.huge)
end
if setsimulationradius then
setsimulationradius(math.huge, math.huge)
end
end
if _G.FreezeWorld or _G.BypassDefense then
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
local eHum = obj.Humanoid
local eRoot = obj.HumanoidRootPart
if eHum.Health > 0
and obj.Name ~= lp.Name
and not obj.Name:find("Dealer")
and not obj.Name:find("Giver")
then
if (root.Position - eRoot.Position).Magnitude < 450 then
if _G.FreezeWorld then
eHum.WalkSpeed = 0
eHum.JumpPower = 0
eRoot.Anchored = true
eRoot.Velocity = Vector3.new(0, 0, 0)
else
eRoot.Anchored = false
end
if _G.BypassDefense then
eRoot.Size = Vector3.new(65, 65, 65)
eRoot.CanCollide = false
end
end
end
end
end
end
if _G.RaidAllIslandsKillAura then
local hoverCenter = getActiveRaidIslandPos(root.Position)
if hoverCenter then
local hasLivingEnemy = false
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
if obj.Humanoid.Health > 0
and obj.Name ~= lp.Name
and not obj.Name:find("Dealer")
and not obj.Name:find("Giver")
then
if (hoverCenter - obj.HumanoidRootPart.Position).Magnitude < 1200 then
hasLivingEnemy = true
break
end
end
end
end
if not hasLivingEnemy then
if activeTween then activeTween:Cancel() end
hum.PlatformStand = false
root.Velocity = Vector3.new(0, 0, 0)
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
local hoverPos = Vector3.new(hoverCenter.X, hoverCenter.Y + 25, hoverCenter.Z)
local lookPos = Vector3.new(hoverCenter.X, hoverCenter.Y, hoverCenter.Z)
root.CFrame = CFrame.lookAt(hoverPos, lookPos)
end
end
end
if _G.SuperSpeed and hum.MoveDirection.Magnitude > 0 then
root.CFrame = root.CFrame + (hum.MoveDirection * 2.2)
end
if _G.BringMobs then
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
local anchorCFrame = nil
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
if obj.Humanoid.Health > 0
and obj.Name ~= lp.Name
and not obj.Name:find("Dealer")
and not obj.Name:find("Giver")
then
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
local isNoclipActive = _G.AutoFarmMobs
or _G.AutoFarmLevelQuest
or _G.AutoFarmNoClickFruit
or _G.AutoFarmBosses
or _G.SafeMode
or _G.AutoRaid
or _G.RaidKillAura
or _G.RaidAllIslandsKillAura
or _G.AutoPumpkinEvent
or _G.AutoSkullEvent
or _G.TpSea1
or _G.TpSea2
or _G.TpSea3
if isNoclipActive then
for _, child in pairs(char:GetChildren()) do
if child:IsA("BasePart") then
child.CanCollide = false
end
end
antiWater.CanCollide = true
antiWater.CFrame = CFrame.new(root.Position.X, 40, root.Position.Z)
else
antiWater.CanCollide = true
antiWater.CFrame = CFrame.new(root.Position.X, -5, root.Position.Z)
if root.Position.Y <= 12 then
local cf = CFrame.new(root.Position.X, -1, root.Position.Z)
workspace.Terrain:FillBlock(cf, Vector3.new(26, 2, 26), Enum.Material.Ice)
end
end
end
end)
end)
-- ==========================================
-- LOOP DE ENERGIA INFINITA
-- ==========================================
task.spawn(function()
while task.wait(1) do
pcall(function()
if _G.InfEnergy then
local char = lp.Character
if char then
local energy = char:FindFirstChild("Energy")
if energy and energy:IsA("NumberValue") then
energy.Value = energy.MaxValue
end
end
end
end)
end
end)
local tp1Toggle, tp2Toggle, tp3Toggle
-- ==========================================
-- LOOP PRINCIPAL (PROTEGIDO POR PCALL ISOLADO)
-- ==========================================
task.spawn(function()
while task.wait(0.05) do
local char = lp.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
if root then
-- 1. INSTANT KILL AURA
if _G.InstantKillAura then
pcall(function()
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
local eHum = obj.Humanoid
local eRoot = obj.HumanoidRootPart
if eHum.Health > 0
and obj.Name ~= lp.Name
and (root.Position - eRoot.Position).Magnitude < 150
then
executeRealAttack(eRoot.Parent)
if eHum.Health < eHum.MaxHealth then
eHum.Health = 0
end
end
end
end
end)
end
-- 2. KILL AURA PARA RAID
if _G.RaidKillAura and not _G.AutoRaid then
pcall(function()
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
end)
end
-- 2.5 KILL AURA TODAS AS 5 ILHAS DA RAID
if _G.RaidAllIslandsKillAura then
pcall(function()
local hoverCenter = getActiveRaidIslandPos(root.Position)
if hoverCenter then
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
local eHum = obj.Humanoid
local eRoot = obj.HumanoidRootPart
if eHum.Health > 0
and obj.Name ~= lp.Name
and not obj.Name:find("Dealer")
and not obj.Name:find("Giver")
then
if (hoverCenter - eRoot.Position).Magnitude < 1200 then
root.Velocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(eRoot.Position + Vector3.new(0, 12, 0), eRoot.Position)
for i = 1, 3 do
executeRealAttack(obj)
end
eHum.Health = 0
eHum:ChangeState(Enum.HumanoidStateType.Dead)
end
end
end
end
end
end)
end
-- 3. AUTO RAID COMPLETO
if _G.AutoRaid then
pcall(function()
local hoverActive = _G.RaidAllIslandsKillAura
and getActiveRaidIslandPos(root.Position) ~= nil
if not hoverActive then
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
end)
end
-- 3.5 AUTO COMPRAR CHIP DE RAID
if _G.AutoBuyChip then
pcall(function()
local hasChip = false
for _, item in pairs(lp.Backpack:GetChildren()) do
if item.Name:lower():find("chip") then
hasChip = true
break
end
end
if not hasChip then
for _, item in pairs(char:GetChildren()) do
if item.Name:lower():find("chip") then
hasChip = true
break
end
end
end
if not hasChip then
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local comm = remotes and remotes:FindFirstChild("CommF_")
if comm then
comm:InvokeServer("RaidsNpc", "Select", _G.SelectedChip)
task.wait(0.25)
comm:InvokeServer("RaidsNpc", "Buy")
end
task.wait(1.5)
end
end)
end
-- 4. AUTO FARM MOBS (QUALQUER SEA / INIMIGO PRÓXIMO)
if _G.AutoFarmMobs and not _G.AutoRaid and not _G.RaidKillAura and not _G.TpSea1 and not _G.TpSea2 and not _G.TpSea3 then
pcall(function()
local targetMob = nil
local shortestDist = 5000
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
local eHum = obj.Humanoid
local eRoot = obj.HumanoidRootPart
if eHum.Health > 0
and obj.Name ~= lp.Name
and not obj.Name:find("Dealer")
and not obj.Name:find("Giver")
and not obj.Name:find("Quest")
then
local dist = (root.Position - eRoot.Position).Magnitude
if dist < shortestDist then
shortestDist = dist
targetMob = obj
end
end
end
end
if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
local enemyRoot = targetMob.HumanoidRootPart
if (root.Position - enemyRoot.Position).Magnitude > 35 then
if not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
bypassTweenTo(enemyRoot.CFrame + Vector3.new(0, 16, 0), 250)
end
else
if activeTween then activeTween:Cancel() end
root.Velocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(enemyRoot.Position + Vector3.new(0, 14, 0), enemyRoot.Position)
executeRealAttack(targetMob)
end
elseif game.PlaceId == 4442272183 then
if not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
bypassTweenTo(CFrame.new(-3250, 250, -10500), 250)
end
end
end)
end
-- 4.2 AUTO FARM LEVEL (SEMPRE ÚLTIMA ILHA DO SEA - MAIOR XP/BELI)
if _G.AutoFarmLevelQuest and not _G.AutoRaid and not _G.RaidKillAura and not _G.TpSea1 and not _G.TpSea2 and not _G.TpSea3 then
pcall(function()
local qName, qIdx, mobName, npcCF, mobSpawnCF = getLastIslandQuestBySea()
local pGui = lp:FindFirstChild("PlayerGui")
local mainGui = pGui and pGui:FindFirstChild("Main")
local questGui = mainGui and mainGui:FindFirstChild("Quest")
local hasQuest = questGui and questGui.Visible
if not hasQuest then
if (root.Position - npcCF.Position).Magnitude > 25 then
if not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
bypassTweenTo(npcCF, 250)
end
else
if activeTween then activeTween:Cancel() end
root.Velocity = Vector3.new(0, 0, 0)
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local comm = remotes and remotes:FindFirstChild("CommF_")
if comm then
comm:InvokeServer("StartQuest", qName, qIdx)
end
task.wait(0.35)
end
else
local targetMob = nil
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and (obj.Name == mobName or obj.Name:find(mobName))
and obj:FindFirstChild("Humanoid")
and obj.Humanoid.Health > 0
then
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
if not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
bypassTweenTo(mobSpawnCF, 250)
end
end
end
end)
end
-- 4.5 AUTO FARM FRUTA (SEM CLICK E SEM HABILIDADES - CORRIGIDO)
if _G.AutoFarmNoClickFruit and not _G.AutoRaid and not _G.TpSea1 and not _G.TpSea2 and not _G.TpSea3 then
pcall(function()
local targetMob = nil
local shortestDist = 2500
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
local eHum = obj.Humanoid
local eRoot = obj.HumanoidRootPart
if eHum.Health > 0
and obj.Name ~= lp.Name
and not obj.Name:find("Dealer")
and not obj.Name:find("Giver")
and not obj.Name:find("Quest")
then
local dist = (root.Position - eRoot.Position).Magnitude
if dist < shortestDist then
shortestDist = dist
targetMob = obj
end
end
end
end
if targetMob and targetMob:FindFirstChild("HumanoidRootPart") and targetMob:FindFirstChild("Humanoid") then
if activeTween then activeTween:Cancel() end
local enemyRoot = targetMob.HumanoidRootPart
local enemyHum = targetMob.Humanoid
root.Velocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(enemyRoot.Position + Vector3.new(0, 14, 0), enemyRoot.Position)
if enemyHum.Health > enemyHum.MaxHealth * 0.85 then
executeRealAttack(targetMob)
else
equipFruitTool()
task.wait(0.08)
enemyHum.Health = 0
enemyHum:ChangeState(Enum.HumanoidStateType.Dead)
end
end
end)
end
-- 4.8 AUTO FARM BOSSES (TODOS DO MAPA)
if _G.AutoFarmBosses and not _G.AutoRaid and not _G.TpSea1 and not _G.TpSea2 and not _G.TpSea3 then
pcall(function()
local targetBoss = nil
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
local eHum = obj.Humanoid
if eHum.Health > 0
and obj.Name ~= lp.Name
and (obj.Name:find("Boss") or eHum.MaxHealth >= 25000)
then
targetBoss = obj
break
end
end
end
if targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") then
local bRoot = targetBoss.HumanoidRootPart
if (root.Position - bRoot.Position).Magnitude > 30 then
if not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
bypassTweenTo(bRoot.CFrame + Vector3.new(0, 16, 0), 250)
end
else
if activeTween then activeTween:Cancel() end
root.Velocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(bRoot.Position + Vector3.new(0, 14, 0), bRoot.Position)
executeRealAttack(targetBoss)
end
end
end)
end
-- 5. AUTO HAKI
if G.AutoHaki and not char:FindFirstChild("HasBuso") then
pcall(function()
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local comm = remotes and remotes:FindFirstChild("CommF")
if comm then
comm:InvokeServer("Buso")
end
end)
end
-- 6. PUXAR FRUTAS
if _G.FruitMagnet then
pcall(function()
for _, obj in pairs(workspace:GetChildren()) do
if obj:IsA("Tool")
and (obj.Name:find("Fruit") or obj.Name:find("Fruta"))
and obj:FindFirstChild("Handle")
then
obj.Handle.CFrame = root.CFrame
end
end
end)
end
-- 7. ESP JOGADORES
pcall(function()
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
end)
-- 8. AUTO BAÚS
if _G.AutoChests and not _G.AutoFarmMobs and not _G.AutoRaid then
pcall(function()
local chestModels = workspace:FindFirstChild("ChestModels") or workspace
for _, v in pairs(chestModels:GetChildren()) do
if not _G.AutoChests then break end
if (v:IsA("BasePart") or v:IsA("Model")) and v.Name:find("Chest") then
local part = v:IsA("Model")
and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart"))
or v
if part and part.Transparency < 1 then
root.CFrame = part.CFrame
task.wait(0.15)
end
end
end
end)
end
-- 8.5 OBLITERATE TARGET
if _G.ObliterateTarget then
pcall(function()
local target = getNearestRaidMob(root.Position)
if target and target:FindFirstChild("Humanoid") and target:FindFirstChild("HumanoidRootPart") then
for i = 1, 5 do
executeRealAttack(target)
end
target.Humanoid.Health = 0
target.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
end
end)
end
-- 8.6 MULTIPLY CURRENCY
if _G.MultiplyCurrency then
pcall(function()
local chestModels = workspace:FindFirstChild("ChestModels") or workspace
for _, v in pairs(chestModels:GetChildren()) do
if not _G.MultiplyCurrency then break end
if (v:IsA("BasePart") or v:IsA("Model")) and v.Name:find("Chest") then
local part = v:IsA("Model")
and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart"))
or v
if part and part.Transparency < 1 and (root.Position - part.Position).Magnitude < 1500 then
part.CFrame = root.CFrame
end
end
end
end)
end
-- 9. AUTO EVENTO ABÓBORA
if _G.AutoPumpkinEvent then
pcall(function()
local targetPart = nil
local shortestDist = 4000
local searchFolders = {
workspace:FindFirstChild("ChestModels"),
workspace:FindFirstChild("_WorldOrigin"),
workspace
}
for _, folder in ipairs(searchFolders) do
if folder then
for _, v in pairs(folder:GetChildren()) do
local n = v.Name:lower()
local isEvent = n:find("pumpkin")
or n:find("candy")
or n:find("abobora")
or n:find("halloween")
or n:find("trick")
or n:find("treat")
or n:find("jack")
or n:find("spooky")
or n:find("chest")
if isEvent then
local part = v:IsA("BasePart") and v
or v:FindFirstChild("Handle")
or (v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")))
if part and part:IsA("BasePart") and part.Transparency < 1 then
local dist = (root.Position - part.Position).Magnitude
if dist < shortestDist then
shortestDist = dist
targetPart = part
end
end
end
end
end
end
if targetPart then
if (root.Position - targetPart.Position).Magnitude > 15 then
if not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
bypassTweenTo(targetPart.CFrame + Vector3.new(0, 3, 0), 260)
end
else
if activeTween then activeTween:Cancel() end
root.Velocity = Vector3.new(0, 0, 0)
root.CFrame = targetPart.CFrame
if firetouchinterest then
firetouchinterest(root, targetPart, 0)
firetouchinterest(root, targetPart, 1)
end
task.wait(0.2)
end
else
for _, obj in pairs(enemiesFolder:GetChildren()) do
if not _G.AutoPumpkinEvent then break end
if obj:IsA("Model")
and obj:FindFirstChild("Humanoid")
and obj:FindFirstChild("HumanoidRootPart")
then
local eHum = obj.Humanoid
local eRoot = obj.HumanoidRootPart
if eHum.Health > 0
and obj.Name ~= lp.Name
and not obj.Name:find("Dealer")
and not obj.Name:find("Giver")
and (root.Position - eRoot.Position).Magnitude < 1800
then
root.Velocity = Vector3.new(0, 0, 0)
root.CFrame = CFrame.new(eRoot.Position + Vector3.new(0, 14, 0), eRoot.Position)
executeRealAttack(obj)
break
end
end
end
end
end)
end
-- 10. AUTO EVENTO CAVEIRA
if _G.AutoSkullEvent then
pcall(function()
for _, obj in pairs(workspace:GetDescendants()) do
if not _G.AutoSkullEvent then break end
local n = obj.Name:lower()
local isSkull = n:find("bone")
or n:find("skull")
or n:find("cursed")
or n:find("caveira")
or n:find("soul")
if (obj:IsA("BasePart") or obj:IsA("Tool") or obj:IsA("Model")) and isSkull then
local part = obj:IsA("BasePart") and obj
or obj:FindFirstChild("Handle")
or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
if part and part.Transparency < 1 then
part.CFrame = root.CFrame
root.CFrame = part.CFrame
task.wait(0.1)
end
end
end
end)
end
-- 11. AUTO ESTILO DE LUTA
if _G.AutoGetStyle then
pcall(function()
local hasStyle = lp.Backpack:FindFirstChild(_G.SelectedStyle)
or char:FindFirstChild(G.SelectedStyle)
if not hasStyle then
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local comm = remotes and remotes:FindFirstChild("CommF")
if comm then
local s = _G.SelectedStyle
if s == "Dark Step" then
comm:InvokeServer("BuyBlackLeg")
elseif s == "Electro" then
comm:InvokeServer("BuyElectro")
elseif s == "Water Kung Fu" then
comm:InvokeServer("BuyFishmanKarate")
elseif s == "Dragon Breath" then
comm:InvokeServer("BlackbeardReward", "DragonClaw", "1")
comm:InvokeServer("BlackbeardReward", "DragonClaw", "2")
elseif s == "Superhuman" then
comm:InvokeServer("BuySuperhuman")
elseif s == "Death Step" then
comm:InvokeServer("BuyDeathStep")
elseif s == "Sharkman Karate" then
comm:InvokeServer("BuySharkmanKarate", true)
comm:InvokeServer("BuySharkmanKarate")
elseif s == "Electric Claw" then
comm:InvokeServer("BuyElectricClaw")
elseif s == "Dragon Talon" then
comm:InvokeServer("BuyDragonTalon", true)
comm:InvokeServer("BuyDragonTalon")
elseif s == "Godhuman" then
comm:InvokeServer("BuyGodhuman")
elseif s == "Sanguine Art" then
comm:InvokeServer("BuySanguineArt", true)
comm:InvokeServer("BuySanguineArt")
end
end
task.wait(1.5)
end
end)
end
-- 12. TELEPORTE ILHAS SEA 1, SEA 2 E SEA 3
if _G.TpSea1 or _G.TpSea2 or _G.TpSea3 then
pcall(function()
local dest = nil
if _G.TpSea1 then
dest = Sea1Coords[_G.SelectedSea1]
elseif _G.TpSea2 then
dest = Sea2Coords[_G.SelectedSea2]
elseif _G.TpSea3 then
dest = Sea3Coords[_G.SelectedSea3]
end
if dest then
local dist = (root.Position - dest.Position).Magnitude
if dist > 20 then
if not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
bypassTweenTo(dest, 260)
end
else
if activeTween then activeTween:Cancel() end
root.CFrame = dest
root.Velocity = Vector3.new(0, 0, 0)
if hum then hum.PlatformStand = false end
if _G.TpSea1 and tp1Toggle then tp1Toggle.Set(false) end
if _G.TpSea2 and tp2Toggle then tp2Toggle.Set(false) end
if _G.TpSea3 and tp3Toggle then tp3Toggle.Set(false) end
end
end
end)
end
end
end
end)
local raidChips = {
"Flame", "Ice", "Quake", "Light", "Dark", "Spider",
"Rumble", "Magma", "Buddha", "Sand", "Phoenix", "Dough"
}
local fightingStyles = {
"Dark Step",
"Electro",
"Water Kung Fu",
"Dragon Breath",
"Superhuman",
"Death Step",
"Sharkman Karate",
"Electric Claw",
"Dragon Talon",
"Godhuman",
"Sanguine Art"
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
t1:AddToggle("Auto Farm Mobs (Original)", function(state)
_G.AutoFarmMobs = state
if not state and activeTween then activeTween:Cancel() end
end)
t1:AddToggle("Auto Farm Level (Ultima Ilha Quest)", function(state)
_G.AutoFarmLevelQuest = state
if not state and activeTween then activeTween:Cancel() end
end)
t1:AddToggle("Auto Farm Fruta (Sem Click)", function(state)
_G.AutoFarmNoClickFruit = state
end)
t1:AddToggle("Auto Farm Bosses (Todos do Mapa)", function(state)
_G.AutoFarmBosses = state
if not state and activeTween then activeTween:Cancel() end
end)
t1:AddToggle("Protecao Anti-Queda / Noclip", function(state)
_G.SafeMode = state
end)
t2:AddToggle("Instant Kill Aura", function(state)
_G.InstantKillAura = state
end)
t3:AddToggle("Auto Raid (Atacar e Avancar)", function(state)
_G.AutoRaid = state
end)
t3:AddToggle("Kill Aura Raid (Limpar Ilha)", function(state)
_G.RaidKillAura = state
end)
t3:AddToggle("Kill Aura Todas Ilhas (HitKill)", function(state)
_G.RaidAllIslandsKillAura = state
if not state and lp.Character then
local h = lp.Character:FindFirstChildOfClass("Humanoid")
if h then h.PlatformStand = false end
end
end)
t3:AddSelector("Chip da Raid", raidChips, function(val)
_G.SelectedChip = val
end)
t3:AddToggle("Auto Comprar Chip da Raid", function(state)
_G.AutoBuyChip = state
end)
t4:AddToggle("Auto Haki (Armamento)", function(state)
_G.AutoHaki = state
end)
t4:AddToggle("Puxar Frutas (Fruit Magnet)", function(state)
_G.FruitMagnet = state
end)
t4:AddToggle("ESP Jogadores (Ver no Mapa)", function(state)
_G.PlayerESP = state
end)
t4:AddToggle("Super Velocidade (WalkSpeed)", function(state)
_G.SuperSpeed = state
end)
t4:AddToggle("Remover Nevoa / FPS Boost", function(state)
_G.FpsBoost = state
if state then
Lighting.FogEnd = 9e9
Lighting.GlobalShadows = false
else
Lighting.FogEnd = 2500
Lighting.GlobalShadows = true
end
end)
t5:AddToggle("Bring Mobs (Juntar Monstros)", function(state)
_G.BringMobs = state
end)
t5:AddToggle("Energia / Pulo Infinito", function(state)
_G.InfEnergy = state
end)
t5:AddToggle("Auto Baus (Farmar Beli)", function(state)
_G.AutoChests = state
end)
t5:AddToggle("FreezeWorld (Congelar NPCs)", function(state)
_G.FreezeWorld = state
if not state then
local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
for _, obj in pairs(enemiesFolder:GetChildren()) do
if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
obj.HumanoidRootPart.Anchored = false
end
end
end
end)
t5:AddToggle("BypassDefense (Ignorar Defesa)", function(state)
_G.BypassDefense = state
end)
t5:AddToggle("ObliterateTarget (Aniquilar Alvo)", function(state)
_G.ObliterateTarget = state
end)
t5:AddToggle("MultiplyCurrency (Puxar Baus)", function(state)
_G.MultiplyCurrency = state
end)
t6:AddToggle("Auto Evento Abobora", function(state)
_G.AutoPumpkinEvent = state
if not state and activeTween then activeTween:Cancel() end
end)
t6:AddToggle("Auto Evento Caveira", function(state)
_G.AutoSkullEvent = state
end)
t7:AddSelector("Estilo de Luta", fightingStyles, function(val)
_G.SelectedStyle = val
end)
t7:AddToggle("Auto Pegar Estilo", function(state)
_G.AutoGetStyle = state
end)
t8:AddSelector("Ilha Sea 1", sea1List, function(val)
_G.SelectedSea1 = val
end)
tp1Toggle = t8:AddToggle("Teleportar Sea 1", function(state)
_G.TpSea1 = state
if not state and activeTween then activeTween:Cancel() end
end)
t8:AddSelector("Ilha Sea 2", sea2List, function(val)
_G.SelectedSea2 = val
end)
tp2Toggle = t8:AddToggle("Teleportar Sea 2", function(state)
_G.TpSea2 = state
if not state and activeTween then activeTween:Cancel() end
end)
t8:AddSelector("Ilha Sea 3", sea3List, function(val)
_G.SelectedSea3 = val
end)
tp3Toggle = t8:AddToggle("Teleportar Sea 3", function(state)
_G.TpSea3 = state
if not state and activeTween then activeTween:Cancel() end
end)
print("Infinity Evo Hub v92.2 carregado com sucesso!")
