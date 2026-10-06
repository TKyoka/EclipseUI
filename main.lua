-- EclipseUI Main Library Entry Point (Performance Optimized)

local TweenService = game:GetService("TweenService")
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
            CloseHover = Color3.fromRGB(235, 65, 80)
        }
    }
}

function EclipseUI:Tween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function EclipseUI:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Name or "EclipseUI"
    local selectedTheme = EclipseUI.Themes.Dark

    local targetParent = LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EclipseUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = targetParent

    -- Main Frame Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
    MainFrame.BackgroundColor3 = selectedTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = selectedTheme.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Header Bar
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
    TitleLabel.TextColor3 = selectedTheme.Text
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- Close / Destroy UI Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseButton"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
    CloseBtn.BackgroundColor3 = selectedTheme.Card
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = selectedTheme.SubText
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TopBar

    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 6)
    CloseBtnCorner.Parent = CloseBtn

    -- Left Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = selectedTheme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local TabNavContainer = Instance.new("ScrollingFrame")
    TabNavContainer.Name = "TabNavContainer"
    TabNavContainer.Size = UDim2.new(1, -20, 1, -20)
    TabNavContainer.Position = UDim2.new(0, 10, 0, 10)
    TabNavContainer.BackgroundTransparency = 1
    TabNavContainer.ScrollBarThickness = 0
    TabNavContainer.Parent = Sidebar

    local TabNavLayout = Instance.new("UIListLayout")
    TabNavLayout.Padding = UDim.new(0, 6)
    TabNavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabNavLayout.Parent = TabNavContainer

    -- Content Area Container
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -220, 1, -55)
    ContentArea.Position = UDim2.new(0, 210, 0, 50)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local Window = {
        Tabs = {},
        CurrentTab = nil,
        ScreenGui = ScreenGui
    }

    -- Destroy Functionality
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    CloseBtn.MouseEnter:Connect(function()
        EclipseUI:Tween(CloseBtn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0,
            BackgroundColor3 = selectedTheme.CloseHover,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
    end)

    CloseBtn.MouseLeave:Connect(function()
        EclipseUI:Tween(CloseBtn, TweenInfo.new(0.15), {
            BackgroundTransparency = 1,
            BackgroundColor3 = selectedTheme.Card,
            TextColor3 = selectedTheme.SubText
        })
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)

    function Window:Tab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "_Btn"
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundColor3 = selectedTheme.Card
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "  " .. tabName
        TabBtn.TextColor3 = selectedTheme.SubText
        TabBtn.TextSize = 14
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabNavContainer

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = tabName .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 2
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarImageColor3 = selectedTheme.Border
        TabPage.Parent = ContentArea

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 12)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = TabPage

        local TabObject = { Page = TabPage, NavButton = TabBtn }

        local function SelectTab()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                EclipseUI:Tween(t.NavButton, TweenInfo.new(0.15), {
                    BackgroundTransparency = 1,
                    TextColor3 = selectedTheme.SubText
                })
            end
            TabPage.Visible = true
            EclipseUI:Tween(TabBtn, TweenInfo.new(0.15), {
                BackgroundTransparency = 0,
                BackgroundColor3 = selectedTheme.Accent,
                TextColor3 = selectedTheme.Text
            })
            Window.CurrentTab = TabObject
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)
        table.insert(Window.Tabs, TabObject)

        if #Window.Tabs == 1 then
            SelectTab()
        end

        function TabObject:Section(secOptions)
            secOptions = secOptions or {}
            local secName = secOptions.Name or "Section"

            local SectionGroup = Instance.new("Frame")
            SectionGroup.Name = secName .. "_Section"
            SectionGroup.Size = UDim2.new(1, -10, 0, 0)
            SectionGroup.AutomaticSize = Enum.AutomaticSize.Y
            SectionGroup.BackgroundTransparency = 1
            SectionGroup.Parent = TabPage

            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.Padding = UDim.new(0, 8)
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Parent = SectionGroup

            local HeaderLabel = Instance.new("TextLabel")
            HeaderLabel.Name = "HeaderLabel"
            HeaderLabel.Size = UDim2.new(1, 0, 0, 20)
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.Text = string.upper(secName)
            HeaderLabel.TextColor3 = selectedTheme.SubText
            HeaderLabel.TextSize = 12
            HeaderLabel.Font = Enum.Font.GothamBold
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLabel.Parent = SectionGroup

            local SectionObject = {}

            local function CreateCardContainer(title, description)
                local Card = Instance.new("Frame")
                Card.Name = title .. "_Card"
                Card.Size = UDim2.new(1, 0, 0, 52)
                Card.BackgroundColor3 = selectedTheme.Card
                Card.BorderSizePixel = 0
                Card.Parent = SectionGroup

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = Card

                local Stroke = Instance.new("UIStroke")
                Stroke.Color = selectedTheme.Border
                Stroke.Thickness = 1
                Stroke.Parent = Card

                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Name = "Title"
                TitleLabel.Size = UDim2.new(0.6, 0, 0, 20)
                TitleLabel.Position = UDim2.new(0, 12, 0, description and 8 or 16)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Text = title
                TitleLabel.TextColor3 = selectedTheme.Text
                TitleLabel.TextSize = 14
                TitleLabel.Font = Enum.Font.GothamMedium
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.Parent = Card

                if description then
                    local DescLabel = Instance.new("TextLabel")
                    DescLabel.Name = "Description"
                    DescLabel.Size = UDim2.new(0.6, 0, 0, 16)
                    DescLabel.Position = UDim2.new(0, 12, 0, 28)
                    DescLabel.BackgroundTransparency = 1
                    DescLabel.Text = description
                    DescLabel.TextColor3 = selectedTheme.SubText
                    DescLabel.TextSize = 11
                    DescLabel.Font = Enum.Font.Gotham
                    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                    DescLabel.Parent = Card
                end

                return Card
            end

            function SectionObject:Button(btnOptions)
                btnOptions = btnOptions or {}
                local name = btnOptions.Name or "Button"
                local desc = btnOptions.Description
                local callback = btnOptions.Callback or function() end

                local Card = CreateCardContainer(name, desc)

                local ClickArea = Instance.new("TextButton")
                ClickArea.Name = "ClickArea"
                ClickArea.Size = UDim2.new(1, 0, 1, 0)
                ClickArea.BackgroundTransparency = 1
                ClickArea.Text = ""
                ClickArea.Parent = Card

                ClickArea.MouseEnter:Connect(function()
                    EclipseUI:Tween(Card, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(34, 38, 58)
                    })
                end)

                ClickArea.MouseLeave:Connect(function()
                    EclipseUI:Tween(Card, TweenInfo.new(0.1), {
                        BackgroundColor3 = selectedTheme.Card
                    })
                end)

                ClickArea.MouseButton1Click:Connect(function()
                    EclipseUI:Tween(Card, TweenInfo.new(0.05), {
                        BackgroundColor3 = selectedTheme.Accent
                    })
                    task.wait(0.05)
                    EclipseUI:Tween(Card, TweenInfo.new(0.05), {
                        BackgroundColor3 = Color3.fromRGB(34, 38, 58)
                    })

                    task.spawn(callback)
                end)

                return Card
            end

            function SectionObject:Toggle(toggleOptions)
                toggleOptions = toggleOptions or {}
                local name = toggleOptions.Name or "Toggle"
                local desc = toggleOptions.Description
                local state = toggleOptions.Default or false
                local callback = toggleOptions.Callback or function() end

                local Card = CreateCardContainer(name, desc)

                local Track = Instance.new("TextButton")
                Track.Name = "ToggleTrack"
                Track.Size = UDim2.new(0, 44, 0, 24)
                Track.Position = UDim2.new(1, -56, 0.5, -12)
                Track.BackgroundColor3 = state and selectedTheme.Accent or Color3.fromRGB(40, 44, 62)
                Track.Text = ""
                Track.AutoButtonColor = false
                Track.Parent = Card

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = Track

                local Knob = Instance.new("Frame")
                Knob.Name = "Knob"
                Knob.Size = UDim2.new(0, 18, 0, 18)
                Knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Parent = Track

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local function UpdateToggle()
                    local targetColor = state and selectedTheme.Accent or Color3.fromRGB(40, 44, 62)
                    local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)

                    EclipseUI:Tween(Track, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = targetColor
                    })
                    EclipseUI:Tween(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = targetPos
                    })

                    task.spawn(callback, state)
                end

                Track.MouseButton1Click:Connect(function()
                    state = not state
                    UpdateToggle()
                end)

                return Track
            end

            return SectionObject
        end

        return TabObject
    end

    return Window
end

return EclipseUI
