/*
 * REQUIRES ACE3
 *
 * Author: P1ker / Ari Hietanen
 * 
 * Logs the wind values at player's position from 0 meters Above Terrain Level
 * to 21m ATL (+ you can see the wind ) with increments of 0.1 
 * in the format "Altitude<NUMBER>;Ratio<NUMBER>".
 * The logs are saved in the newest .rpt file at
 * "C:\Users\USERNAME\AppData\Local\Arma 3"
 * 
 * From the ratio you can see the full wind speed can be measured at 20 ATL and above
 * unless there's an obstacle (such as a hill or building) blocking the measurement
 * 
 * Return Value:
 * Nil
 *
 * Example:
 * execVM "fn_log_wind_from_0_to_21.sqf";
 * ^ Requires the .sqf to be in the mission folder
 */

// Initializing values & logging the first line to .rpt
diag_log "Wind speed is";
_ownWS = 0;

// True wind speed can be
_trueWS = vectorMagnitude wind;
diag_log _trueWS;
_measured_altitude = 0.01;

while {_measured_altitude < 21} do
{
player_pos_x = getPos ACE_player select 0;
player_pos_y = getPos ACE_player select 1;

// Note player pos is used
_ownWS = [ATLToASL [player_pos_x, player_pos_y, _measured_altitude], true, true, true] call ace_weather_fnc_calculateWindSpeed;
diag_log format["%1;%2", _measured_altitude, _ownWS/_trueWS] ;
_measured_altitude = _measured_altitude + 0.1;
};
