// The rocket turret beam will sometimes stop rendering, it tends to happen when the end target moves outside the map.
// This script uses a traceline so that doesn't happen.

max_dist <- 3200; // maximum size of a puzzlemaker map

inst_fixup <- self.GetName().slice(0, self.GetName().find("-"));
beam_start <- Entities.FindByName(null, inst_fixup+"-beam_start");
beam_end <- Entities.FindByName(null, inst_fixup+"-beam_end");

active <- false

function beam_think() {
	if (active) {
		local dist = TraceLine(beam_start.GetOrigin(), beam_start.GetOrigin() + (beam_start.GetForwardVector() * max_dist), self) * max_dist;
		beam_end.SetOrigin(Vector(dist, 0, 0));
	}
}