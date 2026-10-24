local currentBoss = "Lord Marrowgar"
local currentDiff = "10N"
currentLang = "PT" 

local langBtn
local selectedBossTexture 
local sidebarScrollFrame
local sidebarContent

-- Detecta a janela principal do XML (seja com nome antigo ou novo)
local mainFrame = ICCRaiderGuideFrame or ICCJournalFrame

local function SendTacticsToRaid(bossName, diff)
    local bossEntry = BossData[bossName]
    if not bossEntry or not bossEntry[diff] or not bossEntry[diff][currentLang] then 
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[ICCRG]|r Nenhuma dica cadastrada.")
        return 
    end

    local summaryList = bossEntry[diff][currentLang].summary
    local chatChannel = "SAY"

    if GetNumRaidMembers() > 0 then
        if IsRaidLeader() or IsRaidOfficer() then
            chatChannel = "RAID_WARNING"
        else
            chatChannel = "RAID"
        end
    elseif GetNumPartyMembers() > 0 then
        chatChannel = "PARTY"
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100--- " .. bossName .. " (" .. diff .. " - " .. currentLang .. ") ---|r")
        for _, line in ipairs(summaryList) do
            DEFAULT_CHAT_FRAME:AddMessage(line)
        end
        return
    end

    SendChatMessage("=== " .. bossName .. " (" .. diff .. ") ===", chatChannel)
    for _, line in ipairs(summaryList) do
        SendChatMessage(line, chatChannel)
    end
end

local function UpdateJournal(bossName, diff, bossButtonFrame)
    currentBoss = bossName
    currentDiff = diff
    
    local textToDisplay = "Táticas não encontradas."
    local bossEntry = BossData[bossName]
    
    if bossEntry and bossEntry[diff] and bossEntry[diff][currentLang] then
        textToDisplay = bossEntry[diff][currentLang].text
    end
    
    local journalText = ICCRaiderGuideText or ICCJournalText
    local scrollChild = ICCRaiderGuideScrollChild or ICCJournalScrollChild
    local contentBox = ICCRaiderGuideContentBox or ICCJournalContentBox
    local scrollFrame = ICCRaiderGuideScrollFrame or ICCJournalScrollFrame
    local subtitleText = ICCRaiderGuideSubtitle or ICCJournalSubtitle

    if journalText and scrollChild and contentBox then
        local calcWidth = contentBox:GetWidth() - 50
        if calcWidth < 200 then calcWidth = 410 end

        journalText:SetWidth(calcWidth)
        journalText:SetText(textToDisplay)
        
        local actualHeight = journalText:GetHeight()
        if actualHeight < 1 then actualHeight = 400 end
        
        scrollChild:SetHeight(actualHeight + 60)
        if scrollFrame then scrollFrame:SetVerticalScroll(0) end
    end
    
    if subtitleText then
        subtitleText:SetText(bossName .. " (" .. diff .. ") - [" .. currentLang .. "]")
    end

    if bossButtonFrame and selectedBossTexture then
        selectedBossTexture:SetParent(bossButtonFrame)
        selectedBossTexture:SetPoint("TOPLEFT", bossButtonFrame, "TOPLEFT", -2, 2)
        selectedBossTexture:SetPoint("BOTTOMRIGHT", bossButtonFrame, "BOTTOMRIGHT", 2, -2)
        selectedBossTexture:Show()
    end
end

local function ToggleLanguage()
    if currentLang == "PT" then
        currentLang = "EN"
    else
        currentLang = "PT"
    end
    
    if ICCRaiderGuideDB then ICCRaiderGuideDB.lang = currentLang end
    if ICCJournalDB then ICCJournalDB.lang = currentLang end
    if langBtn then langBtn:SetText("Lang: " .. currentLang) end
    
    UpdateJournal(currentBoss, currentDiff)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100[ICCRG]|r Idioma alterado para: " .. currentLang)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "ICCJournal" and addonName ~= "ICCRG" and addonName ~= "ICCRaiderGuide" then return end
    
    mainFrame = ICCRaiderGuideFrame or ICCJournalFrame
    if not mainFrame then return end

    ICCRaiderGuideDB = ICCRaiderGuideDB or ICCJournalDB or {}
    if ICCRaiderGuideDB.lang then
        currentLang = ICCRaiderGuideDB.lang
    end

    ---------------------------------------------------------------------------
    -- FIX DO REDIMENSIONAMENTO / RESIZE DA JANELA PRINCIPAL
    ---------------------------------------------------------------------------
    mainFrame:SetResizable(true)
    
    -- Define limites rígidos de redimensionamento (Lagura Min/Max , Altura Min/Max)
    if mainFrame.SetMinResize then
        mainFrame:SetMinResize(540, 420)
    end
    if mainFrame.SetMaxResize then
        mainFrame:SetMaxResize(850, 650)
    end

    -- Sobrescreve handlers de resize para garantir que o ponteiro do mouse não descole
    mainFrame:SetScript("OnSizeChanged", function(self, width, height)
        if sidebarScrollFrame then
            sidebarScrollFrame:UpdateScrollChildRect()
        end
    end)

    -- Textura de seleção do boss
    selectedBossTexture = mainFrame:CreateTexture(nil, "OVERLAY")
    selectedBossTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight")
    selectedBossTexture:SetBlendMode("ADD")
    selectedBossTexture:SetVertexColor(1, 0.82, 0, 1)

    ---------------------------------------------------------------------------
    -- CONTAINER SCROLLFRAME DOS RETRATOS DOS CHEFES (LATERAL DIREITA)
    ---------------------------------------------------------------------------
    sidebarScrollFrame = CreateFrame("ScrollFrame", "ICCBossSidebarScrollFrame", mainFrame, "UIPanelScrollFrameTemplate")
    
    -- Ancoragem fixa relativa às bordas superior e inferior da janela
    sidebarScrollFrame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -12, -55)
    sidebarScrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -12, 45)
    sidebarScrollFrame:SetWidth(44)

    -- Oculta levemente a barra visual de scroll
    if ICCBossSidebarScrollFrameScrollBar then
        ICCBossSidebarScrollFrameScrollBar:SetAlpha(0.3)
    end

    sidebarContent = CreateFrame("Frame", "ICCBossSidebarContent", sidebarScrollFrame)
    sidebarContent:SetSize(42, 1)
    sidebarScrollFrame:SetScrollChild(sidebarContent)

    -- Permite rolar os ícones com a rodinha do mouse
    sidebarScrollFrame:EnableMouseWheel(true)
    sidebarScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local maxScroll = self:GetVerticalScrollRange()
        local newScroll = current - (delta * 25)
        
        if newScroll < 0 then
            newScroll = 0
        elseif newScroll > maxScroll then
            newScroll = maxScroll
        end
        
        self:SetVerticalScroll(newScroll)
    end)

    -- Criação dos botões dos chefes
    local buttonSize = 38
    local buttonSpacing = 42
    for i, bossName in ipairs(BossOrder) do
        local b = CreateFrame("Button", "ICCBossBtn"..i, sidebarContent)
        b:SetSize(buttonSize, buttonSize)
        b:SetPoint("TOPLEFT", sidebarContent, "TOPLEFT", 0, -(i-1)*buttonSpacing)
        
        local bg = b:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture("Interface\\Buttons\\UI-EmptySlot-White")
        bg:SetVertexColor(0.1, 0.3, 0.5, 1)
        
        local icon = b:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
        
        if BossData[bossName] and BossData[bossName].icon then
            icon:SetTexture(BossData[bossName].icon)
        end
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        local hl = b:CreateTexture(nil, "HIGHLIGHT")
        hl:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        hl:SetAllPoints()
        hl:SetBlendMode("ADD")

        b:SetScript("OnClick", function(self) 
            UpdateJournal(bossName, currentDiff, self) 
        end)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(bossName)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)

        if i == 1 then
            UpdateJournal(bossName, "10N", b)
        end
    end

    sidebarContent:SetHeight(#BossOrder * buttonSpacing)

    -- Botões na Barra Inferior
    local parentFrame = ICCRaiderGuideDifficultyContainer or ICCJournalDifficultyContainer
    if parentFrame then
        local diffs = {"10N", "10H", "25N", "25H"}
        for i, d in ipairs(diffs) do
            local b = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
            b:SetSize(48, 22)
            b:SetPoint("LEFT", parentFrame, "LEFT", (i-1)*52, 0)
            b:SetText(d)
            b:SetScript("OnClick", function() UpdateJournal(currentBoss, d) end)
        end

        langBtn = CreateFrame("Button", "ICCRG_LangBtn", parentFrame, "UIPanelButtonTemplate")
        langBtn:SetSize(72, 22)
        langBtn:SetPoint("LEFT", parentFrame, "LEFT", 212, 0)
        langBtn:SetText("Lang: " .. currentLang)
        langBtn:SetScript("OnClick", function()
            ToggleLanguage()
        end)

        local announceBtn = CreateFrame("Button", "ICCRG_AnnounceBtn", parentFrame, "UIPanelButtonTemplate")
        announceBtn:SetSize(110, 22)
        announceBtn:SetPoint("RIGHT", parentFrame, "RIGHT", 0, 0)
        announceBtn:SetText("Anunciar Chat")
        announceBtn:SetScript("OnClick", function()
            SendTacticsToRaid(currentBoss, currentDiff)
        end)
    end
end)

-- Comandos Slash
SLASH_ICCRG1 = "/iccrg"
SLASH_ICCRG2 = "/iccj"
SlashCmdList["ICCRG"] = function(msg)
    msg = string.lower(strtrim(msg or ""))
    mainFrame = ICCRaiderGuideFrame or ICCJournalFrame
    
    if msg == "en" then
        currentLang = "EN"
        if ICCRaiderGuideDB then ICCRaiderGuideDB.lang = currentLang end
        if langBtn then langBtn:SetText("Lang: " .. currentLang) end
        UpdateJournal(currentBoss, currentDiff)
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100[ICCRG]|r Language changed to English.")
    elseif msg == "pt" then
        currentLang = "PT"
        if ICCRaiderGuideDB then ICCRaiderGuideDB.lang = currentLang end
        if langBtn then langBtn:SetText("Lang: " .. currentLang) end
        UpdateJournal(currentBoss, currentDiff)
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100[ICCRG]|r Idioma alterado para Português.")
    else
        if mainFrame then
            if mainFrame:IsShown() then 
                mainFrame:Hide() 
            else 
                mainFrame:Show() 
            end
        end
    end
end

SLASH_ICCRG1 = "/iccrg"
SLASH_ICCRG2 = "/ICCRG"

SlashCmdList["ICCRG"] = function(msg)
    msg = string.lower(strtrim(msg or ""))
    mainFrame = ICCRaiderGuideFrame or ICCJournalFrame
    
    if msg == "-v" or msg == "-version" or msg == "v" or msg == "version" then
        -- Busca a versão registrada no arquivo .toc
        local version = GetAddOnMetadata("ICCRG", "Version") 
                     or GetAddOnMetadata("ICCRaiderGuide", "Version") 
                     or GetAddOnMetadata("ICCJournal", "Version") 
                     or "1.0.0"
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100[ICCRG]|r Versão atual: |cff00ff00v" .. version .. "|r")

    elseif msg == "-help" or msg == "help" or msg == "-h" then
        -- Menu de ajuda de comandos básicos
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100--- [ICCRG] Ajuda & Comandos ---|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/iccrg|r : Abre ou fecha a janela principal")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/iccrg -v|r : Exibe a versão atual do AddOn")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/iccrg -pt|r : Muda o idioma do guia para Português")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/iccrg -en|r : Muda o idioma do guia para Inglês")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00/iccrg -help|r : Exibe este menu de ajuda")

    elseif msg == "-en" or msg == "en" then
        currentLang = "EN"
        if ICCRaiderGuideDB then ICCRaiderGuideDB.lang = currentLang end
        if langBtn then langBtn:SetText("Lang: " .. currentLang) end
        UpdateJournal(currentBoss, currentDiff)
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100[ICCRG]|r Language changed to English.")

    elseif msg == "-pt" or msg == "pt" then
        currentLang = "PT"
        if ICCRaiderGuideDB then ICCRaiderGuideDB.lang = currentLang end
        if langBtn then langBtn:SetText("Lang: " .. currentLang) end
        UpdateJournal(currentBoss, currentDiff)
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100[ICCRG]|r Idioma alterado para Português.")

    elseif msg == "" then
        -- Sem argumentos: apenas abre/fecha a janela
        if mainFrame then
            if mainFrame:IsShown() then 
                mainFrame:Hide() 
            else 
                mainFrame:Show() 
            end
        end

    else
        -- Comando inválido
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[ICCRG]|r Comando não reconhecido. Use |cff00ff00/iccrg -help|r para ver a lista de comandos.")
    end
end

-------------------------------------------------------------------------------
-- BOTÃO CIRCULAR NO MINIMAPA
-------------------------------------------------------------------------------
local minimapAngle = 45

local mmBtn = CreateFrame("Button", "ICCRG_MinimapBtn", Minimap)
mmBtn:SetSize(31, 31)
mmBtn:SetFrameStrata("MEDIUM")
mmBtn:SetFrameLevel(8)
mmBtn:EnableMouse(true)
mmBtn:RegisterForClicks("LeftButtonUp")
mmBtn:RegisterForDrag("LeftButton")

local mmBg = mmBtn:CreateTexture(nil, "BACKGROUND")
mmBg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
mmBg:SetSize(53, 53)
mmBg:SetPoint("TOPLEFT", -6, 5)

local mmIcon = mmBtn:CreateTexture(nil, "ARTWORK")
mmIcon:SetTexture("Interface\\Icons\\achievement_boss_lichking")
mmIcon:SetSize(18, 18)
mmIcon:SetPoint("CENTER", 0, 0)
mmIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

local mmHighlight = mmBtn:CreateTexture(nil, "HIGHLIGHT")
mmHighlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
mmHighlight:SetBlendMode("ADD")
mmHighlight:SetAllPoints(mmBtn)

mmBtn:SetScript("OnMouseDown", function(self)
    mmIcon:SetSize(16, 16)
    mmIcon:ClearAllPoints()
    mmIcon:SetPoint("CENTER", self, "CENTER", 0, 0)
end)

mmBtn:SetScript("OnMouseUp", function(self)
    mmIcon:SetSize(18, 18)
    mmIcon:ClearAllPoints()
    mmIcon:SetPoint("CENTER", self, "CENTER", 0, 0)
end)

local function UpdateMinimapButtonPosition()
    local rad = math.rad(minimapAngle)
    local x = math.cos(rad) * 80
    local y = math.sin(rad) * 80
    mmBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

mmBtn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local xpos, ypos = GetCursorPosition()
        local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
        local scale = Minimap:GetEffectiveScale()
        
        xpos = xpos / scale - xmin - 70
        ypos = ypos / scale - ymin - 70
        
        minimapAngle = math.deg(math.atan2(ypos, xpos))
        UpdateMinimapButtonPosition()
    end)
end)

mmBtn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

mmBtn:SetScript("OnClick", function()
    mainFrame = ICCRaiderGuideFrame or ICCJournalFrame
    if mainFrame then
        if mainFrame:IsShown() then
            mainFrame:Hide()
        else
            mainFrame:Show()
        end
    end
end)

mmBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("ICC Raider Guide")
    GameTooltip:AddLine("Clique para abrir o guia de ICC.", 1, 1, 1)
    GameTooltip:AddLine("Segure e arraste para mover o ícone.", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

mmBtn:SetScript("OnLeave", function() 
    GameTooltip:Hide() 
end)

UpdateMinimapButtonPosition()