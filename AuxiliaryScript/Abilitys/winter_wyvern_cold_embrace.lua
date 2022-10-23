-----------------
--英雄：寒冬飞龙
--技能：极寒之拥
--键位：E
--类型：指向目标
--作者：Krizalium
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('winter_wyvern_cold_embrace')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 160 --魔法储量
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

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end

	local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	
	if J.IsInTeamFight(bot, 1200)
	then
		for _,npcAlly in pairs( tableNearbyAllyHeroes )
		do
			if J.CanCastOnNonMagicImmune(npcAlly) and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.25 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcAlly;
			end
		end
	end
	
	for _,npcAlly in pairs( tableNearbyAllyHeroes )
	do
		if J.CanCastOnNonMagicImmune(npcAlly) and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.25 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcAlly;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;