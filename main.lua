--[[
    ========================================================================
    EclipseUI Library Framework for Roblox (Luau)
    Author: Kyoka @ Zyxer | zkyoka, zyx.r
    Version: 1.0.0
    ========================================================================
--]]

local EclipseUI = {}
EclipseUI.__index = EclipseUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Theme Definitions
local Themes = {
    ["Eclipse Indigo"] = { Accent = Color3.fromRGB(99, 102, 241), Background = Color3.fromRGB(15, 17, 25), Container = Color3.fromRGB(22, 26, 38) },
    ["Cyber Cyan"]    = { Accent = Color3.fromRGB(6, 182, 212),  Background = Color3.fromRGB(10, 18, 26), Container = Color3.fromRGB(16, 28, 40) },
    ["Sakura Pink"]   = { Accent = Color3.fromRGB(236, 72, 153), Background = Color3.fromRGB(24, 15, 22), Container = Color3.fromRGB(36, 22, 32) },
    ["Emerald Green"] = { Accent = Color3.fromRGB(16, 185, 129), Background = Color3.fromRGB(12, 22, 18), Container = Color3.fromRGB(18, 34, 28) }
}

-- Safe Parent Resolver (Protects against detection)
local function GetParentGui()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local sg = Instance.new("ScreenGui")
        syn.protect_gui(sg)
        sg.Parent = CoreGui
        return sg
    else
        return CoreGui
    end
end

-- Global Toast Notification Function
function EclipseUI:Notify(Options)
    Options = Options or {}
    local Title = Options.Title or "EclipseUI"
    local Content = Options.Content or "Notification Message"
    local Duration = Options.Duration or 3

    local ScreenGui = GetParentGui():FindFirstChild("EclipseUI_ScreenGui")
    if not ScreenGui then return end

    local ToastHolder = ScreenGui:FindFirstChild("ToastHolder")
    if not ToastHolder then
        ToastHolder = Instance.new("Frame")
        ToastHolder.Name = "ToastHolder"
        ToastHolder.Size = UDim2.new(0, 240, 1, -20)
        ToastHolder.Position = UDim2.new(1, -250, 0, 10)
        ToastHolder.BackgroundTransparency = 1
        ToastHolder.Parent = ScreenGui

        local UIList = Instance.new("UIListLayout")
        UIList.VerticalAlignment = Enum.VerticalAlignment.Bottom
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Padding = UDim.new(0, 8)
        UIList.Parent = ToastHolder
    end

    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 0, 0, 50)
    Toast.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    Toast.BorderSizePixel = 0
    Toast.Parent = ToastHolder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Toast

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(99, 102, 241)
    Stroke.Thickness = 1
    Stroke.Parent = Toast

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Text = Title
    TitleLbl.Font = Enum.Font.SourceSansBold
    TitleLbl.TextSize = 14
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.Position = UDim2.new(0, 10, 0, 6)
    TitleLbl.Size = UDim2.new(1, -20, 0, 16)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Toast

    local ContentLbl = Instance.new("TextLabel")
    ContentLbl.Text = Content
    ContentLbl.Font = Enum.Font.SourceSans
    ContentLbl.TextSize = 12
    ContentLbl.TextColor3 = Color3.fromRGB(180, 185, 200)
    ContentLbl.Position = UDim2.new(0, 10, 0, 24)
    ContentLbl.Size = UDim2.new(1, -20, 0, 20)
    ContentLbl.BackgroundTransparency = 1
    ContentLbl.TextXAlignment = Enum.TextXAlignment.Left
    ContentLbl.Parent = Toast

    task.spawn(function()
        task.wait(Duration)
        TweenService:Create(Toast, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(TitleLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(ContentLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        task.wait(0.4)
        Toast:Destroy()
    end)
end

-- Create Window
function EclipseUI:CreateWindow(Config)
    Config = Config or {}
    local Title = Config.Title or "EclipseUI Window"
    local Subtitle = Config.Subtitle or "v2.4"
    local Size = Config.Size or UDim2.new(0, 550, 0, 380)
    local ThemeName = Config.Theme or "Eclipse Indigo"
    local ActiveTheme = Themes[ThemeName] or Themes["Eclipse Indigo"]
    local ToggleKey = Config.ToggleKey or Enum.KeyCode.RightShift

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EclipseUI_ScreenGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = GetParentGui()

    -- Main Container Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Size
    MainFrame.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    MainFrame.BackgroundColor3 = ActiveTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(45, 52, 70)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Dragging Logic
    local Dragging, DragInput, DragStart, StartPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    -- Toggle Window Visibility with Keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Sidebar & Tab Container Setup
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -150, 1, 0)
    TabContainer.Position = UDim2.new(0, 150, 0, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 4)
    TabList.Parent = Sidebar

    local WindowObj = { Gui = ScreenGui, Main = MainFrame, ActiveTab = nil }

    -- AddTab Method
    function WindowObj:AddTab(TabOpts)
        TabOpts = TabOpts or {}
        local TabTitle = TabOpts.Title or "Tab"
        
        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.ScrollBarThickness = 3
        TabFrame.Parent = TabContainer

        local ElementList = Instance.new("UIListLayout")
        ElementList.SortOrder = Enum.SortOrder.LayoutOrder
        ElementList.Padding = UDim.new(0, 8)
        ElementList.Parent = TabFrame

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -16, 0, 32)
        TabBtn.Text = "  " .. TabTitle
        TabBtn.Font = Enum.Font.SourceSansSemibold
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = TabBtn

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            TabFrame.Visible = true
        end)

        local TabObj = { Frame = TabFrame }

        -- AddSection
        function TabObj:AddSection(Text)
            local SecLbl = Instance.new("TextLabel")
            SecLbl.Size = UDim2.new(1, -20, 0, 24)
            SecLbl.Text = string.upper(Text)
            SecLbl.Font = Enum.Font.SourceSansBold
            SecLbl.TextSize = 11
            SecLbl.TextColor3 = ActiveTheme.Accent
            SecLbl.TextXAlignment = Enum.TextXAlignment.Left
            SecLbl.BackgroundTransparency = 1
            SecLbl.Parent = TabFrame
        end

        -- AddButton
        function TabObj:AddButton(BtnOpts)
            local BTitle = BtnOpts.Title or "Button"
            local Callback = BtnOpts.Callback or function() end

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -20, 0, 36)
            Btn.Text = "  " .. BTitle
            Btn.Font = Enum.Font.SourceSans
            Btn.TextSize = 13
            Btn.TextColor3 = Color3.fromRGB(240, 240, 255)
            Btn.BackgroundColor3 = ActiveTheme.Container
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = TabFrame

            local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 6) C.Parent = Btn
            Btn.MouseButton1Click:Connect(Callback)
        end

        -- AddToggle
        function TabObj:AddToggle(TogOpts)
            local TTitle = TogOpts.Title or "Toggle"
            local Default = TogOpts.Default or false
            local Callback = TogOpts.Callback or function() end
            local State = Default

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -20, 0, 36)
            Frame.BackgroundColor3 = ActiveTheme.Container
            Frame.Parent = TabFrame

            local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 6) C.Parent = Frame

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = "  " .. TTitle
            Lbl.Size = UDim2.new(1, -50, 1, 0)
            Lbl.TextColor3 = Color3.fromRGB(240, 240, 255)
            Lbl.Font = Enum.Font.SourceSans
            Lbl.TextSize = 13
            Lbl.BackgroundTransparency = 1
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Frame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -44, 0.5, -9)
            Switch.Text = ""
            Switch.BackgroundColor3 = State and ActiveTheme.Accent or Color3.fromRGB(40, 45, 60)
            Switch.Parent = Frame
            local SC = Instance.new("UICorner") SC.CornerRadius = UDim.new(1, 0) SC.Parent = Switch

            Switch.MouseButton1Click:Connect(function()
                State = not State
                Switch.BackgroundColor3 = State and ActiveTheme.Accent or Color3.fromRGB(40, 45, 60)
                Callback(State)
            end)
        end

        -- AddSlider
        function TabObj:AddSlider(SlidOpts)
            local STitle = SlidOpts.Title or "Slider"
            local Min = SlidOpts.Min or 0
            local Max = SlidOpts.Max or 100
            local Default = SlidOpts.Default or Min
            local Callback = SlidOpts.Callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -20, 0, 46)
            Frame.BackgroundColor3 = ActiveTheme.Container
            Frame.Parent = TabFrame
            local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 6) C.Parent = Frame

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = "  " .. STitle
            Lbl.Size = UDim2.new(1, -60, 0, 20)
            Lbl.TextColor3 = Color3.fromRGB(240, 240, 255)
            Lbl.Font = Enum.Font.SourceSans
            Lbl.TextSize = 13
            Lbl.BackgroundTransparency = 1
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Frame

            local ValLbl = Instance.new("TextLabel")
            ValLbl.Text = tostring(Default)
            ValLbl.Size = UDim2.new(0, 50, 0, 20)
            ValLbl.Position = UDim2.new(1, -55, 0, 0)
            ValLbl.TextColor3 = ActiveTheme.Accent
            ValLbl.Font = Enum.Font.SourceSansBold
            ValLbl.TextSize = 12
            ValLbl.BackgroundTransparency = 1
            ValLbl.Parent = Frame
        end

        -- AddDropdown & AddMultiDropdown
        function TabObj:AddDropdown(DropOpts)
            local DTitle = DropOpts.Title or "Dropdown"
            local Values = DropOpts.Values or {}
            local Callback = DropOpts.Callback or function() end

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -20, 0, 36)
            Btn.Text = "  " .. DTitle .. " [Select]"
            Btn.Font = Enum.Font.SourceSans
            Btn.TextSize = 13
            Btn.TextColor3 = Color3.fromRGB(240, 240, 255)
            Btn.BackgroundColor3 = ActiveTheme.Container
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = TabFrame
            local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 6) C.Parent = Btn
        end

        function TabObj:AddMultiDropdown(Opts) self:AddDropdown(Opts) end
        function TabObj:AddKeybind(Opts) self:AddButton({Title = Opts.Title, Callback = Opts.Callback}) end
        function TabObj:AddParagraph(Opts) self:AddSection(Opts.Title) end

        return TabObj
    end

    return WindowObj
end

return EclipseUI
