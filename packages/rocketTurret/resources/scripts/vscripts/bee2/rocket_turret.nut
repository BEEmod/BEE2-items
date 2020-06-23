// Fix rocket turrets, by applying force to the rockets
// and also adding additional logic.

physimpact <- null;

function OnPostSpawn() {
    physimpact = Entities.FindByName(null, "@rocket_punch");
}

function fix_collisions() {
	// Rocket turrets generate bone followers, but they don't actually move producing wrong collisions.
	// They also sometimes duplicate when a save is reloaded, which can eventually lead to a crash.
	// So we just delete them, it doesn't seem to cause any problems and we have our own clips anyway.
	local ent = null;
	while (ent = Entities.FindByClassname(ent, "phys_bone_follower")) {
		// only delete if it's actually for a rocket turret
		if (ent.GetModelName() == "models/props_bts/rocket_sentry.mdl") {
			EntFireByHandle(ent, "Kill", "", 0, self, self)
		}
	}
}

function Think() {
	local ent = null;
	// Loop over every rocket in the map.
	local rockets = [];
	while(ent = Entities.FindByClassname(ent, "rocket_turret_projectile")) {
		
		// It's a fixed one, skip.
		if(ent.GetName() == "") {
			rockets.append(ent);
		}
	}

	if (rockets.len() == 0) {
		return 0.1;
	} 

	ent = rockets[0];

	local origin = ent.GetOrigin();
	local angles = ent.GetAngles();

	// Rename so we won't affect this one in future.
	ent.__KeyValueFromString("targetname", "@rocket_turret_missile");

	// Spawn in our extra entities. 
	self.SpawnEntityAtLocation(origin, angles);

	// There's a target at 0 0 0 named @rocket_target&xxx, find it.
	// All the other ents are parented to this, so we can easily loop over them.
	local target = null;
	while(target = Entities.FindByClassnameWithin(target, "info_target", origin, 16.0)) {
		printl("Targ: \"" + target.GetName() + "\"")
		if (target.GetPreTemplateName() == "@rocket_target") {
			break;
		}
	}
	if (target == null) {
		printl("No rocket target??");
		return;
	}

	// Move all the children to be parented to the real rocket, then destroy the target.
	local targ_child = target.FirstMoveChild();
	while (targ_child != null) {
		EntFireByHandle(targ_child, "SetParent", "!activator", 0, ent, ent);
		if (targ_child.GetName().find("turret_trig"))
		{
			// This trigger causes problems if it starts enabled, turn it on later
			EntFireByHandle(targ_child, "Enable", "", 0.1, targ_child, targ_child)
		}
		targ_child = targ_child.NextMovePeer();
	}
	target.__KeyValueFromString("targetname", "@rocket_target_used");
	EntFireByHandle(target, "Kill", "", 0.1, self, self);

	physimpact.SetOrigin(origin - ent.GetForwardVector());
	EntFireByHandle(physimpact, "Explode", "", 0.0, ent, self);

	if (rockets.len() > 1) {
		return 0.01;
	}
}
