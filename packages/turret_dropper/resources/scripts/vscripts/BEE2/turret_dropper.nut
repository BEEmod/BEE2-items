template <- EntityGroup[0] // point_template
fizzler <- EntityGroup[1] // env_entity_dissolver for fizzling the turret
ent_retractor <- EntityGroup[2] // Movelinear for raising the turret.

INST_NAME <- self.GetName().slice(0, -("script".len()))
RELEASE_CEIL <- self.GetOrigin().z - 64.0 // Do not release above this height.
RETRACTOR_START <- ent_retractor.GetOrigin()
RETRACTOR_START.z -= 1.0

turret_waiting <- null // The turret inside the dropper, or currently lowering.
turret_spawned <- null // The active turret outside the dropper, if present.
constraint <- null // Constrains the turret to the claw.
claw_phys <- null // Physbox for the claw.
claw_mdl <- null // Claw model.

g_initialised <- false
conf_respawn <- false
conf_ready_to_spawn <- false
conf_want_spawn <- false
// Are we lowering the turret down?
is_lowering <- false
// When lowering, the position of the turret last think cycle.
g_last_lower_z <- null

// If I'm Different is the background music.
has_turr_music <- false
// The point at which the turret was placed, for the music.
// If the turret moves away (tipped/picked up), play music.
// Resetting this to null allows us to ensure each turret
// only plays it once.
turr_land_pos <- null

function on_turret_spawn() {	
	// Grab references to the spawned things.
	// The template is with the spawned ents.
	local pos = template.GetOrigin()
	turret_waiting = Entities.FindByClassnameWithin(null, "npc_portal_turret_floor", pos, 8)
	constraint = Entities.FindByClassnameWithin(null, "phys_constraint", pos, 8)
	claw_mdl = Entities.FindByNameNearest(INST_NAME + "claw_mdl*", pos, 128)
	claw_phys = Entities.FindByNameNearest(INST_NAME + "claw_phys*", pos, 128)
}


function OnPostSpawn() {
	if (!g_initialised) {
		// Trigger an output so we can start getting a turret.
		EntFireByHandle(template, "FireUser1", "", 0.0, self, self)

		// Check if we should do the turret music logic.
		has_turr_music = Entities.FindByName(self, "@music_turret") != null
		g_initialised = true
	}
}

// Turret triggers this when it falls over, so we respawn it.
function turret_died() {
	if (has_turr_music && turr_land_pos != null) {
		EntFire("@music_turret", "PlaySound")
		turr_land_pos = null
	}
	if (conf_respawn) {
		// If lowering, cancel.
		if (!is_lowering) {
			fizzle_active_turret()
		}
		conf_want_spawn = true
	}
	// Treat as if it was lowering, retract the claw.
	if (is_lowering) {
		if (constraint != null) {
			EntFireByHandle(constraint, "Break", "", 0.0, self, self);
			constraint = null
		}
		claw_destroyed()
	}
}

// Request to spawn a turret.
function spawn() {
	if (conf_ready_to_spawn) {
		// Don't wait for the think script.
		do_spawn()
	} else {
		// Wait until ready.
		conf_want_spawn = true
	}
}

// Called when the turret is fully respawned.
function is_ready_to_spawn() {
    conf_ready_to_spawn = true
}

// When the turret starts lowering..
function start_lower() {
	is_lowering = true
	g_last_lower_z = turret_waiting.GetOrigin().z;
}

// Retract the cable.
function retract_cable() {
	if (claw_mdl != null && claw_phys != null && claw_mdl.IsValid() && claw_phys.IsValid()) {
		// Movelinear moves to pre-calculated coordinates, so if we teleport it it'll
		// just return to its original position.
		ent_retractor.SetOrigin(claw_mdl.GetOrigin())
		EntFireByHandle(claw_phys, "DisableMotion", "", 0.0, self, self)
		EntFireByHandle(claw_phys, "SetParent", ent_retractor.GetName(), 0.0, self, self)
		EntFireByHandle(ent_retractor, "SetSpeed", "100", 0.0, self, self)
		EntFireByHandle(ent_retractor, "SetPosition", "0", 0.0, self, self)
		EntFireByHandle(ent_retractor, "SetSpeed", "200", 0.2, self, self)
		EntFireByHandle(ent_retractor, "SetSpeed", "300", 0.4, self, self)
		EntFireByHandle(ent_retractor, "SetSpeed", "400", 0.6, self, self)

		// We don't care about them anymore, it's heading to the dropper regardless.
		claw_phys = null
		claw_mdl = null
		is_lowering = false
	} else {
		// Claw was also destroyed? Quickly reset it, so it spawns a new one.
		ent_retractor.SetOrigin(RETRACTOR_START);
		EntFireByHandle(ent_retractor, "SetPosition", "0", 0.5, self, self);
	}
}

// Turret is fully lowered, release it.
function release_turret() {
	turret_spawned = turret_waiting
	// We just spawned, no need for another.
	conf_want_spawn = false
	EntFireByHandle(turret_spawned, "Enable", "", 0.50, self, self) // Make it active
	EntFireByHandle(constraint, "Break", "", 0.00, self, self) // Actually detach.
	EntFireByHandle(self, "FireUser2", "", 0.00, self, self)
	// Reset everything
	is_lowering = false
	turret_waiting = null
	g_last_lower_z = null
	constraint = null

	if (has_turr_music) {
		// Record the point the turret was dropped at to detect tipping.
		turr_land_pos = turret_spawned.GetOrigin()
	}
}

// Fired if a constraint snaps or the cla fizzled. It needs to be replaced and retried.
// Note we only care if we're lowering. If we aren't, the turret was already released, so it'll 
// reset once the rope completes anyway.
function claw_destroyed() {
	if (is_lowering) {
		// Turret might have died while lifting - ignore if so.

		// Clean up the dead turret after a second or so.
		if (turret_waiting != null && turret_waiting.IsValid()) {
			EntFireByHandle(fizzler, "Dissolve", "!activator", 1.50, turret_waiting, self)
		}
		g_last_lower_z = null
		constraint = null
		turret_waiting = null
		// Should be null, but just in case.
		fizzle_active_turret()
		retract_cable()
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
	printl("Fizzling active: " + turret_spawned);
	if (turret_spawned != null && turret_spawned.IsValid()) {
		// Dissolve activator, and pass the turret along as that.
		EntFireByHandle(fizzler, "Dissolve", "!activator", 0.00, turret_spawned, self)
		turr_land_pos = null
		turret_spawned = null
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

	if (is_lowering && g_last_lower_z != null) {
		// See if the turret stopped.
		local turr_z = turret_waiting.GetOrigin().z;
		// printl(format("Turret Z: %.6f", g_last_lower_z - turr_z));
		if (g_last_lower_z - turr_z < 15.0 && turr_z < RELEASE_CEIL) {
			release_turret();
			g_last_lower_z = null
		} else {
			g_last_lower_z = turr_z;
		}
		return 0.1; // We're active, think faster.
	}
	// We're idle, nothing is time-critical.
	// Put randomness in so lots of these don't all
	// think on the same frame.
	return RandomFloat(0.5, 1.5)
}
