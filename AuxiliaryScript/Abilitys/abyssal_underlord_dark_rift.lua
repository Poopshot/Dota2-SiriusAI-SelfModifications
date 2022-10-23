-----------------
--英雄：孽主
--技能：黑暗之门
--键位：R
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('abyssal_underlord_dark_rift')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("abyssal_underlord_dark_rift");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil then
        X.Compensation() 
        bot:ActionQueue_UseAbilityOnLocation( ability, castTarget ) --使用技能
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()

	if not ability:IsFullyCastable() then return 0 end
	
	if bot:DistanceFromFountain() < 3000 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end	
		
	-- Get some of its values
	local nRadius = ability:GetSpecialValueInt( "radius" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, GetAncient(GetTeam()):GetLocation();
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local location = J.GetTeamFountain();
				return BOT_ACTION_DESIRE_LOW, location;
			end
		end
	end
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( J.IsValidHero(npcTarget) and GetUnitToUnitDistance( npcTarget, bot ) > 2500 ) 
		then
			local tableNearbyEnemyCreeps = npcTarget:GetNearbyCreeps( 800, true );
			local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if tableNearbyEnemyCreeps ~= nil and tableNearbyAllyHeroes ~= nil and #tableNearbyEnemyCreeps >= 2 and #tableNearbyAllyHeroes >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end	
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;