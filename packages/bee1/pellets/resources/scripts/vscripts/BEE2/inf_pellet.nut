cur_pellet <- null; // The pellet entity.
waiting_for_pellet <- false; // Are we waiting for it to spawn and be detected?
is_on <- false; // Current input state.
// respawn: If the pellet should be replaced when killed while input is on.

function pellet_launched() {
	// If we have a pellet, kill it.
	kill_pellet();
	
	// Find the new one...
	local pellet = null;
	while(1) {
		pellet = Entities.FindByClassnameWithin(pellet, "prop_energy_ball", self.GetOrigin(), 16);
		if (pellet == null) {
			// Didn't find it..
			return
		}
		if (pellet.GetClassname() == "bee_exp_pellet") {
			// One of ours already detonating...
			continue;
		}
		cur_pellet = pellet;
		break;
	}
	
	waiting_for_pellet = false;
	
	if(!is_on) {
		// We spawned, but disabled in the time - kill it.
		kill_pellet();
	} else {
		
		// Fire a user output with the pellet as an !activator (for overgrown particles).
		EntFireByHandle(self, "FireUser2", "", 0.0, self, cur_pellet);
	}
}

self.ConnectOutput("OnPostSpawnBall", "pellet_launched")

function launch_pellet() {
	EntFireByHandle(self, "LaunchBall", "", 0.0, self, self);
	waiting_for_pellet = true;
}

function inp_on() {
	is_on = true;
	if (!waiting_for_pellet) {
		launch_pellet();
	}
}

function inp_off() {
	is_on = false;
	kill_pellet();
}

function kill_pellet() {
	// Ignore if the pellet doesn't exist...
	if(cur_pellet != null && cur_pellet.IsValid()) {
		// "Change" it to a different classname, so our search don't find these.
		// It still exists for some time (for FX), and our actual triggers use 
		// direct casts to check so that's safe.
		// Reloading from saves will not spawn this correctly, but that's not too important.
		EntFireByHandle(cur_pellet, "AddOutput", "classname bee_exp_pellet", 0.0, self, self);
		EntFireByHandle(cur_pellet, "Explode", "", 0.0, self, self);
		cur_pellet = null;
	}
}

function Think() {
	// Check to see if the pellet has been destroyed..
	if(cur_pellet != null && !cur_pellet.IsValid()) {
		EntFireByHandle(self, "FireUser1", "", 0.0, self, self);
		cur_pellet = null;
		
		if (is_on && respawn) {
			launch_pellet();
		}
	}
	
	// Re-run only every second, that's sufficent..
	return 1;
}
