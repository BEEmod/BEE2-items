[![BEE2-items Releases](https://img.shields.io/github/downloads/BEEmod/BEE2-items/total.svg?label=Packages)](https://github.com/BEEmod/BEE2-items/releases)
[![BEE2.4 Releases](https://img.shields.io/github/downloads/BEEmod/BEE2.4/total.svg?label=App)](https://github.com/BEEmod/BEE2.4/releases)
[![Discord Server](https://img.shields.io/discord/293435914598744064?color=%235865F2&label=Discord)](https://discord.gg/hnGFJrz)

### Please read the [Contributing Guidelines](https://github.com/BEEmod/.github/blob/master/contributing.md) and [FAQ](https://github.com/BEEmod/BEE2-items/wiki/FAQ) before opening an issue.

![BEE2 Icon](https://raw.githubusercontent.com/BEEmod/BEE2.4/master/BEE2.ico)
# BEE2.4 Default Pack
This is the default set of packages for the [BEE2.4](https://github.com/BEEmod/BEE2.4). Packages contain resources for BEE2.4, such as items or styles.

## Download and Use

1. Download the BEE2.4 app and compiler from [here](https://github.com/BEEmod/BEE2.4/releases). Download the 64-bit version, unless you are on Windows 7 or you have a 32-bit PC; in these cases download the 32-bit version instead.
2. Download the default pack from [here](https://github.com/BEEmod/BEE2-items/releases). Make sure to get the same version as the application, otherwise you may encounter errors.
3. Extract the application zip to anywhere on your computer.
4. Extract the contents of the default pack zip to the application folder you just extracted.
5. To launch BEE2.4, go to the extracted folder and open `BEE2.exe`.
6. Once opened, select the game you want BEE2.4 to modify.

You can add another game using `File > Add Game`. Any Source game can be added, but BEE2.4 will only work with Portal 2 and Aperture Tag. Thinking With Time Machine support is planned, but has not yet been implemented.
To remove a game, use `File > Uninstall from Selected Game`. As well as unmounting it from BEE2.4, this will also remove all BEE2.4-related resources from the game and reset the Puzzlemaker to the default items and style for that game.

### Development builds

These are instructions to install the development version of the default pack. This will allow you to access features directly from GitHub branches such as `dev`, instead of having to wait for a release to be made. However, this version may be unstable. Therefore, it is recommended that you use the release version unless you are developing custom content.

For some things to work correctly, you may need to use this with the development version of the application/compiler. Instructions for how to install this can be found [here](https://github.com/BEEmod/BEE2.4#build-from-source-advanced-for-adding-to-bee24-program-windows).

1. If you don't already have one, download and install a Git client such as [GitHub Desktop](https://desktop.github.com/), or [command-line Git](https://git-scm.com/).
2. Clone this repository to your computer. If you are using GitHub Desktop, this can be done with the green "download" button at the top of this page.
3. Once it is finished, select the branch you want to sync changes from. `master`, the default branch, is the release version. `dev` contains features which will be in the next update. There are also various other branches available, for testing different features.
4. Open `%appdata%/BEEMOD2/config/config.cfg` in a text editor. <!--TODO: Where are these files/directories located on Mac?-->
5. Set the package directory to the `packages` folder within your cloned repository folder. If using GitHub Desktop, this will default to `C:\Users\<yourname>\Documents\GitHub\BEE2-items\packages`.
6. Open the BEE2.4 application. If it works, your files will be equal to the files of the branch you selected.

To continue recieving the latest changes, you must regularly pull commits from the repository in your Git client. For GitHub Desktop, this is done using the "Pull origin" option at the top of the app.

## Additional Information

- Anything that is placed in the folders `Portal 2/bee2` and `Portal 2/sdk_content/maps/instances/bee2` will be deleted when exporting from BEE2.4 If you are developing custom packages, you can enable the setting *Preserve Game Directories* to disable copying resources. Don't forget to turn the option back off once you've copied the files back into the packages.
- BEE2.4 will crash if you are exporting while another folder or file is open that is important to the BEE2.4 compilation process.
- It is recommended to keep backups of the following Portal 2 folders: `sdk_content`, `portal2_dlc2`, and `bin`, just in case you need to restore your Portal 2 files.

The [wiki](https://github.com/BEEmod/BEE2-items/wiki) contains more in-depth explanations of items and styles, as well as development guides. The wiki is missing a lot of content, you can help by contributing to it.

If you have a question about BEE2.4, check the [FAQ](https://github.com/BEEmod/.github/blob/master/FAQ.md) or ask on [Discord](https://discord.gg/hnGFJrz). Please do not open an issue to ask a question.
