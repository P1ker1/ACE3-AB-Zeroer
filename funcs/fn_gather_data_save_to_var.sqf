/*
 * P1ker / Ari Hietanen
 *
 * Systematically measure the senseable wind speed to measure the accuracy of different methods
 * Yes, this could be done with relatively simple trig (probably) but I kinda feel like coding
 * + it gives nice data points to show later on :)
 *
 */

//params ["_TWS_min", "_TWS_max", "_TWS_change_step", "_start_dir", "_dir_step"];
_TWS_min = 10;
_TWS_max = 10;
_TWS_change_step = 0.5;
_start_dir = 0;

systemChat "Exec";
// Wind dir will stay same – from 180 degs. Only it's strength will change
// The change isn't mandatory either, but it's not necessary in this case.
for "_ws" from _TWS_min to _TWS_max step _TWS_change_step do {
	systemChat "Wind speed changed";
	setWind [_ws, 0, true];
	_trueWS = sqrt((wind select 0)^2+(wind select 1)^2);
	_ownWS = [eyePos ACE_player, true, true, true] call ace_weather_fnc_calculateWindSpeed;

	for "_dir" from _start_dir to _start_dir+90 step _dir_step do {
		systemChat "Dir updated";
		player setDir _dir;
		// Measure the conventional clock dir wind speed
			_MWS = call ace_kestrel4500_measureWindSpeed;
			// With MWS
			// With MWS/0.6
			// With TWS

		// Measure crosswind
			// With MWS
			// With MWS/0.6
			// With TWS

		// sleep 0.01;
	};
};

