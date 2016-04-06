if myHero.charName ~= "Irelia" then return end

local Qdmg = myHero:GetSpellData(_Q).level * 30 - 10 + myHero.totalDamage --Niveau du Sort * 30 - 10 + Attaque Champion physique
local Wdmg = myHero:GetSpellData(_W).level * 15  -- Niveau du sort * 15
local Edmg = myHero:GetSpellData(_E).level * 40 + 40 + myHero.ap * 0.5 -- Niveau du sort * 40 +40 + 50 % Magie Champions
local Rdmg = myHero:GetSpellData(_R).level * 40 + 40 + myHero.ap * 0.5 + myHero.addDamage * 0.6 -- Niveau du sort *40 + 40 + 50% Magie + 60 % Degat Physique en fonction des Items AD

--- Starting AutoUpdate
local version = "0.31"
local author = "desperadisse"
local SCRIPT_NAME = "IreliaBattleShield"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/desperadisse/BoL/master/Irelia-DeathSmart/IreliaBattleShield.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/desperadisse/BoL/master/Irelia-DeathSmart/IreliaBattleShield.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				print("New version available "..ServerVersion)
				print(">>Updating, please don't press F9<<")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () print("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				DelayAction(function() print("Hello, "..GetUser()..". You got the latest version! :) ("..ServerVersion..")") end, 3)
			end
		end
		else
			print("Error downloading version info")
	end
end
 --- End Of AutoUpdate

function OnLoad()
	Skills()
	menu()
	print("Loaded")
	--SetSkin(myHero, 4)
	startitem()
	LoadVPred()

	if _G.Reborn_Loaded ~= nil then
   		LoadSACR()
	elseif Despe.orbwalker.n1 == 3 then
		local neo = 1
		print("Nebelwolfi's Orb Walker loading..")
		LoadNEBOrb()
	end
end

function OnTick()
	Target = GetCustomTarget()
	KillSteal()
	Keys()
end


function OnDraw()

	if Despe.Draw.hitbox.hitboxparam then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF)
	end

	if Despe.Draw.hitbox.rangeauto then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius+myHero.range, 1, 0xFFFFFFFF)
	end

	if myHero:CanUseSpell(_Q) == READY  and Despe.Draw.qDraw then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillQ.range, 1, 0xFFFFFFFF)
	end

	if myHero:CanUseSpell(_E) == READY and Despe.Draw.eDraw then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillE.range, 1, 0xFFFFFFFF)
	end

	if myHero:CanUseSpell(_R) == READY and Despe.Draw.rDraw then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillR.range, 1, 0xFFFFFFFF)
	end

	if Target ~= nil then
		if Despe.Draw.targetselector then
			DrawText3D("Cible", Target.x - 100, Target.y - 100, Target.z, 20, 0xFFFFFFFF, center)
			DrawText(""..Target.charName.."", 20, 50, 200, 0xFFFFFFFF)
		end
	end	
end

function OnUnload()
	print("Unload")
end

function menu()
	Despe = scriptConfig("Irelia - BattleShield", "Despe")

	------------------------------------DRAW & SKINCHANGER-------------------------------

	Despe:addSubMenu("Draw Setting", "Draw")
		Despe.Draw:addParam("targetselector", "Select Target", SCRIPT_PARAM_ONOFF, true)
		Despe.Draw:addParam("qDraw", "SkillQ Draw", SCRIPT_PARAM_ONOFF, true)
		Despe.Draw:addParam("wDraw", "SkillW Draw", SCRIPT_PARAM_ONOFF, true)
		Despe.Draw:addParam("eDraw", "SkillE Draw", SCRIPT_PARAM_ONOFF, true)
		Despe.Draw:addParam("rDraw", "SkillR Draw", SCRIPT_PARAM_ONOFF, true)
		--Changement Parametre Skin
		 Despe.Draw:addSubMenu("Skin Changer", "skins")
			Despe.Draw.skins:addParam("skinchange", "Change Skin", SCRIPT_PARAM_ONOFF, false)
			Despe.Draw.skins:addParam("listskin", "Skins", SCRIPT_PARAM_LIST, 1, {"Classic", "Nightblade", "Aviator", "Infiltrator", "Frostblade", "Order of the Lotus"})
			Despe.Draw.skins:setCallback("skinchange", function(Skinchanger)
				if Skinchanger then
					SetSkin(myHero, Despe.Draw.skins.listskin-1)
				else
					SetSkin(myHero, -1)
				end

			end)
			Despe.Draw.skins:setCallback("listskin", function(Skinchanger)
				if Skinchanger and Despe.Draw.skins.skinchange then
					SetSkin(myHero, Despe.Draw.skins.listskin-1)
				end

			end)

	Despe.Draw:addSubMenu("HitBox", "hitbox")
		Despe.Draw.hitbox:addParam("hitboxparam", "HitBox", SCRIPT_PARAM_ONOFF, true)
		Despe.Draw.hitbox:addParam("rangeauto", "Range Auto Attack", SCRIPT_PARAM_ONOFF, true)

	------------------------------------COMBO-------------------------------

	Despe:addSubMenu("Combo Setting", "combo")

		Despe.combo:addParam("UseQ", "Use (Q) in combo", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("QLogic", "Logic Use Q", SCRIPT_PARAM_LIST, 1, {"Classic", "Jump Minion"})
		Despe.combo:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
		Despe.combo:addParam("UseW", "Use (W) in combo", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
		Despe.combo:addParam("UseE", "Use (E) in combo", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("HpE", "Parameter % HP Target", SCRIPT_PARAM_SLICE, 50, 35, 100)
		Despe.combo:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
		Despe.combo:addParam("UseR", "Use (R) in combo", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
		Despe.combo:addParam("killsteal", "Use KillSteal", SCRIPT_PARAM_ONOFF, true)

	------------------------------------LANECLEAR-------------------------------

	Despe:addSubMenu("Lane Clear", "laneclear")
		Despe.laneclear:addParam("ManaQ", "Parameter % Mana ", SCRIPT_PARAM_SLICE, 30, 10, 100)

	------------------------------------HARASS-------------------------------

	Despe:addSubMenu("Harrass (SOON)", "harass")

		Despe.harass:addParam("UseQ", "Use (Q) in harass", SCRIPT_PARAM_ONOFF, true)
		Despe.harass:addParam("UseW", "Use (W) in harass", SCRIPT_PARAM_ONOFF, false)
		Despe.harass:addParam("UseE", "Use (E) in harass", SCRIPT_PARAM_ONOFF, true)
		Despe.harass:addParam("UseR", "Use (R) in harass", SCRIPT_PARAM_ONOFF, false)

	------------------------------------AUTOBUY STARTER-------------------------------	

	Despe:addSubMenu("Item", "buyitem")

		Despe.buyitem:addParam("AutoBuy", "Auto Buy Item", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
		Despe.buyitem:addParam("WardAuto", "Warding Totem", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
		Despe.buyitem:addParam("CorruptPotion", "Corrupting Potion", SCRIPT_PARAM_ONOFF, true)

	enemyMinions = minionManager(MINION_ENEMY, 1300, myHero, MINION_SORT_HEALTH_ASC)
    jungleMinions = minionManager(MINION_JUNGLE, 1300, myHero, MINION_SORT_MAXHEALTH_DEC)
    ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1300, DAMAGE_PHYSICAL)
    ts.name = "Irelia"
    Despe:addTS(ts)

    ------------------------ORBWALKER------------------------------------

    Despe:addSubMenu("OrbWalker", "orbwalker")
		Despe.orbwalker:addParam("n1", "OrbWalker :", SCRIPT_PARAM_LIST, 1, {"Nebelwolfi"})
		Despe.orbwalker:addParam("n2", "If you want to change OrbWalker,", SCRIPT_PARAM_INFO, "")
		Despe.orbwalker:addParam("n3", "Then, change it and press double F9.", SCRIPT_PARAM_INFO, "")
		Despe.orbwalker:addParam("n4", "", SCRIPT_PARAM_INFO, "")
		Despe.orbwalker:addParam("n5", "=> SAC:R are automaticly loaded.", SCRIPT_PARAM_INFO, "")
		Despe.orbwalker:addParam("n6", "=> Enable one of them in BoLStudio", SCRIPT_PARAM_INFO, "")	


end

--

function Skills()
    SkillQ = { range = 650, delay = 0.25, speed = nil, width = nil, ready = false }
    SkillW = { range = nil, delay = nil, speed = nil, width = nil, ready = false }
    SkillE = { range = 425, delay = 0.25, speed = nil, width = nil, ready = false }
    SkillR = { range = 1200, delay = 0, speed = 1600, width = nil, ready = false }
end

--

function GetCustomTarget()
    ts:update()
    if ValidTarget(ts.target) and ts.target.type == myHero.type then
        return ts.target
    else
        return nil
    end
end

--

function KillSteal()
	if Despe.combo.killsteal then
		for _, unit in pairs(GetEnemyHeroes()) do

			if unit ~= nil then 
				dmgQ = myHero:CalcDamage(unit, Qdmg)
				dmgE = myHero:CalcMagicDamage(unit, Edmg)
				--dmgW = Wdmg
				dmgR = myHero:CalcDamage(unit, Rdmg)

				if myHero:CanUseSpell(_E) == READY and ValidTarget(unit) and GetDistance(unit) < SkillE.range and unit.health < dmgE and not unit.dead then

						CastSpell(_E, unit)

				elseif myHero:CanUseSpell(_Q) == READY and ValidTarget(unit) and GetDistance(unit) < SkillQ.range and unit.health < dmgQ and not unit.dead then

						CastSpell(_Q, unit)

				elseif myHero:CanUseSpell(_Q) == READY and myHero:CanUseSpell(_E) == READY and ValidTarget(unit) and GetDistance(unit) < SkillQ.range and unit.health < dmgQ + dmgE and not unit.dead then

						CastSpell(_Q, unit)
						CastSpell(_E, unit)
				elseif myHero:CanUseSpell(_R) == READY and ValidTarget(unit) and GetDistance(unit) < SkillR.range and unit.health < dmgR*2 and not unit.dead then
                    local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SkillR.delay, 65, SkillR.range, SkillR.speed, myHero, true)
                    if HitChance >= 2 then
                        CastSpell(_R, CastPosition.x, CastPosition.z)
                    end
				end
			end
		end
	end
end

--

function startitem()

	if Despe.buyitem.AutoBuy then
		if Despe.buyitem.WardAuto and Despe.buyitem.CorruptPotion then
			BuyItem(2033)
			BuyItem(3340)
		elseif Despe.buyitem.CorruptPotion then
			BuyItem(2033)
		elseif Despe.buyitem.WardAuto then
			BuyItem(3340)
		end
	end
end

--

function Keys()
    if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then

        if _G.AutoCarry.Keys.AutoCarry then 
            Combo()
        elseif  _G.AutoCarry.Keys.MixedMode then 
            Harass()
        elseif  _G.AutoCarry.Keys.LaneClear then 
            LaneClear()
        elseif  _G.AutoCarry.Keys.LastHit then 
            LastHit()
        end

    elseif Despe.orbwalker.n1 == 1 and _G.NebelwolfisOrbWalkerLoaded then

		if _G.NebelwolfisOrbWalker.Config.k.Combo then
			Combo()
		elseif _G.NebelwolfisOrbWalker.Config.k.Harass then
			Harass()
		elseif _G.NebelwolfisOrbWalker.Config.k.LastHit then
			LastHit()
		elseif _G.NebelwolfisOrbWalker.Config.k.LaneClear then
			LaneClear()

		end

	end 
end

--

function Combo()
	if Target == nil then return end
	if Despe.combo.UseQ then
		if Despe.combo.QLogic == 1 then
			if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) <= SkillQ.range then
				if myHero:CanUseSpell(_W) == READY and Despe.combo.UseW then
					CastSpell(_W)
				end
				CastSpell(_Q, Target)
			end
		elseif Despe.combo.QLogic == 2 then
			LogicOfQ()
		end
	end
	if Despe.combo.UseW then
		if myHero:CanUseSpell(_W) == READY and GetDistance(Target) <= myHero.boundingRadius+myHero.range-Target.boundingRadius then
			CastSpell(_W)
		end
	end

	if Despe.combo.UseE then
		if myHero:CanUseSpell(_E) == READY and GetDistance(Target) <= SkillE.range then
			if PercentHP(Target) >= PercentHP(myHero) then
				CastSpell(_E, Target)
			elseif PercentHP(Target) <= 35 then
				CastSpell(_E, Target)
			elseif PercentHP(Target) >= Despe.combo.HpE then
				CastSpell(_E, Target)
			end
		end
	end

	if Despe.combo.UseR then
		if myHero:CanUseSpell(_R) == READY and GetDistance(Target) <= 600 then
			local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, SkillR.delay, 65, SkillR.range, SkillR.speed, myHero, true)
                if HitChance >= 2 then
                    CastSpell(_R, CastPosition.x, CastPosition.z)
                end
		end
	end
end

--

function LoadVPred()
    if FileExist(LIB_PATH .. "/VPrediction.lua") then
        require("VPrediction")
        print("Succesfully loaded VPred")
        VP = VPrediction()
    else
        print("Download VPrediction!")
    end
end

--

function LoadSACR()
    if _G.Reborn_Initialised then
    elseif _G.Reborn_Loaded then
        print("Loaded SAC:R")
    else
        DelayAction(function()print("Failed to Load SAC:R")end, 7)
    end 
end

function LoadNEBOrb()
		if not _G.NebelwolfisOrbWalkerLoaded then
			require "Nebelwolfi's Orb Walker"
			NebelwolfisOrbWalkerClass()
		end
	end
	if not FileExist(LIB_PATH.."Nebelwolfi's Orb Walker.lua") then
		DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
			LoadNEBOrb()
		end)
	else
		local f = io.open(LIB_PATH.."Nebelwolfi's Orb Walker.lua")
		f = f:read("*all")
		if f:sub(1,4) == "func" then
			DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
				LoadNEBOrb()
			end)
		else
			if neo == 1 then
				LoadNEBOrb()
			end
		end
	end


--

function PercentHP(unit)
	return (unit.health * 100) / unit.maxHealth
end

--

function PercentMana(unit) -- Calcule du pourcentage MANA de mon Hero

    return (unit.mana * 100) / unit.maxMana
end

--

function LaneClear()
	enemyMinions:update()
	for _, minion in pairs(enemyMinions.objects) do
		if minion ~= nil then
			dmgQ = myHero:CalcDamage(minion, Qdmg)
			if myHero:CanUseSpell(_Q) == READY and ValidTarget(minion) and GetDistance(minion) <= SkillQ.range and minion.health <= dmgQ and not minion.dead then
				if PercentMana(myHero) >= Despe.laneclear.ManaQ then
					CastSpell(_Q, minion)
				end
			end
		end
	end
end

--

function LogicOfQ()
    if Target == nil then return end
        if myHero:CanUseSpell(_Q) == READY and ValidTarget(Target) and GetDistance(Target) <= SkillQ.range*2 then
            enemyMinions:update()
            for _, minion in pairs(enemyMinions.objects) do
                dmgQ = myHero:CalcDamage(minion, Qdmg)
                if minion ~= nil and GetDistance(minion) <= SkillQ.range and (minion.health <= dmgQ) then
                        if GetDistance(Target, minion) < GetDistance(Target) then
                            if GetDistance(Target, minion) <= SkillQ.range then
                                CastSpell(_Q, minion)
                                DelayAction(function()
                                    CastSpell(_Q, Target)
                                end, SkillQ.delay+1)
                            end
                        end
                 else
                    CastSpell(_Q, Target)
                end
            end
        end
end


