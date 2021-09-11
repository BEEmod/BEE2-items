// Delays inputs, so simultaneous A and B don't briefly trigger
// one half.
// Outputs:
// * OnUser1 = Off
// * OnUser2 = Fizzler
// * OnUser3 = Laserfield
// * OnUser4 = Death Fizzler

has_cback <- false;
a_on <- null;
b_on <- null;

// When setting either input, we delay for 0.01 seconds
// before "committing" the change.

function set_a(new_state) {
	if(new_state == a_on) { return }
	a_on = new_state
	// Don't schedule more than one.
	if (!has_cback) {
		EntFireByHandle(self, "CallScriptFunction", "_cback", 0.01, self, self);
		has_cback = true;
	}
}

function set_b(new_state) {
	if(new_state == b_on) { return }
	b_on = new_state
	if (!has_cback) {
		EntFireByHandle(self, "CallScriptFunction", "_cback", 0.01, self, self);
		has_cback = true;
	}
}
  
function init(a, b) {
	// Initialise after map spawn.
	if (a_on == null) { a_on = a }
	if (b_on == null) { b_on = b }
	if (!has_cback) {
		_cback();
	}   
}

// The state has changed, fire outputs to update it.
// For Clean/Overgrown, this'll have the side effect
// of re-opening the models when just swapping states;
// that's fine though since it adds a nice effect.
function _cback() {
	local cmd;
	if (a_on && b_on) {
		cmd = "FireUser4";
	} else if (a_on) {
		cmd = "FireUser2"; 
	} else if (b_on) {
		cmd = "FireUser3";
	} else {
		cmd = "FireUser1";
	}
	EntFireByHandle(self, cmd, "", 0.00, self, self);
	has_cback = false;
}