-- Robust Executor Compatibility Layer
local getgenv = getgenv or function() return _G end
local writefile = writefile or (appendfile or function() end)
local readfile = readfile or function() return "" end
local isfile = isfile or function() return false end
local makefolder = makefolder or function() end
local listfiles = listfiles or function() return {} end
local gethui = gethui or function() return (game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")) end
local request = (syn and syn.request) or (http and http.request) or http_request or (Fluxus and Fluxus.request) or request or function() end
-- mousemoverel and mouse1click fallbacks removed to allow accurate feature detection

-- Drawing API Fallback (ScreenGui based)
local Drawing = Drawing or (function()
    local D = {}
    local ui = Instance.new("ScreenGui")
    ui.Name = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
    ui.IgnoreGuiInset = true; ui.DisplayOrder = 1000; ui.Parent = gethui()
    local gl = getgenv().XenoDXGuis or {}; table.insert(gl, ui); getgenv().XenoDXGuis = gl
    
    function D.new(t)
        local obj = {Visible = false, Transparency = 1, Color = Color3.new(1,1,1), ZIndex = 0}
        local frame = nil
        if t == "Line" then
            frame = Instance.new("Frame"); frame.AnchorPoint = Vector2.new(0, 0.5); frame.BorderSizePixel = 0; frame.Parent = ui
            local line = {From = Vector2.new(0,0), To = Vector2.new(0,0), Thickness = 1}
            setmetatable(obj, {
                __index = function(_, k) if k=="From" then return line.From elseif k=="To" then return line.To elseif k=="Thickness" then return line.Thickness else return obj[k] end end,
                __newindex = function(_, k, v)
                    if k=="From" then line.From = v elseif k=="To" then line.To = v elseif k=="Thickness" then line.Thickness = v elseif k=="Visible" then obj.Visible = v frame.Visible = v elseif k=="Color" then obj.Color = v frame.BackgroundColor3 = v elseif k=="Transparency" then obj.Transparency = v frame.BackgroundTransparency = 1-v end
                    if line.From and line.To then
                        local mag = (line.To - line.From).Magnitude
                        frame.Size = UDim2.new(0, mag, 0, line.Thickness)
                        frame.Position = UDim2.new(0, line.From.X, 0, line.From.Y)
                        frame.Rotation = math.deg(math.atan2(line.To.Y - line.From.Y, line.To.X - line.From.X))
                    end
                end
            }) 
        elseif t == "Circle" then
            frame = Instance.new("Frame"); frame.AnchorPoint = Vector2.new(0.5, 0.5); frame.BorderSizePixel = 0; frame.Parent = ui
            Instance.new("UICorner", frame).CornerRadius = UDim.new(1,0)
            local circ = {Position = Vector2.new(0,0), Radius = 10}
            setmetatable(obj, {
                __index = function(_, k) if k=="Position" then return circ.Position elseif k=="Radius" then return circ.Radius else return obj[k] end end,
                __newindex = function(_, k, v)
                    if k=="Position" then circ.Position = v frame.Position = UDim2.new(0, v.X, 0, v.Y) elseif k=="Radius" then circ.Radius = v frame.Size = UDim2.new(0, v*2, 0, v*2) elseif k=="Visible" then obj.Visible = v frame.Visible = v elseif k=="Color" then obj.Color = v frame.BackgroundColor3 = v elseif k=="Transparency" then obj.Transparency = v frame.BackgroundTransparency = 1-v end
                end
            })
        elseif t == "Square" then
            frame = Instance.new("Frame"); frame.BorderSizePixel = 0; frame.Parent = ui
            local sq = {Position = Vector2.new(0,0), Size = Vector2.new(0,0), Filled = false}
            setmetatable(obj, {
                __index = function(_, k) if k=="Position" then return sq.Position elseif k=="Size" then return sq.Size elseif k=="Filled" then return sq.Filled else return obj[k] end end,
                __newindex = function(_, k, v)
                    if k=="Position" then sq.Position = v frame.Position = UDim2.new(0, v.X, 0, v.Y) elseif k=="Size" then sq.Size = v frame.Size = UDim2.new(0, v.X, 0, v.Y) elseif k=="Visible" then obj.Visible = v frame.Visible = v elseif k=="Color" then obj.Color = v frame.BackgroundColor3 = v elseif k=="Transparency" then obj.Transparency = v frame.BackgroundTransparency = 1-v elseif k=="Filled" then sq.Filled = v frame.BackgroundTransparency = v and 0 or (obj.Transparency or 0) end
                end
            })
        elseif t == "Text" then
            frame = Instance.new("TextLabel"); frame.BackgroundTransparency = 1; frame.Parent = ui
            local txt = {Position = Vector2.new(0,0), Text = "", Size = 16}
            setmetatable(obj, {
                __index = function(_, k) if k=="Position" then return txt.Position elseif k=="Text" then return txt.Text elseif k=="Size" then return txt.Size else return obj[k] end end,
                __newindex = function(_, k, v)
                    if k=="Position" then txt.Position = v frame.Position = UDim2.new(0, v.X, 0, v.Y) elseif k=="Text" then txt.Text = v frame.Text = v elseif k=="Size" then txt.Size = v frame.TextSize = v elseif k=="Visible" then obj.Visible = v frame.Visible = v elseif k=="Color" then obj.Color = v frame.TextColor3 = v elseif k=="Transparency" then obj.Transparency = v frame.TextTransparency = 1-v end
                end
            })
        end
        function obj:Remove() if frame then frame:Destroy() end end
        return obj
    end
    return D
end)()

pcall(function() if getgenv().XenoDXCleanup then getgenv().XenoDXCleanup() end end)

local CORRECT_KEY = "AKI1-69IK"

local function startScript()
    print("DX: startScript initiated")
    getgenv().XenoDXRunning = true 

    local connections = {}
    getgenv().XenoDXCleanup = function()
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        local function cleanESP(cache)
            if cache then for _, x in pairs(cache) do
                if type(x) == "table" then
                    if x.L then for _, l in pairs(x.L) do pcall(function() l:Remove() end) end end
                    if x.A then pcall(function() x.A:Remove() end) end
                    if x.N then pcall(function() x.N:Remove() end) end
                    if x.HB then pcall(function() x.HB:Remove() end) end
                    if x.HF then pcall(function() x.HF:Remove() end) end
                end
            end end
        end
        cleanESP(getgenv().XBoxESP); cleanESP(getgenv().XAdvESP)
        local function killGui(name)
            pcall(function() local p = gethui and gethui() or game:GetService("CoreGui"); local g = p:FindFirstChild(name); if g then g:Destroy() end end)
            pcall(function() local pg = game:GetService("Players").LocalPlayer.PlayerGui; local g = pg:FindFirstChild(name); if g then g:Destroy() end end)
        end
        killGui("DXPanel"); killGui("DXFovCircle"); killGui("DXDrawingLayer")
        if getgenv().XenoDXGuis then
            for _, g in ipairs(getgenv().XenoDXGuis) do pcall(function() g:Destroy() end) end
            getgenv().XenoDXGuis = {}
        end
        pcall(function() game:GetService("RunService"):UnbindFromRenderStep("DXAimbotLock") end)
        if getgenv().DXAimLockName then pcall(function() game:GetService("RunService"):UnbindFromRenderStep(getgenv().DXAimLockName) end) end
    end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then Players:GetPropertyChangedSignal("LocalPlayer"):Wait(); LocalPlayer = Players.LocalPlayer end

    local S = {
        BoxESP=false, BoxCol=Color3.new(1,1,1), SkeletonESP=false, SkelCol=Color3.new(1,1,1),
        AccurateHead=false, AccCol=Color3.new(1,1,1), NormalHead=false, NormCol=Color3.new(1,1,1),
        Aimbot=false, AimbotPart="Head", AimKey=Enum.UserInputType.MouseButton2,
        AimbotMethod=UIS.TouchEnabled and "Camera" or "Mouse", AimMode="Hold",
        Smoothness=6, AimOffset=0, ShowFov=false, FovRadius=100,
        Triggerbot=false, TriggerKey=Enum.KeyCode.T, TriggerAlwaysOn=false, TriggerDelay=50,
        HudBg=Color3.fromRGB(20,20,20), HudBar=Color3.fromRGB(30,30,30),
        HudTabs=Color3.fromRGB(23,23,23), HudAccent=Color3.fromRGB(0,170,255),
        HealthESP=false, HealthCol=Color3.new(1,1,1),
        HudFov=Color3.new(1,1,1),
    }

    local CONFIG_FILE = "DXPanel_config.txt"
    local function serializeColor(c) return c.R..","..c.G..","..c.B end
    local function deserializeColor(s) local r,g,b = s:match("([^,]+),([^,]+),([^,]+)"); return Color3.new(tonumber(r),tonumber(g),tonumber(b)) end

    local function configToString()
        local lines = {}
        for _, k in ipairs({"BoxESP","SkeletonESP","AccurateHead","NormalHead","Aimbot","ShowFov","Triggerbot","TriggerAlwaysOn","HealthESP"}) do
            table.insert(lines, k.."="..tostring(S[k]))
        end
        for _, k in ipairs({"Smoothness","AimOffset","FovRadius","TriggerDelay"}) do
            table.insert(lines, k.."="..tostring(S[k]))
        end
        for _, k in ipairs({"BoxCol","SkelCol","AccCol","NormCol","HudBg","HudBar","HudTabs","HudAccent","HudFov","HealthCol"}) do
            table.insert(lines, k.."="..serializeColor(S[k]))
        end
        table.insert(lines, "AimbotPart="..tostring(S.AimbotPart))
        table.insert(lines, "AimbotMethod="..tostring(S.AimbotMethod))
        table.insert(lines, "AimMode="..tostring(S.AimMode))
        table.insert(lines, "AimKey="..S.AimKey.Name)
        table.insert(lines, "TriggerKey="..S.TriggerKey.Name)
        return table.concat(lines, "\n")
    end

    local function applyConfigString(data, toggleButtons)
        for line in data:gmatch("[^\n]+") do
            local k, v = line:match("^(.-)=(.+)$")
            if k and v and S[k] ~= nil then
                if v == "true" then S[k] = true
                elseif v == "false" then S[k] = false
                elseif tonumber(v) then 
                    S[k] = tonumber(v)
                    if k == "Smoothness" and S[k] < 6 then S[k] = 6 end
                elseif v:match("^[%d%.]+,[%d%.]+,[%d%.]+$") then S[k] = deserializeColor(v)
                elseif k == "AimbotPart" or k == "AimbotMethod" or k == "AimMode" then S[k] = v
                elseif k == "AimKey" then pcall(function() S[k] = Enum.UserInputType[v] or Enum.KeyCode[v] end)
                elseif k == "TriggerKey" then pcall(function() S[k] = Enum.KeyCode[v] or Enum.UserInputType[v] end)
                end
            end
        end
        if toggleButtons then
            for _, tb in ipairs(toggleButtons) do pcall(function()
                local val = S[tb.k]; tb.b.Text = tb.n..": "..(val and "ON" or "OFF")
                tb.b.BackgroundColor3 = val and S.HudAccent or Color3.fromRGB(45,45,45)
            end) end
        end
    end

    -- ── GUI ────────────────────────────────────────────────────────────────────
    local gui = Instance.new("ScreenGui")
    gui.Name = game:GetService("HttpService"):GenerateGUID(false):gsub("-", ""); gui.ResetOnSpawn = false; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Enabled = true
    local gl2 = getgenv().XenoDXGuis or {}; table.insert(gl2, gui); getgenv().XenoDXGuis = gl2
    
    local function create(c, p) 
        local i = Instance.new(c)
        for k,v in pairs(p) do 
            if k=="Parent" then pcall(function() i.Parent=v end) 
            else pcall(function() i[k]=v end) end 
        end
        if p.Visible == nil then pcall(function() i.Visible = true end) end
        return i 
    end

    local cam = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
    local viewportSize = cam and cam.ViewportSize or Vector2.new(800, 600)
    local bg = create("Frame", {Parent=gui, Size=UDim2.new(0,math.min(520, viewportSize.X - 20),0,math.min(420, viewportSize.Y - 20)), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=S.HudBg, Active=true, Visible=true})
    create("UICorner", {Parent=bg, CornerRadius=UDim.new(0,12)})
    local top = create("Frame", {Parent=bg, Size=UDim2.new(1,0,0,35), BackgroundColor3=S.HudBar})
    create("UICorner", {Parent=top, CornerRadius=UDim.new(0,12)})
    local topFill = create("Frame", {Parent=top, Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,1,-12), BackgroundColor3=S.HudBar, BorderSizePixel=0})
    create("TextLabel", {Parent=top, Text="Dvd's Panel", Font=Enum.Font.GothamBold, TextSize=16, TextColor3=Color3.new(1,1,1), BackgroundTransparency=1, Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,15,0,0), TextXAlignment=Enum.TextXAlignment.Left})

    local minBtn = create("TextButton", {Parent=top, Text="-", Font=Enum.Font.GothamBold, TextSize=20, TextColor3=Color3.new(1,1,1), BackgroundTransparency=1, Size=UDim2.new(0,35,0,35), Position=UDim2.new(1,-35,0,0)})
    local isMin = false

    local tH = create("Frame", {Parent=bg, Size=UDim2.new(0,130,1,-35), Position=UDim2.new(0,0,0,35), BackgroundColor3=S.HudTabs, BorderSizePixel=0})
    create("UICorner", {Parent=tH, CornerRadius=UDim.new(0,12)})
    local tHFillR = create("Frame", {Parent=tH, Size=UDim2.new(0,12,1,0), Position=UDim2.new(1,-12,0,0), BackgroundColor3=S.HudTabs, BorderSizePixel=0})
    local tHFillT = create("Frame", {Parent=tH, Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,0,0), BackgroundColor3=S.HudTabs, BorderSizePixel=0})
    local sepLine = create("Frame", {Parent=bg, Size=UDim2.new(0,1,1,-35), Position=UDim2.new(0,130,0,35), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0})
    local pH = create("Frame", {Parent=bg, Size=UDim2.new(1,-131,1,-35), Position=UDim2.new(0,131,0,35), BackgroundTransparency=1})

    minBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "+" or "-"
        bg.Size = isMin and UDim2.new(0,520,0,35) or UDim2.new(0,520,0,420)
        tH.Visible = not isMin; pH.Visible = not isMin; sepLine.Visible = not isMin
    end)

    local tabs = {}
    local function selectTab(idx)
        for i,v in ipairs(tabs) do 
            v.b.BackgroundColor3 = (i == idx) and S.HudAccent or Color3.fromRGB(35,35,35)
            v.p.Visible = (i == idx) 
        end
    end

    local function makeTab(n, idx)
        local btn = create("TextButton", {Parent=tH, Size=UDim2.new(1,-16,0,36), Position=UDim2.new(0,8,0,10+(idx*42)), Text=n, Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=Color3.fromRGB(220,220,220), BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0})
        create("UICorner", {Parent=btn, CornerRadius=UDim.new(0,8)})
        local pg = create("Frame", {Parent=pH, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false})
        local tabIndex = #tabs + 1
        table.insert(tabs, {b=btn, p=pg})
        btn.MouseButton1Click:Connect(function() selectTab(tabIndex) end)
        return pg
    end
    local pAim, pVis, pMs, pCfg, pHud = makeTab("Aim",0), makeTab("Visuals",1), makeTab("Misc",2), makeTab("Config",3), makeTab("HUD",4)
    selectTab(1)

    local allToggleButtons = {}
    local function toggle(p, n, y, x, k)
        local b = create("TextButton", {Parent=p, Size=UDim2.new(0.42,0,0,32), Position=UDim2.new(x,0,0,y), Text=n..": OFF", Font=Enum.Font.GothamMedium, TextSize=12, BackgroundColor3=Color3.fromRGB(45,45,45), TextColor3=Color3.new(1,1,1), BorderSizePixel=0})
        create("UICorner", {Parent=b, CornerRadius=UDim.new(0,8)})
        b.MouseButton1Click:Connect(function()
            S[k]=not S[k]; b.Text=n..": "..(S[k] and "ON" or "OFF")
            b.BackgroundColor3=S[k] and S.HudAccent or Color3.fromRGB(45,45,45)
        end)
        table.insert(allToggleButtons, {b=b, k=k, n=n})
    end
    local function slider(p, n, y, mi, ma, isF, k)
        local l = create("TextLabel", {Parent=p, Text=n..": "..tostring(S[k]), Size=UDim2.new(0.9,0,0,20), Position=UDim2.new(0.05,0,0,y), Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=Color3.new(1,1,1), BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left})
        local slBg = create("Frame", {Parent=p, Size=UDim2.new(0.9,0,0,10), Position=UDim2.new(0.05,0,0,y+22), BackgroundColor3=Color3.fromRGB(40,40,40)})
        create("UICorner", {Parent=slBg, CornerRadius=UDim.new(1,0)})
        local f = create("Frame", {Parent=slBg, Size=UDim2.new((S[k]-mi)/(ma-mi),0,1,0), BackgroundColor3=S.HudAccent})
        create("UICorner", {Parent=f, CornerRadius=UDim.new(1,0)})
        local d = false
        slBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true end end)
        table.insert(connections, UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end))
        table.insert(connections, UIS.InputChanged:Connect(function(i) if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local pos=math.clamp((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X,0,1); f.Size=UDim2.new(pos,0,1,0); local val=mi+pos*(ma-mi); val=isF and math.floor(val*10)/10 or math.floor(val); l.Text=n..": "..tostring(val); S[k]=val end end))
    end
    local function rgbSlider(p, n, y, x, k, onChange)
        local l = create("TextLabel", {Parent=p, Text=n, Size=UDim2.new(0.42,0,0,20), Position=UDim2.new(x,0,0,y), Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=S[k], TextStrokeTransparency=0.5, BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left})
        local function mk(oy, comp, cCol)
            local sb = create("Frame", {Parent=p, Size=UDim2.new(0.42,0,0,6), Position=UDim2.new(x,0,0,y+oy), BackgroundColor3=Color3.fromRGB(50,50,50)}); create("UICorner", {Parent=sb, CornerRadius=UDim.new(1,0)})
            local val = (comp=="R") and S[k].R or (comp=="G") and S[k].G or S[k].B
            local f = create("Frame", {Parent=sb, Size=UDim2.new(val,0,1,0), BackgroundColor3=cCol}); create("UICorner", {Parent=f, CornerRadius=UDim.new(1,0)})
            local d = false
            sb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true end end)
            table.insert(connections, UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end))
            table.insert(connections, UIS.InputChanged:Connect(function(i)
                if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local pos=math.clamp((i.Position.X-sb.AbsolutePosition.X)/sb.AbsoluteSize.X,0,1)
                    f.Size=UDim2.new(pos,0,1,0)
                    local cv=S[k]; S[k]=comp=="R" and Color3.new(pos,cv.G,cv.B) or comp=="G" and Color3.new(cv.R,pos,cv.B) or Color3.new(cv.R,cv.G,pos)
                    l.TextColor3=S[k]
                    if onChange then pcall(function() onChange(S[k]) end) end
                end
            end))
        end
        mk(22,"R",Color3.new(1,0,0)); mk(30,"G",Color3.new(0,1,0)); mk(38,"B",Color3.new(0,0,1))
    end
    local kN = {Zero="0",One="1",Two="2",Three="3",Four="4",Five="5",Six="6",Seven="7",Eight="8",Nine="9",MouseButton1="MB1",MouseButton2="MB2",LeftShift="LShift",RightShift="RShift",LeftControl="LCtrl",RightControl="RCtrl",LeftAlt="LAlt",RightAlt="RAlt",Return="Enter",Escape="Esc",Minus="-",Equals="=",LeftBracket="[",RightBracket="]",Backslash="\\",Semicolon=";",Quote="'",Comma=",",Period=".",Slash="/"}
    local function keybind(p, n, x, y, w, kName)
        local f = create("Frame", {Parent=p, BackgroundTransparency=1, Size=UDim2.new(w,0,0,32), Position=UDim2.new(x,0,0,y)})
        create("TextLabel", {Parent=f, Text=n..":", Size=UDim2.new(0.5,-5,1,0), Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=Color3.new(1,1,1), BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left})
        local b = create("TextButton", {Parent=f, Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0.5,0,0,0), Text=kN[S[kName].Name] or S[kName].Name, Font=Enum.Font.GothamMedium, TextSize=12, BackgroundColor3=Color3.fromRGB(45,45,45), TextColor3=Color3.new(1,1,1), BorderSizePixel=0})
        create("UICorner", {Parent=b, CornerRadius=UDim.new(0,8)})
        local bd = false
        b.MouseButton1Click:Connect(function() task.wait(0.1); bd=true; b.Text="..." end)
        table.insert(connections, UIS.InputBegan:Connect(function(i) if bd then local k=i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType; if k.Name~="MouseMovement" then bd=false; S[kName]=k; b.Text=kN[k.Name] or k.Name end end end))
    end

    toggle(pAim,"Enable Aim",15,0.05,"Aimbot"); toggle(pAim,"Show FOV",15,0.52,"ShowFov")
    local tgtBtn = create("TextButton", {Parent=pAim, Size=UDim2.new(0.42,0,0,32), Position=UDim2.new(0.05,0,0,60), Text="Target: Head", Font=Enum.Font.GothamMedium, TextSize=12, BackgroundColor3=Color3.fromRGB(45,45,45), TextColor3=Color3.new(1,1,1), BorderSizePixel=0}); create("UICorner", {Parent=tgtBtn, CornerRadius=UDim.new(0,8)})
    tgtBtn.MouseButton1Click:Connect(function() 
        if S.AimbotPart=="Head" then S.AimbotPart="Torso" 
        elseif S.AimbotPart=="Torso" then S.AimbotPart="HumanoidRootPart" 
        else S.AimbotPart="Head" end
        pcall(function() tgtBtn.Text="Target: "..S.AimbotPart end) 
    end)
    keybind(pAim,"Aim Key",0.52,60,0.42,"AimKey")
    local methodBtn = create("TextButton", {Parent=pAim, Size=UDim2.new(0.42,0,0,32), Position=UDim2.new(0.05,0,0,98), Text="Method: "..S.AimbotMethod, Font=Enum.Font.GothamMedium, TextSize=12, BackgroundColor3=Color3.fromRGB(45,45,45), TextColor3=Color3.new(1,1,1), BorderSizePixel=0}); create("UICorner", {Parent=methodBtn, CornerRadius=UDim.new(0,8)})
    methodBtn.MouseButton1Click:Connect(function() S.AimbotMethod = S.AimbotMethod == "Mouse" and "Camera" or "Mouse"; pcall(function() methodBtn.Text="Method: "..S.AimbotMethod end) end)

    local modeBtn = create("TextButton", {Parent=pAim, Size=UDim2.new(0.42,0,0,32), Position=UDim2.new(0.52,0,0,98), Text="Mode: "..S.AimMode, Font=Enum.Font.GothamMedium, TextSize=12, BackgroundColor3=Color3.fromRGB(45,45,45), TextColor3=Color3.new(1,1,1), BorderSizePixel=0}); create("UICorner", {Parent=modeBtn, CornerRadius=UDim.new(0,8)})
    modeBtn.MouseButton1Click:Connect(function() S.AimMode = S.AimMode == "Hold" and "Toggle" or "Hold"; pcall(function() modeBtn.Text="Mode: "..S.AimMode end) end)

    slider(pAim,"FOV Radius",140,10,600,false,"FovRadius"); slider(pAim,"Smoothness",200,6,50,false,"Smoothness"); slider(pAim,"Height Offset",260,-5,5,true,"AimOffset")
    toggle(pVis,"Box ESP",15,0.05,"BoxESP"); rgbSlider(pVis,"Box Color",55,0.05,"BoxCol")
    toggle(pVis,"Skeleton ESP",15,0.52,"SkeletonESP"); rgbSlider(pVis,"Skeleton Color",55,0.52,"SkelCol")
    toggle(pVis,"Dynamic Circle",115,0.05,"AccurateHead"); rgbSlider(pVis,"Circle Color",155,0.05,"AccCol")
    toggle(pVis,"Small Circle",115,0.52,"NormalHead"); rgbSlider(pVis,"Small Color",155,0.52,"NormCol")
    toggle(pVis,"Health Bar",215,0.05,"HealthESP"); rgbSlider(pVis,"Health Color",255,0.05,"HealthCol")
    toggle(pMs,"Triggerbot",15,0.05,"Triggerbot")
    local tbModeBtn = create("TextButton", {Parent=pMs, Size=UDim2.new(0.42,0,0,32), Position=UDim2.new(0.52,0,0,15), Text="Mode: "..(S.TriggerAlwaysOn and "Always On" or "Hold Key"), Font=Enum.Font.GothamMedium, TextSize=12, BackgroundColor3=Color3.fromRGB(45,45,45), TextColor3=Color3.new(1,1,1), BorderSizePixel=0}); create("UICorner", {Parent=tbModeBtn, CornerRadius=UDim.new(0,8)})
    tbModeBtn.MouseButton1Click:Connect(function() S.TriggerAlwaysOn=not S.TriggerAlwaysOn; tbModeBtn.Text="Mode: "..(S.TriggerAlwaysOn and "Always On" or "Hold Key") end)
    keybind(pMs,"Trigger Key",0.05,60,0.89,"TriggerKey"); slider(pMs,"Delay (ms)",110,0,1000,false,"TriggerDelay")

    create("TextLabel", {Parent=pCfg, Text="Config", Font=Enum.Font.GothamBold, TextSize=15, TextColor3=S.HudAccent, BackgroundTransparency=1, Size=UDim2.new(1,0,0,24), Position=UDim2.new(0,0,0,10), TextXAlignment=Enum.TextXAlignment.Center})
    local statusLbl = create("TextLabel", {Parent=pCfg, Text="", Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=Color3.fromRGB(0,220,100), BackgroundTransparency=1, Size=UDim2.new(0.9,0,0,18), Position=UDim2.new(0.05,0,0,368), TextXAlignment=Enum.TextXAlignment.Center})
    local function setStatus(msg, col) statusLbl.Text=msg; statusLbl.TextColor3=col or Color3.fromRGB(0,220,100); task.delay(4, function() pcall(function() statusLbl.Text="" end) end) end
    local saveBtn = create("TextButton", {Parent=pCfg, Size=UDim2.new(0.44,0,0,36), Position=UDim2.new(0.04,0,0,42), Text="💾 Save Config", Font=Enum.Font.GothamBold, TextSize=12, BackgroundColor3=S.HudAccent, TextColor3=Color3.new(1,1,1), BorderSizePixel=0}); create("UICorner", {Parent=saveBtn, CornerRadius=UDim.new(0,8)})
    saveBtn.MouseButton1Click:Connect(function() local ok,err=pcall(function() writefile(CONFIG_FILE,configToString()) end); if ok then setStatus("✓ Saved!",Color3.fromRGB(0,220,100)) else setStatus("✗ "..tostring(err),Color3.fromRGB(255,80,80)) end end)
    local loadBtn = create("TextButton", {Parent=pCfg, Size=UDim2.new(0.44,0,0,36), Position=UDim2.new(0.52,0,0,42), Text="📂 Load Config", Font=Enum.Font.GothamBold, TextSize=12, BackgroundColor3=Color3.fromRGB(35,35,35), TextColor3=Color3.new(1,1,1), BorderSizePixel=0}); create("UICorner", {Parent=loadBtn, CornerRadius=UDim.new(0,8)})
    loadBtn.MouseButton1Click:Connect(function() local ok,err=pcall(function() if not isfile(CONFIG_FILE) then error("File not found") end; applyConfigString(readfile(CONFIG_FILE),allToggleButtons) end); if ok then setStatus("✓ Loaded!",Color3.fromRGB(0,220,100)) else setStatus("✗ "..tostring(err),Color3.fromRGB(255,80,80)) end end)

    rgbSlider(pHud,"Panel BG",40,0.05,"HudBg",function(c) bg.BackgroundColor3=c end)
    rgbSlider(pHud,"Top Bar",40,0.52,"HudBar",function(c) top.BackgroundColor3=c; topFill.BackgroundColor3=c end)
    rgbSlider(pHud,"Tab Sidebar",110,0.05,"HudTabs",function(c) tH.BackgroundColor3=c; tHFillR.BackgroundColor3=c; tHFillT.BackgroundColor3=c end)
    rgbSlider(pHud,"Accent",110,0.52,"HudAccent",function(c) for _, t in ipairs(tabs) do if t.p.Visible then t.b.BackgroundColor3=c end end; for _, tb in ipairs(allToggleButtons) do if S[tb.k] then tb.b.BackgroundColor3=c end end end)

    -- ── DRAG & HIDE ────────────────────────────────────────────────────────────
    local isAiming, isTriggering, cTarget, tbDelay = false, false, nil, 0
    local dU, dI, dS, sPos2 = false, nil, nil, nil
    top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dU = true; dS = i.Position; sPos2 = bg.Position end end)
    top.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dI = i end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dU = false end end)
    UIS.InputChanged:Connect(function(i) if i == dI and dU then local d = i.Position - dS; pcall(function() bg.Position = UDim2.new(sPos2.X.Scale, sPos2.X.Offset + d.X, sPos2.Y.Scale, sPos2.Y.Offset + d.Y) end) end end)
    UIS.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == Enum.KeyCode.K then bg.Visible = not bg.Visible end end)

    -- Mobile Toggle Button
    local aimToggleBtn = nil
    if UIS.TouchEnabled then
        local tBtn = create("TextButton", {Parent=gui, Size=UDim2.new(0,50,0,50), Position=UDim2.new(0,10,0.5,-30), Text="DX", Font=Enum.Font.GothamBold, TextSize=18, BackgroundColor3=S.HudAccent, TextColor3=Color3.new(1,1,1)})
        create("UICorner", {Parent=tBtn, CornerRadius=UDim.new(1,0)})
        tBtn.MouseButton1Click:Connect(function() bg.Visible = not bg.Visible end)
        
        -- Make toggle button draggable
        local tdU, tdI, tdS, tsPos2 = false, nil, nil, nil
        tBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then tdU = true; tdS = i.Position; tsPos2 = tBtn.Position end end)
        tBtn.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then tdI = i end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then tdU = false end end)
        UIS.InputChanged:Connect(function(i) if i == tdI and tdU then local d = i.Position - tdS; pcall(function() tBtn.Position = UDim2.new(tsPos2.X.Scale, tsPos2.X.Offset + d.X, tsPos2.Y.Scale, tsPos2.Y.Offset + d.Y) end) end end)

        aimToggleBtn = create("TextButton", {Parent=gui, Size=UDim2.new(0,50,0,50), Position=UDim2.new(0,10,0.5,30), Text="AIM", Font=Enum.Font.GothamBold, TextSize=16, BackgroundColor3=Color3.fromRGB(45,45,45), TextColor3=Color3.new(1,1,1)})
        create("UICorner", {Parent=aimToggleBtn, CornerRadius=UDim.new(1,0)})
        
        local adU, adI, adS, asPos2 = false, nil, nil, nil
        aimToggleBtn.InputBegan:Connect(function(i) 
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then 
                adU = true; adS = i.Position; asPos2 = aimToggleBtn.Position 
                if S.AimMode == "Hold" then
                    isAiming = true
                    aimToggleBtn.BackgroundColor3 = S.HudAccent
                elseif S.AimMode == "Toggle" then
                    isAiming = not isAiming
                    if not isAiming then cTarget = nil end
                    aimToggleBtn.BackgroundColor3 = isAiming and S.HudAccent or Color3.fromRGB(45,45,45)
                end
            end 
        end)
        aimToggleBtn.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then adI = i end end)
        UIS.InputEnded:Connect(function(i) 
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then 
                if adU then
                    adU = false 
                    if S.AimMode == "Hold" then
                        isAiming = false
                        cTarget = nil
                        aimToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
                    end
                end
            end 
        end)
        UIS.InputChanged:Connect(function(i) if i == adI and adU then local d = i.Position - adS; pcall(function() aimToggleBtn.Position = UDim2.new(asPos2.X.Scale, asPos2.X.Offset + d.X, asPos2.Y.Scale, asPos2.Y.Offset + d.Y) end) end end)
    end

    -- ── PARENT GUIs ────────────────────────────────────────────────────────────
    local function getSafeParent()
        local target = nil
        pcall(function() target = gethui and gethui() end)
        if not target then pcall(function() target = game:GetService("CoreGui") end) end
        if not target then pcall(function() target = LocalPlayer:WaitForChild("PlayerGui", 5) end) end
        return target
    end
    local uiParent = getSafeParent()
    print("DX: Parenting UI to " .. tostring(uiParent))
    pcall(function() for _, v in ipairs(uiParent:GetChildren()) do if v.Name=="DXPanel" or v.Name=="DXFovCircle" then v:Destroy() end end end)
    pcall(function() gui.Parent = uiParent end)
    if not gui.Parent then pcall(function() gui.Parent = LocalPlayer:FindFirstChild("PlayerGui") end) end

    -- ── FOV CIRCLE ─────────────────────────────────────────────────────────────
    local fovGui = Instance.new("ScreenGui")
    fovGui.Name = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
    fovGui.ResetOnSpawn=false; fovGui.IgnoreGuiInset=true; fovGui.Parent = gui.Parent
    local gl3 = getgenv().XenoDXGuis or {}; table.insert(gl3, fovGui); getgenv().XenoDXGuis = gl3
    local fovFrame = create("Frame", {Parent=fovGui, BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,S.FovRadius*2,0,S.FovRadius*2), Visible=S.ShowFov})
    create("UICorner", {Parent=fovFrame, CornerRadius=UDim.new(1,0)})
    local fovStroke = create("UIStroke", {Parent=fovFrame, Thickness=1.5, Color=S.HudFov, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})

    -- ── LOGIC ──────────────────────────────────────────────────────────────────
    local function isValid(p) 
        if not (p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")) then return false end
        return p.Character:FindFirstChildOfClass("Humanoid").Health > 0 and not p.Character:FindFirstChildOfClass("ForceField")
    end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    local function isVisible(tPart)
        if not tPart then return false end
        local cam = workspace.CurrentCamera
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, cam}
        local origin = cam.CFrame.Position
        local dir = tPart.Position - origin
        local result = workspace:Raycast(origin, dir, rayParams)
        if result and (result.Instance.Transparency > 0.5 or not result.Instance.CanCollide) then
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, cam, result.Instance}
            result = workspace:Raycast(result.Position + dir.Unit * 0.1, tPart.Position - result.Position, rayParams)
        end
        return not result or result.Instance:IsDescendantOf(tPart.Parent)
    end
    
    UIS.InputBegan:Connect(function(i,gp) 
        if gp then return end
        local k=i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType
        if k==S.AimKey then 
            if S.AimMode == "Toggle" then
                isAiming = not isAiming
                if not isAiming then cTarget = nil end
                if aimToggleBtn then aimToggleBtn.BackgroundColor3 = isAiming and S.HudAccent or Color3.fromRGB(45,45,45) end
            else
                isAiming = true
                if aimToggleBtn then aimToggleBtn.BackgroundColor3 = S.HudAccent end
            end
        elseif k==S.TriggerKey and (not gp or k~=i.KeyCode) then 
            isTriggering=true 
        end 
    end)
    UIS.InputEnded:Connect(function(i) 
        local k=i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType
        if k==S.AimKey then 
            if S.AimMode == "Hold" then
                isAiming = false; cTarget = nil 
                if aimToggleBtn then aimToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,45) end
            end
        elseif k==S.TriggerKey then 
            isTriggering = false 
        end 
    end)

    local eD, aD = {}, {}; getgenv().XBoxESP, getgenv().XAdvESP = eD, aD
    local BONES = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
    local function buildESP(p)
        if not Drawing then return end
        local L={} for i=1,4 do pcall(function() L[i]=Drawing.new("Line"); L[i].Thickness=2; L[i].Visible=false end) end; eD[p]={L=L}
        local B={} for i=1,#BONES do pcall(function() B[i]=Drawing.new("Line"); B[i].Thickness=1.5; B[i].Visible=false end) end
        local A, N; pcall(function() A=Drawing.new("Circle"); A.Thickness=1.5; A.NumSides=64; N=Drawing.new("Circle"); N.Thickness=1.5; N.NumSides=64 end)
        local HB, HF; pcall(function() HB=Drawing.new("Square"); HB.Thickness=1; HB.Filled=false; HB.Visible=false; HF=Drawing.new("Square"); HF.Thickness=0; HF.Filled=true; HF.Visible=false end)
        aD[p]={L=B,A=A,N=N,HB=HB,HF=HF}
    end
    if Drawing then
        for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then buildESP(p) end end
        playersConnection = Players.PlayerAdded:Connect(function(p) if p~=LocalPlayer then buildESP(p) end end)
        table.insert(connections, playersConnection)
        playersRemovingConnection = Players.PlayerRemoving:Connect(function(p) pcall(function() if eD[p] then for _,l in pairs(eD[p].L) do l:Remove() end eD[p]=nil end if aD[p] then for _,l in pairs(aD[p].L) do l:Remove() end aD[p].A:Remove() aD[p].N:Remove() aD[p].HB:Remove() aD[p].HF:Remove() aD[p]=nil end end) end)
        table.insert(connections, playersRemovingConnection)
    end

    local rX, rY = 0, 0
    getgenv().DXAimLockName = getgenv().DXAimLockName or game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
    RunService:BindToRenderStep(getgenv().DXAimLockName, 205, function(deltaTime)
        local Cam = workspace.CurrentCamera; if not Cam or not isAiming or not S.Aimbot then cTarget = nil; rX, rY = 0, 0; return end
        local vMid = Cam.ViewportSize / 2
        
        -- Target Lock Maintenance (Hysteresis added to stop FOV edge flicking)
        local targetStillValid = false
        if cTarget and isValid(cTarget) then
            local ch = cTarget.Character
            local part = ch:FindFirstChild(S.AimbotPart) or ch:FindFirstChild("Head") or ch:FindFirstChild("UpperTorso")
            if part then
                local pS, oS = Cam:WorldToViewportPoint(part.Position)
                if oS and pS.Z > 1 then
                    local dist = (Vector2.new(pS.X,pS.Y)-vMid).Magnitude
                    if dist <= S.FovRadius * 1.3 and isVisible(part) then targetStillValid = true end
                end
            end
        end
        
        if not targetStillValid then
            cTarget = nil; rX, rY = 0, 0
            local sDist = S.FovRadius
            for _,p in pairs(Players:GetPlayers()) do 
                if p~=LocalPlayer and isValid(p) then 
                    local ch = p.Character
                    local part = ch:FindFirstChild(S.AimbotPart) or ch:FindFirstChild("Head") or ch:FindFirstChild("UpperTorso")
                    if part then
                        local pS, oS = Cam:WorldToViewportPoint(part.Position) 
                        if oS and pS.Z > 1 then 
                            local dist = (Vector2.new(pS.X,pS.Y)-vMid).Magnitude
                            if dist <= sDist and isVisible(part) then cTarget, sDist = p, dist end 
                        end 
                    end
                end 
            end
        end
        
        if cTarget then
            local ch = cTarget.Character
            local tPart = ch:FindFirstChild(S.AimbotPart) or ch:FindFirstChild("Head") or ch:FindFirstChild("UpperTorso")
            if tPart then
                local tPos = tPart.Position + Vector3.new(0,S.AimOffset,0)
                local sPos, oS = Cam:WorldToViewportPoint(tPos)
                if oS and sPos.Z > 1 then
                    if S.AimbotMethod == "Mouse" and type(mousemoverel) == "function" and not UIS.TouchEnabled then 
                        local diffX = sPos.X - vMid.X
                        local diffY = sPos.Y - vMid.Y
                        local fpsComp = deltaTime * 60
                        
                        -- Make smoothness scale stronger (at 6, divisor is 2, meaning very fast snap)
                        local divisor = math.max(1.5, S.Smoothness - 4)
                        
                        -- Frame-rate independent proportional controller
                        local moveX = ((diffX * fpsComp) / divisor) + rX
                        local moveY = ((diffY * fpsComp) / divisor) + rY
                        
                        -- Jitter reduction near target center
                        local dist = math.sqrt(diffX^2 + diffY^2)
                        if dist < 6 then
                            moveX = moveX * 0.4
                            moveY = moveY * 0.4
                        end
                        
                        -- Clamping max speed (increased to allow stronger snaps)
                        local maxS = math.max(20, math.min(120, dist * 1.2))
                        moveX = math.clamp(moveX, -maxS, maxS)
                        moveY = math.clamp(moveY, -maxS, maxS)
                        
                        -- Sub-pixel residual retention
                        local mX = math.floor(moveX + 0.5)
                        local mY = math.floor(moveY + 0.5)
                        rX = moveX - mX
                        rY = moveY - mY
                        
                        -- Dynamic deadzone
                        if math.abs(diffX) < 1.5 then mX = 0; rX = 0 end
                        if math.abs(diffY) < 1.5 then mY = 0; rY = 0 end
                        
                        if mX ~= 0 or mY ~= 0 then 
                            mousemoverel(mX, mY) 
                        end
                    else 
                        local tgtCFrame = CFrame.lookAt(Cam.CFrame.Position, tPos)
                        local smooth = math.clamp((deltaTime * 60) / math.max(1.5, S.Smoothness - 4), 0, 1)
                        if Cam.CFrame.LookVector:Dot(tgtCFrame.LookVector) > 0.999 then smooth = 1 end
                        Cam.CFrame = Cam.CFrame:Lerp(tgtCFrame, smooth) 
                    end
                else cTarget = nil end
            else cTarget = nil end
        end
    end)

    local function getSpectated() local s = workspace.CurrentCamera.CameraSubject if s and s:IsA("BasePart") and s.Parent:FindFirstChildOfClass("Humanoid") then return Players:GetPlayerFromCharacter(s.Parent) elseif s and s:IsA("Humanoid") and s.Parent then return Players:GetPlayerFromCharacter(s.Parent) end return nil end
    table.insert(connections, RunService.RenderStepped:Connect(function()
        local Cam = workspace.CurrentCamera; if not Cam then return end
        local vMid = Cam.ViewportSize / 2
        fovFrame.Visible=S.ShowFov; fovFrame.Size=UDim2.new(0,S.FovRadius*2,0,S.FovRadius*2); fovStroke.Color=S.HudFov
        
        -- Triggerbot
        if S.Triggerbot and (S.TriggerAlwaysOn or isTriggering) and tick()-tbDelay>(S.TriggerDelay/1000) then
            local t = LocalPlayer:GetMouse().Target
            if t and t.Parent then
                local c = (t.Parent:FindFirstChildOfClass("Humanoid") and t.Parent) or (t.Parent.Parent and t.Parent.Parent:FindFirstChildOfClass("Humanoid") and t.Parent.Parent)
                if c and Players:GetPlayerFromCharacter(c) ~= LocalPlayer and isValid(Players:GetPlayerFromCharacter(c)) then if mouse1click and not UIS.TouchEnabled then mouse1click() end tbDelay=tick() end
            end
        end

        -- ESP Rendering (Late Sync)
        local spectated, sP = getSpectated(), {}
        local function getS(part)
            if sP[part] then return unpack(sP[part]) end
            local pS, oS = Cam:WorldToViewportPoint(part.Position)
            sP[part] = {Vector2.new(math.floor(pS.X), math.floor(pS.Y)), oS and pS.Z > 0}
            return unpack(sP[part])
        end

        for p, d in pairs(eD) do
            local ch, sD = p.Character, aD[p]
            if ch and sD and p ~= spectated and isValid(p) then
                local hrp, hd = ch:FindFirstChild("HumanoidRootPart"), ch:FindFirstChild("Head")
                if hrp then
                    hd = hd or hrp
                    local headP, headO = getS(hd); local rootP, rootO = getS(hrp)
                    local tPV, tOV = Cam:WorldToViewportPoint(hd.Position + Vector3.new(0, 1, 0))
                    local bPV, bOV = Cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local tP, bP = Vector2.new(math.floor(tPV.X), math.floor(tPV.Y)), Vector2.new(math.floor(bPV.X), math.floor(bPV.Y))
                    
                    if S.BoxESP and tOV and bOV then
                        local w = math.abs(tP.Y - bP.Y) * 0.65; local hV = rootP; local w2 = w / 2
                        local xs, ys = {hV.X-w2, hV.X+w2, hV.X+w2, hV.X-w2}, {tP.Y, tP.Y, bP.Y, bP.Y}
                        for i=1,4 do d.L[i].Color=S.BoxCol; d.L[i].From=Vector2.new(xs[i],ys[i]); d.L[i].To=Vector2.new(xs[(i%4)+1],ys[(i%4)+1]); d.L[i].Visible=true end
                    else for _,l in pairs(d.L) do l.Visible=false end end
                    
                    if S.SkeletonESP then
                        for i, bn in ipairs(BONES) do
                            local p1, p2 = ch:FindFirstChild(bn[1]), ch:FindFirstChild(bn[2])
                            if p1 and p2 then 
                                local s1, o1 = getS(p1); local s2, o2 = getS(p2)
                                if bn[1] == "Head" then
                                    local sp1, so1 = Cam:WorldToViewportPoint(p1.Position - p1.CFrame.UpVector * 1.3)
                                    s1, o1 = Vector2.new(math.floor(sp1.X), math.floor(sp1.Y)), so1 and sp1.Z > 0
                                elseif bn[2] == "Head" then
                                    local sp2, so2 = Cam:WorldToViewportPoint(p2.Position - p2.CFrame.UpVector * 1.3)
                                    s2, o2 = Vector2.new(math.floor(sp2.X), math.floor(sp2.Y)), so2 and sp2.Z > 0
                                end
                                if o1 and o2 then sD.L[i].Color=S.SkelCol; sD.L[i].From=s1; sD.L[i].To=s2; sD.L[i].Visible=true else sD.L[i].Visible=false end 
                            else sD.L[i].Visible=false end
                        end
                    else for _,l in pairs(sD.L) do l.Visible=false end end
                    
                    if headO then 
                        local rad = math.abs(tP.Y - bP.Y) * 0.15
                        if S.AccurateHead then sD.A.Color=S.AccCol; sD.A.Radius=rad * 1.2; sD.A.Position=headP; sD.A.Visible=true else sD.A.Visible=false end 
                        if S.NormalHead then sD.N.Color=S.NormCol; sD.N.Radius=rad * 0.7; sD.N.Position=headP; sD.N.Visible=true else sD.N.Visible=false end 
                    else sD.A.Visible=false; sD.N.Visible=false end
                    
                    if S.HealthESP and tOV and bOV then
                        local hum = ch:FindFirstChildOfClass("Humanoid")
                        if hum then local h = math.clamp(hum.Health/hum.MaxHealth,0,1); sD.HF.Color=S.HealthCol; sD.HF.Size=Vector2.new(2, math.abs(tP.Y-bP.Y)*h); sD.HF.Position=Vector2.new(tP.X-math.abs(tP.Y-bP.Y)*0.35-5, bP.Y-sD.HF.Size.Y); sD.HF.Visible=true else sD.HF.Visible=false end
                    else sD.HF.Visible=false end
                end
            else 
                pcall(function()
                    if d and d.L then for _,l in pairs(d.L) do l.Visible=false end end
                    if sD then 
                        if sD.L then for _,l in pairs(sD.L) do l.Visible=false end end
                        if sD.A then sD.A.Visible=false end
                        if sD.N then sD.N.Visible=false end
                        if sD.HB then sD.HB.Visible=false end
                        if sD.HF then sD.HF.Visible=false end
                    end
                end)
            end
        end
    end))
end

local function notify(text)
    print("[Xeno DX] " .. text)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Xeno DX", Text = text, Duration = 5}) end)
    if Drawing then pcall(function() local l = Drawing.new("Text"); l.Text = text; l.Color = Color3.new(1,1,1); l.Size = 20; l.Outline = true; l.Position = Vector2.new(50, 50); l.Visible = true; task.delay(5, function() l:Remove() end) end) end
end

task.spawn(function()
    print("DX: Script start sequence begin")
    notify("Bloxstrike DX Loading...")
    local ok, err = pcall(startScript)
    if not ok then warn("DX: Script failed to start: " .. tostring(err)) notify("Load Failed! Check Console (F9)")
    else notify("Bloxstrike DX Loaded! Press K to Toggle Menu.") end
end)
