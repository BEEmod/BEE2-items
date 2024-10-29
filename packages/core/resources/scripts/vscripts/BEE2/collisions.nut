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
	norm = null
	dist = 0.0
	constructor(x, y, z, distance) {
		norm = Vector(x, y, z)
		dist = distance
	}
}

class Hit {
	// Represents the impact of a raytrace.
	start = null
	direction = null // Directional vector.
	distance = null // Distance from start
	impact = null // Impact point
	normal = null  // Pointing outward at the hit location.

	constructor(st, dir, imp, norm, dist) {
		start = st
		direction = dir
		distance = dist
		impact = imp
		normal = norm
	}
}

class Volume {
	mins = null
	maxes = null
	planes = null // List of planes
	constructor(min_x, min_y, min_z, max_x, max_y, max_z, plane_list) {
		mins = Vector(min_x, min_y, min_z)
		maxes = Vector(max_x, max_y, max_z)
		planes = plane_list
	}

	function point_inside(point, tol) {
		if (point.x < mins.x - tol || point.x > maxes.x + tol) {
			return false
		}
		if (point.y < mins.y - tol || point.y > maxes.y + tol) {
			return false
		}
		if (point.z < mins.z - tol || point.z > maxes.z + tol) {
			return false
		}
		if (planes == null) {
			return true
		}
		foreach(plane in planes) {
			if (plane.norm.Dot(point) < plane.dist + tol) {
				return false
			}
		}
		return true
	}

	//Trace a ray against the bbox, returning the hit, or null.
	// start: The starting point for the ray.
	// delta: Both the direction and the maximum length to check.
	function trace_ray(start, delta) {
		// First, handle bounding boxes.
		local bbox_hit = _trace_ray_bbox(start, delta)
		// If it didn't hit the bbox it can't hit the planes.
		// If we have no planes, the bbox hit is correct.
		if (bbox_hit == null || planes == null) {
			return bbox_hit
		}

		local direction = Vector(delta.x, delta.y, delta.z)
		local max_dist = direction.Norm()

		local best_hit = null
		local inside = true
		foreach (plane in planes) {
			// Check if the start point is inside the plane.
			if (start.Dot(plane.norm) < plane.dist){
				inside = false
			}
			local dot = plane.norm.Dot(direction)
			// If perpendicular or facing in the same direction, the ray can't trace into it.
			if (dot <= 0.0) {
				continue
			}
			local t = (plane.dist - start.Dot(plane.norm)) / dot
			if (
				t < 0.0 || t > max_dist ||
				(best_hit != null && t > best_hit.distance)
			) {
				// Not in bounds for the ray, or worse than our best result.
				continue
			}
			local impact = start + direction * t
			// Check this impact is actually possible.
			foreach (other_plane in planes) {
				if (other_plane == plane) {
					continue
				}
				if (impact.Dot(other_plane.norm) < other_plane.dist){
					// We're outside this plane, the impact is wrong.
					impact = null
					break
				}
			}
			if (impact != null) {  // All other plane tests succeeded.
				best_hit = Hit(
					start,
					direction,
					impact,
					plane.norm,
					t
				)
			}
		}

		if (best_hit == null && inside) {
			// The start point is inside all the planes, so we started inside.
			return Hit(
				start,
				direction,
				start,
				direction * -1,
				0.0
			)
		}
		return best_hit
	}

	// Implementation for just bounding boxes.
	function _check_plane(start, delta, axis) {
		// Determine where the intersection would be for each axial face pair.
		local time;
		if (start[axis] < mins[axis]) {
			time = mins[axis] - start[axis]
			if (time > delta[axis]) {
				return null
			}
			time /= delta[axis]
			return {t=time, norm=1.0}
		} else if (start[axis] > maxes[axis]) {
			time = maxes[axis] - start[axis]
			if (time < delta[axis]) {
				return null
			}
			time /= delta[axis]
			return {t=time, norm=-1.0}
		} else {
			return {t=-1.0, norm=0.0}
		}
	}
	function _trace_ray_bbox(start, delta) {

		local plane_x = _check_plane(start, delta, "x")
		if (plane_x == null) {return null}

		local plane_y = _check_plane(start, delta, "y")
		if (plane_y == null) {return null}

		local plane_z = _check_plane(start, delta, "z")
		if (plane_z == null) {return null}

		if (plane_x.norm == 0.0 && plane_y.norm == 0.0 && plane_z.norm == 0.0) {
			// Inside the box. We immediately impact.
			local direction = Vector(delta.x, delta.y, delta.z)
			direction.Norm()
			return Hit(start, direction, start, direction * -1.0, 0.0)
		}

		local normal = Vector(plane_x.norm, 0, 0)
		local time = plane_x.t
		if (plane_y.t > time) {
			time = plane_y.t
			normal = Vector(0, plane_y.norm, 0)
		} else if (plane_z.t > time) {
			time = plane_z.t
			normal = Vector(0, 0, plane_z.norm)
		}
		local impact = start + delta * time

		if (
			mins.x <= impact.x && impact.x <= maxes.x &&
			mins.y <= impact.y && impact.y <= maxes.y &&
			mins.z <= impact.z && impact.z <= maxes.z
		) {
			local direction = Vector(delta.x, delta.y, delta.z)
			direction.Norm()
			return Hit(
				start,
				direction,
				impact,
				normal,
				(impact - start).Length()
			)
		} else {
			return null
		}
	}
}

Volume.Hit <- Hit;

class Entry {
	mask = 0
	volumes = null
	constructor(m, v) {
		mask = m
		volumes = v
	}
}

// Check if the specified point is inside any collision volume.
function point_collide(point, mask, tolerance) {
	foreach(entry in VOLUMES) {
		if ((entry.mask & mask) == 0) {
			continue
		}
		foreach(volume in entry.volumes) {
			local center = (volume.mins + volume.maxes) * 0.5
			if (volume.point_inside(point, tolerance)) {
				return true
			}
		}
	}
	return false
}

// Trace a ray against all collision volumes.
// start: The starting point for the ray.
// delta: Both the direction and the maximum length to check.
function trace_ray(start, delta, mask) {
	local best_hit = null;
	foreach(entry in VOLUMES) {
		if ((entry.mask & mask) == 0) {
			continue
		}
		foreach(volume in entry.volumes) {
			local hit = volume.trace_ray(start, delta)
        	if (hit != null && (
        		best_hit == null || best_hit.distance > hit.distance
        	)) {
	            best_hit = hit
	        }
		}
	}
	return best_hit
}


::BEE_PointCollide <- point_collide.bindenv(this)
::BEE_TraceRay <- trace_ray.bindenv(this)

function Display() {
	printl("Dump collisions:")
	foreach(entry in VOLUMES) {
		printl("- " + entry.mask + " = [")
		foreach(volume in entry.volumes) {
			local center = (volume.mins + volume.maxes) * 0.5
			DebugDrawBox(center, volume.mins - center, volume.maxes - center, 255, 128, 64, 255, 1)
			printl("    center=" + center + ", " + (volume.mins - center) + " <-> " + (volume.maxes - center))
		}
	}
}
