// Play voicelines in Coop when players do various events.
// Based off of code in glados_coop.nut

// Time since last death - we only trigger once every 10 seconds.
BEE2_LastDeathTime <- -100;

// BEE2_PLAY_DING <- false; //Play ding_on and off before/after lines.

// Trigger_hurt values assoicated with the item.
DEATH_TYPES <- [
	{bits=0x40000, name="goo"},
	{bits=0x00100, name="laserfield"},
	{bits=0x00002, name="turret"},
	{bits=0x00001, name="crush"},
]

function BEE2_play_line(channel, ch_arg) {
	// Play a voiceline. Channel is the type (death, taunt), 
	// and ch_arg is the subcatagory (damage type, animation)
	if (!ch_arg) {
		ch_arg = "generic";
	}
	local line_key = channel + "_" + ch_arg;
	if (!(line_key in BEE2_RESPONSES)) {
		return false;
	}

	local lines = BEE2_RESPONSES[line_key]
	
	if (lines == null) {
		return false;
	}

	local line_index = RandomInt(0, lines.len() - 1)
	
	printl("Playing " + line_key + " #" + line_index);
	
	local chosen = lines[line_index];
	
	if (BEE2_PLAY_DING) {
		EntFire("@ding_on", "Start", "", 0.00);
		// ding_on lasts about 0.2 seconds.
		EntFireByHandle(chosen, "Start", "", 0.20, null, null)
		EntFireByHandle(chosen, "AddOutput", "OnCompletion @ding_off,Start,,0,-1", 0.00, null, null)
	} else {
		EntFireByHandle(chosen, "Start", "", 0.00, null, null)
	}
	EntFireByHandle(chosen, "AddOutput", "OnCompletion !self,Kill,,0,-1", 0.00, null, null)

	// Don't play this again.
	lines.remove(line_index);
	printl(lines.len() + " lines left.");

	if (lines.len() == 0) { 
		// No more lines left to play
		BEE2_RESPONSES[line_key] = null;
	}
	return true;
}

function BotDeath(player, dmgtype) {
	// Called automatically on @glados when death occurs
	
	// Ignore if a player dies within the last few seconds..
	local cooldown_time = Time() - BEE2_LastDeathTime
	if (cooldown_time < 10) {
		printl("No death quote - cooldown not elapsed (" + (10 - cooldown_time) + "/10 seconds left).")
		return
	}
	BEE2_LastDeathTime = Time()

	foreach (type in DEATH_TYPES) {
		if ((dmgtype & type.bits) != 0) {
			printl("Death type: " + type.name);
			if (BEE2_play_line("death", type.name)) {
				return;
			}
		}
	}
	// None found, use generic.
	BEE2_play_line("death", null);
}

function DisableDeathResponse() {
	// Prevent death voicelines from playing - used in BTS for DVD death
	BEE2_LastDeathTime = Time() + 5000
}

// Generically taunt
function CoopBotAnimation(player, animation) {
	if (!BEE2_play_line("taunt", animation)) {
		BEE2_play_line("taunt", null);
	}
}

// Gesture at a camera
function PlayerTauntCamera(player, animation) {
	if (!BEE2_play_line("camera", animation)) {
		BEE2_play_line("camera", null);
	}
}

function RespondToTaunt(taunt) {
	// printl("Taunt: " + taunt)
}

function CoopPingTool(player, surface) {
	// Surface 1 = black
	// Surface 2 = white
}
