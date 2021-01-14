Preview maps created by Byzarru. 

Please follow this guide to create previews for styles and skyboxes in BEE 2.4.

First, copy the .p2c files and their screenshots in p2c to:
* C:\Program Files (x86)\Steam\steamapps\common\Portal 2\portal2\puzzles\[a number]\
You should have two maps titled Style Preview Map and Skybox Preview Map under Create Test Chambers. 
Open your preferred image editor and create a file that is 400x300 pixels. An editor with layering support is recommended (Photoshop, paint.NET, etc.).

Style previews: 
Export your custom style with the recommended settings (skybox, etc.)
Build and play Style Preview Map in the PuzzleMaker.
Set your video to the following settings: 
* Widescreen 16:9 Aspect Ratio
* 3840x2160 resolution if available, otherwise 1920x1080 will work
* 8x MSAA Anti-Aliasing
* Anisotropic 16x Filtering mode
* High effect, model, and shader details
Enter the chamber and run the following commands in the console:
* sv_cheats 1;noclip 1;cl_drawhud 0;r_drawviewmodel 0
* setpos 2223.582520 2035.648682 549.729980;setang 15.516277 49.474407 0.000000
Take a screenshot, and move the screenshot to your blank file.
Resize your screenshot to 14% and center to the canvas.
Save your icon as [yourstyle].png in [package]/resources/BEE2/prev/.
Add a line to your style in info.txt: "IconLarge"	"prev/[yourstyle].png"

Skybox previews:
Export the Original Clean style with your custom skybox.
Build and play Skybox Preview Map in the PuzzleMaker.
Set your video to the following settings: 
* Widescreen 16:9 Aspect Ratio
* 2048x1152 resolution if available, otherwise 1920x1080 will work
* 8x MSAA Anti-Aliasing
* Anisotropic 16x Filtering mode
* High effect, model, and shader details
Enter the chamber and run the following commands in the console: 
* sv_cheats 1;noclip 1;cl_drawhud 0;r_drawviewmodel 0
* setpos 568 175 340; setang 0 90 0
Take a screenshot, and move the screenshot to your blank file.
Resize your screenshot to 28% and center to the canvas.
Save your icon as sky_[yourskybox].png in [package]/resources/BEE2/prev/.
Add a line to your style in info.txt: "IconLarge"	"prev/sky_[yourstyle].png"

Notes:
* Do not modify the Puzzlemaker maps in any way. 
* Do not move your camera after running the setpos/setang commands.
* If you are using the wrong resolution while taking screenshots, resize them to 538x303 for styles and 574x323 for skyboxes.