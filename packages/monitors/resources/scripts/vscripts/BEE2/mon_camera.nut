// Cycles through active cameras.
// Values set by generated entity script called 
// before this executes: 
// CAM_NUM = int (Number of cameras in the map)
// CAM_ACTIVE = [bool] (For each camera, if it starts on/is on)
// CAM_ACTIVE_NUM = int (Total number of enabled cams)
// CAM_LOC = [Vector] (For each camera, the location it is at)
// CAM_ANGLES = [Vector] (For each camera, the pitch, yaw, and zero roll)
// CAM_STUDIO_CHANCE = float (If -1, other studio values are undefined..)
// CAM_STUDIO_LOC = Vector (Location of studio, for the voiceline)
// CAM_STUDIO_PITCH = float
// CAM_STUDIO_YAW = float
// This is also always defined
// CAM_STUDIO_TURRET = bool (If true, an ai_relationship should make turrets shoot.)

cur_ind <- 0;
is_studio <- 0;

function CamToggle(index) {
	// Unused, for old logic.
	if (CAM_ACTIVE[index]) {
		CamDisable(index);
	} else {
		CamEnable(index);
	}
}

function CamDisable(index) {
	if (!CAM_ACTIVE[index]) {
		return;
	}
	CAM_ACTIVE[index] = 0;
	CAM_ACTIVE_NUM--;
	if(CAM_ACTIVE_NUM == 0) {
		if(CAM_STUDIO_CHANCE == -1) {
			// No cameras at all, blank the screen.
			// Teleport to arrival_departure_transition_ents...
			// That has a toolsblack surface.
			self.SetAbsOrigin(Vector(-2500, -2500, 0));
			self.SetAngles(0, 90, 0);
		} else {
			// We have a studio, just display that.
			set_camera_studio();
		}
	}
}

function CamEnable(index) {
	if (CAM_ACTIVE[index]) {
		return;
	}
	CAM_ACTIVE[index] = 1;
	CAM_ACTIVE_NUM++;
	// Skip to that camera.
	cur_ind = index;
	set_camera();
}

function Think() {
	// Return 2.0 = run every 2 seconds.
	if (CAM_ACTIVE_NUM == 0) {
		// No active cameras to switch, we're already at the target location.
		return 2.0;
	}
	
	// Don't allow interrupting twice..
	if (is_studio == 0 && CAM_STUDIO_CHANCE > 0) {
		if (CAM_STUDIO_CHANCE >= RandomFloat(0, 100)) {
			// Interupt the normal monitor with the voice character..
			set_camera_studio();
			return 2.0;
		}
	}
	
	
	// Limit the number of jumps to the number of cameras...
	for(local i = 0; i < CAM_NUM; i++) {
		cur_ind++;
		if (cur_ind == CAM_NUM) {
			// Just loop around..
			cur_ind = 0;
		}
		if(CAM_ACTIVE[cur_ind]) {
			// Skip inactive cameras..
			set_camera();
			return 2.0;
		}
	}
	
	return 2.0;
}

function set_camera() {
	self.SetAbsOrigin(CAM_LOC[cur_ind]);
	local ang = CAM_ANGLES[cur_ind];
	self.SetAngles(ang.x, ang.y, 0);
	is_studio = 0;
	if (CAM_STUDIO_TURRET) {
		EntFire("@monitor_turr_hate", "RevertToDefaultRelationship", "", 0);
	}
}

function set_camera_studio() {
	self.SetAbsOrigin(CAM_STUDIO_LOC);
	self.SetAngles(CAM_STUDIO_PITCH, CAM_STUDIO_YAW, 0);
	is_studio = 1;
	if (CAM_STUDIO_TURRET) {
		EntFire("@monitor_turr_hate", "ApplyRelationship", "", 0);
	}
}
