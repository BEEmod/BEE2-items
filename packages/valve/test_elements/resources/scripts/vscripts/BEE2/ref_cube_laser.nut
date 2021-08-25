// Handles reflection cube lasers.
// The laser is turned off after dropping, when it settles, or moves too far.
// This is the beam entity, so the parent is the cube.

drop_loc <- null;
last_loc <- Vector(-100, -100, -100);
TRACE_DIST <- 2048;

state <- 0;

// A relay or catcher.
class LaserTarget {
	ent = null; // Relay or catcher ent.
	attach = 0; // Attachment point index.
	targ = null; // The point_laser_target which does detection.
	hit_count = 0; // Number of cubes for deduplication.
	spr = null; // Sprite we placed.
	constructor (las_ent) {
		ent = las_ent;
		hit_count = 0;
		spr = null;
		local child = las_ent.FirstMoveChild();
		while(child) {
			if (child.GetClassname() == "point_laser_target") {
				targ = child;
			} else if (child.GetName() == "@cube_laser_target") {
			    spr = child;
			    EntFireByHandle(spr, "SetParentAttachment", "laser_target", 0.0, las_ent, las_ent);
			}
			child = child.NextMovePeer();
		}
	}
	function _tostring() { return tostring() }
	function tostring() {
	    return "<Catcher \"" + ent.GetName() + "\">";
	}
}


function OnPostSpawn() {
	// We can probably assume there aren't going to be any relays/catchers spawning in/dying.
	local ent = null;
	if (!("laser_relay_catcher_list" in getroottable())) {
		::laser_relay_catcher_list <- [];
		while(ent = Entities.FindByClassname(ent, "prop_laser_catcher")) {
			::laser_relay_catcher_list.append(LaserTarget(ent));
		}
		ent = null;
		while(ent = Entities.FindByClassname(ent, "prop_laser_relay")) {
			::laser_relay_catcher_list.append(LaserTarget(ent));
		}
	}
}


function pickup() {
    drop_loc = null;
    EntFireByHandle(self, "FireUser2", "", 0, self, self);
    self.__KeyValueFromString("thinkfunction", "heldThink");
}

function dropped() {
	drop_loc = self.GetMoveParent().GetOrigin();
    self.__KeyValueFromString("thinkfunction", "settleThink");
}

// Reset our lasers.
function fizzled() {

}

// Sitting, not doing anything.
function inactiveThink() {
	// Avoid thinking on the same frame.
	return RandomFloat(0.5, 1.5);
}

// From https://gamemath.com/book/geomtests.html#intersection_ray_aabb
function rayIntersect(start, delta, min, max) {
	local inside = true;
	local xt, yt, zt, xn, yn, zn, x, y, z;

    if (start.x < min.x) {
        xt = min.x - start.x;
        if (xt > delta.x) return false;
        xt /= delta.x;
        inside = false;
        xn = -1.0;
    } else if (start.x > max.x) {
        xt = max.x - start.x;
        if (xt < delta.x) return false;
        xt /= delta.x;
        inside = false;
        xn = 1.0;
    } else {
        xt = -1.0;
    }

    if (start.y < min.y) {
        yt = min.y - start.y;
        if (yt > delta.y) return false;
        yt /= delta.y;
        inside = false;
        yn = -1.0;
    } else if (start.y > max.y) {
        yt = max.y - start.y;
        if (yt < delta.y) return false;
        yt /= delta.y;
        inside = false;
        yn = 1.0;
    } else {
        yt = -1.0;
    }

    if (start.z < min.z) {
        zt = min.z - start.z;
        if (zt > delta.z) return false;
        zt /= delta.z;
        inside = false;
        zn = -1.0;
    } else if (start.z > max.z) {
        zt = max.z - start.z;
        if (zt < delta.z) return false;
        zt /= delta.z;
        inside = false;
        zn = 1.0;
    } else {
        zt = -1.0;
    }

    // Ray origin inside box?
    if (inside) {
        return true;
    }

    // Select farthest plane - this is
    // the plane of intersection.
    local which = 0;
    local t = xt;
    if (yt > t) {
        which = 1;
        t = yt;
    }
    if (zt > t) {
        which = 2;
        t = zt;
    }
    switch (which) {
        case 0: // intersect with yz plane
        {
            y = start.y + delta.y*t;
            if (y < min.y || y > max.y) return false;
            z = start.z + delta.z*t;
            if (z < min.z || z > max.z) return false;
            return true
        } break;

        case 1: // intersect with xz plane
        {
            x = start.x + delta.x*t;
            if (x < min.x || x > max.x) return false;
            z = start.z + delta.z*t;
            if (z < min.z || z > max.z) return false;

            return true;

        } break;

        case 2: // intersect with xy plane
        {
            x = start.x + delta.x*t;
            if (x < min.x || x > max.x) return false;
            y = start.y + delta.y*t;
            if (y < min.y || y > max.y) return false;

            return true;

        } break;
    }
}

// Held by player, check for laser ents.
function heldThink() {
	local cube = self.GetMoveParent();
	local origin = cube.GetOrigin();
	local forward = cube.GetForwardVector();
	local end = origin + forward * TRACE_DIST;

	local frac = TraceLine(origin, end, cube);
	local delta = forward * (frac * TRACE_DIST);
	local hit = origin + delta;

	foreach (idx, target in ::laser_relay_catcher_list) {
		local mins = target.targ.GetBoundingMins();
		local maxs = target.targ.GetBoundingMaxs();
		local pos = target.targ.GetOrigin();
		local intersect = rayIntersect(origin - pos, delta, mins, maxs);
		if (intersect) {
			EntFireByHandle(target.spr, "ShowSprite", "", 0.0, cube, self);
		} else { //if (target.spr != null) {
			EntFireByHandle(target.spr, "HideSprite", "", 0.0, cube, self);
		}
	}
	return 0.01; // Important, update quickly.
}

// Dropped, keep laser on until it fully stops.
function settleThink() {
	// Physics objects don't let you check velocity directly,
	// so compare to last frame.
	local cube_loc = self.GetMoveParent().GetOrigin();

	// Settled, or moved too far away.
	if ((cube_loc - last_loc).LengthSqr() < 1 || 
	    (cube_loc - drop_loc).LengthSqr() > 400 // 20^2
	   ) {
    	EntFireByHandle(self, "FireUser1", "", 0, self, self);
    	drop_loc = null;
    	self.__KeyValueFromString("thinkfunction", "inactiveThink");
    	return 0.5;
	} else {
		last_loc = cube_loc;
		return 0.1;
	}
}
