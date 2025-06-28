// Manages the state of portals and portalguns in the map.
// A bunch of functions are public as listed below.

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

// Called OnMapSpawn by the compiler, passing in this config values.
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

// Public: Upgrade the player's gun, for pedestals
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

// Public: Remove the player's gun.
function remove_pgun() {
	if (!has_pgun || IsMultiplayer()) { return; }
	EntFireByHandle(stripper, "Enable", "", 0.0, self, self);
	EntFireByHandle(stripper, "Disable", "", 0.1, self, self);
	has_pgun = false;
}

// Public: Give the player their gun back with the same settings.
function return_pgun() {
	give_gun(has_blue, has_oran);
}


// Public: Give the player a gun with the specified colours, or replace an existing one.
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


// Public: Increment the number of Portalgun on/off buttons being pressed.
function pgun_btn_act() {	
	//  Are we disabled?
	if (portalgun_onoff_count == -1) { return}
	
	portalgun_onoff_count = portalgun_onoff_count + 1;
	
	if (portalgun_onoff_count == 1) {
		// Didn't have a gun, give them one.
		return_pgun();
	}
}

// Public: Decrement the number of Portalgun on/off buttons being pressed.
function pgun_btn_deact() {	
	//  Are we disabled?
	if (portalgun_onoff_count == -1) { return}
	
	portalgun_onoff_count = portalgun_onoff_count - 1;
	
	if (portalgun_onoff_count == 0) {
		// Replace the gun with a no-portal gun.
		give_gun(0, 0);
	}
}

// Public: For use in corridors or other special cases,
// force enable the portalgun.
function pgun_btn_force() {
	if(!portalgun_onoff_forced) {
		portalgun_onoff_forced = true
		pgun_btn_act()
	}
}

// Public: And undo that
function pgun_btn_unforce() {
	if(portalgun_onoff_forced) {
		portalgun_onoff_forced = false
		pgun_btn_deact()
	}
}

// Public: Called by corridors, starts ignoring any on/off buttons still active.
function map_won() {
	if (portalgun_onoff_forced) {
		// But not if the gun's forced on...
		return;
	}
	if (portalgun_onoff_count > 0) {
		give_gun(0, 0);
	}
	portalgun_onoff_count = -1;
}

function portal_active(scope) {
	// Check if 'active' is set.
	return scope != null && "__pgun_active" in scope && scope.__pgun_active;
}

// Public: Collect all active portal pairs and return them.
function get_portal_pairs() {
	port_blue <- {};
	port_oran <- {};
	local portal = null, scope;
	while (portal = Entities.FindByClassname(portal, "prop_portal")) {
		if (portal_active(scope = portal.GetScriptScope())) {
			local table = scope.__pgun_is_oran ? port_oran : port_blue;
			if (scope.__pgun_port_id in table) {
				printl(format(
					"Duplicate active portals with ID %i, colour=%s", 
					scope.__pgun_port_id, 
					scope.__pgun_is_oran ? "orange" : "blue"
				));
			} else {
				table[scope.__pgun_port_id] <- portal;
			}
		}
	}
	local results = {};
	foreach (port_id, blue in port_blue) {
		if (port_id in port_oran) {
			results[port_id] <- [blue, port_oran[port_id]];
		}
	}
	return results;
}

function portal_active_ent(portal) {
	return portal_active(portal.GetScriptScope());
}

function portal_color(portal) {
	local scope = portal.GetScriptScope();
	if (scope != null && "__pgun_is_oran" in scope) {
		return scope.__pgun_is_oran ? "orange" : "blue";
	}
	return null;
}

function portal_get_id(portal) {
	local scope = portal.GetScriptScope();
	if (scope != null && "__pgun_port_id" in scope) {
		return scope.__pgun_port_id;
	}
	return null;
}

// Public APIs for getting portal pairs.
::BEE_GetPortalPairs <- get_portal_pairs.bindenv(this);
::BEE_PortalActive <- portal_active_ent.bindenv(this);

// Public: Fizzle "loose" portals, (not from autoportals).
// If color is -1, we kill all portals (including coop).
// If 0 or 1, we kill just that colour - this is for portalgun pedestals
function kill_pgun_portals(color) {
	local portal = null;
	local scope = null;
	while (portal = Entities.FindByClassname(portal, "prop_portal")) {
		// If the portal has a name, it's an autoportal - ignore.
		if (portal.GetName() == "" && portal_active(scope = portal.GetScriptScope())) {
			// IF -1, we don't care what it is, otherwise it needs to be SP (0) and
			// the right type.
			if (color == -1 || (scope.__pgun_port_id == 0 && scope.__pgun_is_oran == color)) {
				EntFireByHandle(portal, "Fizzle", "", 0.00, null, null);
				EntFireByHandle(portal, "Kill", "", 0.50, null, null);
			}
		}
	}
}

// Public: In coop, delete the portals placed by the other player.
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

// These are triggered by map-global portal detectors, to let us detect open/closed
// portals. This avoids RunScriptCode compiles each time.
// !activator will be the portal.
function _on_blue0_open() {_on_open(0, false)}
function _on_oran0_open() {_on_open(0, true)}
function _on_blue1_open() {_on_open(1, false)}
function _on_oran1_open() {_on_open(1, true)}
function _on_blue2_open() {_on_open(2, false)}
function _on_oran2_open() {_on_open(2, true)}
function _on_close0() {_on_close(0)}
function _on_close1() {_on_close(1)}
function _on_close2() {_on_close(2)}

function _on_open(port_id, is_oran) {
	local portal = activator;
	if (GetDeveloperLevel() > 0) {
		printl(format(
			"Portal open, name=\"%s\", id=%i, color=%s, linkage=%i", 
			portal.GetName(), portal.entindex(), is_oran ? "oran" : "blue", port_id
		));
	}

	portal.ValidateScriptScope();
	local scope = portal.GetScriptScope();
	scope.__pgun_active <- true;
	scope.__pgun_is_oran <- is_oran;
	scope.__pgun_port_id <- port_id;
}

function _on_close(port_id) {
	local portal = activator;
	if (GetDeveloperLevel() > 0) {
		printl(format("Portal closed, name=\"%s\", id=%i", portal.GetName(), portal.entindex()));
	}
	portal.ValidateScriptScope();
	portal.GetScriptScope().__pgun_active <- false;
}
