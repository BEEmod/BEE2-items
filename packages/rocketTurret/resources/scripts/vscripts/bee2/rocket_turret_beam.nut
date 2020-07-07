// The rocket turret beam will sometimes stop rendering, it tends to happen when the end target moves outside the map.
// This script uses a traceline so that doesn't happen.
// It also handles target switching in Co-op.

max_dist <- 3200; // maximum size of a puzzlemaker map

inst_fixup <- self.GetName().slice(0, self.GetName().find("-"));
beam_start <- Entities.FindByName(null, inst_fixup+"-beam_start");
beam_end <- Entities.FindByName(null, inst_fixup+"-beam_end");

dist <- 0

function setup() {
	if (IsMultiplayer()) {
		// Wait long enough for players to spawn
		EntFireByHandle(self, "CallScriptFunction", "find_players", 2.5, self, self);
		EntFire(inst_fixup+"-man", "SetStateBTrue", "", 2.5);
	} else {
		// In SP, trigger immediately
		EntFire(inst_fixup+"-man", "SetStateBTrue", "", 0.1);
	}
	
}

function find_players() {
	blue <- Entities.FindByName(null, "!player_blue");
	oran <- Entities.FindByName(null, "!player_orange");
}

active <- false
blue_visible <- false
oran_visible <- false
target <- ""
old_target <- ""

function beam_think() {
	if (active) {
		dist = TraceLine(beam_start.GetOrigin(), beam_start.GetOrigin() + (beam_start.GetForwardVector() * max_dist), self) * max_dist;
		beam_end.SetOrigin(Vector(dist, 0, 0));

		// In Co-op, dynamically switch targets between the two bots
		if (IsMultiplayer()) {
			// First check for line of sight to each of the bots
			// This is how the actual entity's LOS testing is done, from the barrel to the player's eyes
			if (TraceLine(beam_start.GetOrigin(), blue.GetOrigin() + Vector(0, 0, 64), self) == 1.0) blue_visible = true; else blue_visible = false;
			if (TraceLine(beam_start.GetOrigin(), oran.GetOrigin() + Vector(0, 0, 64), self) == 1.0) oran_visible = true; else oran_visible = false;

			if (blue_visible == oran_visible) {
				// target the closer player
				if (Entities.FindByClassnameNearest("player", self.GetOrigin(), 32767) == blue) target = "!player_blue";
				if (Entities.FindByClassnameNearest("player", self.GetOrigin(), 32767) == oran) target = "!player_orange";
			} else {
				// target whoever is visible
				if (blue_visible) target = "!player_blue";
				if (oran_visible) target = "!player_orange";
			}
			// Don't constantly fire settarget inputs
			if (target != old_target) EntFireByHandle(self, "SetTarget", target, 0, self, self);
			old_target = target;
		}
	}
}