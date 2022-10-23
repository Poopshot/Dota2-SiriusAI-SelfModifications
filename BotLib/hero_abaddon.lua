local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表
--编组技能、天赋、装备,以后独立出来，这个文件尽量小一些，增加可读性
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = '主Q加点',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {2,3,1,1,1,6,1,2,2,2,6,3,3,3,6},
		--装备
		['Buy'] = {
			'item_tango',
			'item_enchanted_mango',
			'item_quelling_blade',
			'item_enchanted_mango',
			'item_magic_wand',
			'item_bracer',
			'item_phase_boots',
			'item_blade_mail',
			'item_vladmir',
			'item_echo_sabre',
			'item_radiance',
			'item_aghanims_shard',
			'item_assault',
			'item_solar_crest',
			'item_ultimate_scepter2',
		},
		--出售
		['Sell'] = {
			'item_abyssal_blade',
			'item_quelling_blade',
		},
	},
	{
		--组合说明，不影响游戏
		['info'] = '主被动加点',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {2,3,2,3,2,6,1,3,2,3,1,1,1,6,6},
		--装备
		['Buy'] = {
			'item_tango',
			'item_enchanted_mango',
			'item_enchanted_mango',
			'item_quelling_blade',
			'item_magic_wand',
			'item_bracer',
			'item_phase_boots',
			'item_falcon_blade',
			'item_blade_mail',
			'item_echo_sabre',
			'item_blink',
			'item_radiance',
			'item_shivas_guard',
			'item_abyssal_blade',
			'item_aghanims_shard',
			'item_heart',
		},
		--出售
		['Sell'] = {
			'item_mjollnir',
			'item_quelling_blade',

			'item_overwhelming_blink',
			'item_blink',
		},
	},
	{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 2, 1, 2, 1, 6, 3, 1, 2, 2, 6, 3, 3, 3, 6},
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_enchanted_mango",
			"item_quelling_blade",
			"item_magic_stick",
			"item_magic_wand",
			"item_phase_boots",
			"item_enchanted_mango",
			"item_ancient_janggo",
			"item_medallion_of_courage",
			"item_vladmir",
			"item_radiance",
			"item_spirit_vessel",
			"item_solar_crest",
			"item_ultimate_scepter2",
			"item_manta",
			"item_heavens_halberd",
			"item_travel_boots2",
			"item_moon_shard",
		},
		--出售
		['Sell'] = {
			"item_ancient_janggo",
			"item_quelling_blade",
			
			"item_radiance",
			"item_magic_wand",

			"item_manta",
			"item_ancient_janggo",
			
			"item_heavens_halberd",
			"item_vladmir",
			
			"item_travel_boots",
			"item_phase_boots",
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	['Ability'] = {2,1,1,3,1,6,1,2,2,2,6,3,3,3,6},
	['Buy'] = {
		'item_tango',
		'item_flask',
		'item_quelling_blade',
		'item_soul_ring',
		'item_phase_boots',
		'item_blade_mail',
		'item_mjollnir',
		'item_sange_and_yasha',
		'item_radiance',
		'item_satanic',
		'item_heart',
	},
	['Sell'] = {
		'item_crimson_guard',
		'item_quelling_blade',
	}
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData, true)


nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:IsIllusion() 
		then 
			Minion.IllusionThink(hMinionUnit)	
		end
	end

end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'Q','W'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X;