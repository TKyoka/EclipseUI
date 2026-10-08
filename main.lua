local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Executor Client-Side Icon Fetching
local LucideIcons = {}
local iconsLoaded = false

task.spawn(function()
	local success, result = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/TKyoka/EclipseUI/refs/heads/main/lucideicons.lua")
	end)

	if success and result then
		local loadSuccess, iconTable = pcall(function()
			return loadstring(result)()
		end)

		if loadSuccess and typeof(iconTable) == "table" then
			LucideIcons = iconTable
			iconsLoaded = true
		end
	end
end)

local function getIconAsset(iconInput)
	if not iconInput then return "" end

	if string.sub(tostring(iconInput), 1, 13) == "rbxassetid://" then
		return iconInput
	elseif typeof(iconInput) == "number" then
		return "rbxassetid://" .. iconInput
	end

	local iconName = string.lower(tostring(iconInput))
	return LucideIcons[iconName] or ""
end

local EclipseUI = {}
EclipseUI.__index = EclipseUI

function EclipseUI:CreateWindow(options)
	options = options or {}
	local windowName = options.Title or options.Name or "Eclipse UI"
	local windowIcon = options.Icon
	local toggleKey = options.ToggleKey or Enum.KeyCode.RightControl
	local bgName = options.BgName
	local windowTags = options.Tags

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EclipseUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Original Window Dimensions
	local defaultSize = UDim2.new(0, 480, 0, 320)
	local defaultPos = UDim2.new(0.5, 0, 0.5, 0)

	-- Main Container Frame
	local mainGroup = Instance.new("CanvasGroup")
	mainGroup.Name = "MainGroup"
	mainGroup.AnchorPoint = Vector2.new(0.5, 0.5)
	mainGroup.Position = defaultPos
	mainGroup.Size = defaultSize
	mainGroup.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
	mainGroup.BackgroundTransparency = 0.2
	mainGroup.BorderSizePixel = 0
	mainGroup.ZIndex = 2
	mainGroup.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = mainGroup

	-- Animated Background
	local mainBackground = Instance.new("Frame")
	mainBackground.Name = "AnimatedBackground"
	mainBackground.Size = UDim2.new(1, 0, 1, 0)
	mainBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	mainBackground.BackgroundTransparency = 0.92
	mainBackground.BorderSizePixel = 0
	mainBackground.ZIndex = 0
	mainBackground.Parent = mainGroup

	local mainBgGradient = Instance.new("UIGradient")
	mainBgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 16, 22)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(45, 55, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 16, 22))
	})
	mainBgGradient.Rotation = 45
	mainBgGradient.Offset = Vector2.new(-1, 0)
	mainBgGradient.Parent = mainBackground

	-- Glowing Outline
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Thickness = 1.5
	uiStroke.Transparency = 0.4
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = mainGroup

	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 90, 120)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 90, 120))
	})
	strokeGradient.Parent = uiStroke

	-- Animation Loop
	local mainTimeAcc = 0
	local mainAnimConnection
	mainAnimConnection = RunService.RenderStepped:Connect(function(dt)
		if not mainGroup:IsDescendantOf(game) then
			mainAnimConnection:Disconnect()
			return
		end

		mainTimeAcc = mainTimeAcc + dt
		strokeGradient.Rotation = (mainTimeAcc * 60) % 360
		local sheenProgress = (mainTimeAcc * 0.4) % 2 - 1
		mainBgGradient.Offset = Vector2.new(sheenProgress, 0)
		local pulse = (math.sin(mainTimeAcc * 2) + 1) / 2
		uiStroke.Transparency = 0.35 + (pulse * 0.2)
	end)

	-- Window Visibility Keybind Listener
	local windowVisible = true
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == toggleKey then
			windowVisible = not windowVisible
			local targetTransparency = windowVisible and 0 or 1
			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			if windowVisible then
				mainGroup.Visible = true
			end

			local t = TweenService:Create(mainGroup, tweenInfo, { GroupTransparency = targetTransparency })
			t:Play()

			if not windowVisible then
				t.Completed:Connect(function()
					if not windowVisible then
						mainGroup.Visible = false
					end
				end)
			end
		end
	end)

	-- Body Content Group (CanvasGroup for fast fade support)
	local bodyGroup = Instance.new("CanvasGroup")
	bodyGroup.Name = "BodyGroup"
	bodyGroup.Size = UDim2.new(1, 0, 1, -46)
	bodyGroup.Position = UDim2.new(0, 0, 0, 46)
	bodyGroup.BackgroundTransparency = 1
	bodyGroup.GroupTransparency = 0
	bodyGroup.ZIndex = 3
	bodyGroup.Parent = mainGroup

	-- Separators (CanvasGroup for line fade support during drag)
	local linesCanvasGroup = Instance.new("CanvasGroup")
	linesCanvasGroup.Name = "LinesCanvasGroup"
	linesCanvasGroup.Size = UDim2.new(1, 0, 1, 0)
	linesCanvasGroup.BackgroundTransparency = 1
	linesCanvasGroup.GroupTransparency = 0
	linesCanvasGroup.ZIndex = 2
	linesCanvasGroup.Parent = mainGroup

	local lineDarkColor = Color3.fromRGB(255, 255, 255)
	local lineTransparency = 0.92

	local headerLine1 = Instance.new("Frame")
	headerLine1.Position = UDim2.new(0, 135, 0, 0)
	headerLine1.Size = UDim2.new(1, -135, 0, 1)
	headerLine1.BackgroundColor3 = lineDarkColor
	headerLine1.BackgroundTransparency = lineTransparency
	headerLine1.BorderSizePixel = 0
	headerLine1.ZIndex = 2
	headerLine1.Parent = linesCanvasGroup

	local headerLine2 = Instance.new("Frame")
	headerLine2.Position = UDim2.new(0, 0, 0, 0)
	headerLine2.Size = UDim2.new(0, 134, 0, 1)
	headerLine2.BackgroundColor3 = lineDarkColor
	headerLine2.BackgroundTransparency = lineTransparency
	headerLine2.BorderSizePixel = 0
	headerLine2.ZIndex = 2
	headerLine2.Parent = linesCanvasGroup

	local verticalLine = Instance.new("Frame")
	verticalLine.Position = UDim2.new(0, 134, 0, 0)
	verticalLine.Size = UDim2.new(0, 1, 1, 0)
	verticalLine.BackgroundColor3 = lineDarkColor
	verticalLine.BackgroundTransparency = lineTransparency
	verticalLine.BorderSizePixel = 0
	verticalLine.ZIndex = 2
	verticalLine.Parent = bodyGroup

	local userLine = Instance.new("Frame")
	userLine.AnchorPoint = Vector2.new(0, 1)
	userLine.Position = UDim2.new(0, 0, 1, -52)
	userLine.Size = UDim2.new(0, 134, 0, 1)
	userLine.BackgroundColor3 = lineDarkColor
	userLine.BackgroundTransparency = lineTransparency
	userLine.BorderSizePixel = 0
	userLine.ZIndex = 2
	userLine.Parent = bodyGroup

	-- Header Frame
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 46)
	header.BackgroundTransparency = 1
	header.ZIndex = 4
	header.Parent = mainGroup

	local titleOffsetLeft = 16

	if windowIcon then
		local headerIcon = Instance.new("ImageLabel")
		headerIcon.Name = "HeaderIcon"
		headerIcon.Size = UDim2.new(0, 16, 0, 16)
		headerIcon.Position = UDim2.new(0, 14, 0.5, -8)
		headerIcon.BackgroundTransparency = 1
		headerIcon.Image = getIconAsset(windowIcon)
		headerIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		headerIcon.ZIndex = 4
		headerIcon.Parent = header

		if not iconsLoaded and not string.find(tostring(windowIcon), "rbxassetid://") then
			task.spawn(function()
				repeat task.wait() until iconsLoaded or not headerIcon:IsDescendantOf(game)
				if headerIcon:IsDescendantOf(game) then
					headerIcon.Image = getIconAsset(windowIcon)
				end
			end)
		end

		titleOffsetLeft = 36
	end

	-- Header Title & Tags Wrapper
	local titleWrapper = Instance.new("Frame")
	titleWrapper.Name = "TitleWrapper"
	titleWrapper.Size = UDim2.new(1, -(titleOffsetLeft + 104), 1, 0)
	titleWrapper.Position = UDim2.new(0, titleOffsetLeft, 0, 0)
	titleWrapper.BackgroundTransparency = 1
	titleWrapper.ZIndex = 4
	titleWrapper.Parent = header

	local titleLayout = Instance.new("UIListLayout")
	titleLayout.FillDirection = Enum.FillDirection.Horizontal
	titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	titleLayout.SortOrder = Enum.SortOrder.LayoutOrder
	titleLayout.Padding = UDim.new(0, 8)
	titleLayout.Parent = titleWrapper

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(0, 0, 1, 0)
	titleLabel.AutomaticSize = Enum.AutomaticSize.X
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = windowName
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.LayoutOrder = 1
	titleLabel.ZIndex = 4
	titleLabel.Parent = titleWrapper

	local TagsObj = {}

	if windowTags and typeof(windowTags) == "table" then
		local tagsList = Instance.new("Frame")
		tagsList.Name = "TagsList"
		tagsList.Size = UDim2.new(0, 200, 1, 0)
		tagsList.AutomaticSize = Enum.AutomaticSize.X
		tagsList.BackgroundTransparency = 1
		tagsList.LayoutOrder = 2
		tagsList.ZIndex = 4
		tagsList.Parent = titleWrapper

		local tagsLayout = Instance.new("UIListLayout")
		tagsLayout.FillDirection = Enum.FillDirection.Horizontal
		tagsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		tagsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tagsLayout.Padding = UDim.new(0, 5)
		tagsLayout.Parent = tagsList

		for index, tagName in ipairs(windowTags) do
			local tagPill = Instance.new("Frame")
			tagPill.Name = "Tag_" .. index
			tagPill.Size = UDim2.new(0, 0, 0, 20)
			tagPill.AutomaticSize = Enum.AutomaticSize.X
			tagPill.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
			tagPill.BackgroundTransparency = 0.4
			tagPill.ZIndex = 4
			tagPill.Parent = tagsList

			local tagCorner = Instance.new("UICorner")
			tagCorner.CornerRadius = UDim.new(1, 0)
			tagCorner.Parent = tagPill

			local tagStroke = Instance.new("UIStroke")
			tagStroke.Color = Color3.fromRGB(255, 255, 255)
			tagStroke.Thickness = 1
			tagStroke.Transparency = 0.85
			tagStroke.Parent = tagPill

			local tagPadding = Instance.new("UIPadding")
			tagPadding.PaddingLeft = UDim.new(0, 8)
			tagPadding.PaddingRight = UDim.new(0, 8)
			tagPadding.Parent = tagPill

			local tagText = Instance.new("TextLabel")
			tagText.Name = "Text"
			tagText.Size = UDim2.new(0, 0, 1, 0)
			tagText.AutomaticSize = Enum.AutomaticSize.X
			tagText.BackgroundTransparency = 1
			tagText.Text = tostring(tagName)
			tagText.TextColor3 = Color3.fromRGB(200, 210, 225)
			tagText.TextSize = 10
			tagText.Font = Enum.Font.GothamBold
			tagText.TextXAlignment = Enum.TextXAlignment.Left
			tagText.ZIndex = 4
			tagText.Parent = tagPill

			TagsObj[index] = {
				SetText = function(_, newText)
					tagText.Text = tostring(newText)
				end
			}
		end
	end

	-- Window Control Buttons Container
	local controlsFrame = Instance.new("Frame")
	controlsFrame.Name = "Controls"
	controlsFrame.AnchorPoint = Vector2.new(1, 0.5)
	controlsFrame.Position = UDim2.new(1, -12, 0.5, 0)
	controlsFrame.Size = UDim2.new(0, 84, 0, 24)
	controlsFrame.BackgroundTransparency = 1
	controlsFrame.ZIndex = 10
	controlsFrame.Parent = header

	local controlsLayout = Instance.new("UIListLayout")
	controlsLayout.FillDirection = Enum.FillDirection.Horizontal
	controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	controlsLayout.Padding = UDim.new(0, 4)
	controlsLayout.Parent = controlsFrame

	local function createControlButton(name, iconName, hoverColor, order, iconSize)
		iconSize = iconSize or 14

		local btnFrame = Instance.new("Frame")
		btnFrame.Name = name
		btnFrame.Size = UDim2.new(0, 24, 0, 24)
		btnFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		btnFrame.BackgroundTransparency = 1
		btnFrame.LayoutOrder = order
		btnFrame.ZIndex = 10
		btnFrame.Parent = controlsFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btnFrame

		local icon = Instance.new("ImageButton")
		icon.Name = "Icon"
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.Size = UDim2.new(0, iconSize, 0, iconSize)
		icon.BackgroundTransparency = 1
		icon.Image = getIconAsset(iconName)
		icon.ImageColor3 = Color3.fromRGB(150, 160, 180)
		icon.ZIndex = 11
		icon.Parent = btnFrame

		if not iconsLoaded then
			task.spawn(function()
				repeat task.wait() until iconsLoaded or not icon:IsDescendantOf(game)
				if icon:IsDescendantOf(game) then
					icon.Image = getIconAsset(iconName)
				end
			end)
		end

		icon.MouseEnter:Connect(function()
			TweenService:Create(btnFrame, TweenInfo.new(0.15), { BackgroundTransparency = 0.92 }):Play()
			TweenService:Create(icon, TweenInfo.new(0.15), { ImageColor3 = hoverColor }):Play()
		end)

		icon.MouseLeave:Connect(function()
			TweenService:Create(btnFrame, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(icon, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(150, 160, 180) }):Play()
		end)

		return icon, btnFrame
	end

	local function setButtonIcon(btnInstance, iconName)
		local iconChild = btnInstance:FindFirstChild("Icon") or btnInstance
		if iconChild:IsA("ImageLabel") or iconChild:IsA("ImageButton") then
			iconChild.Image = getIconAsset(iconName)
		end
	end

	local minimizeBtn = createControlButton("MinimizeBtn", "minus", Color3.fromRGB(255, 255, 255), 1)
	local resizeBtn = createControlButton("ResizeBtn", "maximize", Color3.fromRGB(255, 255, 255), 2)
	local destroyBtn = createControlButton("DestroyBtn", "x", Color3.fromRGB(255, 60, 60), 3, 18)

	local isMinimized = false
	local isMinimizing = false
	local isFullscreen = false

	minimizeBtn.MouseButton1Click:Connect(function()
		if isMinimizing then return end
		isMinimizing = true
		isMinimized = not isMinimized

		local windowTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local fastFadeInfo = TweenInfo.new(0.08, Enum.EasingStyle.Linear)

		if isMinimized then
			TweenService:Create(bodyGroup, fastFadeInfo, { GroupTransparency = 1 }):Play()
			TweenService:Create(linesCanvasGroup, fastFadeInfo, { GroupTransparency = 1 }):Play()

			task.wait(0.08)
			bodyGroup.Visible = false

			local shrinkTween = TweenService:Create(mainGroup, windowTweenInfo, { Size = UDim2.new(0, defaultSize.X.Offset, 0, 46) })
			shrinkTween:Play()
			shrinkTween.Completed:Connect(function()
				isMinimizing = false
			end)
		else
			bodyGroup.Visible = true
			TweenService:Create(bodyGroup, fastFadeInfo, { GroupTransparency = 0 }):Play()
			TweenService:Create(linesCanvasGroup, windowTweenInfo, { GroupTransparency = 0 }):Play()

			local targetSize = isFullscreen and UDim2.new(0.95, 0, 0.95, 0) or defaultSize
			local expandTween = TweenService:Create(mainGroup, windowTweenInfo, { Size = targetSize })
			expandTween:Play()
			expandTween.Completed:Connect(function()
				isMinimizing = false
			end)
		end
	end)

	resizeBtn.MouseButton1Click:Connect(function()
		if isMinimized then return end
		isFullscreen = not isFullscreen

		local resizeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		if isFullscreen then
			setButtonIcon(resizeBtn, "shrink")
			TweenService:Create(mainGroup, resizeTweenInfo, {
				Size = UDim2.new(0.95, 0, 0.95, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0)
			}):Play()
		else
			setButtonIcon(resizeBtn, "maximize")
			TweenService:Create(mainGroup, resizeTweenInfo, {
				Size = defaultSize,
				Position = defaultPos
			}):Play()
		end
	end)

	destroyBtn.MouseButton1Click:Connect(function()
		if mainAnimConnection then
			mainAnimConnection:Disconnect()
		end

		local destroyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		TweenService:Create(mainGroup, destroyTweenInfo, {
			Size = UDim2.new(0, 380, 0, 240),
			BackgroundTransparency = 1
		}):Play()

		task.delay(0.25, function()
			screenGui:Destroy()
		end)
	end)

	-- Sidebar Containers
	local tabsCanvasGroup = Instance.new("CanvasGroup")
	tabsCanvasGroup.Name = "TabsCanvasGroup"
	tabsCanvasGroup.Size = UDim2.new(0, 134, 1, -52)
	tabsCanvasGroup.BackgroundTransparency = 1
	tabsCanvasGroup.GroupTransparency = 0
	tabsCanvasGroup.ZIndex = 3
	tabsCanvasGroup.Parent = bodyGroup

	local activePill = Instance.new("Frame")
	activePill.Name = "ActivePill"
	activePill.AnchorPoint = Vector2.new(0.5, 0.5)
	activePill.Size = UDim2.new(1, -20, 0, 32)
	activePill.Position = UDim2.new(0.5, 0, 0, 24)
	activePill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	activePill.BackgroundTransparency = 0.82
	activePill.Visible = false
	activePill.ZIndex = 3
	activePill.Parent = tabsCanvasGroup

	local pillCorner = Instance.new("UICorner")
	pillCorner.CornerRadius = UDim.new(0, 7)
	pillCorner.Parent = activePill

	local pillStroke = Instance.new("UIStroke")
	pillStroke.Color = Color3.fromRGB(255, 255, 255)
	pillStroke.Thickness = 1
	pillStroke.Transparency = 0.75
	pillStroke.Parent = activePill

	local pillGradient = Instance.new("UIGradient")
	pillGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 85, 140)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 42, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 28, 38))
	})
	pillGradient.Rotation = 90
	pillGradient.Parent = activePill

	local tabs = Instance.new("ScrollingFrame")
	tabs.Name = "Tabs"
	tabs.Size = UDim2.new(1, 0, 1, 0)
	tabs.BackgroundTransparency = 1
	tabs.ScrollBarThickness = 0
	tabs.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabs.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabs.ZIndex = 4
	tabs.Parent = tabsCanvasGroup

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

	-- User Info
	local userInfoCanvasGroup = Instance.new("CanvasGroup")
	userInfoCanvasGroup.Name = "UserInfoCanvasGroup"
	userInfoCanvasGroup.AnchorPoint = Vector2.new(0, 1)
	userInfoCanvasGroup.Position = UDim2.new(0, 0, 1, 0)
	userInfoCanvasGroup.Size = UDim2.new(0, 134, 0, 52)
	userInfoCanvasGroup.BackgroundTransparency = 1
	userInfoCanvasGroup.GroupTransparency = 0
	userInfoCanvasGroup.ZIndex = 3
	userInfoCanvasGroup.Parent = bodyGroup

	local userInfo = Instance.new("TextButton")
	userInfo.Name = "UserInfo"
	userInfo.AnchorPoint = Vector2.new(0.5, 0.5)
	userInfo.Position = UDim2.new(0.5, 0, 0.5, 0)
	userInfo.Size = UDim2.new(1, -8, 1, -8)
	userInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	userInfo.BackgroundTransparency = 1
	userInfo.Text = ""
	userInfo.AutoButtonColor = false
	userInfo.ZIndex = 3
	userInfo.Parent = userInfoCanvasGroup

	local userCorner = Instance.new("UICorner")
	userCorner.CornerRadius = UDim.new(0, 8)
	userCorner.Parent = userInfo

	local userStroke = Instance.new("UIStroke")
	userStroke.Color = Color3.fromRGB(255, 255, 255)
	userStroke.Thickness = 1
	userStroke.Transparency = 1
	userStroke.Parent = userInfo

	local userContentGroup = Instance.new("CanvasGroup")
	userContentGroup.Name = "UserContentGroup"
	userContentGroup.Size = UDim2.new(1, 0, 1, 0)
	userContentGroup.BackgroundTransparency = 1
	userContentGroup.GroupTransparency = 0
	userContentGroup.ZIndex = 3
	userContentGroup.Parent = userInfo

	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Name = "Avatar"
	avatarImage.Size = UDim2.new(0, 30, 0, 30)
	avatarImage.Position = UDim2.new(0, 8, 0.5, -15)
	avatarImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	avatarImage.BackgroundTransparency = 0.94
	avatarImage.ZIndex = 4
	avatarImage.Parent = userContentGroup

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(1, 0)
	avatarCorner.Parent = avatarImage

	local userThumbnail = ""
	task.spawn(function()
		local content, isReady = Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
		if isReady then
			userThumbnail = content
			avatarImage.Image = content
		end
	end)

	local displayNameLabel = Instance.new("TextLabel")
	displayNameLabel.Name = "DisplayName"
	displayNameLabel.Size = UDim2.new(1, -48, 0, 15)
	displayNameLabel.Position = UDim2.new(0, 44, 0, 8)
	displayNameLabel.BackgroundTransparency = 1
	displayNameLabel.Text = LocalPlayer.DisplayName
	displayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	displayNameLabel.TextSize = 12
	displayNameLabel.Font = Enum.Font.GothamBold
	displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	displayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	displayNameLabel.ZIndex = 4
	displayNameLabel.Parent = userContentGroup

	local usernameLabel = Instance.new("TextLabel")
	usernameLabel.Name = "Username"
	usernameLabel.Size = UDim2.new(1, -48, 0, 13)
	usernameLabel.Position = UDim2.new(0, 44, 0, 23)
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.Text = "@" .. LocalPlayer.Name
	usernameLabel.TextColor3 = Color3.fromRGB(150, 158, 175)
	usernameLabel.TextSize = 10
	usernameLabel.Font = Enum.Font.GothamBold
	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	usernameLabel.ZIndex = 4
	usernameLabel.Parent = userContentGroup

	local isHiddenUser = false
	local userHoverInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local userPressInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local fadeOutInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local fadeInInfo = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	userInfo.MouseEnter:Connect(function()
		TweenService:Create(userInfo, userHoverInfo, { BackgroundTransparency = 0.94 }):Play()
		TweenService:Create(userStroke, userHoverInfo, { Transparency = 0.90 }):Play()
		TweenService:Create(displayNameLabel, userHoverInfo, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)

	userInfo.MouseLeave:Connect(function()
		TweenService:Create(userInfo, userHoverInfo, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(userStroke, userHoverInfo, { Transparency = 1 }):Play()
		TweenService:Create(displayNameLabel, userHoverInfo, { TextColor3 = Color3.fromRGB(240, 245, 255) }):Play()
	end)

	userInfo.MouseButton1Down:Connect(function()
		TweenService:Create(userInfo, userPressInfo, { Size = UDim2.new(1, -12, 1, -12) }):Play()
	end)

	userInfo.MouseButton1Up:Connect(function()
		TweenService:Create(userInfo, userHoverInfo, { Size = UDim2.new(1, -8, 1, -8) }):Play()
	end)

	userInfo.MouseButton1Click:Connect(function()
		isHiddenUser = not isHiddenUser
		local fadeOut = TweenService:Create(userContentGroup, fadeOutInfo, { GroupTransparency = 1 })
		fadeOut:Play()

		fadeOut.Completed:Connect(function()
			if isHiddenUser then
				displayNameLabel.Text = "Eclipse"
				usernameLabel.Text = "@EclipseUI"
				avatarImage.Image = "rbxassetid://11984980776"
			else
				displayNameLabel.Text = LocalPlayer.DisplayName
				usernameLabel.Text = "@" .. LocalPlayer.Name
				avatarImage.Image = userThumbnail
			end

			TweenService:Create(userContentGroup, fadeInInfo, { GroupTransparency = 0 }):Play()
		end)
	end)

	-- Contents Area (CanvasGroup)
	local contents = Instance.new("CanvasGroup")
	contents.Name = "Contents"
	contents.AnchorPoint = Vector2.new(1, 1)
	contents.Position = UDim2.new(1, 0, 1, 0)
	contents.Size = UDim2.new(1, -135, 1, 0)
	contents.BackgroundTransparency = 1
	contents.GroupTransparency = 0
	contents.ZIndex = 3
	contents.Parent = bodyGroup

	-- Perfectly Centered BgName Watermark (Hidden by default, appears ONLY on drag)
	local bgWatermark
	if bgName then
		bgWatermark = Instance.new("TextLabel")
		bgWatermark.Name = "BgWatermark"
		bgWatermark.AnchorPoint = Vector2.new(0.5, 0.5)
		bgWatermark.Position = UDim2.new(0.5, 67, 0.5, 0)
		bgWatermark.Size = UDim2.new(1, 0, 0, 50)
		bgWatermark.BackgroundTransparency = 1
		bgWatermark.Text = bgName
		bgWatermark.TextColor3 = Color3.fromRGB(255, 255, 255)
		bgWatermark.TextTransparency = 1 -- Hidden initially
		bgWatermark.TextSize = 28
		bgWatermark.Font = Enum.Font.GothamBold
		bgWatermark.ZIndex = 2
		bgWatermark.Parent = bodyGroup
	end

	-- Smooth Dragging with Watermark & Line Fade Trigger
	local dragging = false
	local dragStart = Vector2.zero
	local startPos = UDim2.new()
	local targetPos = mainGroup.Position

	header.InputBegan:Connect(function(input)
		if isFullscreen then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mousePos = input.Position
			local controlsPos = controlsFrame.AbsolutePosition
			local controlsSize = controlsFrame.AbsoluteSize

			if mousePos.X >= controlsPos.X and mousePos.X <= controlsPos.X + controlsSize.X and
				mousePos.Y >= controlsPos.Y and mousePos.Y <= controlsPos.Y + controlsSize.Y then
				return
			end

			dragging = true
			dragStart = input.Position
			startPos = mainGroup.Position

			if not isMinimized then
				TweenService:Create(mainGroup, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, defaultSize.X.Offset - 8, 0, defaultSize.Y.Offset - 5)
				}):Play()
			end

			local dragFadeInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			TweenService:Create(tabsCanvasGroup, dragFadeInfo, { GroupTransparency = 1 }):Play()
			TweenService:Create(userInfoCanvasGroup, dragFadeInfo, { GroupTransparency = 1 }):Play()
			TweenService:Create(contents, dragFadeInfo, { GroupTransparency = 1 }):Play()
			TweenService:Create(linesCanvasGroup, dragFadeInfo, { GroupTransparency = 1 }):Play()
			if bgWatermark then
				TweenService:Create(bgWatermark, dragFadeInfo, { TextTransparency = 0.25 }):Play()
			end

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if not isMinimized then
						TweenService:Create(mainGroup, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Size = defaultSize
						}):Play()
					end

					local dragEndInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					TweenService:Create(tabsCanvasGroup, dragEndInfo, { GroupTransparency = 0 }):Play()
					TweenService:Create(userInfoCanvasGroup, dragEndInfo, { GroupTransparency = 0 }):Play()
					TweenService:Create(contents, dragEndInfo, { GroupTransparency = 0 }):Play()
					TweenService:Create(linesCanvasGroup, dragEndInfo, { GroupTransparency = 0 }):Play()
					if bgWatermark then
						TweenService:Create(bgWatermark, dragEndInfo, { TextTransparency = 1 }):Play()
					end
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			targetPos = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		if dragging and not isFullscreen then
			mainGroup.Position = mainGroup.Position:Lerp(targetPos, math.clamp(dt * 20, 0, 1))
		end
	end)

	local Window = { Tabs = {}, ActiveTab = nil, ToggleKey = toggleKey, Tags = TagsObj }

	local pillTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local fadeTweenInfo = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	local function tween(object, info, properties)
		if typeof(object) == "Instance" then
			TweenService:Create(object, info, properties):Play()
		end
	end

	function Window:SelectTab(targetTab)
		if Window.ActiveTab == targetTab then return end

		Window.ActiveTab = targetTab

		activePill.Visible = true
		local targetY = targetTab.Frame.AbsolutePosition.Y - tabsCanvasGroup.AbsolutePosition.Y
		tween(activePill, pillTweenInfo, { Position = UDim2.new(0.5, 0, 0, targetY + 16) })

		for _, tab in ipairs(Window.Tabs) do
			if tab == targetTab then
				tween(tab.Label, fadeTweenInfo, { TextColor3 = Color3.fromRGB(255, 255, 255) })
				if tab.Icon then
					tween(tab.Icon, fadeTweenInfo, { ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0 })
				end

				tab.PageGroup.Visible = true
				tab.PageGroup.Position = UDim2.new(0, 0, 0, 8)
				tab.PageGroup.GroupTransparency = 1
				tween(tab.PageGroup, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, 0, 0, 0),
					GroupTransparency = 0
				})
			else
				tween(tab.Label, fadeTweenInfo, { TextColor3 = Color3.fromRGB(140, 148, 165) })
				if tab.Icon then
					tween(tab.Icon, fadeTweenInfo, { ImageColor3 = Color3.fromRGB(140, 148, 165), ImageTransparency = 0.3 })
				end

				tab.PageGroup.Visible = false
			end
		end
	end

	function Window:Tab(tabOptions)
		tabOptions = tabOptions or {}
		local tabTitle = tabOptions.Title or tabOptions.Name or "Tab"
		local tabIcon = tabOptions.Icon

		local tabFrame = Instance.new("Frame")
		tabFrame.Name = tabTitle .. "TabFrame"
		tabFrame.Size = UDim2.new(1, 0, 0, 32)
		tabFrame.BackgroundTransparency = 1
		tabFrame.ZIndex = 4
		tabFrame.Parent = tabs

		local clickBtn = Instance.new("TextButton")
		clickBtn.Name = "ClickDetector"
		clickBtn.Size = UDim2.new(1, 0, 1, 0)
		clickBtn.BackgroundTransparency = 1
		clickBtn.AutoButtonColor = false
		clickBtn.Text = ""
		clickBtn.ZIndex = 5
		clickBtn.Parent = tabFrame

		local textOffsetX = 12
		local iconImage

		if tabIcon then
			iconImage = Instance.new("ImageLabel")
			iconImage.Name = "Icon"
			iconImage.Size = UDim2.new(0, 16, 0, 16)
			iconImage.Position = UDim2.new(0, 12, 0.5, -8)
			iconImage.BackgroundTransparency = 1
			iconImage.Image = getIconAsset(tabIcon)
			iconImage.ImageColor3 = Color3.fromRGB(140, 148, 165)
			iconImage.ImageTransparency = 0.3
			iconImage.ZIndex = 5
			iconImage.Parent = tabFrame

			if not iconsLoaded and not string.find(tostring(tabIcon), "rbxassetid://") then
				task.spawn(function()
					repeat task.wait() until iconsLoaded or not iconImage:IsDescendantOf(game)
					if iconImage:IsDescendantOf(game) then
						iconImage.Image = getIconAsset(tabIcon)
					end
				end)
			end

			textOffsetX = 34
		end

		local tabText = Instance.new("TextLabel")
		tabText.Name = "Text"
		tabText.Size = UDim2.new(1, -(textOffsetX + 6), 1, 0)
		tabText.Position = UDim2.new(0, textOffsetX, 0, 0)
		tabText.BackgroundTransparency = 1
		tabText.Text = tabTitle
		tabText.TextColor3 = Color3.fromRGB(140, 148, 165)
		tabText.TextSize = 12
		tabText.Font = Enum.Font.GothamBold
		tabText.TextXAlignment = Enum.TextXAlignment.Left
		tabText.ZIndex = 5
		tabText.Parent = tabFrame

		local pageGroup = Instance.new("CanvasGroup")
		pageGroup.Name = tabTitle .. "PageGroup"
		pageGroup.Size = UDim2.new(1, 0, 1, 0)
		pageGroup.BackgroundTransparency = 1
		pageGroup.GroupTransparency = 0
		pageGroup.Visible = false
		pageGroup.ZIndex = 3
		pageGroup.Parent = contents

		local page = Instance.new("ScrollingFrame")
		page.Name = tabTitle .. "Page"
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.ScrollBarThickness = 2
		page.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
		page.ScrollBarImageTransparency = 0.85
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.ZIndex = 3
		page.Parent = pageGroup

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
			Frame = tabFrame,
			PageGroup = pageGroup,
			Page = page,
			Button = clickBtn,
			Label = tabText,
			Icon = iconImage
		}

		clickBtn.MouseEnter:Connect(function()
			if Window.ActiveTab ~= TabObject then
				tween(tabText, fadeTweenInfo, { TextColor3 = Color3.fromRGB(220, 225, 235) })
				if iconImage then
					tween(iconImage, fadeTweenInfo, { ImageTransparency = 0.1 })
				end
			end
		end)

		clickBtn.MouseLeave:Connect(function()
			if Window.ActiveTab ~= TabObject then
				tween(tabText, fadeTweenInfo, { TextColor3 = Color3.fromRGB(140, 148, 165) })
				if iconImage then
					tween(iconImage, fadeTweenInfo, { ImageTransparency = 0.3 })
				end
			end
		end)

		clickBtn.MouseButton1Click:Connect(function()
			Window:SelectTab(TabObject)
		end)

		table.insert(Window.Tabs, TabObject)

		if #Window.Tabs == 1 then
			task.defer(function()
				task.wait(0.05)
				Window:SelectTab(TabObject)
			end)
		end

		local function createContainer(parent, height)
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, height)
			frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			frame.BackgroundTransparency = 0.95
			frame.ZIndex = 4
			frame.Parent = parent

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(255, 255, 255)
			stroke.Thickness = 1
			stroke.Transparency = 0.92
			stroke.Parent = frame

			return frame, stroke
		end

		function TabObject:Section(secOptions)
			secOptions = secOptions or {}
			local secTitle = typeof(secOptions) == "string" and secOptions or (secOptions.Title or secOptions.Name or "Section")
			local secIcon = typeof(secOptions) == "table" and secOptions.Icon or nil

			local secFrame = Instance.new("Frame")
			secFrame.Size = UDim2.new(1, 0, 0, 0)
			secFrame.AutomaticSize = Enum.AutomaticSize.Y
			secFrame.BackgroundTransparency = 1
			secFrame.ZIndex = 4
			secFrame.Parent = page

			local secLayout = Instance.new("UIListLayout")
			secLayout.Padding = UDim.new(0, 6)
			secLayout.SortOrder = Enum.SortOrder.LayoutOrder
			secLayout.Parent = secFrame

			local secHeaderContainer = Instance.new("Frame")
			secHeaderContainer.Size = UDim2.new(1, 0, 0, 20)
			secHeaderContainer.BackgroundTransparency = 1
			secHeaderContainer.ZIndex = 4
			secHeaderContainer.Parent = secFrame

			local textOffsetX = 0
			if secIcon then
				local secIconImg = Instance.new("ImageLabel")
				secIconImg.Size = UDim2.new(0, 14, 0, 14)
				secIconImg.Position = UDim2.new(0, 0, 0.5, -7)
				secIconImg.BackgroundTransparency = 1
				secIconImg.Image = getIconAsset(secIcon)
				secIconImg.ImageColor3 = Color3.fromRGB(130, 140, 165)
				secIconImg.ZIndex = 4
				secIconImg.Parent = secHeaderContainer

				textOffsetX = 18
			end

			local secHeader = Instance.new("TextLabel")
			secHeader.Size = UDim2.new(1, -textOffsetX, 1, 0)
			secHeader.Position = UDim2.new(0, textOffsetX, 0, 0)
			secHeader.BackgroundTransparency = 1
			secHeader.Text = string.upper(secTitle)
			secHeader.TextColor3 = Color3.fromRGB(130, 140, 165)
			secHeader.TextSize = 10
			secHeader.Font = Enum.Font.GothamBold
			secHeader.TextXAlignment = Enum.TextXAlignment.Left
			secHeader.ZIndex = 4
			secHeader.Parent = secHeaderContainer

			local SectionObj = {}
			for k, v in pairs(TabObject) do
				if typeof(v) == "function" and k ~= "Section" then
					SectionObj[k] = function(self, opts)
						return v(TabObject, opts, secFrame)
					end
				end
			end
			return SectionObj
		end

		function TabObject:Paragraph(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or "Paragraph Title"
			local content = opts.Content or opts.Text or "Content goes here."

			local pFrame = createContainer(targetParent, 50)
			pFrame.AutomaticSize = Enum.AutomaticSize.Y

			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 4)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = pFrame

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 12)
			padding.PaddingRight = UDim.new(0, 12)
			padding.PaddingTop = UDim.new(0, 10)
			padding.PaddingBottom = UDim.new(0, 10)
			padding.Parent = pFrame

			local pTitle = Instance.new("TextLabel")
			pTitle.Size = UDim2.new(1, 0, 0, 15)
			pTitle.BackgroundTransparency = 1
			pTitle.Text = title
			pTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
			pTitle.TextSize = 12
			pTitle.Font = Enum.Font.GothamBold
			pTitle.TextXAlignment = Enum.TextXAlignment.Left
			pTitle.ZIndex = 5
			pTitle.Parent = pFrame

			local pText = Instance.new("TextLabel")
			pText.Size = UDim2.new(1, 0, 0, 0)
			pText.AutomaticSize = Enum.AutomaticSize.Y
			pText.BackgroundTransparency = 1
			pText.Text = content
			pText.TextColor3 = Color3.fromRGB(150, 160, 180)
			pText.TextSize = 11
			pText.Font = Enum.Font.Gotham
			pText.TextXAlignment = Enum.TextXAlignment.Left
			pText.TextWrapped = true
			pText.ZIndex = 5
			pText.Parent = pFrame

			return {
				SetTitle = function(_, newTitle) pTitle.Text = newTitle end,
				SetContent = function(_, newContent) pText.Text = newContent end
			}
		end

		function TabObject:Button(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local btnName = opts.Title or opts.Name or "Button"
			local callback = opts.Callback or function() end

			local btn, stroke = createContainer(targetParent, 38)
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -28, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = btnName
			label.TextColor3 = Color3.fromRGB(240, 245, 255)
			label.TextSize = 12
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.ZIndex = 5
			label.Parent = btn

			local clickBtn = Instance.new("TextButton")
			clickBtn.Size = UDim2.new(1, 0, 1, 0)
			clickBtn.BackgroundTransparency = 1
			clickBtn.Text = ""
			clickBtn.ZIndex = 6
			clickBtn.Parent = btn

			clickBtn.MouseButton1Click:Connect(callback)
			return btn
		end

		function TabObject:Toggle(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or "Toggle"
			local state = opts.Default or false
			local callback = opts.Callback or function() end

			local toggleContainer = createContainer(targetParent, 38)

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -70, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = title
			label.TextColor3 = Color3.fromRGB(240, 245, 255)
			label.TextSize = 12
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.ZIndex = 5
			label.Parent = toggleContainer

			local toggleFrame = Instance.new("Frame")
			toggleFrame.AnchorPoint = Vector2.new(1, 0.5)
			toggleFrame.Position = UDim2.new(1, -12, 0.5, 0)
			toggleFrame.Size = UDim2.new(0, 44, 0, 22)
			toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
			toggleFrame.BackgroundTransparency = 0.4
			toggleFrame.ZIndex = 5
			toggleFrame.Parent = toggleContainer

			local tfCorner = Instance.new("UICorner")
			tfCorner.CornerRadius = UDim.new(1, 0)
			tfCorner.Parent = toggleFrame

			local gradientOverlay = Instance.new("Frame")
			gradientOverlay.Size = UDim2.new(1, 0, 1, 0)
			gradientOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			gradientOverlay.BackgroundTransparency = state and 0 or 1
			gradientOverlay.ZIndex = 6
			gradientOverlay.Parent = toggleFrame

			local goCorner = Instance.new("UICorner")
			goCorner.CornerRadius = UDim.new(1, 0)
			goCorner.Parent = gradientOverlay

			local bar = Instance.new("Frame")
			bar.AnchorPoint = Vector2.new(0, 0.5)
			bar.Size = UDim2.new(0, 20, 0, 16)
			bar.Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
			bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			bar.ZIndex = 7
			bar.Parent = toggleFrame

			local barCorner = Instance.new("UICorner")
			barCorner.CornerRadius = UDim.new(1, 0)
			barCorner.Parent = bar

			local hitBox = Instance.new("TextButton")
			hitBox.Size = UDim2.new(1, 0, 1, 0)
			hitBox.BackgroundTransparency = 1
			hitBox.Text = ""
			hitBox.ZIndex = 10
			hitBox.Parent = toggleContainer

			local ToggleObj = { Value = state }
			hitBox.MouseButton1Click:Connect(function()
				ToggleObj.Value = not ToggleObj.Value
				bar.Position = ToggleObj.Value and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
				gradientOverlay.BackgroundTransparency = ToggleObj.Value and 0 or 1
				pcall(callback, ToggleObj.Value)
			end)

			return ToggleObj
		end

		return TabObject
	end

	return Window
end

return EclipseUI
