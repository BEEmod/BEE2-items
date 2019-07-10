function OnPostSpawn() {
	// trigger_portal_button is an ent at the button which actually detects things.
	// We can override the spawnflags to only allow players.
	local trig = Entities.FindByClassnameWithin(null, "trigger_portal_button", self.GetOrigin(), 16);
	EntFireByHandle(trig, "addoutput", "spawnflags 1", 0, self, self);
}
