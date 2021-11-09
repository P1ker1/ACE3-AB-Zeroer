player addaction ["Show wind ratio", 
{
	_ownWS = [eyePos ACE_player, true, true, true] call ace_weather_fnc_calculateWindSpeed; 
	_trueWS = [(eyePos ACE_player) vectorAdd [0,0,200], true, true, true] call ace_weather_fnc_calculateWindSpeed;
	systemChat format["Sensed/True: %1", _ownWS/_trueWS];
},
"", 0, false, false];