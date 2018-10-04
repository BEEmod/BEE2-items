touch_pos <- {};  // ID -> -1/+1 for side.
// axis and up_axis: Set by compiler to "x"/"y"/"z".
active <- 0;
color <- 0; // 0-200
mdl_name <- self.GetName().slice(0, -4) + "mdl*";

function OnPostSpawn() {
	out_ent <- Entities.FindByName(null, self.GetName().slice(0, -4) + "out");
}

function Precache() {
	self.PrecacheSoundScript("bee2/p1/hl1_bell.wav");
}

function act_velocity() {
	// Take the player (!activator), and check if they're on the +ve or -ve side.
	// You pass if you enter and leave with the same velocity orientation.
	// That means you've passed through the trigger.
	return activator.GetVelocity()[axis] > 0;
}

function start_touch() {
	touch_pos[activator.entindex()] <- act_velocity();
}


function end_touch() {
	local player_ent = activator.entindex();
	if (!(player_ent in touch_pos)) {
		printl("Exited trigger but didn't enter??");
		return;
	}
	local enter_vel = touch_pos[player_ent];
	delete touch_pos[player_ent];
	
	if (act_velocity() == enter_vel) {
		// Entered and exited with the same velocity, you've passed through.
		active = !active;
		self.EmitSound("bee2/p1/hl1_bell.wav");
		// Produces "[electronic beeping]".
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
