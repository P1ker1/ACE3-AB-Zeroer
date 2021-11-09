/*
 * REQUIRES ACE 
 * Disable ACE Weather from Addon options to avoid conflicts!
 *
 * Author: P1ker / Ari Hietanen
 * 
 * Updates the temperature and the altitude of all objects so that the input
 * values can be reached.
 * Also updates (relative) humidity to the given value
 * 
 * The output is divided in vertical and horizontal components.
 *
 * _input_temp 	:<NUMBER> [-27]	The target temperature
 * _input_bpress 	:<NUMBER>	The target barometric pressure
 * _input_humid 	:<NUMBER>	The target relative air humidity (not affected by BP or TEMP)
 * 
 * Return Value:
 * TODO
 *
 * Example:
 * [15,950,0] execVM "fn_calculate_temp_n_alt.sqf";
 * ^ Requires the .sqf to be in the mission folder
 */

params ["_input_temp", "_input_bpress", "_input_humid"];

// humidity can be just set without conflicts; *0.01 to change % to decimals
ace_weather_currentHumidity = _input_humid*0.01;
// systemChat "Humidity set";
// The values that are required to be input.
private _output_vals = [_input_temp, _input_bpress] call PK_fnc_calculate_temp_n_alt;
// systemChat ("Output vals = " +str(_output_vals));
// systemChat "calc temp n alt done";

// If there's no need to change temp or altitude, exits the script here
systemChat format ["output_temp - input temp: %1", abs(((_output_vals select 0) call ace_weather_fnc_calculateTemperatureAtHeight)  - _input_temp)];
systemChat format ["output_bp at alt - input bp at alt: %1", abs(((_output_vals select 0) call ace_weather_fnc_calculateBarometricPressure)-_input_bpress)];
if (abs(((_output_vals select 0) call ace_weather_fnc_calculateTemperatureAtHeight)  - _input_temp) <0.1 || abs(((_output_vals select 0) call ace_weather_fnc_calculateBarometricPressure)-_input_bpress)<0.1) exitWith {};

// Sets the correct temperature
ace_weather_currentTemperature = (_output_vals select 1);

private _required_altitude_change  = (_output_vals select 0) - ((getPosATL plr) select 2);

// Based on player altitude ATL, changes based on input. If unable, 
// systemChat format ["_required_altitude_change :%1", _required_altitude_change];
// Updates the positions for all objects
private "_new_pos";
{
	_new_pos = getPosATL _x;
	_new_pos = _new_pos vectorAdd [0,0,_required_altitude_change];
	_x setPosATL _new_pos; 
} forEach ALL_OBJECTS;

// systemChat "done";
