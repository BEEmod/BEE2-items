// Block +USE and therefore pickup if the player is on the other side of grating.
block_grab_holder <- null;

function OnPostSpawn() {
	self.ConnectOutput("OnPlayerPickup", "BlockGrabPickup");
	self.ConnectOutput("OnPhysGunDrop", "BlockGrabDrop");
}

function InputUse() {
	local player = activator;
	local trace;
	if (player.GetClassname() != "player") {
		return true; // ??
	}
	local player_pos = player.GetOrigin();
	player_pos.z += 32; // Not eye pos, about halfway where cubes are held.
	if (block_grab_holder != null) {
		// We're held, check the player too  to prevent
		// them pushing the cube through.
		local other_player = block_grab_holder.GetOrigin();
		other_player.z += 32;
		trace = ::BEE_TraceRay(player_pos, other_player - player_pos, ::BEECollide.GRATING)
		if (trace != null) {
			return false;
		}
	}
	local trace = ::BEE_TraceRay(player_pos, self.GetOrigin() - player_pos, ::BEECollide.GRATING);
	return trace == null;
}

function BlockGrabPickup() {
	block_grab_holder = activator;
}

function BlockGrabDrop() {
	block_grab_holder = null;
}
