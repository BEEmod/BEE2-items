function rusty_reflect() // Reflection cube with dirty gel skins
{
self.SetModel("models/BEE2/props_ingame/reflection_cube_rusty.mdl");
}

function p1_button() // Portal 1 style button
{
self.SetModel("models/BEE2/props_ingame/p1_switch.mdl");
}

function p1_cube() // Portal 1 style companion/standard cube
{
self.SetModel("models/BEE2/props_ingame/p1_metal_box.mdl");
}

function p1_ball() // Portal 1 style sphere
{
self.SetModel("models/BEE2/props_ingame/p1_ball.mdl");
}

function p1_cam() 
{
self.SetModel("models/BEE2/props_p1/security_camera.mdl");
// Now set the attachment points of the ropes and sprite.
EntFireByHandle(self, "FireUser1", "", 0.0, null, null);

// We need to get rid of the original env_sprite - it loses the attachment, and gets stuck at the origin.
local sprite = Entities.FindByClassnameNearest("env_sprite", self.GetOrigin(), 32);
EntFireByHandle(sprite, "HideSprite", "", 0.0, null, null);
}

function kill_cam_spr() 
{
	// The sprite reappears after the camera becomes physics, so we need to get rid of it again.
	// Search through all sprites, and remove the ones attached to us.

	local sprite = Entities.FindByClassname(null, "env_sprite");
	while (sprite != null) {
		// Remove only sprites parented to us..
		if (sprite.GetMoveParent() == self) {
			EntFireByHandle(sprite, "Kill", "", 0.00, null, null);
		}
		sprite = Entities.FindByClassname(sprite, "env_sprite");
	}
}

function under_ccube() // underground old aperture cube with hearts. Applied to old cube.
{
self.SetModel("models/BEE2/props_ingame/retro_companion.mdl");
}

function rusty_cube() // Rusty cube like normal one, but using clean skin slots instead to allow showing gels.
{
self.SetModel("models/BEE2/props_ingame/metal_box_rusty.mdl");
}