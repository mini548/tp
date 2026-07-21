-- ===== 座標儲存與傳送腳本 (精簡版) =====
-- 功能：儲存座標(編號1,2,3...) / 傳送 / 縮小面板
-- 操作：點擊座標選取 → 點傳送 → 到達

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- =============================================
-- 📂 儲存空間
-- =============================================
local SavedPoints = {}  -- { Vector3.new(x,y,z), ... }

-- =============================================
-- 🖥️ 主 UI
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Position = UDim2.new(0.5, -110, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
MainFrame.Visible = true

-- ===== 標題列 (含縮小按鈕) =====
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
Title.Text = "📍 座標傳送"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- ===== 縮小按鈕 (標題列右邊) =====
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 25)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 180)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "➖"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

-- ===== 關閉按鈕 =====
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- =============================================
-- 📌 縮小 / 展開 功能
-- =============================================
local isMinimized = false

local function MinimizeUI()
    isMinimized = true
    MainFrame.Size = UDim2.new(0, 50, 0, 35)
    MainFrame.Position = UDim2.new(0.9, -25, 0.05, 0)
    MainFrame.BackgroundTransparency = 0.3
    -- 隱藏所有子元件 (除了標題和展開按鈕)
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child ~= Title and child ~= MinBtn and child ~= CloseBtn then
            child.Visible = false
        end
    end
    Title.Text = "📍"
    Title.TextSize = 20
    MinBtn.Text = "➕"
    CloseBtn.Visible = false
    -- 縮小時可拖動範圍變小，鎖定位置
    MainFrame.Size = UDim2.new(0, 50, 0, 35)
    MainFrame.Active = true
    MainFrame.Draggable = true
end

local function ExpandUI()
    isMinimized = false
    MainFrame.Size = UDim2.new(0, 220, 0, 300)
    MainFrame.BackgroundTransparency = 0.1
    for _, child in ipairs(MainFrame:GetChildren()) do
        child.Visible = true
    end
    Title.Text = "📍 座標傳送"
    Title.TextSize = 16
    MinBtn.Text = "➖"
    CloseBtn.Visible = true
    MainFrame.Active = true
    MainFrame.Draggable = true
end

MinBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        ExpandUI()
    else
        MinimizeUI()
    end
end)

-- ===== 當前座標顯示 =====
local PosLabel = Instance.new("TextLabel")
PosLabel.Size = UDim2.new(0.9, 0, 0, 22)
PosLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
PosLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
PosLabel.BorderSizePixel = 0
PosLabel.Text = "X: 0  Y: 0  Z: 0"
PosLabel.TextColor3 = Color3.new(0.8, 0.8, 1)
PosLabel.Font = Enum.Font.Gotham
PosLabel.TextSize = 12
PosLabel.Parent = MainFrame

game:GetService("RunService").Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        PosLabel.Text = string.format("X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
    end
end)

-- ===== 儲存按鈕 =====
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.42, 0, 0, 35)
SaveBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
SaveBtn.BorderSizePixel = 0
SaveBtn.Text = "💾 儲存"
SaveBtn.TextColor3 = Color3.new(1, 1, 1)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 14
SaveBtn.Parent = MainFrame

SaveBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    table.insert(SavedPoints, root.Position)
    RefreshList()
    print("✅ 已儲存座標 #" .. #SavedPoints)
end)

-- ===== 傳送按鈕 =====
local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Size = UDim2.new(0.42, 0, 0, 35)
TeleportBtn.Position = UDim2.new(0.53, 0, 0.20, 0)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
TeleportBtn.BorderSizePixel = 0
TeleportBtn.Text = "🚀 傳送"
TeleportBtn.TextColor3 = Color3.new(1, 1, 1)
TeleportBtn.Font = Enum.Font.GothamBold
TeleportBtn.TextSize = 14
TeleportBtn.Parent = MainFrame

local SelectedIndex = nil

TeleportBtn.MouseButton1Click:Connect(function()
    if SelectedIndex == nil then
        print("⚠️ 請點擊列表中的座標")
        return
    end
    local pos = SavedPoints[SelectedIndex]
    if not pos then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.CFrame = CFrame.new(pos)
    print("✅ 傳送到 #" .. (SelectedIndex + 1))
end)

-- ===== 座標列表 =====
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(0.9, 0, 0.45, 0)
ListFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
ListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
ListFrame.BorderSizePixel = 1
ListFrame.BorderColor3 = Color3.fromRGB(80, 80, 120)
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.ScrollBarThickness = 6
ListFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = ListFrame

-- ===== 清空全部 =====
local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.42, 0, 0, 30)
ClearBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClearBtn.BorderSizePixel = 0
ClearBtn.Text = "🗑️ 清空"
ClearBtn.TextColor3 = Color3.new(1, 1, 1)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 13
ClearBtn.Parent = MainFrame

ClearBtn.MouseButton1Click:Connect(function()
    if #SavedPoints == 0 then return end
    SavedPoints = {}
    SelectedIndex = nil
    RefreshList()
    print("🗑️ 已清空")
end)

-- ===== 刷新列表 =====
function RefreshList()
    for _, child in ipairs(ListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    if #SavedPoints == 0 then
        local EmptyLabel = Instance.new("TextLabel")
        EmptyLabel.Size = UDim2.new(1, 0, 0, 30)
        EmptyLabel.BackgroundTransparency = 1
        EmptyLabel.Text = "⚠️ 無座標"
        EmptyLabel.TextColor3 = Color3.fromRGB(0.6, 0.6, 0.6)
        EmptyLabel.Font = Enum.Font.Gotham
        EmptyLabel.TextSize = 14
        EmptyLabel.Parent = ListFrame
        return
    end

    ListFrame.CanvasSize = UDim2.new(0, 0, 0, #SavedPoints * 32 + 4)

    for i, pos in ipairs(SavedPoints) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 30)
        btn.BackgroundColor3 = (SelectedIndex == i) and Color3.fromRGB(50, 120, 200) or Color3.fromRGB(50, 50, 75)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(80, 80, 120)
        btn.Text = "#" .. i .. "  (" .. string.format("%.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z) .. ")"
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = ListFrame

        btn.MouseButton1Click:Connect(function()
            if SelectedIndex == i then
                SelectedIndex = nil
            else
                SelectedIndex = i
            end
            RefreshList()
        end)

        -- 右鍵/長按刪除
        btn.MouseButton2Click:Connect(function()
            if i <= #SavedPoints then
                table.remove(SavedPoints, i)
                if SelectedIndex == i then SelectedIndex = nil end
                RefreshList()
                print("🗑️ 已刪除 #" .. i)
            end
        end)

        local holdTime = 0
        local holding = false
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                holding = true
                holdTime = tick()
                task.wait(0.5)
                if holding and (tick() - holdTime) >= 0.5 then
                    if i <= #SavedPoints then
                        table.remove(SavedPoints, i)
                        if SelectedIndex == i then SelectedIndex = nil end
                        RefreshList()
                        print("🗑️ 已刪除 #" .. i)
                    end
                end
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                holding = false
            end
        end)
    end
end

RefreshList()

-- =============================================
-- ⌨️ 快捷鍵
-- =============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.S and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        SaveBtn.MouseButton1Click:Fire()
    end
    if input.KeyCode == Enum.KeyCode.T and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        TeleportBtn.MouseButton1Click:Fire()
    end
end)

-- =============================================
-- 📢 通知
-- =============================================
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "📍 座標傳送",
    Text = "[Ctrl+S]儲存  [Ctrl+T]傳送  點「➖」縮小",
    Duration = 3
})

print("✅ 座標傳送已載入！")
print("   🔹 [Ctrl+S] 儲存當前位置")
print("   🔹 [Ctrl+T] 傳送")
print("   🔹 點「➖」縮小面板")
