--[[
    BEST INVISIBLE — v1
    Mobile / Delta / universal
    Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/supercaptain1233/bestinvisible/main/bestinvisible.lua"))()
]]

--============ PROTECTION ============
local cloneref = cloneref or function(o) return o end
local typeof = typeof or type

if typeof(setthreadidentity) == "function" then pcall(setthreadidentity, 7) end
if typeof(setidentity) == "function" then pcall(setidentity, 7) end
if typeof(setfpscap) == "function" then pcall(setfpscap, 60) end

local RAW_URL = "https://raw.githubusercontent.com/supercaptain1233/bestinvisible/main/bestinvisible.lua"
local FOLDER = "BestInvisible"
local TAG = "BI_" .. tostring(math.random(100000, 999999))

if getgenv and getgenv().BestInvisible and getgenv().BestInvisible.destroy then
    pcall(getgenv().BestInvisible.destroy)
end

local bootCount = (getgenv and getgenv().BestInvisibleBoot or 0) + 1
if getgenv then getgenv().BestInvisibleBoot = bootCount end

local function boot()

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UIS = cloneref(game:GetService("UserInputService"))
local VU = cloneref(game:GetService("VirtualUser"))
local TweenService = cloneref(game:GetService("TweenService"))
local TPS = cloneref(game:GetService("TeleportService"))
local SG = cloneref(game:GetService("StarterGui"))

local LP = Players.LocalPlayer
if not LP then return end

local FAR = 100000
local GHOST_GREY = Color3.fromRGB(150, 150, 150)

--============ ANTI-AFK / ANTI-KICK ============
local conns = {}
local function track(c) conns[#conns + 1] = c return c end

pcall(function()
    track(LP.Idled:Connect(function()
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end))
end)

pcall(function()
    if typeof(queue_on_teleport) == "function" then
        queue_on_teleport(string.format(
            'pcall(function() loadstring(game:HttpGet("%s"))() end)', RAW_URL))
    elseif typeof(syn) == "table" and typeof(syn.queue_on_teleport) == "function" then
        pcall(syn.queue_on_teleport, string.format(
            'pcall(function() loadstring(game:HttpGet("%s"))() end)', RAW_URL))
    end
end)

pcall(function()
    track(LP.OnTeleport:Connect(function(s)
        if s == Enum.TeleportState.Failed then
            pcall(function() TPS:Teleport(game.PlaceId, LP) end)
        end
    end))
end)

pcall(function() SG:SetCore("ResetButtonCallback", true) end)

--============ STATE ============
local on = false
local ghost = nil
local homeCF = nil
local yaw, pitch, zoom = 0, -0.18, 12
local savedCamType = nil
local baseSpeed = nil

local function hrpOf()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function humOf()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

--============ GHOST ============
local function clearGhost()
    if ghost then pcall(function() ghost:Destroy() end) end
    ghost = nil
end

local function buildGhost(cf)
    clearGhost()
    local char = LP.Character
    if not char then return end

    local copy = char:Clone()
    copy.Name = TAG .. "_ghost"

    for _, d in ipairs(copy:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
            d.CanQuery = false
            d.CanTouch = false
            d.Massless = true
            d.Transparency = 0.55
            d.Color = GHOST_GREY
            d.Material = Enum.Material.SmoothPlastic
            d.CastShadow = false
        elseif d:IsA("Script") or d:IsA("LocalScript") then
            d:Destroy()
        elseif d:IsA("Humanoid") then
            d:Destroy()
        elseif d:IsA("Decal") then
            d.Transparency = 0.5
        end
    end

    local root = copy:FindFirstChild("HumanoidRootPart")
    if root then
        copy.PrimaryPart = root
        root.CFrame = cf
    end

    copy.Parent = workspace
    ghost = copy
end

local function headPos()
    if ghost then
        local h = ghost:FindFirstChild("Head")
        if h then return h.Position end
        local r = ghost:FindFirstChild("HumanoidRootPart")
        if r then return r.Position + Vector3.new(0, 1.5, 0) end
    end
    return nil
end

--============ GUI ============
local gui = Instance.new("ScreenGui")
gui.Name = TAG
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if typeof(protectgui) == "function" then pcall(protectgui, gui) end
if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
    pcall(syn.protect_gui, gui)
end

local parented = false
if typeof(gethui) == "function" then
    local ok, h = pcall(gethui)
    if ok and h then gui.Parent = h parented = true end
end
if not parented then
    local ok = pcall(function() gui.Parent = cloneref(game:GetService("CoreGui")) end)
    if not ok then gui.Parent = LP:WaitForChild("PlayerGui") end
end

-- full screen catcher for orbiting, sits under the panel
local catcher = Instance.new("TextButton")
catcher.Size = UDim2.fromScale(1, 1)
catcher.BackgroundTransparency = 1
catcher.Text = ""
catcher.Active = true
catcher.Visible = false
catcher.ZIndex = 2
catcher.Parent = gui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(230, 76)
main.Position = UDim2.new(0, 24, 0.5, -38)
main.BackgroundColor3 = Color3.fromRGB(198, 52, 52)
main.BorderSizePixel = 0
main.Active = true
main.ZIndex = 10
main.Parent = gui

local uiscale = Instance.new("UIScale")
uiscale.Parent = main

local function refreshScale()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
    uiscale.Scale = math.clamp(math.min(vp.X, vp.Y) / 400, 0.72, 1.05)
end
refreshScale()
track((function()
    local c = workspace.CurrentCamera
    if not c then return Instance.new("BindableEvent").Event end
    return c:GetPropertyChangedSignal("ViewportSize"):Connect(refreshScale)
end)())

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.55
stroke.Thickness = 1.5
stroke.Parent = main

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -62, 1, 0)
label.Position = UDim2.fromOffset(8, 0)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.Text = "best invisible"
label.TextSize = 16
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextWrapped = true
label.ZIndex = 11
label.Parent = main

local function zoomBtn(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(24, 24)
    b.Position = UDim2.new(1, -30, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 0.35
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.ZIndex = 12
    b.Parent = main
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b
    return b
end

local zoomIn = zoomBtn("+", 13)
local zoomOut = zoomBtn("-", 41)

--============ DRAG / TAP ============
local press = false
local pressStart, pressPos, moved = nil, nil, 0

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        press = true
        moved = 0
        pressStart = input.Position
        pressPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                press = false
                if moved < 12 then
                    if on then turnOff() else turnOn() end
                end
            end
        end)
    end
end)

track(UIS.InputChanged:Connect(function(input)
    if press and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - pressStart
        moved = math.max(moved, math.abs(d.X) + math.abs(d.Y))
        main.Position = UDim2.new(
            pressPos.X.Scale, pressPos.X.Offset + d.X,
            pressPos.Y.Scale, pressPos.Y.Offset + d.Y)
    end
end))

--============ ORBIT / ZOOM INPUT ============
local orbit = false
local orbitStart, orbitYaw, orbitPitch

catcher.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        orbit = true
        orbitStart = input.Position
        orbitYaw = yaw
        orbitPitch = pitch
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then orbit = false end
        end)
    end
end)

track(UIS.InputChanged:Connect(function(input)
    if orbit and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - orbitStart
        yaw = orbitYaw - d.X * 0.006
        pitch = math.clamp(orbitPitch - d.Y * 0.005, -1.15, 1.15)
    end
    if input.UserInputType == Enum.UserInputType.MouseWheel and on then
        zoom = math.clamp(zoom - input.Position.Z * 3, 3, 60)
    end
end))

zoomIn.Activated:Connect(function() zoom = math.clamp(zoom - 3, 3, 60) end)
zoomOut.Activated:Connect(function() zoom = math.clamp(zoom + 3, 3, 60) end)

--============ CAMERA ============
track(RunService.RenderStepped:Connect(function()
    if not on then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local head = headPos()
    if not head then return end

    local rot = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)
    local dir = rot:VectorToWorldSpace(Vector3.new(0, 0, 1))
    local camPos = head + dir * zoom

    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.lookAt(camPos, head)
    cam.FieldOfView = 70
end))

--============ KEEP IT PINNED ============
track(RunService.Heartbeat:Connect(function()
    if not on then return end
    local hrp = hrpOf()
    if not hrp or not homeCF then return end

    if not hrp.Anchored then hrp.Anchored = true end

    local farCF = homeCF + Vector3.new(0, FAR, 0)
    if (hrp.Position - farCF.Position).Magnitude > 400 then
        pcall(function() hrp.CFrame = farCF end)
    end

    if not ghost or not ghost.Parent then
        pcall(function() buildGhost(homeCF) end)
    end
end))

--============ ON / OFF ============
function turnOn()
    if on then return end
    local hrp = hrpOf()
    if not hrp then return end

    homeCF = hrp.CFrame
    local hum = humOf()
    if hum then
        baseSpeed = hum.WalkSpeed
        pcall(function()
            hum.PlatformStand = true
            hum.WalkSpeed = 0
            hum.AutoRotate = false
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end

    buildGhost(homeCF)

    hrp.Anchored = true
    hrp.CFrame = homeCF + Vector3.new(0, FAR, 0)

    yaw, pitch, zoom = 0, -0.18, 12

    local cam = workspace.CurrentCamera
    if cam then
        savedCamType = cam.CameraType
        cam.CameraType = Enum.CameraType.Scriptable
    end

    on = true
    catcher.Visible = true
    main.BackgroundColor3 = Color3.fromRGB(42, 168, 92)
    label.Text = "best invisible"
    stroke.Transparency = 0.3
end

function turnOff()
    if not on then return end
    on = false

    catcher.Visible = false
    main.BackgroundColor3 = Color3.fromRGB(198, 52, 52)
    stroke.Transparency = 0.55

    clearGhost()

    local hrp = hrpOf()
    if hrp and homeCF then
        pcall(function()
            hrp.Anchored = false
            hrp.CFrame = homeCF
        end)
    end

    local hum = humOf()
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            if baseSpeed then hum.WalkSpeed = baseSpeed end
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end

    local cam = workspace.CurrentCamera
    if cam then
        cam.CameraType = savedCamType or Enum.CameraType.Custom
        pcall(function() cam.CameraSubject = LP.Character:FindFirstChildOfClass("Humanoid") end)
    end
end

-- reapply if the character respawns while it is on
track(LP.CharacterAdded:Connect(function(c)
    if not on then return end
    c:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.2)
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    homeCF = hrp.CFrame
    buildGhost(homeCF)
    hrp.Anchored = true
    hrp.CFrame = homeCF + Vector3.new(0, FAR, 0)
end))

--============ WATCHDOG / DESTROY ============
local function destroy()
    pcall(function() turnOff() end)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    pcall(function() gui:Destroy() end)
    if getgenv then getgenv().BestInvisible = nil end
end

local api = { destroy = destroy, version = "1.0", turnOn = turnOn, turnOff = turnOff }
if getgenv then getgenv().BestInvisible = api end

task.spawn(function()
    while getgenv and getgenv().BestInvisible == api do
        task.wait(1.5)
        pcall(function()
            if not gui.Parent then
                if typeof(gethui) == "function" then
                    local ok, h = pcall(gethui)
                    if ok and h then gui.Parent = h end
                else
                    gui.Parent = cloneref(game:GetService("CoreGui"))
                end
            end
            if on and (not ghost or not ghost.Parent) and homeCF then
                pcall(function() buildGhost(homeCF) end)
            end
        end)
    end
end)

end

--============ BOOT ============
local ok, err = xpcall(boot, function(e) return e end)

if not ok then
    warn("[BestInvisible] " .. tostring(err))
    if bootCount < 2 and typeof(loadstring) == "function" then
        task.wait(1)
        pcall(function()
            loadstring(game:HttpGet(RAW_URL .. "?retry=" .. tostring(os.time())))()
        end)
    end
end
