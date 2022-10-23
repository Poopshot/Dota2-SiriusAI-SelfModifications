-----------------
--英雄：拉比克
--技能：技能窃取
--键位：R
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('rubick_spell_steal')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
local castUltDelay = 0;
local castUltTime = -90;

nKeepMana = 300 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友
--可偷取的英雄
local speelAbilityList = {
    'npc_dota_hero_queenofpain',
    'npc_dota_hero_omniknight',
    'npc_dota_hero_slardar',
    'npc_dota_hero_dazzle',
    'npc_dota_hero_disruptor',
    'npc_dota_hero_shadow_demon',
    'npc_dota_hero_abaddon',
    'npc_dota_hero_axe',
    'npc_dota_hero_batrider',
    'npc_dota_hero_faceless_void',
    'npc_dota_hero_centaur',
    'npc_dota_hero_tidehunter',
    'npc_dota_hero_grimstroke',
    'npc_dota_hero_leshrac',
    'npc_dota_hero_obsidian_destroyer',
    'npc_dota_hero_vengefulspirit',
    'npc_dota_hero_puck',
    'npc_dota_hero_jakiro',
    'npc_dota_hero_antimage',
    'npc_dota_hero_bloodseeker',
    'npc_dota_hero_crystal_maiden',
    'npc_dota_hero_kunkka',
    'npc_dota_hero_sven',
    'npc_dota_hero_arc_warden',
    'npc_dota_hero_dragon_knight',
    'npc_dota_hero_drow_ranger',
    'npc_dota_hero_tiny',
    'npc_dota_hero_earthshaker',
    'npc_dota_hero_razor',
    'npc_dota_hero_silencer',
    'npc_dota_hero_undying',
    'npc_dota_hero_dark_willow',
    'npc_dota_hero_lich',
    'npc_dota_hero_phantom_assassin',
    'npc_dota_hero_riki',
    'npc_dota_hero_snapfire',
    'npc_dota_hero_void_spirit',
    'npc_dota_hero_storm_spirit',
    'npc_dota_hero_magnataur',
    'npc_dota_hero_treant',
    'npc_dota_hero_ursa',
    'npc_dota_hero_mars',
    'npc_dota_hero_abyssal_underlord',
    'npc_dota_hero_ancient_apparition',
    'npc_dota_hero_bane',
    'npc_dota_hero_bounty_hunter',
    'npc_dota_hero_invoker',
    'npc_dota_hero_gyrocopter',
    'npc_dota_hero_pangolier',
    'npc_dota_hero_juggernaut'
    'npc_dota_hero_enigma',
    'npc_dota_hero_winter_wyvern',
    'npc_dota_hero_night_stalker',
    'npc_dota_hero_chen',
    'npc_dota_hero_dark_seer',
    'npc_dota_hero_doom_bringer',
    'npc_dota_hero_earth_spirit',
    'npc_dota_hero_elder_titan',
    'npc_dota_hero_ember_spirit',
    'npc_dota_hero_enchantress',
    'npc_dota_hero_furion',
    'npc_dota_hero_keeper_of_the_light',
    'npc_dota_hero_legion_commander',
    'npc_dota_hero_life_stealer',
    'npc_dota_hero_mirana',
    'npc_dota_hero_wisp',
    'npc_dota_hero_slark',
    'npc_dota_hero_monkey_king',
    'npc_dota_hero_terrorblade',
    'npc_dota_hero_tusk',
    'npc_dota_hero_weaver',
    'npc_dota_hero_naga_siren',
}
--需舍弃的垃圾技能
local discardedAbilityList = {
    'abaddon_death_coil',
    'axe_berserkers_call',
    'centaur_return',
    'faceless_void_time_dilation',
    'queenofpain_blink',
    'faceless_void_time_walk',
    'queenofpain_shadow_strike',
    'queenofpain_scream_of_pain',
    'shadow_demon_shadow_poison_release',
    'shadow_demon_shadow_poison',
    'slardar_sprint',
    'tidehunter_anchor_smash',
    'tidehunter_gush',
    'leshrac_lightning_storm',
    'grimstroke_dark_artistry',
    'dazzle_shadow_wave',
    'centaur_double_edge',
    'centaur_hoof_stomp',
    'batrider_flamebreak',
    'batrider_firefly',
    'axe_battle_hunger',
    'abaddon_aphotic_shield',
    'omniknight_purification',
    'omniknight_repel',
    'vengefulspirit_wave_of_terror',
    'puck_waning_rift',
    'puck_phase_shift',
    'puck_illusory_orb',
    'puck_ethereal_jaunt',
    'obsidian_destroyer_equilibrium',
    'obsidian_destroyer_arcane_orb',
    'jakiro_liquid_fire',
    'jakiro_dual_breath',
    'antimage_blink',
    'bloodseeker_bloodrage',
    'crystal_maiden_crystal_nova',
    'kunkka_tidebringer',
    'kunkka_x_marks_the_spot',
    'sven_warcry',
    'drow_ranger_frost_arrows',
    'drow_ranger_trueshot',
    'drow_ranger_wave_of_silence',
    'dragon_knight_elder_dragon_form',
    'dragon_knight_breathe_fire',
    'dragon_knight_dragon_tail',
    'tiny_tree_channel',
    'tiny_craggy_exterior',
    'tiny_toss_tree',
    'earthshaker_enchant_totem',
    'silencer_glaives_of_wisdom',
}

--敌方英雄已释放技能列表
local nEnemyAbilityList = {}

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil
    then
        X.Compensation() 
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
        castUltTime = DotaTime();
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--偷取的技能
function X.StealingAbility()
    local sAbilityList = J.Skill.GetAbilityList(bot)
    return bot:GetAbilityByName(sAbilityList[4])
end

--技能释放欲望
function X.Consider()

	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
       or (DotaTime() - castUltTime <= castUltDelay and not DiscardedAbility())
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
    
    local StealingAbility = X.StealingAbility();

    if not string.find(StealingAbility:GetName(), 'empty') and not StealingAbility:IsToggle() and StealingAbility:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    -- Get some of its values
    local nCastRange = ability:GetCastRange();
    local projSpeed = ability:GetSpecialValueInt('projectile_speed')
    --------------------------------------
    -- Mode based usage
    --------------------------------------
    local gEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    for _,npcEnemy in pairs( gEnemies )
    do
        if npcEnemy:IsCastingAbility() then
            local enemyAbility = npcEnemy:GetCurrentActiveAbility();
            nEnemyAbilityList[npcEnemy:GetUnitName()] = enemyAbility:GetName()
        end
    end
    
    
    -- If we're going after someone
    if J.IsGoingOnSomeone(bot)
    then
        local npcTarget = bot:GetTarget();
        if npcTarget ~= nil
           and J.IsValidHero(npcTarget) 
           and J.CanCastOnNonMagicImmune(npcTarget) 
           and J.IsInRange(npcTarget, bot, nCastRange + 200) 
           and U.SearchHeroList(speelAbilityList, npcTarget) --确保英雄已经转换技能格式
           --and (nEnemyAbilityList[npcTarget:GetUnitName()] == nil or not SearchList(discardedAbilityList, nEnemyAbilityList[npcTarget:GetUnitName()]))--只获取有用的技能
        then
            castUltDelay = GetUnitToUnitDistance(bot, npcTarget) / projSpeed + ( 2*0.1 ); 
            return BOT_ACTION_DESIRE_HIGH, npcTarget;
        end
    end

    local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
    for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
        if  J.IsValid(npcEnemy) 
            and J.CanCastOnNonMagicImmune(npcEnemy) 
            and J.IsOtherAllyCanKillTarget(bot, npcEnemy)
            and U.SearchHeroList(speelAbilityList, npcTarget) --确保英雄已经转换技能格式
            and (nEnemyAbilityList[npcEnemy:GetUnitName()] == nil or not SearchList(discardedAbilityList, nEnemyAbilityList[npcEnemy:GetUnitName()]))--只获取有用的技能
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
    end
    
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function DiscardedAbility()
    local StealingAbility = X.StealingAbility()
    for _,value in pairs(discardedAbilityList) do
        if StealingAbility ~= nil 
           and value == StealingAbility
        then
            return true;
        end
    end

    return false;
end

function SearchList(list,targetAbility)
    if next(list) ~= nil then
        for _,value in pairs(list) do
            if value == targetAbility then
                return true;
            end
		end
	end
	
    return false;
end

return X;