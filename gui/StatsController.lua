--[[
	StatsController.lua
	Author: powerkasi, DiscoFlower8890
]]

StatsController = {}
local StatsController_mt = Class(StatsController, DialogElement)

function StatsController.new(modName, model)
    local self = DialogElement.new(nil, StatsController_mt)
    self.modName = modName
    self.model = model
    self.i18n = g_i18n
    return self
end

function StatsController:onOpen()
    StatsController:superClass().onOpen(self)
    self:applyAlternatingRowColors()
    self:updateStatsValues()
end

function StatsController:applyAlternatingRowColors()
    local columns = {self.countColumn, self.volumeColumn}
    
    for _, column in ipairs(columns) do
        if column and (column.elements or column.children) then
            local elements = column.elements or column.children
            local alternate = false
            for _, element in ipairs(elements) do
                if element.setImageColor and element:getIsVisible() and element.profile == "fs25_multiTextOptionContainer" then
                    local r, g, b, a = unpack(SettingsScreen.COLOR_ALTERNATING[alternate])
                    element:setImageColor(nil, r, g, b, a)
                    alternate = not alternate
                end
            end
        end
    end
end

function StatsController:updateStatsValues()
    local model = self.model
    if model == nil then return end
    local meas = model.spec_woodHarvesterMeasurement

    local stand = json.decode(meas.currentStand)
    local set = function(id, value, suffix)
        local element = self[id]
        if element ~= nil then
            if value then
                element:setText(suffix and string.format("%0.2f%s", value, suffix) or tostring(value))
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
    set("splitCountOtherLogStand", stand.splitCountOtherLogStand)
    set("splitCountOtherShortStand", stand.splitCountOtherShortStand)
    set("splitCountOtherPulpwoodStand", stand.splitCountOtherPulpwoodStand)
    set("splitCountStand", stand.splitCountStand)

    set("cubicMetrePineLogStand", stand.cubicMetrePineLogStand, " m³")
    set("cubicMetrePineShortStand", stand.cubicMetrePineShortStand, " m³")
    set("cubicMetrePinePulpwoodStand", stand.cubicMetrePinePulpwoodStand, " m³")
    set("cubicMetreSpruceLogStand", stand.cubicMetreSpruceLogStand, " m³")
    set("cubicMetreSpruceShortStand", stand.cubicMetreSpruceShortStand, " m³")
    set("cubicMetreSprucePulpwoodStand", stand.cubicMetreSprucePulpwoodStand, " m³")
    set("cubicMetreOtherLogStand", stand.cubicMetreOtherLogStand, " m³")
    set("cubicMetreOtherShortStand", stand.cubicMetreOtherShortStand, " m³")
    set("cubicMetreOtherPulpwoodStand", stand.cubicMetreOtherPulpwoodStand, " m³")
    set("cubicMetreStand", stand.cubicMetreStand, " m³")
end

function StatsController:onClickSettings()
    self:close()
    g_gui:showDialog("WoodHarvesterMeasurement_UI_SETTINGS")
end

function StatsController:onClickResetStand()
    WoodHarvesterMeasurement.resetStand(self.model)
    self:updateStatsValues()
end

function StatsController:onClickBack()
    self:close()
end