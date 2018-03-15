touch_pos <- {};  // ID -> -1/+1 for side.
// axis = Set by compiler to "x"/"y"/"z".
plane_off <- self.GetOrigin()[axis]; // origin[axis]

function Precache() {
	self.PrecacheSoundScript("bee2/p1/hl1_bell.wav");
}

function act_side() {
	// Take the player (!activator), and check if they're on the +ve or -ve side.
	local off = activator.GetOrigin()[axis];
	if (axis == "z") {
		// Offset to near the center, so vertically you have to go all the way through.
		off += 64;
	}
	if (off > plane_off) {
		return 1;
	} else {
		return -1;
	}
}

function start_touch() {
	touch_pos[activator.entindex()] <- act_side();
}


function end_touch() {
	if (!(activator.entindex() in touch_pos)) {
		// Ended but didn't start!?
		return;
	}
	if (act_side() != touch_pos[activator.entindex()]) {
		// Swapped sides.
		EntFireByHandle(self, "FireUser1", "", 0, activator, self);
		self.EmitSound("bee2/p1/hl1_bell.wav");
	}
}

self.ConnectOutput("OnStartTouch", "start_touch");
self.ConnectOutput("OnEndTouch", "end_touch");
