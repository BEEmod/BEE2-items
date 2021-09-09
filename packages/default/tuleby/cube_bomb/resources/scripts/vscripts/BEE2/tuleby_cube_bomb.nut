
// Modes the cube can be in.
CUBE_BOMB_WAITING <- 0; // Before pickup, waiting for that.
CUBE_BOMB_HELD <- 1;    // In hands.
CUBE_BOMB_ARMED <- 2;   // Timer ticking down, going to fire.

cube_bomb_mode <- CUBE_BOMB_WAITING;
// cube_bomb_time: Set by the map.
blink_state <- false;

// Global time at which we were armed, and will detonate.
// We 'forgive' drops for about .2 seconds.
arm_time <- -1;
det_time <- -1;

function Precache() {
	self.PrecacheSoundScript("NPC_RocketTurret.LockingBeep")
	self.PrecacheSoundScript("World.RobotNegInteract")
	self.PrecacheSoundScript("Default.Null")
}

function OnPostSpawn() {
	self.ConnectOutput("OnPlayerPickup", "_on_pickup")
	self.ConnectOutput("OnPhysGunDrop", "_on_drop")
}

function LightsThink() {
	// Set bodygroup to increment lights as needed.
	
	if (cube_bomb_mode == CUBE_BOMB_HELD) {
		if (blink_state) {
			self.SetBodygroup(1, 30)
		} else {
			self.SetBodygroup(1, 0)
		}
		blink_state = !blink_state
	} else if (cube_bomb_mode == CUBE_BOMB_ARMED) {
		local remaining = det_time - Time();
		if (remaining < 0) {
			cube_bomb_explode();
		} else {
			local frac = (remaining/cube_bomb_time) * 30
			self.SetBodygroup(1, floor(frac).tointeger())
		}
	}
	
	return 0.25
}

function arm() {
	self.EmitSound("NPC_RocketTurret.LockingBeep")
	cube_bomb_mode = CUBE_BOMB_ARMED;
	arm_time = Time();
	det_time = arm_time + cube_bomb_time;
	LightsThink();
}

function cube_bomb_explode() {
	// Detonate.
	EntFireByHandle(self, "SilentDissolve", "", 0.10, self, self);
	
	// Grab our particle systems by looping through children.
	
	local part = self.FirstMoveChild()
	while(part) {
		if (part.GetClassname() == "info_particle_system") {
			EntFireByHandle(part, "ClearParent", "", 0.00, self, self);
			EntFireByHandle(part, "Start", "", 0, self, self);
			EntFireByHandle(part, "Kill", "", 2.00, self, self);
			part.SetAngles(0, 0, 0)
		} else if (part.GetClassname() == "env_explosion") {
			EntFireByHandle(part, "Explode", "", 0.00, self, self);
		}
		part = part.NextMovePeer()
	}
	
	
	// Look for turrets within about a block, and ignite them directly
	local origin = self.GetOrigin()
	local turr = Entities.FindByClassnameWithin(null, "npc_portal_turret_floor", origin, 128)
	while(turr) {
		EntFireByHandle(turr, "SelfDestructImmediately", "", 0.1, null, null);
		turr = Entities.FindByClassnameWithin(turr, "npc_portal_turret_floor", origin, 128)
	}
}

function _on_pickup() {
	if (cube_bomb_mode == CUBE_BOMB_WAITING) {
		cube_bomb_mode = CUBE_BOMB_HELD;
		self.EmitSound("World.RobotNegInteract")
	} else if (cube_bomb_mode == CUBE_BOMB_ARMED) {
		if (Time() - arm_time < 0.25) {
			// Disarm the bomb.
			// Block our activation sound.
			self.EmitSound("Default.Null")
			cube_bomb_mode = CUBE_BOMB_HELD
			arm_time = -1;
			det_time = -1;
		}
	}
}

function _on_drop() {
	// If we fizzle...
	if (!self.IsValid()) {return}
	
	if (cube_bomb_mode == CUBE_BOMB_HELD) {
		arm();
	}
}
