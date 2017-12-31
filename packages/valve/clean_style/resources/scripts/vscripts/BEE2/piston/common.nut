// Coordinates the different parts of the piston platform-style items.

// Used with the PistonPlatform Result - places instances, and this script.
// Entities we control:
// -script: Us
// -pist1 - 4: The func_movelinears, needs SetPosition, OnFullyOpen, OnFullyClosed

inst_name <- self.GetName().slice(0, -7);

pos <- 0;  // Position we want to be at.
// Layout:
// pos, pist
// 4    _ _
//       4
// 3    _4_
//       3
// 2    _3_
//       2 
// 1    _2_  ___
//       1    |
// 0 ____1____|_

// 1-4 = ents, may be null.
pistons <- {};
// positions - where the door is right now.
POS_UP <- 1;
POS_DN <- -1;
POS_MOVING <- 0;
positions <- {};

START_SND <- "";
STOP_SND <- "";

// If true, we spawned extended.
SPAWN_UP <- false;

is_moving <- false;

function Precache() {
	if(START_SND) self.PrecacheSoundScript(START_SND);
	if(STOP_SND)  self.PrecacheSoundScript(STOP_SND);
}

function OnPostSpawn() {
	// Grab our pistons - may not be there if the ents won't exist.
	local pist = null;
	local found_pist = false;
	local start_pos = (SPAWN_UP) ? POS_UP : POS_DN;
	local highest_pos = 0;
	for (local i=1; i<=4; i++) {
		pist = Entities.FindByName(null, inst_name + "-pist" + i);
		pistons[i] <- pist;
		// Hookup IO to notify us when they've reached the ends.
		// We set the position to the correct value, then call _up() or _dn().
		if (pist != null) {
			EntFireByHandle(pist, "AddOutput", "OnFullyOpen " + self.GetName() + ":RunScriptCode:positions[" + i + "]=" + POS_UP + ";_up():0:-1", 0, self, self);
			EntFireByHandle(pist, "AddOutput", "OnFullyClosed " + self.GetName() + ":RunScriptCode:positions[" + i + "]=" + POS_DN + ";_dn():0:-1", 0, self, self);
			positions[i] <- start_pos;
			found_pist = true;
			highest_pos = i;
		} else {
			// Piston not there, so we need to assume bottom ones are up,
			// top ones are down.
			// if found_pist = true, we're past the bottom ones...
			positions[i] <- found_pist ? POS_DN : POS_UP;
		}
	}
	if (SPAWN_UP) {
		pos = highest_pos;
	}
}

function moveto(new_pos) {
	local old_pos = pos;
	pos = new_pos;
	
	if (old_pos == new_pos) {
		return; // No change.
	}
	
	if (!is_moving) {
		is_moving = true;
		if(START_SND) {
			self.EmitSound(START_SND);
		}
		if(self.GetClassname() == "ambient_generic") {
			EntFireByHandle(self, "PlaySound", "", 0.00, self, self);
		}
	}
	
	if (old_pos < new_pos) {
		_up();
	} else if (old_pos > new_pos) {
		_dn();
	}
}

// These two funcs find the first platform in their direction that's wrong,
// and trigger it.
// The pistons then trigger them again when they finish, so we loop until done.
function _up() {
	for(local i=1; i<=pos; i++) {
		if (positions[i] != POS_UP) {
			positions[i] = POS_MOVING;
			EntFireByHandle(pistons[i], "Open", "", 0, self, self);
			return;
		}
	}
	// Finished.
	is_moving = false;
	if (STOP_SND) {
		self.EmitSound(STOP_SND);
	}
	if(self.GetClassname() == "ambient_generic") {
		EntFireByHandle(self, "StopSound", "", 0.00, self, self);
	}
}

function _dn() {
	// Do not include piston[pos].
	for(local i=4; i>pos; i--) {
		if (positions[i] != POS_DN) {
			positions[i] = POS_MOVING;
			EntFireByHandle(pistons[i], "Close", "", 0, self, self);
			return;
		}
	}
	// Finished.
	is_moving = false;
	if (STOP_SND) {
		self.EmitSound(STOP_SND);
	}
	if(self.GetClassname() == "ambient_generic") {
		EntFireByHandle(self, "StopSound", "", 0.00, self, self);
	}
}
