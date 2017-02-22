cur_pellet <- null;
manager <- Entities.FindByName(null, self.GetName().slice(0, -8) + "man");

function pellet_launched() {
	// If we have a pellet, kill it.
	kill_pellet();
	
	// Find the new one...
	cur_pellet = Entities.FindByClassnameNearest("prop_energy_ball", self.GetOrigin(), 16);
	
	// Fire a user output with the pellet as an !activator (for overgrown particles).
	EntFireByHandle(self, "FireUser2", "", 0.0, self, cur_pellet);
	
	// Allow the manager to deactivate itself and kill the pellet now.
	EntFireByHandle(manager, "SetStateBFalse", "", 0.0, self, self);
}

self.ConnectOutput("OnPostSpawnBall", "pellet_launched");

function kill_pellet() {
	// Ignore if the pellet doesn't exist...
	if(cur_pellet != null && cur_pellet.IsValid()) {
		EntFireByHandle(cur_pellet, "Explode", "", 0.0, self, self);
		cur_pellet = null;
	}
}

function Think() {
	// Check to see if the pellet has been destroyed..
	if(cur_pellet != null && !cur_pellet.IsValid()) {
		EntFireByHandle(self, "FireUser1", "", 0.0, self, self);
		cur_pellet = null;
	}
	
	// Re-run only every second, that's sufficent..
	return 1;
}
