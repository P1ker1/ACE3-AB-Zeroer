/*
 *
 *
 *
 *
 *
 * "sign_arrow_direction_pink_f"
 */

params ["_pos", "_amount", "_obj", "_true_speed_scale"];

if (_amount < 2) exitWith {
	hint "Aborted: _amount must be at least 2";
};

if (_true_speed_scale < 0) exitWith {
	hint "Aborted: _true_speed_scale must be a positive number";
};


// Always shifts at 20 ATL, can be a bit higher to note
private _true_WS = vectorMagnitude wind;
private _max_altitude_ATL = 21;

private _h_step = 20/_amount;

private _first_obj = _obj createVehicle (_pos);
_first_obj setDir windDir;
_first_obj setObjectScale (_true_speed_scale^(1/3));
_first_obj setObjectTextureGlobal [0,"#(rgb,8,8,3)color(1,1,1,0)"];  // Invisible

private _new_obj_MWS = 0;
private _wind_color_texture = "#(rgb,8,8,3)color(1,1,1,1)";

private "_first_scale";
private "_first_ws";

for "_i" from _h_step to 20 step _h_step do {

	private _new_obj = _obj createVehicle [0,0,0];
	_new_obj attachTo [_first_obj, [0,0,_i]];

	// Measurable Wind Speed



	_new_obj_MWS = [ATLToASL (getPos _new_obj), true, true, true] call ace_weather_fnc_calculateWindSpeed;

	// Color based on beaufort scale on ace
	// https://github.com/acemod/ACE3/blob/master/addons/weather/functions/fnc_displayWindInfo.sqf#L64

	if (_new_obj_MWS > 0.3) then { _wind_color_texture = "#(rgb,8,8,3)color(0.796,1,1,1)";};
    if (_new_obj_MWS > 1.5) then { _wind_color_texture = "#(rgb,8,8,3)color(0.596,0.996,0.796,1)";};
    if (_new_obj_MWS > 3.3) then { _wind_color_texture = "#(rgb,8,8,3)color(0.596,0.996,0.596,1)";};
    if (_new_obj_MWS > 5.4) then { _wind_color_texture = "#(rgb,8,8,3)color(0.6,0.996,0.4,1)";};
    if (_new_obj_MWS > 7.9) then { _wind_color_texture = "#(rgb,8,8,3)color(0.6,0.996,0.047,1)";};
    if (_new_obj_MWS > 10.7) then { _wind_color_texture = "#(rgb,8,8,3)color(0.8,0.996,0.059,1)";};
    if (_new_obj_MWS > 13.8) then { _wind_color_texture = "#(rgb,8,8,3)color(1,0.996,0.067,1)";};
    if (_new_obj_MWS > 17.1) then { _wind_color_texture = "#(rgb,8,8,3)color(1,0.796,0.051,1)";};
    if (_new_obj_MWS > 20.7) then { _wind_color_texture = "#(rgb,8,8,3)color(1,0.596,0.039,1)";};
    if (_new_obj_MWS > 24.4) then { _wind_color_texture = "#(rgb,8,8,3)color(1,0.404,0.031,1)";};
    if (_new_obj_MWS > 28.4) then { _wind_color_texture = "#(rgb,8,8,3)color(1,0.22,0.027,1)";};
    if (_new_obj_MWS > 32.6) then { _wind_color_texture = "#(rgb,8,8,3)color(1,0.078,0.027,1)";};

	//systemChat str format ["MWS:%1, Tex:%2", _new_obj_MWS, _wind_color_texture];

	_new_obj setObjectTextureGlobal [0, _wind_color_texture];

	// ^1/3 = cube root, because we want to visualize change in scalars with a volume
	_new_obj setObjectScale (_new_obj_MWS/_true_WS)^(1/3);
	// _new_obj setObjectScale _true_speed_scale*(_new_obj_MWS/_true_WS);


	if (_i == _h_step) then {
		_first_scale = getObjectScale _new_obj;
		_first_ws = _new_obj_MWS;
		systemChat format ["First arrow scale: %1",getObjectScale _new_obj];
	}

};

private _top_on_ground = _obj createVehicle [0,0,0];
_top_on_ground attachTo [_first_obj, [0,0,0.1]];
_top_on_ground setObjectTextureGlobal [0, _wind_color_texture];

private _last_scale = getObjectScale _top_on_ground;
systemChat format ["[First scale, Last]: [%1,%2], div=%3",_first_scale,_last_scale,_first_scale/_last_scale];
systemChat format ["[cbrt(First ws), Last]: [%1,%2], div=%3",_first_ws^(1/3),_true_WS^(1/3),_first_ws^(1/3)/_true_WS^(1/3)];
