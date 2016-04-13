// This script was used in the original BEEMOD to detect if the HEP resources
// were installed on a user's computer. It's included to allow those Workshop
// maps to still function, it should not be added to any new map files.
BEE_Version <- 2

function Check_Pellets()
{
	EntFire( "@stop_for_pellets", "Kill", "", 0.0 )
}