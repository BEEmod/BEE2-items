# Changelog

# Version `<dev>`

### Enhancements:
* #647: Re-add Overgrown Separated Coop Checkpoint.

### Bugfixes
* #1875: Fix orientation of Clean door camera.
* Fix Overgrown static non-block Stairs having incorrect panel positions.
* #4150: Fix Paint Fizzlers not cleaning cubes that were prepainted with gel.
* Fix #3671: Incorrect palette icon for Overgrown Signage item.
* Fix P1 not restarting when you enter the elevator in preview mode.
* Fix incorrect name and description for Absolute Fizzler package.
* Fix duplicate description for Overgrown Gels.
* Fix some bad optimisation in Overgrown SP entry elevator.
* Fix Overgrown "staircase" entrance not opening worldportal in preview mode.
* Fix #4247: Prevent portal bumping onto P1 ceiling Small Observation Room.
* Fix internal dimensions for Clean Large Observation Room.

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
