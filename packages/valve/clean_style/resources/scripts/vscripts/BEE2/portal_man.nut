// Manages the state of portals and portalguns in the map.
// Only useful in SP.

has_blue <- true;
has_oran <- true;
has_pgun <- true;

// Takes the gun off you.
stripper <- null;
// Detects cubes held by the player.
held_trig <- null;

_next_blue <- null;
_next_oran <- null;
_spawn_scheduled <- false;

_held_object <- null;

// Number of portalgun on/off buttons currently on.
// If -1, disabled.
portalgun_onoff_count <- -1;

function OnPostSpawn() {
	stripper = Entities.FindByName(null, "__pgun_weapon_strip");
	held_trig = Entities.FindByName(null, "__pgun_held_trig");
}

function init(blue, orange, has_onoff) {
	has_blue = blue
	has_oran = orange
	if (has_onoff) {
		portalgun_onoff_count = 0
		give_gun(0, 0)
	} else if (!has_blue && !has_oran) {
		remove_pgun()
	} else {
		give_gun(blue, orange)
	}
}

function upgrade(blue, orange) {
	local needs_new = false;
	if (blue && !has_blue) {
		has_blue = blue
		needs_new = true
	}
	if (orange && !has_oran) {
		has_oran = orange
		needs_new = true
	}
	// If on-off buttons are blocking the gun,
	// remove the new gun we just got given.
	if (portalgun_onoff_count == 0) {
		has_pgun = true
		give_nogun()
	}
}

function remove_pgun() {
	// Take the gun off the player
	if (!has_pgun) { return; }
	EntFireByHandle(stripper, "Enable", "", 0.0, self, self);
	EntFireByHandle(stripper, "Disable", "", 0.1, self, self);
	has_pgun = false;
}

function return_pgun() {
	give_gun(has_blue, has_oran);
}

function give_gun(blue, oran) {
	_next_blue = blue;
	_next_oran = oran;
	
	if (_spawn_scheduled) {
		// We already are asking for a gun spawn, don't refire outputs.
		// It'll set the gun to our current settings.
		return
	}
	
	_spawn_scheduled = true;
	_held_object = null;
	
	if (has_pgun) { 
		remove_pgun()
	}
	EntFireByHandle(held_trig, "Enable", "", 0.0, self, self);
	EntFireByHandle(held_trig, "Disable", "", 0.1, self, self);
	EntFireByHandle(self, "ForceSpawn", "", 0.1, self, self);
}


function pgun_btn_act() {
	// A Portalgun on-off button is pressed.
	
	// Disabled.
	if (portalgun_onoff_count == -1) { return}
	
	portalgun_onoff_count = portalgun_onoff_count + 1;
	
	if (portalgun_onoff_count == 1) {
		// Didn't have a gun, give them one.
		return_pgun();
	}
}

function pgun_btn_deact() {
	// A Portalgun on-off button is pressed.
	
	// Disabled.
	if (portalgun_onoff_count == -1) { return}
	
	portalgun_onoff_count = portalgun_onoff_count - 1;
	
	if (portalgun_onoff_count == 0) {
		// Replace the gun with a no-portal gun.
		give_gun(0, 0);
	}
}

function pgun_btn_shutdown() {
	// When reaching the exit, swap to deactivated mode.
	if (portalgun_onoff_count > 0) {
		give_gun(0, 0);
	}
	portalgun_onoff_count = -1;
}

function _mark_held_cube() {
	// We drop things when failing.
	_held_object = activator;
	EntFireByHandle(_held_object, "Use", "", 0.01, GetPlayer(), GetPlayer());
}

function _on_spawn() {
	// Called on each ent the template uses.
	// This should be defined by the engine, but that's commented out.
	// So do it ourselves.
	
	local gun = Entities.FindByClassnameWithin(null, "weapon_portalgun", self.GetOrigin(), 16);
	
	if (!_spawn_scheduled) {
		gun.Destroy();
		return;
	}
	
	_spawn_scheduled = false;
	gun.__KeyValueFromInt("CanFirePortal1", _next_blue.tointeger())
	gun.__KeyValueFromInt("CanFirePortal2", _next_oran.tointeger())
	gun.__KeyValueFromInt("Rendermode", 10)
	_next_blue = _next_oran = null;
		
	// TP to player.
	local origin = GetPlayer().GetOrigin();
	origin.z = origin.z + 32;
	gun.SetOrigin(origin)
	has_pgun = true;
	
	if (_held_object && _held_object.IsValid()) {
		EntFireByHandle(_held_object, "Use", "", 0.01, GetPlayer(), GetPlayer());
	}
	_held_object = null;
}
self.ConnectOutput("OnEntitySpawned", "_on_spawn")
