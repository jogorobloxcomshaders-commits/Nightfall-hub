-- Interface-Main.lua (Refatorado)

-- 1. Carrega Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 2. Variáveis de Estado
local currentActiveTabButton = nil
local contentFrame = nil
local TAB_BUTTONS = {}

-- 3. Carrega Módulos (Assumindo que estão na mesma localização)
-- **IMPORTANTE:** Mude o caminho abaixo se os módulos estiverem em outro lugar
local CONFIG = require(script.InterfaceConfig)
local Builder = require(script.InterfaceBuilder)
Builder.init(CONFIG) -- Inicializa o Builder com as configurações

-- Inicializa Funções Globais Placeholders (Para evitar erros de referência antes do scripts.lua carregar)
_G.toggleNeonESPAura = function(active) warn("Função toggleNeonESPAura não carregada.") end
_G.toggleLineESP = function(active) warn("Função toggleLineESP não carregada.") end


---
-- FUNÇÕES DE CONTROLE PRINCIPAL
---

-- Função que retorna o botão ativo (usada no MouseLeave/Enter do Builder)
local function getCurrentActiveTabButton()
    return currentActiveTabButton
end

-- Função principal para troca de abas
local function switchTab(tabButton)
    local tabName = tabButton:GetAttribute("TabName")
    
    if currentActiveTabButton == tabButton then return end

    -- 1. Reseta a aba anterior (função do Builder)
    Builder.resetTabButton(currentActiveTabButton)

    -- 2. Ativa e estiliza a nova aba
    Builder.animateTabExpand(
        tabButton, 
        UDim2.new(1, -10, 0, 45), 
        0, 
        CONFIG.UI.TAB_ACTIVE_COLOR, 
        0
    ) 
    Builder.animateTabShadow(tabButton, true) 
    currentActiveTabButton = tabButton
    
	-- 3. Limpa o ContentFrame
	for _, child in pairs(contentFrame:GetChildren()) do 
		if not child:IsA("UICorner") then
			child:Destroy()
		end
	end
	
	-- 4. Cria o Título
	local tabTitle = Instance.new("TextLabel")
	tabTitle.Name = "TabTitle"
	tabTitle.Size = UDim2.new(1, -40, 0, 40)
	tabTitle.Position = UDim2.new(0, 20, 0, 20)
	tabTitle.BackgroundTransparency = 1
	tabTitle.Text = tabName
	tabTitle.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY
	tabTitle.TextSize = 24
	tabTitle.Font = Enum.Font.GothamBold
	tabTitle.TextXAlignment = Enum.TextXAlignment.Left
	tabTitle.Parent = contentFrame
	
	-- 5. Cria o ContentContainer e chama o Builder
	local tabContent = Instance.new("Frame")
	tabContent.Name = "TabContent"
	tabContent.Size = UDim2.new(1, 0, 1, -70)
	tabContent.Position = UDim2.new(0, 0, 0, 70)
	tabContent.BackgroundTransparency = 1
	tabContent.Parent = contentFrame
	
	Builder.setupTabContent(tabName, tabContent)
end


-- FUNÇÃO DE INICIALIZAÇÃO DA GUI
local function setupGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Interface"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = CONFIG.PALETTE.BLACK_SATIN
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    -- ... (Criação de TabsScrollFrame, TabsContainer, etc. mantida por brevidade) ...

    local tabsScrollFrame = Instance.new("ScrollingFrame")
    tabsScrollFrame.Name = "TabsScrollFrame"
    tabsScrollFrame.Size = UDim2.new(0.2, 0, 1, -80)
    tabsScrollFrame.Position = UDim2.new(0, 20, 0, 60)
    tabsScrollFrame.BackgroundTransparency = 1
    tabsScrollFrame.BorderSizePixel = 0
    tabsScrollFrame.ScrollBarThickness = 6
    tabsScrollFrame.ScrollBarImageColor3 = CONFIG.PALETTE.INDIGO_DUSK
    tabsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    tabsScrollFrame.Parent = mainFrame
    
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, -10, 1, 0)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = tabsScrollFrame
    
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 12)
    tabsLayout.Parent = tabsContainer

    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, tabsLayout.AbsoluteContentSize.Y)
    end)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 200, 0, 30)
    titleLabel.Position = UDim2.new(0, 20, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "nightfall hub"
    titleLabel.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame

    local topButtonsContainer = Instance.new("Frame")
    topButtonsContainer.Name = "TopButtons"
    topButtonsContainer.Size = UDim2.new(0, 100, 0, 30)
    topButtonsContainer.Position = UDim2.new(1, -120, 0, 20)
    topButtonsContainer.BackgroundTransparency = 1
    topButtonsContainer.Parent = mainFrame
    
    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    topLayout.Padding = UDim.new(0, 8)
    topLayout.Parent = topButtonsContainer

    local minimizeButton = Builder.createTopButton("Minimize", "—", topButtonsContainer)
    local closeButton = Builder.createTopButton("Close", "✕", topButtonsContainer)

    local contentFrameRef = Instance.new("Frame")
    contentFrameRef.Name = "ContentFrame"
    contentFrameRef.Size = UDim2.new(0.75, -40, 1, -80)
    contentFrameRef.Position = UDim2.new(0.25, 0, 0, 60)
    contentFrameRef.BackgroundColor3 = CONFIG.PALETTE.EBONY_GLOW
    contentFrameRef.BackgroundTransparency = CONFIG.UI.CONTENT_FRAME_TRANSPARENCY 
    contentFrameRef.BorderSizePixel = 0
    contentFrameRef.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 12)
    contentCorner.Parent = contentFrameRef
    
    -- Criação das abas usando a tabela de configuração
    local firstTabButton = nil
    for order, tabConfig in ipairs(CONFIG.TABS_CONFIG) do
        local button = Builder.createTabButton(tabConfig, order, tabsContainer, getCurrentActiveTabButton)
        if order == 1 then
            firstTabButton = button
        end
        TAB_BUTTONS[tabConfig.Name] = button
    end
    
    -- ... (Lógica de minimização e fechamento mantida) ...
    
    local isMinimized = false
    closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.8, 0, 0, 60)
            }):Play()
            tabsScrollFrame.Visible = false
            contentFrameRef.Visible = false
            titleLabel.Visible = true
            minimizeButton.Text = "□"
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.8, 0, 0.8, 0)
            }):Play()
            task.wait(0.1) 
            tabsScrollFrame.Visible = true
            contentFrameRef.Visible = true
            titleLabel.Visible = true
            minimizeButton.Text = "—"
        end
    end)
    
    return contentFrameRef, firstTabButton
end

-- INICIALIZAÇÃO
contentFrame, firstTabButton = setupGUI() 
switchTab(firstTabButton)
