// This executes on the constraint itself, adjusting it on the fly to constrain the right cube.

inst_name <- self.GetName().slice(0, -6);  // -const
// Retrieve the cube we want to constrain.
cube <- ::rex_holder_constrained[inst_name];
dest_name <- inst_name + "-held_cube";
old_name <- cube.GetName();
// Temporarily rename the cube so we can parent.
cube.__KeyValueFromString("targetname", dest_name);
self.__KeyValueFromString("attach1", dest_name);
self.__KeyValueFromInt("forcelimit", 800);

function OnPostSpawn() {
	// This occurs immediately afterward, reset the name.
	cube.__KeyValueFromString("targetname", old_name);
}
