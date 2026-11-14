-- File: Main.gui
-- Universal Compact Neon UI Library (AcelestuZ Style)

local Library = {}
Library.__index = Library

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local function GetGuiParent()
	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and hui then return hui end

	local robloxGui = CoreGui:FindFirstChild("RobloxGui")
	if robloxGui then return robloxGui end

	local okCore, _ = pcall(function()
		return CoreGui.Name
	end)
	if okCore then return CoreGui end

	return LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
end

function Library:CreateWindow(config)
	config = config or {}
	local WindowTitle = config.Title or "UNIVERSAL GUI"
	local WindowName = config.Name or ("AcelestuZ_UI_" .. WindowTitle)
	local ExpandedHeight = config.Height or 290
	local WindowWidth = config.Width or 260
	local StartOpen = config.StartOpen or false
	local DefaultToggleKey = config.ToggleKey or Enum.KeyCode.H
	local ShowFloatBtn = (config.FloatingButton ~= nil) and config.FloatingButton or UIS.TouchEnabled
	local FloatText = config.FloatText or "UI"

	-- Clean up existing instance with the same name
	_G.AcelestuZ_Windows = _G.AcelestuZ_Windows or {}
	if _G.AcelestuZ_Windows[WindowName] then
		pcall(_G.AcelestuZ_Windows[WindowName])
	end

	local Window = {
		Running = true,
		IsOpen = StartOpen,
		ToggleKey = DefaultToggleKey,
		Connections = {},
		CleanUpCallbacks = {},
		Tabs = {},
		ActiveTab = nil
	}

	function Window:Bind(signal, callback)
		local conn = signal:Connect(callback)
		table.insert(self.Connections, conn)
		return conn
	end

	function Window:OnDestroy(callback)
		table.insert(self.CleanUpCallbacks, callback)
	end

	local Parent = GetGuiParent()
	local oldGui = Parent:FindFirstChild(WindowName)
	if oldGui then oldGui:Destroy() end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = WindowName
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = Parent
	Window.ScreenGui = ScreenGui

	-- Notification Container
	local NotifContainer = Instance.new("Frame", ScreenGui)
	NotifContainer.Size = UDim2.new(0, 220, 1, -20)
	NotifContainer.Position = UDim2.new(1, -230, 0, 10)
	NotifContainer.BackgroundTransparency = 1
	local NotifLayout = Instance.new("UIListLayout", NotifContainer)
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	NotifLayout.Padding = UDim.new(0, 6)

	-- Floating Mini Button (Mobile / Quick Toggle)
	local FloatBtn = Instance.new("TextButton", ScreenGui)
	FloatBtn.Size = UDim2.new(0, 42, 0, 42)
	FloatBtn.Position = UDim2.new(0, 15, 0.5, -21)
	FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	FloatBtn.BackgroundTransparency = 0.25
	FloatBtn.Text = FloatText
	FloatBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
	FloatBtn.Font = Enum.Font.GothamBold
	FloatBtn.TextSize = 12
	FloatBtn.Visible = ShowFloatBtn
	Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

	local floatStroke = Instance.new("UIStroke", FloatBtn)
	floatStroke.Color = Color3.fromRGB(0, 170, 255)
	floatStroke.Thickness = 1.5
	Window.FloatBtn = FloatBtn

	-- Main Window Frame
	local MainFrame = Instance.new("Frame", ScreenGui)
	MainFrame.Size = StartOpen and UDim2.new(0, WindowWidth, 0, ExpandedHeight) or UDim2.new(0, WindowWidth, 0, 35)
	MainFrame.Position = UDim2.new(0.5, -math.floor(WindowWidth / 2), 0.15, 0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
	Window.MainFrame = MainFrame

	-- Neon Animated Border
	local NeonStroke = Instance.new("UIStroke", MainFrame)
	NeonStroke.Thickness = 2
	local NeonGradient = Instance.new("UIGradient", NeonStroke)
	NeonGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
	})

	task.spawn(function()
		local rot = 0
		while Window.Running and ScreenGui and ScreenGui.Parent do
			rot = (rot + 2) % 360
			NeonGradient.Rotation = rot
			task.wait(0.03)
		end
	end)

	-- TopBar
	local TopBar = Instance.new("Frame", MainFrame)
	TopBar.Size = UDim2.new(1, 0, 0, 35)
	TopBar.BackgroundTransparency = 1
	Window.TopBar = TopBar

	local Title = Instance.new("TextLabel", TopBar)
	Title.Size = UDim2.new(1, -80, 1, 0)
	Title.Position = UDim2.new(0, 12, 0, 0)
	Title.Text = WindowTitle
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.BackgroundTransparency = 1

	local MinBtn = Instance.new("TextButton", TopBar)
	MinBtn.Size = UDim2.new(0, 45, 0, 25)
	MinBtn.Position = UDim2.new(1, -75, 0.5, -12)
	MinBtn.BackgroundTransparency = 1
	MinBtn.Text = StartOpen and "HIDE" or "OPEN"
	MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
	MinBtn.Font = Enum.Font.GothamBold
	MinBtn.TextSize = 10

	local CloseBtn = Instance.new("TextButton", TopBar)
	CloseBtn.Size = UDim2.new(0, 22, 0, 22)
	CloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	CloseBtn.Text = " "
	CloseBtn.TextColor3 = Color3.new(1, 1, 1)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 10
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

	-- Tab Container & Navigation Bar
	local TabContainer = Instance.new("Frame", MainFrame)
	TabContainer.Size = UDim2.new(1, 0, 1, -35)
	TabContainer.Position = UDim2.new(0, 0, 0, 35)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Visible = StartOpen
	Window.TabContainer = TabContainer

	local NavBar = Instance.new("Frame", TabContainer)
	NavBar.Size = UDim2.new(1, 0, 0, 26)
	NavBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	NavBar.BorderSizePixel = 0
	Window.NavBar = NavBar

	-- Open / Minimize Logic
	MinBtn.MouseButton1Click:Connect(function()
		Window.IsOpen = not Window.IsOpen
		MinBtn.Text = Window.IsOpen and "HIDE" or "OPEN"
		MainFrame:TweenSize(
			Window.IsOpen and UDim2.new(0, WindowWidth, 0, ExpandedHeight) or UDim2.new(0, WindowWidth, 0, 35),
			"Out", "Back", 0.3, true
		)
		TabContainer.Visible = Window.IsOpen
	end)

	FloatBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = not MainFrame.Visible
	end)

	-- Destroy / CleanUp Logic
	function Window:Destroy()
		if not self.Running then return end
		self.Running = false

		for _, cb in ipairs(self.CleanUpCallbacks) do
			pcall(cb)
		end
		for _, conn in ipairs(self.Connections) do
			if conn and conn.Connected then
				conn:Disconnect()
			end
		end
		self.Connections = {}

		if ScreenGui and ScreenGui.Parent then
			ScreenGui:Destroy()
		end
	end

	_G.AcelestuZ_Windows[WindowName] = function()
		Window:Destroy()
	end

	CloseBtn.MouseButton1Click:Connect(function()
		Window:Destroy()
	end)

	-- Window Dragging (Mouse & Touch)
	local dragInputObj = nil
	local dragStart, startPos

	TopBar.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not dragInputObj then
			dragInputObj = input
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)

	Window:Bind(UIS.InputChanged, function(input)
		if dragInputObj and (input == dragInputObj or (input.UserInputType == Enum.UserInputType.MouseMovement and dragInputObj.UserInputType == Enum.UserInputType.MouseButton1)) then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	Window:Bind(UIS.InputEnded, function(input)
		if input == dragInputObj then
			dragInputObj = nil
		end
	end)

	-- Toggle Keybind Listener
	Window:Bind(UIS.InputBegan, function(input, gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and Window.ToggleKey and input.KeyCode == Window.ToggleKey then
			MainFrame.Visible = not MainFrame.Visible
		end
	end)

	-- Notification Function
	function Window:Notify(notifConfig)
		notifConfig = notifConfig or {}
		local nTitle = notifConfig.Title or WindowTitle
		local nText = notifConfig.Content or ""
		local nDuration = notifConfig.Duration or 3

		local card = Instance.new("Frame", NotifContainer)
		card.Size = UDim2.new(1, 0, 0, 48)
		card.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		card.BorderSizePixel = 0
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

		local st = Instance.new("UIStroke", card)
		st.Color = Color3.fromRGB(0, 170, 255)
		st.Thickness = 1.2

		local tl = Instance.new("TextLabel", card)
		tl.Size = UDim2.new(1, -16, 0, 18)
		tl.Position = UDim2.new(0, 8, 0, 4)
		tl.BackgroundTransparency = 1
		tl.Text = nTitle
		tl.TextColor3 = Color3.fromRGB(0, 200, 255)
		tl.Font = Enum.Font.GothamBold
		tl.TextSize = 11
		tl.TextXAlignment = Enum.TextXAlignment.Left

		local cl = Instance.new("TextLabel", card)
		cl.Size = UDim2.new(1, -16, 0, 22)
		cl.Position = UDim2.new(0, 8, 0, 22)
		cl.BackgroundTransparency = 1
		cl.Text = nText
		cl.TextColor3 = Color3.fromRGB(200, 200, 200)
		cl.Font = Enum.Font.Gotham
		cl.TextSize = 10
		cl.TextWrapped = true
		cl.TextXAlignment = Enum.TextXAlignment.Left

		task.delay(nDuration, function()
			if card and card.Parent then
				TweenService:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
				task.wait(0.25)
				if card and card.Parent then card:Destroy() end
			end
		end)
	end

	function Window:SetFloatingButton(visible)
		FloatBtn.Visible = visible
	end

	function Window:GetFloatingButton()
		return FloatBtn.Visible
	end

	-- Update Tab Layout proportions automatically
	local function RefreshTabButtons()
		local count = #Window.Tabs
		if count == 0 then return end
		local widthScale = 1 / count
		for idx, t in ipairs(Window.Tabs) do
			t.Button.Size = UDim2.new(widthScale, 0, 1, 0)
			t.Button.Position = UDim2.new(widthScale * (idx - 1), 0, 0, 0)
		end
	end

	-- Create Tab
	function Window:CreateTab(tabName)
		local Tab = {
			Name = tabName,
			Order = 0
		}

		local function NextOrder()
			Tab.Order = Tab.Order + 1
			return Tab.Order
		end

		local Page = Instance.new("ScrollingFrame", TabContainer)
		Page.Size = UDim2.new(1, 0, 1, -30)
		Page.Position = UDim2.new(0, 0, 0, 30)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
		Page.BorderSizePixel = 0
		Page.Visible = false

		local UIList = Instance.new("UIListLayout", Page)
		UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIList.SortOrder = Enum.SortOrder.LayoutOrder
		UIList.Padding = UDim.new(0, 8)

		UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 12)
		end)

		local TabBtn = Instance.new("TextButton", NavBar)
		TabBtn.Text = tostring(tabName):upper()
		TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
		TabBtn.Font = Enum.Font.GothamBold
		TabBtn.TextSize = 10
		TabBtn.BorderSizePixel = 0

		Tab.Page = Page
		Tab.Button = TabBtn
		Tab.UIList = UIList

		local function ActivateTab()
			for _, other in ipairs(Window.Tabs) do
				other.Page.Visible = false
				other.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				other.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
			end
			Page.Visible = true
			TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			TabBtn.TextColor3 = Color3.new(1, 1, 1)
			Window.ActiveTab = Tab
		end

		TabBtn.MouseButton1Click:Connect(ActivateTab)

		table.insert(Window.Tabs, Tab)
		RefreshTabButtons()

		if #Window.Tabs == 1 then
			ActivateTab()
		end

		-- 1. Section Title (-- TEXT --)
		function Tab:CreateSection(text)
			local t = Instance.new("TextLabel", Page)
			t.LayoutOrder = NextOrder()
			t.Size = UDim2.new(0.9, 0, 0, 24)
			t.BackgroundTransparency = 1
			t.Text = "-- " .. tostring(text):upper() .. " --"
			t.TextColor3 = Color3.fromRGB(180, 180, 180)
			t.Font = Enum.Font.GothamBold
			t.TextSize = 10
			return t
		end

		-- 2. Button
		function Tab:CreateButton(btnConfig)
			btnConfig = btnConfig or {}
			local name = btnConfig.Name or "BUTTON"
			local callback = btnConfig.Callback or function() end

			local b = Instance.new("TextButton", Page)
			b.LayoutOrder = btnConfig.LayoutOrder or NextOrder()
			b.Size = UDim2.new(0.9, 0, 0, btnConfig.Height or 32)
			b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Font = Enum.Font.GothamBold
			b.Text = name
			b.TextSize = 11
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

			b.MouseButton1Click:Connect(function()
				callback()
			end)

			local BtnObj = { Instance = b }
			function BtnObj:SetText(newText)
				b.Text = tostring(newText)
			end
			function BtnObj:SetColor(newColor)
				b.BackgroundColor3 = newColor
			end
			return BtnObj
		end

		-- 3. Toggle (NAME: ON / OFF with Green Highlight)
		function Tab:CreateToggle(togConfig)
			togConfig = togConfig or {}
			local name = togConfig.Name or "TOGGLE"
			local state = togConfig.Default or false
			local onText = togConfig.OnText or "ON"
			local offText = togConfig.OffText or "OFF"
			local callback = togConfig.Callback or function() end

			local b = Instance.new("TextButton", Page)
			b.LayoutOrder = togConfig.LayoutOrder or NextOrder()
			b.Size = UDim2.new(0.9, 0, 0, togConfig.Height or 30)
			b.Font = Enum.Font.GothamSemibold
			b.TextColor3 = Color3.new(1, 1, 1)
			b.TextSize = 10
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

			local function UpdateVisual()
				b.Text = name .. ": " .. (state and onText or offText)
				b.BackgroundColor3 = state and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(30, 30, 30)
			end

			UpdateVisual()

			local ToggleObj = { Instance = b }
			function ToggleObj:Set(newState, fireCallback)
				state = (newState == true)
				UpdateVisual()
				if fireCallback ~= false then
					callback(state)
				end
			end
			function ToggleObj:Get()
				return state
			end

			b.MouseButton1Click:Connect(function()
				ToggleObj:Set(not state, true)
			end)

			return ToggleObj
		end

		-- 4. Cycle Button (e.g. SPEED: 1x -> 2x -> 5x)
		function Tab:CreateCycle(cycleConfig)
			cycleConfig = cycleConfig or {}
			local name = cycleConfig.Name or "MODE"
			local options = cycleConfig.Options or {"1", "2", "3"}
			local index = cycleConfig.DefaultIndex or 1
			local suffix = cycleConfig.Suffix or ""
			local callback = cycleConfig.Callback or function() end

			local b = Instance.new("TextButton", Page)
			b.LayoutOrder = cycleConfig.LayoutOrder or NextOrder()
			b.Size = UDim2.new(0.9, 0, 0, 32)
			b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Font = Enum.Font.GothamBold
			b.TextSize = 11
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

			local function UpdateText()
				b.Text = name .. ": " .. tostring(options[index]) .. suffix
			end
			UpdateText()

			b.MouseButton1Click:Connect(function()
				index = (index % #options) + 1
				UpdateText()
				callback(options[index], index)
			end)

			local CycleObj = { Instance = b }
			function CycleObj:SetIndex(newIdx, fireCallback)
				if options[newIdx] then
					index = newIdx
					UpdateText()
					if fireCallback ~= false then
						callback(options[index], index)
					end
				end
			end
			function CycleObj:Get()
				return options[index]
			end
			return CycleObj
		end

		-- 5. Slider (Mouse & Touch Compatible)
		function Tab:CreateSlider(sliderConfig)
			sliderConfig = sliderConfig or {}
			local titlePrefix = sliderConfig.Name or "SLIDER"
			local minVal = sliderConfig.Min or 0
			local maxVal = sliderConfig.Max or 100
			local defaultVal = sliderConfig.Default or minVal
			local onChanged = sliderConfig.Callback or function() end

			local container = Instance.new("Frame", Page)
			container.LayoutOrder = sliderConfig.LayoutOrder or NextOrder()
			container.Size = UDim2.new(0.9, 0, 0, 42)
			container.BackgroundTransparency = 1

			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(1, 0, 0, 15)
			label.Text = titlePrefix .. ": " .. tostring(defaultVal)
			label.TextColor3 = Color3.fromRGB(170, 170, 170)
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 10
			label.BackgroundTransparency = 1

			local sliderBack = Instance.new("Frame", container)
			sliderBack.Size = UDim2.new(1, 0, 0, 16)
			sliderBack.Position = UDim2.new(0, 0, 0, 20)
			sliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			sliderBack.BackgroundTransparency = 0.4
			sliderBack.Active = true
			Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(1, 0)

			local sliderVisual = Instance.new("Frame", sliderBack)
			sliderVisual.Size = UDim2.new(1, -8, 0, 6)
			sliderVisual.Position = UDim2.new(0, 4, 0.5, -3)
			sliderVisual.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			sliderVisual.ZIndex = 2
			Instance.new("UICorner", sliderVisual).CornerRadius = UDim.new(1, 0)

			local initPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
			local sliderFill = Instance.new("Frame", sliderVisual)
			sliderFill.Size = UDim2.new(initPercent, 0, 1, 0)
			sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			sliderFill.ZIndex = 3
			Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

			local currentVal = defaultVal
			local activeSliderInput = nil

			local SliderObj = { Instance = container }

			function SliderObj:Set(val, fireCallback)
				val = math.clamp(math.floor(val), minVal, maxVal)
				currentVal = val
				local percent = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
				sliderFill.Size = UDim2.new(percent, 0, 1, 0)
				label.Text = titlePrefix .. ": " .. tostring(val)
				if fireCallback ~= false then
					onChanged(val)
				end
			end

			function SliderObj:Get()
				return currentVal
			end

			local function UpdateFromInput(input)
				local percent = math.clamp((input.Position.X - sliderVisual.AbsolutePosition.X) / sliderVisual.AbsoluteSize.X, 0, 1)
				local val = math.floor(minVal + (percent * (maxVal - minVal)))
				SliderObj:Set(val, true)
			end

			sliderBack.InputBegan:Connect(function(i)
				if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not activeSliderInput then
					activeSliderInput = i
					UpdateFromInput(i)
				end
			end)

			Window:Bind(UIS.InputChanged, function(i)
				if activeSliderInput and (i == activeSliderInput or (i.UserInputType == Enum.UserInputType.MouseMovement and activeSliderInput.UserInputType == Enum.UserInputType.MouseButton1)) then
					UpdateFromInput(i)
				end
			end)

			Window:Bind(UIS.InputEnded, function(i)
				if i == activeSliderInput then
					activeSliderInput = nil
				end
			end)

			return SliderObj
		end

		-- 6. Keybind Picker
		function Tab:CreateKeybind(keyConfig)
			keyConfig = keyConfig or {}
			local name = keyConfig.Name or "KEYBIND"
			local currentKey = keyConfig.Default or Enum.KeyCode.H
			local isUIToggle = keyConfig.IsUIToggle or false
			local callback = keyConfig.Callback or function() end

			local b = Instance.new("TextButton", Page)
			b.LayoutOrder = keyConfig.LayoutOrder or NextOrder()
			b.Size = UDim2.new(0.9, 0, 0, 30)
			b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Font = Enum.Font.GothamSemibold
			b.Text = name .. ": " .. currentKey.Name
			b.TextSize = 10
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

      b.MouseButton1Click:Connect(function()
				b.Text = "PRESS ANY KEY..."
				local conn
				conn = UIS.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						currentKey = input.KeyCode
						if isUIToggle then
							Window.ToggleKey = currentKey
						end
						b.Text = name .. ": " .. currentKey.Name
						conn:Disconnect()
						callback(currentKey)
					end
				end)
			end)

			return b
		end

		-- 7. Dropdown
		function Tab:CreateDropdown(dropConfig)
			dropConfig = dropConfig or {}
			local name = dropConfig.Name or "DROPDOWN"
			local options = dropConfig.Options or {}
			local currentOpt = dropConfig.Default or options[1] or "None"
			local callback = dropConfig.Callback or function() end
			local isOpen = false

			local container = Instance.new("Frame", Page)
			container.LayoutOrder = dropConfig.LayoutOrder or NextOrder()
			container.Size = UDim2.new(0.9, 0, 0, 30)
			container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			container.ClipsDescendants = true
			Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

			local headerBtn = Instance.new("TextButton", container)
			headerBtn.Size = UDim2.new(1, 0, 0, 30)
			headerBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			headerBtn.TextColor3 = Color3.new(1, 1, 1)
			headerBtn.Font = Enum.Font.GothamSemibold
			headerBtn.TextSize = 10
			headerBtn.Text = name .. ": " .. tostring(currentOpt) .. " [v]"
			Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, 6)

			local listFrame = Instance.new("Frame", container)
			listFrame.Size = UDim2.new(1, 0, 1, -30)
			listFrame.Position = UDim2.new(0, 0, 0, 30)
			listFrame.BackgroundTransparency = 1

			local listLayout = Instance.new("UIListLayout", listFrame)
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local function RebuildOptions()
				for _, child in ipairs(listFrame:GetChildren()) do
					if child:IsA("TextButton") then child:Destroy() end
				end
				for _, opt in ipairs(options) do
					local optBtn = Instance.new("TextButton", listFrame)
					optBtn.Size = UDim2.new(1, 0, 0, 26)
					optBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
					optBtn.BorderSizePixel = 0
					optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
					optBtn.Font = Enum.Font.Gotham
					optBtn.TextSize = 10
					optBtn.Text = tostring(opt)

					optBtn.MouseButton1Click:Connect(function()
						currentOpt = opt
						isOpen = false
						headerBtn.Text = name .. ": " .. tostring(currentOpt) .. " [v]"
						container.Size = UDim2.new(0.9, 0, 0, 30)
						callback(currentOpt)
					end)
				end
			end

			RebuildOptions()

			headerBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				headerBtn.Text = name .. ": " .. tostring(currentOpt) .. (isOpen and " [^]" or " [v]")
				local targetHeight = isOpen and (30 + (#options * 26)) or 30
				container.Size = UDim2.new(0.9, 0, 0, targetHeight)
			end)

			return container
		end

		-- 8. Text Input
		function Tab:CreateInput(inpConfig)
			inpConfig = inpConfig or {}
			local placeholder = inpConfig.Placeholder or "Enter text..."
			local defaultText = inpConfig.Default or ""
			local callback = inpConfig.Callback or function() end

			local box = Instance.new("TextBox", Page)
			box.LayoutOrder = inpConfig.LayoutOrder or NextOrder()
			box.Size = UDim2.new(0.9, 0, 0, 30)
			box.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
			box.TextColor3 = Color3.new(1, 1, 1)
			box.PlaceholderText = placeholder
			box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
			box.Text = defaultText
			box.Font = Enum.Font.GothamSemibold
			box.TextSize = 10
			box.ClearTextOnFocus = false
			Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

			box.FocusLost:Connect(function(enterPressed)
				callback(box.Text, enterPressed)
			end)

			return box
		end

		-- 9. Text Label / Hint / Credits
		function Tab:CreateLabel(lblConfig)
			if type(lblConfig) == "string" then
				lblConfig = { Text = lblConfig }
			end
			lblConfig = lblConfig or {}

			local lbl = Instance.new("TextLabel", Page)
			lbl.LayoutOrder = lblConfig.LayoutOrder or NextOrder()
			lbl.Size = UDim2.new(0.9, 0, 0, lblConfig.Height or 24)
			lbl.BackgroundTransparency = 1
			lbl.Text = lblConfig.Text or ""
			lbl.Font = lblConfig.Font or Enum.Font.Gotham
			lbl.TextSize = lblConfig.TextSize or 10
			lbl.TextWrapped = true
			lbl.TextColor3 = lblConfig.Color or Color3.fromRGB(140, 140, 140)
			return lbl
		end

		return Tab
	end

	return Window
end

return Library
