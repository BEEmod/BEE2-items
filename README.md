[![Join the chat at https://gitter.im/BenVlodgi/BEE2.4](https://badges.gitter.im/BenVlodgi/BEE2.4.svg)]  (https://gitter.im/BenVlodgi/BEE2.4?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)  

This is a fork by Byzarru to host signage changes as suggested in #1093.
* Standard signage gets two new rows.
* BEESigns add 5 more rows of custom signage for BEE exclusive items.
* Connection signs add manually placable connection signage to supplement antlines or to avoid clutter.

# BEE2.4 Default Pack
 This pack for BEE2.4 contains the standard packages. Packages contain resources for BEE2.4 - items, styles, music, elevator videos, etc.

# Installation Instructions

* First, you should download the [standard BEE2.4 compiler from here](https://github.com/BEEmod/BEE2.4/releases)
* You will need to extract the zip file to anywhere on your computer. **_You should not launch the program yet!_**
* After that, you must go to the [releases page](https://github.com/BEEmod/BEE2-items/releases) to download the BEE2.4 Default Pack. **_The releases must match!_**
* Next, you must extract the contents of the zip file to your **BEE2.4 compiler folder**.
* Finally, in order to launch BEE2.4, you must go to the `bin` folder and select `BEE2.exe` and open it. Once opened, you must select the game you want BEE2.4 to modify.

## Development Version

**_These are instructions to install the Development Version of the BEE2.4 Default Pack. This version will receive updates and bug-fixes to the `dev` branch in real time, but may be unstable. It is recommended that you use the Release Version instead._**

* First, you need to install [GitHub Desktop from here](https://desktop.github.com/).
* After installation, you must clone this repository. **_It must be done on [GitHub Desktop](https://desktop.github.com/)!_**
* After cloning, you need to select the `dev` branch and _NOT_ the `master` branch.
* Next, click the `Sync` button.
* Now you must go to the BEE2.4 config folder and open `config.cfg`. **_You must use the latest release of the [BEE2.4 Compiler](https://github.com/BEEmod/BEE2.4/releases)!_**
* You must set the package directory to your cloned repository folder. (e.g. `C:\Users\User\Documents\GitHub\BEE2-items`)
* Now open your BEE2.4 application. If it works, your files will be equal to the files of the `dev` branch.

# Packages in BEE2.4 Default Pack

This is a list of packages in the BEE2.4 Default Pack as of Pre-release 23. The BEE2.4 Default Pack has 23 packages.
Packages can contain multiple items/styles, so do not worry. A package can also contain music, or elevator videos.

* Aperture Tag Items (`APERTURE_TAG_ITEMS`)
* Aperture Tag Voicelines (`APERTURE_TAG_VOICE`)
* Block items (`BEE2_BLOCKS`)
* BTS Style (`BEE2_BTS`)
* Catwalk (`BEE2_CATWALK`)
* Clean Style (`BEE2_CLEAN_STYLE`)
* Conveyor (`BEE2_CONVEYOR`)
* Cube Coloriser (`BEE2_CUBE_COLORISER`)
* Elevator Videos (`BEE2_ELEV_VIDEO`)
* Monitors and Cameras (`BEE2_MONITORS`)
* Music (`BEE2_MUSIC`)
* Old Aperture (`BEE2_OLD_AP`)
* Overgrown Style (`BEE2_OVERGROWN`)
* Portal 1 Music (`BEE2_P1_MUSIC`)
* Paint Fizzler (`BEE2_PAINT_FIZZLER`)
* Portal Spawners (`BEE2_PORTALS`)
* Portal 1 (`BEE2_PORTAL_1`)
* Rocket Turret (`BEE2_ROCKET_TURRET`)
* Signage (`BEE2_SIGNAGE`)
* Unstationary Scaffold (`BEE2_UNST_SCAFFOLD`)
* Vactubes (`BEE2_VACTUBES`)
* Extra Voice Lines (`BEE2_VOICE_LINE`)
* BEEMOD 1 (`BEEMOD_1`)
* High Energy Pellets (`BEE_PELLETS`)
* ForthReaper's Fizzlers (`FR_FIZZ`)
* HMW's Pack (`HMW_MOD`)
* Sendificator (`HMW_SENDIFICATOR`)
* Lautaro - Modified Pedestal Buttons (`LAUTARO_MODIFIED_PED_BTN`)
* Death Fizzler (`LP_DEATH_FIZZ`)
* Futbol (`PACK_BEE2_FUTBOL`)
* Conductive Plates (`PACK_WOM_CONDUCTOR`)
* Portal Stories: Mel Music (`PS_MEL_MUSIC`)
* Rexaura Items (`REX_ITEMS`)
* Rexaura Music (`REX_MUSIC`)
* Aperture Tag Music (`TAG_MUSIC`)
* TSpen - Checkpoints (`TSPEN_CHECKPOINT`)
* TSpen - Ditch (`TSPEN_DITCH`)
* TSpen - Large Faith Plate (`TSPEN_LARGE_FAITH`)
* TSpen - Logic (`TSPEN_LOGIC`)
* TSpen - Paint Cleaner (`TSPEN_PAINT_CLEANER`)
* TSpen - Retractable Button (`TSPEN_RET_BUTTON`)
* TSpen - Timers (`TSPEN_TIMERS`)
* Buttons (`VALVE_BUTTONS`)
* Test Chamber Parts (`VALVE_GEOMETRY`)
* Hazards (`VALVE_HAZARDS`)
* Discouragement Beams (`VALVE_LASERS`)
* Test Elements (`VALVE_TEST_ELEM`)


# Additional Information

* If you are editing on Hammer, anything that is placed in the folder `sdk_content\maps\instances\bee2` will be deleted if you export the BEE2.4 pallete without enabling the setting `Preserve Game Directories`. If you are editing any package, after you have finished, do not forget to save it inside the packages, by replacing the old files inside.
* BEE2.4 will crash if you are exporting while another folder or file is open that is important to the BEE2.4 compilation process.
* If you are having problems using BEE2.4, make sure to verify the game cache files of Portal 2 before using a new BEE2.4 Default Pack release. **The issue also could be from another BEE2.4 pack, not just the BEE2.4 Default Pack**
* It is recommended to have backups from the following Portal 2 folders: `sdk_content`, `portal2_dlc2`, and `bin`, just in case you need to restore your Portal 2 files.
* You can use the Development Version for other branches, but not at the same time.

If you need more in-depth explanation of items and styles, or development guides, you may view this on the [BEE2.4 Default Pack wiki](https://github.com/BEEmod/BEE2-items/wiki).
You can also look at the [BEE2.4 wiki](https://github.com/BEEmod/BEE2.4/wiki) for information on the program itself.
And if you have any questions, you can check the [FAQ](https://github.com/BEEmod/BEE2-items/wiki/FAQ) or ask them on [Gitter](https://gitter.im/BenVlodgi/BEE2.4).

You may post issues on either the [BEE2.4 repository](https://github.com/BEEmod/BEE2.4/issues) or the [BEE2.4 Default Pack repository](https://github.com/BEEmod/BEE2-items/issues).
For the [BEE2.4 repository](https://github.com/BEEmod/BEE2.4/issues), you should only post issues about the compiler itself.
For the [BEE2.4 Default Pack repository](https://github.com/BEEmod/BEE2-items/issues), you should only post issues about packages and items.
Remember, issues don't have to be bugs. They can be suggestions as well!

Happy map-making!
