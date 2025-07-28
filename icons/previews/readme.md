Preview maps created by Byzarru. 

Follow this guide to create previews for styles and skyboxes in BEE 2.4 that match the official ones.

First, copy the .p2c files and their screenshots from the `p2c/` folder that sits next to this file, to `Portal 2/portal2/puzzles/[YourSteamID]/`.
You should have two maps titled *Style Preview Map* and *Skybox Preview Map* under Create Test Chambers.

### Video settings
When taking the screenshots, use the following video settings:
* 4:3 aspect ratio
* 1024x768 resolution (exactly 4x what is displayed in the app)
* 8x MSAA Anti-Aliasing
* Anisotropic 16x Filtering mode
* High effect, model, and shader details

### Screenshots
The preview images will end up as PNG files, so ideally they should be taken without lossy compression; i.e. not JPEGs. To do this within Portal 2 itself, you can bind a key to the `screenshot` command (e.g. `bind F4 screenshot`); pressing this key will save an uncompressed screenshot in TGA format to `Portal 2/portal2/screenshots/`, which can be converted into a PNG using an image editor. Note that the "Take Screen Shot" action shown in the keyboard options menu (F5 by default) will instead take a JPEG screenshot, so this is not suitable. Steam screenshots (F12 by default) are also in JPEG format, so these will not work either. Alternatively, you may use an external screenshot tool; make sure that it is saving non-lossy images (PNG or TGA), and be careful not to accidentally include overlapping windows within the screenshot.

### For accurate results
* Do not modify the Puzzlemaker maps in any way. 
* Do not move your camera after running the setpos/setang commands.
* Make sure you are standing still before running the setpos/setang commands, as otherwise your position may drift slightly after teleporting.
* Do not show any custom assets that aren't a part of the style/skybox itself.

## Style previews
1. Set lighting mode to Full in the BEE2 compile options window
2. Export your custom style with the recommended settings (skybox, etc.), but disable all voice lines.
3. Build and play Style Preview Map in the Puzzlemaker.
4. Fully enter the chamber so that the door closes behind you. Ensure that the monitor extends, cubes drop, etc. before proceeding
5. Run the following commands in the console:
* `sv_cheats 1;noclip;notarget;cl_drawhud 0;r_drawviewmodel 0`
* `setpos 2223.582520 2035.648682 549.729980;setang 15.516277 49.474407 0.000000`
6. Double-check that you are using the resolution and video settings listed above
7. Take the screenshot
8. Save your icon as `[yourstyle].png` in `[package]/resources/BEE2/prev/`.
9. If adding a preview to a style that did not previously have one, add this line to your style in info.txt:
`"IconLarge" "prev/[yourstyle].png"`

## Skybox previews
1. Set lighting mode to Full in the BEE2 compile options window
2. Export the Original Clean style with your custom skybox.
3. Build and play Skybox Preview Map in the Puzzlemaker.
4. Fully enter the chamber so that the door closes behind you.
5. Run the following commands in the console: 
* `sv_cheats 1;noclip;cl_drawhud 0;r_drawviewmodel 0`
* `setpos 568 175 340; setang 0 90 0`
6. Double-check that you are using the resolution and video settings listed above
7. Take the screenshot
8. Save your icon as `sky_[yourskybox].png` in `[package]/resources/BEE2/prev/`.
9. If adding a preview to a skybox that did not previously have one, add this line to your skybox in info.txt:
`"IconLarge" "prev/sky_[yourskybox].png"`

## Music and elevator video previews

These have much less strict requirements. Music previews are effectively just screenshots of the locations where each track is heard in their respective game/mod. You can probably just take these at any resolution and then scale and crop them down to 256x192, the size shown within the app. Alternatively, you can use the `mat_setvideomode` command to set the game resolution directly to 256x192, although this will not work in all games, which may be a problem if you are porting music from another game.

Elevator video previews are taken directly from the videos themselves, by picking a single frame from the video which usefully depicts its content, which may simply be the first frame if the video is fairly uniform throughout. These can be created by either taking a screenshot in a media player (some like VLC include a screenshot button) or by extracting frames from the video directly, but you will probably not be creating custom elevator videos to begin with, as these are not packable into maps.

Voice pack previews are supported internally, but are not currently used by the official packages.