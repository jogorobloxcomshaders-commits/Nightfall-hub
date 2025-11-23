-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local currentActiveTabButton = nil
local contentFrame = nil -- Declarado aqui para ser acessível por switchTab

-- PALETA
local PURPLE_BASE = Color3.fromRGB(131, 0, 196) 
local PURPLE_HOVER = Color3.fromRGB(171, 0, 255) 
local DARK_PURPLE_TAB_BASE = Color3.fromRGB(45, 0, 70) 
local DARK_PURPLE_TAB_HOVER = Color3.fromRGB(70, 0, 100) 
local GREEN_BASE = Color3.fromRGB(60, 200, 120)

-- FUNÇÕES DE ANIMAÇÃO E UI

local function animateTabExpand(tabButton, targetSize, targetTransparency, targetColor)
    TweenService:Create(tabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = targetSize,
        BackgroundColor3 = targetColor
    }):Play()
    
    local nameLabel = tabButton:FindFirstChild("NameLabel")
    if nameLabel then
        TweenService:Create(nameLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            TextTransparency = targetTransparency
        }):Play()
    end
end

local function resetTabButton(button)
    if button then
        animateTabExpand(button, UDim2.new(0, 45, 0, 45), 1, DARK_PURPLE_TAB_BASE)
    end
end

local function createTopButton(name, icon, parent)
	local button = Instance.new("TextButton")
	button.Name = name .. "Button"
	button.Size = UDim2.new(0, 40, 0, 30)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	button.BorderSizePixel = 0
	button.Text = icon
	button.TextColor3 = Color3.fromRGB(200, 200, 210)
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button
	
	return button
end

local function createTabButton(name, icon, order, tabsContainer)
	local tabButton = Instance.new("TextButton")
	tabButton.Name = name .. "Tab"
	tabButton.Size = UDim2.new(0, 45, 0, 45)
	tabButton.BackgroundColor3 = DARK_PURPLE_TAB_BASE
	tabButton.BorderSizePixel = 0
	tabButton.Text = ""
	tabButton.TextColor3 = Color3.fromRGB(200, 200, 210)
	tabButton.TextSize = 18
	tabButton.Font = Enum.Font.GothamBold
	tabButton.LayoutOrder = order
	tabButton.ClipsDescendants = true
	tabButton.Parent = tabsContainer
    tabButton:SetAttribute("TabName", name)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = tabButton
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "IconLabel"
	iconLabel.Size = UDim2.new(0, 45, 1, 0)
	iconLabel.Position = UDim2.new(0, 0, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = icon
	iconLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
	iconLabel.TextSize = 18
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = tabButton
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -50, 1, 0)
	nameLabel.Position = UDim2.new(0, 50, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTransparency = 1
	nameLabel.Parent = tabButton
	
	tabButton.MouseEnter:Connect(function()
        if tabButton ~= currentActiveTabButton then
            animateTabExpand(tabButton, UDim2.new(1, -10, 0, 45), 0, DARK_PURPLE_TAB_HOVER)
        end
	end)
	
	tabButton.MouseLeave:Connect(function()
        if tabButton ~= currentActiveTabButton then
            animateTabExpand(tabButton, UDim2.new(0, 45, 0, 45), 1, DARK_PURPLE_TAB_BASE)
        end
	end)
	
	return tabButton
end

local function createSection(sectionName, parent)
	local sectionContainer = Instance.new("Frame")
	sectionContainer.Name = sectionName .. "Section"
	sectionContainer.Size = UDim2.new(1, 0, 0, 150) -- Altura fixa para começar
	sectionContainer.BackgroundTransparency = 0
    sectionContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 42) 
    sectionContainer.BorderSizePixel = 0
	sectionContainer.Parent = parent

    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 10)
    sectionCorner.Parent = sectionContainer
	
	local sectionTitle = Instance.new("TextLabel")
	sectionTitle.Name = "SectionTitle"
	sectionTitle.Size = UDim2.new(1, -20, 0, 20)
	sectionTitle.Position = UDim2.new(0, 10, 0, 10) 
	sectionTitle.BackgroundTransparency = 1
	sectionTitle.Text = string.upper(sectionName)
	sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	sectionTitle.TextSize = 16
	sectionTitle.Font = Enum.Font.GothamBold
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	sectionTitle.Parent = sectionContainer
	
	local buttonsContainer = Instance.new("Frame")
	buttonsContainer.Name = "Buttons"
	buttonsContainer.Size = UDim2.new(1, -20, 1, -40) 
	buttonsContainer.Position = UDim2.new(0, 10, 0, 35) 
	buttonsContainer.BackgroundTransparency = 1
	buttonsContainer.Parent = sectionContainer
	
	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buttonLayout.Padding = UDim.new(0, 8)
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	buttonLayout.Parent = buttonsContainer

    buttonLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = buttonLayout.AbsoluteContentSize.Y + 45 
        sectionContainer.Size = UDim2.new(1, 0, 0, contentHeight)
    end)
    
	return {Container = sectionContainer, Buttons = buttonsContainer}
end

local function setupTabContent(tabName, contentParent)
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = tabName .. "ScrollContent"
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y 
	scrollFrame.Parent = contentParent

	local container = Instance.new("Frame")
	container.Name = "SectionsContainer"
	container.Size = UDim2.new(1, -40, 1, -20)
	container.Position = UDim2.new(0, 20, 0, 10)
	container.BackgroundTransparency = 1
	container.Parent = scrollFrame
	
	local listLayout = Instance.new("UIListLayout")
    listLayout.Name = "SectionsListLayout"
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 20) 
	listLayout.Parent = container

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
	end)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)


	if tabName == "Home" then
		local houses = createSection("Casas", container)
        houses.Container.LayoutOrder = 1
		
		local playerSec = createSection("Player", container)
        playerSec.Container.LayoutOrder = 2
		
	elseif tabName == "Visuals" then
		local esp = createSection("ESP", container)
        esp.Container.LayoutOrder = 1
		
		local chams = createSection("Chams", container)
        chams.Container.LayoutOrder = 2
        
		local fx = createSection("FX", container)
        fx.Container.LayoutOrder = 3
		
	elseif tabName == "Settings" then
		local general = createSection("Geral", container)
        general.Container.LayoutOrder = 1

		local theme = createSection("Temas", container)
        theme.Container.LayoutOrder = 2
		
	elseif tabName == "Combat" then
		local aimbot = createSection("Aimbot", container)
        aimbot.Container.LayoutOrder = 1

		local meele = createSection("Meele", container)
        meele.Container.LayoutOrder = 2

	elseif tabName == "Info" then
		local credits = createSection("Créditos", container)
        credits.Container.LayoutOrder = 1
		
		local version = createSection("Versão", container)
        version.Container.LayoutOrder = 2
	end
end

local function switchTab(tabButton)
    local tabName = tabButton:GetAttribute("TabName")
    
    if currentActiveTabButton == tabButton then
        return
    end

    resetTabButton(currentActiveTabButton)

    animateTabExpand(tabButton, UDim2.new(1, -10, 0, 45), 0, DARK_PURPLE_TAB_HOVER)
    currentActiveTabButton = tabButton
    
	for _, child in pairs(contentFrame:GetChildren()) do 
		if not child:IsA("UICorner") then
			child:Destroy()
		end
	end
	
	local tabTitle = Instance.new("TextLabel")
	tabTitle.Name = "TabTitle"
	tabTitle.Size = UDim2.new(1, -40, 0, 40)
	tabTitle.Position = UDim2.new(0, 20, 0, 20)
	tabTitle.BackgroundTransparency = 1
	tabTitle.Text = tabName
	tabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabTitle.TextSize = 24
	tabTitle.Font = Enum.Font.GothamBold
	tabTitle.TextXAlignment = Enum.TextXAlignment.Left
	tabTitle.Parent = contentFrame
	
	local tabContent = Instance.new("Frame")
	tabContent.Name = "TabContent"
	tabContent.Size = UDim2.new(1, 0, 1, -70)
	tabContent.Position = UDim2.new(0, 0, 0, 70)
	tabContent.BackgroundTransparency = 1
	tabContent.Parent = contentFrame
	
	setupTabContent(tabName, tabContent)
	
	currentTab = tabName
end

-- INICIALIZAÇÃO DA INTERFACE

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
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    local tabsScrollFrame = Instance.new("ScrollingFrame")
    tabsScrollFrame.Name = "TabsScrollFrame"
    tabsScrollFrame.Size = UDim2.new(0.2, 0, 1, -80)
    tabsScrollFrame.Position = UDim2.new(0, 20, 0, 60)
    tabsScrollFrame.BackgroundTransparency = 1
    tabsScrollFrame.BorderSizePixel = 0
    tabsScrollFrame.ScrollBarThickness = 6
    tabsScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
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
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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

    local minimizeButton = createTopButton("Minimize", "—", topButtonsContainer)
    local closeButton = createTopButton("Close", "✕", topButtonsContainer)

    local contentFrameRef = Instance.new("Frame")
    contentFrameRef.Name = "ContentFrame"
    contentFrameRef.Size = UDim2.new(0.75, -40, 1, -80)
    contentFrameRef.Position = UDim2.new(0.25, 0, 0, 60)
    contentFrameRef.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    contentFrameRef.BorderSizePixel = 0
    contentFrameRef.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 12)
    contentCorner.Parent = contentFrameRef
    
    local tab1 = createTabButton("Home", "🏠", 1, tabsContainer)
    local tab2 = createTabButton("Visuals", "👁", 2, tabsContainer)
    local tab3 = createTabButton("Settings", "⚙️", 3, tabsContainer)
    local tab4 = createTabButton("Combat", "⚔", 4, tabsContainer)
    local tab5 = createTabButton("Info", "ℹ️", 5, tabsContainer)

    tab1.MouseButton1Click:Connect(function() switchTab(tab1) end)
    tab2.MouseButton1Click:Connect(function() switchTab(tab2) end)
    tab3.MouseButton1Click:Connect(function() switchTab(tab3) end)
    tab4.MouseButton1Click:Connect(function() switchTab(tab4) end)
    tab5.MouseButton1Click:Connect(function() switchTab(tab5) end)

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

    return contentFrameRef
end

contentFrame = setupGUI() -- Atribui a referência à variável global
switchTab(contentFrame:FindFirstChildOfClass("TextButton"))

task.wait()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jogorobloxcomshaders-commits/Nightfall-hub/refs/heads/main/Interfaceanm.lua"))()
