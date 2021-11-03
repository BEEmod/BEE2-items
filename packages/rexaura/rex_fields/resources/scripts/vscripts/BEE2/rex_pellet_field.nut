// axis: Set by compiler to "x"/"y"/"z".
// timer: Set by conditions to 0/1.
active <- 0; // If toggled, or timer is active.
plane_dist <- 0; 
// FX env_entity_maker.
fx_maker <- null;
angles <- Vector(0, 0, 0);

function OnPostSpawn() {
	fx_maker = Entities.FindByName(null, "@rex_pellet_field_fx_maker");
	self.ConnectOutput("OnStartTouch", timer ? "touch_timer" : "touch_toggle");
	plane_dist = self.GetOrigin()[axis];
	if (axis == "z") {
		angles.x = -90;
	} else if (axis == "y") {
		angles.y = 90;
	}
}

function Precache() {
	self.PrecacheSoundScript("BEE2.p1.rex_field_activate");
	self.PrecacheSoundScript("BEE2.p1.rex_field_deactivate");
}

function InputDisable() {
    // When disabled, turn off the timer if active.
    if (timer && active) {
		EntFireByHandle(self, "FireUser1", "", 0, activator, self);
		active = false;
	}
	return true; // Allow it to be disabled.
}

function spawn_fx() {
	local pos = activator.GetOrigin();
	// Snap into our field.
	pos[axis] = plane_dist;
	fx_maker.SpawnEntityAtLocation(pos, angles);
}

function touch_timer() {
	spawn_fx();
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
}

function touch_toggle() {
	spawn_fx();
	self.EmitSound(active ? "BEE2.p1.rex_field_activate" : "BEE2.p1.rex_field_deactivate");
	// Produces "[electronic beeping]".
	SendToConsole("cc_emit World.RobotNegInteractPitchedUp");

	active = !active;
	EntFireByHandle(self, active ? "FireUser2" : "FireUser1", "", 0, activator, self);
}

function timer_done() {
    // Timer is finished.
	EntFireByHandle(self, "FireUser1", "", 0, activator, self);
	active = false;
}

