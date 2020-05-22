-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/9/2020, 1:02:09 PM

---@type ns
local ns = select(2, ...)

local CIS = LibStub('LibClassicItemSets-1.0')

local ipairs = ipairs
local tonumber = tonumber
local format = string.format

local GetItemInfo = GetItemInfo
local GetRealmName = GetRealmName
local UnitFullName = UnitFullName

local GameTooltip = GameTooltip

local SPELL_PASSIVE = SPELL_PASSIVE
local ITEM_SET_BONUS_GRAY_P = '^' .. ITEM_SET_BONUS_GRAY:gsub('%%s', '(.+)'):gsub('%(%%d%)', '%%((%%d+)%%)') .. '$'

function ns.strcolor(str, r, g, b)
    return format('|cff%02x%02x%02x%s|r', r * 255, g * 255, b * 255, str)
end

function ns.ItemLinkToId(link)
    return link and (tonumber(link) or tonumber(link:match('item:(%d+)')))
end

function ns.GetFullName(name, realm)
    if not name then
        return
    end
    if name:find('-', nil, true) then
        return name
    end

    if not realm or realm == '' then
        realm = GetRealmName()
    end
    return name .. '-' .. realm
end

function ns.UnitName(unit)
    return ns.GetFullName(UnitFullName(unit))
end

local summaryCache = {}
function ns.GetTalentSpellSummary(spellId)
    if summaryCache[spellId] == nil then
        local TipScaner = ns.TipScaner
        TipScaner:Clear()
        TipScaner:SetSpellByID(spellId)

        local n = TipScaner:NumLines()
        local passive
        for i = 1, n do
            if TipScaner.L[i]:GetText() == SPELL_PASSIVE then
                passive = true
                break
            end
        end

        if not passive then
            summaryCache[spellId] = false
        elseif n > 2 then
            summaryCache[spellId] = TipScaner.L[n]:GetText()
        end
    end
    return summaryCache[spellId]
end

function ns.IsTalentPassive(spellId)
    return ns.GetTalentSpellSummary(spellId) == false
end

function ns.FixInspectItemTooltip()
    local id = ns.ItemLinkToId(select(2, GameTooltip:GetItem()))
    if not id then
        return
    end

    local setId = CIS:GetItemSetForItemID(id)
    if not setId then
        return
    end

    local setName = CIS:GetSetName(setId)
    if not setName then
        return
    end

    local items = CIS:GetItems(setId)
    if not items then
        return
    end

    local itemNames = {}
    local equippedCount = 0
    for _, itemId in ipairs(items) do
        if ns.Inspect:IsItemEquipped(itemId) then
            local name = GetItemInfo(itemId)
            if not name then
                return
            end
            itemNames[name] = true
            equippedCount = equippedCount + 1
        end
    end

    local setLine
    local itemsCount = #items

    for i = 2, GameTooltip:NumLines() do
        local textLeft = _G['GameTooltipTextLeft' .. i]
        local text = textLeft:GetText()

        if not setLine then
            local prefix, n, maxCount, suffix = text:match('^(' .. setName .. '.+)(%d+)/(%d+)(.+)$')
            if prefix then
                setLine = i
                textLeft:SetText(prefix .. equippedCount .. '/' .. maxCount .. suffix)
            end
        elseif i - setLine <= itemsCount then
            if itemNames[text:trim()] then
                textLeft:SetTextColor(1, 1, 0.6)
            else
                textLeft:SetTextColor(0.5, 0.5, 0.5)
            end
        else
            local count, summary = text:match(ITEM_SET_BONUS_GRAY_P)
            if count then
                if equippedCount >= tonumber(count) then
                    textLeft:SetText(ITEM_SET_BONUS:format(summary))
                    textLeft:SetTextColor(0.1, 1, 0.1)
                else
                    textLeft:SetTextColor(0.5, 0.5, 0.5)
                end
            end
        end
    end

    GameTooltip:Show()
end
