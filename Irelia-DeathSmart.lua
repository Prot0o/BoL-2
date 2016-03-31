if myHero.charName ~= "Irelia" then return end

local Qdmg = myHero:GetSpellData(_Q).level * 30 - 10 + myHero.totalDamage --Niveau du Sort * 30 - 10 + Attaque Champion physique
local Wdmg = myHero:GetSpellData(_W).level * 15  -- Niveau du sort * 15
local Edmg = myHero:GetSpellData(_E).level * 40 + 40 + myHero.ap * 0.5 -- Niveau du sort * 40 +40 + 50 % Magie Champions
local Rdmg = myHero:GetSpellData(_R).level * 40 + 40 + myHero.ap * 0.5 + myHero.addDamage * 0.6 -- Niveau du sort *40 + 40 + 50% Magie + 60 % Degat Physique en fonction des Items AD

function OnLoad()
	Skills()
	menu()
	print("Loaded")
	--SetSkin(myHero, 4)
	startitem()
	LoadVPred()
	LoadSACR()
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
	Despe = scriptConfig("IreliaStyle", "Despe")

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


	Despe:addSubMenu("Combo Setting", "combo")

		Despe.combo:addParam("UseQ", "Use (Q) in combo", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("QLogic", "Logic Use Q", SCRIPT_PARAM_LIST, 1, {"Classic", "Jump Minion"})
		Despe.combo:addParam("UseW", "Use (W) in combo", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("UseE", "Use (E) in combo", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("HpE", "Parameter % HP Target", SCRIPT_PARAM_SLICE, 50, 35, 100)
		Despe.combo:addParam("UseR", "Use (R) in combo", SCRIPT_PARAM_ONOFF, true)
		Despe.combo:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
		Despe.combo:addParam("killsteal", "Use KillSteal", SCRIPT_PARAM_ONOFF, true)

	Despe:addSubMenu("Lane Clear", "laneclear")
		Despe.laneclear:addParam("ManaQ", "Parameter % Mana ", SCRIPT_PARAM_SLICE, 30, 10, 100)


	Despe:addSubMenu("Harrass", "harass")

		Despe.harass:addParam("UseQ", "Use (Q) in harass", SCRIPT_PARAM_ONOFF, true)
		Despe.harass:addParam("UseW", "Use (W) in harass", SCRIPT_PARAM_ONOFF, false)
		Despe.harass:addParam("UseE", "Use (E) in harass", SCRIPT_PARAM_ONOFF, true)
		Despe.harass:addParam("UseR", "Use (R) in harass", SCRIPT_PARAM_ONOFF, false)

	Despe:addSubMenu("Item", "buyitem")

		Despe.buyitem:addParam("AutoBuy", "Auto Buy Item", SCRIPT_PARAM_ONOFF, true)
		Despe.buyitem:addParam("WardAuto", "Warding Totem", SCRIPT_PARAM_ONOFF, true)
		Despe.buyitem:addParam("CorruptPotion", "Corrupting Potion", SCRIPT_PARAM_ONOFF, true)

	enemyMinions = minionManager(MINION_ENEMY, 1300, myHero, MINION_SORT_HEALTH_ASC)
    jungleMinions = minionManager(MINION_JUNGLE, 1300, myHero, MINION_SORT_MAXHEALTH_DEC)
    ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1300, DAMAGE_PHYSICAL)
    ts.name = "Irelia"
    Despe:addTS(ts)	
end





function Skills()
    SkillQ = { range = 650, delay = 0.25, speed = nil, width = nil, ready = false }
    SkillW = { range = nil, delay = nil, speed = nil, width = nil, ready = false }
    SkillE = { range = 425, delay = 0.25, speed = nil, width = nil, ready = false }
    SkillR = { range = 1200, delay = 0, speed = 1600, width = nil, ready = false }
end

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
	end 
end

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
			
		end
	end
	if Despe.combo.UseW then
		if myHero:CanUseSpell(_W) == READY and GetDistance(Target) <= myHero.boundingRadius+myHero.range-Target.boundingRadius then
			CastSpell(_W)
		end
	end

	if Despe.combo.UseE then
		if myHero:CanUseSpell(_E) == READY and GetDistance(Target) <= SkillE.range then
			if PercentHPTarget() >= PercentHPhero() then
				CastSpell(_E, Target)
			elseif PercentHPTarget() <= 35 then
				CastSpell(_E, Target)
			elseif PercentHPTarget() >= Despe.combo.HpE then
				CastSpell(_E, Target)
			end
		end
	end

	if Despe.combo.UseR then
		if myHero:CanUseSpell(_R) == READY and GetDistance(Target) <= SkillR.range then
			local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, SkillR.delay, 65, SkillR.range, SkillR.speed, myHero, true)
                if HitChance >= 2 then
                    CastSpell(_R, CastPosition.x, CastPosition.z)
                end
		end
	end
end


function LoadVPred()
    if FileExist(LIB_PATH .. "/VPrediction.lua") then
        require("VPrediction")
        print("Succesfully loaded VPred")
        VP = VPrediction()
    else
        print("Download VPrediction!")
    end
end


function LoadSACR()
    if _G.Reborn_Initialised then
    elseif _G.Reborn_Loaded then
        print("Loaded SAC:R")
    else
        DelayAction(function()print("Failed to Load SAC:R")end, 7)
    end 
end

function PercentHPTarget() -- Calcule du pourcentage Vie de la target

    return (Target.health * 100) / Target.maxHealth
end

function PercentHPhero() -- Calcule du pourcentage Vie de mon Hero

    return (myHero.health * 100) / myHero.maxHealth
end

function PercentManahero() -- Calcule du pourcentage MANA de mon Hero

    return (myHero.mana * 100) / myHero.maxMana
end

function LaneClear()
	enemyMinions:update()
	for _, minion in pairs(enemyMinions.objects) do
		if minion ~= nil then
			dmgQ = myHero:CalcDamage(minion, Qdmg)
			if myHero:CanUseSpell(_Q) == READY and ValidTarget(minion) and GetDistance(minion) <= SkillQ.range and minion.health <= dmgQ and not minion.dead then
				if PercentManahero() >= Despe.laneclear.ManaQ then
					CastSpell(_Q, minion)
				end
			end
		end
	end
end

function LogicOfQ()
	enemyMinions:update()
	for _, minion in pairs(enemyMinions.objects) do
		if minion ~= nil then
			dmgQ = myHero:CalcDamage(minion, Qdmg)
			if not minion.health <= dmgQ then return end
		end
	end
end