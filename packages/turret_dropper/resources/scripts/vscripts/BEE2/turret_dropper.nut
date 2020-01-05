template <- EntityGroup[0] // point_template
fizzler <- EntityGroup[1] // env_entity_dissolver for fizzling the turret
lower_door <- EntityGroup[2] // The door for lowering the turret

turret_waiting <- null
turret_spawned <- null
constraint <- null

conf_respawn <- false
conf_ready_to_spawn <- false
conf_want_spawn <- false
// Are we lowering the turret down?
is_lowering <- false

// If I'm Different is the background music.
has_turr_music <- false
// The point at which the turret was placed, for the music.
// If the turret moves away (tipped/picked up), play music.
// Resetting this to null allows us to ensure each turret
// only plays it once.
turr_land_pos <- null;

function on_turret_spawn() {	
	// Grab references to the spawned things.
	// The template is with the spawned ents.
	turret_waiting = Entities.FindByClassnameWithin(null, "npc_portal_turret_floor", template.GetOrigin(), 32)
	constraint = Entities.FindByClassnameWithin(null, "phys_constraint", template.GetOrigin(), 32)
}


function OnPostSpawn() {
	// Trigger an output so we can start getting a turret.
	EntFireByHandle(self, "FireUser4", "", 0.00, self, self)

	// Check if we should do the turret music logic.
	has_turr_music = Entities.FindByName(self, "@music_turret") != null
}

// Turret triggers this when it falls over, so we respawn it.
function turret_died() {
	if (has_turr_music && turr_land_pos != null) {
		EntFire("@music_turret", "PlaySound")
		turr_land_pos = null
	}
	if (conf_respawn) {
		// If lowering, cancel.
		if (is_lowering) {
			const_break()
		} else {
			fizzle_active_turret()
			conf_want_spawn = true
		}
	}
}

// Request to spawn a turret.
function spawn() {
	fizzle_active_turret()
	conf_want_spawn = true
	// Don't delay.
	if (conf_want_spawn && conf_ready_to_spawn) {
		do_spawn()
	}
}

// When the turret starts lowering..
function start_lower() {
	is_lowering = true
}

// Turret is fully lowered, release it.
function release_turret() {
	turret_spawned = turret_waiting
	// Respawning turrets set this, ignore from the turret.
	conf_want_spawn = false
	is_lowering = false
	turret_waiting = null
	EntFireByHandle(turret_spawned, "Enable", "", 0.50, self, self) // Make it active
	EntFireByHandle(constraint, "Break", "", 0.00, self, self)
	constraint = null

	if (has_turr_music) {
		// Record the point the turret was dropped at to detect tipping.
		turr_land_pos = turret_spawned.GetOrigin();
	}
}

// Fired if the constraint snaps - the turret hit a bridge or something
// so we need to fizzle, and retry.
// Note this can only happen if we're Opening the movelinear.
function const_break() {
	if (is_lowering) {
		// Turret might have died while lifting - ignore if so.

		// Clean up the dead turret after a second or so.
		if (turret_waiting != null && turret_waiting.IsValid()) {
			EntFireByHandle(fizzler, "Dissolve", "!activator", 1.50, turret_waiting, self)
		}
		constraint = null
		turret_waiting = null
		conf_want_spawn = true
		// Should be null, but just in case.
		fizzle_active_turret()
		EntFireByHandle(lower_door, "Close", "", 0.00, self, self)
	}
}


// Internal functions

function do_spawn() {
	// Execute a spawn.
	fizzle_active_turret()
	conf_want_spawn = false
	conf_ready_to_spawn = false
	EntFireByHandle(self, "FireUser1", "", 0.00, self, self)
}
// If the turret is alive, fizzle it.
function fizzle_active_turret() {
	if (turret_spawned != null && turret_spawned.IsValid()) {
		// Dissolve activator, and pass the turret along as that.
		EntFireByHandle(fizzler, "Dissolve", "!activator", 0.00, turret_spawned, self)
		turr_land_pos = null
	}
}

function Think() {
	// If the spawned turret is invalid, it's been killed.
	// so we want to respawn it again.
	if (turret_spawned != null) {
		if(!turret_spawned.IsValid()) {
			turret_spawned = null
			if(conf_respawn) {
				conf_want_spawn = true
			}
		} else if (
			turr_land_pos != null &&
			(turret_spawned.GetOrigin() - turr_land_pos).LengthSqr() > 256 // 16^2
		) {
		    // Turret has been bumped a fair bit, treat this as killed.
			EntFire("@music_turret", "PlaySound")
			turr_land_pos = null
		}
	}
	// Check if we can actually spawn.
	if (conf_want_spawn && conf_ready_to_spawn) {
		do_spawn()
	}
	// Nothing is time-critical.
	// Put randomness in so lots of these don't all
	// think on the same frame.
	return RandomFloat(0.5, 1.5);
}
