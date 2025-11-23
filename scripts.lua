-- scripts.lua

local ESPScript = {}

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

---
-- FUNÇÕES INTERNAS DE LÓGICA
---

-- Função para criar cores neon vibrantes que mudam (RGB)
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

-- Função para adicionar o Highlight (sombra/brilho) em um personagem
local function addHighlight(character)
    -- Verifica se já existe um highlight e o destrói para evitar duplicatas
    if character:FindFirstChild("Highlight") then 
        character:FindFirstChild("Highlight"):Destroy()
    end
    
    character:WaitForChild("Humanoid", 5)
    character:WaitForChild("HumanoidRootPart", 5)
    
    task.wait(0.2) 
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Adornee = character 
    highlight.FillTransparency = 1 
    highlight.OutlineTransparency = OUTLINE_THICKNESS 
    highlight.OutlineColor = Color3.new(1, 0, 0) -- Cor inicial
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false 
    highlight.Parent = character
    
    return highlight
end

-- Função para configurar o ESP em um jogador
local function addESPToPlayer(playerObj)
    if playerObj == LocalPlayer or espObjects[playerObj] then return end
    
    local espData = {
        highlight = nil,
        connection = nil
    }
    
    local function onCharacterAdded(character)
        espData.highlight = addHighlight(character)
        
        -- Garante que o highlight esteja no estado desativado, se o ESP não estiver ativo
        if espData.highlight and not heartbeatConnection then
             espData.highlight.Enabled = false
        end
    end
    
    if playerObj.Character then
        onCharacterAdded(playerObj.Character)
    end
    
    -- Reconecta o ESP quando o jogador renasce
    espData.connection = playerObj.CharacterAdded:Connect(onCharacterAdded)
    
    espObjects[playerObj] = espData
end

-- Função para remover ESP de um jogador (usada no PlayerRemoving)
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

-- Função principal de loop (chamada a cada frame do jogo)
local function updateNeonESPAura()
    
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return end
    
    local localPosition = localCharacter.HumanoidRootPart.Position
    local neonColor = getNeonColor()
    
    for playerObj, espData in pairs(espObjects) do
        -- Verifica se o jogador está vivo e o highlight existe
        if espData.highlight and playerObj.Character and playerObj.Character:FindFirstChild("HumanoidRootPart") and playerObj.Character:FindFirstChild("Humanoid") then
            local character = playerObj.Character
            local humanoidRootPart = character.HumanoidRootPart
            local humanoid = character.Humanoid
            
            local distance = (localPosition - humanoidRootPart.Position).Magnitude
            
            if distance <= ESP_DISTANCE and humanoid.Health > 0 then
                -- Aplica a cor RGB em loop
                espData.highlight.OutlineColor = neonColor
                espData.highlight.OutlineTransparency = OUTLINE_THICKNESS
                espData.highlight.Enabled = true
            else
                -- Desativa se estiver fora do alcance ou morto
                espData.highlight.Enabled = false
            end
        elseif espData.highlight then
            -- Desativa se o personagem não estiver carregado
            espData.highlight.Enabled = false
        end
    end
end

---
-- FUNÇÕES PÚBLICAS (EXPOSTAS)
---

-- Esta é a função que a interface chamará
function ESPScript.toggleNeonESPAura(active)
    if active then
        -- Inicia o loop de atualização
        if not heartbeatConnection then
            heartbeatConnection = RunService.Heartbeat:Connect(updateNeonESPAura)
        end
        
        -- Garante que todos os jogadores ativos tenham o Highlight criado e ativado
        for _, playerObj in pairs(Players:GetPlayers()) do
            addESPToPlayer(playerObj) 
            local espData = espObjects[playerObj]
            if espData and espData.highlight then
                espData.highlight.Enabled = true -- Ativa imediatamente o highlight
            end
        end
        
        print("Neon Aura (RGB) Ativada!")
    else
        -- Desativa e limpa o loop
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        
        -- Desativa o highlight em todos os jogadores
        for _, espData in pairs(espObjects) do
            if espData.highlight then
                espData.highlight.Enabled = false
            end
        end
        
        print("Neon Aura (RGB) Desativada!")
    end
end

---
-- INICIALIZAÇÃO E CONEXÕES
---

-- Atribui a função de toggle ao escopo global para que Interface-Main.lua possa chamá-la
_G.toggleNeonESPAura = ESPScript.toggleNeonESPAura

-- Conexão para gerenciar jogadores que entram e saem
Players.PlayerAdded:Connect(addESPToPlayer)
Players.PlayerRemoving:Connect(removeESPFromPlayer)

-- Cria ESP para jogadores que já estão no jogo quando o script é carregado
for _, playerObj in pairs(Players:GetPlayers()) do
    addESPToPlayer(playerObj)
end

print("scripts.lua (Módulo ESP) carregado e pronto.")

-- O módulo retorna a tabela com as funções públicas
return ESPScript
