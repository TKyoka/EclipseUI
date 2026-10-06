-- EclipseUI Main Library Entry Point (Updated Visual Styling)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

local EclipseUI = {
    Themes = {
        Dark = {
            Background = Color3.fromRGB(18, 18, 22),
            Sidebar = Color3.fromRGB(24, 24, 30),
            Card = Color3.fromRGB(28, 28, 35),
            Accent = Color3.fromRGB(98, 102, 241),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(150, 150, 165),
            Border = Color3.fromRGB(255, 255, 255),
            CloseHover = Color3.fromRGB(235, 65, 80)
        }
    }
}

local function ApplyGlow(targetFrame, cornerRadius, transparency)
    local GlowStroke = Instance.new("UIStroke")
    GlowStroke.Name = "GlowStroke"
    GlowStroke.Color = Color3.fromRGB(255, 255, 255)
    GlowStroke.Transparency = transparency or 0.85
    GlowStroke.Thickness = 1.5
    GlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    GlowStroke.Parent = targetFrame

    if not targetFrame:FindFirstChildOfClass("UICorner") then
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, cornerRadius or 8)
        Corner.Parent = targetFrame
    end
    return GlowStroke
end

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

    -- Main Container Frame
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Size = UDim2.new(0, 700, 0, 480)
    MainContainer.Position = UDim2.new(0.5, -350, 0.5, -240)
    MainContainer.BackgroundTransparency = 1
    MainContainer.Parent = ScreenGui

    -- Header Control Bar (Pills Section)
    local HeaderPills = Instance.new("Frame")
    HeaderPills.Name = "HeaderPills"
    HeaderPills.Size = UDim2.new(1, 0, 0, 32)
    HeaderPills.BackgroundTransparency = 1
    HeaderPills.Parent = MainContainer

    -- Title Pill
    local TitlePill = Instance.new("Frame")
    TitlePill.Name = "TitlePill"
    TitlePill.Size = UDim2.new(0, 130, 1, 0)
    TitlePill.Position = UDim2.new(0, 0, 0, 0)
    TitlePill.BackgroundColor3 = selectedTheme.Background
    TitlePill.BackgroundTransparency = 0.15
    TitlePill.Parent = HeaderPills
    ApplyGlow(TitlePill, 8, 0.85)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.fromScale(1, 1)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = windowTitle
    TitleLabel.TextColor3 = selectedTheme.Text
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Parent = TitlePill

    -- FPS Counter Pill
    local FPSPill = Instance.new("Frame")
    FPSPill.Name = "FPSPill"
    FPSPill.Size = UDim2.new(0, 70, 1, 0)
    FPSPill.Position = UDim2.new(0, 138, 0, 0)
    FPSPill.BackgroundColor3 = selectedTheme.Background
    FPSPill.BackgroundTransparency = 0.15
    FPSPill.Parent = HeaderPills
    ApplyGlow(FPSPill, 8, 0.85)

    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.fromScale(1, 1)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Text = "-- FPS"
    FPSLabel.TextColor3 = Color3.fromHex("#00ff88")
    FPSLabel.TextSize = 12
    FPSLabel.Font = Enum.Font.GothamBold
    FPSLabel.Parent = FPSPill

    -- Ping Counter Pill
    local PingPill = Instance.new("Frame")
    PingPill.Name = "PingPill"
    PingPill.Size = UDim2.new(0, 85, 1, 0)
    PingPill.Position = UDim2.new(0, 216, 0, 0)
    PingPill.BackgroundColor3 = selectedTheme.Background
    PingPill.BackgroundTransparency = 0.15
    PingPill.Parent = HeaderPills
    ApplyGlow(PingPill, 8, 0.85)

    local PingLabel = Instance.new("TextLabel")
    PingLabel.Size = UDim2.fromScale(1, 1)
    PingLabel.BackgroundTransparency = 1
    PingLabel.Text = "PING: --"
    PingLabel.TextColor3 = Color3.fromHex("#00ff88")
    PingLabel.TextSize = 12
    PingLabel.Font = Enum.Font.GothamBold
    PingLabel.Parent = PingPill

    -- Close Button Pill
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseButton"
    CloseBtn.Size = UDim2.new(0, 32, 1, 0)
    CloseBtn.Position = UDim2.new(1, -32, 0, 0)
    CloseBtn.BackgroundColor3 = selectedTheme.Background
    CloseBtn.BackgroundTransparency = 0.15
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = selectedTheme.SubText
    CloseBtn.TextSize = 13
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = HeaderPills
    ApplyGlow(CloseBtn, 8, 0.85)

    -- Live Performance Tracker Setup
    local frameCount = 0
    local lastCheck = os.clock()

    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastCheck >= 1 then
            FPSLabel.Text = math.floor(frameCount / (now - lastCheck)) .. " FPS"
            frameCount = 0
            lastCheck = now
            
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            PingLabel.Text = "PING: " .. ping
        end
    end)

    -- Main Content Canvas
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, 0, 1, -40)
    MainFrame.Position = UDim2.new(0, 0, 0, 40)
    MainFrame.BackgroundColor3 = selectedTheme.Background
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = MainContainer

    ApplyGlow(MainFrame, 10, 0.85)

    -- Left Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = selectedTheme.Sidebar
    Sidebar.BackgroundTransparency = 0.2
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
    ContentArea.Size = UDim2.new(1, -210, 1, -20)
    ContentArea.Position = UDim2.new(0, 205, 0, 10)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local Window = {
        Tabs = {},
        CurrentTab = nil,
        ScreenGui = ScreenGui
    }

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    CloseBtn.MouseEnter:Connect(function()
        EclipseUI:Tween(CloseBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = selectedTheme.CloseHover,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
    end)

    CloseBtn.MouseLeave:Connect(function()
        EclipseUI:Tween(CloseBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = selectedTheme.Background,
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
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = selectedTheme.Card
        TabBtn.BackgroundTransparency = 0.3
        TabBtn.Text = "  " .. tabName
        TabBtn.TextColor3 = selectedTheme.SubText
        TabBtn.TextSize = 13
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabNavContainer

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
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
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = TabPage

        local TabObject = { Page = TabPage, NavButton = TabBtn }

        local function SelectTab()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                EclipseUI:Tween(t.NavButton, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.3,
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
            SectionLayout.Padding = UDim.new(0, 6)
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Parent = SectionGroup

            local HeaderLabel = Instance.new("TextLabel")
            HeaderLabel.Name = "HeaderLabel"
            HeaderLabel.Size = UDim2.new(1, 0, 0, 18)
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.Text = string.upper(secName)
            HeaderLabel.TextColor3 = selectedTheme.SubText
            HeaderLabel.TextSize = 11
            HeaderLabel.Font = Enum.Font.GothamBold
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLabel.Parent = SectionGroup

            local SectionObject = {}

            local function CreateCardContainer(title, description)
                local Card = Instance.new("Frame")
                Card.Name = title .. "_Card"
                Card.Size = UDim2.new(1, 0, 0, 48)
                Card.BackgroundColor3 = selectedTheme.Card
                Card.BackgroundTransparency = 0.15
                Card.BorderSizePixel = 0
                Card.Parent = SectionGroup

                ApplyGlow(Card, 6, 0.92)

                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Name = "Title"
                TitleLabel.Size = UDim2.new(0.6, 0, 0, 18)
                TitleLabel.Position = UDim2.new(0, 12, 0, description and 6 or 15)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Text = title
                TitleLabel.TextColor3 = selectedTheme.Text
                TitleLabel.TextSize = 13
                TitleLabel.Font = Enum.Font.GothamMedium
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.Parent = Card

                if description then
                    local DescLabel = Instance.new("TextLabel")
                    DescLabel.Name = "Description"
                    DescLabel.Size = UDim2.new(0.6, 0, 0, 14)
                    DescLabel.Position = UDim2.new(0, 12, 0, 26)
                    DescLabel.BackgroundTransparency = 1
                    DescLabel.Text = description
                    DescLabel.TextColor3 = selectedTheme.SubText
                    DescLabel.TextSize = 10
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
                        BackgroundColor3 = Color3.fromRGB(38, 38, 48)
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
                        BackgroundColor3 = Color3.fromRGB(38, 38, 48)
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
                Track.Size = UDim2.new(0, 40, 0, 20)
                Track.Position = UDim2.new(1, -50, 0.5, -10)
                Track.BackgroundColor3 = state and selectedTheme.Accent or Color3.fromRGB(40, 44, 62)
                Track.Text = ""
                Track.AutoButtonColor = false
                Track.Parent = Card

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = Track

                local Knob = Instance.new("Frame")
                Knob.Name = "Knob"
                Knob.Size = UDim2.new(0, 14, 0, 14)
                Knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Parent = Track

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local function UpdateToggle()
                    local targetColor = state and selectedTheme.Accent or Color3.fromRGB(40, 44, 62)
                    local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)

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
