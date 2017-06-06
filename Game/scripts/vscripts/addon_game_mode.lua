-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

SMASHVERSION = 1.0
require('internal/util')
require('gamemode')


function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint(1,"[BAREBONES] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle","particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf",context)
  PrecacheResource("particle","particles/dev/library/base_dust_hit.vpcf",context)
  PrecacheResource("particle","particles/basic/basic_attack_glow.vpcf",context)
  PrecacheResource("particle_folder", "particles/test_particle", context)



  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheResource("model_folder", "particles/heroes/earthshaker", context)
  PrecacheResource("model_folder", "particles/heroes/zuus", context)
  PrecacheResource("model_folder", "particles/heroes/rattletrap", context)
  PrecacheResource("model_folder", "particles/heroes/nyx_assassin", context)
  PrecacheResource("model_folder", "particles/heroes/lina", context)
  PrecacheResource("model_folder", "particles/heroes/puck", context)
  PrecacheResource("model_folder", "particles/heroes/mirana", context)
  PrecacheResource("model_folder", "particles/heroes/tinker", context)
  PrecacheResource("model_folder", "particles/heroes/tusk", context)
 


  PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  PrecacheResource("model", "models/particle/snowball.vmdl", context)
  PrecacheModel("models/heroes/earthshaker/earthshaker.vmdl", context)
  PrecacheModel("models/heroes/zuus/zuus.vmdl", context)
  --PrecacheModel("models/props_gameplay/treasure_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest002.vmdl", context)

  PrecacheModel("models/props_gameplay/rune_regeneration01.vmdl", context)
  PrecacheModel("models/props_gameplay/rune_doubledamage01.vmdl", context)
  PrecacheModel("models/props_gameplay/rune_arcane.vmdl", context)
  PrecacheModel("models/props_gameplay/rune_haste01.vmdl", context)
  PrecacheModel("models/props_gameplay/rune_invisibility01.vmdl", context)

  -- Sounds can precached here like anything else
  -- Precaching CM for the sounds
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context)
  -- Precaching the jump sound from zuus for the rune.
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)


  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_earthshaker", context)
  PrecacheUnitByNameSync("npc_dota_hero_tusk", context)
  PrecacheUnitByNameSync("npc_dota_hero_mirana", context)
  PrecacheUnitByNameSync("npc_dota_hero_tinker", context)
  PrecacheUnitByNameSync("npc_dota_hero_lina", context)
  PrecacheUnitByNameSync("npc_dota_hero_puck", context)
  PrecacheUnitByNameSync("npc_dota_hero_rattletrap", context)
end

-- Create the game mode when we activate
function Activate()


  GameRules.GameMode = GameMode()
  --GameRules.GameMode:SetupMode()
  GameRules.GameMode:_InitGameMode()

end