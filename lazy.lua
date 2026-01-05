-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

pcall(function()
    player.PlayerGui.BrodyGui:Destroy()
end)

local MIN_SPEED, MAX_SPEED = 16, 90
local speedEnabled = false
local noclipEnabled = false
local espEnabled = false
local currentSpeed = 16

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BrodyGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 270, 0, 230)
frame.Position = UDim2.new(0.5, -135, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local banner = Instance.new("TextLabel", frame)
banner.Size = UDim2.new(1,0,0,25)
banner.BackgroundColor3 = Color3.fromRGB(15,15,15)
banner.Text = "LAZY SCRIPT by BRODZ"
banner.TextColor3 = Color3.fromRGB(0,255,180)
banner.Font = Enum.Font.GothamBold
banner.TextSize = 14
banner.BorderSizePixel = 0
Instance.new("UICorner", banner).CornerRadius = UDim.new(0,12)

local mini = Instance.new("TextButton", banner)
mini.Size = UDim2.new(0,25,1,0)
mini.Position = UDim2.new(1,-25,0,0)
mini.Text = "-"
mini.BackgroundTransparency = 1
mini.TextColor3 = Color3.new(1,1,1)

local container = Instance.new("Frame", frame)
container.Position = UDim2.new(0,0,0,30)
container.Size = UDim2.new(1,0,1,-30)
container.BackgroundTransparency = 1

local box = Instance.new("TextBox", container)
box.Size = UDim2.new(0.8,0,0,30)
box.Position = UDim2.new(0.1,0,0,0)
box.Text = "16"
box.PlaceholderText = "Speed 16 - 90"
box.BackgroundColor3 = Color3.fromRGB(25,25,25)
box.TextColor3 = Color3.new(1,1,1)
box.BorderSizePixel = 0
Instance.new("UICorner", box)

local function makeBtn(text, y)
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(0.8,0,0,32)
    b.Position = UDim2.new(0.1,0,y,0)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b)
    return b
end

local speedBtn = makeBtn("Speed OFF", 0.18)
local noclipBtn = makeBtn("Noclip OFF", 0.36)
local espBtn = makeBtn("ESP OFF", 0.54)

local function humanoid()
    return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

local function lockSpeed(h)
    h.WalkSpeed = currentSpeed
    h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if speedEnabled and h.WalkSpeed ~= currentSpeed then
            h.WalkSpeed = currentSpeed
        end
    end)
end

box.FocusLost:Connect(function()
    local v = tonumber(box.Text)
    if v then
        currentSpeed = math.clamp(v, MIN_SPEED, MAX_SPEED)
        box.Text = tostring(currentSpeed)
        if speedEnabled and humanoid() then
            humanoid().WalkSpeed = currentSpeed
        end
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    local h = humanoid()
    if not h then return end
    speedEnabled = not speedEnabled
    speedBtn.Text = speedEnabled and ("Speed ON ("..currentSpeed..")") or "Speed OFF"
    if speedEnabled then
        lockSpeed(h)
    else
        h.WalkSpeed = 16
    end
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and player.Character then
        for _,v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "Noclip ON" or "Noclip OFF"
end)

local espCache = {}

local function getSize(plr)
    if plr:FindFirstChild("leaderstats") then
        for _,v in pairs(plr.leaderstats:GetChildren()) do
            if v:IsA("NumberValue") then
                return v.Value
            end
        end
    end
    return nil
end

local function addESP(plr)
    if plr == player then return end

    local function apply(char)
        if espCache[plr] then
            for _,v in pairs(espCache[plr]) do
                v:Destroy()
            end
        end

        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 0.9
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char

        task.spawn(function()
            while espEnabled and char.Parent do
                local mySize = getSize(player)
                local enemySize = getSize(plr)

                hl.FillColor = Color3.fromRGB(255,0,0) -- MERAH
                hl.OutlineColor = Color3.fromRGB(255,255,255)

                task.wait(0.4)
            end
        end)

        espCache[plr] = {hl}
    end

    if plr.Character then apply(plr.Character) end
    plr.CharacterAdded:Connect(apply)
end

local function clearESP()
    for _,objs in pairs(espCache) do
        for _,v in pairs(objs) do
            v:Destroy()
        end
    end
    espCache = {}
end

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP ON" or "ESP OFF"

    if espEnabled then
        for _,p in pairs(Players:GetPlayers()) do
            addESP(p)
        end
        Players.PlayerAdded:Connect(addESP)
    else
        clearESP()
    end
end)

local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    container.Visible = not minimized
    frame.Size = minimized and UDim2.new(0,270,0,30) or UDim2.new(0,270,0,230)
    mini.Text = minimized and "+" or "-"
end)

player.CharacterAdded:Connect(function(c)
    if speedEnabled then lockSpeed(c:WaitForChild("Humanoid")) end
end)