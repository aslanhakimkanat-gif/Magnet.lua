local players = game:GetService("Players")
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local player = players.LocalPlayer
local camera = workspace.CurrentCamera

-- Настройки
local magnetRadius = 25  -- Радиус магнита для блоков
local magnetSpeed = 45   -- Скорость притяжения блоков
local flySpeed = 50      -- Скорость полета

local flying = false
local bv, bg

-- Функция включения/выключения полета
local function toggleFly()
    flying = not flying
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart or not humanoid then return end
    
    if flying then
        humanoid.PlatformStand = true
        
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = rootPart
        
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.P = 9000
        bg.Parent = rootPart
        
        print("Полет включен! Нажмите F, чтобы выключить.")
    else
        humanoid.PlatformStand = false
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        print("Полет выключен.")
    end
end

-- Кнопка для переключения полета (клавиша F)
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)

-- Основной цикл (полет + магнит)
runService.Heartbeat:Connect(function()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return end
    
    -- 1. Логика полета
    if flying and bv and bg then
        local moveDir = Vector3.zero
        if uis:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.yAxis end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.yAxis end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * flySpeed
        end
        
        bv.Velocity = moveDir
        bg.CFrame = camera.CFrame
    end
    
    -- 2. Логика магнита для физических блоков
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Part") and not obj.Anchored and obj ~= rootPart then
            local distance = (obj.Position - rootPart.Position).Magnitude
            if distance < magnetRadius then
                local direction = (rootPart.Position - obj.Position).Unit
                -- Безопасное применение скорости для физики
                pcall(function()
                    obj.AssemblyLinearVelocity = direction * magnetSpeed
                end)
            end
        end
    end
end)
