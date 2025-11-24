-- 🧩 Servicios
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- 🌐 Variables globales
getgenv().autoFlash = false
local targetPlayer = nil 
local minimized = false
local currentHighlight = nil -- Solo para el objetivo del AutoFlash
local highlightConn = nil
local maxPerSecond = 1000 -- Esta variable ya no se usará para el bucle constante, pero se mantiene para la GUI
local sentThisSecond = 0 -- Esta variable ya no se usará para el bucle constante

-- 🚩 Variables de la Pestaña Extra
local afkEnabled = false
local noClipEnabled = false
local noClipConn = nil
local customSkyboxEnabled = false -- Nueva variable para Skybox
local espEnabled = false -- Nueva variable para ESP
local espConnections = {} -- Para manejar las conexiones del ESP
local espHighlights = {} -- Para guardar los Highlights del ESP
local espUpdateConn = nil -- Conexión para el loop de actualización del ESP
local infiniteYieldLoaded = false -- ⬅️ NUEVA VARIABLE PARA INFINITE YIELD

-- 🌫️ Blur de fondo
local blur = Instance.new("BlurEffect")
blur.Size = 12
blur.Name = "UIBlur"
blur.Parent = Lighting

-- 🖥️ GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = "😈SixSixClan😈"
ScreenGui.Parent = PlayerGui

-- 🎛️ Marco principal (ANIMADO) - DEBE IR PRIMERO
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 270)
Frame.Position = UDim2.new(0.5, -150, 0.5, -135)
Frame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.ClipsDescendants = true
Frame.ZIndex = 1
Frame.Parent = ScreenGui

-- 🌑 Fondo infernal oscuro dentro del Frame
local BGImage = Instance.new("ImageLabel")
BGImage.Size = UDim2.new(1,0,1,0)
BGImage.Position = UDim2.new(0,0,0,0)
BGImage.BackgroundTransparency = 1
BGImage.Image = "rbxassetid://83339138877786" -- 🔥 textura infernal (Placeholder)
BGImage.ImageTransparency = 0.7
BGImage.ZIndex = 0
BGImage.ClipsDescendants = true
BGImage.Parent = Frame

-- Humo negro flotante dentro del Frame
local smokeFolder = Instance.new("Folder")
smokeFolder.Name = "Smoke"
smokeFolder.Parent = Frame
task.spawn(function()
    while Frame and Frame.Parent do
        local smoke = Instance.new("Frame")
        smoke.Size = UDim2.new(0, math.random(60,120), 0, math.random(30,60))
        smoke.Position = UDim2.new(math.random(),0,1,0)
        smoke.BackgroundColor3 = Color3.fromRGB(0,0,0)
        smoke.BackgroundTransparency = 0.7
        smoke.BorderSizePixel = 0
        smoke.ZIndex = 0
        smoke.Parent = smokeFolder
        TweenService:Create(smoke, TweenInfo.new(math.random(8,15), Enum.EasingStyle.Linear), {
            Position = UDim2.new(smoke.Position.X.Scale,0,-0.2,0),
            BackgroundTransparency = 1
        }):Play()
        task.delay(math.random(2,5), function()
            pcall(function() smoke:Destroy() end)
        end)
        task.wait(0.2)
    end
end)

-- 🌈 Gradiente animado sobre el Frame
local AnimatedGradient = Instance.new("UIGradient")
AnimatedGradient.Rotation = 0
AnimatedGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 0, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 200))
}
AnimatedGradient.Parent = Frame
task.spawn(function()
    local colorSets = {
        {Color3.fromRGB(255,30,30), Color3.fromRGB(80,0,80), Color3.fromRGB(0,0,200)},
        {Color3.fromRGB(0,0,200), Color3.fromRGB(0,200,255), Color3.fromRGB(80,0,80)},
        {Color3.fromRGB(200,0,0), Color3.fromRGB(255,100,0), Color3.fromRGB(255,0,150)}
    }
    local currentSet = 1
    while Frame and Frame.Parent do
        for i = 0, 360, 1 do
            AnimatedGradient.Rotation = i
            task.wait(0.02)
        end
        currentSet = (currentSet % #colorSets) + 1
        local set = colorSets[currentSet]
        TweenService:Create(AnimatedGradient, TweenInfo.new(3, Enum.EasingStyle.Quad), {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0,set[1]),
                ColorSequenceKeypoint.new(0.5,set[2]),
                ColorSequenceKeypoint.new(1,set[3])
            }
        }):Play()
    end
end)

-- 🩸 Partículas ascendentes de fondo
local BGParticles = Instance.new("Frame")
BGParticles.Size = UDim2.new(1,0,1,0)
BGParticles.BackgroundTransparency = 1
BGParticles.ClipsDescendants = true
BGParticles.ZIndex = 1
BGParticles.Parent = Frame
task.spawn(function()
    while Frame and Frame.Parent do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, math.random(2,6), 0, math.random(2,6))
        dot.Position = UDim2.new(math.random(),0,1,0)
        dot.BackgroundColor3 = Color3.fromRGB(255, math.random(0,80), math.random(0,120))
        dot.BackgroundTransparency = 0.4
        dot.BorderSizePixel = 0
        dot.ZIndex = 1
        dot.Parent = BGParticles
        TweenService:Create(dot, TweenInfo.new(math.random(3,6)), {
            Position = UDim2.new(dot.Position.X.Scale,0,0,-10),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.1)
    end
end)

-- 🩸 Partículas decorativas tipo símbolos
local symbols = {"🩸","",""}
local particleFolder = Instance.new("Folder", Frame)
particleFolder.Name = "Particles"
task.spawn(function()
    while Frame and Frame.Parent do
        local sym = symbols[math.random(1,#symbols)]
        local particle = Instance.new("TextLabel")
        particle.Text = sym
        particle.TextColor3 = Color3.fromRGB(255,50,50)
        particle.Font = Enum.Font.GothamBlack
        particle.TextSize = math.random(15,25)
        particle.BackgroundTransparency = 1
        particle.Position = UDim2.new(math.random(),0,0,-0.1)
        particle.ZIndex = 2
        particle.Parent = particleFolder
        local tween = TweenService:Create(particle, TweenInfo.new(math.random(2,4), Enum.EasingStyle.Quad), {Position=UDim2.new(particle.Position.X.Scale,0,1,0), TextTransparency=1})
        tween:Play()
        tween.Completed:Connect(function() pcall(function() particle:Destroy() end) end)
        task.wait(0.2)
    end
end)

-- 🔲 Borde y esquinas
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255,50,50)
UIStroke.Transparency = 0.2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,12)

-- 🖼️ Ícono del clan (alineado al lado del título)
local Icon = Instance.new("ImageLabel")
Icon.Name = "ClanIcon"
Icon.Image = "rbxassetid://131574561771512" 
Icon.Size = UDim2.new(0, 28, 0, 28)
Icon.Position = UDim2.new(0, 10, 0, 7) 
Icon.BackgroundTransparency = 1
Icon.ZIndex = 3
Icon.Parent = Frame

-- ✨ Gradiente animado igual al del fondo
local IconGradient = Instance.new("UIGradient")
IconGradient.Rotation = 0
IconGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 30)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 0, 80)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 200))
}
IconGradient.Parent = Icon

-- 🌀 Animación sincronizada con el efecto del Frame
task.spawn(function()
	local colorSets = {
		{Color3.fromRGB(255,30,30), Color3.fromRGB(80,0,80), Color3.fromRGB(0,0,200)},
		{Color3.fromRGB(0,0,200), Color3.fromRGB(0,200,255), Color3.fromRGB(80,0,80)},
		{Color3.fromRGB(200,0,0), Color3.fromRGB(255,100,0), Color3.fromRGB(255,0,150)}
	}
	local currentSet = 1
	while Icon and Icon.Parent do
		for i = 0, 360, 1 do
			IconGradient.Rotation = i
			task.wait(0.02)
		end
		currentSet = (currentSet % #colorSets) + 1
		local set = colorSets[currentSet]
		TweenService:Create(IconGradient, TweenInfo.new(3, Enum.EasingStyle.Quad), {
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0,set[1]),
				ColorSequenceKeypoint.new(0.5,set[2]),
				ColorSequenceKeypoint.new(1,set[3])
			}
		}):Play()
	end
end)

-- 🏷️ Título siniestro
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-60,0,40)
Title.Position = UDim2.new(0,45,0,0)
Title.BackgroundTransparency = 1
Title.Text = "⸸ SixSixClan ⸸"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Fantasy
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = Frame

-- 🌈 Gradiente animado (negro → rojo → blanco)
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Rotation = 0
TitleGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
TitleGradient.Parent = Title

-- 💀 Brillo exterior tipo neón rojo
local Glow = Instance.new("TextLabel")
Glow.Size = Title.Size
Glow.Position = Title.Position
Glow.BackgroundTransparency = 1
Glow.Text = Title.Text
Glow.Font = Title.Font
Glow.TextSize = Title.TextSize
Glow.TextXAlignment = Title.TextXAlignment
Glow.TextColor3 = Color3.fromRGB(150, 0, 0)
Glow.ZIndex = 2
Glow.Parent = Frame

-- 🔥 Animación de brillo + gradiente rotativo
task.spawn(function()
	local increasing = true
	while Title and Title.Parent do
		-- Rotación del gradiente para efecto oscuro animado
		for i = 0, 360, 3 do
			if not Title or not TitleGradient then break end
			TitleGradient.Rotation = i
			task.wait(0.02)
		end

		-- Efecto de pulso neón (rojo intenso)
		local goalColor = increasing and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(80, 0, 0)
		TweenService:Create(Glow, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			TextColor3 = goalColor
		}):Play()

		increasing = not increasing
		task.wait(0.7)
	end
end)

-- 🔒 Botón anclar
local AnchorButton = Instance.new("TextButton")
AnchorButton.Size = UDim2.new(0,30,0,30)
AnchorButton.Position = UDim2.new(1,-75,0,5)
AnchorButton.BackgroundTransparency = 1
AnchorButton.Text = "🔓"
AnchorButton.TextSize = 18
AnchorButton.TextColor3 = Color3.fromRGB(255,255,255)
AnchorButton.Font = Enum.Font.GothamBold
AnchorButton.Parent = Frame

-- 🔽 Botón minimizar
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0,30,0,30)
MinButton.Position = UDim2.new(1,-40,0,5)
MinButton.BackgroundColor3 = Color3.fromRGB(50,0,0)
MinButton.Text = "−"
MinButton.TextColor3 = Color3.fromRGB(255,50,50)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 18
MinButton.Parent = Frame
Instance.new("UICorner", MinButton).CornerRadius = UDim.new(0,8)

-- ✋ Arrastre libre + anclar (sin límites)
local ExtraTab 
do
    local dragging = false
    local dragStart, startPos
    local anchored = false

    local function update(input)
        if anchored then return end 
        if not dragging then return end
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        -- Si la pestaña extra está visible, también moverla
        if ExtraTab and ExtraTab.Visible then
            ExtraTab.Position = Frame.Position
        end
    end

    Frame.InputBegan:Connect(function(input)
        if anchored then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    -- Botón de anclaje (bloquear movimiento)
    AnchorButton.MouseButton1Click:Connect(function()
        anchored = not anchored
        AnchorButton.Text = anchored and "🔒" or "🔓"
    end)
end

-- ✏️ Caja de texto (Sigue siendo para seleccionar el objetivo de AutoFlash)
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1,-40,0,40)
TextBox.Position = UDim2.new(0,20,0,60)
TextBox.BackgroundColor3 = Color3.fromRGB(60,0,0)
TextBox.TextColor3 = Color3.fromRGB(255,200,200)
TextBox.PlaceholderText = "Nombre del objetivo (AutoFlash)"
TextBox.PlaceholderColor3 = Color3.fromRGB(255,120,120)
TextBox.Font = Enum.Font.Fantasy
TextBox.TextSize = 14
TextBox.ClearTextOnFocus = true
TextBox.Parent = Frame
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0,8)

-- 🧾 Estado
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1,-40,0,30)
StatusLabel.Position = UDim2.new(0,20,0,110)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Esperando selección..."
StatusLabel.TextColor3 = Color3.fromRGB(255,120,120)
StatusLabel.Font = Enum.Font.Fantasy
StatusLabel.TextSize = 14
StatusLabel.Parent = Frame

-- ⚙️ Botón principal
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1,-60,0,45)
ToggleButton.Position = UDim2.new(0,30,0,150)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180,0,0)
ToggleButton.Text = "▶ Iniciar AutoFlash"
ToggleButton.TextColor3 = Color3.fromRGB(255,200,200)
ToggleButton.Font = Enum.Font.Fantasy
ToggleButton.TextSize = 16
ToggleButton.Parent = Frame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0,10)

-- ⚡ Highlight y búsqueda de objetivo para AutoFlash
local function removeHighlight()
    if currentHighlight then
        pcall(function() currentHighlight:Destroy() end)
        currentHighlight = nil
    end
    if highlightConn then
        highlightConn:Disconnect()
        highlightConn = nil
    end
end

TextBox.FocusLost:Connect(function(enterPressed)
    local name = TextBox.Text
    if name == "" then
        StatusLabel.Text = "⚠️ Escribí un nombre. (AutoFlash)"
        targetPlayer = nil
        removeHighlight()
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
    if string.lower(player.Name) == string.lower(name) 
    or string.find(string.lower(player.Name), string.lower(name)) then
            targetPlayer = player
            StatusLabel.Text = "✅ Objetivo AutoFlash: " .. player.Name
            removeHighlight()
            if player.Character then
                currentHighlight = Instance.new("Highlight")
                currentHighlight.Name = "TargetHighlight"
                currentHighlight.FillColor = Color3.fromRGB(255,255,0) -- Amarillo para el objetivo de ataque
                currentHighlight.FillTransparency = 0.5
                currentHighlight.OutlineColor = Color3.fromRGB(255,200,0)
                currentHighlight.OutlineTransparency = 0
                currentHighlight.Adornee = player.Character
                currentHighlight.Parent = player.Character

                task.spawn(function()
                    local increasing = true
                    while currentHighlight and currentHighlight.Parent do
                        if increasing then
                            currentHighlight.FillTransparency = math.max(0, currentHighlight.FillTransparency - 0.01)
                            currentHighlight.OutlineTransparency = math.max(0, currentHighlight.OutlineTransparency - 0.01)
                        else
                            currentHighlight.FillTransparency = math.min(1, currentHighlight.FillTransparency + 0.01)
                            currentHighlight.OutlineTransparency = math.min(1, currentHighlight.OutlineTransparency + 0.01)
                        end
                        if currentHighlight.FillTransparency <= 0.3 then
                            increasing = false
                        elseif currentHighlight.FillTransparency >= 0.5 then
                            increasing = true
                        end
                        task.wait(0.02)
                    end
                end)

                highlightConn = player.CharacterAdded:Connect(function(char)
                    if currentHighlight then
                        currentHighlight.Adornee = char
                    end
                end)
            end
            return
        end
    end
    StatusLabel.Text = "❌ Jugador no encontrado."
    targetPlayer = nil
    removeHighlight()
end)

-- ⚙️ Remote Flash
local remoteTriggers = ReplicatedStorage:FindFirstChild("RemoteTriggers")
local createFlash = remoteTriggers and remoteTriggers:FindFirstChild("CreateFlash")

-- 🧮 Control límite dinámico (FUNCIONA + AHORA SE USA EN EL BUCLE)
local LimitLabel = Instance.new("TextLabel")
LimitLabel.Size = UDim2.new(1,-40,0,20)
LimitLabel.Position = UDim2.new(0,20,0,200)
LimitLabel.BackgroundTransparency = 1
LimitLabel.TextColor3 = Color3.fromRGB(255,200,200)
LimitLabel.Font = Enum.Font.Fantasy
LimitLabel.TextSize = 12
LimitLabel.Text = "🚀 Humos por segundo: " .. maxPerSecond
LimitLabel.Parent = Frame

-- Slider dinámico
local SliderBack = Instance.new("Frame")
SliderBack.Size = UDim2.new(1,-40,0,12)
SliderBack.Position = UDim2.new(0,20,0,225)
SliderBack.BackgroundColor3 = Color3.fromRGB(60,0,0)
SliderBack.BorderSizePixel = 0
SliderBack.Parent = Frame
Instance.new("UICorner", SliderBack).CornerRadius = UDim.new(0,6)

local SliderFill = Instance.new("Frame")
local relInitial = (maxPerSecond - 100) / 49900
SliderFill.Size = UDim2.new(math.clamp(relInitial,0,1),0,1,0)
SliderFill.Parent = SliderBack
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0,6)

local gradient = Instance.new("UIGradient", SliderFill)
gradient.Rotation = 0
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
})

-- Función slider (ACTUALIZA EL LÍMITE)
local sliderDragging = false
local function updateSlider(input)
    local relX = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X,0,1)
    SliderFill.Size = UDim2.new(relX,0,1,0)
    maxPerSecond = math.floor(100 + relX*49900)
    LimitLabel.Text = "🚀 Humos por segundo: "..maxPerSecond
end

SliderBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        updateSlider(input)
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                sliderDragging = false
                conn:Disconnect()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- 🔥 NUEVO SISTEMA DE AUTOFLASH: PRECISO, ESTABLE Y VELOZ
ToggleButton.MouseButton1Click:Connect(function()
    if not targetPlayer then
        StatusLabel.Text = "⚠️ Seleccioná un jugador válido."
        return
    end

    getgenv().autoFlash = not getgenv().autoFlash
    ToggleButton.BackgroundColor3 = getgenv().autoFlash and Color3.fromRGB(255,50,50) or Color3.fromRGB(180,0,0)
    ToggleButton.Text = getgenv().autoFlash and "⛔ Detener AutoFlash" or "▶ Iniciar AutoFlash"

    if getgenv().autoFlash then
        StatusLabel.Text = "💥 Atacando a "..targetPlayer.Name

        task.spawn(function()
            if not createFlash then
                warn("⚠️ Remote CreateFlash no encontrado")
                StatusLabel.Text = "⚠️ Remote CreateFlash no encontrado"
                getgenv().autoFlash = false
                return
            end

            -- Sistema preciso de control
            local accumulated = 0
            local lastTime = tick()

            while getgenv().autoFlash do
                local now = tick()
                local dt = now - lastTime
                lastTime = now

                accumulated += dt * maxPerSecond  -- cuántos flashes se deben enviar

                if accumulated >= 1 then
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = targetPlayer.Character.HumanoidRootPart.Position
                        local toSend = math.floor(accumulated)
                        accumulated -= toSend

                        -- Enviar EXACTAMENTE la cantidad calculada
                        for i = 1, toSend do
                            pcall(function()
                                createFlash:FireServer(pos, 21)
                            end)
                        end
                    end
                end

                task.wait()
            end
        end)
    else
        StatusLabel.Text = "✅ Detenido (último: "..(targetPlayer and targetPlayer.Name or "N/A")..")"
    end
end)

---
-- 🪄 CREACIÓN DE LA SEGUNDA PESTAÑA (ExtraTab)
---

ExtraTab = Instance.new("Frame")
ExtraTab.Size = Frame.Size
ExtraTab.Position = Frame.Position
ExtraTab.BackgroundColor3 = Frame.BackgroundColor3
ExtraTab.BackgroundTransparency = Frame.BackgroundTransparency
ExtraTab.BorderSizePixel = 0
ExtraTab.Visible = false
ExtraTab.ZIndex = Frame.ZIndex
ExtraTab.Parent = ScreenGui
ExtraTab.BackgroundTransparency = 0.1 

-- 🌑 Fondo infernal oscuro (Duplicar de Frame)
local BGImage2 = Instance.new("ImageLabel")
BGImage2.Size = UDim2.new(1,0,1,0)
BGImage2.Position = UDim2.new(0,0,0,0)
BGImage2.BackgroundTransparency = 1
BGImage2.Image = "rbxassetid://83339138877786" -- 🔥 textura infernal
BGImage2.ImageTransparency = 0.7
BGImage2.ZIndex = 0
BGImage2.ClipsDescendants = true
BGImage2.Parent = ExtraTab

-- 🌈 Gradiente animado sobre el ExtraTab (Duplicar de Frame)
local AnimatedGradient2 = Instance.new("UIGradient")
AnimatedGradient2.Rotation = 0
AnimatedGradient2.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 0, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 200))
}
AnimatedGradient2.Parent = ExtraTab

-- 🔲 Borde y esquinas (Duplicar de Frame)
local UIStroke2 = Instance.new("UIStroke", ExtraTab)
UIStroke2.Thickness = 2
UIStroke2.Color = Color3.fromRGB(255,50,50)
UIStroke2.Transparency = 0.2
UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Instance.new("UICorner", ExtraTab).CornerRadius = UDim.new(0,12)

-- 🏷️ Título siniestro (Duplicar para el nuevo Frame)
local Title2 = Instance.new("TextLabel")
Title2.Size = UDim2.new(1,-60,0,40)
Title2.Position = UDim2.new(0,45,0,0)
Title2.BackgroundTransparency = 1
Title2.Text = "⸸ Extras ⸸" -- Nuevo título para la segunda pestaña
Title2.TextColor3 = Color3.fromRGB(255, 255, 255)
Title2.Font = Enum.Font.Fantasy
Title2.TextSize = 22
Title2.TextXAlignment = Enum.TextXAlignment.Left
Title2.ZIndex = 3
Title2.Parent = ExtraTab

-- 👁️ Contenido de la pestaña 2 - Scrollable Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -40, 0, 210)
ScrollFrame.Position = UDim2.new(0, 20, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = ExtraTab

local UILayout = Instance.new("UIListLayout")
UILayout.Padding = UDim.new(0, 10)
UILayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UILayout.VerticalAlignment = Enum.VerticalAlignment.Top
UILayout.FillDirection = Enum.FillDirection.Vertical
UILayout.SortOrder = Enum.SortOrder.LayoutOrder
UILayout.Parent = ScrollFrame

---
-- 🧪 FUNCIONES DE EXTRAS
---

-- Función para crear un botón de toggle
local function createToggle(name, initialValue, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 35) 
    button.BackgroundColor3 = initialValue and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 0, 0)
    button.Text = (initialValue and "🟢 " or "🔴 ") .. name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Fantasy
    button.TextSize = 15
    button.ZIndex = 2
    button.Parent = ScrollFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    
    local enabled = initialValue

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.BackgroundColor3 = enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 0, 0)
        button.Text = (enabled and "🟢 " or "🔴 ") .. name
        callback(enabled)
    end)
    return button
end

-- Función para crear un slider
local function createSlider(name, minVal, maxVal, initialVal, updateFunc)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, -20, 0, 45)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = ScrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(255,200,200)
    label.Font = Enum.Font.Fantasy
    label.TextSize = 14
    label.Text = name .. ": " .. initialVal
    label.Parent = sliderContainer

    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1,0,0,12)
    sliderBack.Position = UDim2.new(0,0,0,25)
    sliderBack.BackgroundColor3 = Color3.fromRGB(60,0,0)
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = sliderContainer
    Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(0,6)

    local relInitial = (initialVal - minVal) / (maxVal - minVal)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(math.clamp(relInitial,0,1),0,1,0)
    sliderFill.Parent = sliderBack
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0,6)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    
    local dragging = false
    local currentValue = initialVal

    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X,0,1)
        sliderFill.Size = UDim2.new(relX,0,1,0)
        
        currentValue = minVal + relX * (maxVal - minVal)
        currentValue = math.floor(currentValue * 10) / 10 -- Redondeo
        
        label.Text = name .. ": " .. currentValue
        updateFunc(currentValue)
    end

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
end

-- 1. Anti-AFK
local antiAFKButton = createToggle("Anti-AFK (Bypass Inactividad)", afkEnabled, function(enabled)
    afkEnabled = enabled
    if afkEnabled then
        task.spawn(function()
            while afkEnabled and plr do
                plr.Idled:Fire()
                task.wait(10)
            end
        end)
    end
end)

-- 2. Toggle Blur
local blurToggle = createToggle("Toggle Blur (UI)", blur.Enabled, function(enabled)
    blur.Enabled = enabled
end)

-- 3. No Clip
local noClipButton = createToggle("No Clip (Atravesar Muros)", noClipEnabled, function(enabled)
    noClipEnabled = enabled
    local char = plr.Character or plr.CharacterAdded:Wait()
    
    local function setCanCollide(c, value)
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = value
            end
        end
    end

    if noClipEnabled then
        setCanCollide(char, false)
        noClipConn = plr.CharacterAdded:Connect(function(newChar)
            newChar:WaitForChild("HumanoidRootPart")
            setCanCollide(newChar, false)
        end)
    else
        if noClipConn then
            noClipConn:Disconnect()
            noClipConn = nil
        end
        -- Solo restaurar las colisiones de las partes principales
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") and (part.Name == "HumanoidRootPart" or part.Name == "Torso") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- 4. FOV Changer (Campo de visión)
local defaultFOV = Camera.FieldOfView
createSlider("FOV (Campo de Visión)", 20, 120, defaultFOV, function(value)
    Camera.FieldOfView = value
end)

-- 5. Custom Skybox / Atmosphere (Skybox con IDs personalizados para cada cara)
local originalSky = Lighting:FindFirstChildOfClass("Sky") 
local customSky = nil
local customAtmosphere = nil
local colorCorrection = nil 

local function setCustomSkybox(enabled)
    
    -- === ⚠️ REEMPLAZAR ESTOS IDS ⚠️ ===
    -- Usa un ID de una textura completamente negra para los lados
    -- Y un ID de una textura de estrellas rojas para el 'SkyboxUp' si lo deseas.
    -- Si solo quieres un cielo negro completo, usa el mismo ID negro para todos.
    local skyboxUpID    = "rbxassetid://77916824609158"     -- Arriba (donde irían las estrellas rojas)
    local skyboxDownID  = "rbxassetid://97839464618263"      -- Abajo
    local skyboxFrontID = "rbxassetid://119754691238397"     -- Frente
    local skyboxBackID  = "rbxassetid://97839464618263"      -- Atrás
    local skyboxLeftID  = "rbxassetid://97839464618263"  -- Izquierda
    local skyboxRightID = "rbxassetid://97839464618263"    -- Derecha
    -- ==================================
    
    if enabled then
        -- Eliminar Skybox original si existe
        if originalSky and originalSky.Parent == Lighting then
            originalSky.Parent = nil
        end
        
        -- Crear un Skybox personalizado con los IDs
        customSky = Instance.new("Sky")
        customSky.SkyboxUp = skyboxUpID 
        customSky.SkyboxDn = skyboxDownID 
        customSky.SkyboxFt = skyboxFrontID 
        customSky.SkyboxBk = skyboxBackID 
        customSky.SkyboxLf = skyboxLeftID 
        customSky.SkyboxRt = skyboxRightID 
        customSky.CelestialBodiesShown = false 
        customSky.StarCount = 0 
        customSky.Parent = Lighting

        -- Crear una atmósfera oscura con un tinte rojizo para ambientación
        customAtmosphere = Instance.new("Atmosphere")
        customAtmosphere.Density = 0.6 
        customAtmosphere.Offset = Vector3.new(0, 0, 0)
        customAtmosphere.Color = Color3.fromRGB(30, 0, 0) -- Color base muy oscuro
        customAtmosphere.Decay = Color3.fromRGB(150, 0, 0) -- Degradado rojizo
        customAtmosphere.Glare = 0.5 
        customAtmosphere.Haze = 0.3 
        customAtmosphere.OutdoorAmbient = Color3.fromRGB(10,0,0) 
        customAtmosphere.Parent = Lighting

        -- Añadir ColorCorrection para un filtro global rojo (efecto de tinte sombrío)
        colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.TintColor = Color3.fromRGB(255, 100, 100) 
        colorCorrection.Saturation = -0.3 
        colorCorrection.Contrast = 0.1 
        colorCorrection.Parent = Lighting

    else
        -- Restaurar Skybox original
        if originalSky and not originalSky.Parent then
            originalSky.Parent = Lighting
        end
        -- Eliminar los efectos personalizados
        if customSky then
            customSky:Destroy()
            customSky = nil
        end
        if customAtmosphere then
            customAtmosphere:Destroy()
            customAtmosphere = nil
        end
        if colorCorrection then
            colorCorrection:Destroy()
            colorCorrection = nil
        end
    end
end

local skyboxToggle = createToggle("Atmósfera Infernal (Skybox Custom)", customSkyboxEnabled, function(enabled)
    customSkyboxEnabled = enabled
    setCustomSkybox(enabled)
end)

-- 6. ESP Básico (Solo Trazador) - Highlight para enemigos
local function clearESPHighlights()
    for _, highlight in pairs(espHighlights) do
        pcall(function() highlight:Destroy() end)
    end
    espHighlights = {}
    for _, conn in pairs(espConnections) do
        pcall(function() conn:Disconnect() end)
    end
    if espUpdateConn then
        espUpdateConn:Disconnect()
        espUpdateConn = nil
    end
end

local function setupESPHighlight(player)
    if player == plr then return end 
    if not player.Character then return end

    local char = player.Character
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight_" .. player.Name
    highlight.FillColor = Color3.fromRGB(255, 0, 0) 
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineTransparency = 0.2
    highlight.Adornee = char
    highlight.Parent = char
    espHighlights[player.UserId] = highlight

    local charAddedConn = player.CharacterAdded:Connect(function(newChar)
        if espEnabled and espHighlights[player.UserId] then
            newChar:WaitForChild("HumanoidRootPart", 10) 
            if newChar:FindFirstChild("HumanoidRootPart") then
                espHighlights[player.UserId].Adornee = newChar
                espHighlights[player.UserId].Parent = newChar
            end
        end
    end)
    espConnections[player.UserId .. "_charAdded"] = charAddedConn

    local playerRemovingConn = Players.PlayerRemoving:Connect(function(removedPlayer)
        if removedPlayer.UserId == player.UserId then
            if espHighlights[removedPlayer.UserId] then
                pcall(function() espHighlights[removedPlayer.UserId]:Destroy() end)
                espHighlights[removedPlayer.UserId] = nil
            end
            if espConnections[removedPlayer.UserId .. "_charAdded"] then
                pcall(function() espConnections[removedPlayer.UserId .. "_charAdded"]:Disconnect() end)
                espConnections[removedPlayer.UserId .. "_charAdded"] = nil
            end
        end
    end)
    espConnections[player.UserId .. "_playerRemoving"] = playerRemovingConn
end

local function toggleESP(enabled)
    espEnabled = enabled
    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            setupESPHighlight(player)
        end
        espConnections["PlayerAdded"] = Players.PlayerAdded:Connect(function(player)
            setupESPHighlight(player)
        end)
    else
        clearESPHighlights()
        if espConnections["PlayerAdded"] then
            espConnections["PlayerAdded"]:Disconnect()
            espConnections["PlayerAdded"] = nil
        end
    end
end

local espToggle = createToggle("ESP (Resaltar Enemigos)", espEnabled, toggleESP)

-- 7. Cargar Infinite Yield (NUEVO BOTÓN)
local function loadInfiniteYield(enabled)
    if enabled and not infiniteYieldLoaded then
        infiniteYieldLoaded = true
        task.spawn(function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            end)
        end)
        StarterGui:SetCore("SendNotification", {
            Title = "SixSixClan";
            Text = "Infinite Yield cargado! (Verifica la consola para comandos)";
            Icon = "rbxassetid://131574561771512";
            Duration = 3;
        })
    end
end

local iyToggle = createToggle("Cargar Infinite Yield (F8)", infiniteYieldLoaded, loadInfiniteYield)

-- Ajustar el tamaño del Canvas después de agregar los elementos
-- Se aumenta el tamaño para acomodar el nuevo botón
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UILayout.AbsoluteContentSize.Y + 50) 

---
-- 🛠️ DEFINICIÓN DE BOTONES DE NAVEGACIÓN Y LÓGICA FINAL
---

-- 🔙 Botón “Volver” (Pestaña Secundaria)
local BackButton = Instance.new("TextButton")
BackButton.Size = UDim2.new(0, 30, 0, 30)
BackButton.Position = UDim2.new(1, -110, 0, 5) 
BackButton.BackgroundColor3 = Color3.fromRGB(80,0,0)
BackButton.Text = "⬅"
BackButton.TextColor3 = Color3.fromRGB(255,200,200)
BackButton.Font = Enum.Font.GothamBold
BackButton.TextSize = 18
BackButton.Parent = ExtraTab
BackButton.Visible = false
Instance.new("UICorner", BackButton).CornerRadius = UDim.new(0,8)

-- 🔁 Botón “Siguiente” (Pestaña Principal)
local NextButton = Instance.new("TextButton")
NextButton.Size = UDim2.new(0, 30, 0, 30)
NextButton.Position = UDim2.new(1, -110, 0, 5) 
NextButton.BackgroundColor3 = Color3.fromRGB(80,0,0)
NextButton.Text = "➡"
NextButton.TextColor3 = Color3.fromRGB(255,200,200)
NextButton.Font = Enum.Font.GothamBold
NextButton.TextSize = 18
NextButton.Parent = Frame
Instance.new("UICorner", NextButton).CornerRadius = UDim.new(0,8)


-- 🌙 Transición entre pestañas
local switching = false
local function switchTabs(showExtra)
	if switching then return end
	switching = true

	local targetFrame = showExtra and ExtraTab or Frame
	local hideFrame = showExtra and Frame or ExtraTab

	-- Si el Frame principal está minimizado, restaurar a tamaño completo antes de la transición
	if minimized then 
		TweenService:Create(Frame, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,300,0,270), Position=UDim2.new(0.5,-150,0.5,-135)}):Play()
		minimized = false
		MinButton.Text = "−"
		blur.Enabled = true
		task.wait(0.3) 
	end
	
	-- 1. Desvanecer Frame que se oculta
	local fadeOut = TweenService:Create(hideFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
	fadeOut:Play()
	task.wait(0.3)
	
	-- 2. Cambiar visibilidad de Frames y Botones de NAVEGACIÓN
	Frame.Visible = not showExtra
	ExtraTab.Visible = showExtra

    -- Alternar la visibilidad de los botones de navegación
    NextButton.Visible = not showExtra 
    BackButton.Visible = showExtra
    
	-- 3. Mostrar Frame con FadeIn
	local fadeIn = TweenService:Create(targetFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1})
	fadeIn:Play()
	task.wait(0.3)
	
	switching = false
end


-- 🔽 Botón minimizar (MANEJA LA PESTAÑA VISIBLE)
MinButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    local elements = {TextBox, StatusLabel, ToggleButton, LimitLabel, SliderBack}
    local activeFrame = Frame.Visible and Frame or ExtraTab

    if minimized then
        MinButton.Text = "+"
        blur.Enabled = false
        
        -- Ocultar elementos de contenido y navegación, manteniendo solo el título y los botones de control
        if Frame.Visible then
            for _, obj in ipairs(elements) do if obj then obj.Visible = false end end
            NextButton.Visible = false 
        end
        if ExtraTab.Visible then
            ScrollFrame.Visible = false -- Ocultar el contenido de la pestaña de extras
            BackButton.Visible = false
        end

        -- Minimizar el Frame activo
        TweenService:Create(activeFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,300,0,45), Position=UDim2.new(0.5,-150,0.5,50)}):Play()
    else
        MinButton.Text = "−"
        blur.Enabled = true
        
        -- Restaurar el Frame activo
        TweenService:Create(activeFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,300,0,270), Position=UDim2.new(0.5,-150,0.5,-135)}):Play()
        task.delay(0.3,function()
            if Frame.Visible then -- Si volvemos a la pestaña principal, mostrar elementos y botón Next
                for _, obj in ipairs(elements) do if obj then obj.Visible = true end end
                NextButton.Visible = true
            end
            if ExtraTab.Visible then -- Si volvemos a ExtraTab, mostrar contenido y BackButton
                ScrollFrame.Visible = true
                BackButton.Visible = true
            end
        end)
    end
end)


-- 🧭 CONEXIONES FINALES DE LOS BOTONES DE NAVEGACIÓN
NextButton.MouseButton1Click:Connect(function()
	switchTabs(true)
end)
BackButton.MouseButton1Click:Connect(function()
	switchTabs(false)
end)


-- ✨ Animación inicial al abrir GUI
Frame.BackgroundTransparency = 1
Frame.Position = UDim2.new(0.5,-150,0.5,-100)
TweenService:Create(Frame,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{BackgroundTransparency=0.1,Position=UDim2.new(0.5,-150,0.5,-135)}):Play()

-- 🔔 Notificación al ejecutar el script 
StarterGui:SetCore("SendNotification", {
    Title = "SixSixClan";
    Text = "Kickeador activado!";
    Icon = "rbxassetid://117520043554283"; -- Usa el ID de tu logo
    Duration = 5;
})
