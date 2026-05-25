-- NPCBotPanel v2.0 - Compatible con WoW 3.3.5a (AzerothCore / TrinityCore)
-- Autor: NPCBotPanel Addon & Lleguito

-- ============================================================
-- LOCALIZATION (SISTEMA DE IDIOMAS)
-- ============================================================
local L = {
    es = {
        title = "NPCBot Panel",
        subtitle = "Panel de Control",
        close = "Cerrar",
        lock = "Bloquear panel",
        unlock = "Desbloquear panel",
        locked_msg = "Panel bloqueado",
        unlocked_msg = "Panel desbloqueado",
        reset_msg = "Posición restablecida",
        loaded_msg = "cargado. Escribe |cffffffff/nbp|r o usa el icono del minimapa.",
        created_by = "Creado por Lleguito",
        command = "Comando:",
        -- Pestañas
        tab_movement = "Movimiento",
        tab_combat = "Combate",
        tab_bonds = "Vínculos",
        tab_utility = "Utilidad",
        -- Botones: Movimiento
        btn_follow = "Seguir", desc_follow = "Bots te siguen",
        btn_follow_only = "Seguir Inactivo", desc_follow_only = "Siguen pero sin actuar",
        btn_standstill = "Quedarse", desc_standstill = "Aguantan posición",
        btn_stopfully = "Parada Total", desc_stopfully = "Paran e ignoran todo",
        btn_walk = "Caminar", desc_walk = "Alternar modo caminar",
        -- Botones: Combate
        btn_nocast = "Sin Hechizos", desc_nocast = "Alternar uso de hechizos",
        btn_nolongcast = "Sin Cast Lento", desc_nolongcast = "Alternar hechizos con cast",
        btn_nogossip = "Sin Gossip", desc_nogossip = "Alternar menú de gossip",
        -- Botones: Vínculos
        btn_unbind = "Desvincular", desc_unbind = "Desvincular bot seleccionado",
        btn_rebind = "Revincular", desc_rebind = "Llamar bot desvinculado",
        btn_hide = "Ocultar Bots", desc_hide = "Desaparecen temporalmente",
        btn_show = "Mostrar Bots", desc_show = "Vuelven a aparecer",
        -- Botones: Utilidad
        btn_info = "Info", desc_info = "Ver estado de tus bots",
        btn_recall = "Recall", desc_recall = "Llamar bots a tu posición",
        btn_teleport = "Teleportar", desc_teleport = "Teleportar bots a ti",
        btn_kill = "Matar Bot", desc_kill = "Matar bot (debug de estado)",
        btn_dist10 = "Dist: 10", desc_dist10 = "Distancia de seguimiento 10",
        btn_dist20 = "Dist: 20", desc_dist20 = "Distancia de seguimiento 20",
        btn_dist50 = "Dist: 50", desc_dist50 = "Distancia de seguimiento 50",
        -- Minimapa
        mm_click_left = "Click: Abrir/Cerrar panel",
        mm_click_right = "Click Derecho: Escribe comando",
    },
    en = {
        title = "NPCBot Panel",
        subtitle = "Control Panel",
        close = "Close",
        lock = "Lock panel",
        unlock = "Unlock panel",
        locked_msg = "Panel locked",
        unlocked_msg = "Panel unlocked",
        reset_msg = "Position reset",
        loaded_msg = "loaded. Type |cffffffff/nbp|r or use the minimap icon.",
        created_by = "Created by Lleguito",
        command = "Command:",
        -- Tabs
        tab_movement = "Movement",
        tab_combat = "Combat",
        tab_bonds = "Bonds",
        tab_utility = "Utility",
        -- Buttons: Movement
        btn_follow = "Follow", desc_follow = "Bots follow you",
        btn_follow_only = "Follow Idle", desc_follow_only = "Follow but do not act",
        btn_standstill = "Stay", desc_standstill = "Hold position",
        btn_stopfully = "Full Stop", desc_stopfully = "Stop and ignore everything",
        btn_walk = "Walk", desc_walk = "Toggle walking mode",
        -- Buttons: Combat
        btn_nocast = "No Spells", desc_nocast = "Toggle spell casting",
        btn_nolongcast = "No Slow Cast", desc_nolongcast = "Toggle spells with cast time",
        btn_nogossip = "No Gossip", desc_nogossip = "Toggle gossip menu",
        -- Buttons: Bonds
        btn_unbind = "Unbind", desc_unbind = "Unbind selected bot",
        btn_rebind = "Rebind", desc_rebind = "Summon unbound bot",
        btn_hide = "Hide Bots", desc_hide = "Temporarily disappear",
        btn_show = "Show Bots", desc_show = "Reappear",
        -- Buttons: Utility
        btn_info = "Info", desc_info = "View status of your bots",
        btn_recall = "Recall", desc_recall = "Call bots to your position",
        btn_teleport = "Teleport", desc_teleport = "Teleport bots to you",
        btn_kill = "Kill Bot", desc_kill = "Kill bot (status debug)",
        btn_dist10 = "Dist: 10", desc_dist10 = "Follow distance 10",
        btn_dist20 = "Dist: 20", desc_dist20 = "Follow distance 20",
        btn_dist50 = "Dist: 50", desc_dist50 = "Follow distance 50",
        -- Minimap
        mm_click_left = "Click: Open/Close panel",
        mm_click_right = "Right Click: Type command",
    }
}

-- ============================================================
-- SAVED VARIABLES & DEFAULTS
-- ============================================================
NPCBotPanelDB = NPCBotPanelDB or {}

local function initDB()
    if NPCBotPanelDB.posX    == nil then NPCBotPanelDB.posX    = 200  end
    if NPCBotPanelDB.posY    == nil then NPCBotPanelDB.posY    = -200 end
    if NPCBotPanelDB.locked  == nil then NPCBotPanelDB.locked  = false end
    if NPCBotPanelDB.activeTab == nil then NPCBotPanelDB.activeTab = 1 end
    if NPCBotPanelDB.mmAngle == nil then NPCBotPanelDB.mmAngle = 45   end
    if NPCBotPanelDB.visible == nil then NPCBotPanelDB.visible = false end
    if NPCBotPanelDB.lang    == nil then NPCBotPanelDB.lang    = "es"  end
end

-- ============================================================
-- CONSTANTES DE DISEÑO
-- ============================================================
local PANEL_W  = 290
local PANEL_H  = 515  -- Aumentado ligeramente para dar espacio al pie de página
local HDR_H    = 44
local TAB_H    = 28
local BTN_H    = 44
local BTN_GAP  = 3
local BTN_PAD  = 10

local WHITE_TEX = "Interface\\Buttons\\WHITE8x8"

-- ============================================================
-- CONTROL DE DATOS DINÁMICOS
-- ============================================================
local tabs = {}

local function loadTabsData()
    local str = L[NPCBotPanelDB.lang or "es"]
    tabs = {
        {
            name = str.tab_movement,
            buttons = {
                { label=str.btn_follow,       desc=str.desc_follow,             cmd=".npcbot command follow",       r=0.2, g=0.9, b=0.3, icon="Interface\\Icons\\Ability_Hunter_SniperShot"      },
                { label=str.btn_follow_only,  desc=str.desc_follow_only,        cmd=".npcbot command follow only",  r=0.3, g=0.6, b=1.0, icon="Interface\\Icons\\Spell_Nature_Slow"              },
                { label=str.btn_standstill,   desc=str.desc_standstill,         cmd=".npcbot command standstill",   r=1.0, g=0.5, b=0.1, icon="Interface\\Icons\\Spell_Nature_StoneClawTotem"    },
                { label=str.btn_stopfully,    desc=str.desc_stopfully,          cmd=".npcbot command stopfully",    r=0.9, g=0.2, b=0.2, icon="Interface\\Icons\\Ability_Golemstormbolt"         },
                { label=str.btn_walk,         desc=str.desc_walk,               cmd=".npcbot command walk",         r=0.7, g=0.3, b=1.0, icon="Interface\\Icons\\Ability_Warrior_Endlessrage"    },
            },
        },
        {
            name = str.tab_combat,
            buttons = {
                { label=str.btn_nocast,      desc=str.desc_nocast,       cmd=".npcbot command nocast",      r=0.9, g=0.2, b=0.2, icon="Interface\\Icons\\Spell_Holy_Silence"       },
                { label=str.btn_nolongcast,  desc=str.desc_nolongcast,     cmd=".npcbot command nolongcast",  r=1.0, g=0.5, b=0.1, icon="Interface\\Icons\\Spell_Nature_SpiritArmor" },
                { label=str.btn_nogossip,    desc=str.desc_nogossip,        cmd=".npcbot command nogossip",    r=0.3, g=0.6, b=1.0, icon="Interface\\Icons\\INV_Misc_Note_01"         },
            },
        },
        {
            name = str.tab_bonds,
            buttons = {
                { label=str.btn_unbind,    desc=str.desc_unbind,    cmd=".npcbot command unbind",   r=1.0, g=0.5, b=0.1, icon="Interface\\Icons\\Ability_Rogue_ShadowStrikes"  },
                { label=str.btn_rebind,    desc=str.desc_rebind,         cmd=".npcbot command rebind",   r=0.2, g=0.9, b=0.3, icon="Interface\\Icons\\Spell_Nature_NaturesBlessing"  },
                { label=str.btn_hide,      desc=str.desc_hide,       cmd=".npcbot hide",             r=0.7, g=0.3, b=1.0, icon="Interface\\Icons\\Ability_Vanish"               },
                { label=str.btn_show,      desc=str.desc_show,              cmd=".npcbot show",             r=0.2, g=0.9, b=0.3, icon="Interface\\Icons\\Ability_Stealth"              },
            },
        },
        {
            name = str.tab_utility,
            buttons = {
                { label=str.btn_info,         desc=str.desc_info,          cmd=".npcbot info",              r=0.3, g=0.6, b=1.0, icon="Interface\\Icons\\INV_Misc_QuestionMark"         },
                { label=str.btn_recall,       desc=str.desc_recall,            cmd=".npcbot recall",            r=0.2, g=0.9, b=0.3, icon="Interface\\Icons\\Spell_Nature_Cyclone"          },
                { label=str.btn_teleport,     desc=str.desc_teleport,            cmd=".npcbot recall teleport",   r=0.3, g=0.6, b=1.0, icon="Interface\\Icons\\Spell_Arcane_PortalDarnassus"  },
                { label=str.btn_kill,         desc=str.desc_kill,     cmd=".npcbot kill",              r=0.9, g=0.2, b=0.2, icon="Interface\\Icons\\Ability_Hunter_SniperShot"    },
                { label=str.btn_dist10,       desc=str.desc_dist10,     cmd=".npcbot distance 10",       r=1.0, g=0.82, b=0.0, icon="Interface\\Icons\\INV_Boots_Cloth_05"          },
                { label=str.btn_dist20,       desc=str.desc_dist20,     cmd=".npcbot distance 20",       r=1.0, g=0.82, b=0.0, icon="Interface\\Icons\\INV_Boots_Cloth_05"          },
                { label=str.btn_dist50,       desc=str.desc_dist50,     cmd=".npcbot distance 50",       r=1.0, g=0.82, b=0.0, icon="Interface\\Icons\\INV_Boots_Cloth_05"          },
            },
        },
    }
end

-- ============================================================
-- EJECUTAR COMANDO
-- ============================================================
local function executeCommand(cmd)
    SendChatMessage(cmd, "SAY")
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot]|r " .. cmd)
end

-- ============================================================
-- FRAME PRINCIPAL Y ELEMENTOS DE INTERFAZ
-- ============================================================
local mainFrame
local contentHolder
local tabBtns = {}
local activeTab = 1

local subFS
local creditFS
local langDropDown
local updateLocalization

local function buildTabContent(tabIdx)
    if contentHolder then
        contentHolder:Hide()
        for _, child in ipairs({contentHolder:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end
        contentHolder:SetParent(nil)
    end

    local tabData = tabs[tabIdx]
    if not tabData then return end

    contentHolder = CreateFrame("Frame", nil, mainFrame)
    contentHolder:SetPoint("TOPLEFT",     mainFrame, "TOPLEFT",      BTN_PAD, -(HDR_H + TAB_H + 6))
    contentHolder:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -BTN_PAD,  42) -- Ajustado para dejar espacio abajo

    for i, btnData in ipairs(tabData.buttons) do
        local btn = CreateFrame("Button", nil, contentHolder)
        btn:SetHeight(BTN_H)
        btn:SetPoint("LEFT",  contentHolder, "LEFT",  0,  0)
        btn:SetPoint("RIGHT", contentHolder, "RIGHT", 0,  0)
        btn:SetPoint("TOP",   contentHolder, "TOP",   0, -(((i-1) * (BTN_H + BTN_GAP)) + BTN_GAP))

        local bgTex = btn:CreateTexture(nil, "BACKGROUND")
        bgTex:SetTexture(WHITE_TEX)
        bgTex:SetVertexColor(0.12, 0.12, 0.18, 1)
        bgTex:SetAllPoints()

        local borderTex = btn:CreateTexture(nil, "BACKGROUND")
        borderTex:SetTexture(WHITE_TEX)
        borderTex:SetVertexColor(0.3, 0.25, 0.08, 0.7)
        borderTex:SetPoint("TOPLEFT",     btn, "TOPLEFT",    -1,  1)
        borderTex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1, -1)
        borderTex:SetDrawLayer("BACKGROUND", 0)
        bgTex:SetDrawLayer("BACKGROUND", 1)

        local accent = btn:CreateTexture(nil, "ARTWORK")
        accent:SetTexture(WHITE_TEX)
        accent:SetVertexColor(btnData.r, btnData.g, btnData.b, 1)
        accent:SetPoint("TOPLEFT",     btn, "TOPLEFT",  2,  -3)
        accent:SetPoint("BOTTOMLEFT",  btn, "BOTTOMLEFT", 2,  3)
        accent:SetWidth(3)

        local ico = btn:CreateTexture(nil, "ARTWORK")
        ico:SetTexture(btnData.icon)
        ico:SetSize(22, 22)
        ico:SetPoint("LEFT", btn, "LEFT", 12, 0)
        ico:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("TOPLEFT", ico, "TOPRIGHT", 7, -4)
        lbl:SetText(btnData.label)
        lbl:SetTextColor(0.95, 0.90, 0.75)

        local dsc = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        dsc:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -4)
        dsc:SetText(btnData.desc)
        dsc:SetTextColor(0.55, 0.50, 0.38)

        btn:SetScript("OnEnter", function()
            local s = L[NPCBotPanelDB.lang or "es"]
            bgTex:SetVertexColor(0.22, 0.20, 0.30, 1)
            lbl:SetTextColor(btnData.r, btnData.g, btnData.b)
            GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine("|cffffd700" .. btnData.label .. "|r")
            GameTooltip:AddLine(btnData.desc, 1, 1, 1, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(s.command, 0.7, 0.7, 0.7)
            GameTooltip:AddLine("|cffffffff" .. btnData.cmd .. "|r")
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            bgTex:SetVertexColor(0.12, 0.12, 0.18, 1)
            lbl:SetTextColor(0.95, 0.90, 0.75)
            GameTooltip:Hide()
        end)

        local cmdCapture = btnData.cmd
        btn:SetScript("OnClick", function()
            bgTex:SetVertexColor(0.28, 0.20, 0.04, 1)
            executeCommand(cmdCapture)
            local restoreFrame = CreateFrame("Frame")
            local elapsed = 0
            restoreFrame:SetScript("OnUpdate", function(self, dt)
                elapsed = elapsed + dt
                if elapsed >= 0.15 then
                    bgTex:SetVertexColor(0.12, 0.12, 0.18, 1)
                    self:SetScript("OnUpdate", nil)
                    self:Hide()
                end
            end)
        end)
    end
end

local function selectTab(idx)
    activeTab = idx
    NPCBotPanelDB.activeTab = idx
    for i, tb in ipairs(tabBtns) do
        if i == idx then
            tb.bg:SetVertexColor(0.18, 0.13, 0.03, 1)
            tb.lbl:SetTextColor(1.0, 0.82, 0.0)
            tb.line:Show()
        else
            tb.bg:SetVertexColor(0.08, 0.07, 0.02, 1)
            tb.lbl:SetTextColor(0.55, 0.50, 0.38)
            tb.line:Hide()
        end
    end
    buildTabContent(idx)
end

local function buildMainFrame()
    local str = L[NPCBotPanelDB.lang or "es"]

    mainFrame = CreateFrame("Frame", "NPCBotPanelMainFrame", UIParent)
    mainFrame:SetWidth(PANEL_W)
    mainFrame:SetHeight(PANEL_H)
    mainFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", NPCBotPanelDB.posX, NPCBotPanelDB.posY)
    mainFrame:SetFrameStrata("MEDIUM")
    mainFrame:SetClampedToScreen(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetMovable(not NPCBotPanelDB.locked)
    if not NPCBotPanelDB.locked then
        mainFrame:RegisterForDrag("LeftButton")
    end

    local mainBg = mainFrame:CreateTexture(nil, "BACKGROUND")
    mainBg:SetTexture(WHITE_TEX)
    mainBg:SetVertexColor(0.05, 0.05, 0.08, 0.94)
    mainBg:SetAllPoints()

    local outerBorder = mainFrame:CreateTexture(nil, "BACKGROUND")
    outerBorder:SetTexture(WHITE_TEX)
    outerBorder:SetVertexColor(0.7, 0.55, 0.0, 0.9)
    outerBorder:SetPoint("TOPLEFT",     mainFrame, "TOPLEFT",    -2,  2)
    outerBorder:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 2, -2)
    outerBorder:SetDrawLayer("BACKGROUND", -1)

    -- ---- CABECERA ----
    local hdr = CreateFrame("Frame", nil, mainFrame)
    hdr:SetHeight(HDR_H)
    hdr:SetPoint("TOPLEFT",  mainFrame, "TOPLEFT",  0, 0)
    hdr:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)

    local hdrBg = hdr:CreateTexture(nil, "BACKGROUND")
    hdrBg:SetTexture(WHITE_TEX)
    hdrBg:SetVertexColor(0.09, 0.07, 0.01, 1)
    hdrBg:SetAllPoints()

    local hdrLine = hdr:CreateTexture(nil, "ARTWORK")
    hdrLine:SetTexture(WHITE_TEX)
    hdrLine:SetVertexColor(1.0, 0.82, 0.0, 0.9)
    hdrLine:SetHeight(2)
    hdrLine:SetPoint("BOTTOMLEFT",  hdr, "BOTTOMLEFT",  0, 0)
    hdrLine:SetPoint("BOTTOMRIGHT", hdr, "BOTTOMRIGHT", 0, 0)

    local addonIco = hdr:CreateTexture(nil, "ARTWORK")
    addonIco:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01")
    addonIco:SetSize(26, 26)
    addonIco:SetPoint("LEFT", hdr, "LEFT", 8, 0)
    addonIco:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local titleFS = hdr:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleFS:SetPoint("LEFT", addonIco, "RIGHT", 7, 3)
    titleFS:SetText("|cffffd700NPCBot|r Panel")

    subFS = hdr:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subFS:SetPoint("LEFT", addonIco, "RIGHT", 7, -9)
    subFS:SetText(str.subtitle)
    subFS:SetTextColor(0.55, 0.50, 0.38)

    local closeBtn = CreateFrame("Button", nil, hdr)
    closeBtn:SetSize(18, 18)
    closeBtn:SetPoint("TOPRIGHT", hdr, "TOPRIGHT", -6, -6)
    local closeTex = closeBtn:CreateTexture(nil, "ARTWORK")
    closeTex:SetTexture("Interface\\Buttons\\UI-StopButton")
    closeTex:SetAllPoints()
    closeBtn:SetScript("OnClick", function()
        mainFrame:Hide()
        NPCBotPanelDB.visible = false
    end)
    closeBtn:SetScript("OnEnter", function()
        local s = L[NPCBotPanelDB.lang or "es"]
        GameTooltip:SetOwner(closeBtn, "ANCHOR_LEFT")
        GameTooltip:SetText(s.close)
        GameTooltip:Show()
    end)
    closeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local lockBtn = CreateFrame("Button", nil, hdr)
    lockBtn:SetSize(18, 18)
    lockBtn:SetPoint("RIGHT", closeBtn, "LEFT", -4, 0)
    local lockIco = lockBtn:CreateTexture(nil, "ARTWORK")
    lockIco:SetTexture("Interface\\Icons\\Ability_Warrior_ShieldWall")
    lockIco:SetAllPoints()
    lockIco:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    if NPCBotPanelDB.locked then
        lockIco:SetVertexColor(1, 0.5, 0.1)
    end
    lockBtn:SetScript("OnClick", function()
        NPCBotPanelDB.locked = not NPCBotPanelDB.locked
        local s = L[NPCBotPanelDB.lang or "es"]
        if NPCBotPanelDB.locked then
            mainFrame:SetMovable(false)
            mainFrame:RegisterForDrag()
            lockIco:SetVertexColor(1, 0.5, 0.1)
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.locked_msg)
        else
            mainFrame:SetMovable(true)
            mainFrame:RegisterForDrag("LeftButton")
            lockIco:SetVertexColor(1, 1, 1)
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.unlocked_msg)
        end
    end)
    lockBtn:SetScript("OnEnter", function()
        local s = L[NPCBotPanelDB.lang or "es"]
        GameTooltip:SetOwner(lockBtn, "ANCHOR_LEFT")
        GameTooltip:SetText(NPCBotPanelDB.locked and s.unlock or s.lock)
        GameTooltip:Show()
    end)
    lockBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ---- BARRA DE PESTAÑAS ----
    local tabBar = CreateFrame("Frame", nil, mainFrame)
    tabBar:SetHeight(TAB_H)
    tabBar:SetPoint("TOPLEFT",  hdr, "BOTTOMLEFT",  0, 0)
    tabBar:SetPoint("TOPRIGHT", hdr, "BOTTOMRIGHT", 0, 0)

    local tabBarBg = tabBar:CreateTexture(nil, "BACKGROUND")
    tabBarBg:SetTexture(WHITE_TEX)
    tabBarBg:SetVertexColor(0.07, 0.06, 0.01, 1)
    tabBarBg:SetAllPoints()

    local tabW = PANEL_W / #tabs
    for i, tabDef in ipairs(tabs) do
        local tb = CreateFrame("Button", nil, tabBar)
        tb:SetWidth(tabW)
        tb:SetHeight(TAB_H)
        tb:SetPoint("LEFT", tabBar, "LEFT", (i - 1) * tabW, 0)

        local tbBg = tb:CreateTexture(nil, "BACKGROUND")
        tbBg:SetTexture(WHITE_TEX)
        tbBg:SetVertexColor(0.08, 0.07, 0.02, 1)
        tbBg:SetAllPoints()
        tb.bg = tbBg

        local tbLbl = tb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tbLbl:SetPoint("CENTER", tb, "CENTER", 0, 0)
        tbLbl:SetText(tabDef.name)
        tbLbl:SetTextColor(0.55, 0.50, 0.38)
        tb.lbl = tbLbl

        local tbLine = tb:CreateTexture(nil, "ARTWORK")
        tbLine:SetTexture(WHITE_TEX)
        tbLine:SetVertexColor(1.0, 0.82, 0.0, 1)
        tbLine:SetHeight(2)
        tbLine:SetPoint("BOTTOMLEFT",  tb, "BOTTOMLEFT",  2, 0)
        tbLine:SetPoint("BOTTOMRIGHT", tb, "BOTTOMRIGHT", -2, 0)
        tbLine:Hide()
        tb.line = tbLine

        if i > 1 then
            local sep = tabBar:CreateTexture(nil, "ARTWORK")
            sep:SetTexture(WHITE_TEX)
            sep:SetVertexColor(0.3, 0.25, 0.05, 0.5)
            sep:SetWidth(1)
            sep:SetPoint("TOPLEFT",    tabBar, "TOPLEFT",    (i-1)*tabW, -3)
            sep:SetPoint("BOTTOMLEFT", tabBar, "BOTTOMLEFT", (i-1)*tabW,  3)
        end

        local iCapture = i
        tb:SetScript("OnEnter", function(self)
            if iCapture ~= activeTab then
                self.bg:SetVertexColor(0.14, 0.12, 0.04, 1)
            end
        end)
        tb:SetScript("OnLeave", function(self)
            if iCapture ~= activeTab then
                self.bg:SetVertexColor(0.08, 0.07, 0.02, 1)
            end
        end)
        tb:SetScript("OnClick", function()
            selectTab(iCapture)
            PlaySound("igCharacterInfoTab")
        end)

        tabBtns[i] = tb
    end

    local tabBottomLine = mainFrame:CreateTexture(nil, "ARTWORK")
    tabBottomLine:SetTexture(WHITE_TEX)
    tabBottomLine:SetVertexColor(0.4, 0.30, 0.05, 0.6)
    tabBottomLine:SetHeight(1)
    tabBottomLine:SetPoint("TOPLEFT",  tabBar, "BOTTOMLEFT",  0, 0)
    tabBottomLine:SetPoint("TOPRIGHT", tabBar, "BOTTOMRIGHT", 0, 0)

    -- ---- PIE DE PÁGINA (CRÉDITOS Y DESPLEGABLE IDIOMA) ----
    creditFS = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    creditFS:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -12, 12)
    creditFS:SetText(str.created_by)
    creditFS:SetTextColor(0.55, 0.50, 0.38)

    langDropDown = CreateFrame("Frame", "NPCBotPanelLangDropDown", mainFrame, "UIDropDownMenuTemplate")
    langDropDown:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", -15, 4)
    UIDropDownMenu_SetWidth(langDropDown, 85)

    local function LangDropDown_OnClick(self)
        UIDropDownMenu_SetSelectedValue(langDropDown, self.value)
        NPCBotPanelDB.lang = self.value
        updateLocalization()
    end

    local function LangDropDown_Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Español"
        info.value = "es"
        info.func = LangDropDown_OnClick
        info.checked = (NPCBotPanelDB.lang == "es")
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = "English"
        info.value = "en"
        info.func = LangDropDown_OnClick
        info.checked = (NPCBotPanelDB.lang == "en")
        UIDropDownMenu_AddButton(info, level)
    end

    UIDropDownMenu_Initialize(langDropDown, LangDropDown_Initialize)
    UIDropDownMenu_SetSelectedValue(langDropDown, NPCBotPanelDB.lang or "es")
    UIDropDownMenu_SetText(langDropDown, NPCBotPanelDB.lang == "es" and "Español" or "English")

    -- Drag & Drop del panel
    mainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    mainFrame:SetScript("OnDragStop",  function(self)
        self:StopMovingOrSizing()
        NPCBotPanelDB.posX = self:GetLeft()
        NPCBotPanelDB.posY = self:GetTop() - UIParent:GetHeight()
    end)

    selectTab(NPCBotPanelDB.activeTab or 1)
end

-- ============================================================
-- FUNCIÓN DE ACTUALIZACIÓN EN TIEMPO REAL
-- ============================================================
updateLocalization = function()
    loadTabsData()
    local str = L[NPCBotPanelDB.lang or "es"]
    
    if subFS then subFS:SetText(str.subtitle) end
    if creditFS then creditFS:SetText(str.created_by) end
    
    for i, tb in ipairs(tabBtns) do
        if tabs[i] then
            tb.lbl:SetText(tabs[i].name)
        end
    end
    
    selectTab(activeTab)
    
    if langDropDown then
        UIDropDownMenu_SetText(langDropDown, NPCBotPanelDB.lang == "es" and "Español" or "English")
    end
end

-- ============================================================
-- BOTÓN MINIMAP
-- ============================================================
local mmBtn

local function buildMinimapButton()
    mmBtn = CreateFrame("Button", "NPCBotPanelMiniBtn", Minimap)
    mmBtn:SetFrameStrata("MEDIUM")
    mmBtn:SetFrameLevel(9)
    mmBtn:SetSize(32, 32)

    local function mmUpdatePos()
        local angle  = math.rad(NPCBotPanelDB.mmAngle or 45)
        local radius = 80
        mmBtn:ClearAllPoints()
        mmBtn:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
    end
    mmUpdatePos()

    local mmBg = mmBtn:CreateTexture(nil, "BACKGROUND")
    mmBg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    mmBg:SetAllPoints()

    local mmIco = mmBtn:CreateTexture(nil, "ARTWORK")
    mmIco:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01")
    mmIco:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    mmIco:SetSize(20, 20)
    mmIco:SetPoint("CENTER", mmBtn, "CENTER", 1, -1)

    mmBtn:SetScript("OnEnter", function(self)
        local s = L[NPCBotPanelDB.lang or "es"]
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cffffd700NPCBot Panel|r")
        GameTooltip:AddLine(s.mm_click_left, 1, 1, 1)
        GameTooltip:AddLine(s.mm_click_right, 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    mmBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    mmBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    mmBtn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if mainFrame:IsShown() then
                mainFrame:Hide()
                NPCBotPanelDB.visible = false
            else
                mainFrame:Show()
                NPCBotPanelDB.visible = true
            end
            PlaySound("igMainMenuOptionCheckBoxOn")
        elseif button == "RightButton" then
            if not ChatFrame1EditBox:IsVisible() then
                ChatFrame1EditBox:Show()
                ChatFrame1EditBox:SetFocus()
            end
            ChatFrame1EditBox:SetText(".npcbot ")
            ChatFrame1EditBox:SetCursorPosition(100)
        end
    end)

    mmBtn:EnableMouse(true)
    mmBtn:SetMovable(true)
    mmBtn:RegisterForDrag("LeftButton")
    mmBtn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local cx, cy = Minimap:GetCenter()
            local mx, my = GetCursorPosition()
            local uiScale = UIParent:GetEffectiveScale()
            mx = mx / uiScale
            my = my / uiScale
            local angle = math.atan2(my - cy, mx - cx)
            NPCBotPanelDB.mmAngle = math.deg(angle)
            mmUpdatePos()
        end)
    end)
    mmBtn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
end

-- ============================================================
-- SLASH COMMANDS
-- ============================================================
SLASH_NPCBOTPANEL1 = "/nbp"
SLASH_NPCBOTPANEL2 = "/npcbotpanel"
SlashCmdList["NPCBOTPANEL"] = function(msg)
    local s = L[NPCBotPanelDB.lang or "es"]
    msg = msg:match("^%s*(.-)%s*$"):lower()
    if msg == "reset" then
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, -200)
        NPCBotPanelDB.posX = 200
        NPCBotPanelDB.posY = -200
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.reset_msg)
    elseif msg == "lock" then
        NPCBotPanelDB.locked = true
        mainFrame:SetMovable(false)
        mainFrame:RegisterForDrag()
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.locked_msg)
    elseif msg == "unlock" then
        NPCBotPanelDB.locked = false
        mainFrame:SetMovable(true)
        mainFrame:RegisterForDrag("LeftButton")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.unlocked_msg)
    else
        if mainFrame and mainFrame:IsShown() then
            mainFrame:Hide()
            NPCBotPanelDB.visible = false
        elseif mainFrame then
            mainFrame:Show()
            NPCBotPanelDB.visible = true
        end
    end
end

-- ============================================================
-- EVENTOS DE CARGA
-- ============================================================
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
local addonLoaded = false

loader:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "NPCBotPanel" then
        initDB()
        loadTabsData()
        buildMainFrame()
        buildMinimapButton()
        if NPCBotPanelDB.visible then
            mainFrame:Show()
        else
            mainFrame:Hide()
        end
        addonLoaded = true

    elseif event == "PLAYER_LOGIN" and addonLoaded then
        local s = L[NPCBotPanelDB.lang or "es"]
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[NPCBot Panel]|r " .. s.loaded_msg)
    end
end)