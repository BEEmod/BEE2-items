// Apply to an env_splash. It should be placed 16 units above the surface.
// The depth of the water should be set as a targetname suffix after a '_'.
// When this passes above/below that height, splashes will be triggered.

is_above <- 0; // 0=above water, 1 = below water.
water_pos <- 0; // Z-pos of the water.
last_z <- null; // Position last think - if not moving, reduce think times.
targ <- null;
off_tick_rate <- 0.4; // Run uncommonly when not moving.

function OnPostSpawn() {
	// Pull arguments from our targetname.

	local name = self.GetName();
	water_pos = name.slice(-10, -1).tofloat();
	
	if (name.slice(-1) == "f") {
		off_tick_rate = 0.1;
	}
	
	//printl("Splash height: " + water_pos.tostring() + ", tick: " + off_tick_rate.tostring())
	
	// Get rid of our junk from the entity name..
	EntFireByHandle(self, "AddOutput", "targetname " + name.slice(0, -11), 0.0, self, self);
	
	last_z = self.GetOrigin().z;
	is_above = (last_z > water_pos);
}

function Think() {
	// The return value of the think function is the time until
	// the next think should execute.
	local z = self.GetOrigin().z;
	
	if (z == last_z) {
		return off_tick_rate;
	} else {
		last_z = z;
	}
	
	// print(self.GetName());
	// print(":");
	// print(is_above);
	// print(" ");
	// print(z);
	// print(" : ");
	// printl(water_pos);
	
	 if (is_above == 1) {
		if (z <= water_pos) {
			// Going underwater
			is_above = 0;
			EntFireByHandle(self, "Splash", "", 0.0, self, self);
		}
	} else {
		if (z > water_pos + 4) {
			// Coming back up
			is_above = 1;
			EntFireByHandle(self, "Splash", "", 0.0, self, self);
		}
	}
	
	// We're moving, check more rapidly.
	return 0.05;
}