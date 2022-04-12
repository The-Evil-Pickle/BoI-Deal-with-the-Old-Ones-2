local	mod = RegisterMod( "Limbo Deals", 1);
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
local function shuffle(tbl)
  size = #tbl
  for i = size, 1, -1 do
    local rand = math.random(size)
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
  return tbl
end
local   rng = RNG()
local   sfxManager = SFXManager()
local	icarus_item = Isaac.GetItemIdByName("Wings of Icarus")
local	sandals_item = Isaac.GetItemIdByName("Sandals")
local   confusion_item = Isaac.GetItemIdByName("Confusion")
local   paw_item = Isaac.GetItemIdByName("Rabbit's Paw")
local   map_item = Isaac.GetItemIdByName("Cursed Map")
local   mirror_item = Isaac.GetItemIdByName("Broken Mirror")
local 	compass_item = Isaac.GetItemIdByName("Broken Compass")
local 	battery_item = Isaac.GetItemIdByName("Leaking Battery")
local   prize_item = Isaac.GetItemIdByName("Participation Award")
local   brush_item = Isaac.GetItemIdByName("Red Brush")
local   head_item = Isaac.GetItemIdByName("Ancient's Head")
local	unknown_item = Isaac.GetItemIdByName("QMK>?")
local   redsea_item = Isaac.GetItemIdByName("Red Sea")
local	sack_item = Isaac.GetItemIdByName("Empty Sack")
local	deal_item = Isaac.GetItemIdByName("Contract with Ultra Greed")
local	scope_item = Isaac.GetItemIdByName("Strange Kaleidoscope")
local	belt_item = Isaac.GetItemIdByName("White Belt")
local   hyperfocus_item = Isaac.GetItemIdByName("Tunnel Vision")
local	quantumrock_item = Isaac.GetItemIdByName("Quantum Rock")
local	toothless_item = Isaac.GetItemIdByName("Toothless Key")
local	wormbox_item = Isaac.GetItemIdByName("Worm Farm")
local	runestone_item = Isaac.GetItemIdByName("Black Runestone")
local	metaldetect_item = Isaac.GetItemIdByName("Dead Metal Detector")
local	wormcan_item = Isaac.GetItemIdByName("Opened Can of Worms")



local	costumehandler = {}
costumehandler[#costumehandler+1] = {
	item = icarus_item,
	costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_wings_of_icarus.anm2"),
	hasit = false
}
costumehandler[#costumehandler+1] = {
	item = brush_item,
	costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_red_brush.anm2"),
	hasit = false
}
costumehandler[#costumehandler+1] = {
	item = confusion_item,
	costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_confusion.anm2"),
	hasit = false
}

local   icarus_costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_wings_of_icarus.anm2")
local   haswings = false
local   brush_costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_red_brush.anm2")
local 	hasbrush = false

local   beetle_trinket = Isaac.GetTrinketIdByName( "Dead Beetle" )
local	pebble_trinket = Isaac.GetTrinketIdByName( "Ancient Pebble" )
local	nail_trinket = Isaac.GetTrinketIdByName( "Red-Hot Nail" )

local	stone_item = Isaac.GetCardIdByName("Aurum")

local   tomb_curse = 2 ^ (Isaac.GetCurseIdByName("Curse of the Tomb")-1)

local   water_challenge = Isaac.GetChallengeIdByName("Troubling Waters")

local   jahaziel_costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_jahaziel.anm2")

local 	limbo_theme = Isaac.GetMusicIdByName("Limbo Deal Room")
local 	limbo_boss_theme = Isaac.GetMusicIdByName("Limbo Deal Fight")
local	limbo_door_sfx = 129--Isaac.GetSoundIdByName("Secret Room Find (jingle)")

local doorvariant = 11340
local chestvariant = 11340
local sackvariant = 11340
local trickvariant = 11344
local reflectorvariant = 11344

local limboroomtype = RoomType.ROOM_ANGEL--RoomType.ROOM_ERROR
--[[
	currently either RoomType.ROOM_ERROR or RoomType.ROOM_ANGEL are best, but RoomType.ROOM_DEVIL works as well.
]]

local inlimbo = false
local bossDoorState = {}
local hassetup = false

local tombroom = false
local tombtimer = 0
local tombloot = 0

local brushtimer = 0
local brushlimit = 500
local brushduration = 180
local brushpickupallowed = true
local playerhastakendamage = false

local qmmax = 2
local qmcounter = qmmax

local builtdeal = false

local sackdumplist = {}

local o_room_basechance = {Value = function() return 1 end}

local o_pool_cursedeye = {Value = function() return 7 end}
local o_pool_curseofthetower = {Value = function() return 9 end}
local o_pool_chaos = {Value = function() return 8 end}
local o_pool_bobsbrain = {Value = function() return 5 end}
local o_pool_brokenwatch = {Value = function() return 6 end}
local o_pool_icarus = {Value = function() return 10 end}
local o_pool_sandals = {Value = function() return 10 end}
local o_pool_confusion = {Value = function() return 10 end}
local o_pool_paw = {Value = function() return 10 end}
local o_pool_map = {Value = function() return 10 end}
local o_pool_battery = {Value = function() return 10 end}
local o_pool_mirror = {Value = function() return 10 end}
local o_pool_brush = {Value = function() return 10 end}
local o_pool_compass = {Value = function() return 3 end}
local o_pool_prize = {Value = function() return 7 end}
local o_pool_unknown = {Value = function() return 6 end}
local o_pool_redsea = {Value = function() return 10 end}
local o_pool_sack = {Value = function() return 10 end}
local o_pool_deal = {Value = function() return 10 end}
local o_pool_scope = {Value = function() return 10 end}
local o_pool_quantum = {Value = function() return 10 end}
local o_pool_toothless = {Value = function() return 10 end}
local o_pool_wormbox = {Value = function() return 9 end}
local o_pool_wormcan = {Value = function() return 9 end}
local o_pool_modded = {Value = function() return 8 end}

local o_tomb_procChance = {Value = function() return 0.33 end}--chance for rooms to reset through tomb of the curse
local o_tomb_increaseRoomCount = {Value = function() return 3 end}--rooms with no tomb reset before tomb chance starts increasing

local o_brush_heartchance = {Value = function() return 1 end}
local o_brush_procchance = {Value = function() return 1 end}
local o_brush_timer = {Value = function() return 600 end}
local o_brush_1x1chance = {Value = function() return 0.6 end}

local o_jahaziel_perthro = {Value = function() return false end}
local o_jahaziel_store_credit = {Value = function() return false end}
local o_jahaziel_chests = {Value = function() return 2 end}

local o_deal_doublechance = {Value = function() return 0.5 end}
local o_deal_greedchance = {Value = function() return 0.67 end}
local o_deal_losschance = {Value = function() return 0.75 end}

local o_mirror_treasure = {Value = function() return 1 end}
local o_mirror_boss = {Value = function() return 0.5 end}
local o_mirror_shop = {Value = function() return 0.5 end}
local o_mirror_curse = {Value = function() return 0 end}
local o_mirror_challenge = {Value = function() return 0.65 end}
local o_mirror_devil = {Value = function() return 0.2 end}
local o_mirror_angel = {Value = function() return 0.3 end}

local o_music_room = {Value = function() return "Limbo Deal Room" end}
local o_music_fight = {Value = function() return "Limbo Deal Fight" end}

local o_quantum_dmg = {Value = function() return 0.5 end}

local function BuildSounds()
	limbo_theme = Isaac.GetMusicIdByName(o_music_room:Value())
	limbo_boss_theme = Isaac.GetMusicIdByName(o_music_fight:Value())
end

local function StartOptionsAPI()
	local modname = "Limbo Deals"
	optionsmod.RegisterMod(modname, {"General", "Item Pool", "Jahaziel", "Broken Mirror", "Red Brush", "Deal w/ Ultra Greed", "Tomb"})--, "Item Balance", "Tomb", "Jahaziel"
	
	o_room_basechance = optionsmod.RegisterNewSetting({
		name = "Deal Chance Multiplier",
		description = "Multiplier for chance of deal opening after boss is defeated.",
		type = "percent",
		category = "General",
		min = 0,
		max = 5,
		adjustRate = 0.1,
		default = 1
	})
	
	o_music_room = optionsmod.RegisterNewSetting({
		modname = modname,
		name = "Room Music",
		description = "Background music to play in deal rooms.",
		category = "General",
		options = {
		{"Default Track", "Limbo Deal Room"},
		{"Angel Room", "Angel Room"},
		{"Devil Room", "Devil Room"},
		{"Secret Room", "Secret Room"},
		{"Library", "Library Room"},
		{"Void", "Void"}
		},
		default = 1,
		OnChanged = BuildSounds
	})
	o_music_fight = optionsmod.RegisterNewSetting({
		modname = modname,
		name = "Fight Music",
		description = "Background music to play during ancient one fights.",
		category = "General",
		options = {
		{"Default Track", "Limbo Deal Fight"},
		{"Generic Boss Theme", "Boss"},
		{"??? Theme", "Boss (Chest - ???)"},
		{"Satan Theme", "Boss (Sheol - Satan)"},
		{"Lamb Theme", "Boss (Dark Room)"},
		{"Hush Theme", "Boss (Blue Womb - Hush)"},
		{"Ultra Greed Theme", "Boss (Ultra Greed)"},
		{"Delirium Theme", "Boss (Void)"}
		},
		default = 1,
		OnChanged = BuildSounds
	})
	
	o_deal_greedchance = optionsmod.RegisterNewSetting({
		name = "Coin Drop Chance",
		description = "Chance for player to drop coins when taking damage.",
		type = "percent",
		category = "Deal w/ Ultra Greed",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 0.65
	})
	o_deal_doublechance = optionsmod.RegisterNewSetting({
		name = "Coin Doubling Chance",
		description = "Chance for pennies to spawn as double packs.",
		type = "percent",
		category = "Deal w/ Ultra Greed",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 0.5
	})
	o_deal_losschance = optionsmod.RegisterNewSetting({
		name = "Coin Drop Chance",
		description = "Chance for a coin to be lost completely when taking damage (rather than just dropping on floor).",
		type = "percent",
		category = "Deal w/ Ultra Greed",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 0.75
	})
	
	o_brush_heartchance = optionsmod.RegisterNewSetting({
		name = "Heart Drop Chance",
		description = "Chance for a heart to drop at the end of the brush event (halved if player has taken damage).",
		type = "percent",
		category = "Red Brush",
		min = 0,
		max = 2,
		adjustRate = 0.1,
		default = 1
	})
	o_brush_timer = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Timer",
		description = "How often the brush event will try to start.",
		category = "Red Brush",
		adjustRate = 15,
		min = 45,
		max = 3000,
		default = 600,
		displayMultiplier = (1/30)
	})
	o_brush_procchance = optionsmod.RegisterNewSetting({
		name = "Event Start Chance",
		description = "Chance for the event to start when timer triggers (in big rooms).",
		type = "percent",
		category = "Red Brush",
		min = 0,
		max = 1.5,
		adjustRate = 0.05,
		default = 1
	})
	o_brush_1x1chance = optionsmod.RegisterNewSetting({
		name = "1x1 room chance multiplier",
		description = "Proc chance is multiplied by this when in a 1x1 room.",
		type = "percent",
		category = "Red Brush",
		min = 0,
		max = 2,
		adjustRate = 0.05,
		default = 0.6
	})
	
	o_jahaziel_perthro = optionsmod.RegisterNewSetting({
		name = "Start with Perthro",
		description = "Jahaziel starts with a perthro rune.",
		type = "toggle",
		category = "Jahaziel",
		default = false
	})
	o_jahaziel_store_credit = optionsmod.RegisterNewSetting({
		name = "Start with Store Credit",
		description = "Jahaziel starts with a store credit trinket.",
		type = "toggle",
		category = "Jahaziel",
		default = false
	})
	
	o_jahaziel_chests = optionsmod.RegisterNewSetting({
		name = "Starting Chests",
		description = "Chests that spawn on the first room of a Jahaziel run.",
		category = "Jahaziel",
		options = {{"None", 0}, {"Random", 1}, {"Golden key/bomb", 2}},
		default = 3
	})
	
	o_tomb_procChance = optionsmod.RegisterNewSetting({
		name = "Proc Chance",
		description = "Chance for Curse of the Tomb to restart rooms.",
		type = "percent",
		category = "Tomb",
		min = 0,
		max = 1,
		adjustRate = 0.025,
		default = 0.325
	})
	o_tomb_increaseRoomCount = optionsmod.RegisterNewSetting({
		name = "Increase After",
		description = "Chance for the curse to restart rooms increases after this many rooms with no restart.",
		type = "value",
		category = "Tomb",
		min = 0,
		max = 10,
		adjustRate = 1,
		default = 3
	})
	
	o_mirror_treasure = optionsmod.RegisterNewSetting({
		name = "Treasure Room",
		description = "Chance for Broken Mirror to change treasure room items.",
		type = "percent",
		category = "Broken Mirror",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 1
	})
	o_mirror_boss = optionsmod.RegisterNewSetting({
		name = "Boss Room",
		description = "Chance for Broken Mirror to change boss room items.",
		type = "percent",
		category = "Broken Mirror",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 0.5
	})
	o_mirror_shop = optionsmod.RegisterNewSetting({
		name = "Shop",
		description = "Chance for Broken Mirror to change shop items.",
		type = "percent",
		category = "Broken Mirror",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 0.5
	})
	o_mirror_curse = optionsmod.RegisterNewSetting({
		name = "Curse Room",
		description = "Chance for Broken Mirror to change curse room items.",
		type = "percent",
		category = "Broken Mirror",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 0
	})
	o_mirror_challenge = optionsmod.RegisterNewSetting({
		name = "Challenge Room",
		description = "Chance for Broken Mirror to change challenge room items.",
		type = "percent",
		category = "Broken Mirror",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 0.65
	})
	o_mirror_devil = optionsmod.RegisterNewSetting({
		name = "Devil Deal",
		description = "Chance for Broken Mirror to change devil deal items.",
		type = "percent",
		category = "Broken Mirror",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 0.2
	})
	o_mirror_angel = optionsmod.RegisterNewSetting({
		name = "Angel Deal",
		description = "Chance for Broken Mirror to change angel deal items.",
		type = "percent",
		category = "Broken Mirror",
		min = 0,
		max = 1,
		adjustRate = 0.05,
		default = 0.3
	})
	
	o_pool_cursedeye = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Cursed Eye",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 7
	})
	o_pool_curseofthetower = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Curse of the Tower",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 9
	})
	o_pool_chaos = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Chaos",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 8
	})
	o_pool_bobsbrain = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Bob's Brain",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 5
	})
	o_pool_brokenwatch = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Broken Stopwatch",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 6
	})
	o_pool_icarus = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Wings of Icarus",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_sandals = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Sandals",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_confusion = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Confusion",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_paw = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Rabbit's Paw",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_map = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Cursed Map",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_battery = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Leaking Battery",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_mirror = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Broken Mirror",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_brush = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Red Brush",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_compass = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Broken Compass",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 3
	})
	o_pool_prize = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Participation Award",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 7
	})
	o_pool_unknown = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "QMK>?",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 6
	})
	o_pool_redsea = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Red Sea",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_sack = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Empty Sack",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_deal = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Contract with Ultra Greed",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_scope = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Strange Kaleidoscope",
		description = "Weight of this item in limbo room item pool. Higher = more common.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 10
	})
	o_pool_modded = optionsmod.RegisterNewSetting({
		modname = modname,
		type = "value",
		name = "Modded Items",
		description = "Weight of compatible items from other mods.",
		category = "Item Pool",
		adjustRate = 1,
		min = 0,
		max = 25,
		default = 8
	})
	
	
end



local secondarypooltrigger = 6

if ANCIENT_DEAL_MOD_ITEM_POOL == nil then ANCIENT_DEAL_MOD_ITEM_POOL = {} end
if ANCIENT_DEAL_MOD_ITEM_POOL_2 == nil then ANCIENT_DEAL_MOD_ITEM_POOL_2 = {} end

local supportedModdedItems = {
"Pickpocket",
"Satan's Contract",
"The First Plague",
"Capripio"
}
local secondarySupportedModdedItems = {
{"Cursed D6", 3},
{"Birth Control", 3},
{"Beer Can", 2},
{"Ligo", 4}
}
for i, t in ipairs(supportedModdedItems) do
	ANCIENT_DEAL_MOD_ITEM_POOL[#ANCIENT_DEAL_MOD_ITEM_POOL + 1] = t
end
for i, t in ipairs(secondarySupportedModdedItems) do
	ANCIENT_DEAL_MOD_ITEM_POOL_2[#ANCIENT_DEAL_MOD_ITEM_POOL_2 + 1] = t
end


local LimboItemPool = {}
local SecondaryItemPool = {}


local function BuildLimboPool()
	LimboItemPool = {
		{CollectibleType.COLLECTIBLE_CURSED_EYE, o_pool_cursedeye:Value()},
		{CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER, o_pool_curseofthetower:Value()},
		{CollectibleType.COLLECTIBLE_CHAOS, o_pool_chaos:Value()},
		{CollectibleType.COLLECTIBLE_BOBS_BRAIN, o_pool_bobsbrain:Value()},
		{CollectibleType.COLLECTIBLE_BROKEN_WATCH, o_pool_brokenwatch:Value()},
		{icarus_item, o_pool_icarus:Value()},
		{sandals_item, o_pool_sandals:Value()},
		{confusion_item, o_pool_confusion:Value()},
		{paw_item, o_pool_paw:Value()},
		{map_item, o_pool_map:Value()},
		{mirror_item, o_pool_mirror:Value()},
		{compass_item, o_pool_compass:Value()},
		{battery_item, o_pool_battery:Value()},
		{prize_item, o_pool_prize:Value()},
		{brush_item, o_pool_brush:Value()},
		{unknown_item, o_pool_unknown:Value()},
		{redsea_item, o_pool_redsea:Value()},
		{sack_item, o_pool_sack:Value()},
		{deal_item, o_pool_deal:Value()},
		{scope_item, o_pool_scope:Value()},
		{quantumrock_item, o_pool_quantum:Value()},
		{toothless_item, o_pool_toothless:Value()},
		{wormbox_item, o_pool_wormbox:Value()},
		{wormcan_item, o_pool_wormcan:Value()}
	}
	local eternalcurse = Isaac.GetCurseIdByName("Curse of Eternity")
	if eternalcurse ~= nil and eternalcurse > 0 then
		LimboItemPool[#LimboItemPool+1] = {belt_item, o_pool_modded:Value()}
	end
	for _, i in ipairs(ANCIENT_DEAL_MOD_ITEM_POOL) do
		local modded_item = Isaac.GetItemIdByName(i)
		if modded_item ~= nil and modded_item > 0 then
			LimboItemPool[#LimboItemPool + 1] = {modded_item, o_pool_modded:Value()}
		end
	end
	SecondaryItemPool = {
		{CollectibleType.COLLECTIBLE_MY_REFLECTION, 5},
		{CollectibleType.COLLECTIBLE_TINY_PLANET, 1},
		{CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT, 5},
		{CollectibleType.COLLECTIBLE_SOY_MILK, 1},
		{CollectibleType.COLLECTIBLE_EVES_MASCARA, 5},
		{CollectibleType.COLLECTIBLE_DUALITY, o_pool_compass:Value()},
		{CollectibleType.COLLECTIBLE_FIRE_MIND, 3},
		{CollectibleType.COLLECTIBLE_THE_WIZ, 5},
		{CollectibleType.COLLECTIBLE_MARKED, 5},
		{CollectibleType.COLLECTIBLE_NUMBER_ONE, 5},
		{CollectibleType.COLLECTIBLE_CHAMPION_BELT, 3},
		{metaldetect_item, 5}
	}
	for _, i in ipairs(ANCIENT_DEAL_MOD_ITEM_POOL_2) do
		local modded_item = Isaac.GetItemIdByName(i[1])
		if modded_item ~= nil and modded_item > 0 then
			SecondaryItemPool[#SecondaryItemPool + 1] = i
		end
	end
end
BuildLimboPool()
local ActiveLimboItemPool = deepcopy(LimboItemPool)
local function BuildActiveLimboPool()
	ActiveLimboItemPool = deepcopy(LimboItemPool)
	local player = Isaac.GetPlayer(0)
	if player ~= nil then
		local amount = #ActiveLimboItemPool
		for _i, _p in ipairs(ActiveLimboItemPool) do
			if player:HasCollectible(_p[1]) 
			or (_p[1] == CollectibleType.COLLECTIBLE_CHAOS and player:HasCollectible(mirror_item)) 
			or (_p[1] == brush_item and player:HasCollectible(sandals_item))
			or (_p[1] == sandals_item and player:HasCollectible(brush_item))
			then
				if _p[1] == prize_item then
					_p[2] = 1
				else
					_p[2] = 0
				end
				amount = amount - 1
			end
		end
		if amount <= secondarypooltrigger then
			for _i, _p in ipairs(SecondaryItemPool) do
				if not player:HasCollectible(_p[1]) then
					ActiveLimboItemPool[#ActiveLimboItemPool + 1] = deepcopy(_p)
				end
			end
		end
	end
end

local LimboTrinketPool = {
	{TrinketType.TRINKET_BROKEN_REMOTE, 5},
	{TrinketType.TRINKET_PURPLE_HEART, 5},
	{TrinketType.TRINKET_RING_WORM, 2},
	{TrinketType.TRINKET_MOMS_TOENAIL, 5},
	{TrinketType.TRINKET_HOOK_WORM, 3},
	{TrinketType.TRINKET_CURSED_SKULL, 5},
	{TrinketType.TRINKET_TICK, 5},
	{TrinketType.TRINKET_LEFT_HAND, 5},
	{TrinketType.TRINKET_RAINBOW_WORM, 5},
	{TrinketType.TRINKET_SUPER_MAGNET, 5},
	{TrinketType.TRINKET_ERROR, 6},
	{TrinketType.TRINKET_OUROBOROS_WORM, 4},
	{TrinketType.TRINKET_STORE_CREDIT, 3},
	{TrinketType.TRINKET_MISSING_POSTER, 6},
	{beetle_trinket, 7},
	{pebble_trinket, 7},
	{nail_trinket, 7}
}

local function SpawnLimboEntrance(room, st)
	sfxManager:Play(limbo_door_sfx, 1, 0, false, 1)
	return Isaac.Spawn(1000, doorvariant, st, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 16, true), Vector(0, 0), nil)
end

local function SpawnLimboDoor(room, st)
	for i=0, 7 do
		if room:IsDoorSlotAllowed(i) and room:GetDoor(i) == nil then
			local newent = Isaac.Spawn(1000, doorvariant, st, room:GetDoorSlotPosition(i), Vector(0,0), nil)
			local sprite = newent:GetSprite()
			if i % 4 == 0 then
				sprite.Rotation = -90
			elseif i % 4 == 1 then
				sprite.Rotation = 0
			elseif i % 4 == 2 then
				sprite.Rotation = 90
			elseif i % 4 == 3 then
				sprite.Rotation = 180
			end
			sprite.Offset = Vector(0, 16):Rotated(sprite.Rotation)
			sfxManager:Play(limbo_door_sfx, 1, 0, false, 1)
			--Isaac.DebugString("BOO!")
			return newent
		end
	end
	return SpawnLimboEntrance(room, 0)
end
local function getScreenCenterPosition()
    local room = Game():GetRoom()
    local centerOffset = (room:GetCenterPos()) - room:GetTopLeftPos()
    local pos = room:GetCenterPos()
    if centerOffset.X > 260 then
		pos.X = pos.X - 260
    end
    if centerOffset.Y > 140 then
        pos.Y = pos.Y - 140
    end
    return Isaac.WorldToRenderPosition(pos, false)
end

local function VectorToGrid(x,y)
	local room = Game():GetRoom()
	if room:GetRoomShape() == RoomShape.ROOMSHAPE_IH or room:GetRoomShape() == RoomShape.ROOMSHAPE_IIH then y=y-2
	elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_IV or room:GetRoomShape() == RoomShape.ROOMSHAPE_IIV then x=x-4 end
	return room:GetGridPosition(room:GetGridIndex(room:GetTopLeftPos()+Vector(x*40+20,y*40+20)))
end

local function CorrectGridType(Type)
	local tbl = {[1000]=2, [1001]=5, [1300]=12, [1497]=14, [1496]=14, [1495]=14, [1494]=14, [1490]=14, [1500]=14, [1900]=3, [1930]=8, [1931]=9, [1940]=10, [3000]=7, [4000]=11, [4500]=20, [9000]=17, [9100]=18, [10000]=19}
	if tbl[tonumber(Type)] == nil then
		return Type
	end
	return tbl[tonumber(Type)]
end

local function PositionInRoom(Vec)
	local room = Game():GetRoom()
	if Vec.X < room:GetTopLeftPos().X then Vec=Vector(room:GetTopLeftPos().X,Vec.Y) end
	if Vec.Y < room:GetTopLeftPos().Y then Vec=Vector(Vec.X,room:GetTopLeftPos().Y) end
	if Vec.Y > room:GetBottomRightPos().Y then Vec=Vector(Vec.X,room:GetBottomRightPos().Y) end
	if Vec.X > room:GetBottomRightPos().X then Vec=Vector(room:GetBottomRightPos().X,Vec.Y) end
	return Vec
end

local function TypeError(Function, Parameter, Expected, Got)
	if type(Expected) ~= type(Got) then
		Isaac.DebugString("Error with "..Function..": Bad argument #"..tostring(Parameter).." to '?' ("..type(Expected).." expected, got "..type(Got)..")")
		return false
	else return true end
end
local function ChangeBackdrop(Name, Variants)
	local game = Game()
	local room = game:GetRoom()
	Variants = Variants or 1
	if TypeError("ChangeBackdrop", 1, "", Name) and TypeError("ChangeBackdrop", 2, 0, Variants) then
		local npc = Isaac.Spawn(EntityType.ENTITY_EFFECT, 82, 0, Vector(0,0), Vector(0,0), nil)
		local sprite = npc:GetSprite()
		sprite:Load("gfx/backdrop/Backdrop_oldlimbo.anm2", true)
		for num=0, 15 do
			if Variants > 1 then 
				sprite:ReplaceSpritesheet(num, "gfx/backdrop/"..Name.."_"..tostring(math.random(Variants))..".png")
			else
				sprite:ReplaceSpritesheet(num, "gfx/backdrop/"..Name..".png")
			end
		end
		sprite:ReplaceSpritesheet(16, "gfx/backdrop/"..Name.."_nfloor.png")
		sprite:ReplaceSpritesheet(17, "gfx/backdrop/"..Name.."_nfloor.png")
		sprite:ReplaceSpritesheet(18, "gfx/backdrop/"..Name.."_lfloor.png")
		sprite:ReplaceSpritesheet(19, "gfx/backdrop/"..Name.."_lfloor.png")
		sprite:ReplaceSpritesheet(20, "gfx/backdrop/"..Name.."_lfloor.png")
		sprite:ReplaceSpritesheet(21, "gfx/backdrop/"..Name.."_lfloor.png")
		sprite:ReplaceSpritesheet(22, "gfx/backdrop/"..Name.."_lfloor.png")
		sprite:ReplaceSpritesheet(23, "gfx/backdrop/"..Name.."_corner.png")
		npc.Position = room:GetTopLeftPos()+Vector(260,0)
		if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x1 then sprite:Play("1x1_room", true)
		elseif room:GetRoomShape() ==  RoomShape.ROOMSHAPE_IH then sprite:Play("IH_room", true)
		elseif room:GetRoomShape() ==  RoomShape.ROOMSHAPE_IV then sprite:Play("IV_room", true)
		npc.Position = room:GetTopLeftPos()+Vector(113,0)
		elseif room:GetRoomShape() ==  RoomShape.ROOMSHAPE_1x2 then sprite:Play("1x2_room", true)
		elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_IIV then sprite:Play("IIV_room", true)
		npc.Position = room:GetTopLeftPos()+Vector(113,0)
		elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_2x1 then sprite:Play("2x1_room", true)
		elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_IIH then sprite:Play("IIH_room", true)
		elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_2x2 then sprite:Play("2x2_room", true)
		elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_LTL then sprite:Play("LTL_room", true)
		elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_LTR then sprite:Play("LTR_room", true)
		elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_LBL then sprite:Play("LBL_room", true)
		elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_LBR then sprite:Play("LBR_room", true) end
		sprite:LoadGraphics()
		npc:ToEffect():AddEntityFlags(EntityFlag.FLAG_NO_REMOVE_ON_TEX_RENDER)
	end
end

local function ReskinDoor(ent, st)
	local newent = Isaac.Spawn(1000, doorvariant, st, ent.Position, Vector(0,0), nil)
	local sprite = newent:GetSprite()
	sprite.Rotation = ent.Sprite.Rotation
	sprite.Offset = ent.Sprite.Offset + Vector(0, 16):Rotated(sprite.Rotation)
	--ent.Sprite.Color = Color(1, 1, 1, 0, 0, 0, 0)
	--ent.Sprite:Load(sprite:GetFilename(), true)
	--ent.Sprite.Offset = Vector(10000, 10000)
	--ent.Sprite:Reload()
	--ent.Sprite:LoadGraphics()
	--ent:ToDoor().ExtraVisible = false
	
	newent:GetData().reskined_door = ent
end

local function SetLimboGraphics(room)
	for i=1, room:GetGridSize() do
		local ent = room:GetGridEntity(i)
		if ent ~= nil then
			local Type = ent:GetType()
			if Type == 16 then
				--ReskinDoor(ent, 2)
				local door = ent:ToDoor()
				Isaac.DebugString(door.CloseAnimation)
				Isaac.DebugString(door.OpenAnimation)
				Isaac.DebugString(door.LockedAnimation)
				Isaac.DebugString(door.OpenLockedAnimation)
				door.CloseAnimation = "LimboClose"
				door.OpenAnimation = "LimboOpen"
				door:Open()
				door:Close(true)
			end
		end
	end
end

local sandalspeed = 0
local sandalspeedmax = {Value = function() return 14 end}
local sandalinvulncooldown = 0;

local mapComp = false
local mapSec = false

local confusionChance = {Value = function() return 0.2 end}
local confusionChanceModifier = 0

local nailChance = {Value = function() return 0.04 end}

local confusionEffects = {
	{TearFlags.TEAR_CONFUSION, 16},
	{TearFlags.TEAR_PERMANENT_CONFUSION, 3},
	{TearFlags.TEAR_CHARM, 1},
	{TearFlags.TEAR_FEAR, 5},
	{0, 2}
}
local confusionPathingEffects = {
	{TearFlags.TEAR_WIGGLE, 8},
	{TearFlags.TEAR_ORBIT, 5},
	{TearFlags.TEAR_PULSE, 4},
	{TearFlags.TEAR_GROW, 2},
	{TearFlags.TEAR_SPIRAL, 6},
	{TearFlags.TEAR_SQUARE, 5},
	{TearFlags.TEAR_BIG_SPIRAL, 1},
	{TearFlags.TEAR_BOMBERANG, 2},
	{TearFlags.TEAR_BOUNCE, 2},
	{0, 2}
}
local confusionExtraEffects = {
	{TearFlags.TEAR_CONTINUUM, 5},
	{TearFlags.TEAR_ATTRACTOR, 2},
	{TearFlags.TEAR_WAIT, 1},
	{TearFlags.TEAR_HOMING, 1}
}

local batterycurses = {
	{LevelCurse.CURSE_OF_BLIND, 3},
	{LevelCurse.CURSE_OF_MAZE, 5},
	{LevelCurse.CURSE_OF_THE_UNKNOWN, 2},
	{LevelCurse.CURSE_OF_THE_LOST, 5},
	{LevelCurse.CURSE_OF_DARKNESS, 8},
	{tomb_curse, 2}
}
local fakedThisRoom = false

local wormList = {
	{TrinketType.TRINKET_WIGGLE_WORM, TearFlags.TEAR_WIGGLE},
	{TrinketType.TRINKET_PULSE_WORM, TearFlags.TEAR_PULSE},
	{TrinketType.TRINKET_RING_WORM, TearFlags.TEAR_SPIRAL},
	{TrinketType.TRINKET_FLAT_WORM, TearFlags.TEAR_FLAT},
	{TrinketType.TRINKET_HOOK_WORM, TearFlags.TEAR_SQUARE},
	{TrinketType.TRINKET_OUROBOROS_WORM, TearFlags.TEAR_BIG_SPIRAL},
	{TrinketType.TRINKET_WHIP_WORM, nil},
	{TrinketType.TRINKET_TAPE_WORM, nil},
	{TrinketType.TRINKET_LAZY_WORM, nil}
	--BRAIN WORM
	
}

local itemTierList = require("newTierList.lua")

local mirrorVal = {}
for i, l in pairs(itemTierList) do
	for _, n in pairs(l) do
		if type(n) == type(0) then
			mirrorVal[n] = i
		else
			local _i = Isaac.GetItemIdByName(n)
			if _i ~= nil and _i > 0 then
				mirrorVal[_i] = i
			end
		end
	end
end

local function hasbit(x, p)
  return x % (p + p) >= p       
end

local function WeightedRNG(args, rng)
    local weight_value = 0
    local iterated_weight = 1
    for _, potentialObject in ipairs(args) do
        weight_value = weight_value + potentialObject[2]
    end
	
    local random_chance = math.floor(rng:RandomFloat() * weight_value + 1)
    for _, potentialObject in ipairs(args) do
        iterated_weight = iterated_weight + potentialObject[2]
        if iterated_weight > random_chance then
            return potentialObject[1]
        end
    end
end

local function Random(min, max) -- Re-implements math.random()
    if min ~= nil and max ~= nil then -- Min and max passed, integer [min,max]
        return math.floor(rng:RandomFloat() * (max - min + 1) + min)
    elseif min ~= nil then -- Only min passed, integer [0,min]
        return math.floor(rng:RandomFloat() * (min + 1))
    end
    return rng:RandomFloat() -- float [0,1)
end

local function SpillCreep(position, maxDistance, maxSize, minSize, type, variant, subtype, parent)
    maxDistance = maxDistance or 1
    maxSize = maxSize or 1
    minSize = minSize or 1
    type = type or EntityType.ENTITY_EFFECT
    variant = variant or EffectVariant.CREEP_RED
    subtype = subtype or 0
    local offset = RandomVector() * (Random(0, maxDistance * 100) * 0.01)
    local size = math.floor(rng:RandomFloat() * (maxSize * 100 - minSize * 100 + 1) + minSize * 100) * 0.01
    local creep = Isaac.Spawn(type, variant, subtype, position + offset, Vector(0, 0), parent)
    creep:ToEffect().Scale = size
	return creep
end

local function GetLimboItem()
	local item = WeightedRNG(ActiveLimboItemPool, rng)
	for i, p in pairs(ActiveLimboItemPool) do
		if p[1] == item then 
			table.remove(ActiveLimboItemPool, i)
			if #ActiveLimboItemPool <= 1 then
				BuildActiveLimboPool()
				--[[
				ActiveLimboItemPool = deepcopy(LimboItemPool)
				local player = Isaac.GetPlayer(0)
				for _i, _p in pairs(ActiveLimboItemPool) do
					if player:HasCollectible(_p[1]) then
						_p[2] = math.max(_p[2] - 5, 1)
					end
				end
				]]
			end
			return item
		end
	end
	return item
end



local function CheckForDevilDoor(room)
	local i = 0
	while i < 8 do
		local door = room:GetDoor(i)
		if door ~= nil then
			local roomid = Game():GetLevel():GetCurrentRoomIndex()
			if door.TargetRoomType == RoomType.ROOM_DEVIL or door.TargetRoomType == RoomType.ROOM_ANGEL then
				return true
			end
		end
		i = i + 1
	end
	return false
end
--[[
	local effects = player:GetEffects()
	local hadTheEffects = effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_GODHEAD)
	if not hadTheEffects then
		effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_GODHEAD, false)
	end
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TAMMYS_HEAD, false, false, false, false)
	if not hadTheEffects then
		effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_GODHEAD)
	end
]]

local angelChampionOptions = {
	--{6, 10},--solid white, stays alive until others are killed
	{7, 10},--gray, less health but double damage
	{8, 10},--transparent, floats over obstacles and shoots spectral tears
	{16, 10},--pulsing gray, repels shots
	{17, 10},--light white, has eternal flies
	{18, 2}--tiny
}
local function SetUpMaw(newent)
	newent:ToNPC():MakeChampion(WeightedRNG(angelChampionOptions, rng))
	newent.MaxHitPoints = newent.MaxHitPoints * 1.25
	newent.HitPoints = newent.HitPoints * 1.25
	local sprite = newent:GetSprite()
	sprite:ReplaceSpritesheet(0, "gfx/limbo_enemies/monster_141_maw.png")
	sprite:LoadGraphics()
end
local function SetUpCyclopia(newent)
	local sprite = newent:GetSprite()
	sprite:ReplaceSpritesheet(1, "gfx/limbo_enemies/280.000_cyclopia.png")
	sprite:LoadGraphics()
	newent.Mass = newent.Mass * 3
	newent.CollisionDamage = newent.CollisionDamage + 1
end

function mod:use_head()
	local player = Isaac.GetPlayer(0)
	if player == nil then return false end
	local hadTheEffects = player:HasCollectible(CollectibleType.COLLECTIBLE_GODHEAD)
	if not hadTheEffects then
		player:AddCollectible(CollectibleType.COLLECTIBLE_GODHEAD, 0, false)
	end
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TAMMYS_HEAD, false, false, false, false)
	if not hadTheEffects then
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_GODHEAD)
	end
end

function mod:use_runestone()
	local player = Isaac.GetPlayer(0)
	if player == nil then return false end
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, false, false)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR, false, false, false, false)
	player:UseCard(Card.RUNE_BLACK)
	player:RemoveCollectible(runestone_item)
	
end

function mod:use_metaldetector()
	local player = Isaac.GetPlayer(0)
	if player == nil then return false end
	
	local room = Game():GetRoom()
	local pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(6), 6, true)
	local NewVar = WeightedRNG({
	{PickupVariant.PICKUP_CHEST, 1},
	{PickupVariant.PICKUP_BOMBCHEST, 1},
	{PickupVariant.PICKUP_LOCKEDCHEST, 1},
	{PickupVariant.PICKUP_SPIKEDCHEST, 1},
	{PickupVariant.PICKUP_MIMICCHEST, 2},
	{PickupVariant.PICKUP_ETERNALCHEST, 3},
	{PickupVariant.PICKUP_REDCHEST, 15},
	{chestvariant, 15}
	}, rng)
	Isaac.Spawn(5, NewVar, 0, pos, Vector(0, 0), nil)
	
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.use_head, head_item );
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.use_runestone, runestone_item );
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.use_metaldetector, metaldetect_item );
local batblok = false
local lastfiredir = nil
local samefiretimer = 0
local firedelaymod = 0
local firedecrease = 0
local updatefiredel = false
function mod:MC_POST_UPDATE()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	if player == nil or room == nil then return end
	
	if tombroom and room:IsClear() then
		tombtimer = tombtimer + 1
		if tombtimer >= 5 then
			tombroom = false
		end
	end
	
	if inlimbo then
		for i, ent in pairs(Isaac.GetRoomEntities()) do
			if ent.Type == EntityType.ENTITY_PICKUP and ent.Variant == PickupVariant.PICKUP_COLLECTIBLE then
				ent:ToPickup().TheresOptionsPickup = false;
			end
		end
		local lm
		if room:IsClear() then lm = limbo_theme else lm = limbo_boss_theme end
		if MusicManager():GetCurrentMusicID() ~= lm then
			--MusicManager():Play(lm, 1)
			MusicManager():Crossfade(lm)
			if RoomReskinAPI == nil then
			for i, ent in pairs(Isaac.GetRoomEntities()) do
				if (ent.Type == 17 and ent.Variant == 2) or --error keeper
				(ent.Type == 1000 and (ent.Variant == 6 or ent.Variant == 9))--devil/angel statue
				then
					--Isaac.Spawn(ent.Type, 1, ent.SubType, ent.Position, Vector(0, 0), player)
					Isaac.Spawn(1000, 11341, 0, ent.Position, Vector(0, 0), player)
					ent:Remove()
					--ent:GetSprite():Load("gfx/1000.009_neutralstatue.anm2", true)
				elseif (ent.Type >= 46 and ent.Type <= 52) or ent.Type == 405 then
					Isaac.Spawn(WeightedRNG({
					{46, 5},--sloth
					{47, 10},--lust
					{48, 5},--wrath
					{49, 15},--gluttony
					{50, 5},--greed
					{51, 15},--envy
					{52, 5}--pride
					}, rng), math.min(ent.Variant, 1), 0, ent.Position, Vector(0, 0), player)
					ent:Remove()
				--[[elseif ent.Type == 33 and ent.Variant <= 3 then
					local sprite = ent:GetSprite()
					if ent.Variant == 0 then
						--sprite:Load("gfx/033.000_limbo Fireplace.anm2", true)
						sprite:ReplaceSpritesheet(1, "gfx/effects/effect_005_limbofire.png")
					elseif ent.Variant == 1 then
						--sprite:Load("gfx/033.001_limbo Red Fireplace.anm2", true)
						--sprite:ReplaceSpritesheet(1, "gfx/effects/effect_005_limbofire.png")
					elseif ent.Variant == 2 then
						--sprite:Load("gfx/033.002_limbo Blue Fireplace.anm2", true)
						--sprite:ReplaceSpritesheet(1, "gfx/effects/effect_005_limbofire.png")
					elseif ent.Variant == 3 then
						--sprite:Load("gfx/033.003_limbo Purple Fireplace.anm2", true)
						sprite:ReplaceSpritesheet(1, "gfx/effects/effect_005_limbofire.png")
					end
					--sprite:Play("Flickering", 1)
					sprite:Reload()
				]]
				--[[
				elseif ent.Type == 33 and ent.Variant <= 3 then
					local v = ent.Variant
					if player:HasCollectible(icarus_item) then
						if v % 2 == 0 then v = v + 1 end
					end
					Isaac.Spawn(ent.Type, v, firesubtype, ent.Position, Vector(0, 0), player)
					ent:Remove()
					]]
				end
			end
			end
		end
	end
	
	if player:HasCollectible(map_item) then
		local level = Game():GetLevel()
		--Isaac.DebugString(tostring(level:GetStateFlag(LevelStateFlag.STATE_MAP_EFFECT)))
		if room:GetFrameCount() == 2 or not level:GetStateFlag(LevelStateFlag.STATE_MAP_EFFECT) then-- or not player:HasCollectible(CollectibleType.COLLECTIBLE_TREASURE_MAP)
			if room:GetType() == RoomType.ROOM_BOSS or room:GetType() == RoomType.ROOM_TREASURE then
				mapComp = true
			elseif room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPERSECRET then
				mapSec = true
			end
			
			if not level:GetStateFlag(LevelStateFlag.STATE_MAP_EFFECT) then
					level:ApplyMapEffect()
			end
			if mapComp and not level:GetStateFlag(LevelStateFlag.STATE_COMPASS_EFFECT) then
				level:ApplyCompassEffect(true)
			end
			if mapSec and not level:GetStateFlag(LevelStateFlag.STATE_BLUE_MAP_EFFECT) then
				level:ApplyBlueMapEffect()
			end
		end
	end
	
	if player:HasCollectible(deal_item) and not builtdeal then
		local room = Game():GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 6, true)
		Isaac.Spawn(5, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_STORE_KEY, pos, Vector(0, 0), nil)
		builtdeal = true
	end
	
	local actitem = player:GetActiveItem()
	if activelimbotracker[actitem] and not player:IsHoldingItem() then
		if actitem == metaldetect_item then
			if player:GetActiveCharge() == 0 then
				activelimbotracker[actitem] = false
			end
			player:SetActiveCharge(0)
		else
			activelimbotracker[actitem] = false
		end
	end
	
	
	if player:HasCollectible(battery_item) and not batblok then
		if player:GetActiveItem() ~= nil and player:GetActiveItem() > 0 then
			if player:GetActiveCharge() == 0 then 
				player:SetActiveCharge(1) 
				if not player:NeedsCharge() then
					player:SetActiveCharge(0)
					batblok = true
				end
			end
			--[[
			if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
				player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_CAR_BATTERY, false)
			end
			]]
		end
	end
	
	if player:HasCollectible(icarus_item) and room:GetFrameCount() == 1 and room:IsFirstVisit() and not inlimbo then
		local icaruschance = 0.95 - player.Luck * 0.025
		for i, ent in pairs(Isaac.GetRoomEntities()) do
			if ent.Type == EntityType.ENTITY_FIREPLACE and math.random() <= icaruschance then
				if ent.Variant == 0 or ent.Variant == 2 then
					Isaac.Spawn(ent.Type, ent.Variant + 1, ent.SubType, ent.Position, Vector(0, 0), player)
					ent:Remove()
					icaruschance = icaruschance - 0.05 - player.Luck * 0.01
				end
			end
		end
		local rockchance = 0.15 - player.Luck * 0.025
		--Isaac.DebugString("Point B")
		for i = 1, room:GetGridSize() do
			--Isaac.DebugString("Point C-" .. tostring(i))
			--local grident = room:GetGridEntityFromPos(room:GetGridPosition(i))
			local grident = room:GetGridEntity(i)
			if (grident ~= nil) then
				--local gridtype = grident:GetType()
				local gridtype = grident.Desc.Type
				--Isaac.DebugString("Point D (" .. tostring(gridtype) .. ")")
				if gridtype == GridEntityType.GRID_ROCK and math.random() <= rockchance then
					--Isaac.DebugString("rock!")
					local pos = grident.Position
					grident:Destroy(true)
					Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 1, 0, pos, Vector(0, 0), player)
					rockchance = rockchance - 0.01
					--grident:SetType(GridEntityType.GRID_NULL)
				end
				--[[
				if gridtype == GridEntityType.GRID_ROCK_ALT then
					--Isaac.DebugString("alt rock!")
					local pos = grident.Position
					grident:Destroy(true)
					Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 1, 0, pos, Vector(0, 0), player)
				end
				if gridtype == GridEntityType.GRID_ROCKB then
					--Isaac.DebugString("rock B!")
					local pos = grident.Position
					grident:Destroy(true)
					Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 1, 0, pos, Vector(0, 0), player)
				end
				if gridtype == GridEntityType.GRID_ROCKT then
					--Isaac.DebugString("rock T!")
					local pos = grident.Position
					grident:Destroy(true)
					Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 1, 0, pos, Vector(0, 0), player)
				end
				if gridtype == GridEntityType.GRID_ROCK_SS then
					--Isaac.DebugString("rock SS!")
					local pos = grident.Position
					grident:Destroy(true)
					Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 1, 0, pos, Vector(0, 0), player)
				end]]
			end
		end
	end
	
	if player:HasCollectible(sandals_item) then
		if not player:GetEffects():HasCollectibleEffect(302) then
			player:GetEffects():AddCollectibleEffect(302, false)
		end
		local game_seeds = Game():GetSeeds()
		if not game_seeds:HasSeedEffect(SeedEffect.SEED_ICE_PHYSICS) then
			game_seeds:AddSeedEffect(SeedEffect.SEED_ICE_PHYSICS)
		end
		
		if (player:GetMovementDirection() >= 0) then
			player.Velocity = player:GetMovementVector():Normalized() * 4 * player.MoveSpeed
		elseif player.Velocity:Length() > 2 then
			player.Velocity = player.Velocity:Normalized() * 2
		end
		
		--[[
		--if (player:GetMovementDirection() >= 0) then
		if (player:GetMovementDirection() >= 0 and math.abs(player:GetMovementJoystick():GetAngleDegrees() - player:GetVelocityBeforeUpdate():GetAngleDegrees()) < 125) then
			if sandalspeed >= 2 then sandalspeed = sandalspeed + 0.15 else sandalspeed = sandalspeed + 0.25 end
		else
			--if (player.Velocity:Length() >= 12) then sandalspeed = sandalspeed - 0.15 else sandalspeed = sandalspeed - 0.3 end
			if sandalspeed >= 5 then sandalspeed = sandalspeed - 0.3 else sandalspeed = sandalspeed - 2.0 end
		end
		if sandalspeed < 0 then sandalspeed = 0 end
		if sandalspeed > sandalspeedmax:Value() then sandalspeed = sandalspeedmax:Value() end
		local pspeed = player.Velocity:Length()
		if (pspeed < sandalspeed) then
			player.Velocity = player.Velocity:Normalized() * (player.Velocity:Length() + (sandalspeed - player.Velocity:Length())/2)
		--else
			--if sandalspeed >= 5 then player.Velocity = player.Velocity:Normalized() * (player.Velocity:Length() + (sandalspeed - player.Velocity:Length())/2) end
		end
		if player.Velocity:Length() >= 10 then
			player:GetEffects():AddCollectibleEffect(302, false)
		else
			player:GetEffects():RemoveCollectibleEffect(302)
		end
		--Isaac.DebugString(tostring(player.Velocity:Length()))
		--player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		if sandalspeed >= 9 then sandalinvulncooldown = sandalinvulncooldown - 1 end
		]]
	end
	
	if player:HasCollectible(hyperfocus_item) then
		local firedir = player:GetFireDirection()
		local damageinc = 0.2
		local boostType = 1
		if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) or player:HasWeaponType(WeaponType.WEAPON_KNIFE) or player:HasWeaponType(WeaponType.WEAPON_TECH_X) then--
			boostType = 2
		elseif player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
			boostType = 3
		end
		
		if updatefiredel then
			local temp = firedelaymod
			firedelaymod = 0
			firedecrease = 0
			samefiretimer = 0
			for i=0, temp do
				if firedelaymod < 7 and
				((boostType == 1 and player.MaxFireDelay > 1) or (boostType == 3 and player.ShotSpeed < 2) or (boostType == 2))
				then
					local delta = 1
					if boostType == 1 then
						delta = math.max(1, math.ceil((player.MaxFireDelay - 2)/10))
						player.MaxFireDelay = player.MaxFireDelay - delta
					elseif boostType == 2 then
						delta = damageinc
						player.Damage = player.Damage + delta
					elseif boostType == 3 then
						delta = math.min(0.1, 2 - player.ShotSpeed)
						player.ShotSpeed = player.ShotSpeed + delta
					end
					firedecrease = firedecrease + delta
					firedelaymod = firedelaymod + 1
				end
			end
			updatefiredel = false
		end
		
		--if not (boostType == 2 and firedir == Direction.NO_DIRECTION) then
			if lastfiredir ~= nil and firedir == lastfiredir and firedir ~= Direction.NO_DIRECTION then
				samefiretimer = samefiretimer + 1
				--if player.FireDelay == math.floor(samefiretimer/10) + 1 then player.FireDelay = 1 end
				if (samefiretimer + (math.min(math.max(1, firedelaymod), 5) * 3)) % 30 == 0 and firedelaymod < 7 and
				((boostType == 1 and player.MaxFireDelay > 1) or (boostType == 3 and player.ShotSpeed < 2) or (boostType == 2))
				then
					local delta = 1
					if boostType == 1 then
						delta = math.max(1, math.ceil((player.MaxFireDelay - 2)/10))
						player.MaxFireDelay = player.MaxFireDelay - delta
					elseif boostType == 2 then
						delta = damageinc
						player.Damage = player.Damage + delta
					elseif boostType == 3 then
						delta = math.min(0.1, 2 - player.ShotSpeed)
						player.ShotSpeed = player.ShotSpeed + delta
					end
					firedecrease = firedecrease + delta
					firedelaymod = firedelaymod + 1
				end
			else
				if firedelaymod > 0 then
					local delta = 1
					local decreasemult = 1
					if boostType == 1 then
						if firedir ~= Direction.NO_DIRECTION then
							delta = math.min(math.ceil(firedelaymod / 3 - 0.4), math.max(2, math.ceil((player.MaxFireDelay + 5)/10)))
						elseif lastfiredir == firedir and room:GetFrameCount() % 3 ~= 0 then
							delta = 0
						end
						if firedelaymod == delta then
							decreasemult = firedecrease / delta
						else
							decreasemult = math.min(firedecrease / delta, math.ceil((player.MaxFireDelay * 1.1 - 1) / 10))
						end
						player.MaxFireDelay = player.MaxFireDelay + delta * decreasemult
					elseif boostType == 2 then
						if firedir ~= Direction.NO_DIRECTION then
							delta = math.min(firedelaymod, 4)
						elseif room:GetFrameCount() % 30 ~= 0 then
							delta = 0
						end
						decreasemult = damageinc
						player.Damage = player.Damage - delta * decreasemult
					elseif boostType == 3 then
						if firedir == Direction.NO_DIRECTION and lastfiredir == firedir and room:GetFrameCount() % 3 ~= 0 then
							delta = 0
						end
						local decreasemult = math.min(0.1, firedecrease / delta)
						player.ShotSpeed = player.ShotSpeed - delta * decreasemult
					end
					firedecrease = firedecrease - delta * decreasemult
					firedelaymod = firedelaymod - delta
				end
				samefiretimer = 0 - (math.min(firedelaymod, 4) * 5)
			end
			if not (boostType == 2 and firedir == Direction.NO_DIRECTION) then lastfiredir = firedir end
		--end
	end
	
	if player:HasCollectible(brush_item) then
		if brushtimer >= brushlimit - 60 or not room:IsClear() then
			brushtimer = brushtimer + 1
			if brushtimer > brushlimit + brushduration then
				brushtimer = 0
				brushlimit = brushlimit + 60 + math.ceil(math.random() * 120)
				if brushpickupallowed and math.random() < o_brush_heartchance:Value() and (playerhastakendamage == false or math.random() < o_brush_heartchance:Value() * 0.5 + player.Luck * 0.05) then
					local hearttype = HeartSubType.HEART_HALF
					local stage = Game():GetLevel():GetStage()
					if stage == LevelStage.STAGE5 or stage == LevelStage.STAGE6 then
						if Game():GetLevel():IsAltStage() then
							hearttype = HeartSubType.HEART_SOUL
						else
							hearttype = HeartSubType.HEART_BLACK
						end
					elseif stage >= LevelStage.STAGE4_1 then
						hearttype = HeartSubType.HEART_FULL
					end
					local position = player.Position
					local r = math.floor(rng:RandomFloat() * 4)
					if r == 0 then
						position = Vector(Random(room:GetTopLeftPos().X, room:GetBottomRightPos().X), room:GetTopLeftPos().Y - 32)
					elseif r == 1 then
						position = Vector(Random(room:GetTopLeftPos().X, room:GetBottomRightPos().X), room:GetBottomRightPos().Y)
					elseif r == 2 then
						position = Vector(room:GetTopLeftPos().X, Random(room:GetTopLeftPos().Y, room:GetBottomRightPos().Y))
					elseif r == 3 then
						position = Vector(room:GetBottomRightPos().X, Random(room:GetTopLeftPos().Y, room:GetBottomRightPos().Y))
					end
					position = room:FindFreeTilePosition(position, 32)
					local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, hearttype, room:FindFreePickupSpawnPosition(position, 6, true), Vector(0, 0), player)
					if heart ~= nil then
						brushpickupallowed = false
					end
				end
			elseif brushtimer >= brushlimit then
				if brushtimer % 10 == 0 then
					local _dur = math.floor(math.max(45, brushduration + brushlimit - brushtimer))
					room:EmitBloodFromWalls(_dur, 2)
					local stage = Game():GetLevel():GetStage()
					for i=1, 3 do
						local r = math.floor(rng:RandomFloat() * 4)
						local position = Vector(0, 0)
						if r == 0 then
							position = Vector(Random(room:GetTopLeftPos().X, room:GetBottomRightPos().X), room:GetTopLeftPos().Y - 32)
						elseif r == 1 then
							position = Vector(Random(room:GetTopLeftPos().X, room:GetBottomRightPos().X), room:GetBottomRightPos().Y)
						elseif r == 2 then
							position = Vector(room:GetTopLeftPos().X, Random(room:GetTopLeftPos().Y, room:GetBottomRightPos().Y))
						elseif r == 3 then
							position = Vector(room:GetBottomRightPos().X, Random(room:GetTopLeftPos().Y, room:GetBottomRightPos().Y))
						end
						position = room:FindFreeTilePosition(position, 32)
						if room:IsPositionInRoom(position, 4) then
							local creep = SpillCreep(position, 16, 1.25, 0.8, nil, nil, nil, nil)
							if creep ~= nil then
								if stage < LevelStage.STAGE4_1 then
									creep.CollisionDamage = 1
								else
									creep.CollisionDamage = 2
								end
								creep:ToEffect():SetTimeout(_dur + 10)
							end
						end
					end
				end
				if brushtimer == brushlimit then
					for i, ent in pairs(Isaac.GetRoomEntities()) do
						if ent:IsVulnerableEnemy() then
							ent:TakeDamage(math.min(player.Damage / (6 + rng:RandomFloat() * 2), ent.HitPoints - 1), 0, EntityRef(player), 1)
						end
					end
				end
			elseif brushtimer > brushlimit - 60 then
				if brushtimer % 10 == 0 then
					room:EmitBloodFromWalls(math.max(60, brushduration + brushlimit - brushtimer), 1)
				end
			elseif brushtimer == brushlimit - 60 then
				local shape = room:GetRoomShape()
				if shape == RoomShape.ROOMSHAPE_IH or 
				shape == RoomShape.ROOMSHAPE_IV or 
				shape == RoomShape.ROOMSHAPE_IIV or 
				shape == RoomShape.ROOMSHAPE_IIH or 
				(shape == RoomShape.ROOMSHAPE_1x1 and math.random() > (o_brush_procchance:Value() * o_brush_1x1chance:Value())) or
				(shape ~= RoomShape.ROOMSHAPE_1x1 and math.random() > o_brush_procchance:Value())
				then
					brushtimer = 0
				end
			end
		end
	end
	
	if room:GetType() == RoomType.ROOM_BOSS and room:IsClear() then
		local level = Game():GetLevel()
		local roomid = level:GetCurrentRoomIndex()
		if bossDoorState[roomid] == nil or bossDoorState[roomid] == 0 then
			bossDoorState[roomid] = 1
		elseif bossDoorState[roomid] == 1 then
			local chance = 1
			local stage = level:GetStage()
			if stage <= 1 then
				chance = chance - 0.75
				if player:GetPlayerType() == PlayerType.PLAYER_ISAAC or player:GetPlayerType() == PlayerType.PLAYER_AZAZEL then chance = chance - 0.15 end
				if player:GetName() == "Jahaziel" and player:HasCollectible(compass_item) then chance = chance - 0.5 end
			elseif stage == 2 then
				chance = chance - 0.3
				if player:GetPlayerType() == PlayerType.PLAYER_ISAAC or player:GetPlayerType() == PlayerType.PLAYER_AZAZEL then chance = chance - 0.2 end
				if player:GetName() == "Jahaziel" and player:HasCollectible(compass_item) then chance = chance - 0.4 end
			elseif (limboroomtype == RoomType.ROOM_ERROR and stage == LevelStage.STAGE4_2) or stage > LevelStage.STAGE5 then
				chance = chance - 1
			end
			if player:GetCollectibleCount() > stage * 2 - 1 then
				chance = chance - (player:GetCollectibleCount() - (stage * 2 - 1)) * 0.1
			end
			if CheckForDevilDoor(room) then 
				if player:HasCollectible(CollectibleType.COLLECTIBLE_DUALITY) then
					chance = chance + 0.20
				else
					chance = chance - 1.5 
				end
			end
			chance = chance + math.max(player.Luck, -2.5) * 0.1
			if player:HasCollectible(mirror_item) then chance = chance + 0.3 end
			--if player:HasCollectible(paw_item) then chance = chance + 0.1 end
			if player:HasCollectible(map_item) then chance = chance + 0.1 end
			if player:HasCollectible(confusion_item) then chance = chance + 0.1 end
			if player:HasCollectible(sandals_item) then chance = chance + 0.1 end
			if player:HasCollectible(icarus_item) then chance = chance + 0.1 end
			if player:HasCollectible(battery_item) then chance = chance + 0.1 end
			if player:HasCollectible(brush_item) then chance = chance + 0.1 end
			if player:HasCollectible(toothless_item) then chance = chance + 0.2 end
			if player:HasCollectible(redsea_item) then chance = chance + 0.1 end
			if player:HasCollectible(sack_item) then chance = chance + 0.1 end
			if player:HasCollectible(deal_item) then chance = chance + 0.1 end
			if player:HasCollectible(scope_item) then chance = chance + 0.1 end
			if player:HasCollectible(belt_item) then chance = chance + 0.1 end
			if player:HasCollectible(wormbox_item) then chance = chance + 0.1 end
			if player:HasCollectible(quantumrock_item) then chance = chance + 0.1 end
			if player:HasTrinket(pebble_trinket) then chance = chance + 0.05 end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then chance = chance + 0.05 end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER) then chance = chance + 0.05 end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then chance = chance + 0.05 end
			if player:HasPlayerForm(PlayerForm.PLAYERFORM_EVIL_ANGEL) then chance = chance - 0.5 end
			if player:HasPlayerForm(PlayerForm.PLAYERFORM_ANGEL) then chance = chance - 0.25 end
			if player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) then chance = chance - 0.25 end
			if player:GetPlayerType() == PlayerType.PLAYER_APOLLYON then chance = chance - 0.30 end
			if player:GetPlayerType() == PlayerType.PLAYER_ISAAC then chance = chance - 0.1 end
			if player:GetName() == "Jahaziel" and not player:HasCollectible(compass_item) then chance = chance + 0.1 end
			if player:GetName() == "Tormented Jahaziel" then chance = chance + 0.1 end
			if player:HasTrinket(TrinketType.TRINKET_MISSING_POSTER) then chance = chance + 0.25 * player:GetTrinketMultiplier() end
			if player:HasTrinket(beetle_trinket) then
				if hasbit(level:GetCurses(), tomb_curse) then chance = chance + 0.5 * player:GetTrinketMultiplier() else chance = chance + 0.1 end
			end
			if hasbit(level:GetCurses(), LevelCurse.CURSE_OF_THE_LOST) then chance = chance + 0.1 end
			if player:HasCollectible(compass_item) then chance = math.max(chance + 1, 0.2) end
			if math.random() < chance then
				if player:HasCollectible(compass_item) or math.random() < (chance / 2) then
					bossDoorState[roomid] = 3
				else
					bossDoorState[roomid] = 2
				end
				--Isaac.Spawn(1000, doorvariant, 0, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 16, true), Vector(0, 0), nil)
				SpawnLimboDoor(room, 1)
				BuildActiveLimboPool()
			else
				bossDoorState[roomid] = -1
			end
		end
	end
end

local function GetBaseTombChance(player)
	if player == nil then return o_tomb_procChance:Value() end
	local tc = (o_tomb_procChance:Value() - math.min(player.Luck * 0.05, o_tomb_procChance:Value() - 0.15))
	if player:HasCollectible(mirror_item) then tc = tc - 0.2 end
	if player:HasTrinket(beetle_trinket) then tc = tc - 0.1 * player:GetTrinketMultiplier() end
	return math.max(tc, 0.1)
end
local function GetBaseTombLoot(player)
	if player == nil then return 0 end
	local loot = 0
	if player:HasCollectible(paw_item) then
		loot = loot + 2
	end
	if player:HasTrinket(beetle_trinket) then
		loot = loot + 3 * player:GetTrinketMultiplier()
	end
	return loot
end
local tombchance = 0.33
local tombcounter = 0
function mod:MC_POST_NEW_ROOM()
	local room = Game():GetRoom()
	--SetLimboGraphics(room)
	tombroom = false
	fakedThisRoom = false
	brushlimit = o_brush_timer:Value()
	if room:GetType() == RoomType.ROOM_BOSS then 
		brushlimit = brushlimit + 100
		brushtimer = 0
	elseif brushtimer > brushlimit - 120 then brushtimer = brushlimit - 120 end
	brushpickupallowed = true
	playerhastakendamage = false
	if inlimbo then
		if room:GetType() ~= limboroomtype then
			inlimbo = false
			local roomid = Game():GetLevel():GetCurrentRoomIndex()
			if room:IsClear() and room:GetType() == RoomType.ROOM_BOSS and bossDoorState[roomid] ~= nil and bossDoorState[roomid] >= 3 then
				bossDoorState[roomid] = 2
			end
		else
			if RoomReskinAPI == nil then
				for i, ent in pairs(Isaac.GetRoomEntities()) do
					if (ent.Type == 17 and ent.Variant == 2) or --error keeper
					(ent.Type == 1000 and (ent.Variant == 6 or ent.Variant == 9))--devil/angel statue
					then
						--Isaac.Spawn(ent.Type, 1, ent.SubType, ent.Position, Vector(0, 0), player)
						Isaac.Spawn(1000, 11341, 0, ent.Position, Vector(0, 0), nil)
						ent:Remove()
						--ent:GetSprite():Load("gfx/1000.009_neutralstatue.anm2", true)
					elseif (ent.Type >= 46 and ent.Type <= 52) or ent.Type == 405 then
						Isaac.Spawn(WeightedRNG({
						{46, 5},--sloth
						{47, 10},--lust
						{48, 5},--wrath
						{49, 15},--gluttony
						{50, 5},--greed
						{51, 15},--envy
						{52, 5}--pride
						}, rng), math.min(ent.Variant, 1), 0, ent.Position, Vector(0, 0), nil)
						ent:Remove()
					end
				end
				ChangeBackdrop("Limbo", 1)
				--ChangeBackdrop("12_Darkroom", 1)
				SetLimboGraphics(room)
			end
		end
	else
		local roomid = Game():GetLevel():GetCurrentRoomIndex()
		if room:IsClear() and room:GetType() == RoomType.ROOM_BOSS and bossDoorState[roomid] ~= nil and bossDoorState[roomid] >= 3 then
			--Isaac.Spawn(1000, doorvariant, 0, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 16, true), Vector(0, 0), nil)
			SpawnLimboDoor(room, 1)
		end
	end
	if room:IsClear() and room:GetType() == RoomType.ROOM_DEFAULT then
		if hasbit(Game():GetLevel():GetCurses(), tomb_curse) then
			if math.random() < tombchance then
				room:RespawnEnemies()
				if not room:IsClear() then
					--Isaac.DebugString("not clear!")
					tombroom = true
					tombtimer = 0
					tombcounter = 0
					tombchance = GetBaseTombChance(Isaac.GetPlayer(0))
				end
			else
				tombcounter = tombcounter + 1
				if tombcounter == o_tomb_increaseRoomCount:Value() then
					tombchance = math.max(GetBaseTombChance(Isaac.GetPlayer(0)) + 0.02, 0.15)--0.35 - math.min(Isaac.GetPlayer(0).Luck * 0.05, 0.25)
				elseif tombcounter > o_tomb_increaseRoomCount:Value() then
					tombchance = tombchance + 0.05
				end
			end
		end
	end
	
	confusionChanceModifier = 0
end
local qmlist = {}
function mod:MC_POST_NEW_LEVEL()
	local player = Isaac.GetPlayer(0)
	mapComp = false
	mapSec = false
	bossDoorState = {}
	if player:HasCollectible(unknown_item) then
		BuildActiveLimboPool()
		local newitem = GetLimboItem()
		player:AddCollectible(newitem, 0, false)
		if newitem == deal_item then player:AddCoins(5)
		elseif newitem == prize_item or newitem == brush_item then player:AddSoulHearts(2) 
		end
		if qmlist[qmcounter] then 
			player:RemoveCollectible(qmlist[qmcounter])
			if qmlist[qmcounter] == sandals_item then
				Game():GetSeeds():RemoveSeedEffect(SeedEffect.SEED_ICE_PHYSICS)
			end
		end
		qmlist[qmcounter] = newitem
		qmcounter = qmcounter - 1
		if qmcounter == 0 then qmcounter = qmmax end
	end
	if player:HasCollectible(toothless_item) then
		local room = Game():GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetTopLeftPos(), 6, true)
		Isaac.Spawn(5, chestvariant, 0, pos, Vector(0,0), nil)
		pos = room:FindFreePickupSpawnPosition(Vector(room:GetBottomRightPos().X, room:GetTopLeftPos().Y), 6, true)
		Isaac.Spawn(5, chestvariant, 0, pos, Vector(0,0), nil)
	end
	tombcounter = 0
	tombchance = GetBaseTombChance(player)
	tombtimer = 0
	tombloot = GetBaseTombLoot(player)
	if Game():GetLevel():GetStage() == 1 then
		if Isaac.GetChallenge() == water_challenge then
			--player:RemoveCollectible(157)
			player:AddCollectible(confusion_item, 0, true)
			player:AddCollectible(redsea_item, 0, true)
		end
		if player:GetName() == "Jahaziel" then
			player:AddCollectible(toothless_item, 0, true)
			player:AddHearts(-2)
			player:AddBoneHearts(1)
			if o_jahaziel_perthro:Value() then player:SetCard(0, Card.RUNE_PERTHRO) end
			if o_jahaziel_store_credit:Value() then player:AddTrinket(TrinketType.TRINKET_STORE_CREDIT) end
			BuildActiveLimboPool()
			--player:AddNullCostume(jahaziel_costume)
			
			--[[local newitem = compass_item
			player:AddCollectible(newitem, 0, true)
			if qmlist[qmcounter] then player:RemoveCollectible(qmlist[qmcounter]) end
			qmlist[qmcounter] = newitem
			qmcounter = qmcounter - 1
			if qmcounter == 0 then qmcounter = qmmax end]]--
			BuildActiveLimboPool()
			--[[
			player:AddCollectible(compass_item, 0, true)
			qmlist[1] = compass_item
			BuildActiveLimboPool()
			local newitem = GetLimboItem()
			player:AddCollectible(newitem, 0, true)
			qmlist[2] = newitem
			]]
			--[[
			for i=1, 2 do
				BuildActiveLimboPool()
				local newitem = GetLimboItem()
				player:AddCollectible(newitem, 0, true)
				if qmlist[qmcounter] then player:RemoveCollectible(qmlist[qmcounter]) end
				qmlist[qmcounter] = newitem
				qmcounter = qmcounter - 1
				if qmcounter == 0 then qmcounter = qmmax end
			end
			]]
			if o_jahaziel_chests:Value() > 0 then
				local room = Game():GetRoom()
				local pos = room:FindFreePickupSpawnPosition(room:GetTopLeftPos(), 6, true)
				local st = 0
				if o_jahaziel_chests:Value() == 2 then st = 2 end
				Isaac.Spawn(5, chestvariant, st, pos, Vector(0,0), nil)
				pos = room:FindFreePickupSpawnPosition(Vector(room:GetBottomRightPos().X, room:GetTopLeftPos().Y), 6, true)
				if o_jahaziel_chests:Value() == 2 then st = 1 end
				Isaac.Spawn(5, chestvariant, st, pos, Vector(0,0), nil)
			end
		end
	end
	if player:HasCollectible(sack_item) then
		table.insert(sackdumplist, 1, WeightedRNG({
			{{300, Card.RUNE_PERTHRO}, 5},
			{{PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_STORE_CREDIT}, 2}
		}, rng))
	end
	if player:HasCollectible(belt_item) and Isaac.GetCurseIdByName("Curse of Eternity") ~= nil and Isaac.GetCurseIdByName("Curse of Eternity") > 0 then
		local level = Game():GetLevel()
		if not hasbit(level:GetCurses(), 2 ^ (Isaac.GetCurseIdByName("Curse of Eternity")-1)) then
			level:AddCurse((2 ^ (Isaac.GetCurseIdByName("Curse of Eternity")-1)), true)
		end
	end
end
local function OnNewGame()
	ActiveLimboItemPool = deepcopy(LimboItemPool)
	for i, c in ipairs(costumehandler) do
		c.hasit = false
	end
	haswings = false
	hasbrush = false
	qmcounter = qmmax
	qmlist = {}
	sackdumplist = {}
	builtdeal = false
	batblok = false
	lastfiredir = nil
	samefiretimer = 0
	firedelaymod = 0
	firedecrease = 0
	updatefiredel = false
	activelimbotracker[head_item] = true;
	activelimbotracker[runestone_item] = true;
	activelimbotracker[metaldetect_item] = true;
	limbochestactivepool = {
		metaldetect_item
	}
end

local ValidLimboRooms = {}
ValidLimboRooms[RoomType.ROOM_ERROR] = {
{"error.0", 15},--2x item
{"error.4", 5},--item + 4x chest
{"error.5", 5},--item + 2x shop item + 7x coin
{"error.6", 2},--item + 2x gold poop + 4x shop item
{"error.8", 2},--item + 6x chest + 2x key
{"error.10", 10},--item + 4x trinket
{"error.15", 2},--item + 2x ragman
{"error.18", 10},--2x item + super greed
{"error.19", 15},--2x item + re-roll machine
}
ValidLimboRooms[RoomType.ROOM_ANGEL] = {
{"angel.0", 8},--1x item
{"angel.1", 10},--2x item
{"angel.3", 5},--5x heart
{"angel.4", 10},--3x item
{"angel.6", 6},--2x item + purple fires
{"angel.7", 3},--4x item (blocked by rocks and locks)
--{"angel.9", 10},--2x item (too small!)
{"angel.10", 5},--1x item
{"angel.11", 10},--1x item + 2x eternal chest
{"angel.12", 10},--2x item
{"angel.13", 8},--2x item + 2x soul heart + 4x blue fire
{"angel.14", 8},--2x item + 1x soul heart + 5x blue fire
{"angel.15", 5},--3x item + 4x purple fire
}
ValidLimboRooms[RoomType.ROOM_DEVIL] = {
{"devil.0", 5},--2x item
{"devil.1", 5},--2x item
{"devil.2", 10},--3x item
{"devil.3", 10},--1x item
{"devil.4", 10},--2x item + 1x red chest
}
ValidLimboRooms[RoomType.ROOM_SECRET] = {
{"secret.0", 10},--1x item
{"secret.0", 10},--1x item
{"secret.4", 1},--slot machine
}

local function GoToLimboRoom()
	inlimbo = true
	Isaac.ExecuteCommand("goto s." .. WeightedRNG(ValidLimboRooms[limboroomtype], rng))
end

function mod:LimboDoorUpdate(ent)
	if ent.Variant ~= doorvariant then return end
	if RoomReskinAPI == nil then
	local sprite = ent:GetSprite()
	if ent:GetData().reskined_door ~= nil then
		local _sprite = ent:GetData().reskined_door.Sprite
		--_sprite.Color = Color(1, 1, 1, 0, 0, 0, 0)
		--_sprite:LoadGraphics()
		if _sprite ~= nil then
			if _sprite:IsPlaying("Opened") and not sprite:IsPlaying("Opened") then
				sprite:Play("Opened", true)
			elseif _sprite:IsPlaying("Closed") and not sprite:IsPlaying("Closed") then
				sprite:Play("Closed", true)
			elseif _sprite:IsPlaying("Open") and not sprite:IsPlaying("Open") then
				sprite:Play("Open", true)
			elseif _sprite:IsPlaying("Close") and not sprite:IsPlaying("Close") then
				sprite:Play("Close", true)
			elseif _sprite:IsPlaying("Break") and not sprite:IsPlaying("Break") then
				sprite:Play("Break", true)
			elseif _sprite:IsPlaying("KeyOpen") and not sprite:IsPlaying("KeyOpen") then
				sprite:Play("KeyOpen", true)
			elseif _sprite:IsPlaying("KeyClose") and not sprite:IsPlaying("KeyClose") then
				sprite:Play("KeyClose", true)
			elseif _sprite:IsPlaying("BrokenOpen") and not sprite:IsPlaying("BrokenOpen") then
				sprite:Play("BrokenOpen", true)
			elseif _sprite:IsPlaying("KeyClosed") and not sprite:IsPlaying("KeyClosed") then
				sprite:Play("KeyClosed", true)
			elseif _sprite:IsPlaying("KeyOpenNoKey") and not sprite:IsPlaying("KeyOpenNoKey") then
				sprite:Play("KeyOpenNoKey", true)
			elseif _sprite:IsPlaying("GoldenKeyOpen") and not sprite:IsPlaying("GoldenKeyOpen") then
				sprite:Play("GoldenKeyOpen", true)
			elseif ent:GetData().reskined_door:ToDoor() ~= nil and not ent:GetData().reskined_door:ToDoor():IsOpen() and (sprite:IsPlaying("Opened") or sprite:IsPlaying("Open")) then
				if ent:GetData().reskined_door:ToDoor():IsLocked() then sprite:Play("KeyClosed", true) else sprite:Play("Closed", true) end
			elseif ent:GetData().reskined_door:ToDoor() ~= nil and ent:GetData().reskined_door:ToDoor():IsOpen() and (sprite:IsPlaying("Closed") or sprite:IsPlaying("Close")) then
				sprite:Play("Opened", true)
			end
		end
	end
	end
	if ent.SubType <= 1 then
		local player = Isaac.GetPlayer(0)
		if (player.Position - ent.Position):Length() < 32 then
			GoToLimboRoom()
		end
	end
end
mod:AddCallback( ModCallbacks.MC_POST_EFFECT_UPDATE, mod.LimboDoorUpdate);

function mod:LimboFireUpdate(ent)
	if not inlimbo then return end
	local sprite = ent:GetSprite()
	if ent.Variant == 0 then
		--sprite:Load("gfx/033.000_limbo Fireplace.anm2", true)
		sprite:ReplaceSpritesheet(1, "gfx/effects/effect_005_limbofire.png")
	elseif ent.Variant == 1 then
		--sprite:Load("gfx/033.001_limbo Red Fireplace.anm2", true)
		sprite:ReplaceSpritesheet(1, "gfx/effects/effect_005_limbofire.png")
	elseif ent.Variant == 2 then
		--sprite:Load("gfx/033.002_limbo Blue Fireplace.anm2", true)
		sprite:ReplaceSpritesheet(1, "gfx/effects/effect_005_limbofire.png")
	elseif ent.Variant == 3 then
		--sprite:Load("gfx/033.003_limbo Purple Fireplace.anm2", true)
		sprite:ReplaceSpritesheet(1, "gfx/effects/effect_005_limbofire.png")
	end
	--sprite:Play("Flickering", 1)
	sprite:Reload()
end
--mod:AddCallback( ModCallbacks.MC_NPC_UPDATE, mod.LimboDoorUpdate, 33);

function mod:MC_ENTITY_TAKE_DMG(entity, amount, flag, source, frames)
	local player = Isaac.GetPlayer(0)
	if entity.Type == 1 and amount > 0 then
		--[[
		if player:HasCollectible(sandals_item) then
			if source ~= nil and source.IsVulnerableEnemy ~= nil and source:IsVulnerableEnemy() then source:TakeDamage(player.Velocity:Length(), 0, player, 1) end
			if player.Velocity:Length() >= 14 or sandalspeed >= 14.5 then
				if sandalinvulncooldown <= 0 then
					sandalinvulncooldown = 20
					return false
				end
			end
		end
		]]
		if player:HasCollectible(sandals_item) then
			if hasbit(flag, DamageFlag.DAMAGE_ACID) or hasbit(flag, DamageFlag.DAMAGE_SPIKES) or hasbit(flag, DamageFlag.DAMAGE_POOP) then
				return false
			end
		end
		playerhastakendamage = true
		if player:HasCollectible(deal_item) and player:GetNumCoins() > 0 and rng:RandomFloat() < o_deal_greedchance:Value() then
			local penalty = math.floor(rng:RandomFloat() + o_deal_losschance:Value())
			local spawnme = math.min(Random(2, 3), player:GetNumCoins() - penalty)
			player:AddCoins((spawnme + penalty) * -1)
			if spawnme > 0 then
				local room = Game():GetRoom()
				ignoreforsack = true
				for i=1, spawnme do
					local rot = Vector(16, 0):Rotated(rng:RandomFloat() * 360)
					Isaac.Spawn(5, PickupVariant.PICKUP_COIN, 1, room:FindFreePickupSpawnPosition(player.Position + rot, 6, true), rot:Normalized(), player)
				end
				ignoreforsack = false
			end
		end
	elseif inlimbo then
		if entity:GetData().is_uriel_spawn then
			for i, ent in pairs(Isaac.GetRoomEntities()) do
				if ent.Type == 271 then
					return false
				end
			end
		end
	end
end

local function GiveConfusionEffect(tear, _tbl)
	local _te = WeightedRNG(_tbl, rng)
	if _te ~= 0 then
		if not hasbit(tear.TearFlags, _te) then
			tear.TearFlags = tear.TearFlags + _te
		end
	end
end
local icarus_firetear_chance = 0.05
function mod:MC_POST_TEAR_INIT(tear)
	local player = Isaac.GetPlayer(0)
	if (tear.SpawnerType == EntityType.ENTITY_PLAYER or (tear.SpawnerType == EntityType.ENTITY_FAMILIAR and tear.SpawnerVariant == incubusVariant)) then
		if player:HasCollectible(confusion_item) then
			if rng:RandomFloat() < confusionChance:Value() + confusionChanceModifier + player.Luck * 0.075 then
				tear.Color = Color(0.25, 0.25, 1, 1, 0, 0, 0)
				
				GiveConfusionEffect(tear, confusionEffects)
				GiveConfusionEffect(tear, confusionEffects)
				
				GiveConfusionEffect(tear, confusionPathingEffects)
				GiveConfusionEffect(tear, confusionPathingEffects)
				GiveConfusionEffect(tear, confusionPathingEffects)
				GiveConfusionEffect(tear, confusionPathingEffects)
				
				GiveConfusionEffect(tear, confusionExtraEffects)
				
				tear.Velocity = tear.Velocity * (rng:RandomFloat() * 0.2 + 0.8)
				tear.Height = tear.Height * (1 + rng:RandomFloat())
				tear.CollisionDamage = tear.CollisionDamage + (rng:RandomFloat() - 0.75) * 3
				if (tear.CollisionDamage < 0.25) then tear.CollisionDamage = 0.25 end
				
				confusionChanceModifier = -0.1
				if Isaac.GetChallenge() == water_challenge then confusionChanceModifier = 0.15 end
			else
				if confusionChanceModifier < 0 then
					confusionChanceModifier = confusionChanceModifier + 0.05
				else
					confusionChanceModifier = confusionChanceModifier + 0.025
				end
			end
		end
		if player:HasTrinket(nail_trinket) then
			if ((player:IsInvincible() or player:HasInvincibility() or player:GetDamageCooldown() > 0) and tear.SpawnerType == EntityType.ENTITY_PLAYER) or rng:RandomFloat() < nailChance:Value() * player:GetTrinketMultiplier() then
				tear:ChangeVariant(TearVariant.NAIL)
				tear:ChangeVariant(TearVariant.FIRE_MIND)
				if not hasbit(tear.TearFlags, TearFlags.TEAR_PIERCING) then
					tear.TearFlags = tear.TearFlags + TearFlags.TEAR_PIERCING
				end
				if not hasbit(tear.TearFlags, TearFlags.TEAR_BURN) then
					tear.TearFlags = tear.TearFlags + TearFlags.TEAR_BURN
				end
				if not hasbit(tear.TearFlags, TearFlags.TEAR_EXPLOSIVE) then
					tear.TearFlags = tear.TearFlags + TearFlags.TEAR_EXPLOSIVE
				end
				if not hasbit(tear.TearFlags, TearFlags.TEAR_KNOCKBACK) then
					tear.TearFlags = tear.TearFlags + TearFlags.TEAR_KNOCKBACK
				end
			end
		end
	end
	if player:HasCollectible(icarus_item) then
		if icarus_firetear_chance > 0 and rng:RandomFloat() < icarus_firetear_chance + math.min(0.05, math.max(-0.025, player.Luck * 0.015)) then--and tear.Variant ~= TearVariant.FIRE_MIND
			--tear:ChangeVariant(TearVariant.FIRE_MIND)
			if not hasbit(tear.TearFlags, TearFlags.TEAR_BURN) then 
				--tear.TearFlags = tear.TearFlags + TearFlags.TEAR_BURN 
				tear:GetData().is_icarus_tear = true
				--if tear.CollisionDamage > 0.75 then tear.CollisionDamage = math.max(0.75, tear.CollisionDamage - 1) end
				tear.CollisionDamage = 0.1--tear.CollisionDamage * 0.4
				tear.Color = Color(0.9, 0.5, 0.12, 1, 0, 0, 0)
				tear:GetSprite():LoadGraphics()
				icarus_firetear_chance = -0.1
			end
			--if not hasbit(tear.TearFlags, TearFlags.TEAR_GLOW) then tear.TearFlags = tear.TearFlags + TearFlags.TEAR_GLOW end
		elseif icarus_firetear_chance < 0.05 then
			icarus_firetear_chance = math.min(icarus_firetear_chance + 0.02, 0.05)
		end
	end
	if firedelaymod > 0 and player:HasCollectible(hyperfocus_item) then
		local misfire = math.min(4, firedelaymod) * 2 + firedelaymod * 3 + 4
		tear.Velocity = tear.Velocity:Rotated(Random(misfire * -1, misfire))
	end
	if player:HasCollectible(wormbox_item) then
		if (tear.SpawnerType == EntityType.ENTITY_PLAYER or (tear.SpawnerType == EntityType.ENTITY_FAMILIAR and tear.SpawnerVariant == incubusVariant)) then
			if rng:RandomFloat() < confusionChance:Value() * 0.35 then
				local rand = rng:RandomInt(7)
				local w = wormList[rand];
				if w[2] ~= nil and hasbit(tear.TearFlags, w[2]) == false then
					tear.TearFlags = tear.TearFlags + w[2];
				end
			end
			for i, c in ipairs(wormList) do
				if c[2] ~= nil and hasbit(tear.TearFlags, c[2]) then-- and (hasbit(wormtagsdata, c[2]) == false or player:HasTrinket(c[1]) == false)
					tear.CollisionDamage = tear.CollisionDamage * 1.1
				end
			end
		end
	end
	if player:HasCollectible(quantumrock_item) then
		for i=1, player:GetCollectibleNum(quantumrock_item) do
			tear.CollisionDamage = tear.CollisionDamage + o_quantum_dmg:Value()
		end
	end
end

function mod:MC_PRE_TEAR_COLLISION(tear, ent, low)
	if tear:GetData().is_icarus_tear and ent ~= nil and ent:IsVulnerableEnemy() then
		ent:AddBurn(EntityRef(tear), 35, tear.CollisionDamage)
	end
end

function mod:MC_POST_BOMB_INIT(bomb)
	if firedelaymod > 0 then
		local player = Isaac.GetPlayer(0)
		if player:HasWeaponType(WeaponType.WEAPON_BOMBS) and bomb.IsFetus and player:HasCollectible(hyperfocus_item) then
			local misfire = math.min(4, firedelaymod) * 3 + firedelaymod * 2 + 4
			bomb.Velocity = bomb.Velocity:Rotated(Random(misfire * -1, misfire))
		end
	end
end

function mod:MC_POST_KNIFE_UPDATE(knife)
	if firedelaymod > 0 then
		local player = Isaac.GetPlayer(0)
		if player:HasWeaponType(WeaponType.WEAPON_KNIFE) and player:HasCollectible(hyperfocus_item) then
			local data = knife:GetData()
			if not data.knife_was_just_flying then
				if knife:IsFlying() then
					local misfire = math.min(4, firedelaymod) * 2 + firedelaymod * 2 + 2
					knife.Rotation = knife.Rotation + Random(-1*misfire, misfire)
				end
			end
			data.knife_was_just_flying = knife:IsFlying()
		end
	end
end

local function RandomFloatBetween(min, max) 
  return math.random()*(max-min)+min
end

local function RandomSign()
  if math.random()<0.5 then return -1 else return 1 end
end

local function Clamp(val, min, max)
  if val>max then return max end
  if val<min then return min end
  return val
end
function mod:MC_POST_LASER_INIT(laser)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(quantumrock_item) and laser ~= nil and (laser.SpawnerType==EntityType.ENTITY_PLAYER or laser.SpawnerType == EntityType.ENTITY_FAMILIAR) then
		for i=1, player:GetCollectibleNum(quantumrock_item) do
			laser.CollisionDamage = laser.CollisionDamage + o_quantum_dmg:Value()
		end
	end
	if firedelaymod > 0 and not laser:GetData().laser_checked_with_limbo then
		if player:HasCollectible(hyperfocus_item) and (player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) or player:HasWeaponType(WeaponType.WEAPON_LASER) or player:HasWeaponType(WeaponType.WEAPON_TECH_X)) then
			if laser ~= nil and laser.SpawnerType==EntityType.ENTITY_PLAYER and not player:HasWeaponType(WeaponType.WEAPON_TECH_X) then
				local randomizer = 0.5 * math.min(firedelaymod, 3)
				if laser.FrameCount == 0 then 
					randomizer = randomizer * 5
				end
				local limiter = 5 + 5 * math.min(firedelaymod, 3) + 5 * firedelaymod
				laser.Angle = laser.Angle + RandomFloatBetween(randomizer, randomizer*2) * RandomSign()
				local st = laser.StartAngleDegrees
				laser.Angle = Clamp(laser.Angle, st-limiter, st+limiter)
			end
			
			if laser ~= nil and laser.SpawnerType==EntityType.ENTITY_PLAYER and laser:IsCircleLaser() then
				laser:AddVelocity(RandomVector()*RandomFloatBetween(0.5 + 0.1 * firedelaymod, 1.4 + 0.1 * firedelaymod))
			end
		end
	end
end

function mod:MC_POST_PROJECTILE_INIT(projectile)
	if projectile:GetData().spawned_by_reflector then
		if not hasbit(projectile.ProjectileFlags, ProjectileFlags.GHOST) then projectile.ProjectileFlags = projectile.ProjectileFlags + ProjectileFlags.GHOST end
	end
	if projectile.SpawnerEntity == nil then
		local maxDistance = 9999999
		local closest = nil
		for _, ent in pairs(Isaac.GetRoomEntities()) do
			if ent ~= nil and (ent:IsActiveEnemy(true) and ent.Position:Distance(projectile.Position) < maxDistance) then
				maxDistance = ent.Position:Distance(projectile.Position)
				closest = ent;
			end
		end
		if closest ~= nil then
			local data = closest:GetData()
			if data.wormcan ~= nil and not hasbit(projectile.ProjectileFlags, data.wormcan) then
				projectile.ProjectileFlags = projectile.ProjectileFlags + data.wormcan
			end
		end
	end
	--[[
	if Isaac.GetPlayer(0):HasCollectible(deal_item) then
		if not hasbit(projectile.ProjectileFlags, ProjectileFlags.GREED) then
			projectile.ProjectileFlags = projectile.ProjectileFlags + ProjectileFlags.GREED
		end
	end
	]]
end

function mod:MC_POST_PICKUP_INIT(pickup)
	if pickup.Variant == trickvariant then
		local sprite = pickup:GetSprite()
		if pickup.SubType <= 5 then
			sprite:ReplaceSpritesheet(0, "gfx/items/tricks/pickup_001_heart.png")
			sprite:LoadGraphics()
		elseif pickup.SubType <= 6 then
			sprite:ReplaceSpritesheet(0, "gfx/items/tricks/pickup_002_coin_" .. tostring(math.ceil(rng:RandomFloat() + 0.5)) .. ".png")
			sprite:LoadGraphics()
		elseif pickup.SubType <= 9 then
			sprite:ReplaceSpritesheet(0, "gfx/items/tricks/pickup_003_key_" .. tostring(math.ceil(rng:RandomFloat() + 0.5)) .. ".png")
			sprite:LoadGraphics()
		elseif pickup.SubType <= 12 then
			sprite:ReplaceSpritesheet(0, "gfx/items/tricks/pickup_016_bomb_" .. tostring(math.ceil(rng:RandomFloat() + 0.5)) .. ".png")
			sprite:LoadGraphics()
		elseif pickup.SubType == 13 then
			sprite:ReplaceSpritesheet(0, "gfx/items/tricks/pickup_018_littlebattery.png")
			sprite:LoadGraphics()
		end
	end
	if pickup.Variant == PickupVariant.PICKUP_TAROTCARD then
		if pickup.SubType == stone_item then
			local sprite = pickup:GetSprite()
			sprite:Load("gfx/animations/pickups/Philosophers_Stone.anm2", true)
			if not pickup:IsShopItem() then
				sprite:Play("Appear", true)
			else
				sprite:Play("Idle", true)
			end
		end
	end
	if tombroom then
		local room = Game():GetRoom()
		if room:GetFrameCount() > 1 then-- and room:IsClear()
			--Isaac.DebugString("Removed pickup")
			if tombloot > 0 and math.random() < 0.5 then
				tombloot = tombloot - 1
			else
				pickup:Remove()
			end
		end
	end
end
local ignorethesehearts = false
local ignoreforsack = false
local activelimbolist = {
	{head_item, 5},
	{metaldetect_item, 1},
	{runestone_item, 5}
}
activelimbotracker = {}
function mod:MC_POST_PICKUP_SELECTION(pickup, Variant, SubType)
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	--if player == nil then return end
	if inlimbo and room:GetType() == limboroomtype then
		if Variant == 100 or Variant == 150 then--item
			if SubType == CollectibleType.COLLECTIBLE_KEY_PIECE_1 then
				local actitem = WeightedRNG(activelimbolist, rng)
				if not activelimbotracker[actitem] then actitem = WeightedRNG(activelimbolist, rng) end
				if not activelimbotracker[actitem] then actitem = WeightedRNG(activelimbolist, rng) end
				if not activelimbotracker[actitem] then actitem = WeightedRNG(activelimbolist, rng) end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) and not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) then
					return
				end
				if rng:RandomFloat() < 0.5 and not player:HasCollectible(actitem) then
					return {Variant, actitem}
				else
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, WeightedRNG(LimboTrinketPool, rng), room:FindFreePickupSpawnPosition(room:GetCenterPos(), 6, true), Vector(0, 0), nil)
				end
			elseif SubType == CollectibleType.COLLECTIBLE_KEY_PIECE_2 then
				local actitem = WeightedRNG(activelimbolist, rng)
				if not activelimbotracker[actitem] then actitem = WeightedRNG(activelimbolist, rng) end
				if not activelimbotracker[actitem] then actitem = WeightedRNG(activelimbolist, rng) end
				if not activelimbotracker[actitem] then actitem = WeightedRNG(activelimbolist, rng) end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) and not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
					return
				end
				if rng:RandomFloat() < 0.5 and not player:HasCollectible(actitem) then
					return {Variant, actitem}
				else
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, WeightedRNG(LimboTrinketPool, rng), room:FindFreePickupSpawnPosition(room:GetCenterPos(), 6, true), Vector(0, 0), nil)
				end
			end
			return {Variant, GetLimboItem()}
		elseif Variant == PickupVariant.PICKUP_CHEST or 
		Variant == PickupVariant.PICKUP_BOMBCHEST or 
		Variant == PickupVariant.PICKUP_LOCKEDCHEST or 
		Variant == PickupVariant.PICKUP_ETERNALCHEST or 
		Variant == PickupVariant.PICKUP_REDCHEST or 
		Variant == PickupVariant.PICKUP_SPIKEDCHEST then
			return {chestvariant, 0}
		elseif Variant == PickupVariant.PICKUP_TRINKET and room:GetFrameCount() <= 1 then--pickup.SpawnerType ~= 1 and not player:HasTrinket(SubType) then--and not Input.IsActionPressed(ActionTriggers.ACTIONTRIGGER_ITEMSDROPPED, 0)
			local gotem = false
			for i, t in ipairs(LimboTrinketPool) do
				if t[1] == SubType then 
					gotem = true 
					break
				end
			end
			if not gotem then return {Variant, WeightedRNG(LimboTrinketPool, rng)} end
		elseif Variant == PickupVariant.PICKUP_HEART and SubType ~= HeartSubType.HEART_HALF then--Variant == PickupVariant.PICKUP_KEY or 
			if room:GetFrameCount() <= 1 or (rng:RandomFloat() < 0.33 and not ignorethesehearts) then
				return {chestvariant, 0}
			end
			return {PickupVariant.PICKUP_HEART, 1}
		end
	end
	if player:HasTrinket(pebble_trinket) then
		if Variant == PickupVariant.PICKUP_CHEST or 
		Variant == PickupVariant.PICKUP_BOMBCHEST or 
		Variant == PickupVariant.PICKUP_LOCKEDCHEST or 
		Variant == PickupVariant.PICKUP_ETERNALCHEST or 
		(Variant == PickupVariant.PICKUP_REDCHEST and ((not player:HasTrinket(TrinketType.TRINKET_LEFT_HAND)) or rng:RandomFloat() < 0.5)) or 
		Variant == PickupVariant.PICKUP_SPIKEDCHEST then
			return {chestvariant, 0}
		end
	else
		if player:GetName() == "Jahaziel" then
			if room:IsFirstVisit()
			and rng:RandomFloat() < 0.2
			and
			(Variant == PickupVariant.PICKUP_CHEST or 
			Variant == PickupVariant.PICKUP_BOMBCHEST or 
			Variant == PickupVariant.PICKUP_LOCKEDCHEST or 
			(Variant == PickupVariant.PICKUP_REDCHEST and (not player:HasTrinket(TrinketType.TRINKET_LEFT_HAND))) or 
			Variant == PickupVariant.PICKUP_SPIKEDCHEST) then
				return {chestvariant, 0}
			end
		end
		if player:HasCollectible(toothless_item) then
			if room:IsFirstVisit()
			and rng:RandomFloat() < 0.15
			and
			(Variant == PickupVariant.PICKUP_CHEST or 
			Variant == PickupVariant.PICKUP_BOMBCHEST or 
			Variant == PickupVariant.PICKUP_LOCKEDCHEST or 
			(Variant == PickupVariant.PICKUP_REDCHEST and (not player:HasTrinket(TrinketType.TRINKET_LEFT_HAND))) or 
			Variant == PickupVariant.PICKUP_SPIKEDCHEST) then
				return {chestvariant, 0}
			end
		end
	end
	local didoverride = false
	if player:HasCollectible(deal_item) and 
	ignoreforsack == false and
	(room:IsFirstVisit() or (room:GetFrameCount() > 1 and not room:IsClear())) and
	(room:GetFrameCount() <= 1 or not playerhastakendamage)
	then
		if Variant == PickupVariant.PICKUP_COIN and SubType == 1 and rng:RandomFloat() < o_deal_doublechance:Value() + math.max(-0.1, player.Luck * 0.05) then
			SubType = CoinSubType.COIN_DOUBLEPACK
			didoverride = true
		end
	end
	if room:IsFirstVisit() and player:HasCollectible(sack_item) and ignoreforsack == false and rng:RandomFloat() < math.min(0.5, 0.175 - math.min(0.075, player.Luck * 0.03)) then
		--trickvariant
		if Variant == PickupVariant.PICKUP_HEART then
			if SubType == HeartSubType.HEART_FULL or SubType == HeartSubType.HEART_HALF then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 0}
			elseif SubType == HeartSubType.HEART_SOUL then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 4}--1
			elseif SubType == HeartSubType.HEART_BLACK then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 2}
			elseif SubType == HeartSubType.HEART_GOLDEN then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 3}
			elseif SubType == HeartSubType.HEART_HALF_SOUL then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 4}
			elseif SubType == HeartSubType.HEART_BLENDED then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 5}
			end
		elseif Variant == PickupVariant.PICKUP_COIN then
			if SubType == 1 or SubType == CoinSubType.COIN_LUCKYPENNY then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 6}
			end
		elseif Variant == PickupVariant.PICKUP_KEY then
			if SubType == 1 then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 7}
			elseif SubType == KeySubType.KEY_GOLDEN then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 8}
			elseif SubType == KeySubType.KEY_DOUBLEPACK then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 9}
			end
		elseif Variant == PickupVariant.PICKUP_BOMB then
			if SubType == 1 then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 10}
			elseif SubType == BombSubType.BOMB_DOUBLEPACK then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 11}
			elseif SubType == BombSubType.BOMB_GOLDEN then
				sackdumplist[#sackdumplist+1] = {Variant, SubType}
				fakedThisRoom = true
				return {trickvariant, 12}
			end
		elseif Variant == PickupVariant.PICKUP_LIL_BATTERY then
			sackdumplist[#sackdumplist+1] = {Variant, SubType}
			fakedThisRoom = true
			return {trickvariant, 13}
		end
	elseif player:HasCollectible(paw_item) and room:IsFirstVisit() then
		if rng:RandomFloat() < 0.75 - player.Luck * 0.033 and
		(Variant == PickupVariant.PICKUP_COIN or 
		Variant == PickupVariant.PICKUP_KEY or 
		Variant == PickupVariant.PICKUP_LIL_BATTERY or 
		(Variant == PickupVariant.PICKUP_BOMB and SubType ~= BombSubType.BOMB_TROLL and SubType ~= BombSubType.BOMB_SUPERTROLL) or 
		Variant == PickupVariant.PICKUP_HEART)
		then
			local coinscore = player:GetNumCoins() / 3
			if coinscore > 5 then coinscore = (coinscore - 5) / 2 + 5 end
			local bombscore = player:GetNumBombs() / 1.5
			if bombscore > 3 then bombscore = (bombscore - 3) / 3 + 3 end
			local keyscore = player:GetNumKeys()
			local heartscore = (player:GetHearts() - 1) / 1.75
			if player:GetMaxHearts() <= 2 then
				heartscore = (coinscore + bombscore + keyscore) / 1.5
			end
			
			local NewVar = WeightedRNG({
			{PickupVariant.PICKUP_COIN, math.ceil(coinscore + 0.1)},
			{PickupVariant.PICKUP_KEY, math.ceil(keyscore + 0.1)},
			{PickupVariant.PICKUP_BOMB, math.ceil(bombscore + 0.1)},
			{PickupVariant.PICKUP_HEART, math.ceil(heartscore + 0.1)}
			}, rng)
			
			--Isaac.DebugString(coinscore)
			--Isaac.DebugString(keyscore)
			--Isaac.DebugString(bombscore)
			--Isaac.DebugString(heartscore)
			--Isaac.DebugString(NewVar)
			
			if NewVar == Variant then return end
			if SubType == 1 then
				return {NewVar, 1}
			end
			if Variant == PickupVariant.PICKUP_HEART then
				if SubType == HeartSubType.HEART_DOUBLEPACK then
					if NewVar == PickupVariant.PICKUP_HEART then
						return {NewVar, HeartSubType.HEART_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_COIN then
						return {NewVar, CoinSubType.COIN_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_KEY then
						return {NewVar, KeySubType.KEY_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_BOMB then
						return {NewVar, BombSubType.BOMB_DOUBLEPACK}
					end
				end
				if SubType == HeartSubType.HEART_ETERNAL and NewVar == PickupVariant.PICKUP_COIN then
					return {NewVar, CoinSubType.COIN_NICKEL}
				end
				if SubType == HeartSubType.HEART_GOLDEN and NewVar == PickupVariant.PICKUP_COIN then
					return {NewVar, CoinSubType.COIN_DIME}
				end
				return {NewVar, 1}
			end
			if Variant == PickupVariant.PICKUP_COIN then
				if SubType == CoinSubType.COIN_DOUBLEPACK then
					if NewVar == PickupVariant.PICKUP_HEART then
						return {NewVar, HeartSubType.HEART_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_COIN then
						return {NewVar, CoinSubType.COIN_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_KEY then
						return {NewVar, KeySubType.KEY_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_BOMB then
						return {NewVar, BombSubType.BOMB_DOUBLEPACK}
					end
				end
				if SubType == CoinSubType.COIN_NICKEL and NewVar == PickupVariant.PICKUP_HEART then
					return {NewVar, HeartSubType.HEART_ETERNAL}
				end
				if SubType == CoinSubType.COIN_DIME and NewVar == PickupVariant.PICKUP_HEART then
					return {NewVar, HeartSubType.HEART_GOLDEN}
				end
				return {NewVar, 1}
			end
			if Variant == PickupVariant.PICKUP_KEY then
				if SubType == KeySubType.KEY_DOUBLEPACK then
					if NewVar == PickupVariant.PICKUP_HEART then
						return {NewVar, HeartSubType.HEART_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_COIN then
						return {NewVar, CoinSubType.COIN_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_KEY then
						return {NewVar, KeySubType.KEY_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_BOMB then
						return {NewVar, BombSubType.BOMB_DOUBLEPACK}
					end
				end
				if SubType == KeySubType.KEY_GOLDEN and NewVar == PickupVariant.PICKUP_BOMB then
					return {NewVar, BombSubType.BOMB_GOLDEN}
				end
				return {NewVar, 1}
			end
			if Variant == PickupVariant.PICKUP_BOMB then
				if SubType == KeySubType.KEY_DOUBLEPACK then
					if NewVar == PickupVariant.PICKUP_HEART then
						return {NewVar, HeartSubType.HEART_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_COIN then
						return {NewVar, CoinSubType.COIN_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_KEY then
						return {NewVar, KeySubType.KEY_DOUBLEPACK}
					end
					if NewVar == PickupVariant.PICKUP_BOMB then
						return {NewVar, BombSubType.BOMB_DOUBLEPACK}
					end
				end
				if SubType == BombSubType.BOMB_GOLDEN and NewVar == PickupVariant.PICKUP_KEY then
					return {NewVar, KeySubType.KEY_GOLDEN}
				end
				return {NewVar, 1}
			end
			return {NewVar, 1}
		end
		
		if Variant == PickupVariant.PICKUP_CHEST or 
		Variant == PickupVariant.PICKUP_BOMBCHEST or 
		Variant == PickupVariant.PICKUP_LOCKEDCHEST or 
		Variant == PickupVariant.PICKUP_SPIKEDCHEST
		then
			local bombscore = player:GetNumBombs() / 1.5
			if bombscore > 3 then bombscore = (bombscore - 3) / 3 + 3 end
			if bombscore <= 0 then bombscore = -10 end
			local keyscore = player:GetNumKeys()
			if keyscore <= 0 then keyscore = -10 end
			local heartscore = (player:GetHearts() + player:GetSoulHearts() - 1) * 2
			
			local NewVar = WeightedRNG({
			{PickupVariant.PICKUP_BOMBCHEST, math.max(keyscore + heartscore - bombscore * 2, 1)},
			{PickupVariant.PICKUP_LOCKEDCHEST, math.max(bombscore + heartscore - keyscore * 2, 1)},
			{PickupVariant.PICKUP_SPIKEDCHEST, math.max(keyscore + bombscore - heartscore * 2, 1)},
			{PickupVariant.PICKUP_REDCHEST, 3},
			{chestvariant, 3}
			}, rng)
			
			return {NewVar, SubType}
		end
	end
	if player:HasCollectible(mirror_item) and room:IsFirstVisit() and inlimbo == false and
	(
	(Variant == 100 and 
	((room:GetType() == RoomType.ROOM_TREASURE and rng:RandomFloat() < o_mirror_treasure:Value()) or 
	(room:GetType() == RoomType.ROOM_BOSSRUSH and rng:RandomFloat() < 0.33) or 
	(room:GetType() == RoomType.ROOM_BOSS and rng:RandomFloat() < o_mirror_boss:Value()) or 
	(room:GetType() == RoomType.ROOM_CURSE and rng:RandomFloat() < o_mirror_curse:Value()) or 
	(room:GetType() == RoomType.ROOM_CHALLENGE and rng:RandomFloat() < o_mirror_challenge:Value()) or 
	(room:GetType() == RoomType.ROOM_DEVIL and rng:RandomFloat() < o_mirror_devil:Value()) or 
	(room:GetType() == RoomType.ROOM_ANGEL and rng:RandomFloat() < o_mirror_angel:Value())
	)) 
	or (Variant == 150 and room:GetType() == RoomType.ROOM_SHOP and rng:RandomFloat() < o_mirror_shop:Value())
	) then
		if mirrorVal[SubType] ~= nil and mirrorVal[SubType] > 0 and mirrorVal[SubType] < 40 then
			Isaac.DebugString(SubType)
			local val = mirrorVal[SubType]
			local tmin = 1
			local tmax = 10
			if val < 3 then tmin = tmin + 1 end
			if val < 4 then tmin = tmin + 1 end
			if val < 5 then 
				tmax = tmax + 1
				tmin = tmin + 1 
			end
			if val < 25 then tmax = tmax + 1 end
			if val < 20 then
				tmax = tmax + 1
				if val > 4 then tmin = tmin + 1 end
			end
			if val < 15 then tmax = tmax + 1 end
			if val < 10 then tmax = tmax + 1 end
			local newTier = val + Random(tmin, math.min(40 - val, math.max(tmax + math.min(player.Luck, 5), tmin + 2)))
			--[[
			if newTier < 4 then newTier = 4 end
			while newTier < 10 and rng:RandomFloat() < 0.9 do-- + math.min(math.max(player.Luck, -2) * 0.05, 0.09)
				newTier = newTier + 1
			end
			while newTier < 20 and rng:RandomFloat() < 0.75 do-- + math.min(math.max(player.Luck, -3) * 0.05, 0.2)
				newTier = newTier + 1
			end
			while newTier < 40 and rng:RandomFloat() < 0.3 do-- + math.min(math.max(player.Luck, -4) * 0.05, 0.5)
				newTier = newTier + 1
			end
			]]
			while itemTierList[newTier] == nil do 
				newTier = newTier + 1
				if newTier > 40 then return end
			end
			local NewSub = itemTierList[newTier][math.floor(rng:RandomFloat() * #itemTierList[newTier] + 1)]
			Isaac.DebugString(NewSub)
			if type(NewSub) ~= type(0) then
				NewSub = Isaac.GetItemIdByName(NewSub)
			end
			Isaac.DebugString(NewSub)
			for i=0, 2 do
				if NewSub == nil or NewSub <= 0 or player:HasCollectible(NewSub) then
					NewSub = itemTierList[newTier][math.floor(rng:RandomFloat() * #itemTierList[newTier] + 1)]
					if type(NewSub) ~= type(0) then NewSub = Isaac.GetItemIdByName(NewSub) end
				end
			end
			if NewSub ~= nil and NewSub > 0 then
				return {Variant, NewSub}
			end
		end
	end
	if didoverride then
		return {Variant, SubType}
	end
end

local function GetTombChance(player)
	if player == nil then return 0 end
	local chance = 0
	if player:HasCollectible(mirror_item) then chance = chance + 0.75 end
	if player:HasTrinket(beetle_trinket) then chance = chance + 1 * player:GetTrinketMultiplier() end
	if player:GetName() == "Tormented Jahaziel" then chance = chance + 1 end
	
	if player:HasCollectible(paw_item) and chance > 0 then chance = chance + 0.15 end
	
	chance = math.min(chance, 1.5)
	return chance
end

function mod:MC_POST_CURSE_EVAL(curse)
	local player = Isaac.GetPlayer(0)
	if player ~= nil then
		if player:HasCollectible(map_item) then
			if curse == LevelCurse.CURSE_NONE then 
				return WeightedRNG({
					{LevelCurse.CURSE_NONE, math.max(1, math.min(6, 1 + player.Luck))},--more likely for no curse the higher player luck is
					{LevelCurse.CURSE_OF_DARKNESS, 4},
					--{LevelCurse.CURSE_OF_THE_LOST, (5 - math.min(2, player.Luck))},--less likely to get curse of the lost the higher player luck is
					{LevelCurse.CURSE_OF_MAZE, 7},
					{LevelCurse.CURSE_OF_THE_UNKNOWN, 1},
					{LevelCurse.CURSE_OF_BLIND, 1},
					{tomb_curse, 16}
				}, rng)
			else
				if curse == LevelCurse.CURSE_OF_THE_LOST or 
				(curse ~= LevelCurse.CURSE_OF_MAZE and curse ~= LevelCurse.CURSE_OF_DARKNESS and math.random() < 0.75) or
				(curse == LevelCurse.CURSE_OF_DARKNESS and math.random() < 0.67) or
				(curse == LevelCurse.CURSE_OF_MAZE and math.random() < 0.5) then
					return tomb_curse
				end
			end
		else
			local tc = GetTombChance(player)
			if tc > 0 then
				if curse ~= LevelCurse.CURSE_NONE then
					local chance = (1 / (LevelCurse.NUM_CURSES - 1)) * tc
					if math.random() < chance then
						return tomb_curse
					end
				end
			end
		end
	end
end

local batterytoggle = 1
function mod:MC_USE_ITEM(item, rng)
	local player = Isaac.GetPlayer(0)
	if player:GetActiveCharge() == 1 and not player:NeedsCharge() then
		batblok = true
	else
		batblok = false
	end
	if player:HasCollectible(battery_item) and item ~= CollectibleType.COLLECTIBLE_TELEPORT then
		if batterytoggle > 0 then
			batterytoggle = 0
			if batblok then batterytoggle = -1 end
			--player:DischargeActiveItem()
			player:UseActiveItem(item, false, false, false, false)
		else
			batterytoggle = batterytoggle + 1
			if batterytoggle > 0 then
				local mishap = WeightedRNG({
					{0, 15},--nothing
					{1, 4},--random teleport
					{2, 5},--damage player
					{3, 3},--pixelation
					{4, 1},--rando curse
					{5, 4},--high priestess
					{6, 3},--spawn guys
				}, rng)
				--Isaac.DebugString(mishap)
				if mishap == 1 then
					--Game():MoveToRandomRoom(true, 1)
					if not inlimbo then
						player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, false, false, false, false)
					end
				elseif mishap == 2 then
					player:TakeDamage(2, 0, EntityRef(player), 0);
				elseif mishap == 3 then
					Game():AddPixelation(300)
				elseif mishap == 4 then
					Game():GetLevel():AddCurse(WeightedRNG(batterycurses, rng), true)
				elseif mishap == 5 then
					player:UseCard(Card.CARD_HIGH_PRIESTESS)
				elseif mishap == 6 then
					local room = Game():GetRoom()
					for i=0, 7 do
						if room:GetDoor(i) ~= nil then--room:GetDoor(i):GetGridIndex()
							local pos = room:FindFreePickupSpawnPosition(room:GetDoor(i).Position, 6, true)
							if math.random() < 0.5 then
								local newent = Isaac.Spawn(284, 0, 0, pos, Vector(0, 0), nil)
								SetUpCyclopia(newent)
							else
								local newent = Isaac.Spawn(26, 0, 0, pos, Vector(0, 0), nil)
								SetUpMaw(newent)
							end
						end
					end
					--[[
					if room:IsClear() then
						room:SetClear(false)
					end
					]]
				end
			else
				player:UseActiveItem(item, false, false, false, false)
			end
		end
		
	end
end
--wormtagsdata = 0
function mod:MC_EVALUATE_CACHE(player,cacheFlag)
	if cacheFlag == CacheFlag.CACHE_FAMILIARS then
		for _, ent in pairs(Isaac.GetRoomEntities()) do
			if ent.Type == 3 and (ent.Variant == sackvariant or ent.Variant == reflectorvariant) then ent:Remove() end
		end
		for i=1, player:GetCollectibleNum(sack_item) do
			Isaac.Spawn(3, sackvariant, 0, player.Position, Vector(0, 0), player)
			--if not player:HasCollectible(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW) then player:AddCollectible(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW, 0, false) end
		end
		for i=1, player:GetCollectibleNum(scope_item) do
			Isaac.Spawn(3, reflectorvariant, 0, player.Position + Vector(16,0):Rotated(i * 90), Vector(0,0), player)
		end
	end
	if cacheFlag == CacheFlag.CACHE_TEARFLAG then
		if player:HasCollectible(redsea_item) then
			if not hasbit(player.TearFlags, TearFlags.TEAR_PIERCING) then player.TearFlags = player.TearFlags + TearFlags.TEAR_PIERCING end
			if not hasbit(player.TearFlags, TearFlags.TEAR_WIGGLE) then player.TearFlags = player.TearFlags + TearFlags.TEAR_WIGGLE end
			--player.TearFlags = setbit(player.TearFlags, bit(2))
		end
		if player:GetName() == "Jahaziel" then
			if not hasbit(player.TearFlags, TearFlags.TEAR_PERSISTENT) then player.TearFlags = player.TearFlags + TearFlags.TEAR_PERSISTENT end
		end
	end
	if cacheFlag == CacheFlag.CACHE_SPEED then
		if player:HasCollectible(icarus_item) then
			player.MoveSpeed = player.MoveSpeed + 0.1
		end
		if player:HasCollectible(sandals_item) then
			player.MoveSpeed = player.MoveSpeed + 1
		end
		if player:HasCollectible(paw_item) then
			player.MoveSpeed = player.MoveSpeed + 0.05
		end
		if player:HasCollectible(prize_item) then
			for i=1, player:GetCollectibleNum(prize_item) do
				player.MoveSpeed = player.MoveSpeed + 0.1
			end
		end
	elseif cacheFlag == CacheFlag.CACHE_FLYING then
		if player:HasCollectible(icarus_item) then
			player.CanFly = true
		end
	elseif cacheFlag == CacheFlag.CACHE_LUCK then
		if player:HasCollectible(mirror_item) then
			player.Luck = player.Luck - 5
		end
		if player:HasCollectible(prize_item) then
			for i=1, player:GetCollectibleNum(prize_item) do
				player.Luck = player.Luck + 1
			end
		end
		if player:HasCollectible(paw_item) then
			player.Luck = player.Luck + 2
			if player.Luck < 0 then
				player.Luck = player.Luck + 1
			end
		end
	elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
		updatefiredel = true
		--[[if player:HasCollectible(wormbox_item) then
			for i, c in ipairs(wormList) do
				if player:HasTrinket(c[1]) or c[2] ~= nil and hasbit(player.TearFlags, c[2]) then
					player.Damage = player.Damage * (1.0 + (0.1 * player:GetTrinketMultiplier()))
				end
			end
			wormtagsdata = player.TearFlags
		end]]--
		if player:HasCollectible(prize_item) then
			for i=1, player:GetCollectibleNum(prize_item) do
				player.Damage = math.max(player.Damage - 1, math.min(player.Damage, 2))
			end
		end
		if player:HasCollectible(quantumrock_item) then
			for i=1, player:GetCollectibleNum(quantumrock_item) do
				player.Damage = math.max(player.Damage - o_quantum_dmg:Value(), math.min(player.Damage, 1))
			end
		end
		if player:GetName() == "Jahaziel" then
			player.Damage = player.Damage + 1.0
		end
		if player:HasCollectible(belt_item) and Isaac.GetCurseIdByName("Curse of Eternity") ~= nil and Isaac.GetCurseIdByName("Curse of Eternity") > 0 then
			player.Damage = player.Damage + 0.6
			local level = Game():GetLevel()
			if not hasbit(level:GetCurses(), 2 ^ (Isaac.GetCurseIdByName("Curse of Eternity")-1)) then
				level:AddCurse((2 ^ (Isaac.GetCurseIdByName("Curse of Eternity")-1)), true)
			end
		end
		if player:HasCollectible(redsea_item) then
			player.Damage = player.Damage/5
		end
	elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		updatefiredel = true
		if player:HasCollectible(prize_item) then
			for i=1, player:GetCollectibleNum(prize_item) do
				player.ShotSpeed = player.ShotSpeed + 0.1
			end
		end
		if player:HasCollectible(redsea_item) then
			player.ShotSpeed = player.ShotSpeed - 0.1
		end
	elseif cacheFlag == CacheFlag.CACHE_RANGE then
		if player:HasCollectible(prize_item) then
			for i=1, player:GetCollectibleNum(prize_item) do
				player.TearHeight = player.TearHeight - 1
				--player.TearFallingSpeed = player.TearFallingSpeed + 1
			end
		end
		if player:HasCollectible(redsea_item) then
			player.TearHeight = player.TearHeight - 1.25
			player.TearFallingSpeed = player.TearFallingSpeed + 1.25
		end
	elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
		updatefiredel = true
		if player:HasCollectible(prize_item) then
			for i=1, player:GetCollectibleNum(prize_item) do
				player.MaxFireDelay = math.max(player.MaxFireDelay - 1, math.min(player.MaxFireDelay, 1))
			end
		end
		if Isaac.GetChallenge() == water_challenge then 
			player.MaxFireDelay = player.MaxFireDelay + 2
		end
		if player:GetName() == "Jahaziel" then
			player.MaxFireDelay = player.MaxFireDelay + 3
		end
		if player:HasCollectible(redsea_item) then
			player.MaxFireDelay = math.ceil(player.MaxFireDelay/5 - 0.5)
		end
	end
end

function mod:MC_POST_RENDER()
	local player = Isaac.GetPlayer(0)

	
	for i, c in ipairs(costumehandler) do
		if player:HasCollectible(c.item) and c.hasit == false then
			player:AddNullCostume(c.costume)
			c.hasit = true
		elseif player:HasCollectible(c.item) == false and c.hasit then
			player:TryRemoveNullCostume(c.costume)
			c.hasit = false
		end
	end
end

local json = require("json")

local function SavePPData()
	local data = {}
	data.mapComp = mapComp
	data.mapSec = mapSec
	data.bossDoorState = bossDoorState
	data.inlimbo = inlimbo
	data.ActiveLimboItemPool = ActiveLimboItemPool
	data.tombloot = tombloot
	data.tombcounter = tombcounter
	data.qmcounter = qmcounter
	data.qmlist = qmlist
	data.sackdumplist = sackdumplist
	data.builtdeal = builtdeal
	data.firedelaymod = firedelaymod
	data.firedecrease = firedecrease
	data = json.encode(data)
	Isaac.SaveModData(mod, data)
end

local function LoadPPData()
	if Isaac.HasModData(mod) then
		local data = Isaac.LoadModData(mod)
		if data ~= nil then
			data = json.decode(data)
			mapComp = data.mapComp
			mapSec = data.mapSec
			bossDoorState = data.bossDoorState
			inlimbo = data.inlimbo
			ActiveLimboItemPool = data.ActiveLimboItemPool
			tombloot = data.tombloot
			tombcounter = data.tombcounter
			qmcounter = data.qmcounter or 2
			qmlist = data.qmlist or {}
			builtdeal = data.builtdeal
			firedelaymod = data.firedelaymod
			firedecrease = data.firedecrease
			sackdumplist = data.sackdumplist or {}
		end
	else
		OnNewGame()
	end
end

function mod:gameStartSave(fromsave)
	if (fromsave) then
		LoadPPData()
	else
		OnNewGame()
	end
end

function mod:gameExitSave()
	SavePPData()
end

function mod:MC_POST_PLAYER_INIT(player)
	if not hassetup then
		math.randomseed(player.InitSeed)
		rng:SetSeed(player.InitSeed, 3)
		BuildLimboPool()
		BuildActiveLimboPool()
		local eternalcurse = Isaac.GetCurseIdByName("Curse of Eternity")
		if eternalcurse ~= nil and eternalcurse > 0 then
			batterycurses[#batterycurses+1] = {(2 ^ (Isaac.GetCurseIdByName("Curse of Eternity")-1)), 3}
		end
		hassetup = true
	end
end

local angelHealthValues = {
	300,
	300
}
local champtest = 0
function mod:MC_POST_NPC_INIT(ent)
	if inlimbo then
		if (ent.Type == 271 or ent.Type == 272) then
			--angel has spawned!
			for i, e in pairs(Isaac.GetRoomEntities()) do
				if e.Type == 1000 and e.Variant == doorvariant + 1 then
					e:Remove()
				end
			end
			local sprite = ent:GetSprite()
			if ent.Type == 271 then
				sprite:ReplaceSpritesheet(0, "gfx/limbo_enemies/angel.png")
			else
				sprite:ReplaceSpritesheet(0, "gfx/limbo_enemies/angel2.png")
			end
			sprite:LoadGraphics()
			ent.HitPoints = angelHealthValues[ent.Type - 270]
			ent.MaxHitPoints = angelHealthValues[ent.Type - 270]
			if ent.Type == 271 then
				local room = Game():GetRoom()
				local newent = Isaac.Spawn(284, 0, 0, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 6, true), Vector(0, 0), nil)
				--newent:ToNPC():MakeChampion(6)
				local sprite = newent:GetSprite()
				sprite:ReplaceSpritesheet(1, "gfx/limbo_enemies/280.000_cyclopia.png")
				sprite:LoadGraphics()
				newent:GetData().is_uriel_spawn = true
				newent.Mass = newent.Mass * 3
				newent.CollisionDamage = 2
			end
		elseif ent.Type == 38 then
			--angelic baby
			local room = Game():GetRoom()
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 6, true)
			local newent = Isaac.Spawn(26, 0, 0, pos, ent.Velocity, nil)
			
			newent:ToNPC():MakeChampion(WeightedRNG(angelChampionOptions, rng))
			newent.MaxHitPoints = newent.MaxHitPoints * 1.25
			newent.HitPoints = newent.HitPoints * 1.25
			local sprite = newent:GetSprite()
			sprite:ReplaceSpritesheet(0, "gfx/limbo_enemies/monster_141_maw.png")
			sprite:LoadGraphics()
			ent:Remove()
		end
	end
	local player = Isaac.GetPlayer(0)
	if player ~= nil and player:HasCollectible(wormcan_item) then
		if ent:IsChampion() or rng:RandomFloat() < 0.2 then
			local data = ent:GetData()
			data.wormcan = WeightedRNG({
				{ProjectileFlags.WIGGLE, 3},
				{ProjectileFlags.BOOMERANG, 1},
				{ProjectileFlags.SINE_VELOCITY, 3},
				{ProjectileFlags.MEGA_WIGGLE, 3},
				{ProjectileFlags.SAWTOOTH_WIGGLE, 2}
			}, rng)
		end
	end
end

limbochestactivepool = {}

local function OpenLimboChest(ent, player)
	local sprite = ent:GetSprite()
	sprite:Play("Open", true)
	player = player:ToPlayer()
	local room = Game():GetRoom()
	
	local reward
	
	if ent.SubType == 1 then
		reward = "GoldKey"
	elseif ent.SubType == 2 then
		reward = "GoldBomb"
	else
		local limboChestRewards = {
			{"Item", 16},
			{"Trinket", 25},
			{"Hearts", 10},
			{"Cyclopia", 5},
			{"Maw", 5},
			{"Dople", 3},
			{"Bombs", 14},
			{"Spiders", 10},
			{"BigBomb", 12},
			{"GoldKey", 1},
			{"GoldBomb", 1},
			{"Rune", 0}
		}
		if (#limbochestactivepool > 0) then
			limboChestRewards[#limboChestRewards+1] = {"ActiveItem", 2}
		end
		if not player:HasCollectible(compass_item) then
			limboChestRewards[#limboChestRewards+1] = {"Compass", 3}
		end
		if player:HasCollectible(toothless_item) then
			if player:GetName() == "Jahaziel" then
				if not player:HasGoldenKey() then limboChestRewards[#limboChestRewards+1] = {"GoldKey", 4} end
				if not player:HasGoldenBomb() then limboChestRewards[#limboChestRewards+1] = {"GoldBomb", 4} end
			else
				if not player:HasGoldenKey() then limboChestRewards[#limboChestRewards+1] = {"GoldKey", 16} end
				if not player:HasGoldenBomb() then limboChestRewards[#limboChestRewards+1] = {"GoldBomb", 15} end
			end
		end
		if not inlimbo then
			limboChestRewards[#limboChestRewards+1] = {"LimboLight", 2}
		end
		reward = WeightedRNG(limboChestRewards, rng)
	end
	
	if reward == "Item" then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, 100, GetLimboItem(), ent.Position, Vector(0, 0), ent)
	elseif reward == "ActiveItem" then
		local r = rng:RandomInt(1,#limbochestactivepool)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, 100, limbochestactivepool[r], ent.Position, Vector(0, 0), ent)
		table.remove(limbochestactivepool, r)
	elseif reward == "Compass" then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, 100, compass_item, ent.Position, Vector(0, 0), ent)
	elseif reward == "Trinket" then
		local rot = Vector(3, 0):Rotated(rng:RandomFloat() * 360)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, WeightedRNG(LimboTrinketPool, rng), ent.Position + rot, rot, ent)
	elseif reward == "Rune" then
		local rot = Vector(3, 0):Rotated(rng:RandomFloat() * 360)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, 300, stone_item, ent.Position + rot, rot, ent)
	elseif reward == "Hearts" then
		ignorethesehearts = true
		local r = math.ceil(rng:RandomFloat() * 3 - 0.25) + 1
		for i=1, r do
			local rot = Vector(3, 0):Rotated(rng:RandomFloat() * 360)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, WeightedRNG({
				{HeartSubType.HEART_FULL, 5},
				{HeartSubType.HEART_HALF, 5},
				{HeartSubType.HEART_BLENDED, 5}
			}, rng), ent.Position + rot, rot, ent)
		end
		ignorethesehearts = false
	elseif reward == "Cyclopia" then
		local pos = room:FindFreePickupSpawnPosition(ent.Position, 6, true)
		local newent = Isaac.Spawn(284, 0, 0, pos, ent.Velocity, nil)
		SetUpCyclopia(newent)
		--newent:ToNPC():MakeChampion(WeightedRNG(angelChampionOptions, rng))
	elseif reward == "Maw" then
		local pos = room:FindFreePickupSpawnPosition(ent.Position, 6, true)
		local newent = Isaac.Spawn(26, 0, 0, pos, ent.Velocity, nil)
		SetUpMaw(newent)
		--newent.Mass = newent.Mass * 3
	elseif reward == "Dople" then
		local pos = room:FindFreePickupSpawnPosition(ent.Position, 6, true)
		local newent = Isaac.Spawn(53, 11340, 0, pos, ent.Velocity, nil)
	elseif reward == "Bombs" then
		player:UseCard(Card.CARD_TOWER)
	elseif reward == "Spiders" then
		local r = math.ceil(rng:RandomFloat() * 3)
		for i=1, r do
			local rot = Vector(2, 0):Rotated(rng:RandomFloat() * 360)
			Isaac.Spawn(EntityType.ENTITY_SPIDER, 0, 0, room:FindFreePickupSpawnPosition(ent.Position + rot, 6, true), rot, ent)
		end
	elseif reward == "BigBomb" then
		local rot = Vector(2, 0):Rotated(rng:RandomFloat() * 360)
		local pos = room:FindFreePickupSpawnPosition(ent.Position + rot, 6, true)
		local newent = Isaac.Spawn(4, 4, 0, pos, rot, nil)
	elseif reward == "GoldKey" then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN, ent.Position, Vector(0, 0), ent)
	elseif reward == "GoldBomb" then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN, ent.Position, Vector(0, 0), ent)
	elseif reward == "LimboLight" then
		Isaac.Spawn(1000, doorvariant, 0, room:FindFreePickupSpawnPosition(ent.Position, 12, true), Vector(0, 0), ent)
	end
	
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
end


function mod:MC_PRE_PICKUP_COLLISION(pickup, collider, low)
	if pickup.Variant == chestvariant and collider ~= nil and collider.Type == 1 then
		OpenLimboChest(pickup, collider)
		--return false
	elseif pickup.Variant == trickvariant and collider ~= nil and collider.Type == 1 then
		collider:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(collider), 0);
	end
end

function mod:MC_POST_PICKUP_UPDATE(pickup)
	if pickup.Variant == chestvariant then
		if pickup:GetSprite():IsFinished("Open") then
			Isaac.Spawn(5, chestvariant+1, 0, pickup.Position, pickup.Velocity, nil)
			pickup:Remove()
		end
	end
end
local sackBonusItems = {
	{{PickupVariant.PICKUP_BOMB, 1}, 20},
	{{PickupVariant.PICKUP_COIN, 1}, 18},
	{{PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY}, 2},
	{{PickupVariant.PICKUP_KEY, 1}, 20},
	{{PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL}, 8},
	{{PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF}, 9},
	{{PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED}, 3},
	{{PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_STORE_CREDIT}, 1},
	{{300, Card.RUNE_PERTHRO}, 1},
	{{300, Card.CARD_RANDOM}, 1},
	{{chestvariant, 0}, 2}
}
function mod:sack_update(entity)
	local sprite = entity:GetSprite()
	if entity.RoomClearCount == entity.Keys + 1 then
		if (fakedThisRoom == false and #sackdumplist > 0) or #sackdumplist > 1 then--(#sackdumplist > 0 and (sackdumplist[1][1] == 300 or sackdumplist[1][1] == PickupVariant.PICKUP_TRINKET))
			entity.Velocity = Vector(0, 0)
			sprite:Play("Spawn", true)
			ignoreforsack = true
			local spawnme = table.remove(sackdumplist, 1)
			Isaac.Spawn(5, spawnme[1], spawnme[2], Isaac.GetFreeNearPosition(entity.Position, 1), Vector(0, 0), entity)
			ignoreforsack = false
			--[[
			local spawnme = WeightedRNG({
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_STORE_CREDIT}, 10},
				{{EntityType.ENTITY_PICKUP, 300, Card.RUNE_PERTHRO}, 10},
			}, rng)
			Isaac.Spawn(spawnme[1], spawnme[2], spawnme[3], Isaac.GetFreeNearPosition(entity.Position, 1), Vector(0, 0), entity)]]
			while #sackdumplist > 2 do
				ignoreforsack = true
				spawnme = table.remove(sackdumplist, 1)
				Isaac.Spawn(5, spawnme[1], spawnme[2], Isaac.GetFreeNearPosition(entity.Position, 1), Vector(0, 0), entity)
				ignoreforsack = false
			end
			--entity:AddKeys(1)
		end
		if entity.Keys % 6 == 4 then
			sackdumplist[#sackdumplist + 1] = WeightedRNG(sackBonusItems, rng)
		end
		entity:AddKeys(1)
	else
		entity:FollowParent()
		if sprite:IsFinished("Spawn") then
			sprite:Play("FloatDown", true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE , mod.sack_update, sackvariant)

local scope_effects = {
	{{TearFlags.TEAR_CHARM, Color(0.96, 0.1, 0.71, 1, 0, 0, 0)}, 5},
	{{TearFlags.TEAR_BURN, Color(1, 0, 0, 1, 0, 0, 0)}, 5},
	{{TearFlags.TEAR_POISON, Color(0, 1, 0, 1, 0, 0, 0)}, 5},
	{{TearFlags.TEAR_CONFUSION, Color(0.45, 0.18, 0.94, 1, 0, 0, 0)}, 5},
	{{TearFlags.TEAR_FEAR, Color(0.1, 0.1, 0.1, 1, 0, 0, 0)}, 5},
	{{TearFlags.TEAR_CONTINUUM, nil}, 2},
	{{TearFlags.TEAR_HOMING, Color(0, 0, 1, 1, 0, 0, 0)}, 4},
}

function mod:reflector_update(entity)
	entity:MoveDiagonally(0.33)
	if not entity:GetData().reflector_cooldown then entity:GetData().reflector_cooldown = 0 end
	entity:GetData().reflector_cooldown = entity:GetData().reflector_cooldown - 1
	for _, ent in pairs(Isaac.GetRoomEntities()) do
		if not ent:GetData().spawned_by_reflector and not ent:IsDead() then
			
			if ent.Type == EntityType.ENTITY_TEAR and ent.Position:Distance(entity.Position) <= 28 then
				if ent.FrameCount > 4 and (inlimbo or not Game():GetRoom():IsClear()) and entity:GetData().reflector_cooldown <= 0 then
					local v = ProjectileVariant.PROJECTILE_NORMAL
					if ent.Variant == TearVariant.BLUE then
						v = ProjectileVariant.PROJECTILE_TEAR
					elseif ent.Variant == TearVariant.FIRE_MIND then
						v = ProjectileVariant.PROJECTILE_FIRE
					elseif ent.Variant == TearVariant.COIN then
						v = ProjectileVariant.PROJECTILE_COIN
					elseif ent.Variant == TearVariant.MULTIDIMENSIONAL then
						v = ProjectileVariant.PROJECTILE_HUSH
					elseif ent.Variant == TearVariant.BONE then
						v = ProjectileVariant.PROJECTILE_BONE
					end
					local newent = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, v, 0, ent.Position, ent.Velocity * -0.75, entity)
					newent:GetData().spawned_by_reflector = true
					local sprite = newent:GetSprite()
					sprite.Color = Color(math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5, 0.5, 0, 0, 0)
					sprite:LoadGraphics()
					entity:GetData().reflector_cooldown = 50
				end
				ent:GetData().spawned_by_reflector = true
				local tear = ent:ToTear()
				if not hasbit(tear.TearFlags, TearFlags.TEAR_SPECTRAL) then tear.TearFlags = tear.TearFlags + TearFlags.TEAR_SPECTRAL end
				local player = Isaac.GetPlayer(0)
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) or rng:RandomFloat() < 0.67 + math.max(-0.17, player.Luck * 0.1) then
					local bonusEffect = WeightedRNG(scope_effects, rng)
					if not hasbit(tear.TearFlags, bonusEffect[1]) then tear.TearFlags = tear.TearFlags + bonusEffect[1] end
					if bonusEffect[2] ~= nil then 
						tear:GetSprite().Color = bonusEffect[2]
						tear:GetSprite():LoadGraphics()
					end
				end
				--if not hasbit(newent.ProjectileFlags, ProjectileFlags.GHOST) then newent.ProjectileFlags = newent.ProjectileFlags + ProjectileFlags.GHOST end
				--[[
				if hasbit(ent.TearFlags, TearFlags.TEAR_HOMING) and not hasbit(newent.ProjectileFlags, ProjectileFlags.SMART) then
					newent.ProjectileFlags = newent.ProjectileFlags + ProjectileFlags.SMART
				end
				if hasbit(ent.TearFlags, TearFlags.TEAR_EXPLOSIVE) and not hasbit(newent.ProjectileFlags, ProjectileFlags.EXPLODE) then
					newent.ProjectileFlags = newent.ProjectileFlags + ProjectileFlags.EXPLODE
				end
				if (hasbit(ent.TearFlags, TearFlags.TEAR_QUADSPLIT) or ent.Variant == TearVariant.BONE) and not hasbit(newent.ProjectileFlags, ProjectileFlags.BURST) then
					newent.ProjectileFlags = newent.ProjectileFlags + ProjectileFlags.BURST
				end
				if hasbit(ent.TearFlags, TearFlags.TEAR_BOMBERANG) and not hasbit(newent.ProjectileFlags, ProjectileFlags.BOOMERANG) then
					newent.ProjectileFlags = newent.ProjectileFlags + ProjectileFlags.BOOMERANG
				end
				if hasbit(ent.TearFlags, TearFlags.TEAR_WIGGLE) and not hasbit(newent.ProjectileFlags, ProjectileFlags.WIGGLE) then
					newent.ProjectileFlags = newent.ProjectileFlags + ProjectileFlags.WIGGLE
				end
				if hasbit(ent.TearFlags, TearFlags.TEAR_CONTINUUM) and not hasbit(newent.ProjectileFlags, ProjectileFlags.CONTINUUM) then
					newent.ProjectileFlags = newent.ProjectileFlags + ProjectileFlags.CONTINUUM
				end
				]]
			elseif ent.Type == EntityType.ENTITY_PROJECTILE and ent.Position:Distance(entity.Position) <= 32 then
				local v = TearVariant.BLOOD
				if ent.Variant == ProjectileVariant.PROJECTILE_TEAR then
					v = TearVariant.BLUE
				elseif ent.Variant == ProjectileVariant.PROJECTILE_COIN then
					v = TearVariant.COIN
				elseif ent.Variant == ProjectileVariant.PROJECTILE_BONE then
					v = TearVariant.BONE
				end
				ent:GetData().spawned_by_reflector = true
				
				for i=-1, 1 do
					local newent = Isaac.Spawn(EntityType.ENTITY_TEAR, v, 0, ent.Position, ent.Velocity:Rotated(i * 15) * -1, entity):ToTear()
					newent:GetData().spawned_by_reflector = true
					if not hasbit(newent.TearFlags, TearFlags.TEAR_SPECTRAL) then newent.TearFlags = newent.TearFlags + TearFlags.TEAR_SPECTRAL end
					local sprite = newent:GetSprite()
					sprite.Color = Color(math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5, 0.5, 0, 0, 0)
					sprite:LoadGraphics()
				end
				
				--[[
				if hasbit(ent.ProjectileFlags, ProjectileFlags.SMART) and not hasbit(newent.TearFlags, TearFlags.TEAR_HOMING) then
					newent.TearFlags = newent.TearFlags + TearFlags.TEAR_HOMING
				end
				if hasbit(ent.ProjectileFlags, ProjectileFlags.EXPLODE) and not hasbit(newent.TearFlags, TearFlags.TEAR_EXPLOSIVE) then
					newent.TearFlags = newent.TearFlags + TearFlags.TEAR_EXPLOSIVE
				end
				if hasbit(ent.ProjectileFlags, ProjectileFlags.BURST) and not hasbit(newent.TearFlags, TearFlags.TEAR_QUADSPLIT) then
					newent.TearFlags = newent.TearFlags + TearFlags.TEAR_QUADSPLIT
				end
				if hasbit(ent.ProjectileFlags, ProjectileFlags.BOOMERANG) and not hasbit(newent.TearFlags, TearFlags.TEAR_BOMBERANG) then
					newent.TearFlags = newent.TearFlags + TearFlags.TEAR_BOMBERANG
				end
				if hasbit(ent.ProjectileFlags, ProjectileFlags.WIGGLE) and not hasbit(newent.TearFlags, TearFlags.TEAR_WIGGLE) then
					newent.TearFlags = newent.TearFlags + TearFlags.TEAR_WIGGLE
				end
				if hasbit(ent.ProjectileFlags, ProjectileFlags.CONTINUUM) and not hasbit(newent.TearFlags, TearFlags.TEAR_CONTINUUM) then
					newent.TearFlags = newent.TearFlags + TearFlags.TEAR_CONTINUUM
				end
				]]
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE , mod.reflector_update, reflectorvariant)

function mod:use_stone( )
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local keys = player:GetNumKeys()
	local bombs = player:GetNumBombs()
	local coins = player:GetNumCoins()--math.ceil(player:GetNumCoins() * 0.75)
	local hearts = math.floor((player:GetHearts() - 1) / 2)
	local soulhearts = math.ceil(player:GetSoulHearts() / 2)
	
	player:AddKeys(keys * -1)
	player:AddBombs(bombs * -1)
	player:AddCoins(coins * -1)
	player:AddHearts(hearts * -2)
	player:AddSoulHearts(player:GetSoulHearts() * -1)
	
	local iter = math.max(keys, bombs, coins, hearts, soulhearts)
	
	for i=1, iter do
		if keys > 0 then
			local spawnme = WeightedRNG({
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 1}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN}, 10},
			}, rng)
			local pos = room:FindFreePickupSpawnPosition(player.Position, 6, true)
			newent = Isaac.Spawn(spawnme[1], spawnme[2] or 0, spawnme[3] or 0, pos, Vector(0, 0), nil)
			keys = keys - 1
		end
		if bombs > 0 then
			local spawnme = WeightedRNG({
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 1}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN}, 10},
			}, rng)
			local pos = room:FindFreePickupSpawnPosition(player.Position, 6, true)
			newent = Isaac.Spawn(spawnme[1], spawnme[2] or 0, spawnme[3] or 0, pos, Vector(0, 0), nil)
			bombs = bombs - 1
		end
		if hearts > 0 then
			local spawnme = WeightedRNG({
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 1}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.HEART_SCARED, 1}, 3},
				{{EntityType.ENTITY_PICKUP, PickupVariant.HEART_BLENDED, 1}, 1},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_GOLDEN}, 16},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_CHILDS_HEART}, 2},
			}, rng)
			local pos = room:FindFreePickupSpawnPosition(player.Position, 6, true)
			newent = Isaac.Spawn(spawnme[1], spawnme[2] or 0, spawnme[3] or 0, pos, Vector(0, 0), nil)
			hearts = hearts - 1
		end
		if soulhearts > 0 then
			local spawnme = WeightedRNG({
				{{EntityType.ENTITY_PICKUP, PickupVariant.HEART_SOUL, 1}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.HEART_BLACK, 1}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.HEART_BLENDED, 1}, 3},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_GOLDEN}, 20},
			}, rng)
			local pos = room:FindFreePickupSpawnPosition(player.Position, 6, true)
			newent = Isaac.Spawn(spawnme[1], spawnme[2] or 0, spawnme[3] or 0, pos, Vector(0, 0), nil)
			soulhearts = soulhearts - 1
		end
		if coins > 0 then
			local spawnme = WeightedRNG({
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1}, 10},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY}, 25},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_SWALLOWED_PENNY}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_BUTT_PENNY}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_BLOODY_PENNY}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_BURNT_PENNY}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_FLAT_PENNY}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_COUNTERFEIT_PENNY}, 5},
				{{EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_SILVER_DOLLAR}, 5},
			}, rng)
			local pos = room:FindFreePickupSpawnPosition(player.Position, 6, true)
			newent = Isaac.Spawn(spawnme[1], spawnme[2] or 0, spawnme[3] or 0, pos, Vector(0, 0), nil)
			coins = coins - 1
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.use_stone, stone_item)

function mod:MC_GET_CARD(rng,current,playing,runes,onlyrunes)
	if inlimbo then
		return stone_item
	else
		if runes then
			local chance = Card.NUM_CARDS
			if onlyrunes then chance = 12 end
			if rng:RandomInt(chance) == 0 then return stone_item end
		end
	end
	return current
end
--mod:AddCallback(ModCallbacks.MC_GET_CARD, mod.MC_GET_CARD);
function mod:MC_POST_GET_COLLECTIBLE(SelectedCollectible, PoolType, Decrease, Seed)
	if SelectedCollectible == deal_item then
		local room = Game():GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 6, true)
		Isaac.Spawn(5, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_STORE_KEY, pos, Vector(0, 0), nil)
	end
	
--THIS DOESN'T WORK YOU GOTTA ADD A CHECK IN UPDATE LIKE YOU DID WITH DEAL_ITEM!!
	if activelimbotracker[SelectedCollectible] then
		local player = Isaac.GetPlayer(0)
		if player ~= nil then
			if SelectedCollectible == metaldetect_item then
				player:SetActiveCharge(0)
			end
			activelimbotracker[SelectedCollectible] = false
		end
	end
end

--THIS DOESN'T WORK YOU GOTTA ADD A CHECK IN UPDATE LIKE YOU DID WITH DEAL_ITEM!!
function mod:MC_GET_TRINKET(SelectedTrinket, TrinketRNG)
	if (SelectedTrinket == nail_trinket) then
		local player = Isaac.GetPlayer(0)
		if player ~= nil then
			player:TakeDamage(1, 0, EntityRef(player), 0);
		end
	end
end


mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,mod.gameStartSave)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.gameExitSave)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, mod.MC_POST_PICKUP_SELECTION)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.MC_EVALUATE_CACHE)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.MC_POST_UPDATE)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.MC_POST_RENDER)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.MC_POST_TEAR_INIT)
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.MC_PRE_TEAR_COLLISION)
mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, mod.MC_POST_BOMB_INIT)
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.MC_POST_LASER_INIT)
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, mod.MC_POST_KNIFE_UPDATE)
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, mod.MC_POST_PROJECTILE_INIT)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.MC_ENTITY_TAKE_DMG)
mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, mod.MC_POST_CURSE_EVAL)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.MC_POST_NEW_ROOM)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.MC_POST_NEW_LEVEL)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.MC_POST_PLAYER_INIT)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.MC_POST_PICKUP_INIT)
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.MC_POST_NPC_INIT)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.MC_PRE_PICKUP_COLLISION)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.MC_POST_PICKUP_UPDATE)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.MC_USE_ITEM)

local function RR_LimboFindEnemyToReplaceWith0(ent)
	if not ent:IsActiveEnemy(false) then return false end
	if ent:IsBoss() then return false end
	return true
end
local function RR_LimboFindEnemyToReplaceWith1(ent)
	if not ent:IsBoss() then return false end
	if ent.Type == 271 or ent.Type == 272 then return false end
	if ent.Type > 45 and ent.Type <= 52 and ent.Variant >= 1 then return false end
	if ent.MaxHitPoints >= 300 then return false end
	return true
end
local function RR_LimboFindEnemyToReplaceWith2(ent)
	if not ent:IsBoss() then return false end
	if ent.Type == 271 or ent.Type == 272 then return false end
	if ent.Type > 45 and ent.Type <= 52 and ent.Variant < 1 then return false end
	if ent.MaxHitPoints < 300 then return false end
	return true
end

local RR_LimboRoomDesc = {
	Door = {
		--Sprite = "gfx/grid/door_limbodoor_x.png",
		Animation = "gfx/grid/door_limbo_out.anm2",
		--Variant = doorvariant,
		--SubType = 2,
		OverrideReplacements = true
	},
	Backdrop = {
	Name = "Limbo",
	--Name = "10_cathedral",
	Variants = 1,
	ChangeWalls = true
	},
	--[[
	Entity = {
		{
			Find = {
				{271},
				{272}
			},
			Replace = {1000, 11341, 0}
		}
	},
	]]
	Entity_StartOnly = {
		{
			Find = {
				{17, 2},--error keeper
				{1000, 6},--devil statue
				{1000, 9}--angel statue
			},
			Replace = {1000, 11341, 0}
		},
		{
			Find = RR_LimboFindEnemyToReplaceWith1,
			Replace = {
				{46, 5},--sloth
				{47, 10},--lust
				{48, 5},--wrath
				{49, 15},--gluttony
				{50, 5},--greed
				{51, 15},--envy
				{52, 5}--pride
			}
		},
		{
			Find = RR_LimboFindEnemyToReplaceWith2,
			Replace = {
				{{46, 1}, 5},--sloth
				{{47, 1}, 10},--lust
				{{48, 1}, 5},--wrath
				{{49, 1}, 15},--gluttony
				{{50, 1}, 5},--greed
				{{51, 1}, 15},--envy
				{{52, 1}, 5}--pride
			}
		},
		{
			Find = {33, 3},
			Replace = {33, 2}
		}
	}
}

local function RR_LimboCheckCallback(room)
	if inlimbo and room:GetType() == limboroomtype then
		return RR_LimboRoomDesc
	end
end

local function Start_RoomReskinAPI()
	RoomReskinAPI.AddRoomCheckCallback(RR_LimboCheckCallback)
end

local START_FUNC = Start_RoomReskinAPI
if RoomReskinAPI then START_FUNC()
else if not __RoomReskinInit then
__RoomReskinInit={Mod = RegisterMod("RoomReskinAPI", 1.0)}
__RoomReskinInit.Mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if not RoomReskinAPI then
		--Isaac.RenderText("A mod requires the Room Reskin API to run, go get it on the workshop!", 60, 60, 255, 255, 255, 1)
	end
end) end
__RoomReskinInit[#__RoomReskinInit+1]=START_FUNC end


if optionsmod ~= nil and optionsmod.RegisterNewSetting ~= nil then
	StartOptionsAPI()
else
	if optionsmod_init == nil then optionsmod_init = {} end
	optionsmod_init[#optionsmod_init+1] = StartOptionsAPI
end