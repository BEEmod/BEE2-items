// Model name to min/max pair.
// Valve's ents:
CATCHER_CENTER <- [Vector(1, -20, -20), Vector(31, 20, 20)]
CATCHER_OFFSET <- [Vector(-5, -11, -24), Vector(27, 11, -3)]
RELAY <- [Vector(-10, -10, -2), Vector(10, 10, 32.5)] // Max-Z = 32, but that doesn't get hit by center lasers.

MODEL_TO_SIZE <- {
	["models/bee2/rosemary/underground_laser_catcher_center.mdl"] = [Vector(19, -14, -14), Vector(24, 14, 14)],
	["models/bee2/rosemary/underground_laser_catcher_offset.mdl"] = [Vector(16, -9, -23), Vector(24, 9, -5)],
	["models/bee2/rosemary/underground_laser_receptacle.mdl"] = [Vector(-7, -7, 7), Vector(7, 7, 35)],
	["models/bee2/props_p1/laser_catcher.mdl"] = CATCHER_CENTER,
	["models/bee2/props_p1/laser_catcher_offset.mdl"] = CATCHER_OFFSET,
}

function OnPostSpawn() {
	local ent = null;
	while(ent = Entities.FindByClassname(ent, "prop_laser_catcher")) {
		EditCatcher(ent);
	}
	ent = null
	while(ent = Entities.FindByClassname(ent, "prop_laser_relay")) {
		EditCatcher(ent);
	}
	// Edit is permanent, us and our scope is useless then.
	EntFireByHandle(self, "Kill", "", 0.0, self, self)
}

function EditCatcher(ent) {
	if (!(ent.GetModelName() in MODEL_TO_SIZE)) {
		return; // No customisation required.
	}
	// point_laser_target is an ent at the catcher which actually detects things.
	// It uses the entity size for this, so we can just resize that.
	local pos = ent.GetOrigin()
	local attach_id = ent.LookupAttachment("laser_target")
	local targ = Entities.FindByClassnameNearest(
		"point_laser_target", 
		(attach_id != 0) ? ent.GetAttachmentOrigin(attach_id) : pos, 
		16.0
	)
	if (targ == null) {
		printl("Laser catcher/relay @ " + ent.GetOrigin() + " has no laser target?")
		return
	}
	local offset = targ.GetOrigin() - ent.GetOrigin()
	// printl("Targ: " + targ + " .parent = " + targ.GetMoveParent() + ", owner = " + targ.GetOwner())
	// printl(format("%s (%s @ %s) = (%s, %s)", 
	// 	ent.GetModelName(), ent.GetAngles().ToKVString(), pos.ToKVString(), 
	// 	(targ.GetBoundingMins() + offset).ToKVString(), 
	// 	(targ.GetBoundingMaxs() + offset).ToKVString()
	// ))
	local size = MODEL_TO_SIZE[ent.GetModelName()]
	// Transform to world coordinates.
	local X = ent.GetForwardVector()
	local Y = ent.GetLeftVector()
	local Z = ent.GetUpVector()
	local mins = pos + X * size[0].x + Y * size[0].y + Z * size[0].z
	local maxes = pos + X * size[1].x + Y * size[1].y + Z * size[1].z
	// Fix order.
	local temp;
	foreach(axis in ["x", "y", "z"]) {
		if (mins[axis] > maxes[axis]) {
			temp = maxes[axis]
			maxes[axis] = mins[axis]
			mins[axis] = temp
		}
	}
	// printl("Catcher @ " + ent.GetOrigin() + " = (" + mins + ", " + maxes + ")")
	// printl(format("Origin = %s, size = %s", ((mins + maxes) * 0.5).ToKVString(), ((maxes - mins) * 0.5).ToKVString()));

	targ.SetAbsOrigin((mins + maxes) * 0.5)
	local size = maxes - mins
	targ.SetSize(size * -0.5, size * 0.5)
}
