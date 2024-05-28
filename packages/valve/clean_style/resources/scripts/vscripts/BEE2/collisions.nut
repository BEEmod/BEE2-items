// Provides an interface to allow querying BEE's collision data.

::BEECollide <- {
	// Must match Python constants!
	NOTHING = 0,
    SOLID = 1,
    DECORATION = 2,
    GRATING = 4, 
    GLASS = 8, 
    BRIDGE = 16,
    FIZZLER = 32,
    TEMPORARY = 64,
    ANTLINES = 128,
    OOB = 256,
}

class Plane {
	norm = null;
	dist = 0.0;
	constructor(x, y, z, distance) {
		norm = Vector(x, y, z);
		dist = distance;
	}
}

class Volume {
	mins = null;
	maxes = null;
	planes = null; // List of planes
	constructor(min_x, min_y, min_z, max_x, max_y, max_z, plane_list) {
		mins = Vector(min_x, min_y, min_z);
		maxes = Vector(max_x, max_y, max_z);
		planes = plane_list;
	}

	function point_inside(point, tol) {
		if (point.x < mins.x - tol || point.x > maxes.x + tol) {
			return false;
		}
		if (point.y < mins.y - tol || point.y > maxes.y + tol) {
			return false;
		}
		if (point.z < mins.z - tol || point.z > maxes.z + tol) {
			return false;
		}
		if (planes == null) {
			return true;
		}
		foreach(plane in planes) {
			if (plane.norm.Dot(point) < plane.dist + tol) {
				return false;
			}
		}
		return true;
	}
}

class Entry {
	mask = 0;
	volumes = null;
	constructor(m, v) {
		mask = m;
		volumes = v;
	}
}

function point_collide(point, mask, tolerance) {
	foreach(entry in VOLUMES) {
		if ((entry.mask & mask) == 0) {
			continue;
		}
		foreach(volume in entry.volumes) {
			local center = (volume.mins + volume.maxes) * 0.5;
			if (volume.point_inside(point, tolerance)) {
				return true;
			}
		}
	}
	return false;
}


::BEE_PointCollide <- point_collide.bindenv(this);

function Display() {
	printl("Dump collisions:")
	foreach(entry in VOLUMES) {
		printl("- " + entry.mask + " = [");
		foreach(volume in entry.volumes) {
			local center = (volume.mins + volume.maxes) * 0.5;
			DebugDrawBox(center, volume.mins - center, volume.maxes - center, 255, 128, 64, 255, 1);
			printl("    center=" + center + ", " + (volume.mins - center) + " <-> " + (volume.maxes - center));
		}
	}
}
