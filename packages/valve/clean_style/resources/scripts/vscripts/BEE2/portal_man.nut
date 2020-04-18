// Manages the state of portals and portalguns in the map.

has_blue <- true;
has_oran <- true;
has_pgun <- true;

start_pos <- self.GetOrigin();

// Takes the gun off you.
stripper <- null;
// Detects cubes held by the player.
held_trig <- null;

// Record the state, since we need to delay for the weapon-strip to fire.
_next_blue <- null;
_next_oran <- null;
_spawn_scheduled <- false;

_held_object <- null;


// Number of portalgun on/off buttons currently on.
// If -1, disabled.
portalgun_onoff_count <- -1;
// If true, force the pgun on.
portalgun_onoff_forced <- false;

function OnPostSpawn() {
	// Cancel if already done.
	if (stripper != null) { return }
	stripper = Entities.FindByName(null, "__pgun_weapon_strip");
	held_trig = Entities.FindByName(null, "__pgun_held_trig");
	if(IsMultiplayer()) {
		// Wait enough for it to spawn.
		EntFireByHandle(self, "CallScriptFunction", "_find_players", 2.5, self, self);
	}
}

function _find_players() {
	// Grab the two coop players, which we know are in this order.
	player_blue <- Entities.FindByClassname(null, "player");
	player_oran <- Entities.FindByClassname(player_blue, "player");
}

// Called OnMapSpawn, passing in this config values.
// We then appropriately remove/give the gun to the player.
// In Coop, never called.
init_called <- false
function init(blue, orange, has_onoff) {
	if (IsMultiplayer() || init_called) {
		return; 
	}
	init_called = true

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

// Upgrade the player's gun, for pedestals
function upgrade(blue, orange) {
	if (IsMultiplayer()) {
		return; 
	}
	
	local needs_new = false;
	
	if (blue && !has_blue) {
		has_blue = blue
		needs_new = true
		kill_pgun_portals(0)
		EntFire("@close_blue_autoportals", "FireUser4", "", 0.00);
	}
	if (orange && !has_oran) {
		has_oran = orange
		needs_new = true
		kill_pgun_portals(1)
		EntFire("@close_orange_autoportals", "FireUser4", "", 0.00);
	}
	
	// If on-off buttons are blocking the gun,
	// remove the new gun we just got given.
	if (portalgun_onoff_count == 0) {
		has_pgun = true
		give_gun(0, 0)
	} else if (needs_new) {
		return_pgun()
	}
}

function remove_pgun() {
	// Take the gun off the player
	if (!has_pgun || IsMultiplayer()) { return; }
	EntFireByHandle(stripper, "Enable", "", 0.0, self, self);
	EntFireByHandle(stripper, "Disable", "", 0.1, self, self);
	has_pgun = false;
}

function return_pgun() {
	give_gun(has_blue, has_oran);
}

function give_gun(blue, oran) {
	if (IsMultiplayer()) {
		return; 
	}
	
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
	
	//  Are we disabled?
	if (portalgun_onoff_count == -1) { return}
	
	portalgun_onoff_count = portalgun_onoff_count + 1;
	
	if (portalgun_onoff_count == 1) {
		// Didn't have a gun, give them one.
		return_pgun();
	}
}

function pgun_btn_deact() {
	// A Portalgun on-off button is pressed.
	
	//  Are we disabled?
	if (portalgun_onoff_count == -1) { return}
	
	portalgun_onoff_count = portalgun_onoff_count - 1;
	
	if (portalgun_onoff_count == 0) {
		// Replace the gun with a no-portal gun.
		give_gun(0, 0);
	}
}

// For use in corridors or other special cases,
// force enable the portalgun.
function pgun_btn_force() {
	if(!portalgun_onoff_forced) {
		portalgun_onoff_forced = true
		pgun_btn_act()
	}
}

// And undo that
function pgun_btn_unforce() {
	if(portalgun_onoff_forced) {
		portalgun_onoff_forced = false
		pgun_btn_deact()
	}
}

function map_won() {
	// When reaching the exit, swap to deactivated mode.
	if (portalgun_onoff_forced) {
		// But not if the gun's forced on...
		return;
	}
	if (portalgun_onoff_count > 0) {
		give_gun(0, 0);
	}
	portalgun_onoff_count = -1;
}

function kill_pgun_portals(color) {
	// Fizzle "loose" portals, (not from autoportals).
	// If color is -1, we kill all portals (including coop).
	// If 0 or 1, we kill just that colour - this is for portalgun pedestals
	local portal = Entities.FindByClassname(null, "prop_portal");
	local scope = null;
	while (portal != null) {
		// If the portal has a name, it's an autoportal - ignore.
		if (portal.GetName() == "") {
			portal.ValidateScriptScope();
			scope = portal.GetScriptScope();
			
			if ("__pgun_active" in scope && scope.__pgun_active) {
				// IF -1, we don't care what it is, otherwise it needs to be SP (0) and
				// the right type.
				if (color == -1 || (scope.__pgun_port_id == 0 && scope.__pgun_is_oran == color)) {
					EntFireByHandle(portal, "Fizzle", "", 0.00, null, null);
					EntFireByHandle(portal, "Kill", "", 0.50, null, null);
				}
			}
		}
		portal = Entities.FindByClassname(portal, "prop_portal");
	}
}

// In coop, delete the portals placed by the other player.
// This ensures the crosshairs match.
function fizzle_other_player() {
	if (!IsMultiplayer()) {
		return
	}
	local pos = null;
	if (activator == player_blue) {
		pos = player_oran.GetOrigin();
	} else {
		pos = player_blue.GetOrigin();
	}
	pos.z += 64;
	self.SetOrigin(pos);
	EntFireByHandle(self, "RunScriptCode", "self.SetOrigin(start_pos)", 0.01, null, null);
}

function _mark_held_cube() {
	// We need to not be holding things while swapping - otherwise
	// the visuals get desynced.
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
	gun.__KeyValueFromInt("Rendermode", 10) // Don't let the player see it onscreen!
	_next_blue = _next_oran = null;
		
	// TP to player.
	local origin = GetPlayer().GetOrigin();
	origin.z = origin.z + 32;
	gun.SetOrigin(origin)
	has_pgun = true;
	
	// If the player was holding a thing, make them pick it up again.
	if (_held_object && _held_object.IsValid()) {
		EntFireByHandle(_held_object, "Use", "", 0.01, GetPlayer(), GetPlayer());
	}
	_held_object = null;
}
self.ConnectOutput("OnEntitySpawned", "_on_spawn")
