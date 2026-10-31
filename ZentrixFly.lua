
--========================================
--       ZENTRIX FLY GUI V2
--       Roblox Studio - LocalScript
--========================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Speed = 50
local MinSpeed = 25
local MaxSpeed = 200
local Flying = false
local Minimized = false

local Connection
local Velocity
local Gyro
local Root
local Humanoid

-- COLORS
local Blue = Color3.fromRGB(0, 170, 255)
local Dark = Color3.fromRGB(12, 16, 27)
local Panel = Color3.fromRGB(19, 26, 42)
local White = Color3.fromRGB(235, 245, 255)

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "ZentrixFlyGUI"
GUI.ResetOnSpawn = false
GUI.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(280, 230)
Main.Position = UDim2.new(0.5, -140, 0.5, -115)
Main.BackgroundColor3 = Dark
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Blue
Stroke.Thickness = 2
Stroke.Parent = Main

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 45)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "Z E N T R I X"
Title.TextColor3 = Blue
Title.TextSize = 21
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

-- MINIMIZE
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(32, 30)
Minimize.Position = UDim2.new(1, -42, 0, 8)
Minimize.Text = "-"
Minimize.TextColor3 = White
Minimize.TextSize = 22
Minimize.BackgroundColor3 = Panel
Minimize.Parent = Main

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 7)
MC.Parent = Minimize

-- STATUS
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -30, 0, 25)
Status.Position = UDim2.fromOffset(15, 48)
Status.BackgroundTransparency = 1
Status.Text = "STATUS: NOT FLYING"
Status.TextColor3 = White
Status.TextSize = 12
Status.Font = Enum.Font.GothamMedium
Status.Parent = Main

-- FLY BUTTON
local Fly = Instance.new("TextButton")
Fly.Size = UDim2.new(1, -30, 0, 43)
Fly.Position = UDim2.fromOffset(15, 82)
Fly.BackgroundColor3 = Color3.fromRGB(25, 65, 100)
Fly.Text = "FLY : OFF"
Fly.TextColor3 = White
Fly.TextSize = 16
Fly.Font = Enum.Font.GothamBold
Fly.Parent = Main

local FC = Instance.new("UICorner")
FC.CornerRadius = UDim.new(0, 9)
FC.Parent = Fly

-- SPEED LABEL
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -30, 0, 25)
SpeedLabel.Position = UDim2.fromOffset(15, 135)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "FLY SPEED : " .. Speed
SpeedLabel.TextColor3 = Blue
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Parent = Main

-- SPEED BUTTONS
local function MakeButton(text, x)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(110, 35)
    Button.Position = UDim2.fromOffset(x, 175)
    Button.BackgroundColor3 = Panel
    Button.Text = text
    Button.TextColor3 = White
    Button.TextSize = 16
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Main

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Button

    return Button
end

local Minus = MakeButton("- SPEED", 15)
local Plus = MakeButton("+ SPEED", 155)

-- FLY SYSTEM
local function StopFlying()
    Flying = false

    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    if Velocity then
        Velocity:Destroy()
        Velocity = nil
    end

    if Gyro then
        Gyro:Destroy()
        Gyro = nil
    end

    if Humanoid then
        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    Fly.Text = "FLY : OFF"
    Fly.BackgroundColor3 = Color3.fromRGB(25, 65, 100)
    Status.Text = "STATUS: NOT FLYING"
end

local function StartFlying()
    local Character = Player.Character
    Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    Root = Character and Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not Root then
        return
    end

    Flying = true
    Humanoid.PlatformStand = true

    Velocity = Instance.new("BodyVelocity")
    Velocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    Velocity.Velocity = Vector3.zero
    Velocity.Parent = Root

    Gyro = Instance.new("BodyGyro")
    Gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    Gyro.P = 10000
    Gyro.CFrame = Root.CFrame
    Gyro.Parent = Root

    Fly.Text = "FLY : ON"
    Fly.BackgroundColor3 = Color3.fromRGB(0, 135, 190)
    Status.Text = "STATUS: FLYING"

    Connection = RunService.RenderStepped:Connect(function()
        if not Flying or not Root or not Root.Parent then
            StopFlying()
            return
        end

        local Camera = workspace.CurrentCamera
        local Direction = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            Direction += Camera.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.S) then
            Direction -= Camera.CFrame.LookVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.A) then
            Direction -= Camera.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.D) then
            Direction += Camera.CFrame.RightVector
        end

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            Direction += Vector3.yAxis
        end

        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            Direction -= Vector3.yAxis
        end

        Velocity.Velocity =
            Direction.Magnitude > 0
            and Direction.Unit * Speed
            or Vector3.zero

        Gyro.CFrame = Camera.CFrame
    end)
end

-- BUTTON EVENTS
Fly.MouseButton1Click:Connect(function()
    if Flying then
        StopFlying()
    else
        StartFlying()
    end
end)

Plus.MouseButton1Click:Connect(function()
    Speed = math.min(Speed + 25, MaxSpeed)
    SpeedLabel.Text = "FLY SPEED : " .. Speed
end)

Minus.MouseButton1Click:Connect(function()
    Speed = math.max(Speed - 25, MinSpeed)
    SpeedLabel.Text = "FLY SPEED : " .. Speed
end)

-- MINIMIZE
Minimize.MouseButton1Click:Connect(function()
    Minimized = not Minimized

    for _, Object in ipairs(Main:GetChildren()) do
        if Object ~= Title
        and Object ~= Minimize
        and Object ~= Corner
        and Object ~= Stroke then
            Object.Visible = not Minimized
        end
    end

    Main.Size = Minimized
        and UDim2.fromOffset(280, 48)
        or UDim2.fromOffset(280, 230)

    Minimize.Text = Minimized and "+" or "-"
end)

-- RESPAWN SUPPORT
Player.CharacterAdded:Connect(function()
    StopFlying()
    Humanoid = nil
    Root = nil
end)

print("ZENTRIX FLY GUI V2 LOADED")
