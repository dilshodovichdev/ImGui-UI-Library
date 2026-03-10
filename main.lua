--[[
   ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ██╗   ██╗██╗
   ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██║   ██║██║
   ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║   ██║██║
   ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║   ██║██║
   ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ╚██████╔╝██║
   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝
   NexusUI v1.0 — Professional Roblox UI Library
--]]

local NexusUI = {}
NexusUI.__index = NexusUI
NexusUI.Version = "1.0.0"
NexusUI._windows = {}
NexusUI._notifications = {}
NexusUI._keybinds = {}

-- ──────────────────────────────────────────────────────────────────────────────
-- Services
-- ──────────────────────────────────────────────────────────────────────────────
local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local TS            = game:GetService("TweenService")
local RS            = game:GetService("RunService")
local TextService   = game:GetService("TextService")
local lp            = Players.LocalPlayer
local pg            = lp:WaitForChild("PlayerGui")

-- ──────────────────────────────────────────────────────────────────────────────
-- Utility
-- ──────────────────────────────────────────────────────────────────────────────
local function make(class, props, children)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	for _, child in ipairs(children or {}) do child.Parent = o end
	return o
end

local function tween(obj, props, t, style, dir)
	local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tw = TS:Create(obj, info, props)
	tw:Play()
	return tw
end

local function lerp(a, b, t) return a + (b - a) * t end

local function round(n, step)
	step = step or 1
	return math.floor(n / step + 0.5) * step
end

local function clamp(n, min, max) return math.max(min, math.min(max, n)) end

local function hexToRGB(hex)
	hex = hex:gsub("#", "")
	return Color3.fromRGB(
		tonumber("0x"..hex:sub(1,2)),
		tonumber("0x"..hex:sub(3,4)),
		tonumber("0x"..hex:sub(5,6))
	)
end

local function RGBtoHSV(r, g, b)
	r, g, b = r/255, g/255, b/255
	local max, min = math.max(r,g,b), math.min(r,g,b)
	local h, s, v = 0, 0, max
	local d = max - min
	s = max == 0 and 0 or d / max
	if max ~= min then
		if max == r then h = (g - b) / d + (g < b and 6 or 0)
		elseif max == g then h = (b - r) / d + 2
		else h = (r - g) / d + 4 end
		h = h / 6
	end
	return h, s, v
end

local function HSVtoRGB(h, s, v)
	local r, g, b
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p, q, t2 = v*(1-s), v*(1-f*s), v*(1-(1-f)*s)
	i = i % 6
	if i==0 then r,g,b=v,t2,p elseif i==1 then r,g,b=q,v,p
	elseif i==2 then r,g,b=p,v,t2 elseif i==3 then r,g,b=p,q,v
	elseif i==4 then r,g,b=t2,p,v else r,g,b=v,p,q end
	return Color3.fromRGB(r*255, g*255, b*255)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Themes
-- ──────────────────────────────────────────────────────────────────────────────
NexusUI.Themes = {
	Dark = {
		Background    = Color3.fromRGB(20, 20, 25),
		Surface       = Color3.fromRGB(28, 28, 35),
		Panel         = Color3.fromRGB(35, 35, 45),
		PanelAlt      = Color3.fromRGB(42, 42, 55),
		Border        = Color3.fromRGB(55, 55, 70),
		Accent        = Color3.fromRGB(99, 102, 241),
		AccentHover   = Color3.fromRGB(120, 124, 255),
		AccentDim     = Color3.fromRGB(60, 63, 160),
		Success       = Color3.fromRGB(34, 197, 94),
		Warning       = Color3.fromRGB(251, 191, 36),
		Danger        = Color3.fromRGB(239, 68, 68),
		Text          = Color3.fromRGB(240, 240, 248),
		TextMuted     = Color3.fromRGB(140, 140, 165),
		TextDisabled  = Color3.fromRGB(80, 80, 100),
		TitleBar      = Color3.fromRGB(25, 25, 32),
		TabActive     = Color3.fromRGB(99, 102, 241),
		TabInactive   = Color3.fromRGB(35, 35, 45),
		Font          = Enum.Font.GothamMedium,
		FontBold      = Enum.Font.GothamBold,
	},
	Light = {
		Background    = Color3.fromRGB(245, 245, 250),
		Surface       = Color3.fromRGB(255, 255, 255),
		Panel         = Color3.fromRGB(235, 235, 242),
		PanelAlt      = Color3.fromRGB(225, 225, 235),
		Border        = Color3.fromRGB(200, 200, 215),
		Accent        = Color3.fromRGB(99, 102, 241),
		AccentHover   = Color3.fromRGB(79, 82, 221),
		AccentDim     = Color3.fromRGB(199, 200, 255),
		Success       = Color3.fromRGB(22, 163, 74),
		Warning       = Color3.fromRGB(217, 119, 6),
		Danger        = Color3.fromRGB(220, 38, 38),
		Text          = Color3.fromRGB(15, 15, 25),
		TextMuted     = Color3.fromRGB(100, 100, 130),
		TextDisabled  = Color3.fromRGB(160, 160, 190),
		TitleBar      = Color3.fromRGB(220, 220, 235),
		TabActive     = Color3.fromRGB(99, 102, 241),
		TabInactive   = Color3.fromRGB(235, 235, 242),
		Font          = Enum.Font.GothamMedium,
		FontBold      = Enum.Font.GothamBold,
	},
	Midnight = {
		Background    = Color3.fromRGB(8, 8, 14),
		Surface       = Color3.fromRGB(14, 14, 22),
		Panel         = Color3.fromRGB(20, 20, 32),
		PanelAlt      = Color3.fromRGB(26, 26, 40),
		Border        = Color3.fromRGB(45, 45, 70),
		Accent        = Color3.fromRGB(168, 85, 247),
		AccentHover   = Color3.fromRGB(192, 120, 255),
		AccentDim     = Color3.fromRGB(90, 40, 140),
		Success       = Color3.fromRGB(34, 197, 94),
		Warning       = Color3.fromRGB(251, 191, 36),
		Danger        = Color3.fromRGB(239, 68, 68),
		Text          = Color3.fromRGB(230, 230, 245),
		TextMuted     = Color3.fromRGB(120, 120, 155),
		TextDisabled  = Color3.fromRGB(65, 65, 90),
		TitleBar      = Color3.fromRGB(12, 12, 20),
		TabActive     = Color3.fromRGB(168, 85, 247),
		TabInactive   = Color3.fromRGB(20, 20, 32),
		Font          = Enum.Font.GothamMedium,
		FontBold      = Enum.Font.GothamBold,
	},
	Emerald = {
		Background    = Color3.fromRGB(10, 18, 14),
		Surface       = Color3.fromRGB(14, 24, 18),
		Panel         = Color3.fromRGB(18, 32, 24),
		PanelAlt      = Color3.fromRGB(24, 40, 30),
		Border        = Color3.fromRGB(40, 70, 50),
		Accent        = Color3.fromRGB(16, 185, 129),
		AccentHover   = Color3.fromRGB(52, 211, 153),
		AccentDim     = Color3.fromRGB(8, 100, 70),
		Success       = Color3.fromRGB(34, 197, 94),
		Warning       = Color3.fromRGB(251, 191, 36),
		Danger        = Color3.fromRGB(239, 68, 68),
		Text          = Color3.fromRGB(220, 250, 235),
		TextMuted     = Color3.fromRGB(100, 150, 120),
		TextDisabled  = Color3.fromRGB(60, 90, 72),
		TitleBar      = Color3.fromRGB(10, 20, 15),
		TabActive     = Color3.fromRGB(16, 185, 129),
		TabInactive   = Color3.fromRGB(18, 32, 24),
		Font          = Enum.Font.GothamMedium,
		FontBold      = Enum.Font.GothamBold,
	},
}

NexusUI._theme = NexusUI.Themes.Dark

-- ──────────────────────────────────────────────────────────────────────────────
-- Root ScreenGui
-- ──────────────────────────────────────────────────────────────────────────────
local gui = make("ScreenGui", {
	Name = "NexusUI",
	Parent = pg,
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
})

local root = make("Frame", {
	Parent = gui,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 1,
})

-- Notification container
local notifContainer = make("Frame", {
	Parent = gui,
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 320, 1, 0),
	Position = UDim2.new(1, -330, 0, 0),
	ZIndex = 100,
})
local notifLayout = make("UIListLayout", {
	Parent = notifContainer,
	SortOrder = Enum.SortOrder.LayoutOrder,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	Padding = UDim.new(0, 8),
})
make("UIPadding", { Parent = notifContainer,
	PaddingBottom = UDim.new(0, 16),
	PaddingTop = UDim.new(0, 16),
})

-- ──────────────────────────────────────────────────────────────────────────────
-- API: SetTheme
-- ──────────────────────────────────────────────────────────────────────────────
function NexusUI.SetTheme(nameOrTable)
	if type(nameOrTable) == "string" then
		NexusUI._theme = NexusUI.Themes[nameOrTable] or NexusUI.Themes.Dark
	else
		NexusUI._theme = nameOrTable
	end
end

function NexusUI.GetTheme() return NexusUI._theme end

-- ──────────────────────────────────────────────────────────────────────────────
-- Notification System
-- ──────────────────────────────────────────────────────────────────────────────
local notifCount = 0
function NexusUI.Notify(cfg)
	cfg = cfg or {}
	local theme = NexusUI._theme
	local title   = cfg.Title or "Notification"
	local desc    = cfg.Description or ""
	local dur     = cfg.Duration or 4
	local ntype   = (cfg.Type or "info"):lower()
	local icon    = cfg.Icon

	local accentColor = theme.Accent
	if ntype == "success" then accentColor = theme.Success
	elseif ntype == "warning" then accentColor = theme.Warning
	elseif ntype == "error" or ntype == "danger" then accentColor = theme.Danger end

	notifCount = notifCount + 1
	local n = make("Frame", {
		Parent = notifContainer,
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 10, 0, 0),
		LayoutOrder = notifCount,
		ZIndex = 102,
	})
	make("UICorner", { Parent = n, CornerRadius = UDim.new(0, 10) })
	make("UIStroke", { Parent = n, Color = theme.Border, Thickness = 1, Transparency = 0.5 })

	-- Accent bar
	local bar = make("Frame", {
		Parent = n,
		Size = UDim2.new(0, 4, 1, -16),
		Position = UDim2.new(0, 0, 0, 8),
		BackgroundColor3 = accentColor,
		BorderSizePixel = 0,
		ZIndex = 103,
	})
	make("UICorner", { Parent = bar, CornerRadius = UDim.new(0, 4) })

	-- Title
	make("TextLabel", {
		Parent = n,
		Text = title,
		Size = UDim2.new(1, -64, 0, 20),
		Position = UDim2.new(0, 18, 0, 12),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = theme.Text,
		Font = theme.FontBold,
		TextSize = 14,
		ZIndex = 103,
	})
	-- Description
	make("TextLabel", {
		Parent = n,
		Text = desc,
		Size = UDim2.new(1, -32, 0, 28),
		Position = UDim2.new(0, 18, 0, 32),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = theme.TextMuted,
		Font = theme.Font,
		TextSize = 13,
		TextWrapped = true,
		ZIndex = 103,
	})
	-- Progress bar
	local prog = make("Frame", {
		Parent = n,
		Size = UDim2.new(1, -8, 0, 3),
		Position = UDim2.new(0, 4, 1, -7),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		ZIndex = 103,
	})
	make("UICorner", { Parent = prog, CornerRadius = UDim.new(1, 0) })
	local progFill = make("Frame", {
		Parent = prog,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = accentColor,
		BorderSizePixel = 0,
		ZIndex = 104,
	})
	make("UICorner", { Parent = progFill, CornerRadius = UDim.new(1, 0) })

	-- Slide in
	tween(n, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back)
	-- Progress drain
	tween(progFill, { Size = UDim2.new(0, 0, 1, 0) }, dur, Enum.EasingStyle.Linear)

	task.delay(dur, function()
		tween(n, { Position = UDim2.new(1, 10, 0, 0), BackgroundTransparency = 1 }, 0.3)
		task.delay(0.35, function() n:Destroy() end)
	end)
	return n
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Window Constructor
-- ──────────────────────────────────────────────────────────────────────────────
function NexusUI.CreateWindow(cfg)
	cfg = cfg or {}
	local theme       = cfg.Theme and (type(cfg.Theme)=="string" and NexusUI.Themes[cfg.Theme] or cfg.Theme) or NexusUI._theme
	local title       = cfg.Title or "NexusUI"
	local subtitle    = cfg.Subtitle or ""
	local width       = cfg.Width or 520
	local toggleKey   = cfg.ToggleKey or Enum.KeyCode.RightControl
	local startPos    = cfg.Position or UDim2.new(0.5, -width/2, 0.5, -280)
	local showLogo    = cfg.Logo ~= false
	local logoText    = cfg.LogoText or "N"
	local autoSave    = cfg.AutoSave or false

	-- ── Window frame ─────────────────────────────────────────────────────────
	local win = make("Frame", {
		Parent = root,
		Size = UDim2.new(0, width, 0, 560),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		Position = startPos,
		ClipsDescendants = true,
		ZIndex = 10,
	})
	make("UICorner",  { Parent = win, CornerRadius = UDim.new(0, 12) })
	make("UIStroke",  { Parent = win, Color = theme.Border, Thickness = 1.5, Transparency = 0.3 })

	-- Drop shadow
	local shadow = make("ImageLabel", {
		Parent = win,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 8),
		Size = UDim2.new(1, 40, 1, 40),
		ZIndex = 9,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
	})
	shadow.Parent = root
	shadow.ZIndex = 9

	-- ── Title bar ────────────────────────────────────────────────────────────
	local titleBar = make("Frame", {
		Parent = win,
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = theme.TitleBar,
		BorderSizePixel = 0,
		ZIndex = 12,
	})
	make("UICorner", { Parent = titleBar, CornerRadius = UDim.new(0, 12) })

	-- Fix bottom corners of titlebar
	make("Frame", {
		Parent = titleBar,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = theme.TitleBar,
		BorderSizePixel = 0,
		ZIndex = 12,
	})

	-- Logo badge
	if showLogo then
		local logoBg = make("Frame", {
			Parent = titleBar,
			Size = UDim2.new(0, 34, 0, 34),
			Position = UDim2.new(0, 12, 0.5, -17),
			BackgroundColor3 = theme.Accent,
			BorderSizePixel = 0,
			ZIndex = 13,
		})
		make("UICorner", { Parent = logoBg, CornerRadius = UDim.new(0, 8) })
		make("TextLabel", {
			Parent = logoBg,
			Text = logoText,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			Font = theme.FontBold,
			TextSize = 18,
			ZIndex = 14,
		})
	end

	local xOffset = showLogo and 56 or 14
	make("TextLabel", {
		Parent = titleBar,
		Text = title,
		Size = UDim2.new(0, 200, 0, 20),
		Position = UDim2.new(0, xOffset, 0, 10),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = theme.Text,
		Font = theme.FontBold,
		TextSize = 15,
		ZIndex = 13,
	})
	make("TextLabel", {
		Parent = titleBar,
		Text = subtitle,
		Size = UDim2.new(0, 240, 0, 16),
		Position = UDim2.new(0, xOffset, 0, 30),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = theme.TextMuted,
		Font = theme.Font,
		TextSize = 12,
		ZIndex = 13,
	})

	-- Close button
	local closeBtn = make("TextButton", {
		Parent = titleBar,
		Text = "✕",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -42, 0.5, -15),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Font = theme.FontBold,
		TextColor3 = theme.TextMuted,
		TextSize = 14,
		AutoButtonColor = false,
		ZIndex = 13,
	})
	make("UICorner", { Parent = closeBtn, CornerRadius = UDim.new(0, 8) })

	-- Minimize button
	local minBtn = make("TextButton", {
		Parent = titleBar,
		Text = "─",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -78, 0.5, -15),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Font = theme.FontBold,
		TextColor3 = theme.TextMuted,
		TextSize = 14,
		AutoButtonColor = false,
		ZIndex = 13,
	})
	make("UICorner", { Parent = minBtn, CornerRadius = UDim.new(0, 8) })

	-- ── Tab bar ──────────────────────────────────────────────────────────────
	local tabBar = make("Frame", {
		Parent = win,
		Size = UDim2.new(0, 140, 1, -54),
		Position = UDim2.new(0, 0, 0, 54),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 11,
	})
	make("UIStroke", { Parent = tabBar, Color = theme.Border, Thickness = 1, Transparency = 0.6, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })

	local tabListLayout = make("UIListLayout", {
		Parent = tabBar,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	})
	make("UIPadding", { Parent = tabBar,
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	})

	-- Tab content area
	local contentArea = make("Frame", {
		Parent = win,
		Size = UDim2.new(1, -140, 1, -54),
		Position = UDim2.new(0, 140, 0, 54),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ZIndex = 11,
		ClipsDescendants = true,
	})

	-- ── Drag ─────────────────────────────────────────────────────────────────
	do
		local dragging, dragOffset = false, Vector2.new()
		titleBar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragOffset = Vector2.new(
					i.Position.X - win.AbsolutePosition.X,
					i.Position.Y - win.AbsolutePosition.Y
				)
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				local sx = root.AbsoluteSize.X
				local sy = root.AbsoluteSize.Y
				local nx = clamp(i.Position.X - dragOffset.X, 0, sx - win.AbsoluteSize.X)
				local ny = clamp(i.Position.Y - dragOffset.Y, 0, sy - win.AbsoluteSize.Y)
				win.Position = UDim2.new(0, nx, 0, ny)
				shadow.Position = UDim2.new(0, nx + win.AbsoluteSize.X/2, 0, ny + win.AbsoluteSize.Y/2 + 8)
			end
		end)
		UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
	end

	-- ── Minimize ─────────────────────────────────────────────────────────────
	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			tween(win, { Size = UDim2.new(0, width, 0, 54) }, 0.25, Enum.EasingStyle.Quart)
		else
			tween(win, { Size = UDim2.new(0, width, 0, 560) }, 0.25, Enum.EasingStyle.Quart)
		end
	end)

	closeBtn.MouseEnter:Connect(function() tween(closeBtn, { BackgroundColor3 = theme.Danger }, 0.15) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, { BackgroundColor3 = theme.Panel }, 0.15) end)
	closeBtn.MouseButton1Click:Connect(function()
		tween(win, { Size = UDim2.new(0, width, 0, 0), BackgroundTransparency = 1 }, 0.2)
		task.delay(0.25, function() win:Destroy(); shadow:Destroy() end)
	end)

	UIS.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == toggleKey then
			win.Visible = not win.Visible
			shadow.Visible = win.Visible
		end
	end)

	-- ── Tabs ─────────────────────────────────────────────────────────────────
	local tabs       = {}
	local activeTab  = nil

	local winAPI = {}

	function winAPI:AddTab(tabCfg)
		tabCfg = tabCfg or {}
		local tabTitle = tabCfg.Title or ("Tab " .. tostring(#tabs + 1))
		local tabIcon  = tabCfg.Icon or ""

		-- Tab button
		local tabBtn = make("TextButton", {
			Parent = tabBar,
			Text = tabIcon ~= "" and (tabIcon .. "  " .. tabTitle) or tabTitle,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = theme.TabInactive,
			BorderSizePixel = 0,
			Font = theme.Font,
			TextColor3 = theme.TextMuted,
			TextSize = 13,
			AutoButtonColor = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 12,
			LayoutOrder = #tabs + 1,
		})
		make("UICorner", { Parent = tabBtn, CornerRadius = UDim.new(0, 8) })
		make("UIPadding", { Parent = tabBtn, PaddingLeft = UDim.new(0, 10) })

		-- Indicator
		local indicator = make("Frame", {
			Parent = tabBtn,
			Size = UDim2.new(0, 3, 0, 18),
			Position = UDim2.new(0, -3, 0.5, -9),
			BackgroundColor3 = theme.Accent,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 13,
		})
		make("UICorner", { Parent = indicator, CornerRadius = UDim.new(0, 4) })

		-- Tab page (scroll frame)
		local page = make("ScrollingFrame", {
			Parent = contentArea,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarImageColor3 = theme.Accent,
			ScrollBarThickness = 3,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = 12,
		})
		make("UIListLayout", {
			Parent = page,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		})
		make("UIPadding", { Parent = page,
			PaddingTop = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 12),
		})

		local tabObj = { btn = tabBtn, page = page, indicator = indicator, sections = {} }

		local function activate()
			if activeTab and activeTab ~= tabObj then
				activeTab.page.Visible = false
				tween(activeTab.btn, { BackgroundColor3 = theme.TabInactive, TextColor3 = theme.TextMuted }, 0.15)
				activeTab.indicator.Visible = false
			end
			activeTab = tabObj
			page.Visible = true
			tween(tabBtn, { BackgroundColor3 = theme.TabActive, TextColor3 = Color3.new(1,1,1) }, 0.15)
			indicator.Visible = true
		end

		tabBtn.MouseButton1Click:Connect(activate)
		tabBtn.MouseEnter:Connect(function()
			if activeTab ~= tabObj then
				tween(tabBtn, { BackgroundColor3 = theme.PanelAlt }, 0.1)
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if activeTab ~= tabObj then
				tween(tabBtn, { BackgroundColor3 = theme.TabInactive }, 0.1)
			end
		end)

		table.insert(tabs, tabObj)
		if #tabs == 1 then activate() end

		-- ── Section builder ───────────────────────────────────────────────────
		local tabAPI = {}
		tabAPI._page = page

		local function makeSection(sectionCfg)
			sectionCfg = sectionCfg or {}
			local secTitle   = sectionCfg.Title
			local collapsible = sectionCfg.Collapsible ~= false

			local secFrame = make("Frame", {
				Parent = page,
				BackgroundColor3 = theme.Surface,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 13,
			})
			make("UICorner", { Parent = secFrame, CornerRadius = UDim.new(0, 10) })
			make("UIStroke", { Parent = secFrame, Color = theme.Border, Thickness = 1, Transparency = 0.6 })

			local headerH = secTitle and 36 or 8
			local header
			if secTitle then
				header = make("TextButton", {
					Parent = secFrame,
					Text = secTitle,
					Size = UDim2.new(1, 0, 0, headerH),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = theme.FontBold,
					TextColor3 = theme.TextMuted,
					TextSize = 12,
					AutoButtonColor = false,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 14,
				})
				make("UIPadding", { Parent = header, PaddingLeft = UDim.new(0, 14) })
				-- arrow
				local arrow = make("TextLabel", {
					Parent = header,
					Text = "▾",
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -24, 0, 0),
					BackgroundTransparency = 1,
					TextColor3 = theme.TextMuted,
					Font = theme.Font,
					TextSize = 14,
					ZIndex = 14,
				})
				-- Divider
				make("Frame", {
					Parent = secFrame,
					Size = UDim2.new(1, -28, 0, 1),
					Position = UDim2.new(0, 14, 0, headerH - 1),
					BackgroundColor3 = theme.Border,
					BorderSizePixel = 0,
					ZIndex = 14,
					BackgroundTransparency = 0.5,
				})
			end

			local innerFrame = make("Frame", {
				Parent = secFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, headerH),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 14,
				ClipsDescendants = true,
			})
			make("UIListLayout", { Parent = innerFrame,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			})
			make("UIPadding", { Parent = innerFrame,
				PaddingLeft  = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop   = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 10),
			})

			local collapsed = false
			if header and collapsible then
				header.MouseButton1Click:Connect(function()
					collapsed = not collapsed
					innerFrame.Visible = not collapsed
					-- arrow rotate via text hack
					local arw = header:FindFirstChild("TextLabel")
					if arw then arw.Text = collapsed and "▸" or "▾" end
				end)
			end

			local sec = {}

			local function makeRow(icon, labelText)
				local row = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
					ZIndex = 15,
				})
				local lbl = make("TextLabel", {
					Parent = row,
					Text = (icon ~= "" and (icon .. "  ") or "") .. labelText,
					Size = UDim2.new(0.5, 0, 1, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.Text,
					Font = theme.Font,
					TextSize = 13,
					ZIndex = 15,
				})
				return row, lbl
			end

			-- ─── Toggle ───────────────────────────────────────────────────────
			function sec:Toggle(cfg2)
				cfg2 = cfg2 or {}
				local key = cfg2.Key or cfg2.Text or tostring(math.random(1e6))
				local val = cfg2.Default == true
				local row, lbl = makeRow(cfg2.Icon or "", cfg2.Text or "Toggle")

				local track = make("TextButton", {
					Parent = row,
					Size = UDim2.new(0, 44, 0, 24),
					Position = UDim2.new(1, -44, 0.5, -12),
					BackgroundColor3 = val and theme.Accent or theme.Panel,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 16,
				})
				make("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })
				local knob = make("Frame", {
					Parent = track,
					Size = UDim2.new(0, 18, 0, 18),
					Position = val and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderSizePixel = 0,
					ZIndex = 17,
				})
				make("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

				if cfg2.Description then
					lbl.Size = UDim2.new(0.5, 0, 0, 18)
					lbl.Position = UDim2.new(0, 0, 0, 4)
					row.Size = UDim2.new(1, 0, 0, 46)
					make("TextLabel", {
						Parent = row,
						Text = cfg2.Description,
						Size = UDim2.new(0.65, 0, 0, 14),
						Position = UDim2.new(0, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = theme.TextMuted,
						Font = theme.Font,
						TextSize = 11,
						ZIndex = 15,
					})
				end

				local ctrl = {}
				local function setVal(v, silent)
					val = v
					tween(track, { BackgroundColor3 = val and theme.Accent or theme.Panel }, 0.18)
					tween(knob,  { Position = val and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9) }, 0.18)
					if not silent then
						if cfg2.Callback then cfg2.Callback(val) end
						if val and cfg2.On then cfg2.On() end
						if not val and cfg2.Off then cfg2.Off() end
					end
				end
				track.MouseButton1Click:Connect(function() setVal(not val) end)
				ctrl.get = function() return val end
				ctrl.set = function(v) setVal(not not v, false) end
				ctrl.type = "toggle"
				return ctrl
			end

			-- ─── Slider ───────────────────────────────────────────────────────
			function sec:Slider(cfg2)
				cfg2 = cfg2 or {}
				local key  = cfg2.Key or cfg2.Text or tostring(math.random(1e6))
				local min  = cfg2.Min or 0
				local max  = cfg2.Max or 100
				local step = cfg2.Step or 1
				local val  = clamp(cfg2.Default or min, min, max)
				local fmt  = cfg2.Format or function(v) return tostring(v) end
				local suffix = cfg2.Suffix or ""

				local row = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 52),
					BackgroundTransparency = 1,
					ZIndex = 15,
				})
				local topRow = make("Frame", {
					Parent = row,
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundTransparency = 1,
					ZIndex = 15,
				})
				local lbl = make("TextLabel", {
					Parent = topRow,
					Text = (cfg2.Icon and (cfg2.Icon.."  ") or "") .. (cfg2.Text or "Slider"),
					Size = UDim2.new(0.7, 0, 1, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.Text,
					Font = theme.Font,
					TextSize = 13,
					ZIndex = 15,
				})
				local valLbl = make("TextLabel", {
					Parent = topRow,
					Text = fmt(val) .. suffix,
					Size = UDim2.new(0.3, 0, 1, 0),
					Position = UDim2.new(0.7, 0, 0, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextColor3 = theme.Accent,
					Font = theme.FontBold,
					TextSize = 13,
					ZIndex = 15,
				})
				local track = make("Frame", {
					Parent = row,
					Size = UDim2.new(1, 0, 0, 6),
					Position = UDim2.new(0, 0, 0, 32),
					BackgroundColor3 = theme.Panel,
					BorderSizePixel = 0,
					ZIndex = 15,
				})
				make("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })
				local fill = make("Frame", {
					Parent = track,
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = theme.Accent,
					BorderSizePixel = 0,
					ZIndex = 16,
				})
				make("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })
				local knob = make("Frame", {
					Parent = track,
					Size = UDim2.new(0, 16, 0, 16),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderSizePixel = 0,
					ZIndex = 17,
				})
				make("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })
				make("UIStroke", { Parent = knob, Color = theme.Accent, Thickness = 2 })

				local draggingSlider = false
				local function setFromPx(px)
					local pct = clamp(px / math.max(1, track.AbsoluteSize.X), 0, 1)
					local raw = min + (max - min) * pct
					val = clamp(round(raw, step), min, max)
					local p = (val - min) / (max - min)
					fill.Size = UDim2.new(p, 0, 1, 0)
					knob.Position = UDim2.new(p, 0, 0.5, 0)
					valLbl.Text = fmt(val) .. suffix
					if cfg2.Callback then cfg2.Callback(val) end
				end

				track.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = true
						setFromPx(i.Position.X - track.AbsolutePosition.X)
						tween(knob, { Size = UDim2.new(0,20,0,20) }, 0.1)
					end
				end)
				UIS.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 and draggingSlider then
						draggingSlider = false
						tween(knob, { Size = UDim2.new(0,16,0,16) }, 0.1)
					end
				end)
				UIS.InputChanged:Connect(function(i)
					if draggingSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
						setFromPx(i.Position.X - track.AbsolutePosition.X)
					end
				end)

				-- init
				task.defer(function() setFromPx(((val-min)/(max-min)) * track.AbsoluteSize.X) end)

				local ctrl = {}
				ctrl.get = function() return val end
				ctrl.set = function(v) val = clamp(v,min,max); task.defer(function() setFromPx(((val-min)/(max-min))*track.AbsoluteSize.X) end) end
				ctrl.type = "slider"
				return ctrl
			end

			-- ─── Button ───────────────────────────────────────────────────────
			function sec:Button(cfg2)
				cfg2 = cfg2 or {}
				local text = cfg2.Text or "Button"
				local style2 = (cfg2.Style or "primary"):lower()

				local bg = theme.Accent
				if style2 == "danger"  then bg = theme.Danger
				elseif style2 == "success" then bg = theme.Success
				elseif style2 == "secondary" then bg = theme.Panel end

				local row = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
					ZIndex = 15,
				})
				local btn = make("TextButton", {
					Parent = row,
					Text = (cfg2.Icon and (cfg2.Icon .. "  ") or "") .. text,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = bg,
					BorderSizePixel = 0,
					Font = theme.FontBold,
					TextColor3 = Color3.new(1,1,1),
					TextSize = 13,
					AutoButtonColor = false,
					ZIndex = 15,
				})
				make("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 8) })
				make("UIStroke", { Parent = btn, Color = Color3.new(1,1,1), Thickness = 1, Transparency = 0.85 })

				btn.MouseEnter:Connect(function() tween(btn, { BackgroundTransparency = 0.15 }, 0.1) end)
				btn.MouseLeave:Connect(function() tween(btn, { BackgroundTransparency = 0 }, 0.1) end)
				btn.MouseButton1Down:Connect(function() tween(btn, { Size = UDim2.new(0.97, 0, 0.9, 0), Position = UDim2.new(0.015, 0, 0.05, 0) }, 0.08) end)
				btn.MouseButton1Up:Connect(function()
					tween(btn, { Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0) }, 0.1)
					if cfg2.Callback then cfg2.Callback() end
				end)
				btn.MouseButton1Click:Connect(function()
					if cfg2.Callback then cfg2.Callback() end
				end)
				return btn
			end

			-- ─── Dropdown ─────────────────────────────────────────────────────
			function sec:Dropdown(cfg2)
				cfg2 = cfg2 or {}
				local options  = cfg2.Options or {}
				local multi    = cfg2.Multi == true
				local selected = cfg2.Default
				if multi then
					selected = cfg2.Default or {}
				end

				local row = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 56),
					BackgroundTransparency = 1,
					ZIndex = 15,
					ClipsDescendants = false,
				})
				make("TextLabel", {
					Parent = row,
					Text = (cfg2.Icon and (cfg2.Icon.."  ") or "")..(cfg2.Text or "Dropdown"),
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.Text,
					Font = theme.Font,
					TextSize = 13,
					ZIndex = 15,
				})
				local dispText = function()
					if multi then
						if #selected == 0 then return "None selected" end
						return table.concat(selected, ", ")
					else
						return selected or "Select..."
					end
				end
				local box = make("TextButton", {
					Parent = row,
					Text = dispText(),
					Size = UDim2.new(1, 0, 0, 32),
					Position = UDim2.new(0, 0, 0, 22),
					BackgroundColor3 = theme.Panel,
					BorderSizePixel = 0,
					Font = theme.Font,
					TextColor3 = selected and theme.Text or theme.TextMuted,
					TextSize = 13,
					AutoButtonColor = false,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 15,
				})
				make("UICorner", { Parent = box, CornerRadius = UDim.new(0, 8) })
				make("UIStroke", { Parent = box, Color = theme.Border, Thickness = 1, Transparency = 0.4 })
				make("UIPadding", { Parent = box, PaddingLeft = UDim.new(0, 12) })
				local arrow = make("TextLabel", {
					Parent = box,
					Text = "▾",
					Size = UDim2.new(0, 24, 1, 0),
					Position = UDim2.new(1, -28, 0, 0),
					BackgroundTransparency = 1,
					TextColor3 = theme.TextMuted,
					Font = theme.Font,
					TextSize = 14,
					ZIndex = 16,
				})

				-- Dropdown list
				local dropList = make("Frame", {
					Parent = row,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 58),
					BackgroundColor3 = theme.Surface,
					BorderSizePixel = 0,
					Visible = false,
					ClipsDescendants = true,
					ZIndex = 50,
				})
				make("UICorner",  { Parent = dropList, CornerRadius = UDim.new(0, 8) })
				make("UIStroke",  { Parent = dropList, Color = theme.Border, Thickness = 1, Transparency = 0.3 })
				local dropLayout = make("UIListLayout", {
					Parent = dropList,
					SortOrder = Enum.SortOrder.LayoutOrder,
				})
				make("UIPadding", { Parent = dropList,
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
				})

				local open = false
				local function buildList()
					for _, c in ipairs(dropList:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for i, opt in ipairs(options) do
						local isSelected = multi and table.find(selected, opt) or selected == opt
						local item = make("TextButton", {
							Parent = dropList,
							Text = (isSelected and "✓  " or "    ") .. opt,
							Size = UDim2.new(1, 0, 0, 32),
							BackgroundColor3 = isSelected and theme.AccentDim or theme.Surface,
							BorderSizePixel = 0,
							Font = theme.Font,
							TextColor3 = isSelected and theme.Text or theme.TextMuted,
							TextSize = 13,
							AutoButtonColor = false,
							TextXAlignment = Enum.TextXAlignment.Left,
							LayoutOrder = i,
							ZIndex = 51,
						})
						make("UIPadding", { Parent = item, PaddingLeft = UDim.new(0, 12) })
						item.MouseEnter:Connect(function()
							if not (multi and table.find(selected, opt)) and selected ~= opt then
								tween(item, { BackgroundColor3 = theme.PanelAlt }, 0.1)
							end
						end)
						item.MouseLeave:Connect(function()
							local isSel = multi and table.find(selected, opt) or selected == opt
							tween(item, { BackgroundColor3 = isSel and theme.AccentDim or theme.Surface }, 0.1)
						end)
						item.MouseButton1Click:Connect(function()
							if multi then
								local idx = table.find(selected, opt)
								if idx then table.remove(selected, idx) else table.insert(selected, opt) end
							else
								selected = opt
								open = false
								tween(dropList, { Size = UDim2.new(1,0,0,0) }, 0.15)
								task.delay(0.15, function() dropList.Visible = false end)
								tween(arrow, { Rotation = 0 }, 0.15)
							end
							box.Text = dispText()
							box.TextColor3 = theme.Text
							buildList()
							if cfg2.Callback then cfg2.Callback(selected) end
						end)
					end
					local totalH = #options * 32 + 8
					tween(dropList, { Size = UDim2.new(1,0,0,math.min(totalH, 180)) }, 0.2, Enum.EasingStyle.Quart)
				end

				box.MouseButton1Click:Connect(function()
					open = not open
					if open then
						dropList.Visible = true
						buildList()
						tween(arrow, { Rotation = 180 }, 0.15)
					else
						tween(dropList, { Size = UDim2.new(1,0,0,0) }, 0.15)
						task.delay(0.15, function() dropList.Visible = false end)
						tween(arrow, { Rotation = 0 }, 0.15)
					end
				end)

				-- Refresh options API
				local ctrl = {}
				ctrl.get = function() return selected end
				ctrl.set = function(v) selected = v; box.Text = dispText() end
				ctrl.setOptions = function(newOpts)
					options = newOpts
					selected = multi and {} or nil
					box.Text = dispText()
					if open then buildList() end
				end
				ctrl.type = "dropdown"
				return ctrl
			end

			-- ─── TextBox ──────────────────────────────────────────────────────
			function sec:TextBox(cfg2)
				cfg2 = cfg2 or {}
				local row = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 56),
					BackgroundTransparency = 1,
					ZIndex = 15,
				})
				make("TextLabel", {
					Parent = row,
					Text = (cfg2.Icon and (cfg2.Icon.."  ") or "") .. (cfg2.Text or "Text Input"),
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.Text,
					Font = theme.Font,
					TextSize = 13,
					ZIndex = 15,
				})
				local box = make("TextBox", {
					Parent = row,
					PlaceholderText = cfg2.Placeholder or "Type here...",
					Text = cfg2.Default or "",
					Size = UDim2.new(1, 0, 0, 32),
					Position = UDim2.new(0, 0, 0, 22),
					BackgroundColor3 = theme.Panel,
					BorderSizePixel = 0,
					Font = theme.Font,
					TextColor3 = theme.Text,
					PlaceholderColor3 = theme.TextMuted,
					TextSize = 13,
					ClearTextOnFocus = cfg2.ClearOnFocus ~= false,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 15,
				})
				make("UICorner", { Parent = box, CornerRadius = UDim.new(0, 8) })
				local stroke = make("UIStroke", { Parent = box, Color = theme.Border, Thickness = 1, Transparency = 0.4 })
				make("UIPadding", { Parent = box, PaddingLeft = UDim.new(0, 12) })

				box.Focused:Connect(function()
					tween(stroke, { Color = theme.Accent, Transparency = 0 }, 0.15)
				end)
				box.FocusLost:Connect(function(enter)
					tween(stroke, { Color = theme.Border, Transparency = 0.4 }, 0.15)
					if cfg2.Callback then cfg2.Callback(box.Text, enter) end
				end)

				local ctrl = {}
				ctrl.get  = function() return box.Text end
				ctrl.set  = function(v) box.Text = v end
				ctrl.type = "textbox"
				return ctrl
			end

			-- ─── ColorPicker ──────────────────────────────────────────────────
			function sec:ColorPicker(cfg2)
				cfg2 = cfg2 or {}
				local color = cfg2.Default or Color3.fromRGB(255, 100, 100)
				local h, s, v2 = RGBtoHSV(color.R*255, color.G*255, color.B*255)

				local row = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
					ZIndex = 15,
					ClipsDescendants = false,
				})
				make("TextLabel", {
					Parent = row,
					Text = (cfg2.Icon and (cfg2.Icon.."  ") or "") .. (cfg2.Text or "Color"),
					Size = UDim2.new(0.7, 0, 1, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.Text,
					Font = theme.Font,
					TextSize = 13,
					ZIndex = 15,
				})

				local preview = make("TextButton", {
					Parent = row,
					Text = "",
					Size = UDim2.new(0, 56, 0, 26),
					Position = UDim2.new(1, -56, 0.5, -13),
					BackgroundColor3 = color,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					ZIndex = 15,
				})
				make("UICorner", { Parent = preview, CornerRadius = UDim.new(0, 6) })
				make("UIStroke", { Parent = preview, Color = theme.Border, Thickness = 1, Transparency = 0.3 })

				-- Full picker panel
				local pickerPanel = make("Frame", {
					Parent = row,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 40),
					BackgroundColor3 = theme.Panel,
					BorderSizePixel = 0,
					Visible = false,
					ClipsDescendants = true,
					ZIndex = 40,
				})
				make("UICorner", { Parent = pickerPanel, CornerRadius = UDim.new(0, 10) })
				make("UIStroke", { Parent = pickerPanel, Color = theme.Border, Thickness = 1, Transparency = 0.3 })

				-- SV square
				local svSize = 160
				local svBox = make("ImageLabel", {
					Parent = pickerPanel,
					Size = UDim2.new(0, svSize, 0, svSize),
					Position = UDim2.new(0, 10, 0, 10),
					BackgroundColor3 = HSVtoRGB(h, 1, 1),
					BorderSizePixel = 0,
					Image = "rbxassetid://4155801252",
					ZIndex = 41,
				})
				make("UICorner", { Parent = svBox, CornerRadius = UDim.new(0, 6) })

				local svKnob = make("Frame", {
					Parent = svBox,
					Size = UDim2.new(0, 12, 0, 12),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(s, 0, 1-v2, 0),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderSizePixel = 0,
					ZIndex = 42,
				})
				make("UICorner", { Parent = svKnob, CornerRadius = UDim.new(1, 0) })
				make("UIStroke", { Parent = svKnob, Color = Color3.new(0,0,0), Thickness = 2 })

				-- Hue bar
				local hueBar = make("ImageLabel", {
					Parent = pickerPanel,
					Size = UDim2.new(0, 16, 0, svSize),
					Position = UDim2.new(0, svSize + 20, 0, 10),
					Image = "rbxassetid://698052001",
					BorderSizePixel = 0,
					ZIndex = 41,
					BackgroundColor3 = Color3.new(1,1,1),
				})
				make("UICorner", { Parent = hueBar, CornerRadius = UDim.new(0, 4) })

				local hueKnob = make("Frame", {
					Parent = hueBar,
					Size = UDim2.new(1, 4, 0, 4),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, h, 0),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderSizePixel = 0,
					ZIndex = 42,
				})
				make("UICorner", { Parent = hueKnob, CornerRadius = UDim.new(1, 0) })

				-- Hex input
				local hexBox = make("TextBox", {
					Parent = pickerPanel,
					Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
					Size = UDim2.new(0, svSize, 0, 28),
					Position = UDim2.new(0, 10, 0, svSize + 18),
					BackgroundColor3 = theme.PanelAlt,
					Font = Enum.Font.Code,
					TextColor3 = theme.Text,
					TextSize = 13,
					BorderSizePixel = 0,
					ZIndex = 41,
					TextXAlignment = Enum.TextXAlignment.Center,
					ClearTextOnFocus = false,
				})
				make("UICorner", { Parent = hexBox, CornerRadius = UDim.new(0, 6) })

				pickerPanel.Size = UDim2.new(1, 0, 0, svSize + 56)

				local function updateColor()
					color = HSVtoRGB(h, s, v2)
					preview.BackgroundColor3 = color
					svBox.BackgroundColor3 = HSVtoRGB(h, 1, 1)
					svKnob.Position = UDim2.new(s, 0, 1 - v2, 0)
					hueKnob.Position = UDim2.new(0.5, 0, h, 0)
					hexBox.Text = string.format("#%02X%02X%02X",
						math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
					if cfg2.Callback then cfg2.Callback(color) end
				end

				-- SV drag
				local svDragging = false
				svBox.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						svDragging = true
						local rel = i.Position - svBox.AbsolutePosition
						s = clamp(rel.X / svBox.AbsoluteSize.X, 0, 1)
						v2 = clamp(1 - rel.Y / svBox.AbsoluteSize.Y, 0, 1)
						updateColor()
					end
				end)
				UIS.InputChanged:Connect(function(i)
					if svDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						local rel = i.Position - svBox.AbsolutePosition
						s = clamp(rel.X / svBox.AbsoluteSize.X, 0, 1)
						v2 = clamp(1 - rel.Y / svBox.AbsoluteSize.Y, 0, 1)
						updateColor()
					end
				end)
				UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end end)

				-- Hue drag
				local hueDragging = false
				hueBar.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						hueDragging = true
						h = clamp((i.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
						updateColor()
					end
				end)
				UIS.InputChanged:Connect(function(i)
					if hueDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						h = clamp((i.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
						updateColor()
					end
				end)
				UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end end)

				-- Hex input
				hexBox.FocusLost:Connect(function()
					local ok, c = pcall(hexToRGB, hexBox.Text)
					if ok then
						color = c
						h, s, v2 = RGBtoHSV(color.R*255, color.G*255, color.B*255)
						updateColor()
					end
				end)

				-- Toggle picker
				local pickerOpen = false
				preview.MouseButton1Click:Connect(function()
					pickerOpen = not pickerOpen
					if pickerOpen then
						pickerPanel.Visible = true
						tween(pickerPanel, { Size = UDim2.new(1, 0, 0, svSize + 56) }, 0.2, Enum.EasingStyle.Quart)
						row.Size = UDim2.new(1, 0, 0, svSize + 100)
					else
						tween(pickerPanel, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
						task.delay(0.15, function()
							pickerPanel.Visible = false
							row.Size = UDim2.new(1, 0, 0, 36)
						end)
					end
				end)

				local ctrl = {}
				ctrl.get  = function() return color end
				ctrl.set  = function(c) color = c; h,s,v2 = RGBtoHSV(c.R*255,c.G*255,c.B*255); updateColor() end
				ctrl.type = "colorpicker"
				return ctrl
			end

			-- ─── Keybind ──────────────────────────────────────────────────────
			function sec:Keybind(cfg2)
				cfg2 = cfg2 or {}
				local bound = cfg2.Default or Enum.KeyCode.Unknown
				local listening = false

				local row = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
					ZIndex = 15,
				})
				make("TextLabel", {
					Parent = row,
					Text = (cfg2.Icon and (cfg2.Icon.."  ") or "") .. (cfg2.Text or "Keybind"),
					Size = UDim2.new(0.6, 0, 1, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.Text,
					Font = theme.Font,
					TextSize = 13,
					ZIndex = 15,
				})
				local keyBtn = make("TextButton", {
					Parent = row,
					Text = bound.Name,
					Size = UDim2.new(0, 90, 0, 28),
					Position = UDim2.new(1, -90, 0.5, -14),
					BackgroundColor3 = theme.Panel,
					BorderSizePixel = 0,
					Font = theme.FontBold,
					TextColor3 = theme.Accent,
					TextSize = 13,
					AutoButtonColor = false,
					ZIndex = 15,
				})
				make("UICorner", { Parent = keyBtn, CornerRadius = UDim.new(0, 6) })
				make("UIStroke", { Parent = keyBtn, Color = theme.Accent, Thickness = 1, Transparency = 0.5 })

				keyBtn.MouseButton1Click:Connect(function()
					listening = true
					keyBtn.Text = "..."
					keyBtn.TextColor3 = theme.Warning
				end)
				UIS.InputBegan:Connect(function(i, gp)
					if not listening then return end
					if i.UserInputType == Enum.UserInputType.Keyboard then
						bound = i.KeyCode
						listening = false
						keyBtn.Text = bound.Name
						keyBtn.TextColor3 = theme.Accent
						if cfg2.Callback then cfg2.Callback(bound) end
					end
				end)

				-- Bind action
				if cfg2.Action then
					UIS.InputBegan:Connect(function(i, gp)
						if gp then return end
						if i.KeyCode == bound then cfg2.Action() end
					end)
				end

				local ctrl = {}
				ctrl.get  = function() return bound end
				ctrl.set  = function(k) bound = k; keyBtn.Text = k.Name end
				ctrl.type = "keybind"
				return ctrl
			end

			-- ─── Label ────────────────────────────────────────────────────────
			function sec:Label(cfg2)
				if type(cfg2) == "string" then cfg2 = { Text = cfg2 } end
				local lbl = make("TextLabel", {
					Parent = innerFrame,
					Text = cfg2.Text or "",
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextColor3 = cfg2.Color or theme.TextMuted,
					Font = cfg2.Bold and theme.FontBold or theme.Font,
					TextSize = cfg2.Size or 13,
					TextWrapped = true,
					ZIndex = 15,
				})
				return lbl
			end

			-- ─── Paragraph ────────────────────────────────────────────────────
			function sec:Paragraph(cfg2)
				if type(cfg2) == "string" then cfg2 = { Content = cfg2 } end
				local frame = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					ZIndex = 15,
				})
				make("UIListLayout", { Parent = frame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
				if cfg2.Title then
					make("TextLabel", {
						Parent = frame,
						Text = cfg2.Title,
						Size = UDim2.new(1, 0, 0, 18),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = theme.Text,
						Font = theme.FontBold,
						TextSize = 14,
						ZIndex = 15,
					})
				end
				make("TextLabel", {
					Parent = frame,
					Text = cfg2.Content or "",
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextColor3 = theme.TextMuted,
					Font = theme.Font,
					TextSize = 13,
					TextWrapped = true,
					ZIndex = 15,
				})
				return frame
			end

			-- ─── Progress Bar ─────────────────────────────────────────────────
			function sec:ProgressBar(cfg2)
				cfg2 = cfg2 or {}
				local val = clamp(cfg2.Default or 0, 0, 100)

				local row = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 44),
					BackgroundTransparency = 1,
					ZIndex = 15,
				})
				make("TextLabel", {
					Parent = row,
					Text = (cfg2.Icon and (cfg2.Icon.."  ") or "") .. (cfg2.Text or "Progress"),
					Size = UDim2.new(0.7, 0, 0, 20),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.Text,
					Font = theme.Font,
					TextSize = 13,
					ZIndex = 15,
				})
				local pctLbl = make("TextLabel", {
					Parent = row,
					Text = tostring(val) .. "%",
					Size = UDim2.new(0.3, 0, 0, 20),
					Position = UDim2.new(0.7, 0, 0, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextColor3 = theme.Accent,
					Font = theme.FontBold,
					TextSize = 13,
					ZIndex = 15,
				})
				local track = make("Frame", {
					Parent = row,
					Size = UDim2.new(1, 0, 0, 8),
					Position = UDim2.new(0, 0, 0, 28),
					BackgroundColor3 = theme.Panel,
					BorderSizePixel = 0,
					ZIndex = 15,
				})
				make("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })
				local fill = make("Frame", {
					Parent = track,
					Size = UDim2.new(val / 100, 0, 1, 0),
					BackgroundColor3 = cfg2.Color or theme.Accent,
					BorderSizePixel = 0,
					ZIndex = 16,
				})
				make("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })

				local ctrl = {}
				ctrl.set = function(p)
					val = clamp(p, 0, 100)
					tween(fill, { Size = UDim2.new(val/100, 0, 1, 0) }, 0.3)
					pctLbl.Text = tostring(math.floor(val)) .. "%"
				end
				ctrl.get  = function() return val end
				ctrl.type = "progressbar"
				return ctrl
			end

			-- ─── Separator ────────────────────────────────────────────────────
			function sec:Separator(lText)
				local f = make("Frame", {
					Parent = innerFrame,
					Size = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					ZIndex = 15,
				})
				if lText then
					make("TextLabel", {
						Parent = f,
						Text = lText,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						TextColor3 = theme.TextDisabled,
						Font = theme.Font,
						TextSize = 11,
						ZIndex = 15,
					})
				else
					make("Frame", {
						Parent = f,
						Size = UDim2.new(1, 0, 0, 1),
						Position = UDim2.new(0, 0, 0.5, 0),
						BackgroundColor3 = theme.Border,
						BorderSizePixel = 0,
						ZIndex = 15,
						BackgroundTransparency = 0.5,
					})
				end
				return f
			end

			-- ─── ImageLabel ───────────────────────────────────────────────────
			function sec:Image(cfg2)
				cfg2 = cfg2 or {}
				local img = make("ImageLabel", {
					Parent = innerFrame,
					Image = cfg2.Asset or "",
					Size = UDim2.new(1, 0, 0, cfg2.Height or 100),
					BackgroundColor3 = theme.Panel,
					BorderSizePixel = 0,
					ScaleType = cfg2.ScaleType or Enum.ScaleType.Fit,
					ZIndex = 15,
				})
				make("UICorner", { Parent = img, CornerRadius = UDim.new(0, 8) })
				return img
			end

			return sec
		end

		-- AddSection is the main builder
		function tabAPI:AddSection(sectionCfg)
			return makeSection(sectionCfg)
		end

		-- Shortcut: add elements directly to tab (auto-section)
		function tabAPI:Toggle(cfg2)   local s = makeSection({}) return s:Toggle(cfg2) end
		function tabAPI:Slider(cfg2)   local s = makeSection({}) return s:Slider(cfg2) end
		function tabAPI:Button(cfg2)   local s = makeSection({}) return s:Button(cfg2) end
		function tabAPI:Dropdown(cfg2) local s = makeSection({}) return s:Dropdown(cfg2) end
		function tabAPI:TextBox(cfg2)  local s = makeSection({}) return s:TextBox(cfg2) end
		function tabAPI:Label(cfg2)    local s = makeSection({}) return s:Label(cfg2) end
		function tabAPI:Separator(t)   local s = makeSection({}) return s:Separator(t) end

		return tabAPI
	end

	-- ── Window helpers ────────────────────────────────────────────────────────
	function winAPI:SetVisible(v) win.Visible = not not v; shadow.Visible = win.Visible end
	function winAPI:IsVisible()   return win.Visible end
	function winAPI:Destroy()     win:Destroy(); shadow:Destroy() end
	function winAPI:SetTitle(t)   -- find title label and update
		for _, d in ipairs(titleBar:GetDescendants()) do
			if d:IsA("TextLabel") and d.Font == theme.FontBold and d.TextSize == 15 then
				d.Text = t; break
			end
		end
	end

	table.insert(NexusUI._windows, winAPI)

	-- Entrance animation
	win.BackgroundTransparency = 1
	win:TweenSize(UDim2.new(0, width, 0, 560), "Out", "Back", 0.4, true)
	tween(win, { BackgroundTransparency = 0 }, 0.3)

	return winAPI
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Convenience: destroy all windows
-- ──────────────────────────────────────────────────────────────────────────────
function NexusUI.DestroyAll()
	for _, w in ipairs(NexusUI._windows) do
		pcall(function() w:Destroy() end)
	end
	NexusUI._windows = {}
end

return NexusUI
