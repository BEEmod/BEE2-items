[![BEE2-items Releases](https://img.shields.io/github/downloads/BEEmod/BEE2-items/total.svg?label=Packages)](https://github.com/BEEmod/BEE2-items/releases)
[![BEE2.4 Releases](https://img.shields.io/github/downloads/BEEmod/BEE2.4/total.svg?label=App)](https://github.com/BEEmod/BEE2.4/releases)

### Please read the [Contributing Guidelines](https://github.com/BEEmod/BEE2-items/blob/master/.github/contributing.md), [FAQ](https://github.com/BEEmod/BEE2-items/wiki/FAQ), and [known issues list](https://github.com/BEEmod/BEE2-items/wiki/Known-Issues) before opening an issue.

![BEE2 Icon](https://raw.githubusercontent.com/BEEmod/BEE2.4/master/bee2.ico)
# BEE2.4 Default Pack
This is the default set of packages for the [BEE2.4](https://github.com/BEEmod/BEE2.4). Packages contain resources for BEE2.4, such as items or styles.

[Application Repository](https://github.com/BEEmod/BEE2.4)

[Discord Server](https://discord.me/beemod)

[Steam Group](https://steamcommunity.com/groups/beemod)

## Download and Use

### Release Version

These are instructions to install the release version of BEE2.4. For the development version, see below.

1. Download the BEE2.4 app and compiler from [here](https://github.com/BEEmod/BEE2.4/releases).
2. Download the Default Pack from [here](https://github.com/BEEmod/BEE2-items/releases). Make sure to get the same version as the application, otherwise you may encounter errors.
3. Extract the application zip to anywhere on your computer.
4. Extract the contents of the Default Pack zip to the application folder you just extracted.
5. To launch BEE2.4, go to the `bin` folder and open `BEE2.exe`.
6. Once opened, select the game you want BEE2.4 to modify.

You can add another game using `File > Add Game`. Any Source game can be added, but BEE2.4 will only work with Portal 2 and Aperture Tag. Thinking With Time Machine support is planned, but has not yet been implemented.
To remove a game, use `File > Uninstall from Selected Game`. As well as unmounting it from BEE2.4, this will also remove all BEE2.4-related resources from the game and reset the Puzzlemaker to the default items and style for that game.

When exporting BEE2.4 after installing a new version, old resources from past releases will not be overwritten, resulting in bugs that were fixed still being present and some things not working correctly. To solve this, choose `File > Uninstall from Selected Game` to remove all BEE2.4 resources from the game. Then, choose `File > Add Game` and browse to the location of `portal2.exe`. Next time you export, the new resources will be copied to the game and new changes and bugfixes will take effect.

### Development Version

These are instructions to install the development version of the Default Pack. This will allow you to access features directly from GitHub branches such as `dev`, instead of having to wait for a release to be made. However, this version may be unstable. Therefore, it is recommended that you use the release version unless you are developing custom content.

For some things to work correctly, you may need to use this with the development version of the application/compiler. Instructions for how to install this can be found [here](https://github.com/BEEmod/BEE2.4#build-from-source-advanced-for-adding-to-bee24-program-windows).

1. If you don't already have one, download and install a Git client such as [GitHub Desktop](https://desktop.github.com/).
2. Clone this repository in your Git client. If you are using GitHub Desktop, the "Clone or Download" button above can be used to instantly begin cloning the repository to your computer.
3. Once it is finished, select the branch you want to sync changes from. `master`, the default branch, is the release version. `dev` contains features which will be in the next update. There are also various other branches available, for testing different features.
4. Open `%appdata%/BEEMOD2/config/config.cfg` in a text editor. <!--TODO: Where are these files/directories located on Mac?-->
5. Set the package directory to the `packages` folder within your cloned repository folder. If using GitHub Desktop, this will default to `C:\Users\<yourname>\Documents\GitHub\BEE2-items\packages`.
6. Open the BEE2.4 application. If it works, your files will be equal to the files of the branch you selected.

To continue recieving the latest changes, you must regularly pull commits from the repository in your Git client. For GitHub Desktop, this is done using the "Pull origin" option at the top of the app.

## Additional Information

- If you are editing in Hammer, anything that is placed in the folder `sdk_content\maps\instances\bee2` will be deleted if you export the BEE2.4 pallete without enabling the setting *Preserve Game Directories*. If you are editing any package, after you have finished, do not forget to save it inside the packages, by replacing the old files inside. If you are using the development version, you can run `reverse-cache.py` to do this automatically. <!--TODO: Does do what I think it does/work properly?-->
- BEE2.4 will crash if you are exporting while another folder or file is open that is important to the BEE2.4 compilation process.
- It is recommended to keep backups of the following Portal 2 folders: `sdk_content`, `portal2_dlc2`, and `bin`, just in case you need to restore your Portal 2 files.

The [BEE2.4 Default Pack wiki](https://github.com/BEEmod/BEE2-items/wiki) contains more in-depth explanations of items and styles, as well as development guides. The [BEE2.4 wiki](https://github.com/BEEmod/BEE2.4/wiki) has information on the application. Note that both of these wikis are missing a lot of content, you can help by contributing to them.

If you have a question about BEE2.4, check the [FAQ](https://github.com/BEEmod/BEE2-items/wiki/FAQ) or ask on [Discord](https://discord.me/beemod). Please do not open an issue to ask a question.
