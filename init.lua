local EclipseUI = {}
EclipseUI.__index = EclipseUI

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function EclipseUI.CreateWindow(config)
	config = config or {}
	local self = setmetatable({}, Window)

	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = config.Folder or "EclipseUI"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.Parent = CoreGui

	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = UDim2.fromOffset(500, 400)
	self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
	self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	self.MainFrame.Parent = self.ScreenGui

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 8)
	mainCorner.Parent = self.MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -20, 0, 40)
	TitleLabel.Position = UDim2.new(0, 10, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	TitleLabel.TextSize = 14
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = (config.Title or "UI") .. " " .. (config.Author or "")
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = self.MainFrame

	self.TagContainer = Instance.new("Frame")
	self.TagContainer.Size = UDim2.new(0, 200, 0, 30)
	self.TagContainer.Position = UDim2.new(1, -210, 0, 5)
	self.TagContainer.BackgroundTransparency = 1
	self.TagContainer.Parent = self.MainFrame

	local tagLayout = Instance.new("UIListLayout")
	tagLayout.FillDirection = Enum.FillDirection.Horizontal
	tagLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	tagLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tagLayout.Padding = UDim.new(0, 5)
	tagLayout.Parent = self.TagContainer

	self.ContentContainer = Instance.new("ScrollingFrame")
	self.ContentContainer.Size = UDim2.new(1, -20, 1, -55)
	self.ContentContainer.Position = UDim2.new(0, 10, 0, 45)
	self.ContentContainer.BackgroundTransparency = 1
	self.ContentContainer.CanvasSize = UDim2.new(0, 0, 2, 0)
	self.ContentContainer.Parent = self.MainFrame

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 8)
	contentLayout.Parent = self.ContentContainer

	return self
end

function Window:Tag(config)
	config = config or {}
	
	local TagFrame = Instance.new("Frame")
	TagFrame.Size = UDim2.fromOffset(80, 24)
	TagFrame.BackgroundColor3 = config.Color or Color3.fromRGB(40, 40, 40)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = TagFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 11
	label.Font = Enum.Font.GothamMedium
	label.Text = tostring(config.Title or "Tag")
	label.Parent = TagFrame

	TagFrame.Parent = self.TagContainer

	if string.find(label.Text, "FPS") then
		RunService.RenderStepped:Connect(function(dt)
			if dt > 0 then
				label.Text = string.format("FPS: %.0f", 1 / dt)
			end
		end)
	end

	local TagObject = {}
	function TagObject:SetText(txt) label.Text = txt end
	return TagObject
end

function Window:Tab(config)
	config = config or {}
	local self = setmetatable({}, Tab)

	self.TabFrame = Instance.new("Frame")
	self.TabFrame.Size = UDim2.new(1, 0, 0, 200)
	self.TabFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = self.TabFrame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 5)
	layout.Parent = self.TabFrame

	self.TabFrame.Parent = Window.ContentContainer
	return self
end

function Tab:Section(config)
	config = config or {}
	local self = setmetatable({}, Section)

	self.SectionFrame = Instance.new("Frame")
	self.SectionFrame.Size = UDim2.new(1, 0, 0, 150)
	self.SectionFrame.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 25)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	titleLabel.TextSize, titleLabel.Font = 12, Enum.Font.GothamBold
	titleLabel.Text = config.Title or "Section"
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = self.SectionFrame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.Parent = self.SectionFrame

	self.SectionFrame.Parent = Tab.TabFrame
	return self
end

function Section:Button(config)
	config = config or {}
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.TextSize, btn.Font = 12, Enum.Font.Gotham
	btn.Text = config.Title or "Button"
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if config.Callback then
			task.spawn(config.Callback)
		end
	end)

	btn.Parent = self.SectionFrame
end

function Section:Dropdown(config)
	self:Button({ Title = config.Title .. " [Dropdown]", Callback = config.Callback })
end

function Section:MultiDropdown(config)
	self:Button({ Title = config.Title .. " [MultiDropdown]", Callback = config.Callback })
end

function Section:Slider(config)
	self:Button({ Title = config.Title .. " [Slider]", Callback = config.Callback })
end

return EclipseUI
