-- File: Example.lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AcelestuZ/GUI-Project-1/main/Main.lua"))()

local Window = Library:CreateWindow({
	Title = "MY UNIVERSAL HUB",
	Name = "MyUniversalHub_V1",
	ToggleKey = Enum.KeyCode.RightShift,
	FloatingButton = true,
	FloatText = "HUB",
	StartOpen = true
})

-- Create Tabs (You can create 2, 3, or 4+ tabs and they auto-resize!)
local MainTab = Window:CreateTab("MAIN")
local PlayerTab = Window:CreateTab("PLAYER")
local SettingsTab = Window:CreateTab("SETTINGS")

-- Sections
MainTab:CreateSection("COMBAT & ACTIONS")

-- Toggle
MainTab:CreateToggle({
	Name = "AUTO FARM",
	Default = false,
	Callback = function(state)
		print("Auto Farm is now:", state)
	end
})

-- Cycle Button
MainTab:CreateCycle({
	Name = "FARM SPEED",
	Options = {1, 2, 5, 10},
	DefaultIndex = 1,
	Suffix = "x",
	Callback = function(value)
		print("Selected multiplier:", value)
	end
})

-- Button
MainTab:CreateButton({
	Name = "COLLECT ALL ITEMS",
	Callback = function()
		Window:Notify({
			Title = "SUCCESS",
			Content = "Collected all items!",
			Duration = 3
		})
	end
})

-- Dropdown
MainTab:CreateDropdown({
	Name = "TEAM",
	Options = {"Pirates", "Marines", "Neutral"},
	Default = "Pirates",
	Callback = function(selected)
		print("Chosen team:", selected)
	end
})

-- Input Box
MainTab:CreateInput({
	Placeholder = "Enter target player...",
	Callback = function(text)
		print("Target set to:", text)
	end
})

-- Player Tab Sliders
PlayerTab:CreateSection("MOVEMENT")

PlayerTab:CreateSlider({
	Name = "WALKSPEED",
	Min = 16,
	Max = 200,
	Default = 16,
	Callback = function(val)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char:FindFirstChildOfClass("Humanoid").WalkSpeed = val
		end
	end
})

-- Settings Tab
SettingsTab:CreateSection("UI CONFIGURATION")

SettingsTab:CreateKeybind({
	Name = "UI TOGGLE KEY",
	Default = Enum.KeyCode.RightShift,
	IsUIToggle = true
})

SettingsTab:CreateLabel("FreeC GUI")
