// Creates sparks when objects touch a thin trigger.

glows <- {};
touching_ents <- {};

function OnPostSpawn() {
	self.ConnectOutput("OnStartTouch", "Touch_Start");
	self.ConnectOutput("OnEndTouch", "Touch_End");
	self.ConnectOutput("OnEndTouchAll", "RemoveAll");
	
	local bbox_min = self.GetBoundingMins();
	local bbox_max = self.GetBoundingMaxs();
	local center = self.GetCenter();
	
	// Determine the shortest axis - the spark stays at origin in that one.
	
	if (bbox_max.x - bbox_min.x < 16) {
		axis <- "x";
		pos <- bbox_max.x - bbox_min.x + center.x;
	} else if (bbox_max.y - bbox_min.y < 16) {
		axis <- "y";
		pos <- bbox_max.y - bbox_min.y + center.y;
	} else {
		axis <- "z";
		pos <- bbox_max.z - bbox_min.z + center.z;
	}
}

function InputDisable() {
	// When disabled they're all gone, so clean up.
	RemoveAll();
}

function Touch_Start() {
	local loc = activator.GetCenter();
	loc[axis] = pos;
		
	local spark = Entities.CreateByClassname("env_spark");
	
	spark.SetAbsOrigin(loc);
	
	EntFireByHandle(spark, "AddOutput", "MaxDelay 0.5", 0.00, self, self);
	EntFireByHandle(spark, "AddOutput", "spawnflags 256", 0.00, self, self); // Glow + silent
	EntFireByHandle(spark, "SetParent", "!activator", 0.01, activator, activator);
	EntFireByHandle(spark, "StartSpark", "", 0.01, self, self);
	glows[activator.entindex()] <- spark;
	touching_ents[activator.entindex()] <- activator;
}

function ThinkFunc() {
	// Adjust position every so often...
	local ent_id, spark;
	foreach (ent_id, spark in glows) {
		local loc = touching_ents[ent_id].GetCenter();
		loc[axis] = pos;
		spark.SetAbsOrigin(loc);
	}
	return 0.25;
}

function Touch_End() {
	if (activator.entindex() in glows) {
		local spark = glows[activator.entindex()];
		delete glows[activator.entindex()];
		delete touching_ents[activator.entindex()];
		spark.Destroy();
	}
}

function RemoveAll() {
	// Remove all sparks.
	local ent_id, spark;
	local ent_id, spark;
	foreach (ent_id, spark in glows) {
		spark.Destroy();
	}
	touching_ents = {};
	glows = {};
}