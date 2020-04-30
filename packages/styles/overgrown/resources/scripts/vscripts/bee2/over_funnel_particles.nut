active <- false;
reverse <- false;

function Update() {
    if (active) {
        if (reverse)
        {
            EntFire(inst_fixup+"-po*", "Start");
            EntFire(inst_fixup+"-pb*", "Stop");
        } else {
            EntFire(inst_fixup+"-pb*", "Start");
            EntFire(inst_fixup+"-po*", "Stop");
        }
    } else {
        EntFire(inst_fixup+"-p*", "Stop");
    }
}

function SetActive(a) {
    active = a;
    Update();
}

function SetReverse(r) {
    reverse = r;
    Update();
}

function OnPostSpawn() {
    // Figure out our instance name fixup
    local name = self.GetName();
    inst_fixup <- name.slice(0, name.find("-"));
    Update()
}