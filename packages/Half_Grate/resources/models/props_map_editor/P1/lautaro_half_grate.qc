// Created by Crowbar 0.36.0.0

$upaxis Z

$origin 60 3.7 98

$ModelName "props_map_editor/lautaro_p1_half_grate.mdl"

$StaticProp

$BodyGroup "lautaro_half_grate"
{
	studio "lautaro_half_grate_reference.smd"
}


$renamematerial "plasticwall004abc" "plasticwall004a" 

$SurfaceProp "no_decal"

$Contents "solid"

$MaxEyeDeflection 90

$CDMaterials "BEE2\models\props_map_editor\"

$CBox 0 0 0 0 0 0

$BBox -64 -64 -64 0 64 0


$Sequence "idle" {
	"lautaro_half_grate_anims\idle.smd"
	activity "ACT_IDLE" -1
	fadein 0.2
	fadeout 0.2
	fps 1
}
