// --------------------------------------------------------
// StartVideo
// --------------------------------------------------------

RandomVideos <-
[
	"animalking.bik",
	"aperture_appear_horiz.bik",
	"bluescreen.bik",
	"coop_bluebot_load.bik",
	"coop_bots_load.bik",
	"coop_bots_load_wave.bik",
	"coop_orangebot_load.bik",
	"exercises_horiz.bik",
	"faithplate.bik",
	"fizzler.bik",
	"hard_light.bik",
	"laser_danger_horiz.bik",
	"laser_portal.bik",
	"plc_blue_horiz.bik",
	"turret_colours_type.bik",
	"turret_dropin.bik",
	"turret_exploded_grey.bik",
	"community_bg1.bik"
]

ARRIVAL_VIDEO <- 0
DEPARTURE_VIDEO <- 1

chosenVideo <- ''

function Precache()
{
	if( "PrecachedVideos" in this )
	{
		// don't do anything
	}
	else
	{
		// If we're in a community map, pick a random one
		local communityMapIndex = GetMapIndexInPlayOrder();
		if ( communityMapIndex != -2 )
		{
			if ( communityMapIndex == -1 )
			{
				communityMapIndex = GetNumMapsPlayed()
			}
			
			chosenVideo = "media\\" + RandomVideos[communityMapIndex % RandomVideos.len()];
			printl( "Preching movie: " + chosenVideo )
			PrecacheMovie( movieName )		
		}
		else
		{
		chosenVideo = "media\\" + RandomVideos[RandomInt(0,RandomVideos.len())] + ".bik"; // For playtesting
		}
	}
}

function StopArrivalVideo(width,height)
{
	EntFire("@arrival_video_master_horiz", "Disable", "", 0)
	EntFire("@arrival_video_master_horiz", "killhierarchy", "", 1.0)
	StopVideo(ARRIVAL_VIDEO,width,height)
}

function StopDepartureVideo(width,height)
{
	EntFire("@departure_video_master_horiz", "Disable", "", 0)
	EntFire("@departure_video_master_horiz", "killhierarchy", "", 1.0)
	StopVideo(DEPARTURE_VIDEO,width,height)
}

function StopVideo(videoType, width, height)
{
	for(local i=0;i<width;i+=1)
	{
		for(local j=0;j<height;j+=1)
		{
			local panelNum = 1 + width*j + i
			local signName
			
			if (videoType == DEPARTURE_VIDEO)
			{
				signName = "@departure_sign_" + panelNum
			}
			else
			{
				signName = "@arrival_sign_" + panelNum
			}
			
			EntFire(signName, "Disable", "", 0)
			EntFire(signName, "killhierarchy", "", 1.0)
		}
	}
}

function StartArrivalVideo(width,height)
{
	
	// If we have something to play, do so
	if ( chosenVideo != "" )
	{
		printl("Setting arrival movie to " + chosenVideo )
		EntFire("@arrival_video_master_horiz", "SetMovie", chosenVideo, 0)
	
		EntFire("@arrival_video_master_horiz", "Enable", "", 0.1)
		StartVideo(ARRIVAL_VIDEO, width, height
	}
}

function StartDepartureVideo(width,height)
{
	if ( chosenVideo != "" )
	{
		printl("Setting departure movie to " + chosenVideo )
		EntFire("@departure_video_master_horiz", "SetMovie", chosenVideo, 0)
		
		EntFire("@departure_video_master_horiz", "Enable", "", 0.1)
		StartVideo(DEPARTURE_VIDEO, width, height)
	}
}

function StartVideo(videoType,width,height)
{
	if (chosenVideo == 'bluescreen.bik')
	{
	videoScaleType = 14
	}
	else
	{
	local videoScaleType = RandomInt(1,13)
	}
	
	for(local i=0;i<width;i+=1)
	{
		for(local j=0;j<height;j+=1)
		{
			local panelNum = 1 + width*j + i
			local signName
			
			if (videoType == DEPARTURE_VIDEO)
			{
				signName = "@departure_sign_" + panelNum
			}
			else
			{
				signName = "@arrival_sign_" + panelNum
			}		
					
			// if( randomDestructChance > RandomInt(0,100) )
			// {
				// EntFire(signName, "Kill", "", 0)
				// continue
			// }
			
			EntFire(signName, "SetUseCustomUVs", 1, 0)
			
			local uMin = (i+0.0001)/(width)
			local uMax = (i+1.0001)/(width)
			local vMin = (j+0.0001)/(height)
			local vMax = (j+1.0001)/(height)
							
			else if( videoScaleType == 1 /*stretch*/ ) 
			{
				uMin = 1.0 - (1.0-uMin)*(1.0-uMin)*(1.0-uMin)
				uMax = 1.0 - (1.0-uMax)*(1.0-uMax)*(1.0-uMax)
			}				

			else if( videoScaleType == 2 /*Mirror*/ ) 
			{					
				uMin = 4*(1.0-uMin)*uMin
				uMax = 4*(1.0-uMax)*uMax					
			}				
			
			else if( videoScaleType == 3 /*Ouroboros*/ )
			{
				uMin = ((i%12)+0.0001)/12
				uMax = ((i%12)+1.0001)/12

				if( ((i)%2) == 1 )
				{
					local temp = uMin
					uMin = uMax
					uMax = temp
				}
			}
			
			else if( videoScaleType == 4 /*Upside down*/ )
			{
				vMin = 0.99999
				vMax = 0.00001
				
				uMin = ((i%3)+0.0001)/3
				uMax = ((i%3)+1.0001)/3					
			}
			
			else if( videoScaleType == 5 /*Tiled*/ )
			{
				vMin = 0.00001
				vMax = 0.99999
				
				uMin = ((i%3)+0.0001)/3
				uMax = ((i%3)+1.0001)/3
			}

			else if( videoScaleType == 6 /*Tiled Really Big*/ )
			{
				uMin = ((i%8)+0.0001)/8
				uMax = ((i%8)+1.0001)/8
			}

			else if( videoScaleType == 7 /*Tiled Big*/ )
			{
				uMin = ((i%12)+0.0001)/12
				uMax = ((i%12)+1.0001)/12
			}

			else if( videoScaleType == 8 /*Tiled Single*/ )
			{
				uMin = 0.0001
				uMax = 0.9999
				vMin = 0.0001
				vMax = 0.9999
			}

			else if( videoScaleType == 9 /*Tiled Double*/ )
			{
				uMin = ((i%2)+0.0001)/2
				uMax = ((i%2)+1.0001)/2
			}

			else if( videoScaleType == 10 /*Two by two*/ )
			{
				vMin = 0.00001
				vMax = 0.99999
				
				uMin = ((i%2)+0.0001)/2
				uMax = ((i%2)+1.0001)/2
			}

			else if( videoScaleType == 11 /*Tiled off 1*/ )
			{
				vMin = 0.00001
				vMax = 0.99999
				
				uMin = (((i+1)%3)+0.0001)/3
				uMax = (((i+1)%3)+1.0001)/3
			}

			else if( videoScaleType == 12 /*Tiled 2x4*/ )
			{
				uMin = ((i%6)+0.0001)/6
				uMax = ((i%6)+1.0001)/6
			}

			else if( videoScaleType == 13 /*Tiled Double - with two blank*/ )
			{
				if( ((i)%4) < 2 )
				{
					uMin = ((i%2)+0.0001)/2
					uMax = ((i%2)+1.0001)/2
				}
				else
				{
					uMin = 0.97
					uMax = 0.97
				}
			}

			else if( videoScaleType == 14 /*bluescreen*/ )
			{
				if( (i%8) >= 1 &&  
					(i%8) < 7 )
				{
					uMin = (((i-1)%8)+0.0001)/6
					uMax = (((i-1)%8)+1.0001)/6
				}
				else
				{
					uMin = 0.97
					uMax = 0.97
				}
			}
							 
			EntFire(signName, "SetUMin", uMin, 0)
			EntFire(signName, "SetUMax", uMax, 0)
			EntFire(signName, "SetVMin", vMin, 0)
			EntFire(signName, "SetVMax", vMax, 0)

			EntFire(signName, "Enable", "", 0.1)
		}
	}
}
