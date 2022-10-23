-----------------
--英雄：主宰
--技能：无敌斩
--键位：R
--类型：指向单位
--作者：Krizalium
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('juggernaut_omni_slash')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 180 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil then
        X.Compensation()
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()
	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

    local nearbyEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	if nearbyEnemyHeroes == nil and #nearbyEnemyHeroes == 0 then -- Нет никого рядом.
		return BOT_ACTION_DESIRE_NONE, nil
	end
--------------------------------------------------------------------
	if J.IsInTeamFight(bot, 1200) and #nearbyEnemyHeroes > 0 then
		local potentialTarget = nearbyEnemyHeroes[1]
		if potentialTarget ~= nil then
			if 
				#nearbyEnemyHeroes == 1 and 
				potentialTarget:GetHealth() / potentialTarget:GetMaxHealth() < 0.4
			then
				return BOT_ACTION_DESIRE_NONE, nil
			else
				return BOT_ACTION_DESIRE_VERYHIGH, potentialTarget
			end
		end
	end
--------------------------------------------------------------------
	return BOT_ACTION_DESIRE_NONE
end

return X;