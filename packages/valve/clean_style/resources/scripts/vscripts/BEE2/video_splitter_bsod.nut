// Gutted and modified video_splitter script, designed to be controlled by the BEE2 compiler.
// This is used for the bluescreen video.
ARRIVAL_VIDEO <- 0
DEPARTURE_VIDEO <- 1


//============================

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

function StopVideo(videoType,width,height)
{
	local signName;
	if (videoType == DEPARTURE_VIDEO)
		{
			signName = "@departure_sign_*";
		}
		else
		{
			signName = "@arrival_sign_*";
		}	
	EntFire(signName, "Disable", "", 0)
	EntFire(signName, "killhierarchy", "", 1.0)
}

function StartArrivalVideo(width, height, use_destructed)
{
	StartVideo(ARRIVAL_VIDEO, width, height, use_destructed)
	EntFire("@arrival_video_master_horiz", "Enable", "", 0.1)
}

function StartDepartureVideo(width, height, use_destructed)
{
	StartVideo(DEPARTURE_VIDEO, width, height, use_destructed)
	EntFire("@departure_video_master_horiz", "Enable", "", 0.1)
}

function StartVideo(videoType, width, height, use_destructed)
{
	local randomDestructChance = 0
	
	if (use_destructed == 1)
	{
		randomDestructChance = RandomInt(30, 70)
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
					
			if( randomDestructChance > RandomInt(0,100) )
			{
				EntFire(signName, "killhierarchy", "", 0)
				continue
			}
			
			EntFire(signName, "SetUseCustomUVs", 1, 0)
			
			local uMin = (i+0.0001)/(width)
			local uMax = (i+1.0001)/(width)
			local vMin = (j+0.0001)/(height)
			local vMax = (j+1.0001)/(height)
			
			// Always use BSOD scale type
			if( (i%8) >= 1 && (i%8) < 7 )
			{
				uMin = (((i-1)%8)+0.0001)/6
				uMax = (((i-1)%8)+1.0001)/6
			}
			else
			{
				uMin = 0.97
				uMax = 0.97
			}
			
			EntFire(signName, "SetUMin", uMin, 0)
			EntFire(signName, "SetUMax", uMax, 0)
			EntFire(signName, "SetVMin", vMin, 0)
			EntFire(signName, "SetVMax", vMax, 0)
			
			EntFire(signName, "Enable", "", 0.2)
		}
	}
}
