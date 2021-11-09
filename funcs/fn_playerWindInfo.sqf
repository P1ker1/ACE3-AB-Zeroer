/*
Author: P1ker1

Displays the current wind info every _interval seconds for _amount times.

*/
/*

params [
	["_amount"],
	["_interval"],
	];

_amount = parseNumber (_this select 0);
_interval = parseNumber (_this select 1);


systemChat str _amount

_ownWS = "";
_trueWS = "";
_hintWindInfo = "";

_i = 0;
while {_i < 10} do {
*/

_ownWS = [eyePos ACE_player, true, true, true] call ace_weather_fnc_calculateWindSpeed;
_trueWS = [(eyePos ACE_player) vectorAdd [0,0,200], true, true, true] call ace_weather_fnc_calculateWindSpeed;

hint composeText [format ["Sensed wind: %1", _ownWS], lineBreak, format["True wind: %1", _trueWS], lineBreak, format["True wind: %1", _ownWS/_trueWS]];
