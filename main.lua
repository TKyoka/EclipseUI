local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local EclipseUI = {}
EclipseUI.__index = EclipseUI

local LucideIcons = {}
local iconsLoaded = false

task.spawn(function()
	local url = "https://raw.githubusercontent.com/TKyoka/EclipseUI/refs/heads/main/lucideicons"
	local success, response = pcall(fetchUrl, url)

	if success and response then
		-- Execute the fetched Lua string to get the returned table
		local loadFunc, err = loadstring(response)
		if loadFunc then
			local funcSuccess, resultTable = pcall(loadFunc)
			if funcSuccess and type(resultTable) == "table" then
				LucideIcons = resultTable
			else
				warn("[EclipseUI] Failed to execute icon table:", resultTable)
			end
		else
			warn("[EclipseUI] Failed to parse icon table:", err)
		end
	else
		warn("[EclipseUI] Failed to fetch icons from GitHub:", response)
	end
	
	iconsLoaded = true
end)

function EclipseUI:CreateWindow(options)
	options = options or {}
	local windowName = options.Title or options.Name or "Eclipse UI"

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EclipseUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Main Container Frame
	local mainGroup = Instance.new("CanvasGroup")
	mainGroup.Name = "MainGroup"
	mainGroup.AnchorPoint = Vector2.new(0.5, 0.5)
	mainGroup.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainGroup.Size = UDim2.new(0, 430, 0, 275)
	mainGroup.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
	mainGroup.BackgroundTransparency = 0.2
	mainGroup.BorderSizePixel = 0
	mainGroup.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = mainGroup

	-- Outer Frame Outline
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Thickness = 1.5
	uiStroke.Transparency = 0.65
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = mainGroup

	-- Separator Lines
	local lines = Instance.new("Folder")
	lines.Name = "Lines"
	lines.Parent = mainGroup

	local lineDarkColor = Color3.fromRGB(255, 255, 255)
	local lineTransparency = 0.92

	local headerLine1 = Instance.new("Frame")
	headerLine1.Position = UDim2.new(0, 135, 0, 46)
	headerLine1.Size = UDim2.new(1, -135, 0, 1)
	headerLine1.BackgroundColor3 = lineDarkColor
	headerLine1.BackgroundTransparency = lineTransparency
	headerLine1.BorderSizePixel = 0
	headerLine1.Parent = lines

	local headerLine2 = Instance.new("Frame")
	headerLine2.Position = UDim2.new(0, 0, 0, 46)
	headerLine2.Size = UDim2.new(0, 134, 0, 1)
	headerLine2.BackgroundColor3 = lineDarkColor
	headerLine2.BackgroundTransparency = lineTransparency
	headerLine2.BorderSizePixel = 0
	headerLine2.Parent = lines

	local verticalLine = Instance.new("Frame")
	verticalLine.Position = UDim2.new(0, 134, 0, 46)
	verticalLine.Size = UDim2.new(0, 1, 1, -46)
	verticalLine.BackgroundColor3 = lineDarkColor
	verticalLine.BackgroundTransparency = lineTransparency
	verticalLine.BorderSizePixel = 0
	verticalLine.Parent = lines

	local userLine = Instance.new("Frame")
	userLine.AnchorPoint = Vector2.new(0, 1)
	userLine.Position = UDim2.new(0, 0, 1, -52)
	userLine.Size = UDim2.new(0, 134, 0, 1)
	userLine.BackgroundColor3 = lineDarkColor
	userLine.BackgroundTransparency = lineTransparency
	userLine.BorderSizePixel = 0
	userLine.Parent = lines

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 46)
	header.BackgroundTransparency = 1
	header.Parent = mainGroup

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = windowName
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = header

	-- Tab Sidebar
	local tabs = Instance.new("ScrollingFrame")
	tabs.Name = "Tabs"
	tabs.Position = UDim2.new(0, 0, 0, 46)
	tabs.Size = UDim2.new(0, 134, 1, -98)
	tabs.BackgroundTransparency = 1
	tabs.ScrollBarThickness = 0
	tabs.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabs.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabs.Parent = mainGroup

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.Padding = UDim.new(0, 4)
	tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabsLayout.Parent = tabs

	local tabsPadding = Instance.new("UIPadding")
	tabsPadding.PaddingLeft = UDim.new(0, 10)
	tabsPadding.PaddingRight = UDim.new(0, 10)
	tabsPadding.PaddingTop = UDim.new(0, 8)
	tabsPadding.PaddingBottom = UDim.new(0, 8)
	tabsPadding.Parent = tabs

	-- User Info Section
	local userInfo = Instance.new("Frame")
	userInfo.Name = "UserInfo"
	userInfo.AnchorPoint = Vector2.new(0, 1)
	userInfo.Position = UDim2.new(0, 0, 1, 0)
	userInfo.Size = UDim2.new(0, 134, 0, 52)
	userInfo.BackgroundTransparency = 1
	userInfo.Parent = mainGroup

	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Name = "Avatar"
	avatarImage.Size = UDim2.new(0, 32, 0, 32)
	avatarImage.Position = UDim2.new(0, 12, 0.5, -16)
	avatarImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	avatarImage.BackgroundTransparency = 0.94
	avatarImage.Parent = userInfo

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(1, 0)
	avatarCorner.Parent = avatarImage

	task.spawn(function()
		local content, isReady = Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
		if isReady then
			avatarImage.Image = content
		end
	end)

	local displayNameLabel = Instance.new("TextLabel")
	displayNameLabel.Name = "DisplayName"
	displayNameLabel.Size = UDim2.new(1, -52, 0, 15)
	displayNameLabel.Position = UDim2.new(0, 50, 0, 10)
	displayNameLabel.BackgroundTransparency = 1
	displayNameLabel.Text = LocalPlayer.DisplayName
	displayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	displayNameLabel.TextSize = 12
	displayNameLabel.Font = Enum.Font.GothamBold
	displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	displayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	displayNameLabel.Parent = userInfo

	local usernameLabel = Instance.new("TextLabel")
	usernameLabel.Name = "Username"
	usernameLabel.Size = UDim2.new(1, -52, 0, 13)
	usernameLabel.Position = UDim2.new(0, 50, 0, 26)
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.Text = "@" .. LocalPlayer.Name
	usernameLabel.TextColor3 = Color3.fromRGB(150, 158, 175)
	usernameLabel.TextSize = 10
	usernameLabel.Font = Enum.Font.GothamBold
	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	usernameLabel.Parent = userInfo

	-- Contents Frame
	local contents = Instance.new("Frame")
	contents.Name = "Contents"
	contents.AnchorPoint = Vector2.new(1, 1)
	contents.Position = UDim2.new(1, 0, 1, 0)
	contents.Size = UDim2.new(1, -135, 1, -46)
	contents.BackgroundTransparency = 1
	contents.Parent = mainGroup

	local Window = { Tabs = {}, ActiveTab = nil }

	local fastTweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function tween(object, properties)
		if typeof(object) == "Instance" then
			TweenService:Create(object, fastTweenInfo, properties):Play()
		end
	end

	function Window:SelectTab(targetTab)
		Window.ActiveTab = targetTab

		for _, tab in ipairs(Window.Tabs) do
			if tab == targetTab then
				tab.Page.Visible = true
				tween(tab.Background, { BackgroundTransparency = 0.86 })
				tween(tab.Stroke, { Transparency = 0.88 })
				tween(tab.Label, { TextColor3 = Color3.fromRGB(255, 255, 255) })
				if tab.IconImage then
					tween(tab.IconImage, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
				end
			else
				tab.Page.Visible = false
				tween(tab.Background, { BackgroundTransparency = 0.96 })
				tween(tab.Stroke, { Transparency = 0.95 })
				tween(tab.Label, { TextColor3 = Color3.fromRGB(160, 168, 184) })
				if tab.IconImage then
					tween(tab.IconImage, { ImageColor3 = Color3.fromRGB(160, 168, 184) })
				end
			end
		end
	end

	function Window:Tab(tabOptions)
		tabOptions = tabOptions or {}
		local tabTitle = tabOptions.Title or tabOptions.Name or "Tab"
		local rawIcon = tabOptions.Icon

		local tabFrame = Instance.new("Frame")
		tabFrame.Name = tabTitle .. "TabFrame"
		tabFrame.Size = UDim2.new(1, 0, 0, 30)
		tabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tabFrame.BackgroundTransparency = 0.96
		tabFrame.Parent = tabs

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 6)
		tabCorner.Parent = tabFrame

		local tabStroke = Instance.new("UIStroke")
		tabStroke.Color = Color3.fromRGB(255, 255, 255)
		tabStroke.Thickness = 1
		tabStroke.Transparency = 0.95
		tabStroke.Parent = tabFrame

		local clickBtn = Instance.new("TextButton")
		clickBtn.Name = "ClickDetector"
		clickBtn.Size = UDim2.new(1, 0, 1, 0)
		clickBtn.BackgroundTransparency = 1
		clickBtn.AutoButtonColor = false
		clickBtn.Text = ""
		clickBtn.ZIndex = 3
		clickBtn.Parent = tabFrame

		local iconImg = nil
		local textOffset = 12

		if rawIcon then
			iconImg = Instance.new("ImageLabel")
			iconImg.Name = "Icon"
			iconImg.Size = UDim2.new(0, 15, 0, 15)
			iconImg.Position = UDim2.new(0, 10, 0.5, -7)
			iconImg.BackgroundTransparency = 1
			iconImg.ImageColor3 = Color3.fromRGB(160, 168, 184)
			iconImg.ZIndex = 2
			iconImg.Parent = tabFrame
			textOffset = 32

			task.spawn(function()
				while not iconsLoaded do
					task.wait(0.05)
				end
				local asset = LucideIcons[string.lower(rawIcon)] or rawIcon
				if asset then
					iconImg.Image = asset
				end
			end)
		end

		local tabText = Instance.new("TextLabel")
		tabText.Name = "Text"
		tabText.Size = UDim2.new(1, -(textOffset + 4), 1, 0)
		tabText.Position = UDim2.new(0, textOffset, 0, 0)
		tabText.BackgroundTransparency = 1
		tabText.Text = tabTitle
		tabText.TextColor3 = Color3.fromRGB(160, 168, 184)
		tabText.TextSize = 13
		tabText.Font = Enum.Font.GothamBold
		tabText.TextXAlignment = Enum.TextXAlignment.Left
		tabText.ZIndex = 2
		tabText.Parent = tabFrame

		local page = Instance.new("ScrollingFrame")
		page.Name = tabTitle .. "Page"
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.ScrollBarThickness = 2
		page.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
		page.ScrollBarImageTransparency = 0.85
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.Parent = contents

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Padding = UDim.new(0, 8)
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Parent = page

		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingLeft = UDim.new(0, 12)
		pagePadding.PaddingRight = UDim.new(0, 12)
		pagePadding.PaddingTop = UDim.new(0, 12)
		pagePadding.PaddingBottom = UDim.new(0, 12)
		pagePadding.Parent = page

		local TabObject = {
			Page = page,
			Background = tabFrame,
			Stroke = tabStroke,
			Button = clickBtn,
			Label = tabText,
			IconImage = iconImg
		}

		clickBtn.MouseEnter:Connect(function()
			if Window.ActiveTab ~= TabObject then
				tween(tabFrame, { BackgroundTransparency = 0.91 })
				tween(tabStroke, { Transparency = 0.90 })
				tween(tabText, { TextColor3 = Color3.fromRGB(220, 225, 235) })
				if iconImg then
					tween(iconImg, { ImageColor3 = Color3.fromRGB(220, 225, 235) })
				end
			end
		end)

		clickBtn.MouseLeave:Connect(function()
			if Window.ActiveTab ~= TabObject then
				tween(tabFrame, { BackgroundTransparency = 0.96 })
				tween(tabStroke, { Transparency = 0.95 })
				tween(tabText, { TextColor3 = Color3.fromRGB(160, 168, 184) })
				if iconImg then
					tween(iconImg, { ImageColor3 = Color3.fromRGB(160, 168, 184) })
				end
			end
		end)

		clickBtn.MouseButton1Click:Connect(function()
			Window:SelectTab(TabObject)
		end)

		table.insert(Window.Tabs, TabObject)

		if #Window.Tabs == 1 then
			Window:SelectTab(TabObject)
		end

		function TabObject:Button(btnOptions)
			btnOptions = btnOptions or {}
			local btnName = btnOptions.Title or btnOptions.Name or "Button"
			local callback = btnOptions.Callback or function() end

			local card = Instance.new("Frame")
			card.Name = btnName .. "Card"
			card.Size = UDim2.new(1, 0, 0, 42)
			card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			card.BackgroundTransparency = 0.96
			card.Parent = page

			local cardCorner = Instance.new("UICorner")
			cardCorner.CornerRadius = UDim.new(0, 8)
			cardCorner.Parent = card

			local cardStroke = Instance.new("UIStroke")
			cardStroke.Color = Color3.fromRGB(255, 255, 255)
			cardStroke.Thickness = 1
			cardStroke.Transparency = 0.93
			cardStroke.Parent = card

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.6, 0, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = btnName
			label.TextColor3 = Color3.fromRGB(245, 248, 255)
			label.TextSize = 13
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = card

			local btnContainer = Instance.new("TextButton")
			btnContainer.Name = "ExecuteButton"
			btnContainer.Size = UDim2.new(0, 72, 0, 26)
			btnContainer.Position = UDim2.new(1, -84, 0.5, -13)
			btnContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			btnContainer.BackgroundTransparency = 0.91
			btnContainer.AutoButtonColor = false
			btnContainer.Text = ""
			btnContainer.Parent = card

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 6)
			btnCorner.Parent = btnContainer

			local btnStroke = Instance.new("UIStroke")
			btnStroke.Color = Color3.fromRGB(255, 255, 255)
			btnStroke.Thickness = 1
			btnStroke.Transparency = 0.88
			btnStroke.Parent = btnContainer

			local btnText = Instance.new("TextLabel")
			btnText.Size = UDim2.new(1, 0, 1, 0)
			btnText.BackgroundTransparency = 1
			btnText.Text = "Execute"
			btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
			btnText.TextSize = 12
			btnText.Font = Enum.Font.GothamBold
			btnText.Active = false
			btnText.Parent = btnContainer

			btnContainer.MouseEnter:Connect(function()
				tween(btnContainer, { BackgroundTransparency = 0.82 })
			end)

			btnContainer.MouseLeave:Connect(function()
				tween(btnContainer, { BackgroundTransparency = 0.91 })
			end)

			btnContainer.MouseButton1Click:Connect(function()
				local t1 = TweenService:Create(btnContainer, TweenInfo.new(0.06), { Size = UDim2.new(0, 68, 0, 24), Position = UDim2.new(1, -82, 0.5, -12) })
				local t2 = TweenService:Create(btnContainer, TweenInfo.new(0.06), { Size = UDim2.new(0, 72, 0, 26), Position = UDim2.new(1, -84, 0.5, -13) })
				t1:Play()
				t1.Completed:Wait()
				t2:Play()

				callback()
			end)

			return card
		end

		return TabObject
	end

	return Window
end

return EclipseUI
