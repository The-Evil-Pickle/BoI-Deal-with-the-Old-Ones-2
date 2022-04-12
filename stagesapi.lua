stagesystem = RegisterMod("Stages Api", 1)

local GetRoomEntities
local notclearedrooms = {}
local namestreak = Sprite()
namestreak:Load("gfx/ui/ui_streak.anm2", true)
namestreak:Play("TextStay", true)
local bossanim = Sprite()
bossanim:Load("gfx/ui/boss/customversusscreen.anm2", true)
bossanim:Play("Idle", true)

function getScreenCenterPosition()
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

function stagesystem:OptimizedGetEntities()
	GetRoomEntities = Isaac.GetRoomEntities()
end

stagesystem:AddCallback(ModCallbacks.MC_POST_RENDER, stagesystem.OptimizedGetEntities)
stagesystem:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, stagesystem.OptimizedGetEntities)

require "catacombs.lua"

CUSTOM_STAGES = {
	[0] = {
		NAME = "Catacombs",
		NAMESPRITE = {FLOOR1 = "effect_catacombs1_streak.png", FLOOR2 = "effect_catacombs2_streak.png"},
		BACKDROPS = {{NAME = "Catacombs1", VARIANTS = 2}, {NAME = "Catacombs2", VARIANTS = 2}},
		BACKDROPBOSS = nil,
		BRIDGES = "bridge_catacombs.png",
		PITS = "catacombs_pit.png",
		ROCKS = "catacombs_rocks.png",
		ROOMS = "catacombs",
		MUSIC = Isaac.GetMusicIdByName("Catacombs"),
		BOSSMUSIC = nil,
		BOSSES = {
			{NAME="67.1_thehusk", TYPE=EntityType.ENTITY_DUKE, VARIANT=1, SUBTYPE=0},
			{NAME="267.0_darkone", TYPE=EntityType.ENTITY_DARK_ONE, VARIANT=0, SUBTYPE=0},
			{NAME="269.0_polycephalus", TYPE=EntityType.ENTITY_POLYCEPHALUS, VARIANT=0, SUBTYPE=0},
			{NAME="28.2_carrionqueen", TYPE=EntityType.ENTITY_CHUB, VARIANT=2, SUBTYPE=0},
			{NAME="100.1_thewretched", TYPE=EntityType.ENTITY_WIDOW, VARIANT=1, SUBTYPE=0},
			{NAME="68.0_peep", TYPE=EntityType.ENTITY_PEEP, VARIANT=0, SUBTYPE=0},
			{NAME="99.0_gurdyjr", TYPE=EntityType.ENTITY_GURDY_JR, VARIANT=0, SUBTYPE=0},
			{NAME="64.0_pestilence", TYPE=EntityType.ENTITY_PESTILENCE, VARIANT=0, SUBTYPE=0},
			{NAME="thefrail", TYPE=EntityType.ENTITY_PIN, VARIANT=2, SUBTYPE=0},
			{NAME="401.0_thestain", TYPE=EntityType.ENTITY_STAIN, VARIANT=0, SUBTYPE=0},
			{NAME="403.0_theforsaken", TYPE=EntityType.ENTITY_FORSAKEN, VARIANT=0, SUBTYPE=0},
			{NAME="bighorn", TYPE=EntityType.ENTITY_BIG_HORN, VARIANT=0, SUBTYPE=0}
		}
	}
}

CUSTOM_OVERLAYS = {}

StageSystem = {
	GotoNewStage = function(StageId)
		if TypeError("GotoNewStage", 1, 0, StageId) then
			local game = Game()
			local level = game:GetLevel()
			game:GetSeeds():SetStartSeed("")
			StageSystem.nextstage = StageId
			level:SetStage(LevelStage.STAGE2_1, StageType.STAGETYPE_WOTL)
			game:StartStageTransition(true, math.random(13))
		end
	end,
	
	ClearRoomLayout = function()
		local game = Game()
		local room = game:GetRoom()
		for i=1, room:GetGridSize() do
			local grid = room:GetGridEntity(i)
			if grid ~= nil then
				if grid:ToDoor() == nil and grid:ToWall() == nil then room:RemoveGridEntity(i, 0, true) end
			end
		end
		local e = GetRoomEntities
		for i=1, #e do
			if e[i].Type > 9 then e[i]:Remove() end
		end
	end,
	
	ChangeRoomLayout = function(RoomFileName, Type)
		Type = Type or RoomType.ROOM_DEFAULT
		if TypeError("ChangeRoomLayout", 1, "", RoomFileName) and TypeError("ChangeRoomLayout", 2, 0, Type) then
			local game = Game()
			local room = game:GetRoom()
			local level = game:GetLevel()
			local roomfile = load("return CUSTOM_ROOMS_"..string.upper(RoomFileName))()
			local goodroom = false
			local roomssearched = 0
			local rand = math.random(#roomfile)
			while true do
				roomssearched=roomssearched+1
				if roomssearched==1000 then break end
				goodroom = false
				rand = math.random(#roomfile)
				if roomfile[rand].SHAPE == room:GetRoomShape() and roomfile[rand].TYPE == Type then
					goodroom = true
					for i=1, #roomfile[rand] do
						if roomfile[rand][i].ISDOOR then
							if roomfile[rand][i].EXISTS == nil and roomfile[rand][i].SLOT ~= nil then
								if room:GetDoor(roomfile[rand][i].SLOT) ~= nil then
									goodroom = false
								end
							end
						end
					end
				end
				if goodroom then break end
			end
			if roomssearched ~= 1000 then
				for i=1, #roomfile[rand] do
					if not roomfile[rand][i].ISDOOR then
						local isgrid = false
						local tbl = {1000,1001,1300,1497,1496,1495,1494,1490,1500,1900,1930,1931,1940,3000,4000,4500,9000,9100,10000}
						for i2=1, #tbl do if roomfile[rand][i][1].TYPE == tbl[i2] then isgrid = true end end
						if isgrid then
							Isaac.GridSpawn(CorrectGridType(roomfile[rand][i][1].TYPE), roomfile[rand][i][1].VARIANT, VectorToGrid(roomfile[rand][i].GRIDX, roomfile[rand][i].GRIDY), true)
						elseif roomfile[rand][i][1].TYPE ~= 0 then
							if roomfile[rand][i][1].TYPE == 1400 or roomfile[rand][i][1].TYPE == 1410 then roomfile[rand][i][1].TYPE = EntityType.ENTITY_FIREPLACE end
							local npc = Isaac.Spawn(roomfile[rand][i][1].TYPE, roomfile[rand][i][1].VARIANT, roomfile[rand][i][1].SUBTYPE, VectorToGrid(roomfile[rand][i].GRIDX, roomfile[rand][i].GRIDY), Vector(0,0), nil)
							if npc:CanShutDoors() then 
								room:SetClear(false) 
								for num=0, 7 do
									if room:GetDoor(num) ~= nil then
										room:GetDoor(num):Close(true)
									end
								end
							end
						end
					end
				end
				local e = Isaac.GetRoomEntities()
				for i=1, #e do
					if e[i]:IsEnemy() then 
						table.insert(notclearedrooms, {INDEX=level:GetCurrentRoomIndex(), CUSTOM_ROOM=rand})
						break
					end
				end
			end
		end
	end,
	
	ChangeBackdrop = function(Name, Variants)
		local game = Game()
		local room = game:GetRoom()
		Variants = Variants or 1
		if TypeError("ChangeBackdrop", 1, "", Name) and TypeError("ChangeBackdrop", 2, 0, Variants) then
			local npc = Isaac.Spawn(EntityType.ENTITY_EFFECT, 82, 0, Vector(0,0), Vector(0,0), nil)
			local sprite = npc:GetSprite()
			sprite:Load("gfx/backdrop/Backdrop.anm2", true)
			for num=0, 15 do
				sprite:ReplaceSpritesheet(num, "gfx/backdrop/"..Name.."_"..tostring(math.random(Variants))..".png")
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
	end,
	
	ChangeDoors = function(Name, TargetRoomType)
		local game = Game()
		local room = game:GetRoom()
		TargetRoomType = TargetRoomType or RoomType.ROOM_DEFAULT
		if TypeError("ChangeDoors", 1, "", Name) and TypeError("ChangeDoors", 2, 0, TargetRoomType) then
			for i=0, DoorSlot.NUM_DOOR_SLOTS-1 do
				local door = room:GetDoor(i)
				if door ~= nil then
					if door.TargetRoomType == TargetRoomType then
						door.CloseAnimation = Name.."Close"
						door.OpenAnimation = Name.."Open"
						door:Open()
						door:Close(true)
					end
				end
			end
		end
	end,
	
	ChangePits = function(FileNamePit, FileNameBridge)
		if TypeError("ChangeBridges", 1, "", FileNamePit) and TypeError("ChangeBridges", 2, "", FileNameBridge) then
			local game = Game()
			local room = game:GetRoom()
			for i=1, room:GetGridSize() do
				local grid = room:GetGridEntity(i)
				if grid ~= nil then
					if grid:ToPit() then
						local sprite = Sprite()
						sprite:Load("gfx/grid/Pit.anm2", true)
						sprite:ReplaceSpritesheet(0, "gfx/grid/"..FileName)
						sprite:SetFrame("pit", grid.Sprite:GetFrame())
						if grid.State == 1 then
							sprite:ReplaceSpritesheet(1, "gfx/grid/"..FileName)
							sprite:SetOverlayFrame("Bridge", 0)
						end
						sprite:LoadGraphics()
						grid.Sprite = sprite
					end
				end
			end
		end
	end,
	
	ChangeRocks = function(FileName)
		if TypeError("ChangeRocks", 1, "", FileName) then
			local game = Game()
			local room = game:GetRoom()
			for i=1, room:GetGridSize() do
				local grid = room:GetGridEntity(i)
				if grid ~= nil then
					if grid:ToRock() then
						local sprite = Sprite()
						sprite:Load("gfx/grid/Rocks.anm2", true)
						for num=0, 4 do
							sprite:ReplaceSpritesheet(num, "gfx/grid/"..FileName)
						end
						local rockanimations = {"normal", "black", "tinted", "rubble", "alt", "rubble_alt", "bombrock", "big", "superspecial", "ss_broken"}
						for rock=1, #rockanimations do
							if grid.Sprite:IsPlaying(rockanimations[rock]) or grid.Sprite:IsFinished(rockanimations[rock]) then
								sprite:SetFrame(rockanimations[rock], grid.Sprite:GetFrame())
							end
						end
						sprite:LoadGraphics()
						grid.Sprite = sprite
					end
				end
			end
		end
	end,
	
	GetStageIdByName = function(Name)
		if TypeError("GetStageIdByName", 1, "", Name) then
			for i=1, #CUSTOM_STAGES do
				if CUSTOM_STAGES[i].NAME == Name then
					return i
				end
			end
			return nil
		end
	end,
	
	AddStage = function(StageName)
		if TypeError("AddStage", 1, "", StageName) then
			table.insert(CUSTOM_STAGES, {})
			local StageId = #CUSTOM_STAGES
			CUSTOM_STAGES[StageId].NAME = StageName
			CUSTOM_STAGES[StageId].NAMESPRITE = {FLOOR1 = "none.png", FLOOR2 = "none.png"}
			CUSTOM_STAGES[StageId].BACKDROPS = {}
			CUSTOM_STAGES[StageId].BACKDROPBOSS = nil
			CUSTOM_STAGES[StageId].PITS = "none.png"
			CUSTOM_STAGES[StageId].BRIDGES = "none.png"
			CUSTOM_STAGES[StageId].ROCKS = "none.png"
			CUSTOM_STAGES[StageId].ROOMS = "clear"
			CUSTOM_STAGES[StageId].MUSIC = nil
			CUSTOM_STAGES[StageId].BOSSMUSIC = nil
			CUSTOM_STAGES[StageId].BOSSES = {}
			return StageSystem.GetStageIdByName(StageName)
		end
	end,
	
	AddStageBackdrop = function(StageId, Name, Variants)
		Variants = Variants or 1
		if TypeError("AddBackdrop", 1, "", Name) and TypeError("AddStageBackdrop", 2, 0, Variants) then
			local backdroptype = 0
			while true do
				backdroptype = backdroptype + 1
				if CUSTOM_STAGES[StageId]["BACKDROP"..backdroptype] == nil then break end
			end
			table.insert(CUSTOM_STAGES[StageId].BACKDROPS, {NAME = Name, VARIANTS = Variants})
		end
	end,
	
	SetStageBossBackdrop = function(StageId, Name)
		if TypeError("SetBossBackdrop", 1, "", Name) then
			CUSTOM_STAGES[StageId].BACKDROPBOSS = Name
		end
	end,
	
	GetCurrentBackdrop = function()
		local e = GetRoomEntities
		for i=1, #e do
			if e[i]:GetSprite():GetFilename() == "gfx/backdrop/Backdrop.anm2" then
				return e[i]:GetSprite()
			end
		end
	end,
	
	SetStageName = function(StageId, Name)
		if TypeError("SetName", 1, "", Name) then
			CUSTOM_STAGES[StageId].NAME = Name
		end
	end,
	
	SetStageNameSprite = function(StageId, FirstFloor, SecondFloor)
		if TypeError("SetNameSprite", 1, "", FirstFloor) and TypeError("SetStageNameSprite", 2, "", SecondFloor) then
			CUSTOM_STAGES[StageId].NAMESPRITE = {FLOOR1 = FirstFloor, FLOOR2 = SecondFloor}
		end
	end,

	AddOverlay = function(FileName, VELOCITY, OFFSET)
		OFFSET = OFFSET or Vector(0,0)
		if TypeError("AddOverlay", 1, "", FileName) then
			local sprite = Sprite()
			sprite:Load("gfx/backdrop/"..FileName, true)
			sprite:Play("Idle")
			table.insert(CUSTOM_OVERLAYS, {Sprite = sprite, Position = Vector(0,0), Velocity = VELOCITY, Offset = OFFSET})
			return #CUSTOM_OVERLAYS
		end
	end, 
	
	GetOverlayIdByAnm2 = function(OverlayAnm2)
		if TypeError("GetOverlayIdByAnm2", 1, "", OverlayAnm2) then
			for i=1, #CUSTOM_STAGES[StageId].OVERLAYS do 
				if CUSTOM_STAGES[StageId].OVERLAYS[i].Sprite:GetFilename() == OverlayAnm2 then 
					return i 
				end 
			end 
		end
	end,
	
	GetOverlay = function(OverlayId)
		if TypeError("GetOverlay", 1, 0, OverlayId) then
			return {
				Id = OverlayId,
				Sprite = CUSTOM_OVERLAYS[OverlayId].Sprite,
				Position = CUSTOM_OVERLAYS[OverlayId].Position,
				Velocity = CUSTOM_OVERLAYS[OverlayId].Velocity,
				Offset = CUSTOM_OVERLAYS[OverlayId].Offset,
				Render = function()
					overlay = CUSTOM_OVERLAYS[OverlayId]
					local overlayoffset = Vector(0,0)
					overlay.Position = overlay.Position + overlay.Velocity
					overlayoffset = overlay.Position
					if overlayoffset.X < 0 then overlay.Position = Vector(overlayoffset.X+512, overlayoffset.Y) end
					if overlayoffset.Y < 0 then overlay.Position = Vector(overlayoffset.X, overlayoffset.Y+512) end
					if overlayoffset.X > 512 then overlay.Position = Vector(overlayoffset.X-512, overlayoffset.Y) end
					if overlayoffset.Y > 512 then overlay.Position = Vector(overlayoffset.X, overlayoffset.Y-512) end
					overlayoffset = overlay.Position
					overlay.Sprite:Render(Vector(0,0)+overlayoffset+overlay.Offset, Vector(0,0), Vector(0,0))
				end
			}
		end
	end,
	
	SetStageBridges = function(StageId, FileName)
		if TypeError("SetBridges", 1, "", FileName) then
			CUSTOM_STAGES[StageId].BRIDGES = FileName
		end
	end, 

	SetStagePits = function(StageId, FileName)
		if TypeError("SetPits", 1, "", FileName) then
			CUSTOM_STAGES[StageId].PITS = FileName
		end
	end, 

	SetStageRocks = function(StageId, FileName)
		if TypeError("SetRocks", 1, "", FileName) then
			CUSTOM_STAGES[StageId].ROCKS = FileName
		end
	end, 
	
	AddCustomRoomsLua = function(LuaFile)
		if TypeError("AddCustomRoomsLua", 1, "", LuaFile) then
			require(LuaFile)
		end
	end,
	
	SetStageCustomRooms = function(StageId, FileName)
		if TypeError("SetCustomRooms", 1, "", FileName) then
			CUSTOM_STAGES[StageId].ROOMS = FileName
		end
	end, 
	
	SetStageMusic = function(StageId, MusicId)
		if TypeError("SetMusic", 1, 0, MusicId) then
			CUSTOM_STAGES[StageId].MUSIC = MusicId
		end
	end,
	
	SetStageBossMusic = function(Stageid, MusicId)
		if TypeError("SetBossMusic", 1, 0, MusicId) then
			CUSTOM_STAGES[StageId].BOSSMUSIC = MusicId
		end
	end,
	
	AddStageBoss = function(StageId, Name, Type, Variant, SubType)
		Variant = Variant or 0
		SubType = SubType or 0
		if TypeError("AddBoss", 1, "", Name) and TypeError("AddBoss", 2, 0, Type) and  TypeError("AddBoss", 3, 0, Variant) then
			table.insert(CUSTOM_STAGES[StageId].BOSSES, {NAME = Name, TYPE = Type, VARIANT = Variant, SUBTYPE = SubType})
		end
	end,
	
	RemoveStageBoss = function(StageId, Name)
		if TypeError("RemoveBoss", 1, "", Name) then
			for i=1, #CUSTOM_STAGES[StageId].BOSSES do
				if CUSTOM_STAGES[StageId].BOSSES[i].NAME == Name then
					table.remove(CUSTOM_STAGES[StageId].BOSSES, i)
				end
			end
		end
	end,

	GetStageNameById = function(StageId)
		if TypeError("GetStageNameById", 1, 0, StageId) then
			return CUSTOM_STAGES[StageId].NAME
		end
	end,

	GetStagesCount = function()
		return #CUSTOM_STAGES 
	end,
	
	ShowVSScreen = function()
		bossanim:Play("Scene", true)
	end,
	
	GetStb = function(Name)
		if TypeError("GetSTB", 1, "", Name) then
			local tbl = load("return CUSTOM_ROOMS_"..string.upper(Name))() or {}
			if not tbl.exists then
				tbl.exists = true
				tbl.Room = function(RoomId) 
					if TypeError("Room", 1, 0, RoomId) then
						load("return CUSTOM_ROOMS_"..string.upper(Name))()[RoomId].ID = RoomId
						return load("return CUSTOM_ROOMS_"..string.upper(Name))()[RoomId]
					end
				end
				tbl.CreateRoom = function(Name, Type, Shape)
					if TypeError("CreateRoom", 1, "", Name) and TypeError("CreateRoom", 2, 0, Type) and TypeError("CreateRoom", 3, 0, Shape) then
						local clearroom = CUSTOM_ROOMS_CLEAR[Shape]
						clearroom.TYPE = Type
						clearroom.NAME = Name
						table.insert(load("return CUSTOM_ROOMS_"..string.upper(Name))(), clearroom)
						return #load("return CUSTOM_ROOMS_"..string.upper(Name))()
					end
				end
				tbl.GetRoomIdByName = function(Name)
					if TypeError("GetRoomIdByName", 1, "", Name) then
						for i, v in ipairs(load("return CUSTOM_ROOMS_"..string.upper(Name))()) do
							if Name == v then return i end
						end
					end
				end
			end
			return tbl
		end
	end,
	
	currentstage = 0,
	nextstage = nil,
	musicsettedup = false,
	bossdefeated = false,
	bosssettedup = false,
	visitedrooms = {},
	firstvisit = nil,
	currentboss = nil
}

StageSystem.ChangeCurrentBoss = function(Name, Type, Variant, SubType)
	Variant = Variant or 0
	SubType = SubType or 0
	if TypeError("ChangeCurrentBoss", 1, "", Name) and TypeError("ChangeCurrentBoss", 2, 0, Type) and TypeError("ChangeCurrentBoss", 3, 0, Variant) then
		StageSystem.currentboss.Name = Name
		StageSystem.currentboss.Type = Type
		StageSystem.currentboss.Variant = Variant
	end
end

StageSystem.GetCurrentStage = function()
	return StageSystem.currentstage
end

StageSystem.GetCurrentBossName = function()
	return StageSystem.currentboss.Name
end

StageSystem.GetCurrentBossType = function()
	return StageSystem.currentboss.Type
end

StageSystem.GetCurrentBossVariant = function()
	return StageSystem.currentboss.Variant
end

StageSystem.GetCurrentBossSubType = function()
	return StageSystem.currentboss.SubType
end

StageSystem.GetStage = function(StageId)
	return {
		AddBackdrop = function(Name ,Variants) return StageSystem.AddStageBackdrop(StageId, Name, Variants) end,
		SetBossBackdrop = function(Name) return StageSystem.SetStageBossBackdrop(StageId, Name) end,
		SetName = function(Name) return StageSystem.SetStageName(StageId, Name) end,
		SetNameSprite = function(FirstFloor, SecondFloor) return StageSystem.SetStageNameSprite(StageId, FirstFloor, SecondFloor) end,
		SetBridges = function(FileName) return StageSystem.SetStageBridges(StageId, FileName) end,
		SetPits = function(FileName) return StageSystem.SetStagePits(StageId, FileName) end,
		SetRocks = function(FileName) return StageSystem.SetStageRocks(StageId, FileName) end,
		SetMusic = function(MusicId) return StageSystem.SetStageMusic(StageId, MusicId) end,
		SetBossMusic = function(MusicId) return StageSystem.SetStageBossMusic(StageId, MusicId) end,
		AddBoss = function(Name, Type, Variant, Subtype) return StageSystem.AddStageBoss(StageId, Name, Type, Variant, SubType) end,
		RemoveBoss = function(Name) return StageSystem.RemoveStageBoss(StageId, Name) end,
		SetRoomFile = function(FileName) return StageSystem.SetStageCustomRooms(StageId, FileName) end,
		GetName = function() return CUSTOM_STAGES[StageId].NAME end,
		GetNameSprite = function(Floor) if TypeError("GetNameSprite", 1, 0, Floor) then return CUSTOM_STAGES[StageId].NAMESPRITE["FLOOR"..Floor] end end,
		GetBackdropName = function(BackdropId) if TypeError("GetBackdropName", 1, 0, BackdropId) then return CUSTOM_STAGES[StageId].BACKDROPS[BackdropId].NAME end end,
		GetBackdropVariants = function(BackdropId) if TypeError("GetBackdropVariants", 1, 0, BackdropId) then return CUSTOM_STAGES[StageId].BACKDROPS[BackdropId].VARIANTS end end,
		GetBackdropId = function(BackdropName) if TypeError("GetBackdropId", 1, 0, BackdropName) then for i=1, 100 do if CUSTOM_STAGES[StageId].BACKDROPS[i].NAME == BackdropName then return i end end end end,
		GetBridges = function() return CUSTOM_STAGES[StageId].BRIDGES end,
		GetPits = function() return CUSTOM_STAGES[StageId].PITS end,
		GetRocks = function() return CUSTOM_STAGES[StageId].ROCKS end,
		GetRoomFile = function() return CUSTOM_STAGES[StageId].ROOMS end,
		GetMusic = function() return CUSTOM_STAGES[StageId].MUSIC end,
		GetBossMusic = function() return CUSTOM_STAGES[StageId].BOSSMUSIC end,
		GetBoss = function(Name) if TypeError("GetBoss", 1, "", Name) then for i=1, #CUSTOM_STAGES[StageId].BOSSES do if Name == CUSTOM_STAGES[StageId].BOSSES[i].NAME then return true end end return false end end,
		Id = StageId
	}
end

abpp = require "ab++"

function Room.inst:IsFirstVisit() return StageSystem.firstvisit end

function stagesystem:SettingUpStage1()
	namestreak:Update()
	namestreak:LoadGraphics()
	bossanim:Update()
	bossanim:LoadGraphics()
	for i=1, #CUSTOM_OVERLAYS do
		CUSTOM_OVERLAYS[i].Sprite:Update()
		CUSTOM_OVERLAYS[i].Sprite:LoadGraphics()
	end
	local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local e = GetRoomEntities
	if room:GetType() == RoomType.ROOM_BOSS then
		StageSystem.bossdefeated = true
	end
	for i=1, #e do
		if room:GetType() == RoomType.ROOM_BOSS then
			if e[i]:IsBoss() then StageSystem.bossdefeated = false end
		end
	end
	for i=16, room:GetGridSize()-16 do
		local grid = room:GetGridEntity(i)
		if grid ~= nil then
			if grid:ToPit() ~= nil and grid.State == 1 and not (grid.Sprite:IsOverlayPlaying("Bridge") or grid.Sprite:IsOverlayFinished("Bridge")) then
				local sprite = Sprite()
				sprite:Load("gfx/grid/Pit.anm2", true)
				sprite:ReplaceSpritesheet(0, "gfx/grid/"..CUSTOM_STAGES[StageSystem.currentstage].PITS)
				sprite:SetFrame("pit", grid.Sprite:GetFrame())
				sprite:ReplaceSpritesheet(1, "gfx/grid/"..CUSTOM_STAGES[StageSystem.currentstage].BRIDGES)
				sprite:SetOverlayFrame("Bridge", 0)
				sprite:LoadGraphics()
				grid.Sprite = sprite
			end
		end
	end
	if room:IsClear() and room:GetFrameCount() > 1 then
		for i=1, #notclearedrooms do
			if notclearedrooms[i].INDEX == level:GetCurrentRoomIndex() then table.remove(notclearedrooms, i) end
		end
	end
	if namestreak:IsFinished("Text") then namestreak:Play("TextStay") end
end

function stagesystem:SettingUpStage2()
	math.randomseed(Isaac.GetTime())
	local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	if namestreak:IsPlaying("Text") then
		namestreak:Render(getScreenCenterPosition()+Vector(0,90), Vector(0,0), Vector(0,0))
	end
	-- when the player is in a new stage
	if level:GetStage() == LevelStage.STAGE2_1 or level:GetStage() == LevelStage.STAGE2_2 then
		if level:GetStageType() == StageType.STAGETYPE_WOTL then
			-- music
			local musicid = CUSTOM_STAGES[StageSystem.currentstage].MUSIC
			if musicid ~= nil then
				if MusicManager():GetCurrentMusicID() ~= musicid and room:GetType() == RoomType.ROOM_DEFAULT and (level:GetCurrentRoomIndex() ~= level:GetStartingRoomIndex() or not room:IsFirstVisit()) and MusicManager():GetCurrentMusicID() ~= 8 and MusicManager():GetCurrentMusicID() ~= 93 and MusicManager():GetCurrentMusicID() ~= 95 and MusicManager():GetCurrentMusicID() ~= 96 then
					MusicManager():Play(musicid, 0.1)
					MusicManager():Queue(musicid)
					MusicManager():UpdateVolume()
				end
				if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() and room:GetFrameCount() == 1 and not StageSystem.musicsettedup then
					MusicManager():Fadein(musicid, 0.1)
					MusicManager():Queue(musicid)
					MusicManager():UpdateVolume()
				end
			end
			if room:GetType() == RoomType.ROOM_BOSS and not StageSystem.bossdefeated and room:GetFrameCount() == 1 then
				bossanim:Play("Scene", true)
			end
			if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() and room:GetFrameCount() == 1 and not StageSystem.musicsettedup then
				if level:GetStage() == LevelStage.STAGE2_1 and CUSTOM_STAGES[StageSystem.currentstage].NAMESPRITE.FLOOR1 ~= nil then
					namestreak:ReplaceSpritesheet(0, "gfx/ui/"..CUSTOM_STAGES[StageSystem.currentstage].NAMESPRITE.FLOOR1)
				elseif level:GetStage() == LevelStage.STAGE2_2 and CUSTOM_STAGES[StageSystem.currentstage].NAMESPRITE.FLOOR2 ~= nil then
					namestreak:ReplaceSpritesheet(0, "gfx/ui/"..CUSTOM_STAGES[StageSystem.currentstage].NAMESPRITE.FLOOR2)
				end
				namestreak:ReplaceSpritesheet(1, "gfx/ui/none.png")
				namestreak:Play("Text")
				StageSystem.musicsettedup = true
			end
			local bossinroom = false
			local e = Isaac.GetRoomEntities()
			for i=1, #e do 
				if e[i]:IsBoss() then bossinroom = true end 
			end
			-- adding boss
			if room:GetType() == RoomType.ROOM_BOSS and room:GetFrameCount() < 1 and not bossinroom and not StageSystem.bossdefeated then
				local e = GetRoomEntities
				for i=1, #e do 
					if e[i].Type == EntityType.ENTITY_PICKUP and e[i].Variant == PickupVariant.PICKUP_COLLECTIBLE then
						e[i]:Remove()
					end
				end
				local bosses = CUSTOM_STAGES[StageSystem.currentstage].BOSSES
				local rand = math.random(#bosses)
				room:SetClear(false)
				Isaac.Spawn(StageSystem.GetCurrentBossType(), StageSystem.GetCurrentBossVariant(), 0, room:GetCenterPos(), Vector(0,0), nil)
				local musicid = CUSTOM_STAGES[StageSystem.currentstage].BOSSMUSIC or 9
				MusicManager():Play(musicid, 0.1)
				MusicManager():Queue(musicid)
				MusicManager():UpdateVolume()
				for i=16, room:GetGridSize()-16 do
					if room:GetGridEntity(i) ~= nil then
						if room:GetGridEntity(i):ToTrapdoor() ~= nil then 
							room:RemoveGridEntity(i, 0, false) 
							break
						end
					end
				end
			elseif room:GetType() == RoomType.ROOM_BOSS and not StageSystem.bossdefeated then
				for i=0, 4 do
					local door = room:GetDoor(i)
					if door ~= nil then
						if door.TargetRoomType == RoomType.ROOM_DEVIL or door.TargetRoomType == RoomType.ROOM_ANGEL then
							room:RemoveDoor(i)
						else door:Close() end
					end
				end
			end
			if bossanim:IsPlaying("Scene") then
				local name = player:GetName()
				if name == "???" then name = "bluebaby" end
				name = string.gsub(name, "%s+", "")
				bossanim:ReplaceSpritesheet(6, "gfx/ui/boss/bossname_"..string.lower(string.gsub(StageSystem.GetCurrentBossName(), "%s+", ""))..".png")
				bossanim:ReplaceSpritesheet(5, "gfx/ui/boss/playername_"..string.lower(name)..".png")
				bossanim:ReplaceSpritesheet(4, "gfx/ui/boss/playerportrait_"..string.lower(name)..".png")
				bossanim:ReplaceSpritesheet(3, "gfx/ui/boss/portrait_"..string.lower(string.gsub(StageSystem.GetCurrentBossName(), "%s+", ""))..".png")
				bossanim:LoadGraphics()
				bossanim:Render(getScreenCenterPosition(), Vector(0,0), Vector(0,0))
			end
		end
	end
end

function stagesystem:OnNewRoom()
	local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local firstvisit = 0
	for i=1, #StageSystem.visitedrooms do
		if level:GetCurrentRoomIndex() == StageSystem.visitedrooms[i] then firstvisit = firstvisit+1 end
	end
	if firstvisit > 0 then StageSystem.firstvisit = false
	else StageSystem.firstvisit = true end
	if level:GetStage() == LevelStage.STAGE2_1 or level:GetStage() == LevelStage.STAGE2_2 then
		if level:GetStageType() == StageType.STAGETYPE_WOTL then
			if firstvisit == 1 then StageSystem.firstvisit = true end
		end
	end
	if StageSystem.firstvisit then table.insert(StageSystem.visitedrooms, level:GetCurrentRoomIndex()) end
	for i=1, room:GetGridSize() do
		local grid = room:GetGridEntity(i)
		if grid ~= nil then
			if grid:ToDecoration() == nil and grid:ToWall() == nil and grid:ToDoor() == nil then
				StageSystem.firstvisit = false
				break
			end 
		end
	end
	if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() and room:IsFirstVisit() and firstvisit == 0 then
		if StageSystem.nextstage ~= nil then
			StageSystem.currentstage = StageSystem.nextstage
		end
	end
	-- when the player is in a new stage
	if level:GetStage() == LevelStage.STAGE2_1 or level:GetStage() == LevelStage.STAGE2_2 then
		-- if the room isn't setup yet
		if level:GetStageType() == StageType.STAGETYPE_WOTL then
			if room:GetType() == RoomType.ROOM_DEFAULT or room:GetType() == RoomType.ROOM_TREASURE or room:GetType() == RoomType.ROOM_BOSS or room:GetType() == RoomType.ROOM_MINIBOSS then
				-- adding the backdrop
				if #CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS ~= 0 then 
					backdroptype = math.random(#CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS)
					local npc = Isaac.Spawn(EntityType.ENTITY_EFFECT, 82, 0, Vector(0,0), Vector(0,0), nil)
					local sprite = npc:GetSprite()
					sprite:Load("gfx/backdrop/Backdrop.anm2", true)
					if room:GetType() ~= RoomType.ROOM_BOSS or CUSTOM_STAGES[StageSystem.currentstage].BACKDROPBOSS == nil then
						for num=0, 15 do
							sprite:ReplaceSpritesheet(num, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].NAME.."_"..tostring(math.random(CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].VARIANTS))..".png")
						end
					else
						for num=0, 15 do
							sprite:ReplaceSpritesheet(num, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPBOSS..".png")
						end
					end
					sprite:ReplaceSpritesheet(16, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].NAME.."_nfloor.png")
					sprite:ReplaceSpritesheet(17, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].NAME.."_nfloor.png")
					sprite:ReplaceSpritesheet(18, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].NAME.."_lfloor.png")
					sprite:ReplaceSpritesheet(19, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].NAME.."_lfloor.png")
					sprite:ReplaceSpritesheet(20, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].NAME.."_lfloor.png")
					sprite:ReplaceSpritesheet(21, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].NAME.."_lfloor.png")
					sprite:ReplaceSpritesheet(22, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].NAME.."_lfloor.png")
					sprite:ReplaceSpritesheet(23, "gfx/backdrop/"..CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[backdroptype].NAME.."_corner.png")
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
				-- textures for doors
				for i=0, DoorSlot.NUM_DOOR_SLOTS-1 do
					local door = room:GetDoor(i)
					if door ~= nil then
						if room:GetType() == RoomType.ROOM_DEFAULT or room:GetType() == RoomType.ROOM_MINIBOSS or room:GetType() == RoomType.ROOM_SACRIFICE then
							if door.TargetRoomType == RoomType.ROOM_DEFAULT or door.TargetRoomType == RoomType.ROOM_MINIBOSS or door.TargetRoomType == RoomType.ROOM_SACRIFICE then
								door.CloseAnimation = CUSTOM_STAGES[StageSystem.currentstage].NAME.."Close"
								door.OpenAnimation = CUSTOM_STAGES[StageSystem.currentstage].NAME.."Open"
								door:Open()
								door:Close(true)
							end
						end
					end
				end
				-- making the custom rooms
				if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_DEFAULT and level:GetCurrentRoomIndex() ~= level:GetStartingRoomIndex() and firstvisit ~= 1 then
					StageSystem.ChangeRoomLayout(CUSTOM_STAGES[StageSystem.currentstage].ROOMS)
				elseif room:IsFirstVisit() and room:GetType() == RoomType.ROOM_BOSS then
					StageSystem.ClearRoomLayout()
				elseif room:GetType() == RoomType.ROOM_DEFAULT and level:GetCurrentRoomIndex() ~= level:GetStartingRoomIndex() and firstvisit == 1 then
					local e = GetRoomEntities
					for i=1, #e do
						if e[i].Type == EntityType.ENTITY_PICKUP and (e[i].Position-room:GetCenterPos()):Length() <= 50 then
							e[i]:Remove()
						end
					end
					for i1=1, #notclearedrooms do
						local roomfile = load("return CUSTOM_ROOMS_"..string.upper(CUSTOM_STAGES[StageSystem.currentstage].ROOMS))()
						local customroom = notclearedrooms[i1].CUSTOM_ROOM
						for i2=1, #roomfile[customroom] do
							if not roomfile[customroom][i2].ISDOOR then
								if roomfile[customroom][i2][1].TYPE ~= 0 and roomfile[customroom][i2][1].TYPE < 1000 then
									if roomfile[customroom][i2][1].TYPE ~= EntityType.ENTITY_FIREPLACE and roomfile[customroom][i2][1].TYPE ~= EntityType.ENTITY_MOVABLE_TNT and roomfile[customroom][i2][1].TYPE ~= EntityType.ENTITY_SHOPKEEPER and roomfile[customroom][i2][1].TYPE ~= EntityType.ENTITY_POOP and roomfile[customroom][i2][1].TYPE ~= EntityType.ENTITY_SLOT then
										local npc = Isaac.Spawn(roomfile[customroom][i2][1].TYPE, roomfile[customroom][i2][1].VARIANT, roomfile[customroom][i2][1].SUBTYPE, VectorToGrid(roomfile[customroom][i2].GRIDX, roomfile[customroom][i2].GRIDY), Vector(0,0), nil)
										if npc:CanShutDoors() then 
											room:SetClear(false) 
											for num=0, 7 do
												if room:GetDoor(num) ~= nil then
													room:GetDoor(num):Close(true)
												end
											end
										end
									end
								end
							end
						end
					end
				end
				-- gridentity textures
				for i=1, room:GetGridSize() do
					local grid = room:GetGridEntity(i)
					if grid ~= nil then
						if grid:ToPit() then
							local sprite = Sprite()
							sprite:Load("gfx/grid/Pit.anm2", true)
							for num=0, 4 do
								sprite:ReplaceSpritesheet(num, "gfx/grid/"..CUSTOM_STAGES[StageSystem.currentstage].PITS)
							end
							sprite:SetFrame("pit", grid.Sprite:GetFrame())
							sprite:LoadGraphics()
							grid.Sprite = sprite
						elseif grid:ToRock() then
							local sprite = Sprite()
							sprite:Load("gfx/grid/Rocks.anm2", true)
							for num=0, 4 do
								sprite:ReplaceSpritesheet(num, "gfx/grid/"..CUSTOM_STAGES[StageSystem.currentstage].ROCKS)
							end
							local rockanimations = {"normal", "black", "tinted", "alt", "bombrock", "big", "superspecial", "ss_broken"}
							for rock=1, #rockanimations do
								if grid.Sprite:IsPlaying(rockanimations[rock]) or grid.Sprite:IsFinished(rockanimations[rock]) then
									sprite:SetFrame(rockanimations[rock], grid.Sprite:GetFrame())
								end
							end
							sprite:LoadGraphics()
							grid.Sprite = sprite
						end
					end
				end
			end
			if room:IsFirstVisit() and firstvisit ~= 1 and room:GetType() ~= RoomType.ROOM_MINIBOSS then
				game:ChangeRoom(level:GetCurrentRoomIndex())
			end
			if not StageSystem.bosssettedup and room:GetType() == RoomType.ROOM_BOSS then
				StageSystem.bosssettedup = true
				game:ChangeRoom(level:GetCurrentRoomIndex())
			end
		end
	elseif room:IsFirstVisit() and level:GetCurrentRoomIndex() ~= level:GetStartingRoomIndex() then
		customdoordir = nil
	end
	local e = Isaac.GetRoomEntities()
	for i=1, #e do
		if e[i].Type == EntityType.ENTITY_EFFECT and e[i].Variant == 8 then
			if e[i]:GetSprite():GetFilename() == "gfx/grid/pit.anm2" or e[i]:GetSprite():GetFilename() == "gfx/grid/Rocks.anm2" then
				if room:GetGridEntity(room:GetGridIndex(e[i].Position)) ~= nil then
					if room:GetGridEntity(room:GetGridIndex(e[i].Position)).State == 2 then
						e[i]:Remove()
					end
				else e[i]:Remove() end
			end
		end
	end
end

function stagesystem:OnNewLevel()
	local player = Isaac.GetPlayer(0)
	local game = Game()
	local level = game:GetLevel()
	StageSystem.musicsettedup = false
	StageSystem.bossdefeated = false
	StageSystem.bosssettedup = false
	StageSystem.visitedrooms = {}
	notclearedrooms = {}
	StageSystem.currentboss = nil
	if level:GetStage() ~= LevelStage.STAGE1_1 then player:AnimateAppear() end
	if level:GetStageType() ~= StageType.STAGETYPE_WOTL and level:GetStage() == LevelStage.STAGE2_2 then
		StageSystem.nextstage = StageSystem.currentstage
		Isaac.ExecuteCommand("stage 4a")
	else
		if level:GetStage() ~= LevelStage.STAGE2_1 and level:GetStage() ~= LevelStage.STAGE2_2 then
			StageSystem.nextstage = nil
			StageSystem.currentstage = 0
		end
		if (level:GetStage() ~= LevelStage.STAGE2_1 or level:GetStage() ~= LevelStage.STAGE2_2) and level:GetStageType() ~= StageType.STAGETYPE_WOTL then
			StageSystem.nextstage = nil
			StageSystem.currentstage = 0
		end
		if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then
            if StageSystem.nextstage ~= nil then
                StageSystem.currentstage = StageSystem.nextstage
                StageSystem.nextstage = nil
            else StageSystem.currentstage = 0 end
        end
		if level:GetStageType() == StageType.STAGETYPE_WOTL then
			if level:GetStage() == LevelStage.STAGE2_1 then
				local bosses = CUSTOM_STAGES[StageSystem.currentstage].BOSSES
				if #bosses ~= 0 then
					local rand = math.random(#bosses)
					StageSystem.currentboss = {Name = bosses[rand].NAME, Type = bosses[rand].TYPE, Variant = bosses[rand].VARIANT, SubType = bosses[rand].SUBTYPE}
				end
				StageSystem.nextstage = StageSystem.currentstage
				StageSystem.ChangeBackdrop(CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[1].NAME, CUSTOM_STAGES[StageSystem.currentstage].BACKDROPS[1].VARIANTS)
				StageSystem.ChangeDoors(CUSTOM_STAGES[StageSystem.currentstage].NAME)
			end
			if level:GetStage() == LevelStage.STAGE2_2 then
				local bosses = CUSTOM_STAGES[StageSystem.currentstage].BOSSES
				if #bosses ~= 0 then
					local rand = math.random(#bosses)
					StageSystem.currentboss = {Name = bosses[rand].NAME, Type = bosses[rand].TYPE, Variant = bosses[rand].VARIANT, SubType = bosses[rand].SUBTYPE}
				end
			end
		end
	end
end

stagesystem:AddCallback(ModCallbacks.MC_POST_UPDATE, stagesystem.SettingUpStage1)
stagesystem:AddCallback(ModCallbacks.MC_POST_RENDER, stagesystem.SettingUpStage2)
stagesystem:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, stagesystem.OnNewRoom)
stagesystem:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, stagesystem.OnNewLevel)

stagesystem.vanillaAddCallback = Isaac.AddCallback
stagesystem.newRoomCallbacks = {}
stagesystem.newLevelCallbacks = {}
stagesystem.lastRoomSeed = 0
stagesystem.laststage = {LEVELSTAGE = -1, STAGE = -1}

--If it's a custom stage, run new room only the second time for each room (as, for example, spawning an entity the first time then teleporting to the same room as the stageapi does would despawn the entity
--Needed as stageapi often teleports you to the same room twice for updating the gridentities after they are spawned, this can't be done without reloading the room
function stagesystem:CustomPostNewRoom()
    local level = Game():GetLevel()
	local room = level:GetCurrentRoom()
	--Isaac.DebugString(tostring(stagesystem.lastRoomSeed).."; "..room:GetDecorationSeed().."; "..tostring((level:GetAbsoluteStage() == LevelStage.STAGE2_1 or level:GetAbsoluteStage() == LevelStage.STAGE2_2) and level:GetStageType() == StageType.STAGETYPE_WOTL ))
    if (level:GetAbsoluteStage() == LevelStage.STAGE2_1 or level:GetAbsoluteStage() == LevelStage.STAGE2_2) and level:GetStageType() == StageType.STAGETYPE_WOTL then
        if stagesystem.lastRoomSeed ~= room:GetDecorationSeed() and room:IsFirstVisit() then --first time this was called in this room
            stagesystem.lastRoomSeed = room:GetDecorationSeed()
        else
			for i, func in ipairs(stagesystem.newRoomCallbacks) do func() end
		end
    end
end

stagesystem:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, stagesystem.CustomPostNewRoom)

function stagesystem:CustomPostNewLevel()
	local level = Game():GetLevel()
	if (level:GetAbsoluteStage() == LevelStage.STAGE2_1 or level:GetAbsoluteStage() == LevelStage.STAGE2_2) and level:GetStageType() == StageType.STAGETYPE_WOTL then
		if level:GetAbsoluteStage() ~= stagesystem.laststage.LEVELSTAGE or StageSystem.currentstage ~= stagesystem.laststage.STAGE then
			for i, func in ipairs(stagesystem.newLevelCallbacks) do func() end
			stagesystem.laststage = {LEVELSTAGE = level:GetAbsoluteStage(), STAGE = StageSystem.currentstage}
		end
	end
end

stagesystem:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, stagesystem.CustomPostNewLevel)

--Override callback to add MC_POST_NEW_ROOM callbacks to our table, and set them to only work outside of custom stages
function Isaac.AddCallback(ref, callbackId, callbackFn, entityId)
	if callbackId == ModCallbacks.MC_POST_NEW_ROOM or callbackId == ModCallbacks.MC_POST_NEW_LEVEL then
		local func = function()
			local level = Game():GetLevel()
			if not ((level:GetAbsoluteStage() == LevelStage.STAGE2_1 or level:GetAbsoluteStage() == LevelStage.STAGE2_2) and level:GetStageType() == StageType.STAGETYPE_WOTL) then
				callbackFn()
			end
		end
		stagesystem.vanillaAddCallback(ref, callbackId, func, entityId)
    
		if callbackId == ModCallbacks.MC_POST_NEW_ROOM then table.insert(stagesystem.newRoomCallbacks, callbackFn)
		elseif callbackId == ModCallbacks.MC_POST_NEW_LEVEL then table.insert(stagesystem.newLevelCallbacks, callbackFn) end
	else
		--Other callback Id, work as normal
		stagesystem.vanillaAddCallback(ref, callbackId, callbackFn, entityId)
	end
end

CUSTOM_ROOMS_CLEAR = {
  {TYPE=1, VARIANT=0, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=13, HEIGHT=7, SHAPE=1,
    {ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
    {ISDOOR=true, GRIDX=13, GRIDY=3, SLOT=2, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=7, SLOT=3, EXISTS=true},
  },
  {TYPE=1, VARIANT=1, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=13, HEIGHT=7, SHAPE=2,
    {ISDOOR=true, GRIDX=13, GRIDY=3, SLOT=2, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
  },
  {TYPE=1, VARIANT=2, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=13, HEIGHT=7, SHAPE=3,
    {ISDOOR=true, GRIDX=6, GRIDY=7, SLOT=3, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
  },
  {TYPE=1, VARIANT=3, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=13, HEIGHT=14, SHAPE=4,
    {ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
    {ISDOOR=true, GRIDX=13, GRIDY=3, SLOT=2, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
    {ISDOOR=true, GRIDX=13, GRIDY=10, SLOT=6, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=10, SLOT=4, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=14, SLOT=3, EXISTS=true},
  },
  {TYPE=1, VARIANT=4, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=13, HEIGHT=14, SHAPE=5,
    {ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=14, SLOT=3, EXISTS=true},
  },
  {TYPE=1, VARIANT=5, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=26, HEIGHT=7, SHAPE=6,
    {ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=7, SLOT=3, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=7, SLOT=7, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=2, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=-1, SLOT=5, EXISTS=true},
  },
  {TYPE=1, VARIANT=6, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=26, HEIGHT=7, SHAPE=7,
    {ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=2, EXISTS=true},
  },
  {TYPE=1, VARIANT=7, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=26, HEIGHT=14, SHAPE=8,
    {ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=10, SLOT=4, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=-1, SLOT=5, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=14, SLOT=3, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=7, SLOT=7, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=2, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=6, EXISTS=true},
  },
  {TYPE=1, VARIANT=8, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=26, HEIGHT=14, SHAPE=9,
    {ISDOOR=true, GRIDX=6, GRIDY=6, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=6, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=10, SLOT=4, EXISTS=true},
    {ISDOOR=true, GRIDX=12, GRIDY=3, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=7, SLOT=7, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=14, SLOT=3, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=2, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=-1, SLOT=5, EXISTS=true},
  },
  {TYPE=1, VARIANT=9, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=26, HEIGHT=14, SHAPE=10,
    {ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
    {ISDOOR=true, GRIDX=13, GRIDY=3, SLOT=2, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=6, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=14, SLOT=3, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=7, SLOT=7, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=10, SLOT=4, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=6, EXISTS=true},
  },
  {TYPE=1, VARIANT=10, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=26, HEIGHT=14, SHAPE=11,
    {ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=7, SLOT=3, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
    {ISDOOR=true, GRIDX=12, GRIDY=10, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=-1, SLOT=5, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=2, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=7, SLOT=7, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=6, EXISTS=true},
  },
  {TYPE=1, VARIANT=11, SUBTYPE=0, NAME="New Room", DIFFICULTY=1, WEIGHT=1, WIDTH=26, HEIGHT=14, SHAPE=12,
    {ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=-1, SLOT=5, EXISTS=true},
    {ISDOOR=true, GRIDX=13, GRIDY=10, SLOT=6, EXISTS=true},
    {ISDOOR=true, GRIDX=26, GRIDY=3, SLOT=2, EXISTS=true},
    {ISDOOR=true, GRIDX=6, GRIDY=14, SLOT=3, EXISTS=true},
    {ISDOOR=true, GRIDX=-1, GRIDY=10, SLOT=4, EXISTS=true},
    {ISDOOR=true, GRIDX=19, GRIDY=7, SLOT=7, EXISTS=true},
  },
}