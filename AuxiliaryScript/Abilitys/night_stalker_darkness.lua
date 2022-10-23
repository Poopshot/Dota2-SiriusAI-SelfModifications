-----------------
--英雄：暗夜魔王
--技能：黑暗飞升  
--键位：R
--类型：无目标
--作者：Krizalium
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('night_stalker_darkness')
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
    X.Compensation() 
    bot:ActionQueue_UseAbility( ability ) --使用技能
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

    local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	if #tableNearbyAllyHeroes == 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local distance = 600;
	
	if J.IsInTeamFight(bot, 1200) and not IsNightTime() 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, distance) and not IsNightTime() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
    
end

function IsNightTime()
	return GetTimeOfDay() == 0.0 or bot:HasModifier("modifier_night_stalker_darkness");
end

return X;