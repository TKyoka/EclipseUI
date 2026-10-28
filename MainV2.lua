--[[
    ====================================================================
    EclipseV2 UI Library Framework
    CoreGui Parented Modern Glassmorphic UI
    ====================================================================
]]

local EclipseV2 = {}
EclipseV2.__index = EclipseV2

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Safely handle parenting to CoreGui with PlayerGui fallback
local LocalPlayer = Players.LocalPlayer
local ParentGui = nil

local success, _ = pcall(function()
    local test = Instance.new("Folder")
    test.Parent = CoreGui
    test:Destroy()
end)

if success then
    ParentGui = CoreGui
else
    ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local function Tween(obj, time, props)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

function EclipseV2.CreateWindow(config)
    local self = setmetatable({}, EclipseV2)
    self.Title = config.Title or "EclipseV2"
    self.SubTitle = config.SubTitle or "Automation Engine"
    self.Footer = config.Footer or "EclipseV2 Library"
    self.Tabs = {}
    self.ActiveTab = nil

    -- ScreenGui Instance parented directly to CoreGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EclipseV2_Root"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = ParentGui

    -- Main Window Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 620, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(16, 20, 16)
    MainFrame.BackgroundTransparency = 0.12
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 14)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(163, 230, 53)
    Stroke.Transparency = 0.78
    Stroke.Thickness = 1
    Stroke.Parent = MainFrame

    -- Top Header Bar
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 48)
    Header.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(0, 200, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 18, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = self.Title
    HeaderTitle.TextColor3 = Color3.fromRGB(226, 232, 240)
    HeaderTitle.TextSize = 13
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header

    -- Sidebar Frame
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 170, 1, -76)
    Sidebar.Position = UDim2.new(0, 0, 0, 48)
    Sidebar.BackgroundColor3 = Color3.fromRGB(13, 17, 13)
    Sidebar.BackgroundTransparency = 0.1
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 4)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar

    -- Content View Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -170, 1, -76)
    ContentArea.Position = UDim2.new(0, 170, 0, 48)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- Footer Bar
    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.Size = UDim2.new(1, 0, 0, 28)
    Footer.Position = UDim2.new(0, 0, 1, -28)
    Footer.BackgroundColor3 = Color3.fromRGB(11, 14, 11)
    Footer.BorderSizePixel = 0
    Footer.Parent = MainFrame

    local FooterLabel = Instance.new("TextLabel")
    FooterLabel.Size = UDim2.new(1, -20, 1, 0)
    FooterLabel.Position = UDim2.new(0, 12, 0, 0)
    FooterLabel.BackgroundTransparency = 1
    FooterLabel.Text = self.Footer
    FooterLabel.TextColor3 = Color3.fromRGB(148, 163, 184)
    FooterLabel.TextSize = 11
    FooterLabel.Font = Enum.Font.Gotham
    FooterLabel.TextXAlignment = Enum.TextXAlignment.Left
    FooterLabel.Parent = Footer

    -- Window Dragging Logic
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    self.ScreenGui = ScreenGui
    self.MainFrame = MainFrame
    self.Sidebar = Sidebar
    self.ContentArea = ContentArea
    return self
end

-- Tab Construction Method
function EclipseV2:CreateTab(tabName)
    local Tab = {}
    
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -12, 0, 34)
    TabButton.Position = UDim2.new(0, 6, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(163, 230, 53)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = "  " .. tabName
    TabButton.TextColor3 = Color3.fromRGB(148, 163, 184)
    TabButton.TextSize = 12
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = self.Sidebar

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(163, 230, 53)
    Page.Parent = self.ContentArea

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 12)
    PagePadding.PaddingLeft = UDim.new(0, 12)
    PagePadding.PaddingRight = UDim.new(0, 12)
    PagePadding.Parent = Page

    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            Tween(t.Button, 0.2, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(148, 163, 184)})
        end
        Page.Visible = true
        Tween(TabButton, 0.2, {BackgroundTransparency = 0.85, TextColor3 = Color3.fromRGB(163, 230, 53)})
    end)

    if #self.Tabs == 0 then
        Page.Visible = true
        TabButton.BackgroundTransparency = 0.85
        TabButton.TextColor3 = Color3.fromRGB(163, 230, 53)
    end

    Tab.Page = Page
    Tab.Button = TabButton
    table.insert(self.Tabs, Tab)

    -- Add Section Card Component
    function Tab:CreateSection(sectionTitle)
        local Section = {}

        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 40)
        Card.AutomaticSize = Enum.AutomaticSize.Y
        Card.BackgroundColor3 = Color3.fromRGB(23, 28, 23)
        Card.BackgroundTransparency = 0.35
        Card.Parent = Page

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 10)
        CardCorner.Parent = Card

        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Color3.fromRGB(255, 255, 255)
        CardStroke.Transparency = 0.92
        CardStroke.Parent = Card

        local CardLayout = Instance.new("UIListLayout")
        CardLayout.Padding = UDim.new(0, 8)
        CardLayout.Parent = Card

        local CardPadding = Instance.new("UIPadding")
        CardPadding.PaddingTop = UDim.new(0, 10)
        CardPadding.PaddingBottom = UDim.new(0, 10)
        CardPadding.PaddingLeft = UDim.new(0, 12)
        CardPadding.PaddingRight = UDim.new(0, 12)
        CardPadding.Parent = Card

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, 0, 0, 18)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = sectionTitle
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 12
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = Card

        -- Add Toggle Component
        function Section:AddToggle(toggleName, default, callback)
            local enabled = default or false
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 26)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = Card

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = toggleName
            ToggleLabel.TextColor3 = Color3.fromRGB(226, 232, 240)
            ToggleLabel.TextSize = 12
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(0, 20, 0, 20)
            ToggleBtn.Position = UDim2.new(1, -20, 0.5, -10)
            ToggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(163, 230, 53) or Color3.fromRGB(0, 0, 0)
            ToggleBtn.BackgroundTransparency = enabled and 0 or 0.6
            ToggleBtn.Text = enabled and "✓" or ""
            ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            ToggleBtn.Font = Enum.Font.GothamBold
            ToggleBtn.TextSize = 12
            ToggleBtn.Parent = ToggleFrame

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 5)
            ToggleCorner.Parent = ToggleBtn

            ToggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                ToggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(163, 230, 53) or Color3.fromRGB(0, 0, 0)
                ToggleBtn.BackgroundTransparency = enabled and 0 or 0.6
                ToggleBtn.Text = enabled and "✓" or ""
                pcall(callback, enabled)
            end)
        end

        return Section
    end

    return Tab
end

return EclipseV2
