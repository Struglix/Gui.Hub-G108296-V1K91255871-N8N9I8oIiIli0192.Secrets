local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local userId = player.UserId

-- ===== SCRIPT DATA (JSON STYLE) =====
local ScriptsData = {
    main = {
        {
            name = "Speed Boost",
            tab = "Movement",
            content = [[
                local plr = game:GetService("Players").LocalPlayer
                local char = plr.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = 100
                    print("Speed set to 100")
                end
            ]]
        },
        {
            name = "Jump Power",
            tab = "Movement",
            content = [[
                local plr = game:GetService("Players").LocalPlayer
                local char = plr.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = 80
                    print("Jump power set to 80")
                end
            ]]
        },
        {
            name = "Infinite Yield",
            tab = "Utility",
            content = [[
                loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            ]]
        },
        {
            name = "ESP Toggle",
            tab = "Visuals",
            content = [[
                local players = game:GetService("Players")
                local lp = players.LocalPlayer
                local enabled = false
                local function addESP(plr)
                    if plr == lp then return end
                    local char = plr.Character
                    if not char then return end
                    local hl = Instance.new("Highlight")
                    hl.Parent = char
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Enabled = true
                end
                enabled = not enabled
                if enabled then
                    for _, plr in ipairs(players:GetPlayers()) do addESP(plr) end
                    players.PlayerAdded:Connect(addESP)
                    print("ESP ON")
                else
                    for _, plr in ipairs(players:GetPlayers()) do
                        local char = plr.Character
                        if char then
                            local hl = char:FindFirstChild("Highlight")
                            if hl then hl:Destroy() end
                        end
                    end
                    print("ESP OFF")
                end
            ]]
        }
    }
}

-- ===== COLORS =====
local COLORS = {
    Bg = Color3.fromRGB(8, 10, 16),
    Sidebar = Color3.fromRGB(5, 7, 12),
    Content = Color3.fromRGB(12, 15, 22),
    Accent = Color3.fromRGB(220, 220, 230),
    Text = Color3.fromRGB(230, 230, 240),
    TextSub = Color3.fromRGB(160, 165, 180),
    FoldBg = Color3.fromRGB(200, 200, 210),
    ExitBg = Color3.fromRGB(200, 40, 40),
    Red = Color3.fromRGB(220, 60, 60),
    White = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(60, 200, 80),
    Orange = Color3.fromRGB(220, 160, 40),
    Blue = Color3.fromRGB(60, 140, 220),
}

local TRANSPARENCY = {
    Main = 0.1,
    Sidebar = 0.5,
    Content = 0.2,
    Tab = 0.8,
    TabActive = 0.1,
    Button = 0.5,
    ButtonHover = 0.1,
    Fold = 0.0,
    Exit = 0.0,
    Notification = 0.1,
}

-- ===== AVATAR =====
local AVATAR_URL = ""
local function getAvatar()
    local success, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
    end)
    AVATAR_URL = (success and thumb) or ""
end
getAvatar()

-- ===== EXECUTE FUNCTION =====
local function executeScript(content, name)
    local success, err = pcall(function()
        local fn, loadErr = loadstring(content)
        if fn then
            fn()
            showNotification("✅ " .. (name or "Script") .. " executed!", "success")
            return true
        else
            showNotification("❌ Load error: " .. tostring(loadErr), "error")
            return false
        end
    end)
    if not success then
        showNotification("❌ Execute error: " .. tostring(err), "error")
        return false
    end
    return true
end

-- ===== NOTIFICATION =====
local function showNotification(text, type)
    local screenGui = screenGuiRef or game:GetService("CoreGui"):FindFirstChild("MzSRHub")
    if not screenGui then return end
    
    local duration = 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 360, 0, 64)
    notif.Position = UDim2.new(0.5, -180, 0, 20)
    notif.BackgroundColor3 = COLORS.Bg
    notif.BackgroundTransparency = 1
    notif.BorderSizePixel = 0
    notif.Parent = screenGui
    notif.ClipsDescendants = true

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 14)
    notifCorner.Parent = notif

    local blur = Instance.new("BlurEffect")
    blur.Size = 16
    blur.Parent = notif

    local color = COLORS.Accent
    if type == "success" then color = COLORS.Green
    elseif type == "error" then color = COLORS.Red
    elseif type == "warning" then color = COLORS.Orange
    elseif type == "info" then color = COLORS.Blue end

    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 0, 3)
    border.BackgroundColor3 = color
    border.BackgroundTransparency = 0
    border.BorderSizePixel = 0
    border.Parent = notif

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = type == "success" and "OK" or type == "error" and "XX" or type == "warning" and "!!" or "i"
    icon.TextColor3 = color
    icon.TextSize = 18
    icon.Font = Enum.Font.GothamBold
    icon.Parent = notif

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -48, 1, -10)
    textLabel.Position = UDim2.new(0, 44, 0, 2)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = COLORS.Text
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextTruncate = Enum.TextTruncate.AtEnd
    textLabel.Parent = notif

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, -48, 0, 3)
    progressBg.Position = UDim2.new(0, 44, 1, -4)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    progressBg.BackgroundTransparency = 0.5
    progressBg.BorderSizePixel = 0
    progressBg.Parent = notif
    local progressBgCorner = Instance.new("UICorner")
    progressBgCorner.CornerRadius = UDim.new(1, 0)
    progressBgCorner.Parent = progressBg

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = color
    progressBar.BackgroundTransparency = 0
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(1, 0)
    progressBarCorner.Parent = progressBar

    notif.BackgroundTransparency = 1
    notif.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = TRANSPARENCY.Notification,
        Size = UDim2.new(0, 360, 0, 64)
    }):Play()

    local startTime = tick()
    local progressConnection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local remaining = math.max(0, 1 - (elapsed / duration))
        progressBar.Size = UDim2.new(remaining, 0, 1, 0)
        if remaining <= 0 then
            progressConnection:Disconnect()
        end
    end)

    task.wait(duration)
    progressConnection:Disconnect()
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.wait(0.3)
    notif:Destroy()
end

-- ===== BUILD UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MzSRHub"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGuiRef = screenGui

-- Main Frame
local main = Instance.new("Frame")
main.Name = "MainUI"
main.Size = UDim2.new(0, 720, 0, 500)
main.Position = UDim2.new(0.5, -360, 0.5, -250)
main.BackgroundColor3 = COLORS.Bg
main.BackgroundTransparency = TRANSPARENCY.Main
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = main

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, 0)
sidebar.BackgroundColor3 = COLORS.Sidebar
sidebar.BackgroundTransparency = TRANSPARENCY.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 18)
sidebarCorner.Parent = sidebar

-- Header
local headerSide = Instance.new("Frame")
headerSide.Size = UDim2.new(1, 0, 0, 80)
headerSide.BackgroundTransparency = 1
headerSide.Parent = sidebar

local titleMain = Instance.new("TextLabel")
titleMain.Size = UDim2.new(1, -16, 0, 28)
titleMain.Position = UDim2.new(0, 12, 0, 10)
titleMain.BackgroundTransparency = 1
titleMain.Text = "MnSr"
titleMain.TextColor3 = COLORS.Text
titleMain.TextSize = 24
titleMain.Font = Enum.Font.GothamBold
titleMain.TextXAlignment = Enum.TextXAlignment.Left
titleMain.Parent = headerSide

local titleSub = Instance.new("TextLabel")
titleSub.Size = UDim2.new(1, -16, 0, 18)
titleSub.Position = UDim2.new(0, 12, 0, 40)
titleSub.BackgroundTransparency = 1
titleSub.Text = "Executor Hub"
titleSub.TextColor3 = COLORS.TextSub
titleSub.TextSize = 12
titleSub.Font = Enum.Font.GothamMedium
titleSub.TextXAlignment = Enum.TextXAlignment.Left
titleSub.TextTransparency = 0.4
titleSub.Parent = headerSide

-- Profile
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(1, -8, 0, 56)
profileFrame.Position = UDim2.new(0, 4, 0, 70)
profileFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
profileFrame.BackgroundTransparency = 0.6
profileFrame.Parent = sidebar
local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0, 10)
profileCorner.Parent = profileFrame

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 34, 0, 34)
avatarImage.Position = UDim2.new(0, 8, 0.5, -17)
avatarImage.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
avatarImage.BackgroundTransparency = 0
if AVATAR_URL ~= "" then
    avatarImage.Image = AVATAR_URL
else
    avatarImage.Image = "rbxassetid://6031095031"
end
avatarImage.Parent = profileFrame
local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatarImage

local nameMain = Instance.new("TextLabel")
nameMain.Size = UDim2.new(0, 80, 0, 16)
nameMain.Position = UDim2.new(0, 48, 0, 12)
nameMain.BackgroundTransparency = 1
nameMain.Text = player.Name
nameMain.TextColor3 = COLORS.Text
nameMain.TextSize = 13
nameMain.Font = Enum.Font.GothamBold
nameMain.TextXAlignment = Enum.TextXAlignment.Left
nameMain.Parent = profileFrame

local nameSub = Instance.new("TextLabel")
nameSub.Size = UDim2.new(0, 80, 0, 14)
nameSub.Position = UDim2.new(0, 48, 0, 30)
nameSub.BackgroundTransparency = 1
nameSub.Text = "@" .. player.DisplayName
nameSub.TextColor3 = COLORS.TextSub
nameSub.TextSize = 11
nameSub.Font = Enum.Font.Gotham
nameSub.TextXAlignment = Enum.TextXAlignment.Left
nameSub.Parent = profileFrame

-- Tab Container
local tabContainer = Instance.new("ScrollingFrame")
tabContainer.Size = UDim2.new(1, -8, 0, 210)
tabContainer.Position = UDim2.new(0, 4, 0, 134)
tabContainer.BackgroundTransparency = 1
tabContainer.BorderSizePixel = 0
tabContainer.ScrollBarThickness = 3
tabContainer.ScrollingDirection = Enum.ScrollingDirection.Y
tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
tabContainer.Parent = sidebar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 4)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabContainer

-- Get unique tabs from ScriptsData
local function getTabs()
    local tabs = {}
    for _, data in ipairs(ScriptsData.main) do
        if data.tab and not tabs[data.tab] then
            tabs[data.tab] = true
        end
    end
    local result = {}
    for tab, _ in pairs(tabs) do
        table.insert(result, tab)
    end
    return result
end

local tabNames = getTabs()
local tabBtns = {}

for _, tabName in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    btn.BackgroundTransparency = TRANSPARENCY.Tab
    btn.Text = "  " .. tabName
    btn.TextColor3 = Color3.fromRGB(180, 190, 210)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = tabContainer
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    table.insert(tabBtns, btn)
end

tabContainer.CanvasSize = UDim2.new(0, 0, 0, #tabNames * 38 + 8)

-- Content Area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -152, 1, -12)
content.Position = UDim2.new(0, 142, 0, 6)
content.BackgroundColor3 = COLORS.Content
content.BackgroundTransparency = TRANSPARENCY.Content
content.BorderSizePixel = 0
content.Parent = main
local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 16)
contentCorner.Parent = content

-- Content Header
local contentHeader = Instance.new("Frame")
contentHeader.Size = UDim2.new(1, -16, 0, 48)
contentHeader.Position = UDim2.new(0, 8, 0, 6)
contentHeader.BackgroundTransparency = 1
contentHeader.Parent = content

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(0, 80, 1, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "Scripts"
headerTitle.TextColor3 = COLORS.Text
headerTitle.TextSize = 16
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = contentHeader

-- Fold Button
local foldBtn = Instance.new("TextButton")
foldBtn.Size = UDim2.new(0, 34, 0, 34)
foldBtn.Position = UDim2.new(1, -82, 0.5, -17)
foldBtn.BackgroundColor3 = COLORS.FoldBg
foldBtn.BackgroundTransparency = TRANSPARENCY.Fold
foldBtn.Text = "-"
foldBtn.TextColor3 = COLORS.Bg
foldBtn.TextSize = 20
foldBtn.Font = Enum.Font.GothamBold
foldBtn.Parent = contentHeader
local foldCorner = Instance.new("UICorner")
foldCorner.CornerRadius = UDim.new(0, 8)
foldCorner.Parent = foldBtn

-- Exit Button
local exitBtn = Instance.new("TextButton")
exitBtn.Size = UDim2.new(0, 34, 0, 34)
exitBtn.Position = UDim2.new(1, -40, 0.5, -17)
exitBtn.BackgroundColor3 = COLORS.ExitBg
exitBtn.BackgroundTransparency = TRANSPARENCY.Exit
exitBtn.Text = "X"
exitBtn.TextColor3 = COLORS.White
exitBtn.TextSize = 18
exitBtn.Font = Enum.Font.GothamBold
exitBtn.Parent = contentHeader
local exitCorner = Instance.new("UICorner")
exitCorner.CornerRadius = UDim.new(0, 8)
exitCorner.Parent = exitBtn

-- Body (Script List)
local body = Instance.new("ScrollingFrame")
body.Size = UDim2.new(1, -16, 1, -62)
body.Position = UDim2.new(0, 8, 0, 58)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 3
body.ScrollingDirection = Enum.ScrollingDirection.Y
body.CanvasSize = UDim2.new(0, 0, 0, 0)
body.Parent = content

local bodyLayout = Instance.new("UIListLayout")
bodyLayout.Padding = UDim.new(0, 6)
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
bodyLayout.Parent = body

-- ===== RENDER SCRIPTS =====
local function renderScripts(tabName)
    for _, child in ipairs(body:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local count = 0
    for _, data in ipairs(ScriptsData.main) do
        if data.tab == tabName then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 42)
            btn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
            btn.BackgroundTransparency = TRANSPARENCY.Button
            btn.Text = "  " .. data.name
            btn.TextColor3 = COLORS.Text
            btn.TextSize = 15
            btn.Font = Enum.Font.GothamSemibold
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = body
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 10)
            btnCorner.Parent = btn

            -- Status indicator
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.Position = UDim2.new(1, -22, 0.5, -4)
            dot.BackgroundColor3 = COLORS.Green
            dot.BackgroundTransparency = 0.3
            dot.BorderSizePixel = 0
            dot.Parent = btn
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = TRANSPARENCY.ButtonHover}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = TRANSPARENCY.Button}):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                local success = executeScript(data.content, data.name)
                if success then
                    dot.BackgroundColor3 = COLORS.Green
                    dot.BackgroundTransparency = 0
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(40, 60, 40)
                    }):Play()
                    task.wait(0.1)
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(30, 35, 50)
                    }):Play()
                else
                    dot.BackgroundColor3 = COLORS.Red
                    dot.BackgroundTransparency = 0
                end
            end)
            
            count = count + 1
        end
    end
    body.CanvasSize = UDim2.new(0, 0, 0, count * 48 + 8)
end

-- Tab click handlers
for i, btn in ipairs(tabBtns) do
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabBtns) do
            b.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
            b.BackgroundTransparency = TRANSPARENCY.Tab
            b.TextColor3 = Color3.fromRGB(180, 190, 210)
        end
        btn.BackgroundColor3 = COLORS.Accent
        btn.BackgroundTransparency = TRANSPARENCY.TabActive
        btn.TextColor3 = COLORS.Bg
        renderScripts(tabNames[i])
    end)
end

-- Select first tab
if #tabBtns > 0 then
    tabBtns[1].BackgroundColor3 = COLORS.Accent
    tabBtns[1].BackgroundTransparency = TRANSPARENCY.TabActive
    tabBtns[1].TextColor3 = COLORS.Bg
    renderScripts(tabNames[1])
end

-- ===== DRAG FUNCTION =====
local dragging = false
local dragInput, dragStart, startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        main.ZIndex = 10
    end
end)

main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        main.ZIndex = 1
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ===== FOLD MODE =====
local miniFrame = nil
local isFolded = false
local dragIndex = 1
local dragAnimConnection = nil
local DRAG_FRAMES = {"|", "/", "-", "\\"}

local function animateDrag(icon)
    if dragAnimConnection then dragAnimConnection:Disconnect() end
    dragIndex = 1
    dragAnimConnection = RunService.RenderStepped:Connect(function()
        icon.Text = DRAG_FRAMES[dragIndex]
        dragIndex = dragIndex + 1
        if dragIndex > #DRAG_FRAMES then dragIndex = 1 end
    end)
end

local function createMiniMode()
    if miniFrame then return end
    
    miniFrame = Instance.new("Frame")
    miniFrame.Size = UDim2.new(0, 160, 0, 44)
    miniFrame.Position = UDim2.new(0, 12, 0, 12)
    miniFrame.BackgroundColor3 = COLORS.Bg
    miniFrame.BackgroundTransparency = 0.2
    miniFrame.BorderSizePixel = 0
    miniFrame.Parent = screenGui

    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 12)
    miniCorner.Parent = miniFrame

    miniFrame.BackgroundTransparency = 1
    miniFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(miniFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 160, 0, 44)
    }):Play()

    local dragIcon = Instance.new("TextButton")
    dragIcon.Size = UDim2.new(0, 32, 0, 32)
    dragIcon.Position = UDim2.new(0, 6, 0.5, -16)
    dragIcon.BackgroundTransparency = 1
    dragIcon.Text = "|"
    dragIcon.TextColor3 = COLORS.Accent
    dragIcon.TextSize = 18
    dragIcon.Font = Enum.Font.GothamBold
    dragIcon.Parent = miniFrame
    animateDrag(dragIcon)

    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 110, 0, 34)
    openBtn.Position = UDim2.new(0, 42, 0.5, -17)
    openBtn.BackgroundColor3 = COLORS.Accent
    openBtn.BackgroundTransparency = 0.1
    openBtn.Text = "OPEN"
    openBtn.TextColor3 = COLORS.Bg
    openBtn.TextSize = 13
    openBtn.Font = Enum.Font.GothamBold
    openBtn.Parent = miniFrame
    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(0, 8)
    openCorner.Parent = openBtn

    local dragMini = false
    local dragMiniStart, dragMiniPos
    dragIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragMini = true
            dragMiniStart = input.Position
            dragMiniPos = miniFrame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragMini = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragMini and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragMiniStart
            miniFrame.Position = UDim2.new(
                dragMiniPos.X.Scale,
                dragMiniPos.X.Offset + delta.X,
                dragMiniPos.Y.Scale,
                dragMiniPos.Y.Offset + delta.Y
            )
        end
    end)

    openBtn.MouseButton1Click:Connect(function()
        if dragAnimConnection then
            dragAnimConnection:Disconnect()
            dragAnimConnection = nil
        end
        TweenService:Create(miniFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.2)
        miniFrame:Destroy()
        miniFrame = nil
        main.Visible = true
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 720, 0, 500)
        }):Play()
        isFolded = false
        foldBtn.Text = "-"
    end)
end

foldBtn.MouseButton1Click:Connect(function()
    if isFolded then
        if dragAnimConnection then
            dragAnimConnection:Disconnect()
            dragAnimConnection = nil
        end
        if miniFrame then
            TweenService:Create(miniFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.wait(0.2)
            miniFrame:Destroy()
            miniFrame = nil
        end
        main.Visible = true
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 720, 0, 500)
        }):Play()
        isFolded = false
        foldBtn.Text = "-"
    else
        TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.25)
        main.Visible = false
        createMiniMode()
        isFolded = true
        foldBtn.Text = "+"
    end
end)

-- ===== EXIT =====
exitBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if miniFrame then miniFrame:Destroy() end
    if dragAnimConnection then
        dragAnimConnection:Disconnect()
        dragAnimConnection = nil
    end
end)

-- ===== KEYBOARD SHORTCUTS =====
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E and input.UserInputType == Enum.UserInputType.Keyboard then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            screenGui.Enabled = not screenGui.Enabled
            showNotification(screenGui.Enabled and "🔓 UI Shown" or "🔒 UI Hidden", "info")
        end
    end
    if input.KeyCode == Enum.KeyCode.R and input.UserInputType == Enum.UserInputType.Keyboard then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            showNotification("🔄 Reloading scripts...", "info")
            for _, child in ipairs(body:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            renderScripts(tabNames[1])
            showNotification("✅ Reloaded!", "success")
        end
    end
end)

-- ===== ENTRY ANIMATION =====
main.BackgroundTransparency = 1
main.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
    BackgroundTransparency = TRANSPARENCY.Main,
    Size = UDim2.new(0, 720, 0, 500)
}):Play()

-- ===== GLOBAL API =====
_G.MzSRHub = {
    AddScript = function(data)
        if not data.name or not data.content then
            showNotification("❌ Need name + content", "error")
            return false
        end
        local tab = data.tab or "Main"
        table.insert(ScriptsData.main, data)
        
        -- Refresh UI
        for _, child in ipairs(body:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        renderScripts(tabNames[1])
        showNotification("✅ Added: " .. data.name, "success")
        return true
    end,
    Execute = executeScript,
    Show = function()
        screenGui.Enabled = true
        showNotification("🔓 UI Shown", "info")
    end,
    Hide = function()
        screenGui.Enabled = false
        showNotification("🔒 UI Hidden", "info")
    end,
    Toggle = function()
        screenGui.Enabled = not screenGui.Enabled
        showNotification(screenGui.Enabled and "🔓 UI Shown" or "🔒 UI Hidden", "info")
    end
}

print("⚡ MzSR Hub loaded!")
print("📋 Use _G.MzSRHub to interact")
print("⌨ Ctrl+E = Toggle UI | Ctrl+R = Reload")
