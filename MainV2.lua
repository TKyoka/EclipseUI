--[[
    Eclipse UI Library - Core Main Frame
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

local Theme = {
    Background = Color3.fromRGB(16, 16, 22),
    CardBg = Color3.fromRGB(22, 22, 30),
    Border = Color3.fromRGB(40, 40, 60),
    AccentGlow = Color3.fromRGB(140, 110, 255),
    SubText = Color3.fromRGB(140, 140, 165),
    Text = Color3.fromRGB(240, 240, 250)
}

local function Tween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function MakeDraggable(gui, handle)
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(gui, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

function Library.CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Eclipse Hub"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EclipseUI"
    ScreenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 720, 0, 480)
    Main.Position = UDim2.new(0.5, -360, 0.5, -240)
    Main.BackgroundColor3 = Theme.Background
    Main.BackgroundTransparency = 0.05
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    AddCorner(Main, 12)
    AddStroke(Main, Theme.Border, 1.5)

    -- Top Header Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main

    MakeDraggable(Main, TopBar)

    -- Branding Title
    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Size = UDim2.new(0, 200, 1, 0)
    BrandTitle.Position = UDim2.new(0, 20, 0, 0)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.Text = Title
    BrandTitle.TextColor3 = Theme.AccentGlow
    BrandTitle.TextSize = 22
    BrandTitle.Font = Enum.Font.GothamBold
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.Parent = TopBar

    -- Controls Container
    local WindowControls = Instance.new("Frame")
    WindowControls.Size = UDim2.new(0, 150, 1, 0)
    WindowControls.Position = UDim2.new(1, -160, 0, 0)
    WindowControls.BackgroundTransparency = 1
    WindowControls.Parent = TopBar

    local ControlLayout = Instance.new("UIListLayout")
    ControlLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlLayout.Padding = UDim.new(0, 8)
    ControlLayout.Parent = WindowControls

    local function CreateIconButton(iconText, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.BackgroundColor3 = Theme.CardBg
        btn.Text = iconText
        btn.TextColor3 = Theme.SubText
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = false
        btn.Parent = WindowControls
        AddCorner(btn, 8)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Border, TextColor3 = Theme.Text})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.CardBg, TextColor3 = Theme.SubText})
        end)
        if callback then
            btn.MouseButton1Click:Connect(callback)
        end
        return btn
    end

    CreateIconButton("🔍")
    CreateIconButton("🎨")
    
    local isMinimized = false
    CreateIconButton("—", function()
        isMinimized = not isMinimized
        Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = isMinimized and UDim2.new(0, 720, 0, 50) or UDim2.new(0, 720, 0, 480)
        })
    end)

    CreateIconButton("✕", function()
        ScreenGui:Destroy()
    end)

    -- Divider
    local HeaderDivider = Instance.new("Frame")
    HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
    HeaderDivider.Position = UDim2.new(0, 0, 0, 50)
    HeaderDivider.BackgroundColor3 = Theme.Border
    HeaderDivider.BorderSizePixel = 0
    HeaderDivider.Parent = Main

    return Main
end

return Library
