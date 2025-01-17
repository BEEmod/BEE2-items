// Ensure the rocket turret beam target stays inside the map, otherwise it can turn invisible

max_dist <- 5000; // bigger than the maximum size of a puzzlemaker map
extra_dist <- 32 // Extend beam by this many units, avoids end of beam jittering near walls

inst_fixup <- self.GetName().slice(0, self.GetName().find("-"));
beam_start <- Entities.FindByName(null, inst_fixup+"-beam_start");
beam_end <- Entities.FindByName(null, inst_fixup+"-beam_end");

active <- false

function beam_think() {
	if (active) {
		local dist = TraceLine(beam_start.GetOrigin(), beam_start.GetOrigin() + (beam_start.GetForwardVector() * max_dist), self) * max_dist;
		beam_end.SetOrigin(Vector(dist + extra_dist, 0, 0));
	}
}