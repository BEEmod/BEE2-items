Preview maps created by Byzarru. 

Follow this guide to create previews for styles and skyboxes in BEE 2.4 that match the official ones.

First, copy the .p2c files and their screenshots from the `p2c/` folder that sits next to this file, to `Portal 2/portal2/puzzles/[YourSteamID]/`.
You should have two maps titled *Style Preview Map* and *Skybox Preview Map* under Create Test Chambers.

Second, you will need to have the "Screenshotter" package installed that contains the item used to set the camera to the correct position in the maps. If you are using a development copy of the packages cloned directly from this repository then you will already have this, but if not, it can be downloaded [here](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2FBEEmod%2FBEE2-items%2Ftree%2Fdev%2Fpackages%2Ftest%2Fscreenshotter) and placed in the BEE2 `packages/` folder just like any other package.

### Video settings
When taking the screenshots, use the following video settings:
* 4:3 aspect ratio
* 1024x768 resolution (exactly 4x what is displayed in the app)
* 8x MSAA Anti-Aliasing
* Anisotropic 16x Filtering mode
* High effect, model, and shader details

If your computer cannot handle these settings and/or you find the resolution annoying, switch to them right before taking each screenshot, then switch back afterward.

### Screenshots
The preview images are stored as PNG files, so they should be taken without lossy compression; i.e. not JPEGs. To do this within Portal 2 itself, you can bind a key to the `screenshot` command (e.g. `bind F4 screenshot`); pressing this key will save an uncompressed screenshot in TGA format to `Portal 2/portal2/screenshots/`, which can be converted into a PNG using an image editor. BEE2 may delete files in this folder if "Cleanup old screenshots" is turned on in the app, disable it or move the screenshots to another folder immediately after taking them to prevent this.

Note that the "Take Screen Shot" action shown in the keyboard options menu (F5 by default) will instead take a JPEG screenshot, so this is not suitable. Steam screenshots (F12 by default) are also in JPEG format, so these will not work either. Alternatively, you may use an external screenshot tool; make sure that it is saving non-lossy images (PNG or TGA), and be careful not to accidentally include overlapping windows or Steam notifications within the screenshot.

### For correct results
* Do not modify the Puzzlemaker maps in any way. 
* Do not show any custom assets that aren't a part of the style/skybox itself.

## Style previews
1. Set lighting mode to Full in the BEE2 compile options window
2. Export your custom style with the recommended settings (skybox, etc.), but disable all voice lines.
3. Build and play Style Preview Map in the Puzzlemaker.
4. Fully enter the chamber so that the door closes behind you. You will automatically enter a viewcontrol with the correct camera angle. Ensure that the monitor extends, cubes drop, etc. before proceeding.
6. Apply the video settings listed above if you were not already using them before this point.
7. Take the screenshot.
8. Save your icon as `[yourstyle].png` in `[package]/resources/BEE2/prev/`.
9. If adding a preview to a style that did not previously have one, add this line to your style in info.txt:
`"IconLarge" "prev/[yourstyle].png"`

## Skybox previews
1. Set lighting mode to Full in the BEE2 compile options window
2. Export the Original Clean style with your custom skybox.
3. Build and play Skybox Preview Map in the Puzzlemaker.
4. Fully enter the chamber so that the door closes behind you. You will automatically enter a viewcontrol with the correct camera angle.
6. Apply the video settings listed above if you were not already using them before this point.
7. Take the screenshot.
8. Save your icon as `sky_[yourskybox].png` in `[package]/resources/BEE2/prev/`.
9. If adding a preview to a skybox that did not previously have one, add this line to your skybox in info.txt:
`"IconLarge" "prev/sky_[yourskybox].png"`

## Music and elevator video previews

These have much less strict requirements. Music previews are effectively just screenshots of the locations where each track is heard in their respective game/mod. You can probably just take these at any resolution and then scale and crop them down to 256x192, the size shown within the app. Alternatively, you can use the `mat_setvideomode` command to set the game resolution directly to 256x192, although this will not work in all games, which may be a problem if you are porting music from another game/mod.

Elevator video previews are taken directly from the videos themselves, by picking a single frame from the video which usefully depicts its content, which may simply be the first frame if the video is fairly uniform throughout. These can be created by either taking a screenshot in a media player (some like VLC include a screenshot button) or by extracting frames from the video directly, but you will probably not be creating custom elevator videos to begin with, as these are not packable into maps.

Voice pack previews are supported internally, but are not currently used by the official packages.
