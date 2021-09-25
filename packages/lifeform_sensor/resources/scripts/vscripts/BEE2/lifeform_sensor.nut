touch_pos <- {};  // ID -> -1/+1 for side.
// axis: Set by compiler to "x"/"y"/"z".
// timer: Set by conditions to 0/1.
active <- 0; // If toggled, or timer is active.
color <- 0; // 0-200
// Remove field from the end, add mdl*.
mdl_name <- self.GetName().slice(0, -5) + "mdl*";

function OnPostSpawn() {
	if (timer) {
		EntFire(mdl_name, "Color", "0 150 0", 0.00);
		self.ConnectOutput("OnStartTouch", "start_touch_timer");
	} else {
		self.ConnectOutput("OnStartTouch", "start_touch_toggle");
		self.ConnectOutput("OnEndTouch", "end_touch");
	}
}

function Precache() {
	self.PrecacheSoundScript("BEE2.p1.rex_field_activate");
	self.PrecacheSoundScript("BEE2.p1.rex_field_deactivate");
}

function InputDisable() {
    // When disabled, turn off the timer if active.
    if (timer) {
		if (active) {
			EntFireByHandle(self, "FireUser1", "", 0, activator, self);
			active = false;
		}
    } else { 
    	// Reset touches as if all ents exited.
        touch_pos = {};
    }
	return true; // Allow it to be disabled.
}

function act_velocity() {
	// Take the player (!activator), and check if they're on the +ve or -ve side.
	// You pass if you enter and leave with the same velocity orientation.
	// That means you've passed through the trigger.
	return activator.GetVelocity()[axis] > 0;
}

function start_touch_timer() {
	self.EmitSound("BEE2.p1.rex_field_activate");
	// Produces "[electronic beeping]".
	SendToConsole("cc_emit World.RobotNegInteractPitchedUp");

	if (active) {
		// Already timing, refire.
		EntFireByHandle(self, "FireUser1", "", 0, activator, self);
		EntFireByHandle(self, "FireUser2", "", 0.01, activator, self);
	} else {
		EntFireByHandle(self, "FireUser2", "", 0, activator, self);
	}
	active = true;
	color = 200;
}

function start_touch_toggle() {
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
		EntFireByHandle(self, active ? "FireUser2" : "FireUser1", "", 0, activator, self);

		self.EmitSound(active ? "BEE2.p1.rex_field_activate" : "BEE2.p1.rex_field_deactivate");
		// Produces "[electronic beeping]".
		SendToConsole("cc_emit World.RobotNegInteractPitchedUp");
	}
}

function timer_done() {
    // Timer is finished.
	EntFireByHandle(self, "FireUser1", "", 0, activator, self);
	active = false;
}

function max(x, y) {
	return (y > x) ? y : x;
}
function min(x, y) {
	return (y < x) ? y : x;
}

function Think() {
	// Fade in and out colours.
	if (timer) {
		if (color > 0) {
			color = max(0, color - 10);
		} else {
			// We're not animating, wait longer.
			return 0.1; 
		}
		EntFire(
			mdl_name, "Color",
			max(0, color-100) + " " + min(255, 150 + color) + " " + max(0, color-100), 
			0.00
		);
	} else {
		if (active && color < 200) {
			color += 20;
		} else if (!active && color > 0) {
			color -= 20;
		} else {
			// We're not animating, wait longer.
			return 0.1; 
		}
		EntFire(mdl_name, "Color", color + " 200 " + (200-color), 0.00);
	}
	// We're animating, think every frame.
	return 0.01;
}
