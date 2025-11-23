-- ===============================================
-- 🎬 INTERFACE ANIMATIONS & MOVEMENT LOCAL SCRIPT
-- ===============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Encontre o MainFrame (supondo que este script esteja em algum lugar acessível a ele)
local MainFrame = script.Parent:WaitForChild("MainFrame")
local TitleLabel = MainFrame:WaitForChild("Title")

-- Configurações
local DRAG_SPEED = 0.5
local INITIAL_SIZE = UDim2.new(0.7, 0, 0.7, 0) -- Tamanho ligeiramente menor para o efeito pop
local TARGET_SIZE = UDim2.new(0.8, 0, 0.8, 0)
local DRAG_BAR_HEIGHT = 60 -- Altura da área clicável para arrastar (Título e botões superiores)

-- ===============================================
-- ANIMAÇÃO DE ABERTURA
-- ===============================================

local function animateOpening()
    -- Garante que ele comece escondido e centralizado
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Active = false -- Desativa temporariamente para evitar cliques antes da animação

    -- Efeito de pop-in
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.OutBack, Enum.EasingDirection.Out), {
        Size = TARGET_SIZE,
        Active = true
    }):Play()
end

-- ===============================================
-- EFEITO DRAG (MOVER O FRAME)
-- ===============================================

local dragging = false
local dragOffset = Vector2.new()

-- Função para verificar se o clique está na "barra de título"
local function isOverDragArea(position)
    local absolutePosition = MainFrame.AbsolutePosition
    local absoluteSize = MainFrame.AbsoluteSize
    
    local xMin = absolutePosition.X
    local xMax = absolutePosition.X + absoluteSize.X
    local yMin = absolutePosition.Y
    local yMax = absolutePosition.Y + DRAG_BAR_HEIGHT -- Apenas o topo do Frame é arrastável

    return position.X >= xMin and position.X <= xMax and position.Y >= yMin and position.Y <= yMax
end

TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Verifica se o clique está dentro da área arrastável
        if isOverDragArea(input.Position) then
            dragging = true
            dragOffset = input.Position - MainFrame.AbsolutePosition
            -- Coloca o frame no topo da hierarquia Z para garantir que ele esteja acima de tudo
            MainFrame.ZIndex = 10 
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local newPosition = input.Position - dragOffset
        
        -- Converte a posição absoluta do mouse para UDim2
        local x = newPosition.X / player.Character.PrimaryPart.Parent.ViewportSize.X
        local y = newPosition.Y / player.Character.PrimaryPart.Parent.ViewportSize.Y
        
        -- Atualiza a posição suavemente (opcional, mas bom para lag)
        MainFrame.Position = MainFrame.Position:Lerp(UDim2.new(x, 0, y, 0), DRAG_SPEED)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        MainFrame.ZIndex = 1 -- Volta ao ZIndex padrão após soltar
    end
end)

-- ===============================================
-- ANIMAÇÃO DOS BOTÕES DE AÇÃO (HOVER/CLICK)
-- ===============================================

local function setupButtonAnimations(container)
    for _, child in pairs(container:GetChildren()) do
        if child:IsA("TextButton") then
            -- Animação de escala ao entrar no hover
            child.MouseEnter:Connect(function()
                TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, 44) -- Pequeno aumento de 4px
                }):Play()
            end)

            -- Animação de retorno ao sair do hover
            child.MouseLeave:Connect(function()
                TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, 40) -- Retorna ao tamanho original
                }):Play()
            end)
        end
    end
end

-- Monitora o ContentFrame para novos elementos
MainFrame.ChildAdded:Connect(function(child)
    if child.Name == "ContentFrame" then
        child.ChildAdded:Connect(function(tab)
            if tab.Name == "TabContent" then
                tab.ChildAdded:Connect(function(scroll)
                    -- Assim que o container de seções for criado
                    if scroll:IsA("ScrollingFrame") then
                        scroll.ChildAdded:Connect(function(sectionsContainer)
                            if sectionsContainer.Name == "SectionsContainer" then
                                -- Monitora a adição de cada SEÇÃO
                                sectionsContainer.ChildAdded:Connect(function(section)
                                    if section:IsA("Frame") and section.Name:match("Section$") then
                                        -- Monitora os botões dentro do container de botões de cada seção
                                        local buttonsContainer = section:FindFirstChild("Buttons")
                                        if buttonsContainer then
                                            setupButtonAnimations(buttonsContainer)
                                            -- Adiciona um monitor para botões que são criados depois
                                            buttonsContainer.ChildAdded:Connect(setupButtonAnimations) 
                                        end
                                    end
                                end)
                            end
                        end)
                    end
                end)
            end
        end)
    end
end)

-- ===============================================
-- INICIALIZAÇÃO
-- ===============================================

animateOpening()
print("Script de animação e arrastar inicializado.")
