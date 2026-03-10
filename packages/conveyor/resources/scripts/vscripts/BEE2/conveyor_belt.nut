// Globals:
//	- belt_size: int = $size
//		* The size of the conveyor belt in voxels (1-25).
//	- is_enabled: bool = $start_enabled
//		* Does the conveyor belt start on?
//	- is_reversed: bool = $start_reversed
//		* Does the conveyor belt start reversed?
//	- anim_speed: float = $speed
//		* What is the start/max speed. Uses animation speed so will be 0.5 to 3.0.

belt_size <- 1;
is_enabled <- false;
was_enabled <- false;
is_reversed <- false;
was_reversed <- false;
anim_speed <- 1;

// Remove anims from the end.
inst_name <- self.GetName().slice(0, -5);

brush_search <- inst_name + "*-segment*-brush";
brush_fx_search <- inst_name + "*-segment*-fx";

push_trigger_name <- inst_name + "push";
push_trigger <- null;

pass_trigger_name <- inst_name + "trig_pass";
pass_trigger_start <- null;
pass_trigger_end <- null;

forw <- self.GetLeftVector() * -1;
back <- self.GetLeftVector();

// Set by comp_scriptvar_setter
//const SOUND_START = "BEE2.ConveyorBelt.Start";
//const SOUND_REVERSE = "BEE2.ConveyorBelt.Reverse";
//const SOUND_STOP = "BEE2.ConveyorBelt.Stop";

// Precached by comp_precache_sound
//function Precache() {
//	self.PrecacheSoundScript(SOUND_START);
//	self.PrecacheSoundScript(SOUND_REVERSE);
//	self.PrecacheSoundScript(SOUND_STOP);
//	printl("Precached sounds for " + inst_name);
//}

function init(_size, _start_enabled, _start_reversed, _speed) {
	belt_size = _size;
	is_enabled = _start_enabled;
	is_reversed = _start_reversed;
	anim_speed = _speed;

	push_trigger = Entities.FindByName(null, push_trigger_name);
	pass_trigger_start = Entities.FindByNameNearest(pass_trigger_name, self.GetOrigin() + (back * 56), 16);
	pass_trigger_end = Entities.FindByNameNearest(pass_trigger_name, self.GetOrigin() + (forw * (((belt_size + 3) * 128) + 56)), 16);

	if (pass_trigger_start != null) {
		EntFireByHandle(pass_trigger_start, "AddOutput", "OnStartTouch " + self.GetName() + ":RunScriptCode:onPass(0)::", 0.0, self, self);
	}
	if (pass_trigger_end != null) {
		EntFireByHandle(pass_trigger_end, "AddOutput", "OnStartTouch " + self.GetName() + ":RunScriptCode:onPass(1)::", 0.0, self, self);
	}

	local ent = null;
	while(ent = Entities.FindByName(ent, brush_search)) {
		local cls = ent.GetClassname();
		if (cls == "func_brush") {
			local ent_name = ent.GetName();
			local string_index = ent_name.find("segment");
			if (string_index != null) {
				local attach_name = ent_name.slice(string_index, -6) + "_attach";
				EntFireByHandle(ent, "SetParent", self.GetName(), 0.0, self, self);
				EntFireByHandle(ent, "SetParentAttachment", attach_name, 0.0, self, self);
			}
			else {
				printl("No & in " + ent_name);
			}
		}
	}

	local anim_move = "move_" + (belt_size * 128).tostring();

	EntFireByHandle(self, "SetDefaultAnimation", anim_move, 0.0, self, self);
	EntFireByHandle(self, "SetAnimation", anim_move, 0.0, self, self);

	update_movement(true);
}

function update_movement(init = false) {
	if (is_enabled) {
		// Make sure we aren't triggering these if it was already enabled.
		if (!was_enabled) {
			EntFireByHandle(push_trigger, "Enable", "", 0.0, self, self);
			if (init) {
				// Wait a second so the sound actually starts.
				EntFire(brush_fx_search, "Start", "", 1.0, self);
			}
			else {
				EntFire(brush_fx_search, "Start", "", 0.0, self);
			}
			if (!init) { // scriptvar setter is set after init
				self.EmitSound(SOUND_START);
			}
		}

		if (is_reversed) {
			EntFireByHandle(self, "SetPlaybackRate", (-anim_speed).tostring(), 0.0, self, self);
			if (push_trigger != null) {
				EntFireByHandle(push_trigger, "AddOutput", "pushdir " + back.ToKVString(), 0.0, self, self);
			}
			EntFireByHandle(pass_trigger_end, "Disable", "", 0.0, self, self);
			EntFireByHandle(pass_trigger_start, "Enable", "", 0.0, self, self);
			if (!was_reversed && was_enabled && !init) { // scriptvar setter is set after init
				self.EmitSound(SOUND_REVERSE);
			}
			was_reversed = true;
		}
		else {
			EntFireByHandle(self, "SetPlaybackRate", (anim_speed).tostring(), 0.0, self, self);
			if (push_trigger != null) {
				EntFireByHandle(push_trigger, "AddOutput", "pushdir " + forw.ToKVString(), 0.0, self, self);
			}
			EntFireByHandle(pass_trigger_start, "Disable", "", 0.0, self, self);
			EntFireByHandle(pass_trigger_end, "Enable", "", 0.0, self, self);
			if (was_reversed && was_enabled && !init) { // scriptvar setter is set after init
				self.EmitSound(SOUND_REVERSE);
			}
			was_reversed = false;
		}
		was_enabled = true;
	}
	else {
		// Make sure we're not triggering this when it was already stopped.
		if (was_enabled || init) {
			if (push_trigger != null) {
				EntFireByHandle(push_trigger, "Disable", "", 0.0, self, self);
			}
			EntFireByHandle(self, "SetPlaybackRate", (0).tostring(), 0.0, self, self);
			EntFireByHandle(pass_trigger_end, "Disable", "", 0.0, self, self);
			EntFireByHandle(pass_trigger_start, "Disable", "", 0.0, self, self);
			EntFire(brush_fx_search, "Stop", "", 0.0, self);
			if (!init) { // scriptvar setter is set after init
				self.EmitSound(SOUND_STOP);
			}
			was_enabled = false;
		}
	}
}

function onPass(loc) {
	//printl(activator.GetName() + " has passed " + self.GetName() + " at " + loc.tostring())
	local reset_time = 0.5/anim_speed

	EntFireByHandle(activator, "RemovePaint", "", 0.0, self, self);
	EntFireByHandle(activator, "Disable", "", 0.0, self, self);
	EntFireByHandle(activator, "Enable", "", reset_time, self, self);
}

function start() {
	is_enabled = true;
	update_movement();
}

function stop() {
	is_enabled = false;
	update_movement();
}

function forward() {
	is_reversed = false;
	update_movement();
}

function reverse() {
	is_reversed = true;
	update_movement();
}