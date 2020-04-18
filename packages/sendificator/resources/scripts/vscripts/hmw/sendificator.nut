//  ________________________________________________________________________
//
//                            hmw/sendificator.nut
//
//
//  Support script for "Sendificator" testing element
//  Use with sendtor_* instances.
//
//  logic_script EntityGroup entries:
//      0:  first env_laser
//      1:  target of first env_laser
//  
//  This has been modified and only works in BEE2.4.
//
//  ________________________________________________________________________
//


//  ------------------------------------------------------------------------
//                               Static symbols
//  ------------------------------------------------------------------------


// Constants

beat_time <- 0.01;
// time between tracing steps; allows game state to update

cube_distance <- 24;
target_distance <- 16384;
// Distance of various things from the beam source

teleport_dest_offset <- 32;
// How far to move back from the final hit point to get the teleport location.
// Maps are allowed to modify this variable via RunScriptCode.

teleport_dest_offset_mon <- 64;
// Ditto for frankencubes.

glass_thickness <- 2.5;
// Barriers that are thinner than this threshold but otherwise solid,
// are treated as glass.
// This distance is measured in the direction of the incoming beam.
// Maps are allowed to modify this variable via RunScriptCode.

cube_size <- 19;   // size of cube for tracing (from origin)
cube_front <- 21;  // size of cube front; needs to be larger because of lens
cube_bbox <- 26;   // max bounding box around cubes
                   // (pre-rotated, for optimising cube tracing)

cube_horz_cutoff <- sin(5.5 / 180.0 * PI);
// Angle below which the outgoing beam is clamped to XY plane.
// (Prevents inaccuracies due to cube physics; also used by 'real' laser.)

// Effects spawned at both ends of the teleportation.
platform_fx_cube <- Entities.FindByName(null, "@sendtor_ghost_cube_e");
platform_fx_sphere <- Entities.FindByName(null, "@sendtor_ghost_sphere_e");
platform_fx_mon <- Entities.FindByName(null, "@sendtor_ghost_mon_e");
destination_fx_cube <- Entities.FindByName(null, "@sendtor_frame_cube_e");
destination_fx_sphere <- Entities.FindByName(null, "@sendtor_frame_sphere_e");
destination_fx_mon <- Entities.FindByName(null, "@sendtor_frame_mon_e");

// Ripple effects along beam.
ripple_fx <- Entities.FindByName(null, "@sendtor_ripple_e");


// Globals

::sendtor_source_offset <- Vector(12, 0, 0);
// offset from laser source entity

::sendtor_angles_override <- false;
// cube angle to use; set by angle snaping instances

// set by the map:
// ::sendtor_source = laser emitter to use for next trace
// ::sendtor_platform = location of source object
// ::sendtor_override_angles = angle to use (set by angle snapping instances)


// static variables

// arrays of env_lasers, corresponding targets and env_sprites
lasers <- [];
targets <- [];
sprites <- [];

// laser_arrays: number of available env_lasers; set by initialise()
// index: current tracing step (must be lower than laser_arrays)
// hit: status for tracing; 0 = nothing, 1 = cube, 2 = portal
//
// The following are used to maintain the current state whilst tracing:
//   current_pos: current scan position
//   current_dir: current scan direction, must be length 1
//   portal_list: array of open portals
//   portal_ids: array of IDs of open portals
//
// laser_ripple_dir: entities used with ripple particle effect, to set the
//                   travel direction of the particles.  See laser_ripples().


//  ------------------------------------------------------------------------
//                           Angle and vector math
//  ------------------------------------------------------------------------


function vector_length(v)
{
    // Return the length of a vector.
    return sqrt(pow(v.x, 2) + pow(v.y, 2) + pow(v.z, 2));
}


function vector_resize(v, f)
{
    // Return a vector colinear to v with length f.
    local len = vector_length(v);
    return v * (f / len);
}


function vector_dot(a, b)
{
    // Return the dot product of vectors a and b.
    return a.x*b.x + a.y*b.y + a.z*b.z
}


function make_rot_matrix(angles)
{
    // Return a 3x3 rotation matrix for the given pitch-yaw-roll angles.
    // (letters are swapped to get roll-yaw-pitch)
    //
    // format: / a b c \
    //         | d e f |
    //         \ g h k /

    local sin_x = sin(-angles.z / 180 * PI);
    local cos_x = cos(-angles.z / 180 * PI);
    local sin_y = sin(-angles.x / 180 * PI);
    local cos_y = cos(-angles.x / 180 * PI);
    local sin_z = sin(-angles.y / 180 * PI);
    local cos_z = cos(-angles.y / 180 * PI);

    return { a = cos_y * cos_z,   b = -sin_x * -sin_y * cos_z + cos_x * sin_z,   c = cos_x * -sin_y * cos_z + sin_x * sin_z,
             d = cos_y * -sin_z,  e = -sin_x * -sin_y * -sin_z + cos_x * cos_z,  f = cos_x * -sin_y * -sin_z + sin_x * cos_z,
             g = sin_y,           h = -sin_x * cos_y,                            k = cos_x * cos_y,
           }
}


function rotate(point, angles)
{
    // Rotate point about the origin by angles and return the result.

    local mx = make_rot_matrix(angles);
    return Vector(point.x * mx.a + point.y * mx.b + point.z * mx.c,
                  point.x * mx.d + point.y * mx.e + point.z * mx.f,
                  point.x * mx.g + point.y * mx.h + point.z * mx.k);
}


function unrotate(point, angles)
{
    // Rotate point about the origin by angles in the opposite direction
    // and return the result.
    //
    // This is very straightforward, as the inverse of the rotation
    // matrix is the original one with the rows and columns swapped.

    local mx = make_rot_matrix(angles);
    return Vector(point.x * mx.a + point.y * mx.d + point.z * mx.g,
                  point.x * mx.b + point.y * mx.e + point.z * mx.h,
                  point.x * mx.c + point.y * mx.f + point.z * mx.k);
}


//  ------------------------------------------------------------------------
//                               Initialisation
//  ------------------------------------------------------------------------


function initialise(n)
{
    // Initialise map entities.  Called 1 second after the map loads.
    // n is the number of lasers in the map template.

    laser_arrays <- 0;
    local origin = self.GetOrigin();
    local tvec = EntityGroup[1].GetOrigin() - origin;
    local lvec = EntityGroup[0].GetOrigin() - (origin + tvec);
    while (laser_arrays < n) {
        // Add a laser and its target and sprite to the lists.
        // The sprite will be at the location of the target since
        // nothing is blocking it.
        local tloc = origin + tvec * (laser_arrays + 1);
        lasers.append(Entities.FindByClassnameNearest(
                "env_laser", tloc + lvec, 1));
        targets.append(Entities.FindByClassnameNearest(
                "info_target", tloc, 1));
        local sprite = Entities.FindByClassnameNearest(
                "env_sprite", tloc, 1);
        sprites.append(sprite);
        EntFireByHandle(sprite, "AddOutput",
                        "targetname @sendtor_sprite" + laser_arrays,
                        0, null, null);
        ++laser_arrays;
    }
    reset_lasers();

    // Set up the enveloping func_portal_detector(s)
    // to keep track of the open-ness of portals.
    // Detectors with name "@sendtor_portal_detect0" detect ID 0 (SP),
    // ones with name "@sendtor_portal_detect1" detect ID 1 (Atlas),
    // "@sendtor_portal_detect2" detect ID 2 (P-Body) etc.
    
    // This is now done in BEE2.4.

    // local ent = Entities.FindByName(null, "@sendtor_portal_detect*");
    // while (ent != null) {

        // local id = ent.GetName().slice(22);
        // if (id == "") {
            // id = "0";
        // }

        // EntFireByHandle(ent, "AddOutput",
                // "OnStartTouchPortal !activator:RunScriptCode:" +
                // "sendtor_active <- " + id, 0, null, null);
        // EntFireByHandle(ent, "AddOutput",
                // "OnEndTouchPortal !activator:RunScriptCode:" +
                // "sendtor_active <- -1", 0, null, null);

        // ent = Entities.FindByName(ent, "@sendtor_portal_detect*");
    // }
}


//  ------------------------------------------------------------------------
//                             Entity operations
//  ------------------------------------------------------------------------


function reset_lasers()
{
    // Turn off all lasers and reset the index number
    EntFire("@sendtor_beam*", "TurnOff", "", 0, null);
    EntFire("@sendtor_beam*", "Color", "0 0 0", 0, null);
    EntFire("@sendtor_sprite*", "Color", "0 0 0", 0, null);
    index <- 0;
}


function place_laser()
{
    // Place the lasers[index] at current_pos, facing current_dir
    // and turn it on.
    lasers[index].SetOrigin(current_pos);
    targets[index].SetOrigin(current_pos + current_dir * target_distance);
    EntFireByHandle(lasers[index], "TurnOn", "", 0, null, null);
}


function place_laser_for_glass()
{
    // Place the lasers[index+1] in front of current_pos/dir, facing backward
    // and turn it on.  Used to determine the thickness of a barrier.
    // Return false if no laser is available.

    local i = index + 1;
    if (i >= laser_arrays) {
        return false;
    }

    lasers[i].SetOrigin(current_pos + current_dir * glass_thickness * 4);
    targets[i].SetOrigin(current_pos + current_dir * glass_thickness * -4);
    EntFireByHandle(lasers[i], "TurnOn", "", 0, null, null);

    return true;
}


function reset_laser_for_glass()
{
    // Turn the laser off that was used by place_laser_for_glass
    local i = index + 1;
    EntFireByHandle(lasers[i], "TurnOff", "", 0, null, null);
}


function schedule_call(code)
{
    // Set an event to start the next operation after beat_time seconds.
    EntFireByHandle(self, "RunScriptCode", code, beat_time, null, null);
}


//  ------------------------------------------------------------------------
//                               Finding stuff
//  ------------------------------------------------------------------------


function find_cube(prev)
{
    // Iterate over all lens cubes in the map.

    local cube = Entities.FindByClassname(prev, "prop_weighted_cube");
    if (cube != null && !is_lens_cube(cube)) {
        // skip non-lens cubes
        return find_cube(cube);
    }
    return cube;
}


function find_cube_to_send(platform_origin)
{
    // Return the cube currently on the indicated platform.
    // Return null if platform is empty.
    local cube = Entities.FindByClassnameNearest(
            "prop_weighted_cube", platform_origin, 32);
    if (cube == null) {
        cube = Entities.FindByClassnameNearest(
                "prop_monster_box", platform_origin, 32);
    }
    return cube;
}


function is_lens_cube(cube)
{
    // Return true if the cube is a lens cube.
    return cube.GetModelName().find("reflection_cube") != null;
}


function is_round_cube(cube)
{
    // Return true if the cube is a round cube (ie ball).
    return cube.GetModelName().find("mp_ball") != null;
}


function is_monster_cube(cube)
{
    // Return true if the cube is a frankencube
    return cube.GetClassname() == "prop_monster_box";
}

// Include the BEE2 script, which will update these functions to
// handle custom cubes.
DoIncludeScript("hmw/sendtor_cube_data", self.GetScriptScope());


function get_portal_id(portal)
{
    // For active portals, return the linkage ID.
    // For inactive portals, return -1.
    // (A portal's sendtor_active attribute is set by the
    // @sendtor_portal_detect portal detectors in the map.)

    portal.ValidateScriptScope();
    local portal_ss = portal.GetScriptScope();
    
    // New BEE2 logic
    if ("__pgun_active" in portal_ss) {
        if (portal_ss.__pgun_active) { 
            return portal_ss.__pgun_port_id;
        } else {
            return -1;
        }
        
    // Original logic.
    } else if ("sendtor_active" in portal_ss) {
        return portal_ss.sendtor_active;
    }
    else {
        return -1;
    }
}


function find_open_portals()
{
    // Find all active portals in the map and fill portal_list and portal_ids.

    portal_list <- [];
    portal_ids <- [];

    local portal = Entities.FindByClassname(null, "prop_portal");
    while (portal != null) {
        local id = get_portal_id(portal);
        if (id >= 0) {
            // Only add active portals, not closed ones.
            portal_list.append(portal);
            portal_ids.append(id);
        }
        portal = Entities.FindByClassname(portal, "prop_portal");
    }
}


function find_portal_partner(portal)
{
    // Find the other end of a portal.

    local this_id = get_portal_id(portal)
    foreach (k, v in portal_list) {
        if (v != portal && portal_ids[k] == this_id) {
            return v;
        }
    }
    return null;
}


//  ------------------------------------------------------------------------
//                                Beam tracing
//  ------------------------------------------------------------------------


function trace_start()
{
    // Start a beam trace.
    local source_rot = ::sendtor_source.GetAngles();
    current_pos <- ::sendtor_source.GetOrigin() +
        rotate(::sendtor_source_offset, source_rot);
    current_dir <- rotate(Vector(1, 0, 0), source_rot);
    find_open_portals();
    reset_lasers();
    place_laser();
    schedule_call("trace();");
}


function trace()
{
    // Find out what the current laser hits and take the appropriate action.
    // Abort if index has reached laser_arrays

    current_pos = sprites[index].GetOrigin();

    hit <- 0;
    trace_cubes();
    trace_portals();
    if (hit == 2) {
        // trace cubes again to prevent wasting a beam
        // when a cube is inside a portal
        trace_cubes();
        if (hit == 1) {
            // ...and once more, with feeling!
            trace_portals();
        }
    }

    if (hit == 0) {
        // No more cubes and portals.  We might still be hitting glass,
        // so check the thickness.
        if (place_laser_for_glass()) {
            schedule_call("trace_glass();");
        }
        else {
            reset_lasers();
        }
        return;
    }

    if (++index >= laser_arrays) {
        // Out of lasers; abort.
        reset_lasers();
        return;
    }
    place_laser();
    schedule_call("trace();");
}


function trace_glass()
{
    // Check the distance between current_pos and the next laser end sprite.
    // If this is less than glass_thickness, jump past the glass
    // and continue tracing normally.
    // Otherwise end the trace and process the result.

    local pos = sprites[index+1].GetOrigin();
    if (vector_length(pos - current_pos) < glass_thickness) {
        current_pos += current_dir * glass_thickness;
        ++index;
        place_laser();
        schedule_call("trace();");
    }
    else {
        // Not glass, so this is the endpoint.
        // Turn off the glass-tracing laser.
        reset_laser_for_glass();

        // Calculate the teleport destination
        local cargo = find_cube_to_send(::sendtor_platform.GetOrigin());
        local dest_offset = teleport_dest_offset;
        if (cargo != null && is_monster_cube(cargo)) {
            dest_offset = teleport_dest_offset_mon;
        }
        pos = backtrack_dest(dest_offset, index);
        dest_confirm(cargo, pos);

        return;
    }
}


function trace_cubes()
{
    // Iterate over all lens cubes and update current_pos
    // and current_dir if one is hit.

    local ent = find_cube(null);
    while (ent != null) {

        local offset = current_pos - ent.GetOrigin();
        local angles = ent.GetAngles();

        local bbox_size = cube_bbox + glass_thickness;
        // Add glass thickness to all cube scanning limits,
        // to correctly handle cubes places on glass.

        // Test unrotated bounding box.
        if (fabs(offset.x) < bbox_size &&
                fabs(offset.y) < cube_bbox &&
                fabs(offset.z) < cube_bbox) {

            local local_size = cube_size + glass_thickness;
            local local_front = cube_front + glass_thickness;

            // Test rotated position against cube volume
            offset = unrotate(offset, angles);
            if (offset.x > -local_size &&
                    offset.x < local_front &&
                    fabs(offset.y) < local_size &&
                    fabs(offset.z) < local_size) {

                // Prevent incoming beam from extending, in case this cube
                // is the one that gets transported.
                targets[index].SetOrigin(current_pos);

                // set next beam to emit from cube
                local source_offset = Vector(cube_distance, 0, 0);
                current_pos = ent.GetOrigin() + rotate(source_offset, angles);
                current_dir = rotate(Vector(1, 0, 0), angles);

                // apply near-horizontal clamping
                if (fabs(current_dir.z) < cube_horz_cutoff) {
                    current_dir.z = 0;
                    current_dir = vector_resize(current_dir, 1);
                }

                // Set flag so the main trace knows we hit a cube.
                hit = 1;
                break;
            }
        }
        ent = find_cube(ent);
    }
}


function trace_portals()
{
    // Find out if we are hitting a portal and translate current_pos
    // and current_dir to the other side.

    foreach (k, v in portal_list) {
        local angles = v.GetAngles();
        local offset = unrotate(current_pos - v.GetOrigin(), angles);
        if (fabs(offset.y) < 32 && fabs(offset.z) < 54 &&
                offset.x < 1 && offset.x > -12) {

            // Position is close to (or past) portal surface.
            // Find other portal end and check incoming direction.

            local local_dir = unrotate(current_dir, angles);
            local other = find_portal_partner(v);
            if (other != null && local_dir.x < 0) {
                // Calculate the next beam.

                // cross the portal plane if not already on the other side
                if (offset.x > -1) {
                    offset += vector_resize(local_dir, offset.x + 1);
                }

                // other portal is rotated 180dg about Z axis
                offset.x *= -1;
                offset.y *= -1;
                local_dir.x *= -1;
                local_dir.y *= -1;

                // add position and angles of other portal
                angles = other.GetAngles();
                current_pos = other.GetOrigin() + rotate(offset, angles);
                current_dir = rotate(local_dir, angles);

                // Donesies!
                hit = 2;
                break;
            }
        }
    }
}


//  ------------------------------------------------------------------------
//                         Teleportation and effects
//  ------------------------------------------------------------------------


function backtrack_dest(distance, laser_index)
{
    // track the given distance back along the laser beams and
    // return the offset position.

    local p0 = lasers[laser_index].GetOrigin();
    local p1 = sprites[laser_index].GetOrigin();
    local delta = p1 - p0;
    local length = vector_length(delta);

    if (length > distance) {
        // Move back by given distance and return result
        return p0 + vector_resize(delta, length - distance);
    }

    if (laser_index > 0) {
        // Substract this beam's length and
        // move remainder to previous beam
        return backtrack_dest(distance - length, laser_index - 1);
    }
    else {
        // If we run out of beams: fall back to midpoint of first beam
        return p0 + vector_resize(delta, length / 2);
    }
}


function dest_confirm(cargo, location)
{
    // Move object to destination and create fade effects

    if (cargo != null) {

        // Delay before re-enabling motion after teleport.
        local freeze_time = 0.01;

        // Effects; depend on type of cube
        local platform_fx = platform_fx_cube;
        local destination_fx = destination_fx_cube;
        if (is_monster_cube(cargo)) {
            platform_fx = platform_fx_mon;
            destination_fx = destination_fx_mon;
        }
        else if (is_round_cube(cargo)) {
            platform_fx = platform_fx_sphere;
            destination_fx = destination_fx_sphere;
        }

        EntFireByHandle(cargo, "DisableMotion", "", 0, null, null);
        platform_fx.SpawnEntityAtLocation(cargo.GetOrigin(),
                                          cargo.GetAngles());


        // Override the cube angle if applicable
        if (::sendtor_angles_override) {
            cargo.SetAngles(::sendtor_override_angles.x,
                            ::sendtor_override_angles.y,
                            ::sendtor_override_angles.z);
            // Delay enable motion to prevent jumping.
            freeze_time = 0.1;
        }

        cargo.SetOrigin(location);
        EntFireByHandle(cargo, "EnableMotion", "", freeze_time, null, null);
        destination_fx.SpawnEntityAtLocation(location, cargo.GetAngles());

        // add ripple effects
        laser_ripple_dir <- null;
        for (local i = 0; i <= index; ++i) {
            laser_ripples(lasers[i], sprites[i], targets[i]);
        }

        // play teleportation effects
        EntFire("@sendtor_tel_fx", "Trigger", "", 0, null);
        // for PeTI, the platform is the texturetoggle too.
        EntFireByHandle(::sendtor_platform, "SetTextureIndex","1",0, null, null);
        // Tell our sendtor to animate too.
        EntFireByHandle(::sendtor_platform, "FireUser1","",0, null, null);
    }
    else {
        // play misfire effects
        EntFire("@sendtor_nop_fx", "Trigger", "", 0, null);
        // for PeTI, the platform is the texturetoggle too.
        EntFireByHandle(::sendtor_platform, "SetTextureIndex","2",0, null, null);
    }

    // play general effects
    EntFire("@sendtor_gen_fx", "Trigger", "", 0, null);
    EntFireByHandle(::sendtor_platform, "FireUser2","",0, null, null);
}


function laser_ripples(laser, sprite, target) {
    // Add ripple effects to the beam between start and end.

    local origin = laser.GetOrigin();
    local extent = sprite.GetOrigin() - origin;
    local length = vector_length(extent);

    // don't place ripples on very short beam sections.
    if (length < 96)  { return; }

    // determine the angles
    target.SetForwardVector(extent);
    local angles = target.GetAngles();
    local dir_vector = vector_resize(extent, 128);

    if (length > 1024) {
        // If the section is very long, add the maximum number of ripples
        // and spread them out uniformly.
        extent *= (length - 96) / 4 / length;
        for (local i = 0; i <= 4; ++i) {
            laser_ripples_place(origin, angles, dir_vector);
            origin += extent;
        }
    }
    else {
        // Place as many ripple effects as is suitable for the given length.
        laser_ripples_split(origin, extent, length, angles, dir_vector);
    }
}


function laser_ripples_split(origin, extent, length, angles, dir_vector)
{
    // Split the section into progressively smaller ones until a limit
    // is reached, then place ripples on each subsection.
    if (length < 192) {
        laser_ripples_place(origin, angles, dir_vector);
    }
    else {
        length *= 0.5;
        extent *= 0.5;
        laser_ripples_split(origin, extent, length, angles, dir_vector);
        laser_ripples_split(origin + extent, extent, length, angles,
                            dir_vector);
    }
}


function laser_ripples_place(origin, angles, dir_vector)
{
    // Place ripples effect at the indicated location and angle.
    // The extra dir_vector is precalculated by laser_ripples and serves
    // as a directional input to the particle system.

    // First create all entities for the effect...
    ripple_fx.SpawnEntityAtLocation(origin, angles);
    // ... then find the next info_target (just created and added
    // to the end of the entity list) that sets the particle travel
    // direction for the particle system, and set its position to match
    // the beam direction.
    laser_ripple_dir = Entities.FindByName(laser_ripple_dir,
                                           "@sendtor_ripple_dir*");
    laser_ripple_dir.SetOrigin(dir_vector);
}


//  ------------------------------------------------------------------------
//                               Angle snapping
//  ------------------------------------------------------------------------


// Static variables

my_angles_override <- false;

snap_dot_threshold <- 0.95;
// minimum dot product for choosing a snap angle

snap_angles_45 <- [
    // angles to snap to (pitch, yaw, roll)
    Vector(0,   0, 0),
    Vector(0,  45, 0),
    Vector(0,  90, 0),
    Vector(0, 135, 0),
    Vector(0, 180, 0),
    Vector(0, 225, 0),
    Vector(0, 270, 0),
    Vector(0, 315, 0),
];

s2 <- sqrt(0.5);
snap_vectors_45 <- [
    // vectors to compare with object's vectors
    Vector(  1,  0,  0),
    Vector( s2, s2,  0),
    Vector(  0,  1,  0),
    Vector(-s2, s2,  0),
    Vector( -1,  0,  0),
    Vector(-s2,-s2,  0),
    Vector(  0, -1,  0),
    Vector( s2,-s2,  0),
];


function snap_update_cube()
{
    // Test the current orientation of the cube
    // to decide whether snapping should be applied.

    local cargo = find_cube_to_send(self.GetOrigin());

    if (cargo != null && is_lens_cube(cargo)) {
        local cargo_vector = cargo.GetForwardVector();
        foreach (k, v in snap_vectors_45) {
            if (vector_dot(cargo_vector, v) > snap_dot_threshold) {
                if (!my_angles_override) {
                    my_angles_override = true;
                    EntFireByHandle(
                        EntityGroup[0], "Skin", "0", 0.1, null, null);
                    EntFireByHandle(
                        EntityGroup[0], "SetAnimation", "on", 0.1, null, null);
                }
                my_override_angles <- snap_angles_45[k];
                EntityGroup[0].SetAngles(my_override_angles.x,
                                         my_override_angles.y
                                         my_override_angles.z);
                return;
            }
        }
    }
    snap_reset();
}


function snap_apply()
{
    // Copy this instance's values to the global state
    // prior to a sending event.
    if (my_angles_override) {
        ::sendtor_angles_override <- my_angles_override;
        ::sendtor_override_angles <- my_override_angles;
    }
}


function snap_reset()
{
    // Turn off snapping and hide the indicator.
    my_angles_override = false;
    ::sendtor_angles_override = false;
    EntFireByHandle(EntityGroup[0], "Skin", "1", 0, null, null);
    EntFireByHandle(EntityGroup[0], "SetAnimation", "off", 0, null, null);
}


// vim:set nowrap:
