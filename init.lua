-- EclipseUI Library
local EclipseUI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local HOVER_TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local OPEN_TWEEN = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local DROPDOWN_TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local MINIMIZE_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TOGGLE_TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TAB_TWEEN = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function ApplyGlow(targetFrame, cornerRadius)
    local GlowStroke = Instance.new("UIStroke")
    GlowStroke.Name = "GlowStroke"
    GlowStroke.Color = Color3.fromRGB(255, 255, 255)
    GlowStroke.Transparency = 0.85
    GlowStroke.Thickness = 1.5
    GlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    GlowStroke.Parent = targetFrame

    if not targetFrame:FindFirstChildOfClass("UICorner") then
        Instance.new("UICorner", targetFrame).CornerRadius = UDim.new(0, cornerRadius or 8)
    end
    return GlowStroke
end

local function CenterTextLabel(text, parent, fontSize, font, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.Position = UDim2.fromScale(0.5, 0.5)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextSize = fontSize or 13
    label.Font = font or Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

function EclipseUI:CreateWindow(windowTitle)
    local WindowLib = {}
    
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "EclipseUIGui"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = Player:WaitForChild("PlayerGui")

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.fromOffset(360, 260)
    Container.Position = UDim2.fromScale(0.5, 0.5)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundTransparency = 1
    Container.Parent = Gui

    local UIScale = Instance.new("UIScale")
    UIScale.Scale = 0
    UIScale.Parent = Container

    local MainCanvas = Instance.new("Frame")
    MainCanvas.Name = "MainCanvas"
    MainCanvas.Size = UDim2.new(1, -10, 0, 215)
    MainCanvas.Position = UDim2.fromOffset(5, 40)
    MainCanvas.BackgroundTransparency = 1
    MainCanvas.ClipsDescendants = false
    MainCanvas.Parent = Container

    local MainGlowStroke = ApplyGlow(MainCanvas, 10)

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.fromScale(1, 1)
    Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Main.BackgroundTransparency = 0.15
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = MainCanvas

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    local DragOverlay = Instance.new("CanvasGroup")
    DragOverlay.Name = "DragOverlay"
    DragOverlay.Size = UDim2.fromScale(1, 1)
    DragOverlay.BackgroundTransparency = 1
    DragOverlay.GroupTransparency = 1
    DragOverlay.Visible = false
    DragOverlay.ZIndex = 500
    DragOverlay.Parent = MainCanvas

    local IronmanTitle = Instance.new("TextLabel")
    IronmanTitle.Name = "WindowTitle"
    IronmanTitle.Size = UDim2.new(1, 0, 0, 40)
    IronmanTitle.Position = UDim2.fromScale(0.5, 0.5)
    IronmanTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    IronmanTitle.BackgroundTransparency = 1
    IronmanTitle.Text = windowTitle or "ECLIPSE UI"
    IronmanTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    IronmanTitle.TextTransparency = 0.1
    IronmanTitle.TextSize = 22
    IronmanTitle.Font = Enum.Font.Merriweather
    IronmanTitle.TextXAlignment = Enum.TextXAlignment.Center
    IronmanTitle.TextYAlignment = Enum.TextYAlignment.Center
    IronmanTitle.ZIndex = 501
    IronmanTitle.Parent = DragOverlay

    local ElementStrokeTemplate = Instance.new("UIStroke")
    ElementStrokeTemplate.Color = Color3.fromRGB(255, 255, 255)
    ElementStrokeTemplate.Transparency = 0.92
    ElementStrokeTemplate.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Title Pill
    local Pill = Instance.new("TextButton")
    Pill.Name = "TitlePill"
    Pill.Size = UDim2.fromOffset(90, 28)
    Pill.Position = UDim2.fromOffset(5, 5)
    Pill.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Pill.BackgroundTransparency = 0.15
    Pill.Text = ""
    Pill.AutoButtonColor = false
    Pill.ZIndex = 100
    Pill.Parent = Container

    ApplyGlow(Pill, 8)
    local PillLabel = CenterTextLabel(windowTitle or "Eclipse", Pill, 13, Enum.Font.GothamBold, Color3.fromRGB(255, 255, 255))
    PillLabel.ZIndex = 101

    -- FPS Pill
    local FPSPill = Instance.new("Frame")
    FPSPill.Name = "FPSPill"
    FPSPill.Size = UDim2.fromOffset(65, 28)
    FPSPill.Position = UDim2.fromOffset(100, 5)
    FPSPill.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    FPSPill.BackgroundTransparency = 0.15
    FPSPill.ZIndex = 100
    FPSPill.Parent = Container

    ApplyGlow(FPSPill, 8)
    local FPSLabel = CenterTextLabel("-- FPS", FPSPill, 13, Enum.Font.GothamBold, Color3.fromHex("#00ff88"))
    FPSLabel.ZIndex = 101

    -- Ping Pill
    local PingPill = Instance.new("Frame")
    PingPill.Name = "PingPill"
    PingPill.Size = UDim2.fromOffset(75, 28)
    PingPill.Position = UDim2.fromOffset(170, 5)
    PingPill.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    PingPill.BackgroundTransparency = 0.15
    PingPill.ZIndex = 100
    PingPill.Parent = Container

    ApplyGlow(PingPill, 8)
    local PingLabel = CenterTextLabel("PING: --", PingPill, 13, Enum.Font.GothamBold, Color3.fromHex("#00ff88"))
    PingLabel.ZIndex = 101

    -- Stats Updater Loop
    local lastUpdate = tick()
    local frameCount = 0
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastUpdate >= 1 then
            local fps = math.floor(frameCount / (now - lastUpdate))
            FPSLabel.Text = fps .. " FPS"
            
            local activeFpsColor = fps >= 50 and Color3.fromHex("#00ff88") or (fps >= 30 and Color3.fromHex("#ffdd00") or Color3.fromHex("#ff4444"))
            TweenService:Create(FPSLabel, HOVER_TWEEN, {TextColor3 = activeFpsColor}):Play()

            local success, pingVal = pcall(function()
                return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local ping = success and pingVal or 0
            PingLabel.Text = ping .. " ms"

            local activePingColor = ping <= 80 and Color3.fromHex("#00ff88") or (ping <= 160 and Color3.fromHex("#ffdd00") or Color3.fromHex("#ff4444"))
            TweenService:Create(PingLabel, HOVER_TWEEN, {TextColor3 = activePingColor}):Play()

            frameCount = 0
            lastUpdate = now
        end
    end)

    -- Window Controls Group
    local ControlsGroup = Instance.new("Frame")
    ControlsGroup.Name = "ControlsGroup"
    ControlsGroup.Size = UDim2.fromOffset(61, 28)
    ControlsGroup.Position = UDim2.new(1, -66, 0, 5)
    ControlsGroup.BackgroundTransparency = 1
    ControlsGroup.ZIndex = 100
    ControlsGroup.Parent = Container

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseButton"
    CloseBtn.Size = UDim2.fromOffset(28, 28)
    CloseBtn.Position = UDim2.fromOffset(33, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    CloseBtn.BackgroundTransparency = 0.15
    CloseBtn.Text = ""
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 101
    CloseBtn.Parent = ControlsGroup

    local CloseBtnLabel = CenterTextLabel("x", CloseBtn, 13, Enum.Font.GothamBold, Color3.fromRGB(200, 200, 210))
    CloseBtnLabel.ZIndex = 102
    local CloseGlowStroke = ApplyGlow(CloseBtn, 8)

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeButton"
    MinimizeBtn.Size = UDim2.fromOffset(28, 28)
    MinimizeBtn.Position = UDim2.fromOffset(0, 0)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MinimizeBtn.BackgroundTransparency = 0.15
    MinimizeBtn.Text = ""
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.ZIndex = 101
    MinimizeBtn.Parent = ControlsGroup

    local MinimizeBtnLabel = CenterTextLabel("-", MinimizeBtn, 16, Enum.Font.GothamBold, Color3.fromRGB(200, 200, 210))
    MinimizeBtnLabel.ZIndex = 102
    local MinimizeGlowStroke = ApplyGlow(MinimizeBtn, 8)

    -- Dragging Logic
    local Dragging, DragStart, StartPosition = false, Vector3.zero, Container.Position
    local TargetPosition = Container.Position

    Pill.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPosition = Container.Position
            TargetPosition = Container.Position
            DragOverlay.Visible = true
            TweenService:Create(DragOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if Dragging then
                Dragging = false
                local fadeOut = TweenService:Create(DragOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1})
                fadeOut:Play()
                fadeOut.Completed:Connect(function()
                    if not Dragging then DragOverlay.Visible = false end
                end)
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - DragStart
            TargetPosition = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        Container.Position = Container.Position:Lerp(TargetPosition, math.clamp(dt * 18, 0, 1))
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        local CloseScale = TweenService:Create(UIScale, CLOSE_TWEEN, {Scale = 0})
        CloseScale:Play()
        CloseScale.Completed:Connect(function() Gui:Destroy() end)
    end)

    local IsMinimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        if IsMinimized then
            TweenService:Create(MainCanvas, MINIMIZE_TWEEN, {Size = UDim2.new(1, -10, 0, 0)}):Play()
            MainCanvas.Visible = false
        else
            MainCanvas.Visible = true
            TweenService:Create(MainCanvas, MINIMIZE_TWEEN, {Size = UDim2.new(1, -10, 0, 215)}):Play()
        end
    end)

    TweenService:Create(UIScale, OPEN_TWEEN, {Scale = 1}):Play()
    return WindowLib
end

return EclipseUI
