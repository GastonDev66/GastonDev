-- 🧩 Servicios
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

-- 🌐 Variables globales
getgenv().autoFlash = false
local targetPlayer = nil
local minimized = false
local currentHighlight = nil
local highlightConn = nil

-- 🔧 Límite dinámico (valor inicial)
local maxPerSecond = 1000
local sentThisSecond = 0

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
ScreenGui.Parent = plr:WaitForChild("PlayerGui")

-- 🎛️ Marco principal
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 270)
Frame.Position = UDim2.new(0.5, -150, 0.5, -135)
Frame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Parent = ScreenGui

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 0))
}
gradient.Rotation = 90
gradient.Parent = Frame

local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 50, 50)
UIStroke.Transparency = 0.2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

-- 🏷️ Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👿SixSixClan😈"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- 🔒 Botón de anclado
local AnchorButton = Instance.new("TextButton")
AnchorButton.Size = UDim2.new(0, 30, 0, 30)
AnchorButton.Position = UDim2.new(1, -75, 0, 5)
AnchorButton.BackgroundTransparency = 1
AnchorButton.Text = "🔓"
AnchorButton.TextSize = 18
AnchorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AnchorButton.Font = Enum.Font.GothamBold
AnchorButton.Parent = Frame

-- 🔽 Botón minimizar
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -40, 0, 5)
MinButton.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
MinButton.Text = "−"
MinButton.TextColor3 = Color3.fromRGB(255, 50, 50)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 18
MinButton.Parent = Frame
Instance.new("UICorner", MinButton).CornerRadius = UDim.new(0, 8)

-- ✋ Arrastre libre + anclar interfaz
do
    local dragging = false
    local dragStart, startPos
    local anchored = false

    local function update(input)
        if anchored then return end
        local delta = input.Position - dragStart
        local newX = math.clamp(startPos.X.Offset + delta.X, -Frame.AbsoluteSize.X + 50, workspace.CurrentCamera.ViewportSize.X - 50)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, -Frame.AbsoluteSize.Y + 50, workspace.CurrentCamera.ViewportSize.Y - 50)
        Frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
    end

    Frame.InputBegan:Connect(function(input)
        if anchored then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    AnchorButton.MouseButton1Click:Connect(function()
        anchored = not anchored
        AnchorButton.Text = anchored and "🔒" or "🔓"
    end)
end

-- 🔄 Efecto color en el título
task.spawn(function()
    local alpha, increasing = 0, true
    while Title and Title.Parent do
        if increasing then alpha = alpha + 0.02 else alpha = alpha - 0.02 end
        if alpha >= 1 then increasing = false elseif alpha <= 0.5 then increasing = true end
        Title.TextColor3 = Color3.fromRGB(255, math.floor(50 + 50 * alpha), math.floor(50 + 50 * alpha))
        task.wait(0.03)
    end
end)

-- 🌌 Partículas decorativas
local symbols = {"🩸", "🔪", "☠️"}
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
        particle.ZIndex = 0
        particle.Parent = particleFolder
        local tween = TweenService:Create(particle, TweenInfo.new(math.random(2,4), Enum.EasingStyle.Quad), {Position=UDim2.new(particle.Position.X.Scale,0,1,0), TextTransparency=1})
        tween:Play()
        tween.Completed:Connect(function() pcall(function() particle:Destroy() end) end)
        task.wait(0.2)
    end
end)

-- ✏️ Caja de texto
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -40, 0, 40)
TextBox.Position = UDim2.new(0, 20, 0, 60)
TextBox.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
TextBox.TextColor3 = Color3.fromRGB(255, 200, 200)
TextBox.PlaceholderText = ""
TextBox.PlaceholderColor3 = Color3.fromRGB(255, 120, 120)
TextBox.Font = Enum.Font.GothamSemibold
TextBox.TextSize = 14
TextBox.ClearTextOnFocus = true
TextBox.Parent = Frame
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 8)

-- 🧾 Estado
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 0, 30)
StatusLabel.Position = UDim2.new(0, 20, 0, 110)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Esperando selección..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = Frame

-- ⚙️ Botón principal
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -60, 0, 45)
ToggleButton.Position = UDim2.new(0, 30, 0, 150)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ToggleButton.Text = "▶ Iniciar / Detener"
ToggleButton.TextColor3 = Color3.fromRGB(255, 200, 200)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.Parent = Frame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

-- ✨ Glow dinámico
local function addButtonGlow(button)
    local stroke = Instance.new("UIStroke")
    stroke.Parent = button
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255,50,50)
    stroke.Transparency = 0.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    task.spawn(function()
        local increasing = true
        while button and button.Parent do
            if increasing then stroke.Transparency = stroke.Transparency - 0.01 else stroke.Transparency = stroke.Transparency + 0.01 end
            if stroke.Transparency <= 0.2 then increasing = false elseif stroke.Transparency >= 0.5 then increasing = true end
            task.wait(0.02)
        end
    end)
end

addButtonGlow(ToggleButton)
addButtonGlow(MinButton)

-- 🔦 Highlight y búsqueda de objetivo
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
        StatusLabel.Text = "⚠️ Escribí un nombre."
        targetPlayer = nil
        removeHighlight()
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name) == string.lower(name) or (player.DisplayName and string.find(string.lower(player.DisplayName), string.lower(name))) then
            targetPlayer = player
            StatusLabel.Text = "✅ Objetivo: " .. player.Name
            removeHighlight()
            if player.Character then
                currentHighlight = Instance.new("Highlight")
                currentHighlight.Name = "TargetHighlight"
                currentHighlight.FillColor = Color3.fromRGB(255, 0, 0)
                currentHighlight.FillTransparency = 0.5
                currentHighlight.OutlineColor = Color3.fromRGB(255, 50, 50)
                currentHighlight.OutlineTransparency = 0
                currentHighlight.Adornee = player.Character
                currentHighlight.Parent = player.Character

                -- Parpadeo del highlight
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

                -- Reanclar al respawnear
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

-- ⚙️ Sistema de humo super rápido (remote)
local remoteTriggers = ReplicatedStorage:FindFirstChild("RemoteTriggers")
local createFlash = remoteTriggers and remoteTriggers:FindFirstChild("CreateFlash")

-- 🧮 Control dinámico de límite (UI)
local LimitLabel = Instance.new("TextLabel")
LimitLabel.Size = UDim2.new(1, -40, 0, 20)
LimitLabel.Position = UDim2.new(0, 20, 0, 200)
LimitLabel.BackgroundTransparency = 1
LimitLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
LimitLabel.Font = Enum.Font.Gotham
LimitLabel.TextSize = 12
LimitLabel.Text = "🚀 Límite flashes/s: " .. maxPerSecond
LimitLabel.Parent = Frame

local SliderBack = Instance.new("Frame")
SliderBack.Size = UDim2.new(1, -40, 0, 12)
SliderBack.Position = UDim2.new(0, 20, 0, 225)
SliderBack.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
SliderBack.BorderSizePixel = 0
SliderBack.Parent = Frame
Instance.new("UICorner", SliderBack).CornerRadius = UDim.new(0, 6)

local SliderFill = Instance.new("Frame")
local relInitial = (maxPerSecond - 100) / 1900
SliderFill.Size = UDim2.new(math.clamp(relInitial, 0, 1), 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
SliderFill.Parent = SliderBack
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 6)

-- 📱 Compatible con celular (Touch) y PC (Mouse)
local sliderDragging = false

local function updateSlider(input)
    local relX = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(relX, 0, 1, 0)
    maxPerSecond = math.floor(100 + relX * 49900) -- rango 100–50000
    LimitLabel.Text = "🚀 Límite flashes/s: " .. maxPerSecond
end

-- Función universal: detecta tanto mouse como toque
local function beginDrag(input)
    sliderDragging = true
    updateSlider(input)

    -- si el usuario suelta el dedo o deja de arrastrar
    local conn
    conn = input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            sliderDragging = false
            conn:Disconnect()
        end
    end)
end

SliderBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        beginDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- 🧭 Control del slider
local sliderDragging = false
SliderBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        -- también actualizar inmediatamente en click
        local relX = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(relX, 0, 1, 0)
        maxPerSecond = math.floor(100 + relX * 49900) -- rango 100–50000 flashes/s
        LimitLabel.Text = "🚀 Límite flashes/s: " .. maxPerSecond
    end
end)
SliderBack.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(relX, 0, 1, 0)
        maxPerSecond = math.floor(100 + relX * 49900)
        LimitLabel.Text = "🚀 Límite flashes/s: " .. maxPerSecond
    end
end)

-- 📊 Contador de flashes por segundo
local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(1, -40, 0, 20)
Counter.Position = UDim2.new(0, 20, 0, 240)
Counter.BackgroundTransparency = 1
Counter.TextColor3 = Color3.fromRGB(255, 255, 255)
Counter.Font = Enum.Font.Gotham
Counter.TextSize = 12
Counter.TextXAlignment = Enum.TextXAlignment.Left
Counter.Text = "📈 Flashes/s: 0"
Counter.Parent = Frame

-- Actualización del contador
task.spawn(function()
    while Frame and Frame.Parent do
        if getgenv().autoFlash then
            Counter.Text = "📈 Flashes/s: " .. sentThisSecond
        else
            Counter.Text = "📈 Flashes/s: 0"
        end
        task.wait(0.5)
    end
end)

-- ⚙️ Botón iniciar/detener
ToggleButton.MouseButton1Click:Connect(function()
    if not targetPlayer then
        StatusLabel.Text = "⚠️ Seleccioná un jugador válido."
        return
    end
    getgenv().autoFlash = not getgenv().autoFlash
    ToggleButton.BackgroundColor3 = getgenv().autoFlash and Color3.fromRGB(255,50,50) or Color3.fromRGB(180,0,0)
    ToggleButton.Text = getgenv().autoFlash and "⛔ Detener" or "▶ Iniciar"
    if getgenv().autoFlash then
        StatusLabel.Text = "💥 Atacando a "..targetPlayer.Name
        task.spawn(function()
            if not createFlash then
                warn("⚠️ Remote CreateFlash no encontrado")
                StatusLabel.Text = "⚠️ Remote CreateFlash no encontrado"
                getgenv().autoFlash = false
                return
            end
            local acc, interval, perInterval = 0, 0.0005, 50
            local lastSecond = tick()
            sentThisSecond = 0
            while getgenv().autoFlash do
                local dt = RunService.Heartbeat:Wait()
                acc = acc + dt
                if tick() - lastSecond >= 1 then
                    sentThisSecond = 0
                    lastSecond = tick()
                end
                while acc >= interval and sentThisSecond < maxPerSecond and getgenv().autoFlash do
                    acc = acc - interval
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = targetPlayer.Character.HumanoidRootPart.Position
                        for i = 1, perInterval do
                            -- usar pcall para evitar errores que corten el bucle
                            pcall(function()
                                createFlash:FireServer(pos, 21)
                            end)
                            sentThisSecond = sentThisSecond + 1
                            if sentThisSecond >= maxPerSecond then break end
                        end
                    else
                        -- si el objetivo ya no tiene character, esperar y continuar
                        task.wait(0.05)
                        break
                    end
                end
            end
        end)
    else
        StatusLabel.Text = "✅ Detenido (último: "..(targetPlayer and targetPlayer.Name or "N/A")..")"
    end
end)

-- 🔘 Minimizar
MinButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    local elements = {TextBox, StatusLabel, ToggleButton, Counter, LimitLabel, SliderBack}

    if minimized then
        MinButton.Text = "+"
        blur.Enabled = false
        for _, obj in ipairs(elements) do if obj then obj.Visible = false end end
        TweenService:Create(
            Frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 300, 0, 45), Position = UDim2.new(0.5, -150, 0.5, 50), Rotation = 0}
        ):Play()
    else
        MinButton.Text = "−"
        blur.Enabled = true
        TweenService:Create(
            Frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 300, 0, 270), Position = UDim2.new(0.5, -150, 0.5, -135), Rotation = 0}
        ):Play()
        task.delay(0.3, function()
            for _, obj in ipairs(elements) do if obj then obj.Visible = true end end
        end)
    end
end)

-- ✨ Animación inicial
Frame.BackgroundTransparency = 1
Frame.Position = UDim2.new(0.5,-150,0.5,-100)
TweenService:Create(Frame,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{BackgroundTransparency=0.1,Position=UDim2.new(0.5,-150,0.5,-135)}):Play()
