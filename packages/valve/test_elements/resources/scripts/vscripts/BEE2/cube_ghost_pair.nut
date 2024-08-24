// Disable collisions between a dropping cube and its ghost.

cube_name <- "";
cube_search <- "";

function OnPostSpawn() {
	local inst_name = self.GetName()
	local hyphen = inst_name.find("-");
	inst_name = inst_name.slice(0, hyphen + 1);
	cube_name = inst_name + "box";
	cube_search = inst_name + "box&*";
}

function FindCube() {
	local real = null;
	local ghost = null;

	local ent = null;
	while(ent = Entities.FindByName(ent, cube_search)) {
		local cls = ent.GetClassname();
		if (cls == "simple_physics_prop") {
			ghost = ent;
		} else if (cls == "prop_weighted_cube" || cls == "prop_monster_box") {
			real = ent;
		} else {
			continue;
		}
		if (ghost != null && real != null) {
			self.__KeyValueFromString("attach1", real.GetName());
			self.__KeyValueFromString("attach2", ghost.GetName());
			EntFireByHandle(self, "DisableCollisions", "", 0.0, self, self);
			return;
		}
	}
}
