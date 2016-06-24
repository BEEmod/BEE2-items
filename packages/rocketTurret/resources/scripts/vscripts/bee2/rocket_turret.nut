// Replaces rocket projectiles to fix bugs.
// Apply to an env_entity_maker.

explosion <- Entities.FindByName(null, self.GetName() + "_exp");

function Think() {
	local ent = null;
	while(1) {
		// Loop over every rocket in the map
		ent = Entities.FindByClassname(ent, "rocket_turret_projectile");
		if(ent == null) {
			break;
		}
		
		// It's a fixed one, skip.
		if(ent.GetPreTemplateName() == "@rocket_turret_missile") {
			continue;
		}
		
		// Get the exact position of the original rocket
		local origin = ent.GetOrigin();
		local angles = ent.GetAngles();
		local forward = ent.GetForwardVector();
		
		// We need to ensure it doesn't spawn inside the barrel -
		// this breaks it sometimes in certain orientations.
		origin.x += forward.x * 32;
		origin.y += forward.y * 32;
		origin.z += forward.z * 32;
		
		// Shove the original out of the map, so it doesn't affect anything.
		ent.SetOrigin(Vector(-1000, 0, 0));
		// Then kill it.
        EntFireByHandle(ent, "Kill", "", 0, self, self);
		
		// Needed to fix bugs?
		self.SetAngles(angles.x, angles.y, angles.z);
		self.SpawnEntityAtLocation(origin, angles);
	}
}