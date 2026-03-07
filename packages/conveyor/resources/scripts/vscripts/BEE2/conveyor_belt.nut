// Globals:
//	- belt_size: int = $size
//		* The size of the conveyor belt in voxels (1-25).
//	- is_enabled: bool = $start_enabled
//		* Does the conveyor belt start on?
//	- is_reversed: bool = $start_reversed
//		* Does the conveyor belt start reversed?
//	- anim_speed: float = $speed
//		* What is the start/max speed. Uses animation speed so will be 0.5 to 3.0.

//local players_touching <- {};
brushes <- {};

belt_size <- 1;
is_enabled <- false;
is_reversed <- false;
anim_speed <- 1;

// Remove anims from the end, add brush*.
brush_search <- self.GetName().slice(0, -5) + "*brush";

function init(_size, _start_enabled, _start_reversed, _speed) {
	belt_size = _size;
	is_enabled = _start_enabled;
	is_reversed = _start_reversed;
	anim_speed = _speed;

	local ent = null;
	while(ent = Entities.FindByName(ent, brush_search)) {
		local cls = ent.GetClassname();
		if (cls == "func_brush") {
			brushes[ent.entindex()] <- ent
			local ent_name = ent.GetName();
			local string_index = ent_name.find("&");
			if (string_index != null) {
				local attach_name = ent_name.slice(string_index+1, -6) + "_attach";
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

	update_movement();
}

//function Think() {
	// foreach (id, player in players_touching)
	// {
	// 	//printl("player found!");
	// 	player.SetVelocity(add_velocity(player.GetVelocity(), self.GetLeftVector() * -128));
	// }

	//foreach (id, brush in brushes)
	//{
	//	if (reversed){
	//		brush.SetVelocity(self.GetLeftVector() * 128);
	//	}
	//	else {
	//		brush.SetVelocity(self.GetLeftVector() * -128);
	//	}
	//}
//	return 0.1;
//}

function update_movement() {
	if (is_enabled) {
		if (is_reversed) {
			EntFireByHandle(self, "SetPlaybackRate", (-anim_speed).tostring(), 0.0, self, self);
		}
		else {
			EntFireByHandle(self, "SetPlaybackRate", (anim_speed).tostring(), 0.0, self, self);
		}
	}
	else {
		EntFireByHandle(self, "SetPlaybackRate", (0).tostring(), 0.0, self, self);
	}
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

//function start_touch() {
//	players_touching[activator.entindex()] <- activator;
//}

//function end_touch() {
//	local player_ent = activator.entindex();
//	if (!(player_ent in players_touching)) {
//		printl("Exited trigger but didn't enter??");
//		return;
//	}
//	delete players_touching[activator.entindex()];
//}

//function add_velocity(start_vel, add_vel) {
//	local velocity = start_vel + add_vel;
//	return velocity;
//}