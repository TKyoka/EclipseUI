--[[
    EclipseUI Library v1.2
    Modern UI Framework for Roblox
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local EclipseUI = {}
EclipseUI.__index = EclipseUI

-- Theme Configuration
EclipseUI.Theme = {
    Background = Color3.fromRGB(18, 19, 26),
    Sidebar = Color3.fromRGB(24, 25, 35),
    Card = Color3.fromRGB(30, 32, 45),
    CardHover = Color3.fromRGB(38, 40, 58),
    Accent = Color3.fromRGB(99, 102, 241),
    Text = Color3.fromRGB(240, 242, 254),
    Muted = Color3.fromRGB(150, 155, 180),
    Border = Color3.fromRGB(45, 48, 70)
}

local function Tween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function EclipseUI.new(title)
    local self = setmetatable({}, EclipseUI)

    -- Base ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EclipseUI"
    ScreenGui.ResetOnSpawn = false

    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 620, 0, 420)
    Main.Position = UDim2.new(0.5, -310, 0.5, -210)
    Main.BackgroundColor3 = EclipseUI.Theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = EclipseUI.Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    -- Header Title
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundTransparency = 1
    Header.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Text = title or "EclipseUI"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 18, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = EclipseUI.Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Header

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 1, -1)
    Divider.BackgroundColor3 = EclipseUI.Theme.Border
    Divider.BorderSizePixel = 0
    Divider.Parent = Header

    -- Sidebar Area
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = EclipseUI.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -16, 1, -20)
    TabContainer.Position = UDim2.new(0, 8, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = EclipseUI.Theme.Border
    TabContainer.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 6)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer

    -- Content Area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -170, 1, -55)
    Content.Position = UDim2.new(0, 165, 0, 50)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    self.ScreenGui = ScreenGui
    self.Main = Main
    self.Content = Content
    self.TabContainer = TabContainer
    self.Tabs = {}
    self.ActiveTab = nil

    -- Make Window Draggable
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    return self
end

function EclipseUI:CreateTab(name)
    local tab = {}
    
    -- Tab Button
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundColor3 = EclipseUI.Theme.Card
    Button.BackgroundTransparency = 1
    Button.Text = name
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 13
    Button.TextColor3 = EclipseUI.Theme.Muted
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = self.TabContainer

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.Parent = Button

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    -- Tab Page Content Frame
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -10, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = EclipseUI.Theme.Border
    Page.Parent = self.Content

    local PageList = Instance.new("UIListLayout")
    PageList.Padding = UDim.new(0, 8)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Parent = Page

    local function Activate()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            Tween(t.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 1,
                TextColor3 = EclipseUI.Theme.Muted
            })
        end
        Page.Visible = true
        Tween(Button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            TextColor3 = EclipseUI.Theme.Text
        })
        self.ActiveTab = tab
    end

    Button.MouseButton1Click:Connect(Activate)

    if #self.Tabs == 0 then
        Activate()
    end

    tab.Page = Page
    tab.Button = Button
    table.insert(self.Tabs, tab)

    -- SECTION ELEMENT
    function tab:AddSection(text)
        local Label = Instance.new("TextLabel")
        Label.Text = string.upper(text)
        Label.Size = UDim2.new(1, 0, 0, 24)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 11
        Label.TextColor3 = EclipseUI.Theme.Accent
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.Parent = Page
    end

    -- BUTTON ELEMENT
    function tab:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 38)
        Btn.BackgroundColor3 = EclipseUI.Theme.Card
        Btn.Text = text
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 13
        Btn.TextColor3 = EclipseUI.Theme.Text
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.Parent = Page

        local BtnPadding = Instance.new("UIPadding")
        BtnPadding.PaddingLeft = UDim.new(0, 12)
        BtnPadding.Parent = Btn

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Btn

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = EclipseUI.Theme.Border
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        Btn.MouseEnter:Connect(function()
            Tween(Btn, TweenInfo.new(0.15), {BackgroundColor3 = EclipseUI.Theme.CardHover})
        end)
        Btn.MouseLeave:Connect(function()
            Tween(Btn, TweenInfo.new(0.15), {BackgroundColor3 = EclipseUI.Theme.Card})
        end)
        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    -- TOGGLE ELEMENT
    function tab:AddToggle(text, default, callback)
        local state = default or false

        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 40)
        Container.BackgroundColor3 = EclipseUI.Theme.Card
        Container.Parent = Page

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Container

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = EclipseUI.Theme.Border
        Stroke.Thickness = 1
        Stroke.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Text = text
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextColor3 = EclipseUI.Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.Parent = Container

        local SwitchTrack = Instance.new("Frame")
        SwitchTrack.Size = UDim2.new(0, 36, 0, 20)
        SwitchTrack.Position = UDim2.new(1, -48, 0.5, -10)
        SwitchTrack.BackgroundColor3 = state and EclipseUI.Theme.Accent or Color3.fromRGB(45, 48, 65)
        SwitchTrack.Parent = Container

        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = SwitchTrack

        local SwitchKnob = Instance.new("Frame")
        SwitchKnob.Size = UDim2.new(0, 14, 0, 14)
        SwitchKnob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchKnob.Parent = SwitchTrack

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = SwitchKnob

        local Clicker = Instance.new("TextButton")
        Clicker.Size = UDim2.new(1, 0, 1, 0)
        Clicker.BackgroundTransparency = 1
        Clicker.Text = ""
        Clicker.Parent = Container

        Clicker.MouseButton1Click:Connect(function()
            state = not state
            Tween(SwitchTrack, TweenInfo.new(0.2), {
                BackgroundColor3 = state and EclipseUI.Theme.Accent or Color3.fromRGB(45, 48, 65)
            })
            Tween(SwitchKnob, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            })
            if callback then callback(state) end
        end)
    end

    -- SLIDER ELEMENT
    function tab:AddSlider(text, min, max, default, callback)
        local value = math.clamp(default or min, min, max)

        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 50)
        Container.BackgroundColor3 = EclipseUI.Theme.Card
        Container.Parent = Page

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Container

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = EclipseUI.Theme.Border
        Stroke.Thickness = 1
        Stroke.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Text = text
        Label.Size = UDim2.new(0.6, 0, 0, 22)
        Label.Position = UDim2.new(0, 12, 0, 6)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextColor3 = EclipseUI.Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.Parent = Container

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Text = tostring(value)
        ValueLabel.Size = UDim2.new(0.3, 0, 0, 22)
        ValueLabel.Position = UDim2.new(0.7, -12, 0, 6)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 12
        ValueLabel.TextColor3 = EclipseUI.Theme.Accent
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Parent = Container

        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -24, 0, 6)
        Track.Position = UDim2.new(0, 12, 1, -14)
        Track.BackgroundColor3 = Color3.fromRGB(45, 48, 65)
        Track.Parent = Container

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = EclipseUI.Theme.Accent
        Fill.Parent = Track

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

        local isDragging = false
        local function UpdateSlider(input)
            local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * pos)
            ValueLabel.Text = tostring(value)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            if callback then callback(value) end
        end

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                UpdateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider(input)
            end
        end)
    end

    -- PARAGRAPH ELEMENT
    function tab:AddParagraph(titleText, bodyText)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 60)
        Container.BackgroundColor3 = EclipseUI.Theme.Card
        Container.Parent = Page

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Container

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = EclipseUI.Theme.Border
        Stroke.Thickness = 1
        Stroke.Parent = Container

        local PTitle = Instance.new("TextLabel")
        PTitle.Text = titleText
        PTitle.Size = UDim2.new(1, -24, 0, 20)
        PTitle.Position = UDim2.new(0, 12, 0, 8)
        PTitle.Font = Enum.Font.GothamBold
        PTitle.TextSize = 13
        PTitle.TextColor3 = EclipseUI.Theme.Text
        PTitle.TextXAlignment = Enum.TextXAlignment.Left
        PTitle.BackgroundTransparency = 1
        PTitle.Parent = Container

        local PBody = Instance.new("TextLabel")
        PBody.Text = bodyText
        PBody.Size = UDim2.new(1, -24, 0, 26)
        PBody.Position = UDim2.new(0, 12, 0, 28)
        PBody.Font = Enum.Font.Gotham
        PBody.TextSize = 12
        PBody.TextColor3 = EclipseUI.Theme.Muted
        PBody.TextXAlignment = Enum.TextXAlignment.Left
        PBody.TextWrapped = true
        PBody.BackgroundTransparency = 1
        PBody.Parent = Container
    end

    return tab
end

return EclipseUI
