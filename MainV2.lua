--[[
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(18, 22, 18),
    Sidebar = Color3.fromRGB(15, 18, 15),
    CardBg = Color3.fromRGB(24, 28, 24),
    Border = Color3.fromRGB(45, 55, 45),
    Accent = Color3.fromRGB(132, 204, 22), -- Bright neon green
    AccentGlow = Color3.fromRGB(163, 230, 53),
    Text = Color3.fromRGB(240, 245, 240),
    SubText = Color3.fromRGB(140, 155, 140),
    Muted = Color3.fromRGB(80, 95, 80)
}

-- Utility Functions
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

local function AddStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- Make Window Draggable
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

-- Create Main Window
function Library.CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Kuurax Hub"
    local FooterText = config.Footer or "Tap Simulator Reborn | Kuurax Hub"
    local UserInfo = config.User or { Name = "Zyxer", Tag = "@South0rn" }

    -- Protect GUI against detection if possible
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KuuraxHubUI"
    ScreenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end

    -- Main Container Frame
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

    -- Top Header / Drag Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main

    MakeDraggable(Main, TopBar)

    -- Window Title (Top Left Branding)
    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Name = "BrandTitle"
    BrandTitle.Size = UDim2.new(0, 200, 1, 0)
    BrandTitle.Position = UDim2.new(0, 20, 0, 0)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.Text = Title
    BrandTitle.TextColor3 = Theme.AccentGlow
    BrandTitle.TextSize = 22
    BrandTitle.Font = Enum.Font.GothamBold
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.Parent = TopBar

    -- Top Center Active Tab Title
    local ActiveTabLabel = Instance.new("TextLabel")
    ActiveTabLabel.Name = "ActiveTabLabel"
    ActiveTabLabel.Size = UDim2.new(0, 200, 1, 0)
    ActiveTabLabel.Position = UDim2.new(0, 220, 0, 0)
    ActiveTabLabel.BackgroundTransparency = 1
    ActiveTabLabel.Text = "Farming"
    ActiveTabLabel.TextColor3 = Theme.Text
    ActiveTabLabel.TextSize = 16
    ActiveTabLabel.Font = Enum.Font.GothamMedium
    ActiveTabLabel.TextXAlignment = Enum.TextXAlignment.Left
    ActiveTabLabel.Parent = TopBar

    -- Right Action Buttons Container (Search, Color Picker, Minimize, Close)
    local WindowControls = Instance.new("Frame")
    WindowControls.Name = "Controls"
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

    -- Divider Lines
    local HeaderDivider = Instance.new("Frame")
    HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
    HeaderDivider.Position = UDim2.new(0, 0, 0, 50)
    HeaderDivider.BackgroundColor3 = Theme.Border
    HeaderDivider.BorderSizePixel = 0
    HeaderDivider.Parent = Main

    -- Sidebar (Left Container)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, -85)
    Sidebar.Position = UDim2.new(0, 0, 0, 51)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.Parent = Main

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 6)
    SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 15)
    SidebarPadding.PaddingLeft = UDim.new(0, 10)
    SidebarPadding.PaddingRight = UDim.new(0, 10)
    SidebarPadding.Parent = Sidebar

    -- Category Header Text
    local CategoryLabel = Instance.new("TextLabel")
    CategoryLabel.Size = UDim2.new(1, -10, 0, 20)
    CategoryLabel.BackgroundTransparency = 1
    CategoryLabel.Text = "Automation"
    CategoryLabel.TextColor3 = Theme.Muted
    CategoryLabel.TextSize = 12
    CategoryLabel.Font = Enum.Font.GothamBold
    CategoryLabel.TextXAlignment = Enum.TextXAlignment.Left
    CategoryLabel.LayoutOrder = 0
    CategoryLabel.Parent = Sidebar

    -- Content Frame (Right Container for Tabs)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -210, 1, -85)
    ContentContainer.Position = UDim2.new(0, 205, 0, 55)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Main

    -- User Profile Footer Card (Bottom Left)
    local UserCard = Instance.new("Frame")
    UserCard.Name = "UserCard"
    UserCard.Size = UDim2.new(0, 190, 0, 45)
    UserCard.Position = UDim2.new(0, 5, 1, -75)
    UserCard.BackgroundColor3 = Theme.CardBg
    UserCard.Parent = Main
    AddCorner(UserCard, 8)

    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 32, 0, 32)
    Avatar.Position = UDim2.new(0, 6, 0.5, -16)
    Avatar.BackgroundColor3 = Theme.Border
    Avatar.Image = "rbxassetid://6031086111" -- Placeholder avatar icon
    Avatar.Parent = UserCard
    AddCorner(Avatar, 16)

    local UserName = Instance.new("TextLabel")
    UserName.Size = UDim2.new(1, -50, 0, 16)
    UserName.Position = UDim2.new(0, 45, 0, 7)
    UserName.BackgroundTransparency = 1
    UserName.Text = UserInfo.Name or "User"
    UserName.TextColor3 = Theme.Text
    UserName.Font = Enum.Font.GothamBold
    UserName.TextSize = 13
    UserName.TextXAlignment = Enum.TextXAlignment.Left
    UserName.Parent = UserCard

    local UserTag = Instance.new("TextLabel")
    UserTag.Size = UDim2.new(1, -50, 0, 14)
    UserTag.Position = UDim2.new(0, 45, 0, 23)
    UserTag.BackgroundTransparency = 1
    UserTag.Text = UserInfo.Tag or "@Guest"
    UserTag.TextColor3 = Theme.SubText
    UserTag.Font = Enum.Font.Gotham
    UserTag.TextSize = 11
    UserTag.TextXAlignment = Enum.TextXAlignment.Left
    UserTag.Parent = UserCard

    -- Bottom Status Bar
    local StatusBar = Instance.new("Frame")
    StatusBar.Name = "StatusBar"
    StatusBar.Size = UDim2.new(1, 0, 0, 25)
    StatusBar.Position = UDim2.new(0, 0, 1, -25)
    StatusBar.BackgroundColor3 = Theme.Sidebar
    StatusBar.BorderSizePixel = 0
    StatusBar.Parent = Main

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 10, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = FooterText
    StatusText.TextColor3 = Theme.SubText
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = StatusBar

    -- Window Context Object
    local Window = {
        Tabs = {},
        ActiveTab = nil
    }

    -- TAB CREATION FUNCTION
    function Window:CreateTab(name, icon)
        local Tab = { Elements = {} }
        
        -- Sidebar Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "TabBtn"
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = Theme.CardBg
        TabButton.BackgroundTransparency = 1
        TabButton.Text = "     " .. (icon and (icon .. "  ") or "") .. name
        TabButton.TextColor3 = Theme.SubText
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        TabButton.Parent = Sidebar
        AddCorner(TabButton, 8)

        -- Active Indicator Line (Left Neon Green Bar)
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 4, 0, 20)
        Indicator.Position = UDim2.new(0, 0, 0.5, -10)
        Indicator.BackgroundColor3 = Theme.AccentGlow
        Indicator.Visible = false
        Indicator.Parent = TabButton
        AddCorner(Indicator, 2)

        -- Page Frame
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = name .. "Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Theme.Border
        TabPage.Parent = ContentContainer

        local PageGrid = Instance.new("UIGridLayout")
        PageGrid.CellSize = UDim2.new(0.48, 0, 0, 230)
        PageGrid.CellPadding = UDim2.new(0.03, 0, 0, 12)
        PageGrid.SortOrder = Enum.SortOrder.LayoutOrder
        PageGrid.Parent = TabPage

        -- Select Tab Logic
        local function Select()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Button.TextColor3 = Theme.SubText
                t.Indicator.Visible = false
            end
            TabPage.Visible = true
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Theme.CardBg
            TabButton.TextColor3 = Theme.Text
            Indicator.Visible = true
            ActiveTabLabel.Text = name
            Window.ActiveTab = Tab
        end

        TabButton.MouseButton1Click:Connect(Select)

        if #Window.Tabs == 0 then
            Select()
        end

        Tab.Page = TabPage
        Tab.Button = TabButton
        Tab.Indicator = Indicator
        table.insert(Window.Tabs, Tab)

        -- SECTION CARD CREATION FUNCTION
        function Tab:CreateSection(title, icon)
            local Section = {}
            
            local Card = Instance.new("Frame")
            Card.Name = title .. "Card"
            Card.BackgroundColor3 = Theme.CardBg
            Card.Parent = TabPage
            AddCorner(Card, 10)
            AddStroke(Card, Theme.Border, 1)

            local CardHeader = Instance.new("TextLabel")
            CardHeader.Size = UDim2.new(1, -20, 0, 35)
            CardHeader.Position = UDim2.new(0, 12, 0, 5)
            CardHeader.BackgroundTransparency = 1
            CardHeader.Text = (icon and (icon .. "  ") or "") .. title
            CardHeader.TextColor3 = Theme.Text
            CardHeader.Font = Enum.Font.GothamBold
            CardHeader.TextSize = 14
            CardHeader.TextXAlignment = Enum.TextXAlignment.Left
            CardHeader.Parent = Card

            local CardList = Instance.new("UIListLayout")
            CardList.Padding = UDim.new(0, 8)
            CardList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            CardList.SortOrder = Enum.SortOrder.LayoutOrder
            CardList.Parent = Card

            local CardPadding = Instance.new("UIPadding")
            CardPadding.PaddingTop = UDim.new(0, 40)
            CardPadding.PaddingLeft = UDim.new(0, 10)
            CardPadding.PaddingRight = UDim.new(0, 10)
            CardPadding.Parent = Card

            -- TOGGLE COMPONENT
            function Section:AddToggle(title, subtitle, default, callback)
                local Toggled = default or false
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 42)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = Card

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.7, 0, 0, 18)
                Label.BackgroundTransparency = 1
                Label.Text = title
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleFrame

                local SubLabel = Instance.new("TextLabel")
                SubLabel.Size = UDim2.new(0.7, 0, 0, 14)
                SubLabel.Position = UDim2.new(0, 0, 0, 18)
                SubLabel.BackgroundTransparency = 1
                SubLabel.Text = subtitle or ""
                SubLabel.TextColor3 = Theme.SubText
                SubLabel.Font = Enum.Font.Gotham
                SubLabel.TextSize = 10
                SubLabel.TextXAlignment = Enum.TextXAlignment.Left
                SubLabel.Parent = ToggleFrame

                local Box = Instance.new("TextButton")
                Box.Size = UDim2.new(0, 20, 0, 20)
                Box.Position = UDim2.new(1, -22, 0.5, -10)
                Box.BackgroundColor3 = Toggled and Theme.Accent or Theme.Background
                Box.Text = Toggled and "✓" or ""
                Box.TextColor3 = Theme.Background
                Box.Font = Enum.Font.GothamBold
                Box.TextSize = 12
                Box.AutoButtonColor = false
                Box.Parent = ToggleFrame
                AddCorner(Box, 5)
                AddStroke(Box, Toggled and Theme.Accent or Theme.Border, 1)

                Box.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Tween(Box, TweenInfo.new(0.15), {
                        BackgroundColor3 = Toggled and Theme.Accent or Theme.Background
                    })
                    Box.Text = Toggled and "✓" or ""
                    Box.UIStroke.Color = Toggled and Theme.Accent or Theme.Border
                    if callback then callback(Toggled) end
                end)
            end

            -- DROPDOWN COMPONENT
            function Section:AddDropdown(title, options, default, callback)
                local Selected = default or options[1] or "Select..."
                
                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 32)
                DropFrame.BackgroundTransparency = 1
                DropFrame.Parent = Card

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, 0, 1, 0)
                DropBtn.BackgroundColor3 = Theme.Background
                DropBtn.Text = "  " .. title .. ": " .. Selected
                DropBtn.TextColor3 = Theme.SubText
                DropBtn.Font = Enum.Font.Gotham
                DropBtn.TextSize = 11
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.Parent = DropFrame
                AddCorner(DropBtn, 6)
                AddStroke(DropBtn, Theme.Border, 1)

                -- Basic dropdown cycle implementation
                local currentIndex = 1
                DropBtn.MouseButton1Click:Connect(function()
                    currentIndex = (currentIndex % #options) + 1
                    Selected = options[currentIndex]
                    DropBtn.Text = "  " .. title .. ": " .. Selected
                    if callback then callback(Selected) end
                end)
            end

            -- SLIDER COMPONENT
            function Section:AddSlider(title, min, max, default, callback)
                local Value = default or min
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 30)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = Card

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(1, 0, 0, 14)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = title .. " (" .. tostring(Value) .. ")"
                ValLabel.TextColor3 = Theme.SubText
                ValLabel.Font = Enum.Font.Gotham
                ValLabel.TextSize = 10
                ValLabel.TextXAlignment = Enum.TextXAlignment.Left
                ValLabel.Parent = SliderFrame

                local Bar = Instance.new("Frame")
                Bar.Size = UDim2.new(1, 0, 0, 6)
                Bar.Position = UDim2.new(0, 0, 0, 18)
                Bar.BackgroundColor3 = Theme.Background
                Bar.Parent = SliderFrame
                AddCorner(Bar, 3)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.Parent = Bar
                AddCorner(Fill, 3)

                -- Interactive Slider logic
                local dragging = false
                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                        Value = math.floor(min + (max - min) * percent)
                        Fill.Size = UDim2.new(percent, 0, 1, 0)
                        ValLabel.Text = title .. " (" .. tostring(Value) .. ")"
                        if callback then callback(Value) end
                    end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Library
