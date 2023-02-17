// Logic for the ghost cube.

disabled_coll <- {};
spawned <- false;
dying <- false;
next_coll <- 0.0;
// ghost_color, ghost_alpha: From compiler.
is_superpos_ghost <- true;  // So other VScripts can recognise.

function Think() {
	if (next_coll < Time() ) {
		next_coll = Time() + RandomFloat(0.25, 0.75);
		// As ents are created/destroyed this will get big - if it hits, clear
		// so we rescan and clear out any dead ents.
		if (disabled_coll.len() > 256) {
			disabled_coll = {};
		} 
		if (disable_collision("projected_wall_entity")) {
			EntFireByHandle(self, "Wake", "", 0.0, self, self);
		}
		disable_collision("prop_energy_ball");
	}
	self.__KeyValueFromString("rendercolor", ghost_color);
	self.__KeyValueFromInt("renderamt", ghost_alpha);
	return 0.001;
}

function disable_collision(classname) {
	local ent = null;
	local found = false;
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
		found = true;
	}
	return found;
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
	if (!dying) {
		local dissolver = Entities.FindByName(null, "@superpos_dissolver");
		EntFireByHandle(dissolver, "Dissolve", "!activator", 0.0, self, self);
		call_respawn();
	}
}

function FellInGoo() {
	call_respawn();
}

function call_respawn() {
	// find the instance name from "inst_name-box&0123"
	local name = self.GetName();
	name = name.slice(0, name.find("-box")) + "_respawn_rl";
	EntFire(name, "Trigger");
	dying = true;  // Don't repeat.
}
