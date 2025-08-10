IncludeScript("BEE2/rex_cube_holder_ball.nut"); // Creates is_round_cube() predicate.

if (!("rex_holder_constrained" in getroottable())) {
	::rex_holder_constrained <- {};
}
inst_name <- self.GetName().slice(0, -7); // Remove -script
tele <- EntityGroup[0];
template <- EntityGroup[1];
ORIENT_NORM <- tele.GetAngles();
// ORIENT_MONST: comp_kv_setter.
cube <- null;
was_ball <- false;
cube_child <- null;
cube_trigger <- null;

const SND_OFF = "BEE2.p1.rex_deflect_off";
const SND_ON  = "BEE2.p1.rex_deflect_on";
const SND_LAUNCH = "World.Wheatley.fire";

function Precache() {
	self.PrecacheSoundScript(SND_OFF);
	self.PrecacheSoundScript(SND_ON);
	self.PrecacheSoundScript(SND_LAUNCH);
}

function PlayLaunch() {
	tele.EmitSound(SND_LAUNCH);
}

function AttachCube() {
	cube = activator;

	was_ball = false;
	if (cube.GetClassname() == "prop_monster_box") {
		tele.SetAngles(ORIENT_MONST.x, ORIENT_MONST.y, ORIENT_MONST.z);
	} else {
		tele.SetAngles(ORIENT_NORM.x, ORIENT_NORM.y, ORIENT_NORM.z);
		if (is_round_cube(cube)) {
			was_ball = true;
		}
	}
	if (was_ball) {
		EntFireByHandle(self, "FireUser2", "", 0.0, cube, self);
	} else {
		EntFireByHandle(self, "FireUser1", "", 0.0, cube, self);
		tele.EmitSound(SND_ON);
	}
	
	::rex_holder_constrained[inst_name] <- cube;
	EntFireByHandle(self, "Disable", "", 0.0, self, self);
	EntFireByHandle(cube, "DisableMotion", "", 0.0, cube, self);
	EntFireByHandle(tele, "TeleportToCurrentPos", "!activator", 0.0, cube, self);
	
	// Disable cube pellet trigger
	cube_child = cube.FirstMoveChild();
	if (cube_child != null && cube_child.IsValid() && cube_child.GetClassname() == "trigger_multiple" && cube_child.GetName().find("cube_addon_rex_pellet_trig") != null) {
		cube_trigger = cube_child;
		EntFireByHandle(cube_trigger, "Disable", "", 0.0, cube_trigger, self);
	}
	cube_child = null;
	
	EntFireByHandle(template, "ForceSpawn", "", 0.0, self, self);
	EntFireByHandle(cube, "EnableMotion", "", 0.1, cube, self);
}

function Reset() {
	if (cube != null && cube.IsValid() && cube.GetClassname() == "prop_monster_box") {
		EntFireByHandle(cube, "BecomeMonster", "", 0.0, self, self);
	}
	if (!was_ball) {
		tele.EmitSound(SND_OFF);
	}
	cube = null;
	
	if (cube_trigger != null && cube_trigger.IsValid()) {
		EntFireByHandle(cube_trigger, "Enable", "", 0.0, cube_trigger, self);
	}
	cube_trigger = null;
}

function FizzleCube() {
	if (cube != null) {
	
		if (cube_trigger != null && cube_trigger.IsValid()) {
			cube_trigger.Destroy();
		}
		
		EntFireByHandle(cube, "Dissolve", "", 0.0, activator, self);
		cube = null;
	}
}