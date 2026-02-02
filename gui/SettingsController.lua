--[[
	SettingsController.lua
	Author: powerkasi, DiscoFlower8890
]]

SettingsController = {}
local SettingsController_mt = Class(SettingsController, DialogElement)

function SettingsController.new(modName, model)
    local self = DialogElement.new(nil, SettingsController_mt)
    self.modName = modName
    self.model = model
    self.i18n = g_i18n
    return self
end

function SettingsController:onOpen()
    SettingsController:superClass().onOpen(self)
    self:initTexts()
    self:applyAlternatingRowColors()
    self:updateAll()
end

function SettingsController:applyAlternatingRowColors()
    local panels = { self.leftPanel, self.rightPanel }

    for _, panel in ipairs(panels) do
        if panel and (panel.children or panel.elements) then
            local childs = panel.children or panel.elements
            local alternate = false
            for _, element in ipairs(childs) do
                if element.setImageColor and element:getIsVisible() then
                    local r, g, b, a = unpack(SettingsScreen.COLOR_ALTERNATING[alternate])
                    element:setImageColor(nil, r, g, b, a)
                    alternate = not alternate
                end
            end
        end
    end
end

function SettingsController:initTexts()
    self.hudPositionSetting:setTexts({
        self.i18n:getText("ui_WoodHarvesterMeasurement_hudPosHidden"),
        self.i18n:getText("ui_WoodHarvesterMeasurement_hudPosCenter"),
        self.i18n:getText("ui_WoodHarvesterMeasurement_hudPosRight")
    })
    self.hudOffsetSetting:setTexts({
        "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"
    })
end

function SettingsController:updateAll()
    self:updateEditableValues()
    self:updateStatsValues()
end

function SettingsController:updateEditableValues()
    local model = self.model
    if model == nil then return end

    local spec = model.spec_woodHarvester
    local meas = model.spec_woodHarvesterMeasurement

    self.cutLengthMin:setText(string.format("%.1f", spec.cutLengthMin or 1.0))
    self.cutLengthMax:setText(string.format("%.1f", spec.cutLengthMax or 8.0))
    self.cutLengthStep:setText(string.format("%.1f", spec.cutLengthStep or 1.0))

    local thresholds = json.decode(meas.radiusThresholds)
    if thresholds then
        self.pineLogMinRadius:setText(tostring(math.floor((thresholds.pineLogMinRadius or 0) / 0.01)))
        self.pineShortMinRadius:setText(tostring(math.floor((thresholds.pineShortMinRadius or 0) / 0.01)))
        self.pinePulpwoodMinRadius:setText(tostring(math.floor((thresholds.pinePulpwoodMinRadius or 0) / 0.01)))
        self.spruceLogMinRadius:setText(tostring(math.floor((thresholds.spruceLogMinRadius or 0) / 0.01)))
        self.spruceShortMinRadius:setText(tostring(math.floor((thresholds.spruceShortMinRadius or 0) / 0.01)))
        self.sprucePulpwoodMinRadius:setText(tostring(math.floor((thresholds.sprucePulpwoodMinRadius or 0) / 0.01)))
    end

    local hud = json.decode(meas.hudConfigs)
    self.hudPositionSetting:setState((hud and hud.position) or 1)
    self.hudOffsetSetting:setState((hud and hud.offsetX) or HUDOffset.DEFAULT)
end

function SettingsController:updateStatsValues()
    local model = self.model
    if model == nil then return end
    local meas = model.spec_woodHarvesterMeasurement

    -- Stand stats
    local stand = json.decode(meas.currentStand)
    local set = function(id, value, suffix)
        local element = self[id]
        if element ~= nil then
            if value then
                if suffix then
                    element:setText(string.format("%0.2f%s", value, suffix))
                else
                    element:setText(tostring(value))
                end
            else
                element:setText("0")
            end
        end
    end


    set("splitCountPineLogStand", stand.splitCountPineLogStand)
    set("splitCountPineShortStand", stand.splitCountPineShortStand)
    set("splitCountPinePulpwoodStand", stand.splitCountPinePulpwoodStand)
    set("splitCountSpruceLogStand", stand.splitCountSpruceLogStand)
    set("splitCountSpruceShortStand", stand.splitCountSpruceShortStand)
    set("splitCountSprucePulpwoodStand", stand.splitCountSprucePulpwoodStand)
    set("splitCountStand", stand.splitCountStand)

    set("cubicMetrePineLogStand", stand.cubicMetrePineLogStand, " m³")
    set("cubicMetrePineShortStand", stand.cubicMetrePineShortStand, " m³")
    set("cubicMetrePinePulpwoodStand", stand.cubicMetrePinePulpwoodStand, " m³")
    set("cubicMetreSpruceLogStand", stand.cubicMetreSpruceLogStand, " m³")
    set("cubicMetreSpruceShortStand", stand.cubicMetreSpruceShortStand, " m³")
    set("cubicMetreSprucePulpwoodStand", stand.cubicMetreSprucePulpwoodStand, " m³")
    set("cubicMetreStand", stand.cubicMetreStand, " m³")
end

function SettingsController:onCutLengthChanged(element, text)
    if text == "" or text == "-" or text == "." then
        return
    end

    local num = tonumber(text)
    if not num then
        element:setText("")
        return
    end

    if num < 0.0 then num = 0.0 end
    if num > 20.0 then num = 20.0 end
end

function SettingsController:onRadiusChanged(element, text)
    local num = tonumber(text)
    if not num then
        element:setText("")
        return
    end
    if num < 0.0 then num = 0.0 end
    if num > 200.0 then num = 200.0 end
    element:setText(tostring(num))
end

function SettingsController:onClickSave()
    local model = self.model
    if not model then return end
    local spec = model.spec_woodHarvester

    local cutMin = tonumber(self.cutLengthMin:getText()) or 1.0
    local cutMax = tonumber(self.cutLengthMax:getText()) or 8.0
    local cutStep = tonumber(self.cutLengthStep:getText()) or 1.0

    spec.cutLengthMin = math.max(0.0, math.min(20.0, cutMin))
    spec.cutLengthMax = math.max(0.0, math.min(20.0, cutMax))
    spec.cutLengthStep = math.max(0.0, math.min(20.0, cutStep))

    -- Have to update this table cause apparently the game prioritises the table over the set values
    spec.cutLengths = {}
    local numSteps = math.floor((spec.cutLengthMax - spec.cutLengthMin) / spec.cutLengthStep + 0.5)
    for i = 0, numSteps do
        local length = spec.cutLengthMin + (i * spec.cutLengthStep)
        table.insert(spec.cutLengths, length)
    end

    if spec.cutLengthIndex ~= nil and spec.cutLengthIndex > #spec.cutLengths then
        spec.cutLengthIndex = #spec.cutLengths
    end

    local thresholds = json.decode(model.spec_woodHarvesterMeasurement.radiusThresholds) or {}
    thresholds.pineLogMinRadius = (tonumber(self.pineLogMinRadius:getText()) or 16) * 0.01
    thresholds.pineShortMinRadius = (tonumber(self.pineShortMinRadius:getText()) or 10) * 0.01
    thresholds.pinePulpwoodMinRadius = (tonumber(self.pinePulpwoodMinRadius:getText()) or 6) * 0.01
    thresholds.spruceLogMinRadius = (tonumber(self.spruceLogMinRadius:getText()) or 16) * 0.01
    thresholds.spruceShortMinRadius = (tonumber(self.spruceShortMinRadius:getText()) or 10) * 0.01
    thresholds.sprucePulpwoodMinRadius = (tonumber(self.sprucePulpwoodMinRadius:getText()) or 7) * 0.01
    WoodHarvesterMeasurement.setRadiusThresholds(model, json.encode(thresholds))

    local hud = json.decode(model.spec_woodHarvesterMeasurement.hudConfigs) or {}
    hud.position = self.hudPositionSetting:getState()
    hud.offsetX = self.hudOffsetSetting:getState()
    WoodHarvesterMeasurement.setHUDConfigs(model, json.encode(hud))

    self:updateStatsValues()
    g_gui:closeDialogByName("WoodHarvesterMeasurement_UI")
end

function SettingsController:onClickResetDefaults()
    local defaults = WoodHarvesterMeasurement.defaults
    self.cutLengthMin:setText(string.format("%.1f", defaults.cutLengthMin))
    self.cutLengthMax:setText(string.format("%.1f", defaults.cutLengthMax))
    self.cutLengthStep:setText(string.format("%.1f", defaults.cutLengthStep))

    local def = json.decode(WoodHarvesterMeasurement.defaultRadiusThresholds)
    if def then
        self.pineLogMinRadius:setText(tostring(math.floor(def.pineLogMinRadius / 0.01)))
        self.pineShortMinRadius:setText(tostring(math.floor(def.pineShortMinRadius / 0.01)))
        self.pinePulpwoodMinRadius:setText(tostring(math.floor(def.pinePulpwoodMinRadius / 0.01)))
        self.spruceLogMinRadius:setText(tostring(math.floor(def.spruceLogMinRadius / 0.01)))
        self.spruceShortMinRadius:setText(tostring(math.floor(def.spruceShortMinRadius / 0.01)))
        self.sprucePulpwoodMinRadius:setText(tostring(math.floor(def.sprucePulpwoodMinRadius / 0.01)))
    end
end

function SettingsController:onClickResetStand()
    WoodHarvesterMeasurement.resetStand(self.model)
    self:updateStatsValues()
end

function SettingsController:onClickHudPosition(state) end

function SettingsController:onClickBack()
    g_gui:closeDialogByName("WoodHarvesterMeasurement_UI")
end

function SettingsController:onClickSyncWHC()
    local model = self.model
    if not model then
        return
    end

    if model.spec_woodHarvesterControls ~= nil then
        local whSpec = model.spec_woodHarvester

        local logDia = math.floor((whSpec.bucking[1].minDiameter or 0) * 100)
        local shortDia = math.floor((whSpec.bucking[2].minDiameter or 0) * 100)
        local pulpDia = math.floor((whSpec.bucking[3].minDiameter or 0) * 100)

        self.pineLogMinRadius:setText(tostring(logDia))
        self.pineShortMinRadius:setText(tostring(shortDia))
        self.pinePulpwoodMinRadius:setText(tostring(pulpDia))

        self.spruceLogMinRadius:setText(tostring(logDia))
        self.spruceShortMinRadius:setText(tostring(shortDia))
        self.sprucePulpwoodMinRadius:setText(tostring(pulpDia))
    else
        g_gui:closeDialogByName("WoodHarvesterMeasurement_UI")
        g_currentMission:showBlinkingWarning("Wood Harvester Controls mod not active for savegame!", 2500)
    end
end
