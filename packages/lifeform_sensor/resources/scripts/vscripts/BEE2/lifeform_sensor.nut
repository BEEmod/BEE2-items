touch_pos <- {};  // ID -> -1/+1 for side.
// axis = Set by compiler to "x"/"y"/"z".
plane_off <- 0;  // origin[axis]
active <- 0;
color <- 0; // 0-200

mdl_name <- self.GetName().slice(0, -4) + "mdl*";

function OnPostSpawn() {
	out_ent <- Entities.FindByName(null, self.GetName().slice(0, -4) + "out");
	plane_off <- self.GetOrigin()[axis];
}

function Precache() {
	self.PrecacheSoundScript("bee2/p1/hl1_bell.wav");
}

function act_side() {
	// Take the player (!activator), and check if they're on the +ve or -ve side.
	// We use GetCenter() since that gives a logical value vertically - the player must
	// be all the way through to trigger.
	local off = activator.GetCenter()[axis];
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
		active = !active;
		self.EmitSound("bee2/p1/hl1_bell.wav");
		// Produces "electronic beeping."
		SendToConsole("cc_emit World.RobotNegInteractPitchedUp");
		EntFireByHandle(out_ent, active ? "FireUser2" : "FireUser1", "", 0, activator, self);
	}
}

self.ConnectOutput("OnStartTouch", "start_touch");
self.ConnectOutput("OnEndTouch", "end_touch");

function Think() {
	// Fade in and out colours.
	if (active && color < 200) {
		color += 20;
	} else if (!active && color > 0) {
		color -= 20;
	} else {
		// We're not animating, wait longer.
		return 0.1; 
	}
	EntFire(mdl_name, "Color", color + " 200 " + (200-color), 0.00);
	// We're animating, think every frame.
	return 0.01;
}
