// Logic for the ghost cube.

disabled_coll <- {};
spawned <- false;
next_coll <- 0.0;
// ghost_color, ghost_alpha: From compiler.

function Think() {
	if (next_coll < Time() ) {
		next_coll = Time() + RandomFloat(0.25, 0.75);
		// As ents are created/destroyed this will get big - if it hits, clear
		// so we rescan and clear out any dead ents.
		if (disabled_coll.len() > 256) {
			disabled_coll = {};
		} 
		disable_collision("projected_wall_entity");
		disable_collision("prop_energy_ball");
	}
	self.__KeyValueFromString("rendercolor", ghost_color);
	self.__KeyValueFromInt("renderamt", ghost_alpha);
	return 0.01;
}

function disable_collision(classname) {
	local ent = null;
	while(ent = Entities.FindByClassname(ent, classname)) {
		local name = ent.GetName();
		if (name == "") {
			name = "_" + classname + UniqueString();
			ent.__KeyValueFromString("targetname", name);
		}
		if (name in disabled_coll) {
			continue;
		}
		collision_pair <- Entities.CreateByClassname("logic_collision_pair");
		collision_pair.__KeyValueFromString("attach1", self.GetName())	
		collision_pair.__KeyValueFromString("attach2", name);
		EntFireByHandle(collision_pair, "DisableCollisions", "", 0, null, null);
		EntFireByHandle(collision_pair, "Kill", "", 0.01, null, null);
		disabled_coll[name] <- null;
	}
}

function Spawned() {
	spawned = true;
}

function FizzleIfOutside() {
	if (spawned) {
		Fizzle();
	}
}

function Fizzle() {
	dissolver = Entities.FindByName(null, "@superpos_dissolver");
	EntFireByHandle(dissolver, "Dissolve", "!activator", 0.0, self, self);
}
