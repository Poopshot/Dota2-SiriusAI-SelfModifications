-----------------
--英雄：赏金猎人
--技能：投掷飞镖
--键位：Q
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('bounty_hunter_shuriken_toss')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 180 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
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
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if npcEnemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
		if J.CanCastOnNonMagicImmune(npcEnemy) and J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) 
		then
			if J.IsInRange(npcEnemy, bot, nCastRange + 200) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			elseif tableNearbyCreeps[1] ~= nil and X.StillHasModifier(npcEnemy, 'modifier_bounty_hunter_track') 
				and J.IsInRange(npcEnemy, bot, nRadius - 200)
			then	
				return BOT_ACTION_DESIRE_HIGH, tableNearbyCreeps[1] ;
			end
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local trackedEnemy = 0;
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( X.StillHasModifier(npcEnemy, 'modifier_bounty_hunter_track')  ) 
			then
				trackedEnemy = trackedEnemy + 1;
			end
		end
		if trackedEnemy >= 2 then
			if tableNearbyCreeps[1] ~= nil then
				return BOT_ACTION_DESIRE_HIGH, tableNearbyCreeps[1];
			elseif J.IsInRange(tableNearbyEnemyHeroes[1], bot, nCastRange + 200) 
			then
				return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1];
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) 
		then
			if J.IsInRange(npcEnemy, bot, nCastRange + 200) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			elseif tableNearbyCreeps[1] ~= nil and X.StillHasModifier(npcEnemy, 'modifier_bounty_hunter_track') 
				and J.IsInRange(npcEnemy, bot, nRadius - 200)
			then	
				return BOT_ACTION_DESIRE_HIGH, tableNearbyCreeps[1] ;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.StillHasModifier(npcTarget, modifier)
	return npcTarget:HasModifier(modifier);
end

return X;