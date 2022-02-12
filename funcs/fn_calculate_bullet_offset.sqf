/*
 * REQUIRES ACE
 *
 * Author: P1ker / Ari Hietanen
 * Calculates the offset between the impact of the bullet and the position aimed at when the weapon was fired
 * from the shooter's point of view.
 * The output is divided in vertical and horizontal components and is given in millradians (MRADs)
 *
 * Additionally logs the distance to the mean point of impacts & measures if you're within acccurate range
 * utilizing the dispersion and remaining bullet velocity
 *
 * Arguments (from Fired EH) https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#Fired:
 * unit: Object - Object the event handler is assigned to
 * weapon: String - Fired weapon
 * muzzle: String - Muzzle that was used
 * mode: String - Current mode of the fired weapon
 * ammo: String - Ammo used
 * magazine: String - magazine name which was used
 * projectile: Object - Object of the projectile that was shot out
 * gunner: Object - gunner whose weapons are firing.
 *
 * Return Value:
 * <ARRAY> [Horizontal(wind) offset in mrads <NUMBER>, Vertical(elevation) offset in mrads <NUMBER>]
 *
 * Example:
 * this addEventHandler ["fired", {_this execVM "fn_calculate_bullet_offset.sqf"}];
 * ^ Requires the .sqf to be in the mission folder
 */

params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
private "_impact_pos";  // Will get set after the flight of the bullet has ended
private _firing_pos = eyePos _gunner;

// The first closest surface the player is aiming at.
// screenToWorld didn't work as smoothly
private _target_pos = (lineIntersectsSurfaces [
	AGLToASL positionCameraToWorld [0,0,0],
	AGLToASL positionCameraToWorld [0,0,3000],
	player,
	objNull,
	true,
	2,
	"FIRE",
	"VIEW",
	true]) select 0 select 0;

if (isNil "_target_pos") then {
	_target_pos = [0,0,0];
	hintSilent "Faulty target position received.";
	[0,0]
};

private _start_to_target = _target_pos vectorDiff _firing_pos;

// The impact position is figured by stopping the loop as soon as the bullet
// "dies." I tried other methods too that didn't require check but couldn't
// It to work yet; this does the trick well enough!
private _previous_speed = vectorMagnitude velocity _projectile;
private _min_ratio = (vectorMagnitude velocity _projectile)/_previous_speed;

// Update the location of the "previous impact"
PREVIOUS_IMPACT_HELPER setPos (getPos LATEST_IMPACT_HELPER);

/*
_projectile addEventHandler ["EpeContactStart", {
	params ["_object1", "_object2", "_selection1", "_selection2", "_force"];

	_impact_pos = getPosASL _object1;
}];
*/

waitUntil {
	if (getPos _projectile select 0 != 0) then {
		_impact_pos = getPosASL _projectile;
		// systemChat str("Impact pos set to" + str(_impact_pos));
	};

	// Ratio between the current and previous bullet velocity.
	// as the bullet starts slowing down, the ratio will decrease more rapidly
	_min_ratio = (vectorMagnitude velocity _projectile)/_previous_speed;

	/* DEBUG
	if (_min_ratio < 0.95) then {
		systemChat "ratio was below 0.95";
		Projectile_DEBUG setPosASL (getPosAsl _projectile);
		true
	};
	// DEBUG
	*/
	_pos_asl = getPosASL _projectile;

	// If the projectile is at almost the same altitude as firing pos and proj is closer to target than firing pos
	if ((abs(_pos_asl#2 - _firing_pos#2) < 0.25) && ((_pos_asl distance _target_pos)<(_pos_asl distance _firing_pos))) then {
		systemChat format ["Dist:%1, Velocity:%2",player distance _projectile,_previous_speed];
	};


	//_previous_speed = vectorMagnitude velocity _projectile;
	// systemChat str(_previous_speed);
	// systemChat ("Min ratio   " + str(_min_ratio));
	// 1) The bullet gets moved to [0,0,0] before it gets deleted
	// or 2) the bullet hits something that slows it down over 4 %
	LATEST_IMPACT_HELPER setPos (getPos _projectile);
	if (getPos _projectile select 0 == 0 || (_min_ratio < 0.96)) then {
		true;
	} else {
		_previous_speed = vectorMagnitude velocity _projectile;
		false;
	};
};

// DEBUG time
private _start_time = time;

private _start_to_impact = _impact_pos vectorDiff _firing_pos;
private _dist_to_impact = vectorMagnitude _start_to_impact;
private _dist_to_target = vectorMagnitude _start_to_target;



// Setting the horizontal component = Wind hold with dot product by comparing the
// target which was aimed at and the point of impact where the bullet ultimately landed
private _horiz_projection_coefficient = (_start_to_target vectorDotProduct _start_to_impact)/((_dist_to_impact)^2);
private _horiz_projection = _start_to_impact vectorMultiply _horiz_projection_coefficient;

private _horiz_offset_in_meters = _horiz_projection distance2d _start_to_target;

// Sets the offset either + or - depending on whether the bullet landed to left or right
if (atan ((_horiz_projection select 0)/(_horiz_projection select 1))
		< atan ((_start_to_target select 0)/(_start_to_target select 1)) ) then {
	_horiz_offset_in_meters = -_horiz_offset_in_meters;
};

private _horiz_offset_in_mrads = _horiz_offset_in_meters/(0.001*(_firing_pos distance _target_pos));



// Delving into the inclination angle / azimuth...
// Sure, there are few additional variables, but it should be easier to follow at least :)
private _ffp_altitude = _firing_pos select 2;
private _target_altitude = _target_pos select 2;
private _impact_altitude = _impact_pos select 2;

// _d = delta_
private _d_height_ffp_tgt = _target_altitude - _ffp_altitude;
private _d_height_ffp_imp = _impact_altitude - _ffp_altitude;

// We have the opposite cathetus and hypotenuse
// getting the difference from plane in mrads
private _d_angle_ffp_tgt = 1000 * (_d_height_ffp_tgt/(_dist_to_target));
private _d_angle_ffp_imp = 1000 * (_d_height_ffp_imp/(_dist_to_impact));

private _vert_offset_in_meters = _d_height_ffp_imp - _d_height_ffp_tgt;
private _vert_offset_in_mrads = _d_angle_ffp_imp - _d_angle_ffp_tgt;


// Debug prints
if (abs(_vert_offset_in_mrads) > 1) then {
	systemChat "Anomaly in vertical offset:";
	systemChat ("Inclination FFP_target : "+str(_d_angle_ffp_tgt));
	systemChat ("Inclination FFP_impact : "+str(_d_angle_ffp_imp));
	//systemChat ""+str();
} else {
	// Update the global variable with offsets so far
	(MRAD_ADJUSTMENTS select 0) pushBack _horiz_offset_in_mrads;
	(MRAD_ADJUSTMENTS select 1) pushBack _vert_offset_in_mrads;
};

private _adjustment_data = [0,0,0];

if (count (MRAD_ADJUSTMENTS select 0) > 0) then {
	_adjustment_data set [0, (MRAD_ADJUSTMENTS select 0) call BIS_fnc_ArithmeticMean];
	_adjustment_data set [1, (MRAD_ADJUSTMENTS select 1) call BIS_fnc_ArithmeticMean];
};

// systemChat str(_adjustment_data);

// Get the current scope adjustments in MRADs
private _scope_adj_mrad = player getVariable ["ace_scopes_Adjustment", [[0, 0, 0], [0, 0, 0], [0, 0, 0]]] select 0;
private _scope_elev = _scope_adj_mrad select 0;
private _scope_wind = _scope_adj_mrad select 1;

// Store the current AtragMX profile values in MRADs
//TODO remove the comments maybe_atrag_elev_mrad = (ace_atragmx_elevationOutput select ace_atragmx_currentTarget)*1000*pi/(60*180);
//_atrag_wind_mrad = (ace_atragmx_windage1Output select ace_atragmx_currentTarget)*1000*pi/(60*180);

// Calculate monitor the distribution of the bullets

private _x_bar = _adjustment_data#0;
private _y_bar = _adjustment_data#1;
private _impact_dist_from_mean = 1000 * (([_x_bar, _y_bar] distance2D [_horiz_offset_in_mrads, _vert_offset_in_mrads])/(_dist_to_impact));

// Updates the averages each time a new value gets added


// TODO fix, currently only compares the old means for prior values (read: early values are less accurate & may break the max)
if ((abs(_vert_offset_in_mrads) <= 1) and count (MRAD_ADJUSTMENTS select 0) > 1) then {
	// DEBUG
	// systemChat format ["Len of array: %1", MRAD_ADJUSTMENTS select 2];
	for "_i" from 0 to (count (MRAD_ADJUSTMENTS select 0)-1) step 1 do {
		(MRAD_ADJUSTMENTS select 2) set [_i,
			1000 * (([_x_bar, _y_bar] distance2D [((MRAD_ADJUSTMENTS select 0) select _i), ((MRAD_ADJUSTMENTS select 1) select _i)])/(_dist_to_impact))
		];
		// DEBUG below
		// systemChat format ["_i: %1", _i];
	};
};

// Set the other helper to mean point of impact
// This conversion works because the target is almost directly to north and the
MEAN_POINT_OF_IMPACTS_HELPER setPosASL (_target_pos vectorAdd [_x_bar*_dist_to_impact/1000,0,(_y_bar*_dist_to_impact)/1000]);

LATEST_IMPACT_HELPER setPosASL (_impact_pos);

/* // Calculate the error for each x/wind/horizontal value
_wind_e = MRAD_ADJUSTMENTS#0 apply {_x-_x_bar};
// Apply arithmetic mean to get the MSE
_mean_wind_error = _wind_e call BIS_fnc_arithmeticMean;
systemChat ("Mean wind error: " + str (_mean_wind_error));

// Calculate the error for each y/elev/vertical value following the previous logic
_elev_e = MRAD_ADJUSTMENTS#1 apply {_x-_y_bar};
_mean_elev_error = _elev_e call BIS_fnc_arithmeticMean;
systemChat ("Mean elev error: " + str (_mean_elev_error)); */


private _mean_tot_error = 0;  // Default for the 1st time a shot is take before reset
if (count (MRAD_ADJUSTMENTS select 2) > 0) then {
	_mean_tot_error = (MRAD_ADJUSTMENTS select 2) call BIS_fnc_ArithmeticMean;
};

// https://github.com/acemod/ACE3/blob/master/extensions/advanced_ballistics/AdvancedBallistics.cpp#L27
private _transonic_speed = (331.3 * sqrt(1 + (ace_weather_currentTemperature) / 273.15));

// *1000 to get MRADs instead of radians
private _current_weapon_dispersion = 1000 * getNumber (configfile >> "CfgWeapons" >> (primaryWeapon player) >> "dispersion");

// 31cm is pretty much the average width of torso in A3 models
private _center_mass_width_in_MRADs = 0.31*((_dist_to_impact)*0.001);

/* systemChat ("Avg impact dist from mean: " + str (_mean_tot_error));

systemChat ("Impact dist from mean: " + str (_impact_dist_from_mean));
 */
// Logs the values to a separate log file if the variable is true
//if () then {
//	["I am Batman!",SNIPER_LOG_FILE] call A3Log;
// };


	/* Commenting the debug out for the hint
	format ["_firing_pos: %1", _firing_pos],
	lineBreak,
	format ["_target_pos: %1", _target_pos],
	lineBreak,
	format ["_impact_pos: %1", _impact_pos],
	lineBreak,
	format ["_start_to_target: %1, %2", _start_to_target, vectorMagnitude _start_to_target],
	lineBreak,
	format ["_start_to_impact: %1, %2", _start_to_impact, _dist_to_impact],
	lineBreak,
	format ["_numerator/_delimeter: %1", _projection_coefficient],
	lineBreak,
	format ["_projection: %1", _projection],
	lineBreak,
	lineBreak,
	*/

hintSilent composeText
[
	//format ["_firing_pos: %1", _firing_pos],
	//lineBreak,
	//format ["_target_pos: %1", _target_pos],
	//lineBreak,
	//format ["_impact_pos: %1", _impact_pos],
	//lineBreak,
	//lineBreak,

	format ["The horizontal offset in meters: %1", _horiz_offset_in_meters],
	lineBreak,
	format ["The vertical offset in meters: %1", _vert_offset_in_meters],
	lineBreak,
	format ["The horizontal offset in mrads: %1", _horiz_offset_in_mrads],
	lineBreak,
	format ["The vertical offset in mrads: %1", _vert_offset_in_mrads],
	lineBreak,
	lineBreak,
	format ["Bullect vel / Transonic vel: %1/%2", _previous_speed, _transonic_speed],
	lineBreak,
	format ["Bullect vel / Transonic vel: %1", _previous_speed/_transonic_speed],
	lineBreak,
	lineBreak,
	format ["Amount of offset pairs: %1", count(MRAD_ADJUSTMENTS#0)],
	lineBreak,
	format ["Avg dispersion in MRADs: %1",  2*_mean_tot_error],
	lineBreak,
	format ["Avg dispersion in MOAs: %1",  2*_mean_tot_error*((60*180)/(1000*pi))],
	lineBreak,
	format ["Max dispersion in MRADs: %1",  2* (selectMax (MRAD_ADJUSTMENTS#2))],	// 2*(distance between the furthest hit from current mean)
	lineBreak,
	lineBreak,
	format ["Offset averages (Wind, Elev):"],
	lineBreak,
	format ["(%1, %2)", _adjustment_data select 0, _adjustment_data select 1],
	lineBreak,
	format ["Corrected based on avgs (Wind, Elev):"],
	lineBreak,
	format ["(%1, %2)", _scope_wind-(_adjustment_data select 0), _scope_elev-(_adjustment_data select 1)]
];

// Print to monitor how the array sizes slow down the script
systemChat format ["It took %1 seconds to calc bullet offset with MRAD_ADJST size of %2",time-_start_time, count (MRAD_ADJUSTMENTS#0)];

// Returns the offsets from the position aimed at in MRADs
[_horiz_offset_in_mrads, _vert_offset_in_mrads]
