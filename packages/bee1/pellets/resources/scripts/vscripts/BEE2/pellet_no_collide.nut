
// store a list of all known pellets, more efficient than searching for them every time
pellets <- [];
player_spawned <- false;

function pellet_launched() {
    // Find the newly fired pellet, relative to the !caller
	local pellet = null;
	while(1) {
		pellet = Entities.FindByClassnameWithin(pellet, "prop_energy_ball", caller.GetOrigin(), 16);
		if (pellet == null) {
			// Didn't find it..
			return
		}
		if (pellet.GetClassname() == "bee_exp_pellet") {
			// ignore already detonating infinite pellets
			continue;
		}
		break;
	}

    local owner = null;
    if (!IsMultiplayer()) {
        owner = GetPlayer()
    } else {
        owner = Entities.FindByClassnameNearest("player", pellet.GetOrigin(), 512)
    }

    // if a player hasn't spawned yet, don't bother
    if (owner != null) {
        pellet.SetOwner(owner)
    }

    // in SP we don't need to keep track of pellets after the player has spawned
    if (!player_spawned || IsMultiplayer()) {
        pellets.append(pellet)
    }
}

function Think() {
    if (!IsMultiplayer()) {
        // infinite pellets can spawn before the player spawns, so wait until they do and then set the owner
        if (GetPlayer()) {
            foreach (index, pellet in pellets) {
                if (pellet && pellet.IsValid()) {
                    pellet.SetOwner(GetPlayer())
                }
            }
            // in SP we never need to think again, later pellets will set owner on spawn
            pellets.clear()
            player_spawned = true
            return 999999999;
        }
        return 0.1;
    } else {
        // in MP, we have to swap constantly
        foreach(index, pellet in pellets) {
            if (pellet && pellet.IsValid()) {
                local owner = Entities.FindByClassnameNearest("player", pellet.GetOrigin(), 512)
                pellet.SetOwner(owner)
            } else {
                pellets.remove(index);
            }
        }
        // do this as often as we can to minimize deaths
        // this is slightly expensive but should be fine
        return 0;
    }
}