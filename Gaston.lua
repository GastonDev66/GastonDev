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

-- 🌫️ Blur de fondo
local blur = Instance.new("BlurEffect")
blur.Size = 12
blur.Name = "UIBlur"
blur.Parent = Lighting

-- 🖥️ GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = "SixsixUI"
ScreenGui.Parent = plr:WaitForChild("PlayerGui")

-- 🎛️ Marco principal
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 250)
Frame.Position = UDim2.new(0.5, -150, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = false
Frame.Parent = ScreenGui

-- 🌈 Gradiente rojo/negro
local gradient = Instance.new("UIGradient", Frame)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 0))
}
gradient.Rotation = 90

-- 🔥 Glow en bordes
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 50, 50)
UIStroke.Transparency = 0.2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- 🎨 Bordes redondeados
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

-- 🏷️ Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🩸 SixSixClan🩸"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- 🌟 Brillo pulsante en el título
spawn(function()
	local alpha = 0
	local increasing = true
	while Title.Parent do
		if increasing then
			alpha = alpha + 0.02
			if alpha >= 1 then increasing = false end
		else
			alpha = alpha - 0.02
			if alpha <= 0.5 then increasing = true end
		end
		Title.TextColor3 = Color3.fromRGB(255, math.floor(50 + 50*alpha), math.floor(50 + 50*alpha))
		task.wait(0.03)
	end
end)

-- 🌌 Partículas de símbolos detrás del título
local symbols = {"⛧", "⸸", "☠"}
local particleFolder = Instance.new("Folder")
particleFolder.Name = "Particles"
particleFolder.Parent = Frame

spawn(function()
	while Frame.Parent do
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

		-- Movimiento descendente
		local tween = TweenService:Create(particle, TweenInfo.new(math.random(2,4), Enum.EasingStyle.Quad), {Position=UDim2.new(particle.Position.X.Scale,0,1,0), TextTransparency=1})
		tween:Play()
		tween.Completed:Connect(function()
			particle:Destroy()
		end)

		task.wait(0.2)
	end
end)

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

-- ✏️ Caja de texto
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -40, 0, 40)
TextBox.Position = UDim2.new(0, 20, 0, 60)
TextBox.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
TextBox.TextColor3 = Color3.fromRGB(255, 200, 200)
TextBox.PlaceholderText = "Nombre exacto del jugador..."
TextBox.PlaceholderColor3 = Color3.fromRGB(255, 120, 120)
TextBox.Font = Enum.Font.GothamSemibold
TextBox.TextSize = 14
TextBox.ClearTextOnFocus = false
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
ToggleButton.Position = UDim2.new(0, 30, 1, -65)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ToggleButton.Text = "▶ Iniciar / Detener"
ToggleButton.TextColor3 = Color3.fromRGB(255, 200, 200)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.Parent = Frame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

-- 🔥 Glow animado en GUI
local function animateGlow(stroke)
	spawn(function()
		local alpha = 0
		local increasing = true
		while true do
			if increasing then
				alpha = alpha + 0.02
				if alpha >= 0.5 then increasing = false end
			else
				alpha = alpha - 0.02
				if alpha <= 0.2 then increasing = true end
			end
			stroke.Transparency = 1 - alpha
			task.wait(0.03)
		end
	end)
end
animateGlow(UIStroke)

-- ✨ Glow dinámico en botones
local function addButtonGlow(button)
	local stroke = Instance.new("UIStroke")
	stroke.Parent = button
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(255,50,50)
	stroke.Transparency = 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local increasing = true
	spawn(function()
		while button.Parent do
			if increasing then
				stroke.Transparency = stroke.Transparency - 0.01
				if stroke.Transparency <= 0.2 then increasing = false end
			else
				stroke.Transparency = stroke.Transparency + 0.01
				if stroke.Transparency >= 0.5 then increasing = true end
			end
			task.wait(0.02)
		end
	end)

	-- Hover y touch
	button.MouseEnter:Connect(function()
		stroke.Color = Color3.fromRGB(255,100,100)
		stroke.Thickness = 3
	end)
	button.MouseLeave:Connect(function()
		stroke.Color = Color3.fromRGB(255,50,50)
		stroke.Thickness = 2
	end)
	button.TouchTap:Connect(function()
		stroke.Color = Color3.fromRGB(255,100,100)
		stroke.Thickness = 3
		task.delay(0.3,function()
			stroke.Color = Color3.fromRGB(255,50,50)
			stroke.Thickness = 2
		end)
	end)
end

addButtonGlow(ToggleButton)
addButtonGlow(MinButton)

-- ✋ Arrastre libre (PC + Móvil)
do
	local dragging = false
	local dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	Frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end

-- 🔎 Buscar jugador
TextBox.FocusLost:Connect(function()
	local name = TextBox.Text
	if name == "" then
		StatusLabel.Text = "⚠️ Escribí un nombre."
		targetPlayer = nil
		return
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if string.lower(player.Name) == string.lower(name) or string.find(string.lower(player.DisplayName), string.lower(name)) then
			targetPlayer = player
			StatusLabel.Text = "✅ Objetivo: " .. player.Name
			return
		end
	end
	StatusLabel.Text = "❌ Jugador no encontrado."
	targetPlayer = nil
end)

-- 🔁 Iniciar / Detener
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
		spawn(function()
			while getgenv().autoFlash do
				if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
					ReplicatedStorage.RemoteTriggers.CreateFlash:FireServer(targetPlayer.Character.HumanoidRootPart.Position,21)
				end
				task.wait()
			end
		end)
	else
		StatusLabel.Text = "✅ Detenido (último: "..targetPlayer.Name..")"
	end
end)

-- 🔘 Minimizar / restaurar
MinButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	local elements = {TextBox, StatusLabel, ToggleButton}
	if minimized then
		MinButton.Text = "+"
		blur.Enabled = false
		for _, obj in ipairs(elements) do obj.Visible = false end
		TweenService:Create(Frame,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,300,0,45),Position=UDim2.new(0.5,-150,0.5,50),Rotation=10}):Play()
	else
		MinButton.Text = "−"
		blur.Enabled = true
		TweenService:Create(Frame,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,300,0,250),Position=UDim2.new(0.5,-150,0.5,-125),Rotation=0}):Play()
		task.delay(0.3,function()
			for _, obj in ipairs(elements) do obj.Visible = true end
		end)
	end
end)

-- ✨ Animación de entrada
Frame.BackgroundTransparency = 1
Frame.Position = UDim2.new(0.5,-150,0.5,-100)
TweenService:Create(Frame,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0.1,Position=UDim2.new(0.5,-150,0.5,-125)}):Play()
