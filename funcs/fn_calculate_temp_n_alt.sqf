#define C_IN_KELVINS 273.15		// 0 deg C in K
#define BPRESS_0 1013.25		// ICAO Standard
#define COEF 5.255754495		// From ACE calculateBarometricPressure
#define T_DELTA 0.0065			// The change in temperature per meter in altitude

/*
 * REQUIRES ACE
 * Disable ACE Weather from Addon options to avoid conflicts!
 *
 * Author: P1ker / Ari Hietanen
 *
 * Calculates the altitude and temperature where given temperature and barometric pressure are apparent.
 *
 * Based on ACE fncs
 * https://github.com/acemod/ACE3/blob/76676eee462cb0bbe400a482561c148d8652b550/addons/weather/functions/fnc_calculateTemperatureAtHeight.sqf
 * and
 * https://github.com/acemod/ACE3/blob/76676eee462cb0bbe400a482561c148d8652b550/addons/weather/functions/fnc_calculateBarometricPressure.sqf
 *
 * These two form a system of two equations which can be solved with known _input_bpress and _input_temp
 * Further notes on the steps towards the solution in "calc_temp_n_alt_readme.txt"
 *
 * _input_temp 		:<NUMBER>	The temperature (at _required_altitude)
 * _input_bpress 	:<NUMBER>	The barometric pressure (at _required_altitude)
 *
 * Return Value: 	<ARRAY>
 * 0: temperature at ground level <NUMBER>
 * 1: altitude Above Terrain Level (ATL) <NUMBER>
 *
 * Example:
 * [15,950] execVM "fn_calculate_temp_n_alt.sqf";
 * ^ Requires the .sqf to be in the mission folder
 */
params ["_input_temp", "_input_bpress"];

private ["_o", "_a_0", "_required_altitude", "_required_temperature"];
_o = ace_weather_currentOvercast;

// This calculates it so that player must be elevated a certain amount to reach the value
_a_0 = (getPosASL player select 2) - (getPosATL player select 2);

// Based on the functions linked at rows 15 & 17:
_required_altitude = -(((_input_bpress/(BPRESS_0-10*_o))^(1/COEF)-1)*_input_temp+(C_IN_KELVINS+a_0*T_DELTA)*(_input_bpress/(BPRESS_0-10*_o))^(1/COEF)-C_IN_KELVINS)/(T_DELTA*(_input_bpress/(BPRESS_0-10*_o))^(1/COEF));
_required_temperature = _input_temp+T_DELTA*_required_altitude;

// Debug print
/*
 *hint composeText [
 *	format ["C_IN_KELVINS %1", C_IN_KELVINS], linebreak,
 *	format ["BPRESS_0 %1", BPRESS_0], linebreak,
 *	format ["COEF %1", COEF], linebreak,
 *	format ["T_DELTA %1", T_DELTA], linebreak,
 *	format ["_o %1", _o], linebreak,
 *	format ["_a_0 %1", _a_0], linebreak,
 *	format ["_input_temp %1", _input_temp], linebreak,
 *	format ["_input_bpress %1", _input_bpress], linebreak,
 *	format ["ALTITUDE: %1", _required_altitude], linebreak,
 *	format ["TEMP AT GROUND LVL: %1", _required_temperature]
 *];
 */

[_required_altitude, _required_temperature]
