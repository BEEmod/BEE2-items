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
cur_moving <- -1;
//Set for the tick that _up or _down gets called
desired_direction <- 0;
verify_clock <- 0;//Clock to verify that no inputs butt to the front of the line
//INFINITESIMAL_TICK = 3.8146977e-6;

START_SND <- "";
STOP_SND <- "";

// If true, we spawned extended.
SPAWN_UP <- false;
// Name of down fizzler. Starts set for backward compat.
DN_FIZZ_NAME <- "dn_fizz";

dn_fizz_ents <- [];
dn_fizz_on <- false;
dn_fizz_allowed <- false;
door_pos <- null;
crush_count <- 0;
snd_btm_pos <- self.GetOrigin();
snd_top_ent <- null;


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
	
	snd_top_ent <- self.GetMoveParent();
	if (snd_top_ent != null) {
		// We now know what it is.
		EntFireByHandle(self, "ClearParent", "", 0, self, self);
	}
	
	// If present, trigger whenever we start moving to wake cubes.
	enable_motion_trig <- Entities.FindByName(null, inst_name + "-wake_trig");
	
	// If we have these, turn them on while going down.
	// Need to loop since there could be a hurt and fizzler.
	local dn_fizz = null;
	local dn_fizz_name = format("%s-%s", inst_name, DN_FIZZ_NAME);
	while (dn_fizz = Entities.FindByName(dn_fizz, dn_fizz_name)) {
		dn_fizz_ents.push(dn_fizz);
	}
}

function moveto(new_pos) {
	local old_pos = pos;
	pos = new_pos;
	
	// printl("Moving: " + old_pos + " -> " + new_pos);
	
	if (old_pos == new_pos) {
		return; // No change.
	}
	
	if (cur_moving == -1) {
		if(START_SND) {
			self.EmitSound(START_SND);
		}
		if (self.GetClassname() == "func_rotating") { // Looping sound
			EntFireByHandle(self, "Start", "", 0.00, self, self);
		}
		if (enable_motion_trig != null) {
			EntFireByHandle(enable_motion_trig, "Enable", "", 0, self, self);
			EntFireByHandle(enable_motion_trig, "Disable", "", 0.1, self, self);
		}
	}
	
	if (old_pos < new_pos) {
		door_pos = null;
		if (dn_fizz_ents.len() > 0) {
			dn_fizz_allowed = false;
			if (dn_fizz_on) {
				dn_fizz_on = false;
				foreach (fizz in dn_fizz_ents) {
					EntFireByHandle(fizz, "Disable", "", 0, self, self);
				}
			}
		}
		_up();
	} else if (old_pos > new_pos) {
		_dn();
		if (dn_fizz_ents.len() > 0) {
			dn_fizz_allowed <- true;
		}
	}
}

// These two funcs find the first platform in their direction that's wrong,
// and trigger it.
// The pistons then trigger them again when they finish, so we loop until done.
function _up() {
	if (desired_direction && verify_clock != Time()) {//Caused by I/O logic butting in line
		EntFireByHandle(self, "CallScriptFunction", "_up", 0, self, self);//Push to the end of the I/O queue after verifyDirection
		return;
	}
	for(local i=1; i<=pos; i++) {
		if (positions[i] != POS_UP) {
			positions[i] = POS_MOVING;
			EntFireByHandle(pistons[i], "SetSpeed", ""+SPEED_UP, 0, self, self);//From init_code
			EntFireByHandle(pistons[i], "Open", "", 0, self, self);
			if (desired_direction == 0) {
				EntFireByHandle(self, "RunScriptCode", "verifyDirection(POS_UP)", 0.01, self, self);
				verify_clock = Time();
			}
			desired_direction <- POS_UP;
			cur_moving = i;
			return;
		}
	}
	// Finished.
	cur_moving = -1;
	if (STOP_SND) {
		self.EmitSound(STOP_SND);
	}
	if (self.GetClassname() == "func_rotating") { // Looping sound
		EntFireByHandle(self, "Stop", "", 0.00, self, self);
	}
}

function _dn() {
	if (desired_direction && verify_clock != Time()) {//Caused by I/O logic butting in line
		EntFireByHandle(self, "CallScriptFunction", "_dn", 0, self, self);//Push to the end of the I/O queue so that verifyDirection runs before this
		return;
	}
	// Do not include piston[pos].
	for(local i=4; i>pos; i--) {
		if (positions[i] != POS_DN) {
			positions[i] = POS_MOVING;
			EntFireByHandle(pistons[i], "SetSpeed", ""+SPEED_DOWN, 0, self, self);//From init_code
			EntFireByHandle(pistons[i], "Close", "", 0, self, self);
			if (desired_direction == 0) {
				EntFireByHandle(self, "RunScriptCode", "verifyDirection(POS_DN)", 0.01, self, self);
				verify_clock <- Time();
			}
			desired_direction <- POS_DN;
			cur_moving = i;
			door_pos = pistons[i].GetOrigin();
			crush_count = 0;
			return;
		}
	}
	// Finished.
	cur_moving = -1;
	if (STOP_SND) {
		self.EmitSound(STOP_SND);
	}
	if (self.GetClassname() == "func_rotating") { // Looping sound.
		EntFireByHandle(self, "Stop", "", 0.00, self, self);
	}
	if (dn_fizz_on) {
		dn_fizz_on = false;
		dn_fizz_allowed = false;
		door_pos = null;
		foreach (fizz in dn_fizz_ents) {
			EntFireByHandle(fizz, "Disable", "", 0, self, self);
		}
	}
}

function verifyDirection(original_direction) {
	if (original_direction == desired_direction) {
		desired_direction <- 0;//Nothing to correct
	} else if (desired_direction == POS_UP) {
		desired_direction <- 0;//Repeat verification
		_up();
	} else if (desired_direction == POS_DN) {
		desired_direction <- 0;//Repeat verification
		_dn();
	} else {
		printl("Incorrect piston behavior");
		desired_direction <- 0;
	}
}

function Think() {
	if (cur_moving != -1 && snd_top_ent != null) {
		// Update position.
		local sum = snd_btm_pos + snd_top_ent.GetOrigin();
		sum *= 0.5;
		self.SetOrigin(sum);
	}

	// Used by pistons that can fizzle objects below them.
	// If it gets stuck (stops moving), activate.
	// Lotsa checks here.
	// Only run if:
	// * allowed to.
	// * Not already on
	// * Currently moving
	// * We have a valid previous position
	// It has to trigger twice consecuatively.
    if (dn_fizz_allowed && !dn_fizz_on && cur_moving != -1 && door_pos != null) {
		local new_pos = pistons[cur_moving].GetOrigin();
		if ((new_pos - door_pos).LengthSqr() < 1) {
			crush_count++;
			if (crush_count > 2) {
				// Stuck...
				dn_fizz_on = true;
				foreach (fizz in dn_fizz_ents) {
					EntFireByHandle(fizz, "Enable", "", 0, self, self);
				}
			}
		} else {
			crush_count = 0;
		}
		door_pos = new_pos;
   		return 0.05;
    }
    return cur_moving != -1 ? 0.1 : 0.25;
}
