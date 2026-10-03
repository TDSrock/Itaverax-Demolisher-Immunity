-- Itaverax Segmented Unit Immunity
--
-- Abacayba: Infested Death Twin of Nauvis applies "itaverax" melee damage to all
-- SegmentedUnitPrototype entities (vanilla demolishers included), but vanilla
-- demolisher resistances were authored before this damage type existed, so they
-- take full unmitigated damage from their own attacks and self-destruct.
--
-- This mod mirrors Abacayba's own blanket application: it grants 100% itaverax
-- resistance to every segmented-unit and segment prototype in the game, the same
-- way Abacayba itself applies the damage type to every segmented-unit/segment.
--
-- This is a temporary stopgap. Abacayba's author (emerson5442) is aware of the
-- underlying issue and intends to ship a proper fix; once that lands, this mod
-- can be disabled/removed.

-- Safety check: only act if the itaverax damage type actually exists.
-- (It always will, since Abacayba is a hard dependency of this mod -- but this
-- keeps the mod from erroring out if that ever changes.)
if not data.raw["damage-type"] or not data.raw["damage-type"]["itaverax"] then
    return
end

local function add_itaverax_immunity(prototype)
    if not prototype.resistances then
        prototype.resistances = {}
    end

    for _, resistance in pairs(prototype.resistances) do
        if resistance.type == "itaverax" then
            -- Already has an entry (e.g. another mod set one) -- don't override it.
            return
        end
    end

    table.insert(prototype.resistances, {
        type = "itaverax",
        percent = 100
    })
end

local categories = { "segmented-unit", "segment" }

for _, category in pairs(categories) do
    if data.raw[category] then
        for _, prototype in pairs(data.raw[category]) do
            add_itaverax_immunity(prototype)
        end
    end
end
