// Randomly sparks within a rectangular region.

start_pos <- off_side <- off_down <- null;
max_side <- max_down <- 0;

function set_pos(wid, height) {
	max_side = wid;
	max_down = height;
	start_pos = self.GetOrigin();
	off_down = self.GetLeftVector(); // Green-direction normal vector..
	off_side = self.GetUpVector(); // Blue-direction normal vector..
}
set_pos(92, 188); // In case lasers trigger before it opens..

function spark() {
	do_sp();
	EntFireByHandle(self, "CallScriptFunction", "do_sp", RandomFloat(0.01, 0.3), self, self);
	EntFireByHandle(self, "CallScriptFunction", "do_sp", RandomFloat(0.31, 0.6), self, self);
}

function do_sp() {
	local loc = Vector(start_pos.x, start_pos.y, start_pos.z);
	// Move this far along in the two directions, locally.
	local down = -RandomInt(0, max_down);
	local side = RandomInt(0, max_side);
	loc.x += off_down.x * down + off_side.x * side;
	loc.y += off_down.y * down + off_side.y * side;
	loc.z += off_down.z * down + off_side.z * side;
	self.SetAbsOrigin(loc);
	EntFireByHandle(self, "SparkOnce", "", 0.0, self, self);
}

// When broken, randomly spark every few seconds.
function screen_broken() {
	spark();
	EntFireByHandle(self, "CallScriptFunction", "screen_broken", RandomFloat(3, 8), self, self);
}