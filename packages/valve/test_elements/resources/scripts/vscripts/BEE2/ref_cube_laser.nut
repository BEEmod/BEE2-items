// Turn off reflection cube lasers when they settle, or move too far.
drop_loc <- null;
last_loc <- Vector(-100, -100, -100);
spr <- null;

function pickup() {
    drop_loc = null;
    EntFireByHandle(self, "FireUser2", "", 0, self, self);
}

function settle() {
	drop_loc = self.GetMoveParent().GetOrigin();
	_check();
}

function _check() {
	if (drop_loc == null) {
		return;
	}

	// Physics objects don't let you check velocity directly,
	// so compare to last frame.
	local cube_loc = self.GetMoveParent().GetOrigin();

	// Settled, or moved too far away.
	if ((cube_loc - last_loc).LengthSqr() < 1 || 
	    (cube_loc - drop_loc).LengthSqr() > 400 // 20^2
	   ) {
    	EntFireByHandle(self, "FireUser1", "", 0, self, self);
    	drop_loc = null;
	} else {
		last_loc = cube_loc;
		EntFireByHandle(self, "CallScriptFunction", "_check", 0.1, self, self);
	}
}
