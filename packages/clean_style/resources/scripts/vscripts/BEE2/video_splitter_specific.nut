// Gutted and modified video_splitter script, designed to be controlled by the BEE2 compiler.

ARRIVAL_VIDEO <- 0
DEPARTURE_VIDEO <- 1

scaleOverride = -1


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
	for(local i=0;i<width;i+=1)
	{
		for(local j=0;j<height;j+=1)
		{
			local panelNum = 1 + width*j + i
			local signName
			
			if (videoType == DEPARTURE_VIDEO || videoType == DEPARTURE_DESTRUCTED_VIDEO )
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

function StartArrivalVideo(width, height, use_destructed)
{
	EntFire("@arrival_video_master_horiz", "Enable", "", 0.1)
	StartVideo(ARRIVAL_VIDEO, width, height)
}

function StartDepartureVideo(width, height, use_destructed)
{
	EntFire("@departure_video_master_horiz", "Enable", "", 0.1)
	StartVideo(DEPARTURE_VIDEO, width, height)
}

function StartVideo(videoType, width, height, use_destructed)
{
	local videoScaleType = 0
	local randomDestructChance = 0
	
	if (use_destructed == 1)
	{
		videoScaleType = RandomInt(1,5)
		randomDestructChance = RandomInt(30, 70)
	}
	else
	{
		videoScaleType = RandomInt(6,7)
	}
	
	if (scale_override > -1)
	{
		videoScaleType = scale_override
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
				EntFire(signName, "Kill", "", 0)
				continue
			}
			
			EntFire(signName, "SetUseCustomUVs", 1, 0)
			
			local uMin = (i+0.0001)/(width)
			local uMax = (i+1.0001)/(width)
			local vMin = (j+0.0001)/(height)
			local vMax = (j+1.0001)/(height)
			
			if( videoScaleType == 0 /*full elevator*/ ) 				
			{
			
			}				
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
