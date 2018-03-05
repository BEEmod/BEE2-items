function OnPostSpawn() {
	// trigger_portal_button is an ent at the button which actually detects things.
	// It uses the entity size for this, so we can just resize that.
	local trig = Entities.FindByClassnameWithin(null, "trigger_portal_button", self.GetOrigin(), 16);
	trig.SetSize(Vector(-64, -64, 0), Vector( 64,  64, 16));
}
