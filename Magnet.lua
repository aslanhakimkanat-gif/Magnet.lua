-- Мобильный скрипт: Магнит блоков + Полет с GUI
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local coreGui = game:GetService("CoreGui")

local player = players.LocalPlayer
local camera = workspace.CurrentCamera

-- Настройки
local magnetRadius = 30
local magnetSpeed = 50
local flySpeed = 50
local flying = false
local bv, bg

-- Создание интерфейса (GUI) на экране телефона
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileMagnetFlyGUI"
pcall(function()
    screenGui.Parent = coreGui
end)
if not screenGui.Parent then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Главная панель
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 160)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Панель можно перетаскивать пальцем по экрану
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Magnet & Fly Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Кнопка полета
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 180, 0, 45)
flyButton.Position = UDim2.new(0, 10, 0, 40)
flyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flyButton.Text = "Полет: ВЫКЛ"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 14
flyButton.Font = Enum.Font.SourceSansBold
flyButton.Parent = mainFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyButton

-- Кнопка магнита
local magnetButton = Instance.new("TextButton")
magnetButton.Size = UDim2.new(0, 180, 0, 45)
magnetButton.Position = UDim2.new(0, 10, 0, 95)
magnetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
magnetButton.Text = "Магнит: ВКЛ"
magnetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
magnetButton.TextSize = 14
magnetButton.Font = Enum.Font.SourceSansBold
magnetButton.Parent = mainFrame

local magCorner = Instance.new("UICorner")
magCorner.CornerRadius = UDim.new(0, 8)
magCorner.Parent = magnetButton

local magnetActive = true

-- Функция переключения полета
local function toggleFly()
    flying = not flying
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart or not humanoid then return end
    
    if flying then
        humanoid.PlatformStand = true
        flyButton.Text = "Полет: ВКЛ"
        flyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = rootPart
        
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.P = 9000
        bg.Parent = rootPart
    else
        humanoid.PlatformStand = false
        flyButton.Text = "Полет: ВЫКЛ"
        flyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

flyButton.MouseButton1Click:Connect(toggleFly)

magnetButton.MouseButton1Click:Connect(function()
    magnetActive = not magnetActive
    if magnetActive then
        magnetButton.Text = "Магнит: ВКЛ"
        magnetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    else
        magnetButton.Text = "Магнит: ВЫКЛ"
        magnetButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

-- Основной цикл (полет летит туда, куда смотрит камера телефона, а магнит притягивает блоки)
runService.Heartbeat:Connect(function()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart then return end
    
    -- Логика полета на телефоне (движение вперед туда, куда смотрит камера)
    if flying and bv and bg then
        local moveDir = Vector3.zero
        -- Если персонаж идет с помощью стандартного джойстика Roblox на телефоне:
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            moveDir = humanoid.MoveDirection * flySpeed
        end
        bv.Velocity = moveDir
        bg.CFrame = camera.CFrame
    end
    
    -- Логика магнита
    if magnetActive then
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Part") and not obj.Anchored and obj ~= rootPart then
                local distance = (obj.Position - rootPart.Position).Magnitude
                if distance < magnetRadius then
                    local direction = (rootPart.Position - obj.Position).Unit
                    pcall(function()
                        obj.AssemblyLinearVelocity = direction * magnetSpeed
                    end)
                end
            end
        end
    end
end)
