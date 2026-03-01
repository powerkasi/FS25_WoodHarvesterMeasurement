--[[
	Tree.lua
	Author: powerkasi, DiscoFlower8890
]]

Species = {
    OTHER = 0,
    PINE = 1, -- mänty
    SPRUCE = 2, -- kuusi
    BIRCH = 3 -- koivu
}

SplitTypes = {
    UNKNOWN = 0,
    LOG = 1,
    SHORTWOOD = 2,
    PULPWOOD = 8 -- why 8 here?
}

Tree = {
    specie = Species.OTHER,
    totalCubeMetre = 0,
    totalLength = 0,
    splitCount = 0,
    splits = {}
}

function Tree:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.specie = o.specie or self.specie
    o.totalCubeMetre = o.totalCubeMetre or self.totalCubeMetre
    o.totalLength = o.totalLength or self.totalLength
    o.splitCount = o.splitCount or self.splitCount
    o.splits = o.splits or self.splits
    return o
end

function Tree:addSplit(split)
    table.insert(self.splits, split);
    self.totalCubeMetre = self.totalCubeMetre + split.cubeMetre
    self.totalLength = self.totalLength + split.length
    self.splitCount = self.splitCount + 1
end

function Tree.specieToString(specie)
    if specie == Species.PINE then
        return "Pine"
    elseif specie == Species.SPRUCE then
        return "Spruce"
    elseif specie == Species.BIRCH then
        return "Birch"
    else
        return "Other"
    end
end

function Tree.splitTypeToString(specie)
    if specie == SplitTypes.LOG then
        return "Log"
    elseif specie == SplitTypes.SHORTWOOD then
        return "Short"
    elseif specie == SplitTypes.PULPWOOD then
        return "Pulpwood"
    else
        return "Unknown"
    end
end

return Tree
