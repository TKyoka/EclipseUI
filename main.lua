local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local EclipseUI = {
    Themes = {
        Dark = {
            Background = Color3.fromRGB(15, 17, 26),
            Sidebar = Color3.fromRGB(20, 22, 34),
            Card = Color3.fromRGB(26, 29, 45),
            Accent = Color3.fromRGB(98, 102, 241),
            Text = Color3.fromRGB(240, 242, 254),
            SubText = Color3.fromRGB(130, 135, 160),
            Border = Color3.fromRGB(38, 42, 65),
            StatusBox = Color3.fromRGB(18, 20, 30)
        }
    }
}

-- Utility function for smooth component animations
function EclipseUI:Tween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function EclipseUI:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Name or "EclipseUI Hub"
    local versionText = options.Version or "v1.0.0"

    -- Core Gui setup (Parented to LocalPlayer.PlayerGui for in-game development)
    local targetParent = LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EclipseUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = targetParent

    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
    MainFrame.BackgroundColor3 = EclipseUI.Themes.Dark.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = EclipseUI.Themes.Dark.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    --------------------------------------------------------------------
    -- 1. Top Header Bar
    --------------------------------------------------------------------
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = windowTitle
    TitleLabel.TextColor3 = EclipseUI.Themes.Dark.Text
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    --------------------------------------------------------------------
    -- 2. Left Sidebar Navigation
    --------------------------------------------------------------------
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = EclipseUI.Themes.Dark.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -20, 1, -70)
    TabContainer.Position = UDim2.new(0, 10, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer

    --------------------------------------------------------------------
    -- 3. Content Viewport (Right Side)
    --------------------------------------------------------------------
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -210, 1, -55)
    ContentArea.Position = UDim2.new(0, 205, 0, 50)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- Window interface methods
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    return Window
end

return EclipseUI
