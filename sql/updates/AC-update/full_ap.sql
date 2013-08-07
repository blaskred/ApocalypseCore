DELETE FROM `trinity_string` WHERE `entry` = 11002;
INSERT INTO `trinity_string` (`entry`, `content_default`) VALUES
(11002, '|cFFFFBF00[%s]:|cFFFFFFFF [%s] |cFF00FFFFdetected as possible cheater.');
UPDATE `gameobject_template` SET `flags` = '36' WHERE `entry` IN (192642,192643);
DELETE FROM disables WHERE sourceType = 3 AND entry IN (10,11);

SET @Hadronox                := 28921;
SET @Crusher                 := 28922;
SET @NoSpellNecromancer      := 29119; -- These 3 are used for initial spawns and reinforcement groups
SET @NoSpellChampion         := 29117; -- -//-
SET @NoSpellFiend            := 29118; -- -//-
SET @AttackingNecromancer    := 28925; -- Periodically sent NPCs to attack player (max 3 for each front door)
SET @AttackingChampion       := 28924; -- -//-
SET @AttackingFiend          := 29051; -- -//-
SET @LARGE_TRIGGER_AOI       := 23472; -- Triggers used at doors to summon spider trash
SET @StaticCrusher          := 127402; -- Guid of static spawned Crusher
SET @WP_Hadronox          := 28921*10; -- Hadronox path through tunnel
SET @WEB_SIDE_DOOR           := 53185; -- Spell used to "web" spawning doors
SET @WEB_FRONT_DOORS         := 53177; -- -//-
SET @GUID1                  := 209846; -- Guids of 2 guards of initial Crusher
SET @GUID2                  := 209847; -- -//-

-- Delete existing unblizzlike spawns
DELETE FROM `creature` WHERE `id` IN (29064,29063,29062,29098,29096,29097,@AttackingNecromancer,@AttackingChampion,@AttackingFiend,@NoSpellNecromancer);

-- Delete addon data from previous mentioned wrong spanws
DELETE FROM `creature_addon` WHERE `guid` BETWEEN 127316 AND 127337;
DELETE FROM `creature_addon` WHERE `guid` BETWEEN 127340 AND 127375;
DELETE FROM `creature_addon` WHERE `guid` BETWEEN 127293 AND 127315;
DELETE FROM `creature_addon` WHERE `guid` BETWEEN 127272 AND 127292;
DELETE FROM `creature_addon` WHERE `guid`=12246;
DELETE FROM `creature_addon` WHERE `guid`=127401;

-- Assign ScriptNames to creature_templates
UPDATE `creature_template` SET `ScriptName`='npc_anub_ar_crusher' WHERE `entry` IN (28922); -- Anub'Ar Crusher
UPDATE `creature_template` SET `ScriptName`='npc_anub_ar_champion' WHERE `entry` IN (29117,28924,29096,29062); -- Anub'Ar Champions
UPDATE `creature_template` SET `ScriptName`='npc_anub_ar_necromancer' WHERE `entry` IN (29119,28925,29064,29098); -- Anub'Ar Necromancers
UPDATE `creature_template` SET `ScriptName`='npc_anub_ar_crypt_fiend' WHERE `entry` IN (29118,29051,29063,29097); -- Anub'Ar Crypt Fiends

-- Replace wrong faction
UPDATE `creature_template` SET `faction_A`=14,`faction_H`=14 WHERE `entry` IN (28924,28925,29051);

-- Remove creature_ai support where there was one
DELETE FROM `creature_ai_scripts` WHERE `creature_id` IN (@Crusher,@NoSpellChampion,@NoSpellNecromancer,@NoSpellFiend,@AttackingNecromancer,@AttackingFiend,@AttackingChampion,29062,29096,29063,29097,29064,29098);
UPDATE `creature_template` SET `AIName`='' WHERE `entry` IN (@Crusher,@NoSpellChampion,@NoSpellNecromancer,@NoSpellFiend,@AttackingNecromancer,@AttackingFiend,@AttackingChampion,29062,29096,29063,29097,29064,29098);

-- Update bounding radius and combat reach
UPDATE `creature_model_info` SET `bounding_radius`=0.31,`combat_reach`=1 WHERE `modelid` IN (29096,29062,29064,28924);
UPDATE `creature_model_info` SET `bounding_radius`=1,`combat_reach`=1.25 WHERE `modelid` IN (29097,29063,28921);
UPDATE `creature_model_info` SET `bounding_radius`=0.31,`combat_reach`=1.5 WHERE `modelid` IN (29098,29119,28925);
UPDATE `creature_model_info` SET `bounding_radius`=1.35,`combat_reach`=1.6875 WHERE `modelid` IN (29118,29051);
UPDATE `creature_model_info` SET `bounding_radius`=0.31,`combat_reach`=1.25 WHERE `modelid`=29117;
UPDATE `creature_model_info` SET `bounding_radius`=0.375,`combat_reach`=7.5 WHERE `modelid`=28922;
UPDATE `creature_model_info` SET `bounding_radius`=0.85,`combat_reach`=1.275 WHERE `modelid`=29153;

-- Insert into creature_text - Anub'ar Crusher and Hadronox texts
DELETE FROM `creature_text` WHERE `entry` IN (@Crusher,@Hadronox);
INSERT INTO `creature_text` (`entry`,`groupid`,`id`,`text`,`type`,`language`,`probability`,`emote`,`duration`,`sound`,`comment`) VALUES
(@Crusher,0,0,'The gate has been breached! Quickly, divert forces to deal with these invaders!',14,0,100,1,2500,0,'Anub''ar Crusher'),
(@Crusher,1,0,'Anub''ar Crusher goes into a frenzy!',41,0,100,1,1000,0,'Anub''ar Crusher'),
(@Hadronox,0,0,'Hadronox moves up the tunnel!',41,0,100,1,1000,0,'Hadronox');

-- Add some needed conditions
DELETE FROM `conditions` WHERE `SourceEntry` IN (53826,53827,53828,@WEB_SIDE_DOOR,@WEB_FRONT_DOORS) AND `SourceTypeOrReferenceId`=13;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
-- Don't asky me why, but they hit only the very caster implicitly?!
(13,1,53826,0,0,31,0,3,23472,0,0,0,'', 'Event 0 of Anub\'ar Champion can hit only trigger'),
(13,1,53826,0,0,33,0,1,0,0,0,0,'', 'Event 2 of  Anub\'ar Champion caster and hit target can only be same npc'),
(13,1,53827,0,0,31,0,3,23472,0,0,0,'', 'Event 0 of  Anub\'ar Necromancer can hit only trigger'),
(13,1,53827,0,0,33,0,1,0,0,0,0,'', 'Event 2 of  Anub\'ar Necromancer caster and hit target can only be same npc'),
(13,1,53828,0,0,31,0,3,23472,0,0,0,'', 'Event 0 of  Anub\'ar Crypt Fiend can hit only trigger'),
(13,1,53828,0,0,33,0,1,0,0,0,0,'', 'Event 2 of  Anub\'ar Crypt Fiend caster and hit target can only be same npc'),
(13,1,@WEB_SIDE_DOOR,0,0,31,0,3,23472,0,0,0,'', 'Web Side Door can hit only World Trigger Large AOI'),
(13,1,@WEB_FRONT_DOORS,0,0,31,0,3,23472,0,0,0,'', 'Web Front Doors can hit only World Trigger Large AOI');

-- Insert into waypoint_data - Hadronox waypoints on the way up
DELETE FROM `waypoint_data` WHERE `id`=@WP_Hadronox;
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `move_flag`, `action`, `action_chance`, `wpguid`) VALUES
(@WP_Hadronox,1,530.406128,539.697144,678.06640,0,1,0,0,100,0),
(@WP_Hadronox,2,539.736572,533.151306,684.36322,0,1,0,0,100,0),
(@WP_Hadronox,3,554.09241,520.610229,690.13574,0,1,0,0,100,0),
(@WP_Hadronox,4,573.976929,513.072876,698.37188,0,1,0,0,100,0),
(@WP_Hadronox,5,566.644714,513.355530,698.91723,0,1,0,0,100,0),
(@WP_Hadronox,6,584.711609,509.847137,696.98925,0,1,0,0,100,0),
(@WP_Hadronox,7,588.071411,511.273407,695.12219,0,1,0,0,100,0),
(@WP_Hadronox,8,602.654419,511.136871,694.73089,0,1,0,0,100,0),
(@WP_Hadronox,9,617.250305,522.585205,695.48046,0,1,0,0,100,0),
(@WP_Hadronox,10,623.674683,536.210999,704.561,0,1,0,0,100,0),
(@WP_Hadronox,11,620.4,561.0,717.8,0,1,0,0,100,0),
(@WP_Hadronox,12,602.9,579.5,724.0,0,1,0,0,100,0),
(@WP_Hadronox,13,532.5,560.0,732.0,0,0,1,0,100,0);

-- Update orientation of the guards of initial Crusher
UPDATE `creature` SET `orientation`=4.8 WHERE `guid` IN (@GUID1,@GUID2);

-- Linked respawn - remove linked_respawn of unblizzlike spawned trash
DELETE FROM `linked_respawn` WHERE `guid` IN (127272,127273,127275,127293,127296,127318,127340,127341,127350,127351,127352,127355,127357,127359,127360,127364,127365,127375,127379,127380);

-- Linked respawn - link initial spawned in db first Crusher's group to first boss death in order to bound the id,
-- since Hadronox actions are permanent (and adds won't reset on even rest, also bound triggers).
DELETE FROM `linked_respawn` WHERE `guid` IN (@StaticCrusher,@GUID1,@GUID2,127376,127377,127378);
INSERT INTO `linked_respawn` (`guid`,`linkedGuid`,`linkType`) VALUES
(@GUID1,127214,0),
(@GUID2,127214,0),
(@StaticCrusher,127214,0),
(127376,127214,0), -- Large Trigger AOI
(127377,127214,0), -- -//-
(127378,127214,0); -- -//-

-- Add all 3 auras to each of the invisible triggers
DELETE FROM `creature_addon` WHERE `guid` IN (127376,127377,127378);
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `auras`) VALUES
(127376,0,0,0,1,0, '53035 53036 53037'), -- Anub'ar Champion, Necromancer and Crypt Fiend Periodic
(127377,0,0,0,1,0, '53035 53036 53037'), -- Anub'ar Champion, Necromancer and Crypt Fiend Periodic
(127378,0,0,0,1,0, '53035 53036 53037'); -- Anub'ar Champion, Necromancer and Crypt Fiend Periodic

-- Update orientations of triggers to set webbed doors animation correctly
UPDATE `creature` SET `orientation`=2.4360 WHERE `guid`=127377;
UPDATE `creature` SET `orientation`=0.694 WHERE `guid`=127378;
UPDATE `creature` SET `orientation`=2.202 WHERE `guid`=127376;

-- Creature template addon updates - add missing auras to some trash adds
DELETE FROM `creature_template_addon` WHERE `entry` IN (@AttackingChampion,@AttackingNecromancer,@AttackingFiend,29117,29118,29119,29062,29063,29064,29096,29097,29098,@Hadronox);
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `auras`) VALUES
-- All these 53255 auras are used to check if event was reseted
(@AttackingChampion,0,0,0,1,0, '53255'),
(@AttackingNecromancer,0,0,0,1,0, '53255'),
(@AttackingFiend,0,0,0,1,0, '53255'),
(29117,0,0,0,1,0, ''),
(29118,0,0,0,1,0, ''),
(29119,0,0,0,1,0, ''),
(29063,0,0,0,1,0, ''),
(29097,0,0,0,1,0, ''),
(29062,0,0,0,1,0, ''),
(29096,0,0,0,1,0, ''),
(29064,0,0,0,1,0, ''),
(29098,0,0,0,1,0, ''),
(@Hadronox,0,0,0,1,0, '');

-- Update position - Adjust Hadronox spawning position
UPDATE `creature` SET `position_x`=515.5848,`position_y`=544.2007,`position_z`=673.6272,`orientation`=5.647 WHERE `guid`=127401;

-- Add spelldifficulty spells
DELETE FROM `spelldifficulty_dbc` WHERE `id` IN (53030,53400,57731,53406,53318,53330,53322,53317,53394);
INSERT INTO `spelldifficulty_dbc`(`id`,`spellid0`,`spellid1`) VALUES
(53030,53030,59417), -- Spell Leech Poison
(53400,53400,59419), -- Spell Acid Cloud
(57731,57731,59421), -- Spell Web Grab - cast only when players are fighting boss
(53406,53406,59420), -- Spell Web Grab - cast when players aren't fighting boss
(53318,53318,59346), -- Spell Smash used by Anub'Ar Crusher
(53330,53330,59348), -- Spell Infected Wounds used by Anub'Ar Crypt Fiend
(53322,53322,59347), -- Spell Crushing Webs used by Anub'Ar Crypt Fiend
(53317,53317,59343), -- Spell Rend used by Anub'Ar Champion
(53394,53394,59344); -- Spell Pummel used by Anub'Ar Champion

-- Add spell_script names
DELETE FROM `spell_script_names` WHERE `spell_id` IN (53035,53037,53036,@WEB_FRONT_DOORS,@WEB_SIDE_DOOR,53255);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(53035, 'spell_trigger_large_aoi_summon_anubar_champion_periodic'),
(53037, 'spell_trigger_large_aoi_summon_anubar_crypt_fiend_periodic'),
(53036, 'spell_trigger_large_aoi_summon_anubar_necromancer_periodic'),
(53255, 'spell_hadronox_event_check_reset'),
(@WEB_FRONT_DOORS, 'spell_hadronox_web_front_doors'),
(@WEB_SIDE_DOOR, 'spell_hadronox_web_side_door');

-- Remove http://www.wowhead.com/achievement=1297 "Hadronox Denied" from disabled
DELETE FROM `disables` WHERE `sourceType`=4 AND `entry`=4244;

-- Achievement criteria data - instance script support
DELETE FROM `achievement_criteria_data` WHERE `criteria_id`=4244 AND `type`=11;
INSERT INTO `achievement_criteria_data` (`criteria_id`,`type`,`value1`,`value2`,`ScriptName`) VALUES
(4244,11,0,0, 'achievement_hadronox_denied');

UPDATE `creature_template` SET `ScriptName`='bosses_isle_of_conquest' WHERE `entry` IN (34924,34922);

-- Teleport Isle of Conquest battleground
UPDATE `spell_linked_spell` SET `spell_effect` = 66551 WHERE `spell_trigger` IN (66549, 66548); 
UPDATE `spell_linked_spell` SET `spell_trigger` = 66551 WHERE `spell_effect` IN (-66548, -66549); 

DELETE FROM`creature_text` WHERE `entry` = 23872;
INSERT INTO `creature_text` (`entry`, `groupid`, `id`, `text`, `type`, `language`, `probability`, `emote`, `duration`, `sound`, `comment`) VALUES 
('23872', '0', '0', 'This is an insult! An affront! They deny us participation in time-honored dwarven traditions!', '12', '0', '0', '0', '0', '0', 'Coren Rant 1'),
('23872', '1', '0', 'Are we going to hide in our mountain and let those swill-peddlers have their little shindig without us?', '12', '0', '0', '0', '0', '0', 'Coren Rant 2'),
('23872', '2', '0', 'DAMN RIGHT! We''ll show ''em why you don''t cross the Dark Iron dwarves!', '12', '0', '0', '0', '0', '0', 'Coren Rant 3'),
('23872', '3', '0', 'You''ll pay for this insult!', '12', '0', '0', '0', '0', '0', 'Coren Intro'),
('23872', '4', '0', 'Smash their kegs! DRAIN BREWFEST DRY!', '12', '0', '0', '0', '0', '0', 'Coren something');

DELETE FROM`creature_text` WHERE `entry` = 23795;
INSERT INTO `creature_text` (`entry`, `groupid`, `id`, `text`, `type`, `language`, `probability`, `emote`, `duration`, `sound`, `comment`) VALUES 
('23795', '0', '0', 'Yeah!', '12', '0', '100', '0', '0', '0', 'Dark Iron Antagonist'),
('23795', '0', '1', 'Right!', '12', '0', '100', '0', '0', '0', 'Dark Iron Antagonist'),
('23795', '0', '2', 'You said it!', '12', '0', '100', '0', '0', '0', 'Dark Iron Antagonist'),
('23795', '0', '3', 'Damn straight!', '12', '0', '100', '0', '0', '0', 'Dark Iron Antagonist'),
('23795', '1', '0', 'NO!', '0', '0', '100', '12', '0', '0', 'Dark Iron Antagonist'),
('23795', '1', '1', 'No way!', '0', '0', '100', '12', '0', '0', 'Dark Iron Antagonist'),
('23795', '1', '2', 'Not on your life!', '12', '0', '100', '0', '0', '0', 'Dark Iron Antagonist'),
('23795', '2', '0', 'Time to die, $C.', '12', '0', '50', '0', '0', '0', 'Dark Iron Antagonist'),
('23795', '2', '1', 'Never cross a Dark Iron, $C.', '12', '0', '50', '0', '0', '0', 'Dark Iron Antagonist');

UPDATE  `creature_template` SET  `faction_A` =  '35', `faction_H` =  '35', `npcflag` =  '1' WHERE `entry` =23872;
UPDATE  `creature_template` SET  `faction_A` =  '35', `faction_H` =  '35' WHERE  `entry` =23795;

DELETE FROM `creature` WHERE `id` IN (23795, 23872);
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`) VALUES 
('250640', '23795', '230', '1', '1', '0', '0', '896.401', '-130.886', '-49.7459', '2.56785', '300', '0', '0', '12600', '0', '0', '0', '0', '0'), -- Antagonist
('250642', '23795', '230', '1', '1', '0', '0', '895.341', '-132.526', '-49.7473', '2.56785', '300', '0', '0', '12600', '0', '0', '0', '0', '0'),
('250644', '23795', '230', '1', '1', '0', '0', '894.091', '-134.46', '-49.7488', '2.56785', '300', '0', '0', '12600', '0', '0', '0', '0', '0'),
('250400', '23872', '230', '1', '1', '0', '0', '895.679', '-127.46', '-49.7433', '3.63599', '43200', '0', '0', '302400', '0', '2', '1', '0', '0'); -- Spawn Coren

DELETE FROM `waypoint_data` WHERE `id` = 2504000;
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `move_flag`, `action`, `action_chance`, `wpguid`) VALUES 
('2504000', '1', '888.65', '-131.418', '-49.7426', '0', '500', '0', '0', '100', '0'),
('2504000', '2', '895.869', '-127.393', '-49.7432', '0', '500', '0', '0', '100', '0');

DELETE FROM `game_event_creature` WHERE `guid` IN (250640, 250642, 250644, 250400);
INSERT INTO  `game_event_creature` (`eventEntry`,`guid`)VALUES 
('24', '250640'),
('24', '250642'),
('24', '250644'),
('24', '250400');

DELETE FROM `creature_addon` WHERE `guid` = 250400;
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `auras`) VALUES ('250400', '2504000', '0', '0', '0', '0', NULL);

UPDATE  `creature_template` SET  `ScriptName` =  'npc_dark_iron_antagonist' WHERE  `entry` =23795;
UPDATE  `creature_template` SET  `ScriptName` =  'boss_coren_direbrew' WHERE  `entry` =23872;

-- Fixes Orb Rotation being visible to players.
UPDATE `creature_template` SET `modelid1`=169, `modelid2`=11686, `flags_extra` = `flags_extra` | 128 WHERE `entry` IN (40091, 43280, 43281, 43282);

-- Halls of Reflection
-- Creature Defines 
SET @NPC_UTHER              := 37225; 
SET @NPC_JAINA_OUTRO        := 36955;
SET @NPC_SYLVANA_OUTRO      := 37554;
SET @NPC_FROSTWORN_GENERAL  := 36723;
SET @NPC_LICH_KING_EVENT    := 36954;
SET @NPC_LICH_KING_BOSS     := 37226;
SET @NPC_QUEL_DELAR			:= 37158;

-- LK adds
DELETE FROM `creature_template` WHERE `entry` IN (37014, 36940, 36941, 37069, 37550, 37551, 37549);
INSERT INTO `creature_template` (`entry`, `difficulty_entry_1`, `difficulty_entry_2`, `difficulty_entry_3`, `KillCredit1`, `KillCredit2`, `modelid1`, `modelid2`, `modelid3`, `modelid4`, `name`, `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`, `exp`, `faction_A`, `faction_H`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `rank`, `mindmg`, `maxdmg`, `dmgschool`, `attackpower`, `dmg_multiplier`, `baseattacktime`, `rangeattacktime`, `unit_class`, `unit_flags`, `dynamicflags`, `family`, `trainer_type`, `trainer_spell`, `trainer_class`, `trainer_race`, `minrangedmg`, `maxrangedmg`, `rangedattackpower`, `type`, `type_flags`, `lootid`, `pickpocketloot`, `skinloot`, `resistance1`, `resistance2`, `resistance3`, `resistance4`, `resistance5`, `resistance6`, `spell1`, `spell2`, `spell3`, `spell4`, `spell5`, `spell6`, `spell7`, `spell8`, `PetSpellDataId`, `VehicleId`, `mingold`, `maxgold`, `AIName`, `MovementType`, `InhabitType`, `Health_mod`, `Mana_mod`, `Armor_mod`, `RacialLeader`, `questItem1`, `questItem2`, `questItem3`, `questItem4`, `questItem5`, `questItem6`, `movementId`, `RegenHealth`, `mechanic_immune_mask`, `flags_extra`, `ScriptName`, `WDBVerified`) VALUES
(36940, 37550, 0, 0, 0, 0, 24993, 0, 0, 0, 'Raging Ghoul', '', '', 0, 80, 80, 2, 1771, 1771, 0, 2, 1.42857, 1, 0, 422, 586, 0, 642, 1, 2000, 0, 1, 0, 8, 0, 0, 0, 0, 0, 345, 509, 103, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 151, 1, 8388624, 0, 'npc_raging_gnoul', 12340),
(36941, 37551, 0, 0, 0, 0, 25245, 0, 0, 0, 'Risen Witch Doctor', '', '', 0, 80, 80, 2, 1771, 1771, 0, 2, 1.42857, 1, 1, 417, 582, 0, 608, 7.5, 2000, 0, 2, 0, 8, 0, 0, 0, 0, 0, 341, 506, 80, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 6, 1, 1, 0, 0, 0, 0, 0, 0, 0, 151, 1, 8388624, 0, 'npc_risen_witch_doctor', 12340),
(37014, 0, 0, 0, 0, 0, 169, 16925, 0, 0, 'Ice Wall Target', '', '', 0, 60, 60, 0, 114, 114, 0, 1, 0.99206, 1, 0, 2, 2, 0, 24, 1, 2000, 0, 1, 33555200, 8, 0, 0, 0, 0, 0, 1, 1, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 7, 1.35, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 128, '', 12340),
(37069, 37549, 0, 0, 0, 0, 30503, 0, 0, 0, 'Lumbering Abomination', '', '', 0, 80, 80, 2, 1771, 1771, 0, 1, 1.14286, 1, 1, 422, 586, 0, 642, 7.5, 2000, 0, 1, 0, 8, 0, 0, 0, 0, 0, 345, 509, 103, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 10, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 8388624, 0, 'npc_abon', 12340),
(37549, 0, 0, 0, 37069, 0, 30503, 0, 0, 0, 'Lumbering Abomination (1)', '', '', 0, 80, 80, 2, 1771, 1771, 0, 1, 1.14286, 1, 1, 422, 586, 0, 642, 13, 0, 0, 1, 0, 8, 0, 0, 0, 0, 0, 345, 509, 103, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 15, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 8388624, 0, '', 12340),
(37550, 0, 0, 0, 36940, 0, 24993, 0, 0, 0, 'Raging Ghoul (1)', '', '', 0, 80, 80, 2, 1771, 1771, 0, 2, 1.42857, 1, 0, 422, 586, 0, 642, 1, 0, 0, 1, 0, 8, 0, 0, 0, 0, 0, 345, 509, 103, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 1.5, 1, 1, 0, 0, 0, 0, 0, 0, 0, 151, 1, 8388624, 0, '', 12340),
(37551, 0, 0, 0, 36941, 0, 25245, 0, 0, 0, 'Risen Witch Doctor (1)', '', '', 0, 80, 80, 2, 1771, 1771, 0, 2, 1.42857, 1, 1, 417, 582, 0, 608, 13, 0, 0, 2, 0, 8, 0, 0, 0, 0, 0, 341, 506, 80, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 7.5, 1, 1, 0, 0, 0, 0, 0, 0, 0, 151, 1, 8388624, 0, '', 12340);

-- Creature template updates
UPDATE `creature_template` SET `AIName`='', `Scriptname`='npc_frostworn_general' WHERE `entry`=@NPC_FROSTWORN_GENERAL;
UPDATE `creature_template` SET `AIName`='', `Scriptname`='npc_jaina_and_sylvana_hor_part2' WHERE `entry` IN (@NPC_JAINA_OUTRO, @NPC_SYLVANA_OUTRO);
UPDATE `creature_template` SET `AIName`='', `Scriptname`='boss_lich_king_hor' WHERE `entry`=@NPC_LICH_KING_BOSS;
UPDATE `creature_template` SET `AIName`='', `Scriptname`='npc_sylvanas_hor_part1' WHERE `entry`=37223;
UPDATE `creature_template` SET `AIName`='', `Scriptname`='npc_jaina_hor_part1' WHERE `entry`=37221;
UPDATE `creature_template` SET `AIName`='', `Scriptname`='npc_raging_gnoul' WHERE `entry`=36940;
UPDATE `creature_template` SET `AIName`='', `Scriptname`='npc_risen_witch_doctor' WHERE `entry`=36941;
UPDATE `creature_template` SET `AIName`='', `Scriptname`='npc_abon' WHERE `entry`=37069;
UPDATE `creature_template` SET `AIName`='', `Scriptname`='npc_queldelar' WHERE `entry`=@NPC_QUEL_DELAR;
UPDATE `creature_template` SET `unit_flags` = 32784, `AIName` = '', `ScriptName` = 'npc_spiritual_reflection', `difficulty_entry_1` = 37721 WHERE `entry` = 37107;
UPDATE `creature_template` SET `minlevel` = 80, `maxlevel` = 80, `unit_flags` = 32784, `mindmg` = '422', `maxdmg` = '586', `attackpower` = '642', `dmg_multiplier` = '13' WHERE `entry` = 37721;
UPDATE `creature_template` SET `flags_extra` = 1 WHERE `entry` = @NPC_FROSTWORN_GENERAL;
UPDATE `creature_template` SET `flags_extra` = 257 WHERE `entry` = @NPC_FROSTWORN_GENERAL;

UPDATE `creature_template` SET `scale`='0.8' WHERE `entry` IN (@NPC_JAINA_INTRO, @NPC_JAINA_OUTRO);

UPDATE `creature_template` SET `speed_walk`='1.8', `speed_run`='2.0' WHERE `entry` IN (@NPC_LICH_KING_EVENT, @NPC_LICH_KING_BOSS);
UPDATE `creature_template` SET `scale`='1' WHERE `entry` IN (@NPC_UTHER, @NPC_SYLVANA_INTRO, @NPC_LICH_KING_BOSS, @NPC_SYLVANA_OUTRO); 

-- Update equiment to Jaina
DELETE FROM `creature_equip_template` WHERE `entry` = 36955;
INSERT INTO `creature_equip_template` (`entry`, `id`, `itemEntry1`, `itemEntry2`, `itemEntry3`) VALUES
('36955','1','2177','12869','0');

-- Halls of Reflection
 REPLACE INTO `creature_template` (`entry`, `difficulty_entry_1`, `difficulty_entry_2`, `difficulty_entry_3`, `KillCredit1`, `KillCredit2`, `modelid1`, `modelid2`, `modelid3`, `modelid4`, `name`, `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`, `exp`, `faction_A`, `faction_H`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `rank`, `mindmg`, `maxdmg`, `dmgschool`, `attackpower`, `dmg_multiplier`, `baseattacktime`, `rangeattacktime`, `unit_class`, `unit_flags`, `dynamicflags`, `family`, `trainer_type`, `trainer_spell`, `trainer_class`, `trainer_race`, `minrangedmg`, `maxrangedmg`, `rangedattackpower`, `type`, `type_flags`, `lootid`, `pickpocketloot`, `skinloot`, `resistance1`, `resistance2`, `resistance3`, `resistance4`, `resistance5`, `resistance6`, `spell1`, `spell2`, `spell3`, `spell4`, `spell5`, `spell6`, `spell7`, `spell8`, `PetSpellDataId`, `VehicleId`, `mingold`, `maxgold`, `AIName`, `MovementType`, `InhabitType`, `Health_mod`, `Mana_mod`, `Armor_mod`, `RacialLeader`, `questItem1`, `questItem2`, `questItem3`, `questItem4`, `questItem5`, `questItem6`, `movementId`, `RegenHealth`, `mechanic_immune_mask`, `flags_extra`, `ScriptName`, `WDBVerified`) VALUES 
(38172, 38524, 0, 0, 0, 0, 30977, 0, 0, 0, 'Phantom Mage', '', '', 0, 80, 80, 2, 16, 16, 0, 1, 1.28571, 1, 1, 417, 582, 0, 608, 7.5, 2000, 0, 2, 576, 136, 0, 0, 0, 0, 0, 341, 506, 80, 6, 72, 100000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 6.5, 10, 1, 0, 0, 0, 0, 0, 0, 0, 133, 1, 8388624, 0, 'npc_phantom_mage', 12340),
(38175, 38563, 0, 0, 0, 0, 30979, 0, 0, 0, 'Ghostly Priest', '', '', 0, 80, 80, 2, 16, 16, 0, 1, 1.28571, 1, 1, 417, 582, 0, 608, 7.5, 2000, 0, 2, 576, 136, 0, 0, 0, 0, 0, 341, 506, 80, 6, 72, 100000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 6.5, 5, 1, 0, 0, 0, 0, 0, 0, 0, 133, 1,  8388624, 0, 'npc_ghostly_priest', 12340),
(38176, 38544, 0, 0, 0, 0, 30980, 0, 0, 0, 'Tortured Rifleman', '', '', 0, 80, 80, 2, 16, 16, 0, 1, 1.28571, 1, 1, 417, 582, 0, 608, 7.5, 2000, 0, 2, 576, 136, 0, 0, 0, 0, 0, 341, 506, 80, 6, 72, 100000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 6.5, 5, 1, 0, 0, 0, 0, 0, 0, 0, 133, 1, 8388624, 0, 'npc_tortured_rifleman', 12340),
(38173, 38525, 0, 0, 0, 0, 30978, 0, 0, 0, 'Spectral Footman', '', '', 0, 80, 80, 2, 16, 16, 0, 1, 1.28571, 1, 1, 422, 586, 0, 642, 7.5, 2000, 0, 1, 576, 136, 0, 0, 0, 0, 0, 345, 509, 103, 6, 72, 100000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 6.5, 5, 1, 0, 0, 0, 0, 0, 0, 0, 133, 1, 8388624, 0, 'npc_spectral_footman', 12340),
(38177, 38564, 0, 0, 0, 0, 30981, 0, 0, 0, 'Shadowy Mercenary', '', '', 0, 80, 80, 2, 16, 16, 0, 1, 1.28571, 1, 1, 422, 586, 0, 642, 7.5, 2000, 0, 1, 576, 136, 0, 0, 0, 0, 0, 345, 509, 103, 6, 72, 100000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 6.5, 5, 1, 0, 0, 0, 0, 0, 0, 0, 133, 1,  8388624, 0, 'npc_shadowy_mercenary', 12340),
(38113, 38603, 0, 0, 0, 0, 30973, 0, 0, 0, 'Marwyn', '', '', 0, 82, 82, 2, 16, 16, 0, 1.2, 1.42857, 1, 1, 488, 642, 0, 782, 7.5, 2000, 0, 1, 576, 136, 0, 0, 0, 0, 0, 363, 521, 121, 6, 72, 38113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 40, 1, 1, 0, 0, 0, 0, 0, 0, 0, 147, 1, 617299955, 0, 'boss_marwyn', 12340),
(38112, 38599, 0, 0, 0, 0, 30972, 0, 0, 0, 'Falric', '', '', 0, 82, 82, 2, 16, 16, 0, 1.2, 1.42857, 1, 1, 488, 642, 0, 782, 7.5, 1800, 0, 1, 576, 136, 0, 0, 0, 0, 0, 363, 521, 121, 6, 72, 38112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 28, 1, 1, 0, 0, 0, 0, 0, 0, 0, 147, 1, 617299955, 0, 'boss_falric', 12340);

-- AreaTrigger for waves restarter
DELETE FROM `areatrigger_scripts` WHERE `entry` = 5697;
INSERT INTO `areatrigger_scripts` VALUES
(5697, 'at_hor_waves_restarter');

-- Normal
UPDATE `creature_template` SET `unit_flags`=576 WHERE `entry` IN (38172, 38175, 38176, 38173, 38177, 38113, 38112);
-- Heroic
UPDATE `creature_template` SET `unit_flags`=576 WHERE `entry` IN (38599, 38603, 38524, 38525, 38563, 38544, 38564);
-- Fix faction on Heroic 
UPDATE `creature_template` SET `faction_A`=16, `faction_H`=16 WHERE `entry` = 37720;

-- Waipoints to escort event on Halls of reflection 
-- Jaina
DELETE FROM `script_waypoint` WHERE `entry` IN(@NPC_JAINA_OUTRO,@NPC_LICH_KING_BOSS,@NPC_SYLVANA_OUTRO);
INSERT INTO `script_waypoint` VALUES
-- Jaina
   (@NPC_JAINA_OUTRO, 0, 5587.682,2228.586,733.011, 0, 'WP1'),
   (@NPC_JAINA_OUTRO, 1, 5600.715,2209.058,731.618, 0, 'WP2'),
   (@NPC_JAINA_OUTRO, 2, 5606.417,2193.029,731.129, 0, 'WP3'),
   (@NPC_JAINA_OUTRO, 3, 5598.562,2167.806,730.918, 0, 'WP4 - Summon IceWall 01'),
   (@NPC_JAINA_OUTRO, 4, 5556.436,2099.827,731.827, 0, 'WP5 - Spell Channel'),
   (@NPC_JAINA_OUTRO, 5, 5543.498,2071.234,731.702, 0, 'WP6'),
   (@NPC_JAINA_OUTRO, 6, 5528.969,2036.121,731.407, 0, 'WP7'),
   (@NPC_JAINA_OUTRO, 7, 5512.045,1996.702,735.122, 0, 'WP8'),
   (@NPC_JAINA_OUTRO, 8, 5504.490,1988.789,735.886, 0, 'WP9 - Spell Channel'),
   (@NPC_JAINA_OUTRO, 9, 5489.645,1966.389,737.653, 0, 'WP10'),
   (@NPC_JAINA_OUTRO, 10, 5475.517,1943.176,741.146, 0, 'WP11'),
   (@NPC_JAINA_OUTRO, 11, 5466.930,1926.049,743.536, 0, 'WP12'),
   (@NPC_JAINA_OUTRO, 12, 5445.157,1894.955,748.757, 0, 'WP13 - Spell Channel'),
   (@NPC_JAINA_OUTRO, 13, 5425.907,1869.708,753.237, 0, 'WP14'),
   (@NPC_JAINA_OUTRO, 14, 5405.118,1833.937,757.486, 0, 'WP15'),
   (@NPC_JAINA_OUTRO, 15, 5370.324,1799.375,761.007, 0, 'WP16'),
   (@NPC_JAINA_OUTRO, 16, 5335.422,1766.951,767.635, 0, 'WP17 - Spell Channel'),
   (@NPC_JAINA_OUTRO, 17, 5311.438,1739.390,774.165, 0, 'WP18'),
   (@NPC_JAINA_OUTRO, 18, 5283.589,1703.755,784.176, 0, 'WP19'),
   (@NPC_JAINA_OUTRO, 19, 5260.400,1677.775,784.301, 3000, 'WP20'),
   (@NPC_JAINA_OUTRO, 20, 5262.439,1680.410,784.294, 0, 'WP21'),
   (@NPC_JAINA_OUTRO, 21, 5260.400,1677.775,784.301, 0, 'WP22'),
-- Sylvana
   (@NPC_SYLVANA_OUTRO, 0, 5587.682,2228.586,733.011, 0, 'WP1'),
   (@NPC_SYLVANA_OUTRO, 1, 5600.715,2209.058,731.618, 0, 'WP2'),
   (@NPC_SYLVANA_OUTRO, 2, 5606.417,2193.029,731.129, 0, 'WP3'),
   (@NPC_SYLVANA_OUTRO, 3, 5598.562,2167.806,730.918, 0, 'WP4 - Summon IceWall 01'),
   (@NPC_SYLVANA_OUTRO, 4, 5556.436,2099.827,731.827, 0, 'WP5 - Spell Channel'),
   (@NPC_SYLVANA_OUTRO, 5, 5543.498,2071.234,731.702, 0, 'WP6'),
   (@NPC_SYLVANA_OUTRO, 6, 5528.969,2036.121,731.407, 0, 'WP7'),
   (@NPC_SYLVANA_OUTRO, 7, 5512.045,1996.702,735.122, 0, 'WP8'),
   (@NPC_SYLVANA_OUTRO, 8, 5504.490,1988.789,735.886, 0, 'WP9 - Spell Channel'),
   (@NPC_SYLVANA_OUTRO, 9, 5489.645,1966.389,737.653, 0, 'WP10'),
   (@NPC_SYLVANA_OUTRO, 10, 5475.517,1943.176,741.146, 0, 'WP11'),
   (@NPC_SYLVANA_OUTRO, 11, 5466.930,1926.049,743.536, 0, 'WP12'),
   (@NPC_SYLVANA_OUTRO, 12, 5445.157,1894.955,748.757, 0, 'WP13 - Spell Channel'),
   (@NPC_SYLVANA_OUTRO, 13, 5425.907,1869.708,753.237, 0, 'WP14'),
   (@NPC_SYLVANA_OUTRO, 14, 5405.118,1833.937,757.486, 0, 'WP15'),
   (@NPC_SYLVANA_OUTRO, 15, 5370.324,1799.375,761.007, 0, 'WP16'),
   (@NPC_SYLVANA_OUTRO, 16, 5335.422,1766.951,767.635, 0, 'WP17 - Spell Channel'),
   (@NPC_SYLVANA_OUTRO, 17, 5311.438,1739.390,774.165, 0, 'WP18'),
   (@NPC_SYLVANA_OUTRO, 18, 5283.589,1703.755,784.176, 0, 'WP19'),
   (@NPC_SYLVANA_OUTRO, 19, 5260.400,1677.775,784.301, 3000, 'WP20'),
   (@NPC_SYLVANA_OUTRO, 20, 5262.439,1680.410,784.294, 0, 'WP21'),
   (@NPC_SYLVANA_OUTRO, 21, 5260.400,1677.775,784.301, 0, 'WP22'),
-- Lich King
   (@NPC_LICH_KING_BOSS, 1, 5577.19, 2236, 733.012, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 2, 5580.57, 2232.22, 733.012, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 3, 5586.67, 2225.54, 733.012, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 4, 5590.45, 2221.41, 733.012, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 5, 5595.75, 2215.62, 732.101, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 6, 5601.21, 2206.49, 731.54, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 7, 5605.01, 2197.9, 731.667, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 8, 5606.55, 2191.39, 730.977, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 9, 5604.68, 2186.11, 730.998, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 10, 5602.26, 2179.9, 730.967, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 11, 5600.06, 2174.38, 730.924, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 12, 5597.29, 2166.81, 730.924, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 13, 5596.25, 2160.36, 730.931, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 14, 5591.79, 2152.87, 731.008, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 15, 5585.47, 2146.63, 731.109, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 16, 5579.1, 2140.34, 731.18, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 17, 5572.56, 2134.21, 731.092, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 18, 5564.08, 2126.53, 730.816, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 19, 5559.04, 2117.64, 730.812, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 20, 5555.77, 2111.88, 730.995, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 21, 5550.82, 2103.14, 731.123, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 22, 5546.02, 2094.68, 731.16, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 23, 5541.53, 2084.42, 730.999, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 24, 5537.5, 2075.18, 730.901, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 25, 5533.76, 2063.84, 730.87, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 26, 5530.97, 2052.98, 730.981, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 27, 5526.75, 2041.73, 731.193, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 28, 5522.88, 2031.65, 731.7, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 29, 5521.01, 2023.02, 732.396, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 30, 5516.55, 2015.36, 733.12, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 31, 5513.06, 2007.33, 733.99, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 32, 5510.43, 1997.9, 735.016, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 33, 5504.53, 1990.39, 735.748, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 34, 5499.34, 1983.78, 736.29, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 35, 5493.11, 1975.86, 736.852, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 36, 5487.58, 1968.81, 737.394, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 37, 5483.12, 1961.78, 738.06, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 38, 5478.33, 1954.2, 739.343, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 39, 5475.2, 1945.84, 740.697, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 40, 5472.15, 1938.02, 741.884, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 41, 5469.26, 1931.34, 742.813, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 42, 5464.23, 1922.25, 744.055, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 43, 5458.43, 1912.96, 745.229, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 44, 5452.26, 1902.95, 747.091, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 45, 5442.44, 1892.51, 749.208, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 46, 5435.67, 1879.7, 751.776, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 47, 5429.03, 1870.73, 753.151, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 48, 5423.72, 1862.16, 754.263, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 49, 5417.21, 1851.7, 755.507, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 50, 5408.94, 1838.38, 757.002, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 51, 5398.8, 1829.61, 757.742, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 52, 5388.47, 1817.95, 759.285, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 53, 5378.23, 1808.5, 760.316, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 54, 5368.5, 1801.35, 760.845, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 55, 5360.86, 1793.16, 762.271, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 56, 5353.62, 1785.4, 763.868, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 57, 5344.78, 1776.09, 765.759, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 58, 5336.38, 1768.67, 767.324, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 59, 5327.56, 1760.12, 769.332, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 60, 5319.62, 1750.7, 771.487, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 61, 5313.12, 1742.99, 773.424, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 62, 5305.41, 1735.79, 775.473, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 63, 5298.93, 1728.16, 777.573, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 64, 5292.54, 1720.37, 779.862, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 65, 5287.11, 1713.96, 781.667, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 66, 5280.14, 1705.21, 784.65, 0, 'HoR WP LichKing'),
   (@NPC_LICH_KING_BOSS, 67, 5277.98, 1701.28, 785.224, 0, 'HoR WP LichKing');

-- Normal loot
DELETE FROM `gameobject_loot_template` WHERE `entry` =27985;
INSERT INTO `gameobject_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincountOrRef`, `maxcount`) VALUES
(27985, 43102, 100, 1, 0, 1, 1),
(27985, 47241, 100, 1, 0, 2, 2),
(27985, 100000, 100, 1, 1, -100000, 2);
DELETE FROM `reference_loot_template` WHERE `entry` =100000;
INSERT INTO `reference_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincountOrRef`, `maxcount`) VALUES
(100000, 49839, 0, 1, 1, 1, 1),
(100000, 49840, 0, 1, 1, 1, 1),
(100000, 49841, 0, 1, 1, 1, 1),
(100000, 49842, 0, 1, 1, 1, 1),
(100000, 49843, 0, 1, 1, 1, 1),
(100000, 49844, 0, 1, 1, 1, 1),
(100000, 49845, 0, 1, 1, 1, 1),
(100000, 49846, 0, 1, 1, 1, 1),
(100000, 49847, 0, 1, 1, 1, 1),
(100000, 49848, 0, 1, 1, 1, 1),
(100000, 49849, 0, 1, 1, 1, 1),
(100000, 49851, 0, 1, 1, 1, 1);

-- Heroic Loot
DELETE FROM `gameobject_loot_template` WHERE `entry` =27993;
INSERT INTO `gameobject_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincountOrRef`, `maxcount`) VALUES
(27993, 43102, 100, 1, 0, 1, 1),
(27993, 47241, 100, 1, 0, 2, 2),
(27993, 100000, 100, 1, 1, -100001, 2);

DELETE FROM `reference_loot_template` WHERE `entry` =100001;
INSERT INTO `reference_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincountOrRef`, `maxcount`) VALUES
(100001, 50302, 0, 1, 1, 1, 1),
(100001, 50303, 0, 1, 1, 1, 1),
(100001, 50304, 0, 1, 1, 1, 1),
(100001, 50305, 0, 1, 1, 1, 1),
(100001, 50306, 0, 1, 1, 1, 1),
(100001, 50308, 0, 1, 1, 1, 1),
(100001, 50309, 0, 1, 1, 1, 1),
(100001, 50310, 0, 1, 1, 1, 1),
(100001, 50311, 0, 1, 1, 1, 1),
(100001, 50312, 0, 1, 1, 1, 1),
(100001, 50313, 0, 1, 1, 1, 1),
(100001, 50314, 0, 1, 1, 1, 1);

-- Fix portal spell
UPDATE `gameobject_template` SET `data0`='53141' WHERE `entry`=202079;

-- Fix loot Halls of Reflection
UPDATE `gameobject_template` SET `flags` = '0' WHERE `gameobject_template`.`entry` = 202212;
UPDATE `gameobject_template` SET `flags` = '0' WHERE `gameobject_template`.`entry` = 201710;
UPDATE `gameobject_template` SET `flags` = '0' WHERE `gameobject_template`.`entry` = 202337;
UPDATE `gameobject_template` SET `flags` = '0' WHERE `gameobject_template`.`entry` = 202336;

-- Creature Text
DELETE FROM `creature_text` WHERE `entry` IN (37221, 37225, 37223, 36954, 38112, 38113, 36955, 37554, 37226, 36723, 37182, 37833, 38177, 38173, 38176, 38175, 38172);
INSERT INTO `creature_text` (`entry`, `groupid`, `id`, `text`, `type`, `language`, `probability`, `emote`, `duration`, `sound`, `comment`) VALUES
(37221, 0, 0, "The chill of this place... Brr... I can feel my blood freezing.", 14, 0, 10, 0, 0, 16631, "Jaina HoR Alliance Intro 1"),
(37221, 1, 0, "What is that! Up ahead! Could it be? Heroes, at my side!", 14, 0, 10, 0, 0, 16632, "Jaina HoR Alliance Intro 2"),
(37221, 2, 0, "Frostmourne: the blade that destroyed our kingdom...", 14, 0, 10, 0, 0, 16633, "Jaina HoR Alliance Intro 3"),
(37221, 3, 0, "Stand back! Touch that blade and your soul will be scarred for all eternity! I must attempt to commune with the spirits locked away within Frostmourne. Give me space. Back up, please.", 14, 0, 10, 0, 0, 16634, "Jaina HoR Alliance Intro 4"),
(37225, 0, 0, "Jaina! Could it truly be you?", 12, 0, 10, 0, 0, 16666, "Uther HoR Alliance Intro 5"),
(37221, 4, 0, "Uther! Dear Uther! I... I'm so sorry.", 12, 0, 10, 0, 0, 16635, "Jaina HoR Alliance Intro 6"),
(37225, 1, 0, "Jaina you haven't much time. The Lich King sees what the sword sees. He will be here shortly!", 12, 0, 10, 0, 0, 16667, "Uther HoR Alliance Intro 7"),
(37221, 5, 0, "Arthas is here? Maybe I...", 12, 0, 10, 0, 0, 16636, "Jaina HoR Alliance Intro 8"),
(37225, 2, 0, "No, girl. Arthas is not here. Arthas is merely a presence within the Lich King's mind. A dwindling presence...", 12, 0, 10, 0, 0, 16668, "Uther HoR Alliance Intro 9"),
(37221, 6, 0, "But Uther, if there's any hope of reaching Arthas. I... I must try.", 12, 0, 10, 0, 0, 16637, "Jaina HoR Alliance Intro 10"),
(37225, 3, 0, "Jaina, listen to me. You must destroy the Lich King. You cannot reason with him. He will kill you and your allies and raise you all as powerful soldiers of the Scourge.", 12, 0, 10, 0, 0, 16669, "Uther HoR Alliance Intro 11"),
(37221, 7, 0, "Tell me how, Uther? How do I destroy my prince? My...", 12, 0, 10, 0, 0, 16638, "Jaina HoR Alliance Intro 12"),
(37225, 4, 0, "Snap out of it, girl. You must destroy the Lich King at the place where he merged with Ner'zhul - atop the spire, at the Frozen Throne. It is the only way.", 12, 0, 10, 0, 0, 16670, "Uther HoR Alliance Intro 13"),
(37221, 8, 0, "You're right, Uther. Forgive me. I... I don't know what got a hold of me. We will deliver this information to the King and the knights that battle the Scourge within Icecrown Citadel.", 12, 0, 10, 0, 0, 16639, "Jaina HoR Alliance Intro 14"),
(37225, 5, 0, "There is... something else that you should know about the Lich King. Control over the Scourge must never be lost. Even if you were to strike down the Lich King, another would have to take his place. For without the control of its master, the Scourge would run rampant across the world - destroying all living things.", 12, 0, 10, 0, 0, 16671, "Uther HoR Alliance Intro 15"),
(37225, 6, 0, "A grand sacrifice by a noble soul...", 12, 0, 10, 0, 0, 16672, "Uther HoR Alliance Intro 16"),
(37221, 9, 0, "Who could bear such a burden?", 12, 0, 10, 0, 0, 16640, "Jaina HoR Alliance Intro 17"),
(37225, 7, 0, "I do not know, Jaina. I suspect that the piece of Arthas that might be left inside the Lich King is all that holds the Scourge from annihilating Azeroth.", 12, 0, 10, 0, 0, 16673, "Uther HoR Alliance Intro 18"),
(37221, 10, 0, "Then maybe there is still hope...", 12, 0, 10, 0, 0, 16641, "Jaina HoR Alliance Intro 19"),
(37225, 8, 0, "No, Jaina! ARRRRRRGHHHH... He... He is coming. You... You must...", 12, 0, 10, 0, 0, 16674, "Uther HoR Alliance Intro 20"),
(37223, 0, 0, "I... I don't believe it! Frostmourne stands before us, unguarded! Just as the Gnome claimed. Come, heroes!", 14, 0, 10, 0, 0, 17049, "Sylvanas HoR Horde Intro 1"),
(37223, 1, 0, "Standing this close to the blade that ended my life... The pain... It is renewed.", 14, 0, 10, 0, 0, 17050, "Sylvanas HoR Horde Intro 2"),
(37223, 2, 0, "I dare not touch it. Stand back! Stand back as I attempt to commune with the blade! Perhaps our salvation lies within...", 14, 0, 10, 0, 0, 17051, "Sylvanas HoR Horde Intro 3"),
(37225, 9, 0, "Careful, girl. I've heard talk of that cursed blade saving us before. Look around you and see what has been born of Frostmourne.", 12, 0, 10, 0, 0, 16659, "Uther HoR Horde Intro 4"),
(37223, 3, 0, "Uther...Uther the Lightbringer. How...", 12, 0, 10, 0, 0, 17052, "Sylvanas HoR Horde Intro 5"),
(37225, 10, 0, "You haven't much time. The Lich King sees what the sword sees. He will be here shortly.", 12, 0, 10, 0, 0, 16660, "Uther HoR Horde Intro 6"),
(37223, 4, 0, "The Lich King is here? Then my destiny shall be fulfilled today!", 12, 0, 10, 0, 0, 17053, "Sylvanas HoR Horde Intro 7"),
(37225, 11, 0, "You cannot defeat the Lich King. Not here. You would be a fool to try. He will kill those who follow you and raise them as powerful servants of the Scourge. But for you, Sylvanas, his reward for you would be worse than the last.", 12, 0, 10, 0, 0, 16661, "Uther HoR Horde Intro 8"),
(37223, 5, 0, "There must be a way... ", 12, 0, 10, 0, 0, 17054, "Sylvanas HoR Horde Intro 9"),
(37225, 12, 0, "Perhaps, but know this: there must always be a Lich King. Even if you were to strike down Arthas, another would have to take his place, for without the control of the Lich King, the Scourge would wash over this world like locusts, destroying all that they touched.", 12, 0, 10, 0, 0, 16662, "Uther HoR Horde Intro 10"),
(37223, 6, 0, "Who could bear such a burden?", 12, 0, 10, 0, 0, 17055, "Sylvanas HoR Horde Intro 11"),
(37225, 13, 0, "I do not know, Banshee Queen. I suspect that the piece of Arthas that might be left inside the Lich King is all that holds the Scourge from annihilating Azeroth.", 12, 0, 10, 0, 0, 16663, "Uther HoR Horde Intro 12"),
(37225, 14, 0, "Alas, the only way to defeat the Lich King is to destroy him at the place he was created.", 12, 0, 10, 0, 0, 16664, "Uther HoR Horde Intro 13"),
(37223, 7, 0, "The Frozen Throne...", 12, 0, 10, 0, 0, 17056, "Sylvanas HoR Horde Intro 14"),
(37225, 15, 0, "Aye. ARRRRRRGHHHH... He... He is coming. You... You must...", 12, 0, 10, 0, 0, 16665, "Uther HoR Horde Intro 15"),
(36954, 0, 0, "SILENCE, PALADIN!", 14, 0, 10, 0, 0, 17225, "HoR Intro LK 1"),
(36954, 1, 0, "So you wish to commune with the dead? You shall have your wish.", 14, 0, 10, 0, 0, 17226, "HoR Intro LK 2"),
(36954, 2, 0, "Falric. Marwyn. Bring their corpses to my chamber when you are through.", 14, 0, 10, 0, 0, 17227, "HoR Intro LK 3"),
(38112, 5, 0, "As you wish, my lord.", 14, 0, 10, 0, 0, 16717, "HoR Intro LK 4"),
(38113, 5, 0, "As you wish, my lord.", 14, 0, 10, 0, 0, 16741, "HoR Intro LK 5"),
(38112, 6, 0, "Soldiers of Lordaeron, rise to meet your master's call!", 14, 0, 10, 0, 0, 16714, "HoR Intro LK 6"),
(37221, 11, 0, "You won't deny me this Arthas! I must know! I must find out!", 14, 0, 10, 0, 0, 16642, "HoR Alliance Intro 20"),
(37223, 8, 0, "You will not escape me that easily, Arthas! I will have my vengeance!", 12, 0, 10, 0, 0, 17057, "Sylvanas HoR Horde Intro 16"),
(36954, 3, 0, "Foolish girl, you seek that which I killed long ago. He is merely a ghost now, a faint echo in my mind.", 14, 0, 10, 0, 0, 17229, "HoR Intro LK 7 Alliance"),
(36954, 4, 0, "I will not make the same mistake again Sylvanas, this time there will be no escape. You failed to serve me in undeath, now all that remains for you is oblivion.", 14, 0, 10, 0, 0, 17228, "HoR Intro LK 7 Horde"),
(37226, 0, 0, "Your allies have arrived, Jaina, just as you promised. You will all become powerful agents of the Scourge.", 14, 0, 10, 0, 0, 17212, "HoR Escape Alliance 1"),
(37226, 1, 0, "I will not make the same mistake again, Sylvanas. This time there will be no escape. You will all serve me in death!", 14, 0, 10, 0, 0, 17213, "HoR Escape Horde 1"),
(36955, 0, 0, "He is too powerful, we must leave this place at once! My magic will hold him in place for only a short time! Come quickly, heroes!", 14, 0, 10, 0, 0, 16644, "HoR Escape Alliance 2"),
(37554, 0, 0, "He's too powerful! Heroes, quickly, come to me! We must leave this place immediately! I will do what I can do hold him in place while we flee.", 14, 0, 10, 0, 0, 17058, "HoR Escape Horde 2"),
(36955, 1, 0, "I will destroy this barrier. You must hold the undead back!", 14, 0, 10, 0, 0, 16607, "HoR Escape Alliance 3 Wall 1"),
(37554, 1, 0, "No wall can hold the Banshee Queen! Keep the undead at bay, heroes! I will tear this barrier down!", 14, 0, 10, 0, 0, 17029, "HoR Escape Horde 3 Wall 1"),
(37226, 2, 0, "Succumb to the chill of the grave.", 14, 0, 10, 0, 0, 17218, "HoR Escape 4 LK"),
(36955, 2, 0, "Another ice wall! Keep the undead from interrupting my incantation so that I may bring this wall down!", 14, 0, 10, 0, 0, 16608, "HoR Escape Alliance 5 Wall 2"),
(37554, 2, 0, "Another barrier? Stand strong, champions! I will bring the wall down!", 14, 0, 10, 0, 0, 17030, "HoR Escape Horde 5 Wall 2"),
(37226, 3, 0, "Another dead end.", 14, 0, 10, 0, 0, 17219, "HoR Escape 6 LK"),
(36955, 3, 0, "He's playing with us! I'll show him what happens to ice when it meets fire!", 14, 0, 10, 0, 0, 16609, "HoR Escape Alliance 7 Wall 3"),
(37554, 3, 0, "I grow tired of these games, Arthas! Your walls can't stop me!", 14, 0, 10, 0, 0, 17031, "HoR Escape Horde 7 Wall 3"),
(37226, 4, 0, "How long can you fight it?", 14, 0, 10, 0, 0, 17220, "HoR Escape 8 LK"),
(36955, 4, 0, "Your barriers can't hold us back much longer, monster. I will shatter them all!", 14, 0, 10, 0, 0, 16610, "HoR Escape Alliance 9 Wall 4"),
(37554, 4, 0, "You won't impede our escape, fiend. Keep the undead off me while I bring this barrier down!", 14, 0, 10, 0, 0, 17032, "HoR Escape Horde 9 Wall 4"),
(36955, 5, 0, "There's an opening up ahead. GO NOW!", 14, 0, 10, 0, 0, 16645, "HoR Escape Alliance 10"),
(37554, 5, 0, "There's an opening up ahead. GO NOW!", 14, 0, 10, 0, 0, 17059, "HoR Escape Horde 10"),
(36955, 6, 0, "We're almost there... Don't give up!", 14, 0, 10, 0, 0, 16646, "HoR Escape Alliance 11"),
(37554, 6, 0, "We're almost there... Don't give up!", 14, 0, 10, 0, 0, 17060, "HoR Escape Horde 11"),
(36955, 7, 0, "It... It's a dead end. We have no choice but to fight. Steel yourself heroes, for this is our last stand!", 14, 0, 10, 0, 0, 16647, "HoR Escape Alliance 12"),
(37554, 7, 0, "BLASTED DEAD END! So this is how it ends. Prepare yourselves, heroes, for today we make our final stand!", 14, 0, 10, 0, 0, 17061, "HoR Escape Horde 12"),
(37182, 0, 0, "Fire! FIRE!", 14, 0, 10, 0, 0, 16721, "HoR Escape Alliance 14"),
(37833, 0, 0, "Fire! FIRE!", 14, 0, 10, 0, 0, 16732, "HoR Escape Horde 14"),
(37182, 1, 0, "Quickly, climb aboard! We mustn't tarry here! There's no telling when this whole mountainside will collapse.", 14, 0, 10, 0, 0, 16722, "HoR Escape Alliance 15"),
(37833, 1, 0, "Get onboard, now! This whole mountainside could collapse at any moment.", 14, 0, 10, 0, 0, 16733, "HoR Escape Horde 15"),
(36955, 8, 0, "Forgive me, heroes. I should have listened to Uther. I... I just had to see for myself. To look into his eyes one last time. I am sorry.", 14, 0, 10, 0, 0, 16648, "HoR Escape Alliance 16"),
(37554, 8, 0, " We are safe, for now. His strength has increased ten-fold since our last battle! It will take a mighty army to destroy the Lich King, an army greater than even the Horde can rouse.", 14, 0, 10, 0, 0, 17062, "HoR Escape Horde 16"),
(36955, 9, 0, "We now know what must be done. I will deliver this news to King Varian and Highlord Fordring.", 14, 0, 10, 0, 0, 16649, "HoR Escape Alliance 16"),
(37226, 5, 0, "There is no escape!", 14, 0, 10, 0, 0, 17217, "boss_the_lich_king_hor 1"),
(37226, 6, 0, "Succumb to the chill of the grave.", 14, 0, 10, 0, 0, 17218, "boss_the_lich_king_hor 2"),
(37226, 7, 0, "Rise minions, do not left them us!", 14, 0, 10, 0, 0, 17216, "boss_the_lich_king_hor 3"),
(37226, 8, 0, "Minions seize them.  Bring their corpses back to me!", 14, 0, 10, 0, 0, 17222, "boss_the_lich_king_hor 4"),
(37226, 9, 0, "Death's cold embrace awaits.", 14, 0, 10, 0, 0, 17221, "boss_the_lich_king_hor 5"),
(37226, 10, 0, "Nowhere to run! You're mine now...", 14, 0, 10, 0, 0, 17223, "boss_the_lich_king_hor 6"),
(37226, 11, 0, "All is lost!", 14, 0, 10, 0, 0, 17215, "boss_the_lich_king_hor wipe"),
(38112, 0, 0, "Men, women and children... None were spared the master's wrath. Your death will be no different.", 14, 0, 10, 0, 0, 16710, "HoR Falric Aggro"),
(38112, 1, 0, "Sniveling maggot!", 14, 0, 10, 0, 0, 16711, "HoR Falric Slay 1"),
(38112, 1, 1, "The children of Stratholme fought with more ferocity!", 14, 0, 10, 0, 0, 16712, "HoR Falric Slay 2"),
(38112, 2, 0, "Despair... so delicious...", 14, 0, 10, 0, 0, 16715, "HoR Falric Impending Despair"),
(38112, 3, 0, "Fear... so exhilarating...", 14, 0, 10, 0, 0, 16716, "HoR Falric Defiling Horor"),
(38112, 4, 0, "Marwyn, finish them...", 14, 0, 10, 0, 0, 16713, "HoR Falric Death"),
(38113, 0, 0, "Death is all that you will find here!", 14, 0, 10, 0, 0, 16734, "HoR Marwyn Aggro"),
(38113, 1, 0, "I saw the same look in his eyes when he died. Terenas could hardly believe it. Hahahaha!", 14, 0, 10, 0, 0, 16735, "HoR Marwyn Slay 1"),
(38113, 1, 1, "Choke on your suffering!", 14, 0, 10, 0, 0, 16736, "HoR Marwyn Slay 2"),
(38113, 2, 0, "Your flesh has decayed before your very eyes!", 14, 0, 10, 0, 0, 16739, "HoR Marwyn Corrupted Flesh"),
(38113, 3, 0, "Waste away into nothingness!", 14, 0, 10, 0, 0, 16734, "HoR Marwyn Well of Corruption"),
(38113, 4, 0, "Yes... Run... Run to meet your destiny... Its bitter, cold embrace, awaits you.", 14, 0, 10, 0, 0, 16737, "HoR Marwyn Death"),
(36723, 0, 0, "You are not worthy to face the Lich King!", 14, 0, 10, 0, 0, 16921, "HoR FrostSworn General Aggro"),
(36723, 1, 0, "Master, I have failed...", 14, 0, 10, 0, 0, 16922, "HoR FrostSworn General Death"),
(38177, 0, 0, 'This is not our final rest.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38173, 0, 0, 'This is not our final rest.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38176, 0, 0, 'This is not our final rest.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38175, 0, 0, 'This is not our final rest.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38172, 0, 0, 'This is not our final rest.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38177, 0, 1, 'All serve the master in death.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38173, 0, 1, 'All serve the master in death.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38176, 0, 1, 'All serve the master in death.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38175, 0, 1, 'All serve the master in death.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38172, 0, 1, 'All serve the master in death.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38177, 0, 2, 'Our souls will never be freed.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38173, 0, 2, 'Our souls will never be freed.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38176, 0, 2, 'Our souls will never be freed.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38175, 0, 2, 'Our souls will never be freed.', 12, 0, 10, 0, 0, 0, 'HoR Trash death'),
(38172, 0, 2, 'Our souls will never be freed.', 12, 0, 10, 0, 0, 0, 'HoR Trash death');

INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincountOrRef`, `maxcount`) VALUES (37158, 50254, -100, 1, 0, 1, 1);

DELETE FROM `creature` WHERE `id`=37158;
INSERT INTO `creature` (`id`, `map`, `spawnMask`, `phaseMask`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`) VALUES (37158, 668, 1, 1, 0, 0, 5304.82, 2000.48, 709.341, 0.800565, 300, 0, 0, 214200, 0, 0, 0, 0, 0);

-- Fixed Halls of Reflection 
-- Creature Spawns
DELETE FROM `gameobject_template` WHERE `entry` = 500001;
INSERT INTO `gameobject_template` VALUES ('500001', '0', '9214', 'Ice Wall', '', '', '', '1375', '0', '2.5', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '', '', '1');
SET @GUID_CREATURE := 202284;
DELETE FROM creature WHERE map=668 AND id IN (14881, 36723, 37221, 37704, 37906, 38112, 38113);
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`) VALUES
(@GUID_CREATURE+1,'37704','668','3','1','17612','0','5309.08','2006.32','711.422','3.93429','604800','0','0','12600','0','0','0','0','0'),
(@GUID_CREATURE+2,'14881','668','3','1','1160','0','5337.6','2012.14','707.695','3.52509','604800','0','0','8','0','0','0','0','0'),
(@GUID_CREATURE+3,'14881','668','3','1','2536','0','5268.91','1969.17','707.696','0.321519','604800','0','0','8','0','0','0','0','0'),
(@GUID_CREATURE+4,'14881','668','3','1','1160','0','5386.99','2080.5','707.695','4.67797','604800','0','0','8','0','0','0','0','0'),
(@GUID_CREATURE+5,'38112','668','3','1','0','0','5271.65','2042.5','709.32','5.51217','604800','0','0','377468','0','0','0','0','0'),
(@GUID_CREATURE+6,'38113','668','3','1','0','0','5344.75','1972.87','709.319','2.33445','604800','0','0','539240','0','0','0','0','0'),
(@GUID_CREATURE+7,'37221','668','3','1','0','0','5236.67','1929.91','707.695','0.837758','604800','0','0','5040000','881400','0','0','0','0'),
(@GUID_CREATURE+8,'36723','668','3','1','0','2432','5413.9','2116.65','707.695','3.94765','604800','0','0','315000','0','0','0','0','0'); 

-- GameObjects Halls Of Refletion
UPDATE `gameobject_template` SET `faction`='1375' WHERE `entry` IN (197341, 202302, 201385, 201596);

-- Spawns
DELETE FROM gameobject WHERE map = 668 AND id IN (190236, 196391, 196392, 197341, 197342, 197343, 201385, 201596, 201710, 201747, 201756, 201885, 201976, 202079, 202212, 202236, 202302, 202336, 202337, 202396, 500001, 500002, 500003);
SET @GUID_GO := 153000;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`) VALUES
(@GUID_GO,201747,668,3,1,5231.04,1923.79,707.044,0.810935,0,0,-0.370856,0.928691,6000,100,1),
(@GUID_GO+1,201756,668,3,1,5231.04,1923.79,707.044,0.810935,0,0,-0.370856,0.928691,6000,100,1),
(@GUID_GO+2,190236,668,3,1,4926.09,1554.96,163.292,-2.26562,0,0,0.999999,-0.001655,6000,100,1),
(@GUID_GO+3,202302,668,3,1,5309.51,2006.64,709.341,5.50041,0,0,0.381473,-0.92438,604800,100,1),
(@GUID_GO+4,202236,668,3,1,5309.51,2006.64,709.341,5.53575,0,0,0.365077,-0.930977,604800,100,1),
(@GUID_GO+5,201596,668,3,1,5275.28,1694.23,786.147,0.981225,0,0,0.471166,0.882044,25,0,0),
(@GUID_GO+6,500001,668,3,1,5323.61,1755.85,770.305,0.784186,0,0,0.382124,0.924111,604800,100,0),
(@GUID_GO+7,196391,668,3,1,5232.31,1925.57,707.695,0.815481,0,0,0.396536,0.918019,300,0,1),
(@GUID_GO+8,196392,668,3,1,5232.31,1925.57,707.695,0.815481,0,0,0.396536,0.918019,300,0,1),
(@GUID_GO+9,202396,668,3,1,5434.27,1881.12,751.303,0.923328,0,0,0.445439,0.895312,604800,100,0),
(@GUID_GO+10,201885,668,3,1,5494.3,1978.27,736.689,1.0885,0,0,0.517777,0.855516,604800,100,0),
(@GUID_GO+11,197341,668,3,1,5359.24,2058.35,707.695,3.96022,0,0,0.917394,-0.397981,300,100,1),
(@GUID_GO+12,201976,668,3,1,5264.6,1959.55,707.695,0.736951,0,0,0.360194,0.932877,300,100,0),
(@GUID_GO+13,197342,668,3,1,5520.72,2228.89,733.011,0.778581,0,0,0.379532,0.925179,300,100,1),
(@GUID_GO+14,197343,668,3,1,5582.96,2230.59,733.011,5.49098,0,0,0.385827,-0.922571,300,100,1),
(@GUID_GO+15,201385,668,3,1,5540.39,2086.48,731.066,1.00057,0,0,0.479677,0.877445,604800,100,0),
(@GUID_GO+16,202337,668,2,1,5252.33,1585.36,796.062,2.80195,0,0,0.985615,0.169007,604800,100,1),
(@GUID_GO+17,202336,668,2,1,5264.22,1584.94,794.359,2.70142,0,0,0.975878,0.218315,604800,100,1),
(@GUID_GO+18,202079,668,3,1,5248.58,1574.22,795.209,0,0,0,0,1,604800,100,1),
(@GUID_GO+19,500002,668,3,1,5247.09,1586.39,773.922,5.86166,0,0,0.209207,-0.977871,300,0,1),
(@GUID_GO+20,500003,668,3,1,5245.17,1582.11,761.72,5.86166,0,0,0.209207,-0.977871,300,0,1),
(@GUID_GO+21,202212,668,1,1,5253.03,1585.13,796.089,2.75698,0,0,0.981566,0.191121,300,0,1),
(@GUID_GO+22,201710,668,1,1,5262.5,1582.41,794.342,2.75698,0,0,0.981566,0.191121,300,0,1);

-- Gunship models
DELETE FROM `gameobject_template` WHERE `entry` IN (201709, 500002, 202211, 500003);
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `IconName`, `castBarCaption`, `unk1`, `faction`, `flags`, `size`, `questItem1`, `questItem2`, `questItem3`, `questItem4`, `questItem5`, `questItem6`, `data0`, `data1`, `data2`, `data3`, `data4`, `data5`, `data6`, `data7`, `data8`, `data9`, `data10`, `data11`, `data12`, `data13`, `data14`, `data15`, `data16`, `data17`, `data18`, `data19`, `data20`, `data21`, `data22`, `data23`, `AIName`, `ScriptName`, `WDBVerified`) VALUES
(201709, 5, 9288, 'Gunship Stairs', '', '', '', 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', 12340),
(202211, 5, 9289, 'Gunship Stairs', '', '', '', 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', 12340),
(500002, 14, 9150, 'The Skybreaker', '', '', '', 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', 1),
(500003, 14, 8253, 'Orgrim''s Hammer', '', '', '', 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', 1);

-- Spawn Ships
DELETE FROM `gameobject` WHERE `id` IN (201709, 500002, 202211, 500003);
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`) VALUES
(150180, 202211, 631, 15, 1, -437.351, 1979.57, 190.897, 0, 0, 0, 0, 1, 6000, 100, 1),
(150185, 202211, 631, 15, 1, -437.564, 1959.54, 203.37, 0, 0, 0, 0, 1, 6000, 100, 1),
(153019, 500002, 668, 3, 1, 5247.09, 1586.39, 773.922, 5.86166, 0, 0, 0.209207, -0.977871, 300, 0, 1),
(153020, 500003, 668, 3, 1, 5245.17, 1582.11, 761.72, 5.86166, 0, 0, 0.209207, -0.977871, 300, 0, 1);

-- Templates
DELETE FROM gameobject_template WHERE entry IN (201709, 202211, 190236, 196391, 196392, 197341, 197342, 197343, 201385, 201596, 201710, 201747, 201756, 201885, 201976, 202079, 202212, 202236, 202302, 202336, 202337, 202396, 500001, 500002, 500003);
INSERT INTO `gameobject_template` (`entry`, `TYPE`, `displayId`, `NAME`, `IconName`, `castBarCaption`, `unk1`, `faction`, `flags`, `size`, `questItem1`, `questItem2`, `questItem3`, `questItem4`, `questItem5`, `questItem6`, `data0`, `data1`, `data2`, `data3`, `data4`, `data5`, `data6`, `data7`, `data8`, `data9`, `data10`, `data11`, `data12`, `data13`, `data14`, `data15`, `data16`, `data17`, `data18`, `data19`, `data20`, `data21`, `data22`, `data23`, `AIName`, `ScriptName`, `WDBVerified`) VALUES
('201596','0','9223','Cave In','','','','1375','4','2','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('197342','0','9124','Doodad_IceCrown_Door_02','','','','1375','36','1','0','0','0','0','0','0','1','0','3','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('197343','0','9124','Doodad_IceCrown_Door_03','','','','1375','36','1','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('201976','0','9124','Doodad_IceCrown_Door_04','','','','114','32','1','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('196391','31','8196','Doodad_InstanceNewPortal_Purple01','','','','0','0','2.72','0','0','0','0','0','0','632','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('201747','31','8196','Doodad_InstanceNewPortal_Purple01','','','','0','0','2.72','0','0','0','0','0','0','668','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('196392','31','8197','Doodad_InstanceNewPortal_Purple_Skull01','','','','0','0','2.72','0','0','0','0','0','0','632','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('201756','31','8197','Doodad_InstanceNewPortal_Purple_Skull01','','','','0','0','2.72','0','0','0','0','0','0','668','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('202302','0','9301','Frostmourne','','','','1375','32','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('202236','0','9294','Frostmourne Altar','','','','114','32','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('190236','0','7876','Gate','','','','114','32','0.88','0','0','0','0','0','0','0','0','3000','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('201385','0','9214','Ice Wall','','','','1375','1','2.5','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('500001','0','9214','Ice Wall','','','','1375','1','2.5','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','1'),
('201885','0','9214','Ice Wall','','','','0','1','2','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('202396','0','9214','Ice Wall','','','','114','33','2','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('197341','0','9124','Impenetrable Door','','','','1375','32','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('500003','14','8253','Orgrim\'s Hammer','','','','0','1','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','1'),
('202079','22','8111','Portal to Dalaran','','','','0','0','1','0','0','0','0','0','0','53141','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('201710','3','9280','The Captain\'s Chest','','','','1732','0','1','0','0','0','0','0','0','57','27985','0','1','0','0','0','0','0','0','0','1','0','0','0','1','0','0','0','0','0','0','0','0','','','12340'),
('202337','3','9281','The Captain\'s Chest','','','','1735','0','1','0','0','0','0','0','0','57','27993','0','1','0','0','0','0','0','0','0','1','0','0','0','1','0','0','0','0','0','0','0','0','','','12340'),
('202336','3','9280','The Captain\'s Chest','','','','1732','0','1','0','0','0','0','0','0','57','27993','0','1','0','0','0','0','0','0','0','1','0','0','0','1','0','0','0','0','0','0','0','0','','','12340'),
('202212','3','9281','The Captain\'s Chest','','','','1735','0','1','0','0','0','0','0','0','57','27985','0','1','0','0','0','0','0','0','0','1','0','0','0','1','0','0','0','0','0','0','0','0','','','11723'),
('500002','14','9150','The Skybreaker','','','','0','1','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','1'),
('201709','5','9288','Gunship Stairs','','','','0','1','2','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340'),
('202211','5','9289','Gunship Stairs','','','','0','1','2','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','','','12340');

-- Equip template Fix some startup errors.
UPDATE `creature_equip_template` SET `id`='2' WHERE `entry`='1976' AND `id`='2';
UPDATE `creature` SET `equipment_id`='2' WHERE `guid`='90438';
UPDATE `creature_equip_template` SET `id`='2' WHERE `entry`='424' AND `id`='2';
UPDATE `creature_equip_template` SET `id`='2' WHERE `entry`='25239' AND `id`='1';
UPDATE `creature` SET `equipment_id`='0' WHERE `guid`='202292';

DELETE FROM `creature_text` WHERE `entry` BETWEEN -1594540 AND -1594430;
INSERT INTO `creature_text` (`entry`,`content_default`,`content_loc8`,`sound`,`TYPE`,`LANGUAGE`,`emote`,`COMMENT`) VALUES
(-1594473, 'Insensata, buscas lo que asesine tiempo atras. Ahora no es mas que un fantasma, un eco lejano en mi mente.', '', 17229,1,0,0, '67234'),
(-1594474, 'No cometere el mismo error, Sylvanas. Esta vez no habra escapatoria. Fallaste al servirme como no muerta. Ahora lo que te queda es el olvido.', '', 17228,1,0,0, '67234'),

-- SCENE - Hall Of Reflection (Extro) - PreEscape
(-1594477, 'Han llegado tus aliados, Jaina, como prometiste. Todos sereis poderosos agentes de la Plaga.', '', 17212,1,0,0, '67234'),
(-1594478, 'No cometere el mismo error, Sylvanas. Esta vez no habra escapatoria. Me servireis en la muerte!', '', 17213,1,0,0, '67234'),
(-1594479, 'Es demasiado poderoso, debemos abandonar este lugar ahora mismo! Mi magia podra inmovilizarlo brevemente! Vamos rapido, heroes!', '', 16644,0,0,1, '67234'),
(-1594480, 'Es demasiado poderoso! Heroes, rapido, venid! Debemos abandonar este lugar ahora mismo! Hare lo que pueda para inmovilizarlo mientras huimos.', '', 17058,0,0,1, '67234'),

-- SCENE - Hall Of Reflection (Extro) - Escape
(-1594481, 'El frio abrazo de la muerte os aguarda!', '', 17221,1,0,0, '67234'),
(-1594482, 'Alzaos esbirros! Que no pasen!', '', 17216,1,0,0, '67234'),
(-1594483, 'Esbirros cojedlos. Traedme sus cadaveres!', '', 17222,1,0,0, '67234'),
(-1594484, 'Sin esperanza...', '!', 17214,1,0,0, '67234'),
(-1594485, 'Todo perdido!', '', 17215,1,0,0, '67234'),
(-1594486, 'No hay escapatoria!', '', 17217,1,0,0, '67234'),
(-1594487, 'Destruire esta barrera. Debeis mantener atras a los no muertos!', '', 16607,1,0,0, '67234'),
(-1594488, 'Ninguna pared detendre a la Reina Alma en Pena! Mantened a los no muertos a raya, heroes! Destruire esta barrera!', '', 17029,1,0,0, '67234'),
+(-1594489, 'Otro muro de hielo! Evitad que los no muertos interrumpan mis conjuros para que pueda derribar este muro!', '', 16608,1,0,0, '67234'),
(-1594490, 'Otra barrera? Sed fuertes, campeones! Derrumbare el muro!', '', 17030,1,0,0, '67234'),
(-1594491, 'Sucumbid al frio de la tumba.', '', 17218,1,0,0, '67234'),
(-1594492, 'Otro final sin salida.', '', 17219,1,0,0, '67234'),
(-1594493, 'Cuanto vais a aguantar?', '', 17220,1,0,0, '67234'),
(-1594494, 'Esta jugando con nosotros. Le enseÃ±are lo que le pasa al hielo cuando se junta con el fuego!', '', 16609,0,0,0, '67234'),
(-1594495, 'Tus muros no pueden detenernos, monstruo. Los destruire todos!', '', 16610,1,0,0, '67234'),
(-1594496, 'Me canso de estos juegos, Arthas! Tus muros no me detendran!', '', 17031,1,0,0, '67234'),
(-1594497, 'No impediras que escapemos, demonio. Acabad con los no muertos mientras derribo esta barrera!', '', 17032,1,0,0, '67234'),
(-1594498, 'Hay una salida ahi delante, vamos!', '', 16645,1,0,0, '67234'),
(-1594499, 'Casi estamos, no os rindais!', '', 16646,1,0,0, '67234'),
(-1594500, 'Hay una salida ahi delante, vamos!', '', 17059,1,0,0, '67234'),
(-1594501, 'Casi estamos, no os rindais!', '', 17060,1,0,0, '67234'),
(-1594502, 'No... No hay salida. No tenemos mas opcion que luchar. Armaos de valor heroes, pues esta sera nuestra ultima batalla!', '', 16647,1,0,0, '67234'),
(-1594503, 'Maldicion, no hay salida! Asi es como acaba. Preparaos heroes, hoy tendra lugar nuestra ultima batalla!', '', 17061,1,0,0, '67234'),
(-1594504, 'No corrais. Sois mios....', '', 17223,1,0,0, '67234'),
(-1594524,'Perdonadme heroes. Debi escuchar a Uther. Tenia que verlo por mi misma, poder mirarle a los ojos una ultima vez. Lo siento.', '','16648','0','0','0','67234'),
(-1594525,'Ahora sabemos que debemos hacer, les dare estas noticias al Rey Varian y al alto seÃ±or Vadin.','','16649','0','0','0','67234'),
(-1594522,'Fuego, fuego!','','16732','1','0','0','67234'),
(-1594523,'A bordo! Ya! La ladera de la montaÃ±a se derrumbara en cualquier momento!','','16733','1','0','0','67234'),
(-1594521,'Estamos a salvo por ahora. Su fuerza se ha multiplicado desde nuestra ultima batalla. Necesitamos un ejercito poderoso para destruir al Rey Exanime, mejor incluso que el que la Horda puede convocar.','','17062','0','0','0','67234'),
(-1594526,'Fuego, fuego!','','16721','1','0','0','67234'),
(-1594527,'Rapido! A bordo! No debemos entretenernos. La ladera de la montaÃ±a se derrumbara en cualquier momento!','','16722','1','0','0','67234'),
(-1594505, 'Soldados de Lordaeron, alzaos ante la llamada de vuestro maestro!', '', 16714,1,0,0, '67234'),
(-1594506, 'El maestro observo su reino, y lo encontro... incompleto. Su juicio fue rapido y despiado. Muerte a todos!', '', 16738,1,0,0, '67234'),

-- FrostWorn General
(-1594519, 'No sois dignos de enfrentaros al Rey Exanime!', '', 16921,1,0,0, '67234'),
(-1594520, 'Maestro, he fracasado...', '', 16922,1,0,0, '67234');

-- --------------
-- -Trashmobs ICC
-- --------------

UPDATE `creature_template` SET AIName = "" WHERE entry IN (36725, 36724, 37012, 37007, 36811, 36807, 36829, 36805, 36808, 37098, 37022, 37038, 37023, 10404, 36880, 37664, 37595, 37663, 37901, 37571, 37662, 37665, 37666, 38125, 37127, 37132, 37134, 37133); 
UPDATE `creature_template` SET `ScriptName` = 'npc_NerubarBroodkeeper' WHERE `entry` = 36725;
UPDATE `creature_template` SET `ScriptName` = 'npc_ServantoftheThrone' WHERE `entry` = 36724;
UPDATE `creature_template` SET `ScriptName` = 'npc_AncientSkeletalSoldier' WHERE `entry` = 37012;
UPDATE `creature_template` SET `ScriptName` = 'npc_DeathboundWard' WHERE `entry` = 37007;
UPDATE `creature_template` SET `ScriptName` = 'npc_DeathspeakerAttedant' WHERE `entry` = 36811;
UPDATE `creature_template` SET `ScriptName` = 'npc_DeathspeakerDisciple' WHERE `entry` = 36807;
UPDATE `creature_template` SET `ScriptName` = 'npc_DeathspeakerHighPriest' WHERE `entry` = 36829;
UPDATE `creature_template` SET `ScriptName` = 'npc_DeathspeakerServant' WHERE `entry` = 36805;
UPDATE `creature_template` SET `ScriptName` = 'npc_DeathspeakerZealot' WHERE `entry` = 36808;
UPDATE `creature_template` SET scriptname = "npc_valkyr_herald" WHERE entry = 37098;
UPDATE `creature_template` SET scriptname = "npc_blighted_abomination" WHERE entry = 37022;
UPDATE `creature_template` SET scriptname = "npc_vengeful_fleshreapert" WHERE entry = 37038;
UPDATE `creature_template` SET scriptname = "npc_plague_scientist" WHERE entry = 37023;
UPDATE `creature_template` SET scriptname = "npc_pustulating_horror" WHERE entry = 10404;
UPDATE `creature_template` SET scriptname = "npc_decaying_colossus" WHERE entry = 36880;
UPDATE `creature_template` SET scriptname = "npc_darkfallen_archmage" WHERE entry = 37664;
UPDATE `creature_template` SET scriptname = "npc_darkfallen_blood_knight" WHERE entry = 37595;
UPDATE `creature_template` SET scriptname = "npc_darkfallen_noble" WHERE entry = 37663;
UPDATE `creature_template` SET scriptname = "npc_vampiric_fiend" WHERE entry = 37901;
UPDATE `creature_template` SET scriptname = "npc_darkfallen_advisor" WHERE entry = 37571;
UPDATE `creature_template` SET scriptname = "npc_darkfallen_commander" WHERE entry = 37662;
UPDATE `creature_template` SET scriptname = "npc_darkfallen_lieutenant" WHERE entry = 37665;
UPDATE `creature_template` SET scriptname = "npc_darkfallen_tactician" WHERE entry = 37666;

-- Equip for darkfallen blood knight
DELETE FROM `creature_equip_template` WHERE entry = 37595;
INSERT INTO `creature_equip_template` VALUES (37595, 1, 51028, 0, 0);
UPDATE creature SET equipment_id = 37595 WHERE id = 37595;
-- Equip for darkfallen tactician
DELETE FROM `creature_equip_template` WHERE entry = 37666;
INSERT INTO `creature_equip_template` VALUES (37666, 1, 51029, 51029, 0);
UPDATE creature SET equipment_id = 37666 WHERE id = 37666;
-- Equip for darkfallen commander
DELETE FROM `creature_equip_template` WHERE entry = 37662;
INSERT INTO `creature_equip_template` VALUES (37662, 1, 51322, 0, 0);
UPDATE creature SET equipment_id = 37662 WHERE id = 37662;
-- Equip for darkfallen lieutenant
DELETE FROM `creature_equip_template` WHERE entry = 37665;
INSERT INTO `creature_equip_template` VALUES (37665, 1, 51323, 51324, 0);
UPDATE creature SET equipment_id = 37662 WHERE id = 37665;

-- Nerubar Broodkeeper position
UPDATE `creature` SET `position_z` = 35.24 WHERE `guid`=201170;
UPDATE `creature` SET `position_z` = 35.24 WHERE `guid`=201106;
UPDATE `creature` SET `position_z` = 44.57 WHERE `guid`=200949;
UPDATE `creature` SET `position_z` = 44.57 WHERE `guid`=200956;
UPDATE `creature` SET `position_z` = 42.1 WHERE `guid`=200912;
UPDATE `creature` SET `position_z` = 42.1 WHERE `guid`=200934;
UPDATE `creature` SET `position_z` = 37.98 WHERE `guid`=201127;
UPDATE `creature` SET `position_z` = 37.98 WHERE `guid`=200939;

-- Inmunity's trash-icc:
-- ancient skeletal soldier
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37012,38059);
-- deathbound ward
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37007,38031);
-- servant of the throne
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (36724,38057);
-- the damned
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37011,38061);
-- nerubar broodkeeper
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (36725,38058);
-- deathspeaker servant
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (36805,38075);
-- deathspeaker disciple
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (36807,38073);
-- deathspeaker zealot
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (36808,38076);
-- deathspeaker attendant
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (36811,38072);
-- deathspeaker high priest
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (36829,38074);
-- blighted abomination
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37022,38108);
-- vengeful fleshreapert
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37038,38063);
-- plague scientist
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37023,38062);
-- pustulating horror
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (10404,38110);
-- decaying colossus
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (36880,37655);
-- darkfallen archmage
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37664,38099);
-- darkfallen blood knight
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37595,38100);
-- darkfallen noble
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37663,38480);
-- vampiric fiend
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry`=37901;
-- darkfallen advisor
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37571,38098);
-- darkfallen commander
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37662,38102);
-- darkfallen lieutenant
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37665,38101);
-- darkfallen tactician
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37666,38479);
-- ymirjar deathbringer
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (38125,38130);
-- ymirjar frostbinder
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry` IN (37127,38126);
-- ymirjar battlemaiden
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry`=38132;
-- ymirjar huntress
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry`=38134;
-- ymirjar warlord
UPDATE `creature_template` SET `mechanic_immune_mask` = `mechanic_immune_mask`|1|4|8|16|128|512|1024|65536|131072|524288|1048576|4194304|8388608|33554432|67108864|134217728 WHERE `entry`=38133;

DELETE FROM `creature_text` WHERE `entry` = 38995 AND `groupid` = 4;
INSERT INTO `creature_text` (`entry`, `groupid`, `id`, `text`, `type`, `language`, `probability`, `emote`, `duration`, `sound`, `comment`) VALUES 
(38995, 4, 0, 'THE LICH KING...MUST...FALL!', 14, 0, 0, 0, 0, 17389, 'Highlord Tirion Fordring - SAY_TIRION_OUTRO_3');

UPDATE `creature_text` SET `sound` = 17352 WHERE `entry` = 36597 AND `groupid` = 3; -- Lich King's Agrro

-- Sindragosa Flight
UPDATE `creature_template` SET `InhabitType`=7 WHERE `entry`=36853;

-- Register spell-script for Sindragosa ability Permeating Chill / Durchdringende Kaelte 70107 in instance / Instanz ICC / Eiskronenzitadelle / Icecrown Citadel
DELETE FROM `spell_script_names` WHERE `spell_id` = 70107 AND `ScriptName` = 'spell_sindragosa_permeating_chill';

UPDATE `creature_template` SET `modelid1` = 25455, `modelid2` = 0, `unit_flags` = 33555202, `flags_extra` = 129, `ScriptName` = 'npc_sindragosas_ward' WHERE `entry` = 37503;
DELETE FROM `creature` WHERE `id` = 37503;
INSERT INTO `creature` (id, map, spawnMask, phaseMask, modelid, equipment_id, position_x, position_y, position_z, orientation, spawntimesecs, spawndist, currentwaypoint, curhealth, curmana, MovementType, npcflag, unit_flags, dynamicflags) VALUES
(37503, 631, 15, 1, 0, 0, 4181.54, 2551.65, 211.033, 4.72777, 604800, 0, 0, 27890000, 8516000, 0, 0, 0, 0);

UPDATE `gameobject` SET `state` = 0 WHERE `id` = 201373;

DELETE FROM `areatrigger_scripts` WHERE `entry` = 5623;
INSERT INTO `areatrigger_scripts` (entry, ScriptName) VALUES
(5623, 'at_icc_start_sindragosa_gauntlet');

UPDATE `creature_template` SET `minlevel` = 80, `maxlevel` = 80, `exp` = 2, `faction_A` = 21, `faction_H` = 21, `mechanic_immune_mask` = 8388624 WHERE `entry` IN (37228, 37229, 37232, 37501, 37502, 38197, 38198, 38362, 38134, 38137);
UPDATE `creature_template` SET `mindmg` = 422, `maxdmg` = 586, `attackpower` = 642, `dmg_multiplier` = 7.5, `minrangedmg` = 345, `maxrangedmg` = 509, `rangedattackpower` = 103 WHERE `entry` IN (37228, 37229);
UPDATE `creature_template` SET `mindmg` = 422, `maxdmg` = 586, `attackpower` = 642, `dmg_multiplier` = 13, `lootid` = 100002, `minrangedmg` = 345, `maxrangedmg` = 509, `rangedattackpower` = 103 WHERE `entry` IN (38134, 38137);
UPDATE `creature_template` SET `dmg_multiplier` = 2 WHERE `entry` = 38362;
UPDATE `creature_template` SET `difficulty_entry_1` = 38134 WHERE `entry` = 37228;
UPDATE `creature_template` SET `difficulty_entry_1` = 38137 WHERE `entry` = 37229;
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` IN (37228, 37229, 37501, 37502);

DELETE FROM `smart_scripts` WHERE `entryorguid` IN (37228, 37229, 37501, 37502) AND `source_type` = 0;
INSERT INTO `smart_scripts` (entryorguid, source_type, id, link, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, target_type, target_param1, target_param2, target_param3, target_x, target_y, target_z, target_o, comment) VALUES
-- Frostwarden Warrior: 37228 / 38134
(37228, 0, 0, 0, 0, 0, 100, 30, 5000, 15000, 10000, 25000, 11, 71323, 3, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Frostwarden Warrior - Cast Frostblade'),
(37228, 0, 1, 0, 6, 0, 100, 30, 0, 0, 0, 0, 11, 71203, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Frostwarden Warrior - Cast Soul Feast On Death'),
-- Frostwarden Sorceress: 37229 / 38137
(37229, 0, 0, 0, 0, 0, 100, 20, 15000, 20000, 20000, 25000, 11, 71331, 1, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Frostwarden Sorceress - Cast Ice Tomb (25 man only)'),
(37229, 0, 1, 0, 0, 0, 100, 30, 10000, 15000, 10000, 20000, 11, 71320, 3, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Frostwarden Sorceress - Cast Frost Nova'),
(37229, 0, 2, 0, 0, 0, 100, 30, 3000, 5000, 3000, 4000, 11, 71318, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Frostwarden Sorceress - Cast Frostbolt'),
(37229, 0, 3, 0, 6, 0, 100, 30, 0, 0, 0, 0, 11, 71203, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Frostwarden Sorceress - Cast Soul Feast On Death'),
-- Nerub'ar Champion: 37501 / 38197
(37501, 0, 0, 0, 0, 0, 100, 30, 3000, 5000, 10000, 15000, 11, 71801, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Nerub\'ar Champion - Cast Rush'),
(37501, 0, 1, 0, 6, 0, 100, 30, 0, 0, 0, 0, 11, 71203, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Nerub\'ar Champion - Cast Soul Feast On Death'),
-- Nerub'ar Webweaver: 37502 / 38198
(37502, 0, 0, 0, 0, 0, 100, 30, 3000, 5000, 10000, 15000, 11, 71326, 1, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Nerub\'ar Webweaver - Cast Crypt Scarabs'),
(37502, 0, 1, 0, 0, 0, 100, 30, 10000, 15000, 10000, 20000, 11, 71327, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Nerub\'ar Webweaver - Cast Web'),
(37502, 0, 2, 0, 6, 0, 100, 30, 0, 0, 0, 0, 11, 71203, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 'Nerub\'ar Webweaver - Cast Soul Feast On Death');

-- Close entrance door by default in encounter Sindragosa in instance / Instanz ICC / Eiskronenzitadelle / Icecrown Citadel
UPDATE `gameobject` SET `state` = 1 WHERE `id` = 201373; 

DELETE FROM `creature_template` WHERE `entry` IN (30230);
INSERT INTO `creature_template` (`entry`, `difficulty_entry_1`, `difficulty_entry_2`, `difficulty_entry_3`, `KillCredit1`, `KillCredit2`, `modelid1`, `modelid2`, `modelid3`, `modelid4`, `name`, `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`, `exp`, `faction_A`, `faction_H`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `rank`, `mindmg`, `maxdmg`, `dmgschool`, `attackpower`, `dmg_multiplier`, `baseattacktime`, `rangeattacktime`, `unit_class`, `unit_flags`, `unit_flags2`, `dynamicflags`, `family`, `trainer_type`, `trainer_spell`, `trainer_class`, `trainer_race`, `minrangedmg`, `maxrangedmg`, `rangedattackpower`, `type`, `type_flags`, `lootid`, `pickpocketloot`, `skinloot`, `resistance1`, `resistance2`, `resistance3`, `resistance4`, `resistance5`, `resistance6`, `spell1`, `spell2`, `spell3`, `spell4`, `spell5`, `spell6`, `spell7`, `spell8`, `PetSpellDataId`, `VehicleId`, `mingold`, `maxgold`, `AIName`, `MovementType`, `InhabitType`, `HoverHeight`, `Health_mod`, `Mana_mod`, `Armor_mod`, `RacialLeader`, `questItem1`, `questItem2`, `questItem3`, `questItem4`, `questItem5`, `questItem6`, `movementId`, `RegenHealth`, `mechanic_immune_mask`, `flags_extra`, `ScriptName`, `WDBVerified`) VALUES
(30230, 0, 0, 0, 0, 0, 24992, 24993, 24994, 24995, 'Risen Ally', '', '', 0, 1, 1, 0, 35, 35, 0, 0.8, 0.99206, 1, 0, 422, 586, 0, 642, 4.6, 2000, 0, 1, 0, 0, 0, 40, 0, 0, 0, 0, 345, 506, 80, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 62225, 47480, 47481, 47482, 47484, 51874, 0, 0, 0, 0, 0, 0, '', 0, 3, 1, 288.8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 8388624, 0, 'npc_risen_ally', 12340);

-- Fix boss scourgelord tyrannus
UPDATE creature_template SET InhabitType = InhabitType | 4 WHERE `entry` IN (36658);

UPDATE `creature_template` SET `ScriptName` = 'npc_vladof_the_butcher' WHERE `entry` =30022;

-- The Grand Melee
-- (13665,13745,13750,13756,13761,13767,13772,13777,13782,13787);

-- Remove Wrong Gossips :
DELETE FROM gossip_menu_option WHERE menu_id = 10458;

-- Set Scriptname, Dmg Multiplier for Valiants :
UPDATE creature_template SET ScriptName = 'npc_valiant' , dmg_multiplier = 2 , gossip_menu_id = 10464 WHERE entry IN (33285,33306,33382,33383,33384,33558,33559,33561,33562,33564);

-- Remove wrong ScriptName that was set by TC :
UPDATE creature_template SET ScriptName = '' , gossip_menu_id = 10457 WHERE entry IN (33738,33739,33740,33743,33744,33745,33746,33747,33748,33749);

-- Fix Shadowmeld.
DELETE FROM spell_script_names WHERE spell_id = 58984;
INSERT INTO spell_script_names VALUES (58984, 'spell_gen_shadowmeld');

-- Fix Sylvanas Music Box
DELETE FROM spell_script_names WHERE spell_id = 73331;
INSERT INTO spell_script_names VALUES ('73331', 'spell_item_sylvanas_music_box');

-- Fix Glyph of Succubus.
DELETE FROM `spell_script_names` WHERE `spell_id`=6358;
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(6358,'spell_warl_seduction');

-- Blessing of Sanctuary vs Vigilance
DELETE FROM `spell_dbc` WHERE `id` = 20912;
INSERT INTO `spell_dbc` (`Id`,`CastingTimeIndex`,`DurationIndex`,`RangeIndex`,`Effect1`,`EffectBasePoints1`,`EffectImplicitTargetA1`,`EffectApplyAuraName1`,`EffectMiscValue1`,`SpellFamilyName`,`Comment`) VALUES
(20912,1,21,1,6,-3,1,87,127,10,'Blessing of Sanctuary Helper');

UPDATE `spell_group` SET `spell_id` = 68066 WHERE `id` = 1091 and `spell_id` = 47930;
UPDATE `spell_group` SET `spell_id` = 20912 WHERE `id` = 1092 and `spell_id` = 20911;

-- spell_warl_shadow_bite
DELETE FROM spell_script_names WHERE spell_id IN (-54049,54049,54050,54051,54052,54053);
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES (-54049, 'spell_warl_shadow_bite');

-- spell_dk_raise_dead
DELETE FROM `spell_script_names` WHERE `spell_id` = -46584;
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-46584, "spell_dk_raise_dead");

-- Update InhabitType for Skadi and Grauf. (Very Hacky, It's under the "It Works" Category.)
UPDATE `creature_template` SET `InhabitType`=7 WHERE `entry`=26893;
UPDATE `creature_template` SET `InhabitType`=7 WHERE `entry`=26693;