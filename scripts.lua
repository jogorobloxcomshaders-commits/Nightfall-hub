-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configurações
local ESP_DISTANCE = 2000
local OUTLINE_THICKNESS = 0.15 

-- Estado Interno do ESP
local espObjects = {}
local colorTime = 0
local heartbeatConnection = nil 

-- Função para criar cores neon vibrantes que mudam
local function getNeonColor()
    colorTime = colorTime + 0.08 
    local r = math.sin(colorTime) * 0.5 + 0.5
    local g = math.sin(colorTime + 2.094) * 0.5 + 0.5
    local b = math.sin(colorTime + 4.188) * 0.5 + 0.5
    
    r = math.pow(r, 0.8) * 1.3
    g = math.pow(g, 0.8) * 1.3  
    b = math.pow(b, 0.8) * 1.3
    
    return Color3.new(math.min(r, 1), math.min(g, 1), math.min(b, 1))
end

-- Função para adicionar highlight neon em um jogador
local function addESPToPlayer(playerObj)
    if playerObj == LocalPlayer or espObjects[playerObj] then return end
    
    local espData = {
        highlight = nil,
        connection = nil
    }
    
    local function addHighlight(character)
        if espData.highlight then espData.highlight:Destroy() end
        
        character:WaitForChild("Humanoid", 5)
        character:WaitForChild("HumanoidRootPart", 5)
        
        task.wait(0.2) 
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character 
        highlight.FillTransparency = 1 
        highlight.OutlineTransparency = OUTLINE_THICKNESS 
        highlight.OutlineColor = Color3.new(1, 0, 0) 
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = false 
        highlight.Parent = character
        
        espData.highlight = highlight
    end
    
    local function onCharacterAdded(character)
        addHighlight(character)
    end
    
    if playerObj.Character then
        onCharacterAdded(playerObj.Character)
    end
    
    espData.connection = playerObj.CharacterAdded:Connect(onCharacterAdded)
    
    espObjects[playerObj] = espData
end

-- Função para remover ESP de um jogador
local function removeESPFromPlayer(playerObj)
    if espObjects[playerObj] then
        local espData = espObjects[playerObj]
        
        if espData.highlight then
            espData.highlight:Destroy()
        end
        
        if espData.connection then
            espData.connection:Disconnect()
        end
        
        espObjects[playerObj] = nil
    end
end

-- Função principal para atualizar cores e visibilidade
local function updateNeonESPAura()
    
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return end
    
    local localPosition = localCharacter.HumanoidRootPart.Position
    local neonColor = getNeonColor()
    
    for playerObj, espData in pairs(espObjects) do
        if espData.highlight and playerObj.Character and playerObj.Character:FindFirstChild("HumanoidRootPart") and playerObj.Character:FindFirstChild("Humanoid") then
            local character = playerObj.Character
            local humanoidRootPart = character.HumanoidRootPart
            local humanoid = character.Humanoid
            
            local distance = (localPosition - humanoidRootPart.Position).Magnitude
            
            if distance <= ESP_DISTANCE and humanoid.Health > 0 then
                espData.highlight.OutlineColor = neonColor
                espData.highlight.OutlineTransparency = OUTLINE_THICKNESS
                espData.highlight.Enabled = true
            else
                espData.highlight.Enabled = false
            end
        elseif espData.highlight then
            espData.highlight.Enabled = false
        end
    end
end

-- A IMPLEMENTAÇÃO GLOBAL DA FUNÇÃO DE TOGGLE
-- Esta função é definida GLOBALMENTE (_G) para sobrescrever a função placeholder no Interface-Main.lua
_G.toggleNeonESPAura = function(active)
    if active then
        -- Inicia o loop de atualização se ainda não estiver rodando
        if not heartbeatConnection then
            heartbeatConnection = RunService.Heartbeat:Connect(updateNeonESPAura)
        end
        
        -- Garante que todos os jogadores ativos tenham o Highlight criado
        for _, playerObj in pairs(Players:GetPlayers()) do
            addESPToPlayer(playerObj)
        end
        
        print("Neon Aura (RGB) Ativada!")
    else
        -- Desativa e limpa todos os Highlights
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        
        for _, espData in pairs(espObjects) do
            if espData.highlight then
                espData.highlight.Enabled = false
            end
        end
        
        print("Neon Aura (RGB) Desativada!")
    end
end

-- Conexão inicial dos eventos de PlayerAdded/Removing
Players.PlayerAdded:Connect(addESPToPlayer)
Players.PlayerRemoving:Connect(removeESPFromPlayer)

-- Cria ESP para jogadores já existentes (com o highlight desativado por padrão)
for _, playerObj in pairs(Players:GetPlayers()) do
    addESPToPlayer(playerObj)
end

print("scripts.lua (Lógica ESP) carregado e conectado à interface.")
