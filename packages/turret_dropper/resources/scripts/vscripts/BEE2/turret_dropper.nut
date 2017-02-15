template <- EntityGroup[0] // point_template
fizzler <- EntityGroup[1] // env_entity_dissolver for fizzling the turret
upper_door <- EntityGroup[2] // The door for respawning the turret

turret_waiting <- null;
turret_spawned <- null;
constraint <- null;

conf_respawn <- false;
conf_ready_to_spawn <- false;
conf_want_spawn <- false;

function on_turret_spawn() {	
	// Grab references to the spawned things.
	// The template is with the spawned ents.
	turret_waiting = Entities.FindByClassnameWithin(null, "npc_portal_turret_floor", template.GetOrigin(), 32)
	constraint = Entities.FindByClassnameWithin(null, "phys_constraint", template.GetOrigin(), 32)
	print("Turret: ")
	printl(turret_waiting)
	print("Constraint: ")
	printl(constraint)
}


function OnPostSpawn() {
	EntFireByHandle(upper_door, "Open", "", 0.00, self, self)
}

// Turret triggers this when it falls over, so we respawn it.
function turret_died() {
	if (!conf_respawn) {
		return
	}
	fizzle_active_turret()
	conf_want_spawn = true;
}

// Request to spawn a turret.
function spawn() {
	fizzle_active_turret()
	conf_want_spawn = true;
	// Don't delay.
	if (conf_want_spawn && conf_ready_to_spawn) {
		do_spawn()
	}
}

function do_spawn() {
	// Execute a spawn.
	fizzle_active_turret()
	conf_want_spawn = false;
	conf_ready_to_spawn = false;
	EntFireByHandle(self, "FireUser1", "", 0.00, self, self);
}

// If the turret is alive, fizzle it.
function fizzle_active_turret() {
	if (turret_spawned != null && turret_spawned.IsValid()) {
		// Dissolve activator, and pass the turret along as that.
		EntFireByHandle(fizzler, "Dissolve", "!activator", 0.00, turret_spawned, self)
	}
}

function Think() {
	if (conf_respawn && turret_spawned != null) {
		if (!turret_spawned.IsValid()) {
			turret_spawned = null
			conf_want_spawn = true
		}
	}
	// Check if we can actually spawn.
	if (conf_want_spawn && conf_ready_to_spawn) {
		do_spawn()
	}
	// Nothing is time-critical.
	return 1;
}

// Turret is fully lowered, release it.
function release_turret() {
	turret_spawned = turret_waiting
	// Respawning turrets set this, ignore from the turret.
	conf_want_spawn = false
	turret_waiting = null;
	EntFireByHandle(turret_spawned, "Enable", "", 0.00, self, self) // Make it active
	EntFireByHandle(constraint, "Break", "", 0.00, self, self)
	constraint = null
}
