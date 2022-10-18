function OnPostSpawn() {
	// trigger_portal_button is an ent at the button which actually detects things.
	// It uses the entity size for this, so we can just resize that.
	local trig = Entities.FindByClassnameWithin(null, "trigger_portal_button", self.GetOrigin(), 16);
	if (self.GetClassname() == "prop_floor_ball_button") {
		// Really small, because this tests the bbox against the cube bbox, so there's diagonals.
		trig.SetSize(Vector(-8, -8, 8), Vector(8, 8, 24));
	} else {
		trig.SetSize(Vector(-24, -24, 12), Vector(24, 24, 18));
	}
	// New buttons are a different shape, turn off the OG collisions.
	EntFireByHandle(self, "DisableCollision", "", 0.5, self, self);
}
