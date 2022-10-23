-----------------
--英雄：虚无之灵
--技能：太虚之径
--键位：R
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('void_spirit_astral_step')
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
        bot:ActionQueue_UseAbilityOnLocation( ability, castTarget ) --使用技能
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
	   or bot:IsRooted()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	-- Get some of its values
	local nSkillLV     = ability:GetLevel(); 
	local nRadius      = ability:GetSpecialValueInt( "radius" );
	local nCastRange   = ability:GetSpecialValueInt("max_travel_distance") - 200;
	local nCastPoint   = ability:GetCastPoint();
	local nDamage      = ability:GetSpecialValueInt( "pop_damage" );
	local nSpeed       = 3000;
	local nManaCost    = ability:GetManaCost( );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if J.CanCastOnMagicImmune(npcEnemy) 
		   and J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) then
			if npcEnemy:GetMovementDirectionStability() < 1.0 then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			else
				local eta = ( GetUnitToUnitDistance(npcEnemy, bot) / nSpeed ) + nCastPoint;
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(eta);	
			end
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) )
			then
				local loc = J.GetEscapeLoc();
				return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange-(#tableNearbyEnemyHeroes*50));
			end
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget)
		   and J.CanCastOnMagicImmune(npcTarget)
		   and not J.IsInRange(npcTarget, bot, 350) 
		   and J.IsInRange(npcTarget, bot, nCastRange) 
		then
			local targetAlly  = npcTarget:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local targetEnemy = npcTarget:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if targetEnemy ~= nil and targetAlly ~= nil and #targetEnemy >= #targetAlly then
				if npcTarget:GetMovementDirectionStability() < 1.0 then
					return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
				else
					local eta = ( GetUnitToUnitDistance(npcTarget, bot) / nSpeed ) + nCastPoint;
					return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(eta);	
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;