-----------------
--英雄：灰烬之灵
--技能：无影拳
--键位：W
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('ember_spirit_sleight_of_fist')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 160 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--是否拥有蓝杖
abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); 

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
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
	-- Get some of its values
	local nRadius    = ability:GetSpecialValueInt('radius');
	local nCastRange = ability:GetCastRange();
	local nCastPoint = ability:GetCastPoint( );
	local nManaCost  = ability:GetManaCost( );
	local nDamage    = bot:GetAttackDamage() + ability:GetSpecialValueInt( 'bonus_hero_damage');
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + nRadius/2, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if J.CanCastOnMagicImmune(npcEnemy) and J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PHYSICAL) then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and J.CanCastOnMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
	end
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) and J.IsAllowedToSpam(bot, nManaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange + (nRadius/2)) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end


return X;