-- [[ INFINITY EVO HUB - PANDA AUTH KEY SYSTEM (PUSL-V4) ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TargetGui = (gethui and gethui())
    or (CoreGui:FindFirstChild("RobloxGui") and CoreGui)
    or lp:WaitForChild("PlayerGui")

local PUSL = loadstring(game:HttpGet("https://pandauth.com"))()
if not PUSL or type(PUSL.configure) ~= "function" then
    return warn("[Panda] Falha ao inicializar a biblioteca de Key.")
end

PUSL.configure({
    serviceId = "infinityevohub",
})

local function loadMainHub()
    local u1 = string.reverse("aul.tpircs/niam/buh-nayR/297siulnayr/")
    local u2 = string.reverse("moc.tnetnocresubuhtig.war//:sptth")
    loadstring(game:HttpGet(u2 .. u1))()
end

-- Se o usuario ja definiu getgenv().Key antes de executar
local preKey = (getgenv and getgenv().Key) or _G.Key
if preKey and preKey ~= "" then
    local res = PUSL.validate(preKey)
    if res and res.success then
        loadMainHub()
        return
    end
end

-- Interface Neon de Key
local old = TargetGui:FindFirstChild("InfinityKeyUI")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui", TargetGui)
sg.Name = "InfinityKeyUI"
sg.ResetOnSpawn = false

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 380, 0, 220)
Main.Position = UDim2.new(0.5, -190, 0.5, -110)
Main.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2.5
Stroke.Color = Color3.fromRGB(0, 255, 220)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "INFINITY EVO HUB - KEY SYSTEM"
Title.TextColor3 = Color3.fromRGB(0, 255, 220)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -30, 0, 24)
Status.Position = UDim2.new(0, 15, 0, 48)
Status.BackgroundTransparency = 1
Status.Text = "Pegue sua key gratuita e cole abaixo:"
Status.TextColor3 = Color3.fromRGB(200, 210, 225)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12

local KeyBox = Instance.new("TextBox", Main)
KeyBox.Size = UDim2.new(1, -40, 0, 38)
KeyBox.Position = UDim2.new(0, 20, 0, 82)
KeyBox.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
KeyBox.PlaceholderText = "Cole sua Key aqui..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.Font = Enum.Font.GothamSemibold
KeyBox.TextSize = 12
KeyBox.ClearTextOnFocus = false
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 6)
local boxStroke = Instance.new("UIStroke", KeyBox)
boxStroke.Thickness = 1
boxStroke.Color = Color3.fromRGB(0, 255, 220)

local GetKeyBtn = Instance.new("TextButton", Main)
GetKeyBtn.Size = UDim2.new(0.45, -15, 0, 38)
GetKeyBtn.Position = UDim2.new(0, 20, 0, 138)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(26, 34, 52)
GetKeyBtn.Text = "Pegar Key (Link)"
GetKeyBtn.TextColor3 = Color3.fromRGB(0, 255, 220)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 12
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

local CheckBtn = Instance.new("TextButton", Main)
CheckBtn.Size = UDim2.new(0.45, -15, 0, 38)
CheckBtn.Position = UDim2.new(0.55, -5, 0, 138)
CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
CheckBtn.Text = "Verificar Key"
CheckBtn.TextColor3 = Color3.fromRGB(10, 12, 18)
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 12
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 6)

GetKeyBtn.MouseButton1Click:Connect(function()
    local link = PUSL.getKeyUrl() or "https://pandauth.com"
    if setclipboard then
        setclipboard(link)
        Status.Text = "Link copiado! Cole no seu navegador."
        Status.TextColor3 = Color3.fromRGB(0, 255, 170)
    else
        KeyBox.Text = link
        Status.Text = "Copie o link da caixa acima no navegador!"
    end
end)

CheckBtn.MouseButton1Click:Connect(function()
    local inputKey = KeyBox.Text:gsub("%s+", "")
    if inputKey == "" then
        Status.Text = "Digite ou cole uma key primeiro!"
        Status.TextColor3 = Color3.fromRGB(235, 75, 75)
        return
    end

    Status.Text = "Verificando key no servidor..."
    Status.TextColor3 = Color3.fromRGB(255, 220, 80)

    local result = PUSL.validate(inputKey)
    if result and result.success then
        Status.Text = "Key valida! Carregando hub..."
        Status.TextColor3 = Color3.fromRGB(0, 255, 170)
        task.wait(0.4)
        sg:Destroy()
        loadMainHub()
    else
        Status.Text = "Key invalida ou expirada! Tente novamente."
        Status.TextColor3 = Color3.fromRGB(235, 75, 75)
    end
end)
