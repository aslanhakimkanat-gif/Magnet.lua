local players = game:GetService("Players")
local runService = game:GetService("RunService")

local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Радиус притяжения и сила
local magnetRadius = 15 

runService.Heartbeat:Connect(function()
    if not rootPart or not rootPart.Parent then return end
    
    -- Проверяем все объекты в Workspace
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Part") and not obj.Anchored and obj ~= rootPart then
            local distance = (obj.Position - rootPart.Position).Magnitude
            
            -- Если блок близко, притягиваем его к игроку
            if distance < magnetRadius then
                local direction = (rootPart.Position - obj.Position).Unit
                obj.Velocity = direction * 35 -- задаем скорость движения блока к игроку
            end
        end
    end
end)
