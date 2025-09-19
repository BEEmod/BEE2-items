# Changelog

# Version (dev)

* New Save Point item features:
	* Inputs can trigger the save point, instead of player presence.
	* A timer can be used to activate 'dangerous' autosaves, which require the player to live for a specified time before being used.
	* Auto-respawn allows triggering it multiple times.
* #4577: Dynamically generate cube dropper clips, making direct button drops much more reliable.
* Fix missing antline checkmark material.
* Fix incorrect NOT gate texture.
* #4556: Fix sendificator 'fail' antlines not triggering.
* #4559: Fix portals not being placable on retracted stairs.
* #4597: Fix missing editor model for Overgrown Reflection Gel Dropper
* Fix leaks on protruding pedestal buttons.
* Added a floor exit corridor to Portal 1 style.
* Portal 1 exit corridors with metal walls no longer have small portalable areas near the elevator.
* Fix incorrect filename for single-sign catapult signage.
* Removed alternate angle-change sounds in the editor for P1 style, since these constantly break.

------------------------------------------

# Version 4.46.1
* Re-added missing "Test Elements" package.

------------------------------------------

# Version 4.46.0

## New Items
* Added strip forms of Input A/B, SR Latches and Delayers.
* Added standalone checkmarks, as timer values 11-18 of Antline Corners.

## Enhancements
* The Half Grate has been replaced by an item which offers several shapes of glass/grating, which will merge into the standard glass/grating.
* Added an explicit error if a Neurotoxin Timer is present in the map without
  any Vents also present.
* Optimise track platforms with longer rail models, depending on the length.
* #4383: Added "Precise Cube Dropper" option, which delays cube release to prevent it tumbling from the dropper doors.
* Added option to prevent cubes from colliding with their own fizzling ghost.
* Several "style properties" have been moved to other tabs: 
	* "Unlock Default Items" and "Restart On Exit": moved to "mandatory items" tab
	* "Use P1 Portal Gun" and "Use P1 Fizzler FX": moved to new "Portal 1" tab
* Added numbers to the ingame signage legend.
* Added option to have barriers (glass, grating, fizzlers) extend down to the surface of goo.
* Added option to disable automatic exit door signage.
* It is now possible to select Portal 1's Chell as a player model.
* Portal 1 style will now extend white walls into the top of goo to better match the actual levels.
* The portal magnets automatically created by lasers/funnels/bridges can now be disabled.
* Add colourised version of Rosemary's Old Ap Reflection Cube.
* Added option to enable the 'cube flipper' device on Sendificators, to more easily point reflection cubes upwards. This isn't present on the slim version due to size reasons.
* VScript code is now able to perform collision checks against chamber geometry calculated by BEE, which enables more robust items.
* Rebuilt Rexaura Cube Deflector to be more reliable:
	* Redirected pellets will continue down the direct center of the voxel.
	* Fix #1599: Cubes will slightly resist being removed.
	* Fix #2206: Deflectors can now be placed on walls and ceilings.
	* Visual effects have been remade using particle systems.
* All block items and several logic gates have been remade with a new editor design courtesy of Konclan.
* All logic gates have a unified design now, with additional iconography/text.
* Added an option to prevent players from grabbing cubes through grating in coop. This functionality is no longer present directly in Half Grates.
* Added two additional modes to Surface Lacquer to allow disabling surface or voxel application, as well as connection support to apply to a larger area.
* Antlasers can now be used in the special connection between Sendificators and their laser, producing a unique variant.

## Bugfixes:
* #2475: Fix cubes being duplicated if they get fizzled while they are leaving the dropper.
* #4300 Added option to make monitors unbreakable.
* #4382: Re-enable antline transferal to block items.
* #4441: Fix incorrect positioning of observation grates
* #4442: Fix missing `exit_deadly_coop` instance for "Glados Human Vault" voiceline set.
* #4446: Fix piston movement sounds never stopping.
* #4448: Futbols will now respawn if falling into goo.
* #4449: Fix Monitors not showing GLaDOS/Wheatley in them correctly.
* #4466: Fix conveyors not starting in Old Ap, make it more difficult to misalign them.
* #4473: Fix Sendificator not teleporting through glass in P1 and Overgrown.
  Also ensure it can teleport through the small Window item.
* #4476: Fix turrets ignoring players if aiming at a target behind glass.
* #4538: Fix incorrect model filename for flamethrower 'crusher'.
* Fix 1-long Clean Track Platform not working.
* Fix barriers not being cut by the resizable Black/White Wall item.
* Fix Clean downward exit not trigging "map won" logic.
* Fix collisions on static Angled Panels.
* Fix leak in 1980s Coop spawn room.
* Fix missing texture for Tinted Glass editor model.
* Fix P1 ceiling Obs Room (light hole) and Large Obs Room not actually producing light.
* Fixed Old Aperture non-oscillating Unstationary Scaffolds.
* Make P1 Track Platform 'bottom grate' match the shape of the platform.
* Unstationary Scaffolds will now wake laser cubes when starting to move.

------------------------------------------

# Version 4.45.0

## New Features:
* New Item: Tinted Glass, a blue-coloured version of glass which blocks absolutely everything, including lasers.
* Added 2 new Barrier Hole variants: the Medium Hole can fit cubes, and the Slot Hole fits a light bridge through. The package has been renamed from "glass_hole", make sure to remove that file.
* Glass/Grating now has a Start Reversed option, which shifts them to the inner pair of tiles.
* Added a few new Clean entry corridor variants, based on the Overgrown layouts.

## Enhancements:
* #4308: Enlarge P1/1950s Small Glass Hole slightly to allow pellets through.
* Add editor model for Absolute Fizzlers.
* Laser Emitters now always use a static light, instead of it being togglable. This had the potential to quickly hit VRAD limits and generally fail to function.
* Added ability to specify travel direction and stair direction for Clean SP elevators.
* The light "temperature" can now be customised for Clean SP corridors.
* #2811: Added "Auto Drop" to Track Platforms, giving them the player detection trigger like Piston Platforms.

### Bugfixes:
* Fix neurotoxin timer not compiling in P1 style.
* Fix weird geometry in clean fizzler editor models.
* Fix laser emitters not starting disabled properly.
* #1571: Tweak coop exit stair position, add endcap model.
* #4406: Fix centered Overgrown laser catcher not triggering outputs.
* #4403: Fix missing palette icon for voxel logic gates.
* Fix an issue where Clean and Overgrown cube droppers could be tricked into dropping two cubes, if a spawning cube is pushed against the iris.
* #3289: Redo custom fizzler textures to fix bad tinting.
* #2966: Sendificators will fizzle cubes if transported past the exit door fizzler, as well as other "out of bounds" locations.
* #1609: Sendificators are now blocked by Closed Solid Fields.
* #4415: Add additional clips underneath stair items to fix issues with items falling inside.
* #4417: Fix it being possible to portal on extended Old Aperture stairs.
* #2779: Add proper hold-logic and clips to P1 vertical Exit Door.
* #4290, #3242, #4393: Remake restart-on-exit logic to be more consistent across styles.
* Fix "advanced" P1 Indicator Timer Panels not functioning.
* Fix extraneous world brush being placed when Standing Fizzlers are used.
* Fix incorrect beveling on non-block Overgrown Stairs.
* Fix Overgrown/Clean Track Platforms moving when built to be 1 block long.

------------------------------------------

# Version 4.44.0

### New Features:
* Added the Destruction Target, a bullseye that turrets shoot to fire outputs.
* New custom models for Old Aperture Laser items, made by [Rosemary Webs](https://www.youtube.com/@ErinRoseWebs).
* Laser Catchers and Emitters can now use the alternate model which is closer to the floor.

### Enhancements:
* Added tint mask for ARES 228's Old Aperture ball, when being coloured.
* Added a new Clean coop corridor, which shoots the bots up out of the floor.
* #4315 & #1100: Piston and Track Platforms can now have their speed customised.
* Large and Small Faith Plate items have now been merged together. This means the "faith_variants" package has been removed entirely, make sure to remove that file.
* Add compiler error if unused cube types on piston/track platforms.
* #3917: New editor models for P1 entry/exit doors.
* Tweak Coop Spawn Room editor model to indicate orientation when vertical.
* Several editor models have been remade: Pellet Destroyers, Logic gates, Triggers, Catwalks, Coop Checkpoints, P1 Entry/Exit Doors and P1 Fizzlers.
* Pellets may now be configured to no longer hurt players.

### Bugfixes:
* Improve entry door logic to prevent being able to portal past the door-close trigger.
* #4288: Change origin of `static_phys.mdl` to fix leaks if angled panels are facing a wall at a corner.
* #3878: Fix missing frames in 70s/80s Half Glass Door.
* Use a model for the sides/back of P1 Piston Platforms, to fix collision (especially with portals) and allow them to be lit dynamically.
* Disallow Scaffold Slot items from being used as a midpoint.
* Set a minimum light value on flip panels, to partially mitigate #4022.
* Antline toggle, checkmark and timer items are now defined as proper items instead of directly in the style. This ensures they can be inherited as normal.
* #4312: Fix blank Glass/Grating item descriptions.
* Fix compile failure if 80s lobby entry is used with crushers.
* Remove duplicate sign in Clean SP downward exit, if the regular sign is present.
* Add clips to panels in Clean SP upward exit.
* When spawning in Clean corridors, make the test chamber sign start illuminated.
* Increase brightness of light strips in Clean corridors.
* The Overgrowth music track now functions properly.
* #4352: Fix Clean Coop Entry not cutting tiles when on the floor/ceiling.
* #4336, #3941: Fix some catwalk placement issues.
* Fix seams in Clean custom fizzler model, improve collisions.
* Fix Piston/Track Platforms always using 4x4 tile patterns.
* #4378: Fix 1970s SP exit door sign not working when vertical.
* #4379: Fix leak with P1 Adjustable Pedestal Buttons.
* #4076: Added safeguard in case Sendificator sends cubes out of bounds - they will be fizzled.
* #3574: Fix leaks when using Old Aperture drawbridge with inputs.
* #4392: Fix incorrect nodrawing of tiles underneath Clean/P1/Overgrown BEE1 doors.

------------------------------------------

# Version 4.43.0

### Enhancements:
* #647: Re-add all styled versions of Separated Coop Checkpoint.
* Removed subtle fade when swapping Funnel polarity. It didn't match with any of the actual effects.
* Improve areaportals in Clean upward SP exit.
* Altered exit doors and checkpoints to use `NeedsAbsFizz` chamber attribute, instead of 
  `PortalGunOnOff`. This way items can get the Absolute Fizzlers in the exit without the portal gun
  changes.
 * Added a filter to all cube-fizzling fizzlers (except Absolute Fizzlers), allowing creating 
   fizzler-proof cubes and the like. Simply add the `nofizzle:1` response context to the object.

### Bugfixes:
* Fix #1875: orientation of Clean door camera.
* Fix Overgrown static non-block Stairs having incorrect panel positions.
* Fix #4150: Paint Fizzlers not cleaning cubes that were prepainted with gel.
* Fix #3671: Incorrect palette icon for Overgrown Signage item.
* Fix P1 not restarting when you enter the elevator in preview mode.
* Fix incorrect name and description for Absolute Fizzler package.
* Fix duplicate description for Overgrown Gels.
* Fix some bad optimisation in Overgrown SP entry elevator.
* Fix Overgrown "staircase" entrance not opening worldportal in preview mode.
* Fix #4247: Prevent portal bumping onto P1 ceiling Small Observation Room.
* Fix internal dimensions for Clean Large Observation Room.
* Fix #4263: 50s SP entrances having a few compile errors.
* Fix #4264: 70s SP entrances having a few compile errors.
* Fix 80s SP Lobby entrance not working.
* Fix Overgrown Excursion Funnels and reversed funnels not being visible in published maps.
* Fix positioning of P1 Coop corridors.
* Fix #4266: Sendificator Slim not working in Clean, Overgrown, P1.
* Fix #3960: Remake P1 Sendificator antlines to remove green tint.
* Fix #4269: Old Aperture checkpoints not functioning.
* Fix P1 Entrance 2 causing leaks.
* Fix name and icon for Old Aperture Coop Spawn Room.
* Fix fizzlers in 60s SP lobby Exits.
* Fix #4110: Recompile signage frame props, remove duplicates.

------------------------------------------

# Version 4.42.0

### New Features:
* New corridor selection system
	* Each corridor can now be individually enabled/disabled, you can have any number active.
	* UCPs can easily add new corridors to the mix
	* Corridor designs can be added for the floor/ceiling.
	* As a side effect, all corridors have been tidied up a little, and have better lighting.
* Old Aperture Edgeless Safety Cubes now have a custom model, made by ARES Agent 228.
* Old Aperture Cube and Ball Buttons now have a custom model, made by Erin Rose.
* Add new broken/dirty Overgrown Funnel, made by Erin-Rose.

### Enhancements
* #2387: Add colourised Bomb Cube model.
* #3017: Small Glass Holes no longer have clips, allowing things like pellets to pass through.
* #3102: Overgrown static Stairs now use piston arms, like in Portal 1.
* #3853: Old Aperture Stairs now have a unique non-block static variant.
* Dropperless cubes now use the "6 position" handle, allowing them to be positioned offset in a voxel. By switching to and from the reflection cube, you can both offset and rotate them.
* Fix #1944: Add Old Aperture editor models for CSFI and Physlers.
* HMW's logic gates now have editor models for all variants, and have a table displaying them in the description.
* Implement #4002: use Wii2's technique for reversible funnel models.
* Improve lighting in Old Aperture Coop Checkpoints, optimise logic.
* Old Aperture "locking" pedestal buttons will no longer make timer sounds.
* Port the original Portal 1 Portalgun Pedestal particle effects.
* Sendificators also lock attached pedestal buttons, making their timer delay sync with the animation.
* The Antline Corner item description has a diagram showing valid placements.
* When Sendificating Frankenturrets, they are popped out of box form at the destination.

### Bugfixes
* #803: Remove modern conveyor belts props from Old Aperture Conveyors.
* #2112: Fix clean FR fizzler models used for laserfield mode in Old Aperture.
* #2454: Fix unstyled Overgrown static Closed Solid Field.
* #3177: Fix rotation of Reflection Gel splatter editor model.
* #3255: Make 80s Coop Checkpoint switch checkmark/timer sign properly.
* #3375: Thin down P1 Camera cables to match originals.
* #3584: Make Cube Droppers "lock" pedestal button inputs, so it does not play timer sounds and has an appropriate delay.
* #3645: Fix invisible Overgrown / 80s Cube Button.
* #3937: Fix bad lighting behind Clean angled panels.
* #3962: Fix missing outputs on P1 Retractable Floor Buttons.
* #3977: Make Old Aperture Conveyors function properly.
* #3996: Fix outdated description of P1 light strips.
* #3999: Fix Incorrect orientation of Overgrown fizzler emitters.
* #4006: Fix missing editor model for 50s Funnel.
* #4007: Fix 70s Funnels can have a missing top model.
* #4027: Fix missing Repulsion Gel music samples for Robot Waiting Room
* #4052: Fix 80s Chamberlock is bricked up.
* #4083: Fix `r_portal_fastpath` is now disabled in BEE maps, fixing issues with rendering many portals onscreen at once.
* #4085: Fix remove broken shatter logic from Old Aperture monitors.
* #4107: Fix Absolute Fizzler having a missing editor model.
* #4122: Fix bad smoothing groups with PGun buttons.
* #4164: Add missing 70s/80s window instances.
* BEEmod/BEE2.4#1776: Fix funnel lighting not functioning correctly.
* BEEmod/BEE2.4#1854: Add delay to inverted logic items to prevent crashes.
* Fix Old Aperture Sendificator Slim having broken antlines.
* Fix P1 entrances not detecting people portalling out.
* Fixed position of Old Aperture Flip Panel wheel.
* Fixed check locations for Old Aperture entry/exit door speaker placements.

------------------------------------------

## Version 4.41.0
* The music packages have been split into a separate download, since they make up a large amount of the download size.
* The BTS style has been removed, due to it being rather substandard and not really possible to function in the puzzlemaker.
* New Item: Antline Corner item, which allows for manually placing antlines anywhere. Place two down with a straight line between them, then link with antlines. A contiguous section is treated as one item, which acts like an OR gate.
* New Item: Half Obs Room, a half-voxel wide Observation Room. The P1 room has switched to be a full voxel like other styles.
* P1 style light strips now are a rectangular lamp like other styles, with the square hole split into a new item.
* Add brand new versions of Old Aperture SP spheres, and 50s+60s entry corridors all by @Critfish.
* Old Aperture and P1 Gel Droppers now have new custom models.
* P1 and Old Aperture exit signs will now reposition themselves like other styles.
* Vactubes now have P1 and Old Aperture styles.
* Remake some P1 entry corridors.
* Add new option for making fizzlers force black tiles on adjacent tiles to discourage portal bumping. 
* Selector windows now save/load their position and group expand/contract state.
* The pipes in Enrichment Spheres now can appear in several random positions.

------------------------------------------

## Version 4.40.0
* New Item: Antlaser, a nonsolid laser which can be used to connect antlines through the air. The model was created by Konclan.
* Add some Old Aperture/BTS editor textures, made by @saismee/@seagemgames
* Old Aperture droppers will now have different signage (made by Critfish) on the base to indicate the cube type that will be dispensed.
* The P1 exit sign will now correctly appear on different sides as required.
* Added an itemvar for disabling lasers bending to hit catchers.
* Rexaura Flux Fields will now detect Rocket Turret rockets.

* Fix a variety of items having their instances being broken in several ways.
* Fix lots of items colliding when they shouldn't.
* Fix autoportals/portalguns not working.
* Fixed Sendificators not being connectable.
* The P1 SP exit corridor 4's observation room will only use a worldportal now if it needs to.
* Fixed some issues with P1 piston platforms.

------------------------------------------

## Version 4.39.1
* Fixes missing resources for Surface Lacquer
* Fix item inputs and collisions being broken
* Convert Standing/Reclined Fizzlers to have 1 palette icon, also fixing configuration
* Convert Vactubes to have 1 palette icon also

------------------------------------------

## Version 4.39.0
* New item: "Surface Lacquer"
    * Coats surfaces and blocks, preventing them from being paintable, though they can still be portalled as normal.
    * It affects the surface it's applied directly on, plus any block/panel items inside the voxel.
*  Use new RotateInst result in Protruding Pedestal Buttons to avoid having extra instances.
* Improve brushes generated by Glass Hole.

------------------------------------------

## Version 4.38.0
* Update Fizzler Output Relay  description (via @micheledicosomo)
* Add BTS Antline Resources
* Fix some bugs with Protruding Pedestal Buttons
* Fix alignment of Clean/80s Indicator Panels, Cool Light Strip
* Add modelled form of 50s Crusher
* Fix leaks in Old Aperture Sendificator
* Use dirty buttons in 80s style
* Fix Bomb Cubes not functioning in the Sendificator
* Fix Clean dropper being jammable, getting items stuck
* Add on/off option to Lifeform Sensors
* Remove the random radios on tables from P1 corridors (@Luke18033)
* Add option to use Portal 1's fizzling effect
* Improvements to P1 Checkpoints
* Fix 60s Cave not functioning (@GiovanH)
* Fix BTS obs rooms not being placable on floor/ceilings
* Rebuild ditch item to work properly in all styles
* Fix 70s Floor button and stairs not working
* Fix Old Aperture Monitor not showing up
* Convert P1 Small Observation Room to take up the full voxel
* Fix P1 Gel Droppers not accepting inputs
* Fix the orientation of faces on Angled Blocks and Panels
* Fix nodraw underneath P1 Doors
* Fix Monitors moving their covers the incorrect direction
* Remake a bunch of the bullsye materials.
* Port P1's original color correction filter

------------------------------------------

## Version 4.37.0
Bottomless Pits and Cutout Tiles are currently disabled in this version, and do nothing. These will be reimplemented later.
This is a fairly massive update, bringing a large internal change. The floor/wall/ceiling tiles are now entirely generated by the BEE2 compiler. This brings the following upgrades:

* Each 1/4 tile can now be set to white/black individually by using Half Wall items, or the new Quarter Tile. Items like panels placed on top will use the tile pattern.
* The texturing algorithm has been greatly improved, so all styles will now have better appearances.
* Tiles will now reshape around items that cover up bits of walls, producing appropriate panel sizes.
* Standing/Reclined Fizzlers can now be connected to a normal fizzler item to make it use that type (with the original removed in the process).
* Clean and Portal 1 Cube Droppers will extend themselves upwards if additional room is present, to improve their aesthetics.
* HMW's placement helper item will now override automatically placed helpers on surfaces, and attach itself properly to angled panels.
* Fizzlers now appear embedded into the wall properly, instead of black surface covering the hole.

Additionally:
* Old Aperture's Angled/Glass Panels, Faith Plates and Stairs have been rebuilt with new models.
* Fizzlers which don't block portal shots (Physics Repulsion Field, Force Deflection Field) now use the full on/off transition animation.
* New models for Old Aperture and Portal 1 Gel Droppers from @Konclan, plus Old Aperture Futbols.
* Fix far too many bugs to list!

------------------------------------------

## Version 4.36.0
- Add "Disable Laser Collision" checkbox.
- Add "no-recycle" signage.
- Fix #3079: Add "15 Acres of Broken Glass" music
- Add many new signage textures by @Wii2.
- Add 4x4 P1 wall texture by @Konclan and new editor textures by @Luke18033.
- Add an additional glow to fizzler models to help distinguish them from each other.

- Fix a bunch of broken/missing signages.
- Fix #610: "Special Marker" editor model was sideways.
- Fix #3043: 1970s Indicator Panels not working.
- Fix Blue Portalgun On/Off buttons being non-functional.
- Fix Timed Pellet Emitters and Force Deflection Fields not being able to Start Disabled correctly.

------------------------------------------

## Version 4.35.0
* Rebuild Signage - allowing users to customise what icons are available.
    * Double the number of signs available.

* Add new Covered Panel and Retractable Button palette icons, via @HugoBDesigner.
* Fix Portal Magnet editor model orientations.
* Rebuild Pellet Destroyer / Positron Orb, fixing appearance.
* Fix Cube Painters not working in Clean.
* Fix missing wake-trigger on Clean Faith Plate.
* Fix broken Sendificator and Slim Sendificators in various styles.
* Relax collision rules for Angled Panels to be the same as Glass Panels.
* Fix Death Fizzlers not working in Portal 1 style.
* Fix for antline routers gridding the wall behind it.
* Fix #2967: NOT gates without inputs crashing.

------------------------------------------

# Version 4.34.0
* Remove duplicate Antline Router Strip item.
* Make I'm Different turret defeat music work properly.
* Portalgun On/Off player-only buttons now are an actual button, making them work better in some situations.
* If Portalgun On/Off buttons are present, switch exits to use Absolute Fizzlers.
* Add "Refresh Time" config for HEP emitters.
* Add "Block Stair" config, allowing static stairs to be either panels or blocks.
* Tweak heights of P1 Stair platforms.
* #2397: Delay turning off of Reflection Cube targeting laser.

* Fix #2880: Coop Exit Doors not working.
* Fix #2897: Visible Nodraw on Retractable Floor Buttons.
* Fix #2425: Cube Deflector not working in Clean.
* Fix #2907: Old Aperture Catwalks not compiling.
* Fix BEEmod/BEE2.4#1073: PeTI/Robot Room music not working properly.
