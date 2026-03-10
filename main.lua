local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local function make(class,props)
	local o=Instance.new(class)
	for k,v in pairs(props or {}) do o[k]=v end
	return o
end

local imgui = {}
imgui._windows = {}

local style = {
	bg = Color3.fromRGB(30,30,30),
	panel = Color3.fromRGB(40,40,40),
	accent = Color3.fromRGB(0,162,255),
	text = Color3.fromRGB(230,230,230),
	font = Enum.Font.Gotham
}

local gui = make("ScreenGui",{Name="imgui_root",Parent=pg,ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
local root = make("Frame",{Parent=gui,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)})

local function newWindow(title,opts)
	local w=make("Frame",{Parent=root,Size=UDim2.new(0,220,0,32),BackgroundColor3=style.bg,BorderSizePixel=0,Position=UDim2.new(0.1,0,0.1,0)})
	local bar=make("TextButton",{Parent=w,Text=title or "Window",Size=UDim2.new(1,0,0,26),BackgroundColor3=style.panel,BorderSizePixel=0,AutoButtonColor=false,Font=style.font,TextColor3=style.text,TextSize=14})
	local body=make("Frame",{Parent=w,Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,26),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y})
	local layout=make("UIListLayout",{Parent=body,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)})
	w.ClipsDescendants=true
	local dragging=false
	local dragOffset=Vector2.new()
	bar.MouseButton1Down:Connect(function(x)
		dragging=true
		dragOffset=Vector2.new(x.Position.X-w.AbsolutePosition.X,x.Position.Y-w.AbsolutePosition.Y)
		local conn
		conn=UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
				w.Position=UDim2.new(0,math.clamp(input.Position.X-dragOffset.X,0,root.AbsoluteSize.X-w.AbsoluteSize.X),0,math.clamp(input.Position.Y-dragOffset.Y,0,root.AbsoluteSize.Y-w.AbsoluteSize.Y))
			end
		end)
		UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; conn:Disconnect() end end)
	end)

	local function resize()
		w.Size=UDim2.new(0,math.max(220,w.AbsoluteSize.X),0,bar.AbsoluteSize.Y+body.AbsoluteSize.Y+12)
	end

	local controls = {}
	local api = {}

	function api:AddLabel(text)
		local l=make("TextLabel",{Parent=body,Text=text,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=style.text,Font=style.font,TextSize=14,AutomaticSize=Enum.AutomaticSize.Y})
		resize()
		return l
	end

	function api:Button(cfg)
		local text = cfg.Text or "Button"
		local cb = cfg.Callback
		local b=make("TextButton",{Parent=body,Text=text,Size=UDim2.new(1,0,0,28),BackgroundColor3=style.panel,BorderSizePixel=0,Font=style.font,TextColor3=style.text,TextSize=14})
		b.MouseButton1Click:Connect(function() if cb then cb() end end)
		resize()
		return b
	end

	function api:Toggle(cfg)
		local key = cfg.Key or cfg.Text or ("toggle"..tostring(#controls+1))
		local val = (cfg.Default and true) or false
		local f=make("Frame",{Parent=body,Size=UDim2.new(1,0,0,28),BackgroundTransparency=1})
		local lbl=make("TextLabel",{Parent=f,Text=cfg.Text or key,Size=UDim2.new(1,-34,1,0),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=style.text,Font=style.font,TextSize=14,Position=UDim2.new(0,8,0,0)})
		local btn=make("TextButton",{Parent=f,Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-28,0,2),BackgroundColor3=style.panel,BorderSizePixel=0,Text="",AutoButtonColor=false})
		local dot=make("Frame",{Parent=btn,Size=UDim2.new(0,12,0,12),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=style.bg,BorderSizePixel=0})
		local function update()
			if val then btn.BackgroundColor3=style.accent; dot.BackgroundColor3=Color3.new(1,1,1) else btn.BackgroundColor3=style.panel; dot.BackgroundColor3=style.bg end
		end
		btn.MouseButton1Click:Connect(function()
			val=not val
			update()
			if cfg.Callback then cfg.Callback(val) end
			if val and cfg.On then cfg.On() end
			if (not val) and cfg.Off then cfg.Off() end
		end)
		update()
		controls[key]= {type="toggle",get=function() return val end,set=function(v) val=not not v; update() if cfg.Callback then cfg.Callback(val) end end}
		resize()
		return controls[key]
	end

	function api:Slider(cfg)
		local key = cfg.Key or cfg.Text or ("slider"..tostring(#controls+1))
		local min = cfg.Min or 0
		local max = cfg.Max or 100
		local step = cfg.Step or 1
		local val = cfg.Default or min
		local f=make("Frame",{Parent=body,Size=UDim2.new(1,0,0,44),BackgroundTransparency=1})
		local lbl=make("TextLabel",{Parent=f,Text=(cfg.Text or key).."  "..tostring(val),Size=UDim2.new(1,-8,0,18),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=style.text,Font=style.font,TextSize=13,Position=UDim2.new(0,8,0,0)})
		local bar=make("Frame",{Parent=f,Size=UDim2.new(1,-16,0,10),Position=UDim2.new(0,8,0,22),BackgroundColor3=style.panel,BorderSizePixel=0})
		local fill=make("Frame",{Parent=bar,Size=UDim2.new(0,0,1,0),BackgroundColor3=style.accent,BorderSizePixel=0})
		local knob=make("TextButton",{Parent=bar,Size=UDim2.new(0,10,1,0),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0.5,0,0),BackgroundColor3=style.accent,Text="",AutoButtonColor=false})
		local dragging=false
		local function setValFromPx(px)
			local p = math.clamp(px / math.max(1,bar.AbsoluteSize.X),0,1)
			local raw = min + (max-min)*p
			if step>0 then raw = math.floor(raw/step+0.5)*step end
			val = math.clamp(raw,min,max)
			local pct = (val-min)/(max-min)
			fill.Size = UDim2.new(pct,0,1,0)
			knob.Position = UDim2.new(pct,0,0.5,0)
			lbl.Text = (cfg.Text or key).."  "..tostring(val)
			if cfg.Callback then cfg.Callback(val) end
		end
		bar.InputBegan:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setValFromPx(i.Position.X-bar.AbsolutePosition.X) end
		end)
		bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
		UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setValFromPx(i.Position.X-bar.AbsolutePosition.X) end end)
		controls[key] = {type="slider",get=function() return val end,set=function(v) val=v; setValFromPx(((val-min)/(max-min))*(bar.AbsoluteSize.X or 1)) end}
		setValFromPx(((val-min)/(max-min))*(bar.AbsoluteSize.X or 1))
		resize()
		return controls[key]
	end

	function api:Separator()
		local s=make("Frame",{Parent=body,Size=UDim2.new(1,0,0,6),BackgroundTransparency=1})
		make("Frame",{Parent=s,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,3),BackgroundColor3=style.panel,BorderSizePixel=0})
		resize()
		return s
	end

	function api:SetPos(x,y) w.Position=UDim2.new(0,x,0,y) end
	function api:SetVisible(v) w.Visible = not not v end
	function api:GetControl(key) return controls[key] end
	function api:Destroy() w:Destroy() end

	table.insert(imgui._windows,{win=w,api=api})
	return api
end

imgui.CreateWindow = newWindow

function imgui.CreateWindowFromConfig(title,config)
	local win = imgui.CreateWindow(title)
	for _,c in ipairs(config or {}) do
		local t = (c.Type or "Label"):lower()
		if t=="label" then win:AddLabel(c.Text or "") end
		if t=="button" then win:Button(c) end
		if t=="toggle" then win:Toggle(c) end
		if t=="slider" then win:Slider(c) end
		if t=="sep" or t=="separator" then win:Separator() end
	end
	return win
end

UIS.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==Enum.KeyCode.RightControl then for _,v in pairs(imgui._windows) do v.win.Visible = not v.win.Visible end end end)

return imgui
