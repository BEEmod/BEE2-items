mat_mod <- null;
// Bodygroups:
// 0: slice_solid_ref
// 1: slice1_ref
// 2: slice2_ref
// 3: slice3_ref
// 4: slice4_ref
// 5: slice5_ref
// 6: slice6_ref
// 7: slice7_ref
// 8: slice8_ref
// 9: slice_fade_ref
// 10: Blank

next_beat <- -1;
slice_interval <- 0.0;
cur_slices <- 0;
desired_slices <- 0;
direction <- -1;

function SetSliceGroup(ind) {
	self.SetBodygroup(1, ind);
}

function OnPostSpawn() {
	local ent = self.FirstMoveChild();
	while (ent) {
		if (ent.GetClassname() == "material_modify_control") {
			mat_mod = ent;
			break;
		}
		ent = ent.NextMovePeer();
	}
}

// Iterate the slices.
function Beat() {
	if (next_beat < 0.0 || next_beat > Time()) {
		return; // Too early for this.
	}
	// printl("Beat: cur=" + cur_slices + ", dir=" + direction + ", desired=" + desired_slices);
	cur_slices += direction;
	if ((direction == -1 && cur_slices <= desired_slices) || (direction == 1 && cur_slices >= desired_slices)) {
		SetSliceGroup(cur_slices == 8 ? 0: 10);
		cur_slices = desired_slices;
		return;
	}
	SetSliceGroup(1 + cur_slices);
	EntFireByHandle(mat_mod, "StartFloatLerp", (direction > 0 ? "0 1 " : "1 0 ") + slice_interval.tostring() + " 0", 0.0, self, self);
	next_beat = Time() + slice_interval - 0.1;
	EntFireByHandle(self, "CallScriptFunction", "Beat", slice_interval, self, self);
}

function CountUp(total_time) {
	cur_slices = 0;
	desired_slices = 8;
	direction = 1;
	slice_interval = total_time / 8.0;
	next_beat = 0.0;
	Beat();
}

function CountDown(total_time) {
	cur_slices = 8;
	desired_slices = 0;
	direction = -1;
	slice_interval = total_time / 8.0;
	next_beat = 0.0;
	Beat();
}

function Stop(full) {
	if (cur_slices != desired_slices) {
		cur_slices = desired_slices = direction > 0 ? 0 : 8;
		SetSliceGroup(cur_slices == 8 ? 0: 10);
		next_beat = -1.0;
	}
}

function SetFull() {
	if (cur_slices <= 4) {
		// If we've got only a few slices, fade to full.
		// 0.25s is the same as the regular timer reset once it's complete.
		SetSliceGroup(9);
		EntFireByHandle(mat_mod, "StartFloatLerp", "0 1 0.25 0", 0.0, self, self);
	} else { 
		// In the middle of an animation, snap to.
		SetSliceGroup(0);
	}
	cur_slices = desired_slices = 8;
	next_beat = -1.0;
}

function SetEmpty() {
	if (cur_slices >= 5 ) {
		SetSliceGroup(9);
		EntFireByHandle(mat_mod, "StartFloatLerp", "1 0 0.25 0", 0.0, self, self);
	} else {
		SetSliceGroup(10);
	}
	cur_slices = desired_slices = 0;
	next_beat = -1.0;
}
