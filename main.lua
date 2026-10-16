local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

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

function EclipseUI:Notify(opts)
	opts = opts or {}
	local title = opts.Title or "Notification"
	local content = opts.Content or ""
	local duration = opts.Duration or 4
	local iconName = opts.Icon

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local notifGui = playerGui:FindFirstChild("EclipseNotifications")
	if not notifGui then
		notifGui = Instance.new("ScreenGui")
		notifGui.Name = "EclipseNotifications"
		notifGui.IgnoreGuiInset = true
		notifGui.ResetOnSpawn = false
		notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		notifGui.Parent = playerGui
	end

	local holder = notifGui:FindFirstChild("Holder")
	if not holder then
		holder = Instance.new("Frame")
		holder.Name = "Holder"
		holder.AnchorPoint = Vector2.new(1, 1)
		holder.Position = UDim2.new(1, -20, 1, -20)
		holder.Size = UDim2.new(0, 300, 1, 0)
		holder.BackgroundTransparency = 1

		local listLayout = Instance.new("UIListLayout")
		listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 8)
		listLayout.Parent = holder

		holder.Parent = notifGui
	end

	local wrapper = Instance.new("Frame")
	wrapper.Name = "NotifWrapper"
	wrapper.Size = UDim2.new(1, 0, 0, 58)
	wrapper.BackgroundTransparency = 1
	wrapper.ZIndex = 99
	wrapper.Parent = holder

	local cardGroup = Instance.new("CanvasGroup")
	cardGroup.Size = UDim2.new(1, 0, 1, 0)
	cardGroup.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
	cardGroup.BackgroundTransparency = 0.2
	cardGroup.GroupTransparency = 1
	cardGroup.Position = UDim2.new(0, 60, 0, 0)
	cardGroup.ZIndex = 100
	cardGroup.Parent = wrapper

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = cardGroup

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = Color3.fromRGB(255, 255, 255)
	cardStroke.Thickness = 1.5
	cardStroke.Transparency = 0.4
	cardStroke.Parent = cardGroup

	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 90, 120)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 90, 120))
	})
	strokeGradient.Parent = cardStroke

	local notifTimeAcc = 0
	local notifConn
	notifConn = RunService.RenderStepped:Connect(function(dt)
		if not cardGroup:IsDescendantOf(game) then
			notifConn:Disconnect()
			return
		end
		notifTimeAcc = notifTimeAcc + dt
		strokeGradient.Rotation = (notifTimeAcc * 60) % 360
	end)

	local textOffsetLeft = 14
	if iconName then
		local iconImg = Instance.new("ImageLabel")
		iconImg.Size = UDim2.new(0, 18, 0, 18)
		iconImg.Position = UDim2.new(0, 14, 0.5, -9)
		iconImg.BackgroundTransparency = 1
		iconImg.Image = getIconAsset(iconName)
		iconImg.ImageColor3 = Color3.fromRGB(200, 210, 230)
		iconImg.ZIndex = 101
		iconImg.Parent = cardGroup
		textOffsetLeft = 40
	end

	local textContainer = Instance.new("Frame")
	textContainer.Size = UDim2.new(1, -(textOffsetLeft + 14), 1, 0)
	textContainer.Position = UDim2.new(0, textOffsetLeft, 0, 0)
	textContainer.BackgroundTransparency = 1
	textContainer.ZIndex = 101
	textContainer.Parent = cardGroup

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 18)
	titleLabel.Position = UDim2.new(0, 0, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 12
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 101
	titleLabel.Parent = textContainer

	local contentLabel = Instance.new("TextLabel")
	contentLabel.Size = UDim2.new(1, 0, 0, 16)
	contentLabel.Position = UDim2.new(0, 0, 0, 28)
	contentLabel.BackgroundTransparency = 1
	contentLabel.Text = content
	contentLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
	contentLabel.TextSize = 11
	contentLabel.Font = Enum.Font.Gotham
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextTruncate = Enum.TextTruncate.AtEnd
	contentLabel.ZIndex = 101
	contentLabel.Parent = textContainer

	TweenService:Create(cardGroup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		GroupTransparency = 0,
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()

	task.spawn(function()
		task.wait(duration)
		if notifConn then notifConn:Disconnect() end
		if not cardGroup.Parent then return end
		
		local fadeOut = TweenService:Create(cardGroup, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			GroupTransparency = 1,
			Position = UDim2.new(0, 60, 0, 0)
		})
		fadeOut:Play()
		fadeOut.Completed:Wait()
		wrapper:Destroy()
	end)
end

function EclipseUI:CreateWindow(options)
	options = options or {}
	local windowName = options.Title or options.Name or "Eclipse UI"
	local windowSubtitle = options.Subtitle
	local windowIcon = options.Icon
	local initialToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
	local bgName = options.BgName
	local windowTags = options.Tags
	local loadAnimEnabled = options.LoadAnim or false
	local openButtonEnabled = options.OpenButton or false
	local userOptions = options.User

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EclipseUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local defaultSize = UDim2.new(0, 480, 0, 320)
	local defaultPos = UDim2.new(0.5, 0, 0.5, 0)

	local Window = { Tabs = {}, ActiveTab = nil, ToggleKey = initialToggleKey, Tags = {}, CleanupItems = {} }

	-- Config Manager Setup
	local registeredElements = {}
	local configsFolder = "EclipseUI/" .. windowName .. "/config/"

	pcall(function()
		if not isfolder("EclipseUI") then makefolder("EclipseUI") end
		if not isfolder("EclipseUI/" .. windowName) then makefolder("EclipseUI/" .. windowName) end
		if not isfolder(configsFolder) then makefolder(configsFolder) end
	end)

	local ConfigManager = {}

	function ConfigManager:CreateConfig(fileName)
		local configName = fileName or "default"
		local filePath = configsFolder .. configName .. ".json"

		local ConfigObject = {}

		function ConfigObject:Register(flag, element)
			if flag and element then
				registeredElements[flag] = element
			end
		end

		function ConfigObject:Save()
			local saveData = {}
			for flag, element in pairs(registeredElements) do
				pcall(function()
					if element.Value ~= nil then
						saveData[flag] = element.Value
					elseif element.Get ~= nil then
						saveData[flag] = element:Get()
					elseif element.GetText ~= nil then
						saveData[flag] = element:GetText()
					elseif element.GetSelected ~= nil then
						saveData[flag] = element:GetSelected()
					elseif element.GetKey ~= nil then
						saveData[flag] = tostring(element:GetKey())
					elseif element.GetColor ~= nil then
						local c = element:GetColor()
						saveData[flag] = {c.R, c.G, c.B}
					end
				end)
			end
			pcall(function()
				writefile(filePath, HttpService:JSONEncode(saveData))
			end)
		end

		function ConfigObject:Load()
			pcall(function()
				if isfile and isfile(filePath) then
					local content = readfile(filePath)
					local data = HttpService:JSONDecode(content)
					if typeof(data) == "table" then
						for flag, val in pairs(data) do
							local element = registeredElements[flag]
							if element then
								pcall(function()
									if element.Set then
										if typeof(val) == "table" and element.GetColor then
											element:Set(Color3.new(val[1], val[2], val[3]))
										else
											element:Set(val)
										end
									end
								end)
							end
						end
					end
				end
			end)
		end

		function ConfigObject:Delete()
			pcall(function()
				if isfile and isfile(filePath) then
					delfile(filePath)
				end
			end)
		end

		return ConfigObject
	end

	function ConfigManager:AllConfigs()
		local configs = {}
		pcall(function()
			if isfolder and isfolder(configsFolder) then
				local files = listfiles(configsFolder)
				for _, file in ipairs(files) do
					if string.sub(file, -5) == ".json" then
						local name = string.match(file, "([^/\\]+)%.json$")
						if name then
							table.insert(configs, name)
						end
					end
				end
			end
		end)
		return configs
	end

	Window.ConfigManager = ConfigManager

	function Window:Cleanup(item)
		table.insert(self.CleanupItems, item)
		return item
	end

	local mainGroup = Instance.new("CanvasGroup")
	mainGroup.Name = "MainGroup"
	mainGroup.AnchorPoint = Vector2.new(0.5, 0.5)
	mainGroup.Position = defaultPos
	mainGroup.Size = defaultSize
	mainGroup.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
	mainGroup.BackgroundTransparency = 0.2
	mainGroup.BorderSizePixel = 0
	mainGroup.GroupTransparency = loadAnimEnabled and 1 or 0
	mainGroup.ZIndex = 2
	mainGroup.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = mainGroup

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

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Thickness = 1.5
	uiStroke.Transparency = loadAnimEnabled and 1 or 0.4
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = mainGroup

	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 90, 120)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 90, 120))
	})
	strokeGradient.Parent = uiStroke

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
		if uiStroke.Transparency < 0.9 then
			uiStroke.Transparency = 0.35 + (pulse * 0.2)
		end
	end)

	local loaderGuiRef = nil
	local blurRef = nil

	if loadAnimEnabled then
		mainGroup.Visible = false

		local blur = Instance.new("BlurEffect")
		blur.Size = 0
		blur.Parent = Lighting
		blurRef = blur
		TweenService:Create(blur, TweenInfo.new(1.0, Enum.EasingStyle.Quint), {Size = 16}):Play()

		local loaderGui = Instance.new("ScreenGui")
		loaderGui.Name = "EclipseLoaderGui"
		loaderGui.IgnoreGuiInset = true
		loaderGui.ResetOnSpawn = false
		loaderGui.Parent = playerGui
		loaderGuiRef = loaderGui

		local overlay = Instance.new("Frame")
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
		overlay.BackgroundTransparency = 1
		overlay.BorderSizePixel = 0
		overlay.Parent = loaderGui

		TweenService:Create(overlay, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.3}):Play()

		local container = Instance.new("Frame")
		container.AnchorPoint = Vector2.new(0.5, 0.5)
		container.Position = UDim2.new(0.5, 0, 0.5, 0)
		container.Size = UDim2.new(0, 360, 0, 64)
		container.BackgroundTransparency = 1
		container.Parent = overlay

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0, 24)
		label.Text = "INITIALIZING " .. string.upper(windowName)
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextTransparency = 1
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.Parent = container

		local barBg = Instance.new("Frame")
		barBg.AnchorPoint = Vector2.new(0.5, 0.5)
		barBg.Position = UDim2.new(0.5, 0, 0.75, 0)
		barBg.Size = UDim2.new(0, 280, 0, 6)
		barBg.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
		barBg.BackgroundTransparency = 1
		barBg.BorderSizePixel = 0
		barBg.Parent = container

		local barBgCorner = Instance.new("UICorner")
		barBgCorner.CornerRadius = UDim.new(1, 0)
		barBgCorner.Parent = barBg

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(0, 0, 1, 0)
		bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bar.BackgroundTransparency = 1
		bar.BorderSizePixel = 0
		bar.Parent = barBg

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(1, 0)
		barCorner.Parent = bar

		local barGradient = Instance.new("UIGradient")
		barGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 130, 200)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		})
		barGradient.Parent = bar

		TweenService:Create(label, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
		TweenService:Create(barBg, TweenInfo.new(0.4), {BackgroundTransparency = 0.4}):Play()
		TweenService:Create(bar, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()

		local progress = 0
		local loadStartTime = tick()

		while not iconsLoaded and (tick() - loadStartTime < 4) do
			task.wait(0.05)
		end
		progress = 0.65

		TweenService:Create(bar, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
		task.wait(0.2)

		progress = 1
		TweenService:Create(bar, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, 0)}):Play()
		task.wait(0.4)

		TweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(barBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(bar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = 0}):Play()
		task.wait(0.4)

		loaderGui:Destroy()
		blur:Destroy()
		loaderGuiRef = nil
		blurRef = nil

		mainGroup.Visible = true
		TweenService:Create(mainGroup, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
		TweenService:Create(uiStroke, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = 0.4}):Play()
	end

	local windowVisible = true
	
	local function toggleWindowVisibility()
		windowVisible = not windowVisible
		local targetGroupTrans = windowVisible and 0 or 1
		local targetStrokeTrans = windowVisible and 0.4 or 1
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		if windowVisible then
			mainGroup.Visible = true
		end

		TweenService:Create(mainGroup, tweenInfo, { GroupTransparency = targetGroupTrans }):Play()
		local strokeTween = TweenService:Create(uiStroke, tweenInfo, { Transparency = targetStrokeTrans })
		strokeTween:Play()

		if not windowVisible then
			strokeTween.Completed:Connect(function()
				if not windowVisible then
					mainGroup.Visible = false
				end
			end)
		end
	end

	if openButtonEnabled then
		local openBtnGui = Instance.new("ScreenGui")
		openBtnGui.Name = "EclipseOpenButtonGui"
		openBtnGui.ResetOnSpawn = false
		openBtnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		openBtnGui.Parent = playerGui

		local openBtn = Instance.new("ImageButton")
		openBtn.Size = UDim2.new(0, 44, 0, 44)
		openBtn.Position = UDim2.new(0, 20, 0, 20)
		openBtn.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
		openBtn.BackgroundTransparency = 0.2
		openBtn.AutoButtonColor = false
		openBtn.Image = ""
		openBtn.Parent = openBtnGui

		local openCorner = Instance.new("UICorner")
		openCorner.CornerRadius = UDim.new(0, 10)
		openCorner.Parent = openBtn

		local openStroke = Instance.new("UIStroke")
		openStroke.Color = Color3.fromRGB(255, 255, 255)
		openStroke.Thickness = 1.5
		openStroke.Transparency = 0.4
		openStroke.Parent = openBtn

		local openIcon = Instance.new("ImageLabel")
		openIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		openIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
		openIcon.Size = UDim2.new(0, 20, 0, 20)
		openIcon.BackgroundTransparency = 1
		openIcon.Image = getIconAsset(windowIcon or "sparkles")
		openIcon.ImageColor3 = Color3.fromRGB(240, 245, 255)
		openIcon.Parent = openBtn

		if not iconsLoaded and windowIcon then
			task.spawn(function()
				repeat task.wait() until iconsLoaded or not openIcon:IsDescendantOf(game)
				if openIcon:IsDescendantOf(game) then
					openIcon.Image = getIconAsset(windowIcon)
				end
			end)
		end

		local openDragging = false
		local openDragStart = Vector2.zero
		local openStartPos = UDim2.new()
		local totalDelta = 0

		openBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				openDragging = false
				openDragStart = input.Position
				openStartPos = openBtn.Position
				totalDelta = 0

				local moveConn, endConn
				moveConn = UserInputService.InputChanged:Connect(function(moveInput)
					if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
						local delta = moveInput.Position - openDragStart
						if delta.Magnitude > 4 then
							openDragging = true
						end
						totalDelta = delta.Magnitude
						openBtn.Position = UDim2.new(
							openStartPos.X.Scale,
							openStartPos.X.Offset + delta.X,
							openStartPos.Y.Scale,
							openStartPos.Y.Offset + delta.Y
						)
					end
				end)

				endConn = UserInputService.InputEnded:Connect(function(endInput)
					if endInput.UserInputType == input.UserInputType then
						if moveConn then moveConn:Disconnect() end
						if endConn then endConn:Disconnect() end
						if totalDelta <= 5 then
							openDragging = false
							toggleWindowVisibility()
						end
					end
				end)
			end
		end)

		Window.OpenButtonGui = openBtnGui
		table.insert(Window.CleanupItems, openBtnGui)
	end

	local toggleKeyConn
	toggleKeyConn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Window.ToggleKey then
			toggleWindowVisibility()
		end
	end)

	local bodyGroup = Instance.new("CanvasGroup")
	bodyGroup.Name = "BodyGroup"
	bodyGroup.Size = UDim2.new(1, 0, 1, -46)
	bodyGroup.Position = UDim2.new(0, 0, 0, 46)
	bodyGroup.BackgroundTransparency = 1
	bodyGroup.GroupTransparency = 0
	bodyGroup.ZIndex = 3
	bodyGroup.Parent = mainGroup

	local showUser = true
	local userAnon = false
	local userCallback = function() end

	if userOptions ~= nil then
		if typeof(userOptions) == "table" then
			if userOptions.Enabled ~= nil then showUser = userOptions.Enabled end
			if userOptions.Anonymous ~= nil then userAnon = userOptions.Anonymous end
			if userOptions.Callback ~= nil then userCallback = userOptions.Callback end
		elseif typeof(userOptions) == "boolean" then
			showUser = userOptions
		end
	end

	local bodySizeOffset = showUser and 52 or 0

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
	headerLine1.Position = UDim2.new(0, 134, 0, 46)
	headerLine1.Size = UDim2.new(1, -134, 0, 1)
	headerLine1.BackgroundColor3 = lineDarkColor
	headerLine1.BackgroundTransparency = lineTransparency
	headerLine1.BorderSizePixel = 0
	headerLine1.ZIndex = 2
	headerLine1.Parent = linesCanvasGroup

	local headerLine2 = Instance.new("Frame")
	headerLine2.Position = UDim2.new(0, 0, 0, 46)
	headerLine2.Size = UDim2.new(0, 134, 0, 1)
	headerLine2.BackgroundColor3 = lineDarkColor
	headerLine2.BackgroundTransparency = lineTransparency
	headerLine2.BorderSizePixel = 0
	headerLine2.ZIndex = 2
	headerLine2.Parent = linesCanvasGroup

	local verticalLine = Instance.new("Frame")
	verticalLine.Position = UDim2.new(0, 134, 0, 46)
	verticalLine.Size = UDim2.new(0, 1, 1, -46)
	verticalLine.BackgroundColor3 = lineDarkColor
	verticalLine.BackgroundTransparency = lineTransparency
	verticalLine.BorderSizePixel = 0
	verticalLine.ZIndex = 2
	verticalLine.Parent = linesCanvasGroup

	local userLine
	if showUser then
		userLine = Instance.new("Frame")
		userLine.AnchorPoint = Vector2.new(0, 1)
		userLine.Position = UDim2.new(0, 0, 1, -52)
		userLine.Size = UDim2.new(0, 134, 0, 1)
		userLine.BackgroundColor3 = lineDarkColor
		userLine.BackgroundTransparency = lineTransparency
		userLine.BorderSizePixel = 0
		userLine.ZIndex = 2
		userLine.Parent = linesCanvasGroup
	end

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

		titleOffsetLeft = 42
	end

	local titleWrapper = Instance.new("Frame")
	titleWrapper.Name = "TitleWrapper"
	titleWrapper.AnchorPoint = Vector2.new(0, 0.5)
	titleWrapper.Position = UDim2.new(0, titleOffsetLeft, 0.5, 0)
	titleWrapper.Size = UDim2.new(1, -(titleOffsetLeft + 104), 0, 32)
	titleWrapper.BackgroundTransparency = 1
	titleWrapper.ZIndex = 4
	titleWrapper.Parent = header

	local headerMainLayout = Instance.new("UIListLayout")
	headerMainLayout.FillDirection = Enum.FillDirection.Horizontal
	headerMainLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	headerMainLayout.SortOrder = Enum.SortOrder.LayoutOrder
	headerMainLayout.Padding = UDim.new(0, 8)
	headerMainLayout.Parent = titleWrapper

	local textBlock = Instance.new("Frame")
	textBlock.Name = "TextBlock"
	textBlock.Size = UDim2.new(0, 0, 1, 0)
	textBlock.AutomaticSize = Enum.AutomaticSize.X
	textBlock.BackgroundTransparency = 1
	textBlock.LayoutOrder = 1
	textBlock.ZIndex = 4
	textBlock.Parent = titleWrapper

	local textLayout = Instance.new("UIListLayout")
	textLayout.FillDirection = Enum.FillDirection.Vertical
	textLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	textLayout.SortOrder = Enum.SortOrder.LayoutOrder
	textLayout.Padding = UDim.new(0, 1)
	textLayout.Parent = textBlock

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(0, 0, 0, 16)
	titleLabel.AutomaticSize = Enum.AutomaticSize.X
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = windowName
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.LayoutOrder = 1
	titleLabel.ZIndex = 4
	titleLabel.Parent = textBlock

	if windowSubtitle then
		local subtitleLabel = Instance.new("TextLabel")
		subtitleLabel.Name = "Subtitle"
		subtitleLabel.Size = UDim2.new(0, 0, 0, 13)
		subtitleLabel.AutomaticSize = Enum.AutomaticSize.X
		subtitleLabel.BackgroundTransparency = 1
		subtitleLabel.Text = windowSubtitle
		subtitleLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
		subtitleLabel.TextSize = 11
		subtitleLabel.Font = Enum.Font.Gotham
		subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		subtitleLabel.LayoutOrder = 2
		subtitleLabel.ZIndex = 4
		subtitleLabel.Parent = textBlock
	end

	local TagsObj = {}
	if windowTags and typeof(windowTags) == "table" then
		local tagsList = Instance.new("Frame")
		tagsList.Name = "TagsList"
		tagsList.Size = UDim2.new(0, 0, 1, 0)
		tagsList.AutomaticSize = Enum.AutomaticSize.X
		tagsList.BackgroundTransparency = 1
		tagsList.LayoutOrder = 2
		tagsList.ZIndex = 4
		tagsList.Parent = titleWrapper

		local tagsLayout = Instance.new("UIListLayout")
		tagsLayout.FillDirection = Enum.FillDirection.Horizontal
		tagsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		tagsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tagsLayout.Padding = UDim.new(0, 4)
		tagsLayout.Parent = tagsList

		for index, tagName in ipairs(windowTags) do
			local tagPill = Instance.new("Frame")
			tagPill.Size = UDim2.new(0, 0, 0, 20)
			tagPill.AutomaticSize = Enum.AutomaticSize.X
			tagPill.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
			tagPill.BackgroundTransparency = 0.4
			tagPill.ZIndex = 4
			tagPill.Parent = tagsList

			local tagCorner = Instance.new("UICorner")
			tagCorner.CornerRadius = UDim.new(1, 0)
			tagCorner.Parent = tagPill

			local tagStroke = Instance.new("UIStroke")
			tagStroke.Color = Color3.fromRGB(255, 255, 255)
			tagStroke.Thickness = 1
			tagStroke.Transparency = 0.82
			tagStroke.Parent = tagPill

			local tagGradient = Instance.new("UIGradient")
			tagGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 190, 210))
			})
			tagGradient.Rotation = 90
			tagGradient.Parent = tagPill

			local tagPadding = Instance.new("UIPadding")
			tagPadding.PaddingLeft = UDim.new(0, 8)
			tagPadding.PaddingRight = UDim.new(0, 8)
			tagPadding.Parent = tagPill

			local tagText = Instance.new("TextLabel")
			tagText.Size = UDim2.new(0, 0, 1, 0)
			tagText.AutomaticSize = Enum.AutomaticSize.X
			tagText.BackgroundTransparency = 1
			tagText.Text = tostring(tagName)
			tagText.TextColor3 = Color3.fromRGB(220, 228, 240)
			tagText.TextSize = 11
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
	Window.Tags = TagsObj

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
		if toggleKeyConn then
			toggleKeyConn:Disconnect()
		end

		for _, item in ipairs(Window.CleanupItems) do
			if typeof(item) == "Instance" then
				pcall(function() item:Destroy() end)
			elseif typeof(item) == "RBXScriptConnection" then
				pcall(function() item:Disconnect() end)
			elseif typeof(item) == "function" then
				pcall(item)
			end
		end

		local destroyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		TweenService:Create(mainGroup, destroyTweenInfo, {
			Size = UDim2.new(0, 380, 0, 240),
			BackgroundTransparency = 1
		}):Play()

		task.delay(0.25, function()
			screenGui:Destroy()
			local notifGui = playerGui:FindFirstChild("EclipseNotifications")
			if notifGui then
				notifGui:Destroy()
			end
			if loaderGuiRef and loaderGuiRef.Parent then
				loaderGuiRef:Destroy()
			end
			if blurRef and blurRef.Parent then
				blurRef:Destroy()
			end
		end)
	end)

	local tabsCanvasGroup = Instance.new("CanvasGroup")
	tabsCanvasGroup.Name = "TabsCanvasGroup"
	tabsCanvasGroup.Size = UDim2.new(0, 134, 1, -(52 + bodySizeOffset))
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

	if showUser then
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

		local realThumbnail = ""
		task.spawn(function()
			local content, isReady = Players:GetUserThumbnailAsync(
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size420x420
			)
			if isReady then
				realThumbnail = content
				avatarImage.Image = userAnon and "rbxassetid://11984980776" or realThumbnail
			end
		end)

		local displayNameLabel = Instance.new("TextLabel")
		displayNameLabel.Name = "DisplayName"
		displayNameLabel.Size = UDim2.new(1, -48, 0, 15)
		displayNameLabel.Position = UDim2.new(0, 44, 0, 8)
		displayNameLabel.BackgroundTransparency = 1
		displayNameLabel.Text = userAnon and "Eclipse" or LocalPlayer.DisplayName
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
		usernameLabel.Text = userAnon and "@EclipseUI" or ("@" .. LocalPlayer.Name)
		usernameLabel.TextColor3 = Color3.fromRGB(150, 158, 175)
		usernameLabel.TextSize = 10
		usernameLabel.Font = Enum.Font.GothamBold
		usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
		usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		usernameLabel.ZIndex = 4
		usernameLabel.Parent = userContentGroup

		local userHoverInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local userPressInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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
			userAnon = not userAnon
			displayNameLabel.Text = userAnon and "Eclipse" or LocalPlayer.DisplayName
			usernameLabel.Text = userAnon and "@EclipseUI" or ("@" .. LocalPlayer.Name)
			avatarImage.Image = userAnon and "rbxassetid://11984980776" or (realThumbnail ~= "" and realThumbnail or "rbxassetid://11984980776")
			pcall(userCallback)
		end)
	end

	local contents = Instance.new("CanvasGroup")
	contents.Name = "Contents"
	contents.AnchorPoint = Vector2.new(1, 1)
	contents.Position = UDim2.new(1, 0, 1, 0)
	contents.Size = UDim2.new(1, -135, 1, 0)
	contents.BackgroundTransparency = 1
	contents.GroupTransparency = 0
	contents.ZIndex = 3
	contents.Parent = bodyGroup

	local bgWatermark
	if bgName then
		bgWatermark = Instance.new("TextLabel")
		bgWatermark.Name = "BgWatermark"
		bgWatermark.AnchorPoint = Vector2.new(0.5, 0.5)
		bgWatermark.Position = UDim2.new(0.5, 0, 0.5, 0)
		bgWatermark.Size = UDim2.new(1, 0, 0, 50)
		bgWatermark.BackgroundTransparency = 1
		bgWatermark.Text = bgName
		bgWatermark.TextColor3 = Color3.fromRGB(255, 255, 255)
		bgWatermark.TextTransparency = 1
		bgWatermark.TextSize = 28
		bgWatermark.FontFace = Font.new("rbxassetid://12187375194", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		bgWatermark.TextXAlignment = Enum.TextXAlignment.Center
		bgWatermark.ZIndex = 1
		bgWatermark.Parent = mainGroup
	end

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
			if showUser then
				local userInfoGroup = bodyGroup:FindFirstChild("UserInfoCanvasGroup")
				if userInfoGroup then
					TweenService:Create(userInfoGroup, dragFadeInfo, { GroupTransparency = 1 }):Play()
				end
			end
			TweenService:Create(contents, dragFadeInfo, { GroupTransparency = 1 }):Play()
			TweenService:Create(linesCanvasGroup, dragFadeInfo, { GroupTransparency = 1 }):Play()
			if bgWatermark then
				TweenService:Create(bgWatermark, dragFadeInfo, { TextTransparency = 0.25 }):Play()
			end

			local endConn
			endConn = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == input.UserInputType then
					endConn:Disconnect()
					dragging = false
					if not isMinimized then
						TweenService:Create(mainGroup, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Size = defaultSize
						}):Play()
					end

					local dragEndInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					TweenService:Create(tabsCanvasGroup, dragEndInfo, { GroupTransparency = 0 }):Play()
					if showUser then
						local userInfoGroup = bodyGroup:FindFirstChild("UserInfoCanvasGroup")
						if userInfoGroup then
							TweenService:Create(userInfoGroup, dragEndInfo, { GroupTransparency = 0 }):Play()
						end
					end
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
			iconImage.Position = UDim2.new(0, 8, 0.5, -8)
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

			textOffsetX = 32
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
			Icon = iconImage,
			Select = function(self)
				Window:SelectTab(self)
			end
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

		clickBtn.MouseButton1Down:Connect(function()
			if Window.ActiveTab == TabObject then
				tween(activePill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, -26, 0, 28) })
			end
		end)

		clickBtn.MouseButton1Up:Connect(function()
			tween(activePill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, -20, 0, 32) })
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

		function TabObject:Space(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local spaceHeight = 0
			if typeof(opts) == "number" then
				spaceHeight = opts
			elseif typeof(opts) == "table" then
				spaceHeight = opts.Height or opts.Size or 0
			end

			local spaceFrame = Instance.new("Frame")
			spaceFrame.Name = "Space"
			spaceFrame.Size = UDim2.new(1, 0, 0, spaceHeight)
			spaceFrame.BackgroundTransparency = 1
			spaceFrame.ZIndex = 4
			spaceFrame.Parent = targetParent

			return spaceFrame
		end

		function TabObject:Divider(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local dividerHeight = 16
			if typeof(opts) == "number" then
				dividerHeight = opts
			elseif typeof(opts) == "table" then
				dividerHeight = opts.Height or opts.Size or 16
			end

			local dividerFrame = Instance.new("Frame")
			dividerFrame.Name = "Divider"
			dividerFrame.Size = UDim2.new(1, 0, 0, dividerHeight)
			dividerFrame.BackgroundTransparency = 1
			dividerFrame.ZIndex = 4
			dividerFrame.Parent = targetParent

			local line = Instance.new("Frame")
			line.Size = UDim2.new(1, 0, 0, 1)
			line.AnchorPoint = Vector2.new(0, 0.5)
			line.Position = UDim2.new(0, 0, 0.5, 0)
			line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			line.BackgroundTransparency = 0.88
			line.BorderSizePixel = 0
			line.ZIndex = 4
			line.Parent = dividerFrame

			return dividerFrame
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

				if not iconsLoaded and not string.find(tostring(secIcon), "rbxassetid://") then
					task.spawn(function()
						repeat task.wait() until iconsLoaded or not secIconImg:IsDescendantOf(game)
						if secIconImg:IsDescendantOf(game) then
							secIconImg.Image = getIconAsset(secIcon)
						end
					end)
				end

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

		function TabObject:GroupBox(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local boxTitle = opts.Title or "Group"
			local boxIcon = opts.Icon
			local isFoldable = opts.Foldable or false
			local isFolded = (opts.Default == false)

			local boxFrame = Instance.new("Frame")
			boxFrame.Size = UDim2.new(1, 0, 0, 0)
			boxFrame.AutomaticSize = Enum.AutomaticSize.Y
			boxFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
			boxFrame.BackgroundTransparency = 0.6
			boxFrame.ClipsDescendants = true
			boxFrame.ZIndex = 4
			boxFrame.Parent = targetParent

			local boxCorner = Instance.new("UICorner")
			boxCorner.CornerRadius = UDim.new(0, 8)
			boxCorner.Parent = boxFrame

			local boxStroke = Instance.new("UIStroke")
			boxStroke.Color = Color3.fromRGB(255, 255, 255)
			boxStroke.Thickness = 1
			boxStroke.Transparency = 0.88
			boxStroke.Parent = boxFrame

			local boxMainLayout = Instance.new("UIListLayout")
			boxMainLayout.Padding = UDim.new(0, 4)
			boxMainLayout.SortOrder = Enum.SortOrder.LayoutOrder
			boxMainLayout.Parent = boxFrame

			local boxPadding = Instance.new("UIPadding")
			boxPadding.PaddingLeft = UDim.new(0, 12)
			boxPadding.PaddingRight = UDim.new(0, 12)
			boxPadding.PaddingTop = UDim.new(0, 8)
			boxPadding.PaddingBottom = UDim.new(0, 8)
			boxPadding.Parent = boxFrame

			local contentContainer = Instance.new("Frame")
			contentContainer.Name = "ContentContainer"
			contentContainer.Size = UDim2.new(1, 0, 0, 0)
			contentContainer.AutomaticSize = Enum.AutomaticSize.Y
			contentContainer.BackgroundTransparency = 1
			contentContainer.ClipsDescendants = true
			contentContainer.Visible = not isFolded
			contentContainer.ZIndex = 4
			contentContainer.LayoutOrder = 1
			contentContainer.Parent = boxFrame

			local contentLayout = Instance.new("UIListLayout")
			contentLayout.Padding = UDim.new(0, 6)
			contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			contentLayout.Parent = contentContainer

			if boxTitle ~= "" or boxIcon or isFoldable then
				local headerContainer = Instance.new("Frame")
				headerContainer.Size = UDim2.new(1, 0, 0, 16)
				headerContainer.BackgroundTransparency = 1
				headerContainer.ZIndex = 5
				headerContainer.LayoutOrder = 0
				headerContainer.Parent = boxFrame

				local textOffsetX = 0
				if boxIcon then
					local iconImg = Instance.new("ImageLabel")
					iconImg.Size = UDim2.new(0, 14, 0, 14)
					iconImg.Position = UDim2.new(0, 0, 0.5, -7)
					iconImg.BackgroundTransparency = 1
					iconImg.Image = getIconAsset(boxIcon)
					iconImg.ImageColor3 = Color3.fromRGB(160, 170, 190)
					iconImg.ZIndex = 5
					iconImg.Parent = headerContainer

					if not iconsLoaded and not string.find(tostring(boxIcon), "rbxassetid://") then
						task.spawn(function()
							repeat task.wait() until iconsLoaded or not iconImg:IsDescendantOf(game)
							if iconImg:IsDescendantOf(game) then
								iconImg.Image = getIconAsset(boxIcon)
							end
						end)
					end

					textOffsetX = 18
				end

				local titleLabel = Instance.new("TextLabel")
				titleLabel.Size = UDim2.new(1, -textOffsetX - (isFoldable and 20 or 0), 1, 0)
				titleLabel.Position = UDim2.new(0, textOffsetX, 0, 0)
				titleLabel.BackgroundTransparency = 1
				titleLabel.Text = string.upper(boxTitle)
				titleLabel.TextColor3 = Color3.fromRGB(160, 170, 190)
				titleLabel.TextSize = 10
				titleLabel.Font = Enum.Font.GothamBold
				titleLabel.TextXAlignment = Enum.TextXAlignment.Left
				titleLabel.ZIndex = 5
				titleLabel.Parent = headerContainer

				if isFoldable then
					local arrowIcon = Instance.new("ImageLabel")
					arrowIcon.AnchorPoint = Vector2.new(1, 0.5)
					arrowIcon.Position = UDim2.new(1, 0, 0.5, 0)
					arrowIcon.Size = UDim2.new(0, 14, 0, 14)
					arrowIcon.BackgroundTransparency = 1
					arrowIcon.Image = getIconAsset("chevron-down")
					arrowIcon.ImageColor3 = Color3.fromRGB(160, 170, 190)
					arrowIcon.Rotation = isFolded and 180 or 0
					arrowIcon.ZIndex = 5
					arrowIcon.Parent = headerContainer

					if not iconsLoaded then
						task.spawn(function()
							repeat task.wait() until iconsLoaded or not arrowIcon:IsDescendantOf(game)
							if arrowIcon:IsDescendantOf(game) then
								arrowIcon.Image = getIconAsset("chevron-down")
							end
						end)
					end

					local clickBtn = Instance.new("TextButton")
					clickBtn.Size = UDim2.new(1, 0, 1, 0)
					clickBtn.BackgroundTransparency = 1
					clickBtn.Text = ""
					clickBtn.ZIndex = 6
					clickBtn.Parent = headerContainer

					local isAnimating = false
					clickBtn.MouseButton1Click:Connect(function()
						if isAnimating then return end
						isAnimating = true
						isFolded = not isFolded

						tween(arrowIcon, fadeTweenInfo, { Rotation = isFolded and 180 or 0 })

						local fullHeight = contentLayout.AbsoluteContentSize.Y + 6

						if isFolded then
							contentContainer.AutomaticSize = Enum.AutomaticSize.None
							contentContainer.Size = UDim2.new(1, 0, 0, fullHeight)
							
							local foldTween = TweenService:Create(contentContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
								Size = UDim2.new(1, 0, 0, 0)
							})
							foldTween:Play()
							foldTween.Completed:Wait()
							
							contentContainer.Visible = false
							isAnimating = false
						else
							contentContainer.Visible = true
							contentContainer.Size = UDim2.new(1, 0, 0, 0)
							contentContainer.AutomaticSize = Enum.AutomaticSize.None

							local unfoldTween = TweenService:Create(contentContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
								Size = UDim2.new(1, 0, 0, fullHeight)
							})
							unfoldTween:Play()
							unfoldTween.Completed:Wait()

							contentContainer.AutomaticSize = Enum.AutomaticSize.Y
							isAnimating = false
						end
					end)
				end
			end

			local GroupObj = {}
			for k, v in pairs(TabObject) do
				if typeof(v) == "function" and k ~= "GroupBox" then
					GroupObj[k] = function(self, elementOpts)
						return v(TabObject, elementOpts, contentContainer)
					end
				end
			end

			return GroupObj
		end

		function TabObject:Paragraph(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or "Paragraph Title"
			local content = opts.Content or opts.Text or "Paragraph content description goes here."

			local pFrame, pStroke = createContainer(targetParent, 50)
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
			local btnIcon = opts.Icon
			local callback = opts.Callback or function() end

			local btn, stroke = createContainer(targetParent, 38)
			btn.Name = btnName .. "Button"
			btn.BackgroundTransparency = 0.75
			btn.ClipsDescendants = true

			stroke.Transparency = 0.5

			local btnGradient = Instance.new("UIGradient")
			btnGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 85, 130)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 45, 65)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 85, 130))
			})
			btnGradient.Rotation = 0
			btnGradient.Parent = btn

			task.spawn(function()
				local tAcc = 0
				while btn:IsDescendantOf(game) do
					local dt = RunService.RenderStepped:Wait()
					tAcc = tAcc + dt
					btnGradient.Rotation = (tAcc * 50) % 360
				end
			end)

			local textRightOffset = -14
			if btnIcon then
				local iconImg = Instance.new("ImageLabel")
				iconImg.Size = UDim2.new(0, 16, 0, 16)
				iconImg.AnchorPoint = Vector2.new(1, 0.5)
				iconImg.Position = UDim2.new(1, -14, 0.5, 0)
				iconImg.BackgroundTransparency = 1
				iconImg.Image = getIconAsset(btnIcon)
				iconImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
				iconImg.ZIndex = 5
				iconImg.Parent = btn
				textRightOffset = -36

				if not iconsLoaded and not string.find(tostring(btnIcon), "rbxassetid://") then
					task.spawn(function()
						repeat task.wait() until iconsLoaded or not iconImg:IsDescendantOf(game)
						if iconImg:IsDescendantOf(game) then
							iconImg.Image = getIconAsset(btnIcon)
						end
					end)
				end
			end

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, textRightOffset, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = btnName
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
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

			clickBtn.MouseEnter:Connect(function()
				tween(btn, fadeTweenInfo, { BackgroundTransparency = 0.60 })
				tween(stroke, fadeTweenInfo, { Transparency = 0.30 })
			end)

			clickBtn.MouseLeave:Connect(function()
				tween(btn, fadeTweenInfo, { BackgroundTransparency = 0.75 })
				tween(stroke, fadeTweenInfo, { Transparency = 0.5 })
			end)

			clickBtn.MouseButton1Down:Connect(function()
				tween(btn, fadeTweenInfo, { BackgroundTransparency = 0.50 })
			end)

			clickBtn.MouseButton1Up:Connect(function()
				tween(btn, fadeTweenInfo, { BackgroundTransparency = 0.60 })
			end)

			clickBtn.MouseButton1Click:Connect(function()
				callback()
			end)

			return btn
		end

		function TabObject:ButtonRow(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local buttonsList = opts.Buttons or {}

			local rowFrame = Instance.new("Frame")
			rowFrame.Name = "ButtonRow"
			rowFrame.Size = UDim2.new(1, 0, 0, 32)
			rowFrame.BackgroundTransparency = 1
			rowFrame.ZIndex = 4
			rowFrame.Parent = targetParent

			local rowLayout = Instance.new("UIListLayout")
			rowLayout.FillDirection = Enum.FillDirection.Horizontal
			rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rowLayout.Padding = UDim.new(0, 6)
			rowLayout.Parent = rowFrame

			for _, bOpts in ipairs(buttonsList) do
				local bTitle = bOpts.Title or "Button"
				local bIcon = bOpts.Icon
				local bCallback = bOpts.Callback or function() end

				local btnFrame = Instance.new("Frame")
				btnFrame.Size = UDim2.new(0, 0, 1, 0)
				btnFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				btnFrame.BackgroundTransparency = 0.75
				btnFrame.ClipsDescendants = true
				btnFrame.ZIndex = 4
				btnFrame.Parent = rowFrame

				local flexItem = Instance.new("UIFlexItem")
				flexItem.FlexMode = Enum.UIFlexMode.Fill
				flexItem.Parent = btnFrame

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 8)
				corner.Parent = btnFrame

				local stroke = Instance.new("UIStroke")
				stroke.Color = Color3.fromRGB(255, 255, 255)
				stroke.Thickness = 1
				stroke.Transparency = 0.5
				stroke.Parent = btnFrame

				local btnGradient = Instance.new("UIGradient")
				btnGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 85, 130)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 45, 65)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 85, 130))
				})
				btnGradient.Rotation = 0
				btnGradient.Parent = btnFrame

				task.spawn(function()
					local tAcc = 0
					while btnFrame:IsDescendantOf(game) do
						local dt = RunService.RenderStepped:Wait()
						tAcc = tAcc + dt
						btnGradient.Rotation = (tAcc * 50) % 360
					end
				end)

				local textRightOffset = -10
				if bIcon then
					local iconImg = Instance.new("ImageLabel")
					iconImg.Size = UDim2.new(0, 14, 0, 14)
					iconImg.AnchorPoint = Vector2.new(1, 0.5)
					iconImg.Position = UDim2.new(1, -10, 0.5, 0)
					iconImg.BackgroundTransparency = 1
					iconImg.Image = getIconAsset(bIcon)
					iconImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
					iconImg.ZIndex = 5
					iconImg.Parent = btnFrame
					textRightOffset = -28

					if not iconsLoaded and not string.find(tostring(bIcon), "rbxassetid://") then
						task.spawn(function()
							repeat task.wait() until iconsLoaded or not iconImg:IsDescendantOf(game)
							if iconImg:IsDescendantOf(game) then
								iconImg.Image = getIconAsset(bIcon)
							end
						end)
					end
				end

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, textRightOffset, 1, 0)
				label.Position = UDim2.new(0, 10, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = bTitle
				label.TextColor3 = Color3.fromRGB(255, 255, 255)
				label.TextSize = 11
				label.Font = Enum.Font.GothamBold
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextTruncate = Enum.TextTruncate.AtEnd
				label.ZIndex = 5
				label.Parent = btnFrame

				local clickBtn = Instance.new("TextButton")
				clickBtn.Size = UDim2.new(1, 0, 1, 0)
				clickBtn.BackgroundTransparency = 1
				clickBtn.Text = ""
				clickBtn.ZIndex = 6
				clickBtn.Parent = btnFrame

				clickBtn.MouseEnter:Connect(function()
					tween(btnFrame, fadeTweenInfo, { BackgroundTransparency = 0.60 })
					tween(stroke, fadeTweenInfo, { Transparency = 0.30 })
				end)

				clickBtn.MouseLeave:Connect(function()
					tween(btnFrame, fadeTweenInfo, { BackgroundTransparency = 0.75 })
					tween(stroke, fadeTweenInfo, { Transparency = 0.5 })
				end)

				clickBtn.MouseButton1Down:Connect(function()
					tween(btnFrame, fadeTweenInfo, { BackgroundTransparency = 0.50 })
				end)

				clickBtn.MouseButton1Up:Connect(function()
					tween(btnFrame, fadeTweenInfo, { BackgroundTransparency = 0.60 })
				end)

				clickBtn.MouseButton1Click:Connect(function()
					bCallback()
				end)
			end

			return rowFrame
		end

		function TabObject:Input(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or opts.Name or "Input"
			local default = opts.Default or ""
			local placeholder = opts.Placeholder or "Enter text..."
			local callback = opts.Callback or function() end
			local flag = opts.Flag

			local inputContainer, stroke = createContainer(targetParent, 38)

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -150, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = title
			label.TextColor3 = Color3.fromRGB(240, 245, 255)
			label.TextSize = 12
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.ZIndex = 5
			label.Parent = inputContainer

			local textBox = Instance.new("TextBox")
			textBox.AnchorPoint = Vector2.new(1, 0.5)
			textBox.Position = UDim2.new(1, -12, 0.5, 0)
			textBox.Size = UDim2.new(0, 130, 0, 24)
			textBox.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
			textBox.BackgroundTransparency = 0.2
			textBox.Text = tostring(default)
			textBox.PlaceholderText = placeholder
			textBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
			textBox.TextColor3 = Color3.fromRGB(230, 238, 250)
			textBox.TextSize = 11
			textBox.Font = Enum.Font.GothamMedium
			textBox.TextYAlignment = Enum.TextYAlignment.Center
			textBox.ClearTextOnFocus = false
			textBox.ZIndex = 6
			textBox.Parent = inputContainer

			local tbCorner = Instance.new("UICorner")
			tbCorner.CornerRadius = UDim.new(0, 6)
			tbCorner.Parent = textBox

			local tbStroke = Instance.new("UIStroke")
			tbStroke.Color = Color3.fromRGB(255, 255, 255)
			tbStroke.Thickness = 1
			tbStroke.Transparency = 0.75
			tbStroke.Parent = textBox

			local tbPadding = Instance.new("UIPadding")
			tbPadding.PaddingLeft = UDim.new(0, 8)
			tbPadding.PaddingRight = UDim.new(0, 8)
			tbPadding.Parent = textBox

			textBox.Focused:Connect(function()
				tween(tbStroke, TweenInfo.new(0.15), { Transparency = 0.2 })
			end)

			textBox.FocusLost:Connect(function(enterPressed)
				tween(tbStroke, TweenInfo.new(0.15), { Transparency = 0.75 })
				pcall(callback, textBox.Text)
			end)

			local obj = {
				GetText = function() return textBox.Text end,
				Set = function(_, val)
					textBox.Text = tostring(val)
					pcall(callback, textBox.Text)
				end
			}

			if flag then
				registeredElements[flag] = obj
			end

			return obj
		end

		function TabObject:Colorpicker(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or opts.Name or "Colorpicker"
			local defaultColor = opts.Default or Color3.fromRGB(255, 255, 255)
			local defaultAlpha = opts.Alpha or 1
			local callback = opts.Callback or function() end
			local flag = opts.Flag

			local cpContainer, stroke = createContainer(targetParent, 38)

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -60, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = title
			label.TextColor3 = Color3.fromRGB(240, 245, 255)
			label.TextSize = 12
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.ZIndex = 5
			label.Parent = cpContainer

			local colorPreview = Instance.new("TextButton")
			colorPreview.AnchorPoint = Vector2.new(1, 0.5)
			colorPreview.Position = UDim2.new(1, -12, 0.5, 0)
			colorPreview.Size = UDim2.new(0, 36, 0, 20)
			colorPreview.BackgroundColor3 = defaultColor
			colorPreview.AutoButtonColor = false
			colorPreview.Text = ""
			colorPreview.ZIndex = 6
			colorPreview.Parent = cpContainer

			local cpCorner = Instance.new("UICorner")
			cpCorner.CornerRadius = UDim.new(0, 6)
			cpCorner.Parent = colorPreview

			local cpStroke = Instance.new("UIStroke")
			cpStroke.Color = Color3.fromRGB(255, 255, 255)
			cpStroke.Thickness = 1
			cpStroke.Transparency = 0.6
			cpStroke.Parent = colorPreview

			local currentColor = defaultColor
			local currentAlpha = defaultAlpha
			local drawerFrame = nil
			local isDrawerOpen = false

			local function closeDrawer()
				if not drawerFrame or not drawerFrame.Parent then return end
				isDrawerOpen = false
				
				local tw = TweenService:Create(drawerFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
					GroupTransparency = 1
				})
				tw:Play()
				tw.Completed:Wait()
				if drawerFrame then
					drawerFrame:Destroy()
					drawerFrame = nil
				end
			end

			colorPreview.MouseButton1Click:Connect(function()
				if isDrawerOpen and drawerFrame and drawerFrame.Parent then
					closeDrawer()
					return
				end
				isDrawerOpen = true

				local h, s, v = currentColor:ToHSV()
				local tempH, tempS, tempV, tempA = h, s, v, currentAlpha

				-- Parented to screenGui so it sits outside the main window boundary without getting clipped
				drawerFrame = Instance.new("CanvasGroup")
				drawerFrame.Name = "ColorpickerDrawer"
				drawerFrame.GroupTransparency = 1
				drawerFrame.BackgroundColor3 = mainGroup.BackgroundColor3
				drawerFrame.BackgroundTransparency = mainGroup.BackgroundTransparency
				drawerFrame.ZIndex = 100
				drawerFrame.Parent = screenGui

				local dCorner = Instance.new("UICorner", drawerFrame)
				dCorner.CornerRadius = UDim.new(0, 10)

				-- Animated Gradient Border Stroke matching Main Window style
				local dStroke = Instance.new("UIStroke", drawerFrame)
				dStroke.Color = Color3.fromRGB(255, 255, 255)
				dStroke.Thickness = 1.5
				dStroke.Transparency = 0.4

				local strokeGradient = Instance.new("UIGradient", dStroke)
				strokeGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 90, 120)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 90, 120))
				})

				-- Position, height, and visibility sync loop
				local trackConn
				trackConn = RunService.RenderStepped:Connect(function()
					if not drawerFrame or not drawerFrame.Parent or not mainGroup:IsDescendantOf(game) then
						if trackConn then trackConn:Disconnect() end
						return
					end

					if not mainGroup.Visible or mainGroup.GroupTransparency >= 0.99 then
						closeDrawer()
						if trackConn then trackConn:Disconnect() end
						return
					end

					strokeGradient.Rotation = (tick() * 60) % 360
					
					local mainPos = mainGroup.AbsolutePosition
					local mainSize = mainGroup.AbsoluteSize
					
					drawerFrame.Size = UDim2.new(0, 172, 0, mainSize.Y)
					drawerFrame.Position = UDim2.new(0, mainPos.X + mainSize.X + 8, 0, mainPos.Y)
				end)

				-- Drawer Header Title & Lucide X Close Button
				local dTitle = Instance.new("TextLabel", drawerFrame)
				dTitle.Size = UDim2.new(1, -36, 0, 38)
				dTitle.Position = UDim2.new(0, 14, 0, 0)
				dTitle.BackgroundTransparency = 1
				dTitle.Text = title
				dTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
				dTitle.TextSize = 12
				dTitle.Font = Enum.Font.GothamBold
				dTitle.TextXAlignment = Enum.TextXAlignment.Left
				dTitle.ZIndex = 101

				local closeBtn = Instance.new("ImageButton", drawerFrame)
				closeBtn.AnchorPoint = Vector2.new(1, 0.5)
				closeBtn.Position = UDim2.new(1, -12, 0, 19)
				closeBtn.Size = UDim2.new(0, 16, 0, 16)
				closeBtn.BackgroundTransparency = 1
				closeBtn.Image = "rbxassetid://10709791437" -- Lucide X Icon
				closeBtn.ImageColor3 = Color3.fromRGB(160, 170, 190)
				closeBtn.ZIndex = 101

				closeBtn.MouseButton1Click:Connect(closeDrawer)

				-- Header Divider Line matching Main Window style
				local headerDivider = Instance.new("Frame", drawerFrame)
				headerDivider.Position = UDim2.new(0, 0, 0, 38)
				headerDivider.Size = UDim2.new(1, 0, 0, 1)
				headerDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				headerDivider.BackgroundTransparency = 0.85
				headerDivider.BorderSizePixel = 0
				headerDivider.ZIndex = 101

				-- 1. Saturation & Value Box
				local svBox = Instance.new("Frame", drawerFrame)
				svBox.Position = UDim2.new(0, 14, 0, 52)
				svBox.Size = UDim2.new(0, 104, 0, 104)
				svBox.BackgroundColor3 = Color3.fromHSV(tempH, 1, 1)
				svBox.BorderSizePixel = 0
				svBox.ZIndex = 101
				Instance.new("UICorner", svBox).CornerRadius = UDim.new(0, 6)

				local satGrad = Instance.new("Frame", svBox)
				satGrad.Size = UDim2.new(1, 0, 1, 0)
				satGrad.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				satGrad.BorderSizePixel = 0
				satGrad.ZIndex = 102
				Instance.new("UICorner", satGrad).CornerRadius = UDim.new(0, 6)
				local sGr = Instance.new("UIGradient", satGrad)
				sGr.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})

				local valGrad = Instance.new("Frame", svBox)
				valGrad.Size = UDim2.new(1, 0, 1, 0)
				valGrad.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				valGrad.BorderSizePixel = 0
				valGrad.ZIndex = 103
				Instance.new("UICorner", valGrad).CornerRadius = UDim.new(0, 6)
				local vGr = Instance.new("UIGradient", valGrad)
				vGr.Rotation = 90
				vGr.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})

				local svKnob = Instance.new("Frame", svBox)
				svKnob.AnchorPoint = Vector2.new(0.5, 0.5)
				svKnob.Size = UDim2.new(0, 10, 0, 10)
				svKnob.Position = UDim2.new(tempS, 0, 1 - tempV, 0)
				svKnob.BackgroundColor3 = Color3.fromHSV(tempH, tempS, tempV)
				svKnob.ZIndex = 105
				Instance.new("UICorner", svKnob).CornerRadius = UDim.new(1, 0)
				Instance.new("UIStroke", svKnob).Color = Color3.fromRGB(255, 255, 255)

				-- 2. Hue Bar
				local hueBar = Instance.new("Frame", drawerFrame)
				hueBar.Position = UDim2.new(0, 124, 0, 52)
				hueBar.Size = UDim2.new(0, 10, 0, 104)
				hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				hueBar.BorderSizePixel = 0
				hueBar.ZIndex = 101
				Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1, 0)

				local hGr = Instance.new("UIGradient", hueBar)
				hGr.Rotation = 90
				hGr.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
				})

				local hueKnob = Instance.new("Frame", hueBar)
				hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
				hueKnob.Position = UDim2.new(0.5, 0, tempH, 0)
				hueKnob.Size = UDim2.new(0, 12, 0, 12)
				hueKnob.BackgroundColor3 = Color3.fromHSV(tempH, 1, 1)
				hueKnob.ZIndex = 104
				Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(1, 0)
				Instance.new("UIStroke", hueKnob).Color = Color3.fromRGB(255, 255, 255)

				-- 3. Inputs (Hex & RGB)
				local inputStartX = 14
				local function createInputRow(labelName, defaultVal, yPos)
					local box = Instance.new("TextBox", drawerFrame)
					box.Position = UDim2.new(0, inputStartX, 0, yPos)
					box.Size = UDim2.new(0, 78, 0, 20)
					box.BackgroundColor3 = Color3.fromRGB(22, 27, 38)
					box.BackgroundTransparency = 0.1
					box.Text = tostring(defaultVal)
					box.TextColor3 = Color3.fromRGB(240, 245, 250)
					box.TextSize = 10
					box.Font = Enum.Font.GothamMedium
					box.ZIndex = 101
					Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

					local bSt = Instance.new("UIStroke", box)
					bSt.Color = Color3.fromRGB(255, 255, 255)
					bSt.Transparency = 0.55

					box.Focused:Connect(function()
						TweenService:Create(bSt, TweenInfo.new(0.15), { Transparency = 0.2 }):Play()
					end)
					box.FocusLost:Connect(function()
						TweenService:Create(bSt, TweenInfo.new(0.15), { Transparency = 0.55 }):Play()
					end)

					local tag = Instance.new("TextLabel", drawerFrame)
					tag.Position = UDim2.new(0, inputStartX + 82, 0, yPos)
					tag.Size = UDim2.new(0, 62, 0, 20)
					tag.BackgroundTransparency = 1
					tag.Text = labelName
					tag.TextColor3 = Color3.fromRGB(130, 140, 160)
					tag.TextSize = 10
					tag.Font = Enum.Font.Gotham
					tag.TextXAlignment = Enum.TextXAlignment.Left
					tag.ZIndex = 101

					return box
				end

				local hexBox = createInputRow("Hex", "#" .. currentColor:ToHex(), 164)
				local rBox = createInputRow("Red", math.floor(currentColor.R * 255 + 0.5), 188)
				local gBox = createInputRow("Green", math.floor(currentColor.G * 255 + 0.5), 212)
				local bBox = createInputRow("Blue", math.floor(currentColor.B * 255 + 0.5), 236)

				local function updatePicker(skipInputs)
					local activeColor = Color3.fromHSV(tempH, tempS, tempV)
					svBox.BackgroundColor3 = Color3.fromHSV(tempH, 1, 1)
					svKnob.Position = UDim2.new(tempS, 0, 1 - tempV, 0)
					svKnob.BackgroundColor3 = activeColor
					hueKnob.Position = UDim2.new(0.5, 0, tempH, 0)
					hueKnob.BackgroundColor3 = Color3.fromHSV(tempH, 1, 1)

					if not skipInputs then
						hexBox.Text = "#" .. activeColor:ToHex()
						rBox.Text = tostring(math.floor(activeColor.R * 255 + 0.5))
						gBox.Text = tostring(math.floor(activeColor.G * 255 + 0.5))
						bBox.Text = tostring(math.floor(activeColor.B * 255 + 0.5))
					end
				end

				-- Drag Handlers
				local svDrag = false
				svBox.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						svDrag = true
						local function updateSV(pos)
							tempS = math.clamp((pos.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
							tempV = math.clamp(1 - ((pos.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y), 0, 1)
							updatePicker()
						end
						updateSV(input.Position)
						local mConn = UserInputService.InputChanged:Connect(function(m)
							if svDrag and (m.UserInputType == Enum.UserInputType.MouseMovement or m.UserInputType == Enum.UserInputType.Touch) then
								updateSV(m.Position)
							end
						end)
						local eConn
						eConn = UserInputService.InputEnded:Connect(function(e)
							if e.UserInputType == input.UserInputType then
								svDrag = false
								if mConn then mConn:Disconnect() end
								if eConn then eConn:Disconnect() end
							end
						end)
					end
				end)

				local hueDrag = false
				hueBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						hueDrag = true
						local function updateH(pos)
							tempH = math.clamp((pos.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
							updatePicker()
						end
						updateH(input.Position)
						local mConn = UserInputService.InputChanged:Connect(function(m)
							if hueDrag and (m.UserInputType == Enum.UserInputType.MouseMovement or m.UserInputType == Enum.UserInputType.Touch) then
								updateH(m.Position)
							end
						end)
						local eConn
						eConn = UserInputService.InputEnded:Connect(function(e)
							if e.UserInputType == input.UserInputType then
								hueDrag = false
								if mConn then mConn:Disconnect() end
								if eConn then eConn:Disconnect() end
							end
						end)
					end
				end)

				hexBox.FocusLost:Connect(function()
					local cleanHex = hexBox.Text:gsub("#", "")
					local success, parsed = pcall(function() return Color3.fromHex(cleanHex) end)
					if success and parsed then
						tempH, tempS, tempV = parsed:ToHSV()
						updatePicker()
					end
				end)

				local function rgbLost()
					local r = math.clamp(tonumber(rBox.Text) or 0, 0, 255)
					local g = math.clamp(tonumber(gBox.Text) or 0, 0, 255)
					local b = math.clamp(tonumber(bBox.Text) or 0, 0, 255)
					tempH, tempS, tempV = Color3.fromRGB(r, g, b):ToHSV()
					updatePicker()
				end
				rBox.FocusLost:Connect(rgbLost)
				gBox.FocusLost:Connect(rgbLost)
				bBox.FocusLost:Connect(rgbLost)

				-- Apply Button at the bottom
				local applyBtn = Instance.new("TextButton", drawerFrame)
				applyBtn.AnchorPoint = Vector2.new(0, 1)
				applyBtn.Position = UDim2.new(0, 14, 1, -14)
				applyBtn.Size = UDim2.new(1, -28, 0, 28)
				applyBtn.BackgroundColor3 = Color3.fromRGB(65, 85, 130)
				applyBtn.BackgroundTransparency = 0.2
				applyBtn.Text = "Apply"
				applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				applyBtn.TextSize = 11
				applyBtn.Font = Enum.Font.GothamBold
				applyBtn.ZIndex = 101
				Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)

				applyBtn.MouseButton1Click:Connect(function()
					currentColor = Color3.fromHSV(tempH, tempS, tempV)
					currentAlpha = tempA
					colorPreview.BackgroundColor3 = currentColor
					pcall(callback, currentColor, currentAlpha)
					closeDrawer()
				end)

				-- Smooth Appearance Tween Animation
				TweenService:Create(drawerFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					GroupTransparency = 0
				}):Play()

				updatePicker()
			end)

			local obj = {
				GetColor = function() return currentColor end,
				GetAlpha = function() return currentAlpha end,
				Set = function(_, col, alpha)
					currentColor = col or currentColor
					currentAlpha = alpha or currentAlpha
					colorPreview.BackgroundColor3 = currentColor
					pcall(callback, currentColor, currentAlpha)
				end
			}

			if flag then
				registeredElements[flag] = obj
			end

			return obj
		end
		
		function TabObject:Toggle(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or opts.Name or "Toggle"
			local state = opts.Default or false
			local callback = opts.Callback or function() end
			local flag = opts.Flag

			local toggleContainer, stroke = createContainer(targetParent, 38)

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
			toggleFrame.Name = "ToggleFrame"
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
			gradientOverlay.Name = "GradientOverlay"
			gradientOverlay.Size = UDim2.new(1, 0, 1, 0)
			gradientOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			gradientOverlay.BackgroundTransparency = state and 0 or 1
			gradientOverlay.ZIndex = 6
			gradientOverlay.Parent = toggleFrame

			local goCorner = Instance.new("UICorner")
			goCorner.CornerRadius = UDim.new(1, 0)
			goCorner.Parent = gradientOverlay

			local toggleGradient = Instance.new("UIGradient")
			toggleGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 218, 230)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 160, 175))
			})
			toggleGradient.Rotation = 45
			toggleGradient.Parent = gradientOverlay

			local tfStroke = Instance.new("UIStroke")
			tfStroke.Color = Color3.fromRGB(255, 255, 255)
			tfStroke.Thickness = 1
			tfStroke.Transparency = state and 0.5 or 0.8
			tfStroke.Parent = toggleFrame

			local bar = Instance.new("Frame")
			bar.Name = "Bar"
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
			hitBox.Name = "Hitbox"
			hitBox.Size = UDim2.new(1, 0, 1, 0)
			hitBox.BackgroundTransparency = 1
			hitBox.Text = ""
			hitBox.ZIndex = 10
			hitBox.Parent = toggleContainer

			local ToggleObj = { Value = state }

			local function updateToggle(newState, animate)
				ToggleObj.Value = newState
				local targetPos = newState and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
				local targetOverlayTrans = newState and 0 or 1
				local targetStrokeTrans = newState and 0.5 or 0.8

				local info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				if animate then
					tween(bar, info, { Position = targetPos })
					tween(gradientOverlay, info, { BackgroundTransparency = targetOverlayTrans })
					tween(tfStroke, info, { Transparency = targetStrokeTrans })
				else
					bar.Position = targetPos
					gradientOverlay.BackgroundTransparency = targetOverlayTrans
					tfStroke.Transparency = targetStrokeTrans
				end

				pcall(callback, newState)
			end

			hitBox.MouseEnter:Connect(function()
				tween(toggleContainer, fadeTweenInfo, { BackgroundTransparency = 0.90 })
				tween(stroke, fadeTweenInfo, { Transparency = 0.85 })
			end)

			hitBox.MouseLeave:Connect(function()
				tween(toggleContainer, fadeTweenInfo, { BackgroundTransparency = 0.95 })
				tween(stroke, fadeTweenInfo, { Transparency = 0.92 })
			end)

			hitBox.MouseButton1Click:Connect(function()
				updateToggle(not ToggleObj.Value, true)
			end)

			ToggleObj.Set = function(_, val)
				updateToggle(val, true)
			end

			if flag then
				registeredElements[flag] = ToggleObj
			end

			return ToggleObj
		end

		function TabObject:Slider(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or opts.Name or "Slider"
			local min = opts.Min or 0
			local max = opts.Max or 100
			local default = math.clamp(opts.Default or min, min, max)
			local callback = opts.Callback or function() end
			local flag = opts.Flag

			local sliderContainer, stroke = createContainer(targetParent, 56)

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -84, 0, 18)
			label.Position = UDim2.new(0, 14, 0, 10)
			label.BackgroundTransparency = 1
			label.Text = title
			label.TextColor3 = Color3.fromRGB(240, 245, 255)
			label.TextSize = 12
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.ZIndex = 5
			label.Parent = sliderContainer

			local valBox = Instance.new("TextBox")
			valBox.AnchorPoint = Vector2.new(1, 0)
			valBox.Position = UDim2.new(1, -12, 0, 8)
			valBox.Size = UDim2.new(0, 56, 0, 22)
			valBox.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
			valBox.BackgroundTransparency = 0.2
			valBox.Text = tostring(default)
			valBox.TextColor3 = Color3.fromRGB(230, 238, 250)
			valBox.TextSize = 11
			valBox.Font = Enum.Font.GothamMedium
			valBox.TextYAlignment = Enum.TextYAlignment.Center
			valBox.ClearTextOnFocus = false
			valBox.ZIndex = 6
			valBox.Parent = sliderContainer

			local valBoxCorner = Instance.new("UICorner")
			valBoxCorner.CornerRadius = UDim.new(0, 6)
			valBoxCorner.Parent = valBox

			local valBoxStroke = Instance.new("UIStroke")
			valBoxStroke.Color = Color3.fromRGB(255, 255, 255)
			valBoxStroke.Thickness = 1
			valBoxStroke.Transparency = 0.75
			valBoxStroke.Parent = valBox

			local track = Instance.new("Frame")
			track.AnchorPoint = Vector2.new(0.5, 0)
			track.Position = UDim2.new(0.5, 0, 0, 38)
			track.Size = UDim2.new(1, -32, 0, 6)
			track.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
			track.BorderSizePixel = 0
			track.ZIndex = 5
			track.Parent = sliderContainer

			local trackCorner = Instance.new("UICorner")
			trackCorner.CornerRadius = UDim.new(1, 0)
			trackCorner.Parent = track

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			fill.BorderSizePixel = 0
			fill.ZIndex = 6
			fill.Parent = track

			local fillCorner = Instance.new("UICorner")
			fillCorner.CornerRadius = UDim.new(1, 0)
			fillCorner.Parent = fill

			local fillGradient = Instance.new("UIGradient")
			fillGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 210, 225)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 160, 175))
			})
			fillGradient.Parent = fill

			local thumb = Instance.new("Frame")
			thumb.AnchorPoint = Vector2.new(0.5, 0.5)
			thumb.Position = UDim2.new(1, 0, 0.5, 0)
			thumb.Size = UDim2.new(0, 16, 0, 12)
			thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			thumb.ZIndex = 7
			thumb.Parent = fill

			local thumbCorner = Instance.new("UICorner")
			thumbCorner.CornerRadius = UDim.new(1, 0)
			thumbCorner.Parent = thumb

			local thumbStroke = Instance.new("UIStroke")
			thumbStroke.Color = Color3.fromRGB(255, 255, 255)
			thumbStroke.Thickness = 1.5
			thumbStroke.Transparency = 0.2
			thumbStroke.Parent = thumb

			local isDragging = false
			local connectionMove, connectionEnd

			local function updateSliderVal(value)
				value = math.clamp(value, min, max)
				local percentage = (value - min) / (max - min)
				valBox.Text = tostring(value)
				fill.Size = UDim2.new(percentage, 0, 1, 0)
			end

			local function updateSlider(inputX)
				local absolutePos = track.AbsolutePosition.X
				local absoluteSize = track.AbsoluteSize.X
				local percentage = math.clamp((inputX - absolutePos) / absoluteSize, 0, 1)
				local value = math.floor(min + (max - min) * percentage + 0.5)
				updateSliderVal(value)
			end

			valBox.Focused:Connect(function()
				tween(valBoxStroke, TweenInfo.new(0.15), { Transparency = 0.2 })
			end)

			valBox.FocusLost:Connect(function()
				tween(valBoxStroke, TweenInfo.new(0.15), { Transparency = 0.75 })
				local num = tonumber(valBox.Text)
				if num then
					updateSliderVal(num)
					pcall(callback, num)
				else
					updateSliderVal(min + (max - min) * fill.Size.X.Scale)
				end
			end)

			thumb.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
				if isDragging then return end

				isDragging = true
				tween(thumb, TweenInfo.new(0.15), { Size = UDim2.new(0, 20, 0, 14) })
				tween(valBoxStroke, TweenInfo.new(0.15), { Transparency = 0.4 })

				connectionMove = UserInputService.InputChanged:Connect(function(moveInput)
					if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
						updateSlider(moveInput.Position.X)
					end
				end)

				connectionEnd = UserInputService.InputEnded:Connect(function(endInput)
					if endInput.UserInputType == input.UserInputType then
						isDragging = false
						pcall(callback, tonumber(valBox.Text) or default)
						tween(thumb, TweenInfo.new(0.15), { Size = UDim2.new(0, 16, 0, 12) })
						tween(valBoxStroke, TweenInfo.new(0.15), { Transparency = 0.75 })
						if connectionMove then connectionMove:Disconnect() end
						if connectionEnd then connectionEnd:Disconnect() end
					end
				end)
			end)

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					updateSlider(input.Position.X)
					pcall(callback, tonumber(valBox.Text) or default)
				end
			end)

			local obj = {
				Set = function(_, val)
					updateSliderVal(val)
					pcall(callback, tonumber(valBox.Text) or default)
				end,
				Get = function() return tonumber(valBox.Text) or default end
			}

			if flag then
				registeredElements[flag] = obj
			end

			return obj
		end

		function TabObject:Keybind(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or opts.Name or "Keybind"
			local currentKey = opts.Default or Enum.KeyCode.E
			local callback = opts.Callback or function() end
			local flag = opts.Flag

			local kbFrame, stroke = createContainer(targetParent, 38)

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -110, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = title
			label.TextColor3 = Color3.fromRGB(240, 245, 255)
			label.TextSize = 12
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.ZIndex = 5
			label.Parent = kbFrame

			local keyBtn = Instance.new("TextButton")
			keyBtn.AnchorPoint = Vector2.new(1, 0.5)
			keyBtn.Position = UDim2.new(1, -12, 0.5, 0)
			keyBtn.Size = UDim2.new(0, 90, 0, 24)
			keyBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
			keyBtn.BackgroundTransparency = 0.2
			keyBtn.Text = currentKey.Name
			keyBtn.TextColor3 = Color3.fromRGB(230, 238, 250)
			keyBtn.TextSize = 11
			keyBtn.Font = Enum.Font.GothamMedium
			keyBtn.TextYAlignment = Enum.TextYAlignment.Center
			keyBtn.ZIndex = 6
			keyBtn.Parent = kbFrame

			local keyCorner = Instance.new("UICorner")
			keyCorner.CornerRadius = UDim.new(0, 6)
			keyCorner.Parent = keyBtn

			local keyStroke = Instance.new("UIStroke")
			keyStroke.Color = Color3.fromRGB(255, 255, 255)
			keyStroke.Thickness = 1
			keyStroke.Transparency = 0.75
			keyStroke.Parent = keyBtn

			local listening = false

			keyBtn.MouseEnter:Connect(function()
				if not listening then
					tween(keyStroke, TweenInfo.new(0.15), { Transparency = 0.4 })
				end
			end)

			keyBtn.MouseLeave:Connect(function()
				if not listening then
					tween(keyStroke, TweenInfo.new(0.15), { Transparency = 0.75 })
				end
			end)

			keyBtn.MouseButton1Click:Connect(function()
				listening = true
				keyBtn.Text = "..."
				keyBtn.TextColor3 = Color3.fromRGB(255, 220, 100)
				tween(keyStroke, TweenInfo.new(0.15), { Transparency = 0.2 })
			end)

			local keybindInputConn
			keybindInputConn = UserInputService.InputBegan:Connect(function(input, gpe)
				if not kbFrame:IsDescendantOf(game) then
					if keybindInputConn then keybindInputConn:Disconnect() end
					return
				end
				if gpe then return end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					if listening then
						listening = false
						currentKey = input.KeyCode
						keyBtn.Text = currentKey.Name
						keyBtn.TextColor3 = Color3.fromRGB(230, 238, 250)
						tween(keyStroke, TweenInfo.new(0.15), { Transparency = 0.75 })
					elseif input.KeyCode == currentKey then
						pcall(callback, currentKey)
					end
				end
			end)

			local obj = {
				GetKey = function() return currentKey end,
				Set = function(_, newKey)
					if typeof(newKey) == "EnumItem" then
						currentKey = newKey
						keyBtn.Text = currentKey.Name
					elseif typeof(newKey) == "string" and Enum.KeyCode[newKey] then
						currentKey = Enum.KeyCode[newKey]
						keyBtn.Text = currentKey.Name
					end
				end
			}

			if flag then
				registeredElements[flag] = obj
			end

			return obj
		end

		function TabObject:Dropdown(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or opts.Name or "Dropdown"
			local items = opts.Items or {}
			local selected = (opts.Default ~= nil and opts.Default ~= "") and opts.Default or "--"
			local callback = opts.Callback or function() end
			local flag = opts.Flag

			local ddFrame, stroke = createContainer(targetParent, 38)
			ddFrame.ClipsDescendants = true

			local headerBtn = Instance.new("TextButton")
			headerBtn.Size = UDim2.new(1, 0, 0, 38)
			headerBtn.BackgroundTransparency = 1
			headerBtn.Text = ""
			headerBtn.ZIndex = 6
			headerBtn.Parent = ddFrame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -125, 0, 38)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = title
			label.TextColor3 = Color3.fromRGB(240, 245, 255)
			label.TextSize = 12
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.ZIndex = 5
			label.Parent = headerBtn

			local selBox = Instance.new("Frame")
			selBox.AnchorPoint = Vector2.new(1, 0.5)
			selBox.Position = UDim2.new(1, -12, 0.5, 0)
			selBox.Size = UDim2.new(0, 104, 0, 24)
			selBox.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
			selBox.BackgroundTransparency = 0.2
			selBox.ZIndex = 6
			selBox.Parent = headerBtn

			local selBoxCorner = Instance.new("UICorner")
			selBoxCorner.CornerRadius = UDim.new(0, 6)
			selBoxCorner.Parent = selBox

			local selBoxStroke = Instance.new("UIStroke")
			selBoxStroke.Color = Color3.fromRGB(255, 255, 255)
			selBoxStroke.Thickness = 1
			selBoxStroke.Transparency = 0.75
			selBoxStroke.Parent = selBox

			local selLabel = Instance.new("TextLabel")
			selLabel.Size = UDim2.new(1, -26, 1, 0)
			selLabel.Position = UDim2.new(0, 8, 0, 0)
			selLabel.BackgroundTransparency = 1
			selLabel.Text = tostring(selected)
			selLabel.TextColor3 = Color3.fromRGB(230, 238, 250)
			selLabel.TextSize = 11
			selLabel.Font = Enum.Font.GothamMedium
			selLabel.TextYAlignment = Enum.TextYAlignment.Center
			selLabel.TextXAlignment = Enum.TextXAlignment.Left
			selLabel.TextTruncate = Enum.TextTruncate.AtEnd
			selLabel.ZIndex = 7
			selLabel.Parent = selBox

			local arrowIcon = Instance.new("ImageLabel")
			arrowIcon.Name = "Chevron"
			arrowIcon.AnchorPoint = Vector2.new(1, 0.5)
			arrowIcon.Position = UDim2.new(1, -8, 0.5, 0)
			arrowIcon.Size = UDim2.new(0, 12, 0, 12)
			arrowIcon.BackgroundTransparency = 1
			arrowIcon.Image = getIconAsset("chevron-down")
			arrowIcon.ImageColor3 = Color3.fromRGB(170, 180, 200)
			arrowIcon.ZIndex = 7
			arrowIcon.Parent = selBox

			if not iconsLoaded then
				task.spawn(function()
					repeat task.wait() until iconsLoaded or not arrowIcon:IsDescendantOf(game)
					if arrowIcon:IsDescendantOf(game) then
						arrowIcon.Image = getIconAsset("chevron-down")
					end
				end)
			end

			local isOpen = false

			local itemsList = Instance.new("Frame")
			itemsList.Position = UDim2.new(0, 10, 0, 42)
			itemsList.Size = UDim2.new(1, -20, 0, 0)
			itemsList.AutomaticSize = Enum.AutomaticSize.Y
			itemsList.BackgroundTransparency = 1
			itemsList.ZIndex = 5
			itemsList.Parent = ddFrame

			local listLayout = Instance.new("UIListLayout")
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Padding = UDim.new(0, 3)
			listLayout.Parent = itemsList

			local listPadding = Instance.new("UIPadding")
			listPadding.PaddingBottom = UDim.new(0, 8)
			listPadding.Parent = itemsList

			local itemButtons = {}

			local function refreshSelectionStates()
				for _, data in ipairs(itemButtons) do
					local isSel = (data.Item == selected)
					tween(data.Btn, fadeTweenInfo, {
						BackgroundTransparency = isSel and 0.82 or 0.96
					})
					data.Text.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 160, 180)
				end
			end

			for _, item in ipairs(items) do
				local itemBtn = Instance.new("TextButton")
				itemBtn.Size = UDim2.new(1, 0, 0, 28)
				itemBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				itemBtn.BackgroundTransparency = 0.96
				itemBtn.Text = ""
				itemBtn.ZIndex = 6
				itemBtn.Parent = itemsList

				local itemCorner = Instance.new("UICorner")
				itemCorner.CornerRadius = UDim.new(0, 6)
				itemCorner.Parent = itemBtn

				local itemText = Instance.new("TextLabel")
				itemText.Size = UDim2.new(1, -16, 1, 0)
				itemText.Position = UDim2.new(0, 12, 0, 0)
				itemText.BackgroundTransparency = 1
				itemText.Text = tostring(item)
				itemText.TextColor3 = Color3.fromRGB(150, 160, 180)
				itemText.TextSize = 11
				itemText.Font = Enum.Font.Gotham
				itemText.TextYAlignment = Enum.TextYAlignment.Center
				itemText.TextXAlignment = Enum.TextXAlignment.Left
				itemText.ZIndex = 7
				itemText.Parent = itemBtn

				table.insert(itemButtons, { Item = item, Btn = itemBtn, Text = itemText })

				itemBtn.MouseEnter:Connect(function()
					if selected ~= item then
						tween(itemBtn, fadeTweenInfo, { BackgroundTransparency = 0.90 })
						tween(itemText, fadeTweenInfo, { TextColor3 = Color3.fromRGB(230, 238, 250) })
					end
				end)

				itemBtn.MouseLeave:Connect(function()
					if selected ~= item then
						tween(itemBtn, fadeTweenInfo, { BackgroundTransparency = 0.96 })
						tween(itemText, fadeTweenInfo, { TextColor3 = Color3.fromRGB(150, 160, 180) })
					end
				end)

				itemBtn.MouseButton1Click:Connect(function()
					selected = item
					selLabel.Text = tostring(selected)
					isOpen = false
					refreshSelectionStates()
					tween(arrowIcon, fadeTweenInfo, { Rotation = 0 })
					tween(selBoxStroke, fadeTweenInfo, { Transparency = 0.75 })
					tween(ddFrame, fadeTweenInfo, { Size = UDim2.new(1, 0, 0, 38) })
					pcall(callback, selected)
				end)
			end

			refreshSelectionStates()

			headerBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				local targetHeight = isOpen and (46 + listLayout.AbsoluteContentSize.Y) or 38
				local targetRotation = isOpen and 180 or 0
				local targetStrokeTrans = isOpen and 0.4 or 0.75
				tween(arrowIcon, fadeTweenInfo, { Rotation = targetRotation })
				tween(selBoxStroke, fadeTweenInfo, { Transparency = targetStrokeTrans })
				tween(ddFrame, fadeTweenInfo, { Size = UDim2.new(1, 0, 0, targetHeight) })
			end)

			local obj = {
				GetSelected = function() return selected end,
				Set = function(_, val)
					selected = val
					selLabel.Text = tostring(selected)
					refreshSelectionStates()
					pcall(callback, selected)
				end,
				SetItems = function(_, newItems)
					items = newItems or {}
					for _, data in ipairs(itemButtons) do
						if data.Btn then data.Btn:Destroy() end
					end
					itemButtons = {}

					for _, item in ipairs(items) do
						local itemBtn = Instance.new("TextButton")
						itemBtn.Size = UDim2.new(1, 0, 0, 28)
						itemBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						itemBtn.BackgroundTransparency = 0.96
						itemBtn.Text = ""
						itemBtn.ZIndex = 6
						itemBtn.Parent = itemsList

						local itemCorner = Instance.new("UICorner")
						itemCorner.CornerRadius = UDim.new(0, 6)
						itemCorner.Parent = itemBtn

						local itemText = Instance.new("TextLabel")
						itemText.Size = UDim2.new(1, -16, 1, 0)
						itemText.Position = UDim2.new(0, 12, 0, 0)
						itemText.BackgroundTransparency = 1
						itemText.Text = tostring(item)
						itemText.TextColor3 = Color3.fromRGB(150, 160, 180)
						itemText.TextSize = 11
						itemText.Font = Enum.Font.Gotham
						itemText.TextYAlignment = Enum.TextYAlignment.Center
						itemText.TextXAlignment = Enum.TextXAlignment.Left
						itemText.ZIndex = 7
						itemText.Parent = itemBtn

						table.insert(itemButtons, { Item = item, Btn = itemBtn, Text = itemText })

						itemBtn.MouseEnter:Connect(function()
							if selected ~= item then
								tween(itemBtn, fadeTweenInfo, { BackgroundTransparency = 0.90 })
								tween(itemText, fadeTweenInfo, { TextColor3 = Color3.fromRGB(230, 238, 250) })
							end
						end)

						itemBtn.MouseLeave:Connect(function()
							if selected ~= item then
								tween(itemBtn, fadeTweenInfo, { BackgroundTransparency = 0.96 })
								tween(itemText, fadeTweenInfo, { TextColor3 = Color3.fromRGB(150, 160, 180) })
							end
						end)

						itemBtn.MouseButton1Click:Connect(function()
							selected = item
							selLabel.Text = tostring(selected)
							isOpen = false
							refreshSelectionStates()
							tween(arrowIcon, fadeTweenInfo, { Rotation = 0 })
							tween(selBoxStroke, fadeTweenInfo, { Transparency = 0.75 })
							tween(ddFrame, fadeTweenInfo, { Size = UDim2.new(1, 0, 0, 38) })
							pcall(callback, selected)
						end)
					end
					refreshSelectionStates()
				end
			}

			if flag then
				registeredElements[flag] = obj
			end

			return obj
		end

		function TabObject:MultiDropdown(opts, targetParent)
			opts = opts or {}
			targetParent = targetParent or page
			local title = opts.Title or opts.Name or "MultiDropdown"
			local items = opts.Items or {}
			local default = opts.Default or {}
			local callback = opts.Callback or function() end
			local flag = opts.Flag

			local selectedMap = {}
			if typeof(default) == "table" then
				for _, item in ipairs(default) do
					selectedMap[item] = true
				end
			end

			local ddFrame, stroke = createContainer(targetParent, 38)
			ddFrame.ClipsDescendants = true

			local headerBtn = Instance.new("TextButton")
			headerBtn.Size = UDim2.new(1, 0, 0, 38)
			headerBtn.BackgroundTransparency = 1
			headerBtn.Text = ""
			headerBtn.ZIndex = 6
			headerBtn.Parent = ddFrame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -125, 0, 38)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = title
			label.TextColor3 = Color3.fromRGB(240, 245, 255)
			label.TextSize = 12
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.ZIndex = 5
			label.Parent = headerBtn

			local selBox = Instance.new("Frame")
			selBox.AnchorPoint = Vector2.new(1, 0.5)
			selBox.Position = UDim2.new(1, -12, 0.5, 0)
			selBox.Size = UDim2.new(0, 104, 0, 24)
			selBox.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
			selBox.BackgroundTransparency = 0.2
			selBox.ZIndex = 6
			selBox.Parent = headerBtn

			local selBoxCorner = Instance.new("UICorner")
			selBoxCorner.CornerRadius = UDim.new(0, 6)
			selBoxCorner.Parent = selBox

			local selBoxStroke = Instance.new("UIStroke")
			selBoxStroke.Color = Color3.fromRGB(255, 255, 255)
			selBoxStroke.Thickness = 1
			selBoxStroke.Transparency = 0.75
			selBoxStroke.Parent = selBox

			local selLabel = Instance.new("TextLabel")
			selLabel.Size = UDim2.new(1, -26, 1, 0)
			selLabel.Position = UDim2.new(0, 8, 0, 0)
			selLabel.BackgroundTransparency = 1
			selLabel.TextColor3 = Color3.fromRGB(230, 238, 250)
			selLabel.TextSize = 11
			selLabel.Font = Enum.Font.GothamMedium
			selLabel.TextYAlignment = Enum.TextYAlignment.Center
			selLabel.TextXAlignment = Enum.TextXAlignment.Left
			selLabel.TextTruncate = Enum.TextTruncate.AtEnd
			selLabel.ZIndex = 7
			selLabel.Parent = selBox

			local arrowIcon = Instance.new("ImageLabel")
			arrowIcon.Name = "Chevron"
			arrowIcon.AnchorPoint = Vector2.new(1, 0.5)
			arrowIcon.Position = UDim2.new(1, -8, 0.5, 0)
			arrowIcon.Size = UDim2.new(0, 12, 0, 12)
			arrowIcon.BackgroundTransparency = 1
			arrowIcon.Image = getIconAsset("chevron-down")
			arrowIcon.ImageColor3 = Color3.fromRGB(170, 180, 200)
			arrowIcon.ZIndex = 7
			arrowIcon.Parent = selBox

			if not iconsLoaded then
				task.spawn(function()
					repeat task.wait() until iconsLoaded or not arrowIcon:IsDescendantOf(game)
					if arrowIcon:IsDescendantOf(game) then
						arrowIcon.Image = getIconAsset("chevron-down")
					end
				end)
			end

			local isOpen = false

			local itemsList = Instance.new("Frame")
			itemsList.Position = UDim2.new(0, 10, 0, 42)
			itemsList.Size = UDim2.new(1, -20, 0, 0)
			itemsList.AutomaticSize = Enum.AutomaticSize.Y
			itemsList.BackgroundTransparency = 1
			itemsList.ZIndex = 5
			itemsList.Parent = ddFrame

			local listLayout = Instance.new("UIListLayout")
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Padding = UDim.new(0, 3)
			listLayout.Parent = itemsList

			local listPadding = Instance.new("UIPadding")
			listPadding.PaddingBottom = UDim.new(0, 8)
			listPadding.Parent = itemsList

			local itemButtons = {}

			local function getSelectedList()
				local list = {}
				for _, item in ipairs(items) do
					if selectedMap[item] then
						table.insert(list, item)
					end
				end
				return list
			end

			local function updateDisplay()
				local list = getSelectedList()
				if #list == 0 then
					selLabel.Text = "--"
				elseif #list == 1 then
					selLabel.Text = tostring(list[1])
				else
					selLabel.Text = #list .. " selected"
				end
			end

			local function refreshSelectionStates()
				for _, data in ipairs(itemButtons) do
					local isSel = selectedMap[data.Item] == true
					tween(data.Btn, fadeTweenInfo, {
						BackgroundTransparency = isSel and 0.82 or 0.96
					})
					data.Text.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 160, 180)
				end
				updateDisplay()
			end

			for _, item in ipairs(items) do
				local itemBtn = Instance.new("TextButton")
				itemBtn.Size = UDim2.new(1, 0, 0, 28)
				itemBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				itemBtn.BackgroundTransparency = 0.96
				itemBtn.Text = ""
				itemBtn.ZIndex = 6
				itemBtn.Parent = itemsList

				local itemCorner = Instance.new("UICorner")
				itemCorner.CornerRadius = UDim.new(0, 6)
				itemCorner.Parent = itemBtn

				local itemText = Instance.new("TextLabel")
				itemText.Size = UDim2.new(1, -16, 1, 0)
				itemText.Position = UDim2.new(0, 12, 0, 0)
				itemText.BackgroundTransparency = 1
				itemText.Text = tostring(item)
				itemText.TextColor3 = Color3.fromRGB(150, 160, 180)
				itemText.TextSize = 11
				itemText.Font = Enum.Font.Gotham
				itemText.TextYAlignment = Enum.TextYAlignment.Center
				itemText.TextXAlignment = Enum.TextXAlignment.Left
				itemText.ZIndex = 7
				itemText.Parent = itemBtn

				table.insert(itemButtons, { Item = item, Btn = itemBtn, Text = itemText })

				itemBtn.MouseEnter:Connect(function()
					if not selectedMap[item] then
						tween(itemBtn, fadeTweenInfo, { BackgroundTransparency = 0.90 })
						tween(itemText, fadeTweenInfo, { TextColor3 = Color3.fromRGB(230, 238, 250) })
					end
				end)

				itemBtn.MouseLeave:Connect(function()
					if not selectedMap[item] then
						tween(itemBtn, fadeTweenInfo, { BackgroundTransparency = 0.96 })
						tween(itemText, fadeTweenInfo, { TextColor3 = Color3.fromRGB(150, 160, 180) })
					end
				end)

				itemBtn.MouseButton1Click:Connect(function()
					selectedMap[item] = not selectedMap[item]
					refreshSelectionStates()
					pcall(callback, getSelectedList())
				end)
			end

			refreshSelectionStates()

			headerBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				local targetHeight = isOpen and (46 + listLayout.AbsoluteContentSize.Y) or 38
				local targetRotation = isOpen and 180 or 0
				local targetStrokeTrans = isOpen and 0.4 or 0.75
				tween(arrowIcon, fadeTweenInfo, { Rotation = targetRotation })
				tween(selBoxStroke, fadeTweenInfo, { Transparency = targetStrokeTrans })
				tween(ddFrame, fadeTweenInfo, { Size = UDim2.new(1, 0, 0, targetHeight) })
			end)

			local obj = {
				GetSelected = function() return getSelectedList() end,
				Set = function(_, val)
					selectedMap = {}
					if typeof(val) == "table" then
						for _, item in ipairs(val) do
							selectedMap[item] = true
						end
					end
					refreshSelectionStates()
					pcall(callback, getSelectedList())
				end
			}

			if flag then
				registeredElements[flag] = obj
			end

			return obj
		end

		return TabObject
	end

	return Window
end

return EclipseUI
