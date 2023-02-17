// Logic for swapping superposition cubes.

tele_real  <- EntityGroup[0];
tele_ghost <- EntityGroup[1];
dest_real  <- EntityGroup[2];
dest_ghost <- EntityGroup[3];
force_drop_filter <- EntityGroup[4];

// FIZZLE_TOGETHER: From scriptvar setter.

cube_real <- null;
cube_ghost <- null;

function SpawnedGhost() {
	cube_ghost <- activator;
	// printl("Ghost cube: " + cube_ghost);
}

function SpawnedReal() {
	cube_real <- activator;
	// printl("Real cube: " + cube_real);
}

function FizzledGhost() {
	cube_ghost <- null;
	printl("Ghost cube fizzled");
	if (FIZZLE_TOGETHER && cube_real != null) {
		EntFireByHandle(cube_real, "Dissolve", "", 0.0, self, self);
		cube_real = null;
	}
}

function FizzledReal() {
	cube_real <- null;
	printl("Real cube fizzled");
	if (FIZZLE_TOGETHER && cube_ghost != null) {
		EntFireByHandle(cube_ghost, "CallScriptFunction", "FizzleIfOutside", 0.0, self, self);
		cube_ghost = null;
	}
}

function DoSwap() {
	if (cube_real == null || cube_ghost == null) {
		printl("No pair!");
		return;
	}
	collision_pair <- Entities.CreateByClassname("logic_collision_pair");
	collision_pair.__KeyValueFromString("attach1", cube_real.GetName());
	collision_pair.__KeyValueFromString("attach2", cube_ghost.GetName());

	local real_pos = cube_real.GetOrigin();
	local real_ang = cube_real.GetAngles();
	local ghost_pos = cube_ghost.GetOrigin();
	local ghost_ang = cube_ghost.GetAngles();

	// printl("Swapping " + real_pos + " @ " + real_ang + " <-> " + ghost_pos + " @ " + ghost_ang);

	tele_real.SetOrigin(real_pos);
	tele_ghost.SetOrigin(ghost_pos);

	dest_real.SetOrigin(real_pos);
	dest_real.SetAngles(real_ang.x, real_ang.y, real_ang.z);

	dest_ghost.SetOrigin(ghost_pos);
	dest_ghost.SetAngles(ghost_ang.x, ghost_ang.y, ghost_ang.z);

	EntFireByHandle(collision_pair, "DisableCollisions", "", 0, null, null);
	EntFireByHandle(tele_real, "Enable", "", 0.01, null, null);
	EntFireByHandle(tele_ghost, "Enable", "", 0.01, null, null);
	EntFireByHandle(force_drop_filter, "TestActivator", "", 0.01, cube_real, cube_real);
	EntFireByHandle(force_drop_filter, "TestActivator", "", 0.01, cube_ghost, cube_ghost);
	EntFireByHandle(collision_pair, "EnableCollisions", "", 0.02, null, null);
	EntFireByHandle(collision_pair, "Kill", "", 0.10, null, null);
	EntFireByHandle(tele_real, "Disable", "", 0.2, null, null);
	EntFireByHandle(tele_ghost, "Disable", "", 0.2, null, null);
}
