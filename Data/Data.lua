-- DataApi.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/25/2020, 4:43:38 PM
---@type ns
local ns = select(2, ...)

ns.Talents = {}
ns.ItemSets = {}

local T = ns.memorize(function(v)
    local t = {strsplit('/', v)}
    for i, v in ipairs(t) do
        t[i] = tonumber(v)
    end
    return t
end)

function ns.TalentMake()
    ns.TalentMake = nil

    local CURRENT

    local function CreateClass(classFileName)
        CURRENT = {}
        ns.Talents[classFileName] = CURRENT
    end

    local function CreateTab(background, numTalents)
        tinsert(CURRENT, {background = background, numTalents = numTalents, talents = {}})
    end

    local function CreateTalentInfo(row, column, maxRank)
        local tab = CURRENT[#CURRENT]
        tinsert(tab.talents, {row = row, column = column, maxRank = maxRank})
    end

    local function FillTalentRanks(ranks)
        local tab = CURRENT[#CURRENT]
        local talent = tab.talents[#tab.talents]
        talent.ranks = ranks
    end

    local function FillTalentPrereq(row, column, reqIndex)
        local tab = CURRENT[#CURRENT]
        local talent = tab.talents[#tab.talents]
        talent.prereqs = talent.prereqs or {}
        tinsert(talent.prereqs, {row = row, column = column, reqIndex = reqIndex})
    end

    local function SetTabName(locale, name)
        local tab = CURRENT[#CURRENT]
        if tab.name and locale ~= GetLocale() then
            return
        end
        tab.name = name
    end

    setfenv(2, {
        C = CreateClass,
        T = CreateTab,
        I = CreateTalentInfo,
        R = FillTalentRanks,
        P = FillTalentPrereq,
        N = SetTabName,
    })
end

function ns.ItemSetMake()
    ns.ItemSetMake = nil

    local SLOTS = {
        [0] = 'INVTYPE_NON_EQUIP',
        [1] = 'INVTYPE_HEAD',
        [2] = 'INVTYPE_NECK',
        [3] = 'INVTYPE_SHOULDER',
        [4] = 'INVTYPE_BODY',
        [5] = 'INVTYPE_CHEST',
        [6] = 'INVTYPE_WAIST',
        [7] = 'INVTYPE_LEGS',
        [8] = 'INVTYPE_FEET',
        [9] = 'INVTYPE_WRIST',
        [10] = 'INVTYPE_HAND',
        [11] = 'INVTYPE_FINGER',
        [12] = 'INVTYPE_TRINKET',
        [13] = 'INVTYPE_WEAPON',
        [14] = 'INVTYPE_SHIELD',
        [15] = 'INVTYPE_RANGED',
        [16] = 'INVTYPE_CLOAK',
        [17] = 'INVTYPE_2HWEAPON',
        [18] = 'INVTYPE_BAG',
        [19] = 'INVTYPE_TABARD',
        [20] = 'INVTYPE_ROBE',
        [21] = 'INVTYPE_WEAPONMAINHAND',
        [22] = 'INVTYPE_WEAPONOFFHAND',
        [23] = 'INVTYPE_HOLDABLE',
        [24] = 'INVTYPE_AMMO',
        [25] = 'INVTYPE_THROWN',
        [26] = 'INVTYPE_RANGEDRIGHT',
        [27] = 'INVTYPE_QUIVER',
        [28] = 'INVTYPE_RELIC',
    }

    local CURRENT

    local function CreateItemSet(setId)
        local db = {slots = {}}
        ns.ItemSets[setId] = db
        CURRENT = db
    end

    local function SetItemSetBouns(bouns)
        CURRENT.bouns = T(bouns)
    end

    local function SetItemSetSlotItem(slot, itemId)
        slot = SLOTS[slot]
        CURRENT.slots[slot] = CURRENT.slots[slot] or {}
        CURRENT.slots[slot][itemId] = true
    end

    setfenv(2, { --
        S = CreateItemSet,
        B = SetItemSetBouns,
        I = SetItemSetSlotItem,
    })
end
