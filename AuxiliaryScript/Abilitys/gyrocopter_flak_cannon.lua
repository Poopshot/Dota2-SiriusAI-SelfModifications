-----------------
--英雄：矮人直升机
--技能：高射火炮
--键位：E
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('gyrocopter_flak_cannon')
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

    -- Get some of its values
    local nCastRange = ability:GetSpecialValueInt("radius");
    local nEnemysHerosInBonus = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
    end
    
    --打架时	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and ( J.GetHP(npcTarget) > 0.25 or #nEnemysHerosInBonus >= 2 )
		   and ( J.IsInRange(npcTarget,bot,700)
				 or J.IsInRange(npcTarget,bot,npcTarget:GetAttackRange() + 80) )				  
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
    
end

return X;