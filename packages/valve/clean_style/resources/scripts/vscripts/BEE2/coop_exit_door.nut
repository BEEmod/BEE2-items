// Coop Exit Door logic.
// OnUser1: Close door.
// OnUser2: Open door.
// OnUser3: Lock door and open elevator door
// OnUser4: 
BLUE <- 0
ORAN <- 1

ent_camera <- EntityGroup[0]

ent_spr <- [EntityGroup[1], EntityGroup[2]]
ent_tog <- [EntityGroup[3], EntityGroup[4]]

// CONF_SENSE_ON <- "Portal.button_down"
// CONF_SENSE_OFF <- "Portal.button_up"
// CONF_STARTOPEN <- true

// Player states:
STATE_OUTSIDE  <- 0 // Not near the door.
STATE_INFRONT  <- 1 // In front of the door - open it.
STATE_INSIDE   <- 2 // Inside corridor - lock door open
STATE_ELEVATOR <- 3 // Fully inside - close door when both are here.

// st_names <- ["OUTSIDE", "INFRONT", "INSIDE", "ELEVATOR"]

state <- [STATE_OUTSIDE, STATE_OUTSIDE]

is_open <- null // Neither state, forces it to open/close.
is_unlocked <- false // IO state.
has_won <- false  // If true, exit door is locked close.

function Precache() {
    self.PrecacheSoundScript(CONF_SENSE_OFF)
    self.PrecacheSoundScript(CONF_SENSE_ON)
}
function OnPostSpawn() {
	inp_io(CONF_STARTOPEN)
}

function EFBH(ent, inp, parm="") {
	if (ent != null) EntFireByHandle(ent, inp, parm, 0, self, self)
}

function door_open() {
	if (is_open != true) {
	    is_open = true
	    EFBH(self, "FireUser2")
	}
}

function door_close() {
	if (is_open != false) {
	    is_open = false
	    EFBH(self, "FireUser1")
	}
}

function update_state() {
	if (state[BLUE] != STATE_OUTSIDE && state[ORAN] != STATE_OUTSIDE) {
		EFBH(ent_spr[BLUE], "HideSprite")
		EFBH(ent_spr[ORAN], "HideSprite")
		EFBH(ent_camera, "LookAllTeams")
	} else {
		local no_spr = true
		if (state[BLUE] != STATE_OUTSIDE && ent_spr[BLUE] != null) {
			EFBH(ent_spr[BLUE], "ShowSprite")
			EFBH(ent_camera, "LookAtBlue")
			no_spr = false
		}
		if (state[ORAN] != STATE_OUTSIDE && ent_spr[ORAN] != null) {
			EFBH(ent_spr[ORAN], "ShowSprite")
			EFBH(ent_camera, "LookAtOrange")
			no_spr = false
		}
		if (no_spr) {
			EFBH(ent_camera, "Disable")
		}
	}
	//printl("Blue: " + st_names[state[BLUE]] + ", Oran: " + st_names[state[ORAN]])
	//printl("has_won=" + has_won.tostring() + " unlocked=" + is_unlocked.tostring());

	if (has_won) {
		return;
	}
	if (state[BLUE] == STATE_ELEVATOR && state[ORAN] == STATE_ELEVATOR) {
		has_won = true;
		door_close();
		EntFire("@has_won", "Trigger")
	    EFBH(self, "FireUser3")

	} else if (state[BLUE] >= STATE_INSIDE || state[ORAN] >= STATE_INSIDE) {
		// Players force it open.
		door_open();
	} else if (is_unlocked && state[BLUE] != STATE_OUTSIDE && state[ORAN] != STATE_OUTSIDE) {
		door_open();
	} else {
		door_close();
	}
}

function inp_io(is_open) {
	is_unlocked = is_open;
	update_state();
}

// Player detection trigger.
function inp_det_player(player) {
    if (state[player] == STATE_OUTSIDE) {
		state[player] = STATE_INFRONT
		self.EmitSound(CONF_SENSE_ON)
		EFBH(ent_camera, "Enable")
		EFBH(ent_tog[player], "SetTextureIndex", "1")
		update_state();
    }
}

// Player fully left door, or went all the way inside.
function inp_undet_player(player) {
    if (state[player] == STATE_INSIDE || state[player] == STATE_INFRONT) {
		state[player] = STATE_OUTSIDE
		self.EmitSound(CONF_SENSE_OFF)
		EFBH(ent_tog[player], "SetTextureIndex", "0")
		update_state();
    }
}

// Player entered the door. Lock it open.
// Don't change if they're coming out though.
function inp_player_entered(player) {
	if(!has_won) {
		state[player] = STATE_INSIDE
    	update_state()
	}
}

// Player walked fully inside - ready to close the door.
function inp_player_inside(player) {
    state[player] = STATE_ELEVATOR
    update_state()
}
