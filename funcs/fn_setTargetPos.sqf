#define ZERO_POS [1000, 1000, 25]

/*
 *  Author: P1ker1
 *
 *  Moves the target (which is a global var) on Y-axis
 *  using ZERO_pos as the starting point
 *
 *  Arguments:
 *	0: Distance in meters <NUMBER>

 *  Return:
 *	None (setPos command to move the 2nd target)
 *  Example: N/A, use wit the event handlers
 */

params ["_distance_num"];

systemChat str(_distance_num);

private _y = (ZERO_POS select 1) + _distance_num;
private _z = getPosATL TARGET2 select 2;

// +1 and -2.5 to set it so that the background is evenly covered
BACKGROUND_BLOCK setPosATL [1000, _y+5.25, _z-2.5];

TARGET2_BASE setPosATL [1005, _y, _z-1];

TARGET2 setPosATL [1005, _y, _z];

Projectile_Impact_Aux_TGT2 setPos (getPos Projectile_Impact_Aux vectorAdd [0,_y,0]);
