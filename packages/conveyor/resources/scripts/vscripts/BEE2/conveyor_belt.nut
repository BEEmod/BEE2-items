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
anim_speed <- 1;

pos_start <- self.GetOrigin()
pos_end <- null
forw <- self.GetLeftVector() * -1;
back <- self.GetLeftVector();

is_enabled <- false;
was_enabled <- false;
is_reversed <- false;
was_reversed <- false;

is_static <- false;

// Remove anims from the end.
inst_name <- self.GetName().slice(0, -5);

function by_name(_name, _prev = null) {
	return Entities.FindByName(_prev, _name);
}

function local_name(_add = "") {
	return inst_name + _add;
}

brush_search <- local_name("*-brush");

trigger_push <- by_name(local_name("push"));
trigger_pass_start <- by_name(local_name("end_trig_start"));
trigger_pass_end <- by_name(local_name("end_trig_end"));

fx_source <- by_name(local_name("fx_source"));
fx_move <- by_name(local_name("fx_move"));
fx_move_is_playing <- false;
fx_start <- by_name(local_name("fx_start"));
fx_reverse <- by_name(local_name("fx_reverse"));
fx_stop <- by_name(local_name("fx_stop")) ;

bounds <- {}

function init(_type, _size, _start_enabled, _start_reversed, _speed, _angle_fixup) {
	belt_size = _size;
	is_enabled = _start_enabled;
	is_reversed = _start_reversed;
	anim_speed = _speed;
	is_static = anim_speed <= 0;

	pos_end = pos_start + (forw * ((belt_size + 3) * 128))

	bounds = vec_bounds(pos_start, pos_end);

	if (trigger_pass_start != null) {
		EntFireByHandle(trigger_pass_start, "AddOutput", "OnStartTouch " + self.GetName() + ":RunScriptCode:onPass(0)::", 0.0, self, self);
	}
	if (trigger_pass_end != null) {
		EntFireByHandle(trigger_pass_end, "AddOutput", "OnStartTouch " + self.GetName() + ":RunScriptCode:onPass(1)::", 0.0, self, self);
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
				EntFireByHandle(ent, "SetLocalAngles", _angle_fixup, 0.0, self, self);
			}
		}
	}

	local anim = null;
	if (is_static) {
		anim = "idle_" + (belt_size * 128).tostring();
	} else {
		anim = "move_" + (belt_size * 128).tostring();
	}

	EntFireByHandle(self, "SetDefaultAnimation", anim, 0.0, self, self);
	EntFireByHandle(self, "SetAnimation", anim, 0.0, self, self);
	EntFireByHandle(self, "SetPlaybackRate", "0", 0.0, self, self);

	//update_movement(true);
}

function Think() {
	if (IsMultiplayer()) {return 9999999999}

	if (!is_enabled) {return 1;}

	if (GetPlayer()) {
		fx_source.SetOrigin(vec_clamp(GetPlayer().EyePosition(), bounds.min, bounds.max));
	} else {
		//printl("No player found")
		return 30;
	}

	return 0.1;
}

function update_movement(silent = false) {
	if (is_static) {return;}

	// Check if nothing changed
	if (is_enabled == was_enabled && is_reversed == was_reversed) {return;}

	if (!is_enabled) { // Stop moving
		if (!silent) {
			EntFireByHandle(fx_stop, "PlaySound", "", 0.0, self, self);
		}
		if (fx_move_is_playing) {
			EntFireByHandle(fx_move, "StopSound", "", 0.0, self, self);
			fx_move_is_playing = false;
		}
		movement_stop();
		was_enabled = false;
		return;
	}
	else {
		if (!was_enabled) {
			if (!silent) {
				EntFireByHandle(fx_start, "PlaySound", "", 0.0, self, self);
			}
			if (!fx_move_is_playing) {
				EntFireByHandle(fx_move, "PlaySound", "", 0.0, self, self);
				fx_move_is_playing = true;
			}
			if (trigger_push != null) {
				EntFireByHandle(trigger_push, "Enable", "", 0.0, self, self);
			}
		}
		else if (is_reversed != was_reversed && !silent) {
			EntFireByHandle(fx_reverse, "PlaySound", "", 0.0, self, self);
		}

		if (!is_reversed) {
			movement_forward();
			was_reversed = false;
		}
		else {
			movement_reverse();
			was_reversed = true;
		}
		was_enabled = true;
	}
}

function movement_forward() {
	EntFireByHandle(self, "SetPlaybackRate", (anim_speed).tostring(), 0.0, self, self);
	if (trigger_push != null) {
		EntFireByHandle(trigger_push, "AddOutput", "pushdir " + forw.ToKVString(), 0.0, self, self);
	}
	EntFireByHandle(trigger_pass_start, "Disable", "", 0.0, self, self);
	EntFireByHandle(trigger_pass_end, "Enable", "", 0.0, self, self);
}

function movement_reverse() {
	EntFireByHandle(self, "SetPlaybackRate", (-anim_speed).tostring(), 0.0, self, self);

	if (trigger_push != null) {
		EntFireByHandle(trigger_push, "AddOutput", "pushdir " + back.ToKVString(), 0.0, self, self);
	}

	EntFireByHandle(trigger_pass_end, "Disable", "", 0.0, self, self);
	EntFireByHandle(trigger_pass_start, "Enable", "", 0.0, self, self);
}

function movement_stop() {
	// Make sure we're not triggering this when it was already stopped.
	if (trigger_push != null) {
		EntFireByHandle(trigger_push, "Disable", "", 0.0, self, self);
	}
	EntFireByHandle(self, "SetPlaybackRate", "0", 0.0, self, self);
	EntFireByHandle(trigger_pass_end, "Disable", "", 0.0, self, self);
	EntFireByHandle(trigger_pass_start, "Disable", "", 0.0, self, self);
}

function onPass(loc) {
	//printl(activator.GetName() + " has passed " + self.GetName() + " at " + loc.tostring());
	local reset_time = 0.5/anim_speed;

	//EntFireByHandle(activator, "RemovePaint", "", 0.0, self, self);
	EntFireByHandle(activator, "Disable", "", 0.0, self, self);
	EntFireByHandle(activator, "Enable", "", reset_time, self, self);

	// For some reason finding by parent doesn't work so we'll just search for them.
	local child = by_name(activator.GetName() + "_*");

	while (child) {
		EntFireByHandle(child, "Disable", "", 0.0, self, self);
		EntFireByHandle(child, "Enable", "", reset_time, self, self);
		child = by_name(activator.GetName() + "_*", child);
	}
}

function start() {
	if (was_enabled) {return;}

	is_enabled = true;
	update_movement();
}

function stop() {
	if (!was_enabled) {return;}

	is_enabled = false;
	update_movement();
}

function forward() {
	is_reversed = false;
	if (!is_enabled) {return;}
	update_movement();
}

function reverse() {
	is_reversed = true;
	if (!is_enabled) {return;}
	update_movement();
}

function vec_bounds(pos1, pos2) {

	local _x = [pos1.x, pos2.x];
	local _y = [pos1.y, pos2.y];
	local _z = [pos1.z, pos2.z];

	_x.sort();
	_y.sort();
	_z.sort();

	local _min = Vector(_x[0], _y[0], _z[0]);
	local _max = Vector(_x[1], _y[1], _z[1]);

	return { min = _min, max = _max};
}

function vec_clamp(val, min_, max_) {
	return Vector((val.x < min_.x) ? min_.x : (val.x > max_.x) ? max_.x : val.x,
				  (val.y < min_.y) ? min_.y : (val.y > max_.y) ? max_.y : val.y,
				  (val.z < min_.z) ? min_.z : (val.z > max_.z) ? max_.z : val.z);
}