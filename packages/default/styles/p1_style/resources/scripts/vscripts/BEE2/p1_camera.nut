function OnPostSpawn() {
	self.SetModel("models/BEE2/props_p1/security_camera.mdl");

	// We need to fix the existing env_sprite, it has the wrong attachment point.
	local ent = Entities.FindByClassnameWithin(null, "env_sprite", self.GetOrigin(), 32);
	while (ent != null) {
		if (ent.GetName() == "") {
			EntFireByHandle(ent, "HideSprite", "", 0.0, self, self);
		}
		ent = Entities.FindByClassnameWithin(ent, "env_sprite", self.GetOrigin(), 32);
	}

	// Now set the attachment points of the ropes and sprite.
	ent = self.FirstMoveChild();
	local cls;
	while (ent != null) {
		cls = ent.GetClassname();
		if (cls == "move_rope" || cls == "keyframe_rope") {
			// Named blah-r2_b -> attachment wire2_b
			EntFireByHandle(ent, "SetParentAttachment", "wire" + ent.GetName().slice(-3), 0.1, self, self);
			
		// Only affect our sprite.
		} else if (cls == "env_sprite" && ent.GetName()) {
			EntFireByHandle(ent, "SetParentAttachment", "light", 0.1, self, self);
		} 
		ent = ent.NextMovePeer();
	}
}

function kill_cam_spr() {
	// After the camera becomes physics, we need to remove the light.
	// Search through all sprites, and remove the ones attached to us.
	local sprite = self.FirstMoveChild();
	while (sprite != null) {
		// Remove only sprites.
		if (sprite.GetClassname() == "env_sprite") {
			EntFireByHandle(sprite, "Kill", "", 0.01, self, self);
		}
		sprite = sprite.NextMovePeer();
	}
}
