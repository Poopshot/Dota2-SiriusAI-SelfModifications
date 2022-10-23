-----------------
--英雄：干扰者
--技能：风雷之击
--键位：Q
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('disruptor_thunder_strike')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 400 --魔法储量
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
	
	local nRadius = 240
	local nCastRange = ability:GetCastRange() + aetherRange 
	local target  = J.GetProperTarget(bot);
    local aTarget = bot:GetAttackTarget(); 
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostAoeEnemy = nil;
		local nMostAoeECount  = 1;
		local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange + 43,true,BOT_MODE_NONE);
		local nEmemysCreepsInRange = bot:GetNearbyCreeps(nCastRange + 43,true);
		local nAllEnemyUnits = J.CombineTwoTable(nEnemysHerosInRange,nEmemysCreepsInRange);
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nAllEnemyUnits )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				
				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount(npcEnemy, nRadius);
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount;
					npcMostAoeEnemy = npcEnemy;
				end
				
				if npcEnemy:IsHero()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_MAGICAL );
					if ( npcEnemyDamage > nMostDangerousDamage )
					then
						nMostDangerousDamage = npcEnemyDamage;
						npcMostDangerousEnemy = npcEnemy;
					end
				end
			end
		end
		
		if ( npcMostAoeEnemy ~= nil )
		then
			return BOT_MODE_DESIRE_MODERATE, npcMostAoeEnemy;
		end	

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_MODE_DESIRE_MODERATE, npcMostDangerousEnemy;
		end	
	end

	--对线期间对敌方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING
	then
		for _,npcEnemy in pairs( enemies )
		do
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(npcEnemy)
			then
				local enemyCount = J.GetAroundTargetEnemyUnitCount(npcEnemy, 600)
				if enemyCount ~= nil
				   and enemyCount >= 4
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end

	if ( J.IsPushing(bot) or J.IsDefending(bot) ) 
	then

		--拥有魔晶
		if bot:HasModifier( 'modifier_item_aghanims_shard' ) then
			if J.IsInTeamFight(bot, 1200)
			then
				if bot:GetMana() / bot:GetMaxMana() >= 0.65 then
					local tableNearbyFriendlyHeroes = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
					for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
						if myFriend:GetAttackRange() < 240 then
							return BOT_ACTION_DESIRE_MODERATE, myFriend;
						end
					end	
					local tableNearbyFriendlyCreeps = bot:GetNearbyLaneCreeps( nCastRange, false );
					for _,myCreeps in pairs(tableNearbyFriendlyCreeps) do
						if  myCreeps:GetHealth() / myCreeps:GetMaxHealth() >= 0.85 and 
							myCreeps:GetAttackRange() < 240
						then
							return BOT_ACTION_DESIRE_MODERATE, myCreeps;
						end
					end
				end
			end
		end

		local creeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		if #creeps >= 4 and creeps[1] ~= nil
		then
			return BOT_MODE_DESIRE_MODERATE, creeps[1];
		end
	end

	
	if J.IsGoingOnSomeone(bot)
	then

		if bot:HasModifier( 'modifier_item_aghanims_shard' ) then
			local npcTarget = bot:GetTarget();
			if  J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, 1000)
			then
				local tableNearbyFriendlyHeroes = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
				for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
					if myFriend:GetAttackRange() < 300
					then
						return BOT_ACTION_DESIRE_MODERATE, myFriend;
					end
				end
			end	
		end

		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, bot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;