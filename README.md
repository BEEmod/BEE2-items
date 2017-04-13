[![BEE2-items Releases](https://img.shields.io/github/downloads/BEEmod/BEE2-items/total.svg?label=Packages)](https://github.com/BEEmod/BEE2-items/releases)
[![BEE2.4 Releases](https://img.shields.io/github/downloads/BEEmod/BEE2.4/total.svg?label=App)](https://github.com/BEEmod/BEE2.4/releases)
[![Join the chat at https://gitter.im/BEEmod/BEE2-items](https://badges.gitter.im/BEEmod/BEE2-items.svg)](https://gitter.im/BEEmod/BEE2-items?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Join the Discord [here](https://discord.gg/mZ4peDd) and chat with us!


![BEE2 Icon](https://raw.githubusercontent.com/BEEmod/BEE2.4/master/bee2.ico)
# BEE2.4 Default Pack
 This pack for BEE2.4 contains the standard packages. Packages contain resources for BEE2.4 - items, styles, music, elevator videos, etc.

## Installation Instructions

### Release Version

* First, you should download the [standard BEE2.4 compiler from here](https://github.com/BEEmod/BEE2.4/releases)
* You will need to extract the zip file to anywhere on your computer. **You should not launch the program yet!**
* After that, you must go to the [releases page](https://github.com/BEEmod/BEE2-items/releases) to download the BEE2.4 Default Pack. **Make sure the releases match** - non-matching releases don't go well together.
* Next, you must extract the contents of the zip file to your **BEE2.4 compiler folder**.
* Finally, in order to launch BEE2.4, you must go to the `bin` folder and select `BEE2.exe` and open it. Once opened, you must select the game you want BEE2.4 to modify.

### Development Version

These are instructions to install the Development Version of the BEE2.4 Default Pack. This version will receive updates and bug-fixes to the selected branch in real time, but may be unstable. It is recommended that you use the Release Version instead.

* First, you need to install [GitHub Desktop from here](https://desktop.github.com/).
* After installation, you must clone this repository. **It must be done on [GitHub Desktop](https://desktop.github.com/)!**
* After cloning, you need to select a branch other than the `master` branch. Features which will be in the next release are on the `dev` branch
* Next, click the `Sync` button.
* Now you must go to the BEE2.4 config folder and open `config.cfg`. **Make sure you have the latest version.**
* You must set the package directory to your cloned repository folder. (e.g. `C:\Users\User\Documents\GitHub\BEE2-items`)
* Now open your BEE2.4 application. If it works, your files will be equal to the files of the `dev` branch.

Some items require a compiler change and will not work with the Release Version compiler. You will need the development version of the program for these items to work - see the [BEE2.4 readme](https://github.com/BEEmod/BEE2.4/blob/master/README.md) for instructions to install that.

## Packages in BEE2.4 Default Pack

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


## Additional Information

- **If you constantly recieve the message "Build Error: There was an error building the puzzle", even when there are no items in the map, make sure to post a console log to the issue you open.** To do this, enable the developer console (Settings>Controls>Allow Developer Console) and open it (\` by default). Copy the big block of red text.
- If you are editing on Hammer, anything that is placed in the folder `sdk_content\maps\instances\bee2` will be deleted if you export the BEE2.4 pallete without enabling the setting *Preserve Game Directories*. If you are editing any package, after you have finished, do not forget to save it inside the packages, by replacing the old files inside.
- BEE2.4 will crash if you are exporting while another folder or file is open that is important to the BEE2.4 compilation process.
- If you are having problems using BEE2.4, make sure to verify the game cache files of Portal 2 before using a new BEE2.4 Default Pack release. **The issue also could be from another BEE2.4 pack, not just the BEE2.4 Default Pack**
- It is recommended to have backups from the following Portal 2 folders: `sdk_content`, `portal2_dlc2`, and `bin`, just in case you need to restore your Portal 2 files.

If you need more in-depth explanation of items and styles, or development guides, you may view this on the [BEE2.4 Default Pack wiki](https://github.com/BEEmod/BEE2-items/wiki).
You can also look at the [BEE2.4 wiki](https://github.com/BEEmod/BEE2.4/wiki) for information on the program itself.
And if you have any questions, you can check the [FAQ](https://github.com/BEEmod/BEE2-items/wiki/FAQ) or ask them on [Gitter](https://gitter.im/BEEmod/BEE2-items).

You may post issues on either the [BEE2.4 repository](https://github.com/BEEmod/BEE2.4/issues) or the [BEE2.4 Default Pack repository](https://github.com/BEEmod/BEE2-items/issues).
For the [BEE2.4 repository](https://github.com/BEEmod/BEE2.4/issues), you should only post issues about the compiler itself.
For the [BEE2.4 Default Pack repository](https://github.com/BEEmod/BEE2-items/issues), you should only post issues about packages and items.
Remember, issues don't have to be bugs. They can be suggestions as well!

Happy map-making!
