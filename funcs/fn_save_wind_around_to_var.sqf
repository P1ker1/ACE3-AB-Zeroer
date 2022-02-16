/*
 * REQUIRES ACE
 * P1ker / Ari Hietanen
 *
 * Systematically measure the senseable wind speed to measure the accuracy of different methods
 * Yes, this could be done with relatively simple trig (probably) but I kinda feel like coding
 * + it gives nice data points to show later on :)
 *
 *
 * Must be spawned due to sleep being used, "call" doesn't work
 *
 * E.g.
 * [10, 15, 1, 0, 360, 1, 0.01] spawn PK_fnc_save_wind_around_to_var
 */

params ["_TWS_min", "_TWS_max", "_TWS_change_step", "_start_dir", "_end_dir", "_dir_step", "_sleep_time"];

// TODO test implementation using call & execute immediately when not in menu
// [args] call CBA_fnc_waitUntilAndExecute with !isGamePaused

// Set the global variable defined in init.sqf to an empty array
GATHERED_WIND_DATA = [];
/**
 * Structure:
 * The first 6 are attempts to measure crosswind at different directions
 * The last 2 help distinguishing the logs from each getObjectChildren
 * 2d list like this is easier to convert to table, hence keeping all vals in one arr
 * [
 *  [_MCWS_CD, _MCWS_CD_Corr, _TWS_CD, _MCWS_AD, _MCWS_AD_Corr, _TCWS_AD, _dir, _TWS],
 *  [_MCWS_CD, _MCWS_CD_Corr, _TWS_CD, _MCWS_AD, _MCWS_AD_Corr, _TCWS_AD, _dir, _TWS]
 *  ...
 * ]
 */

systemChat "Exec";
// WIND DIRECTION WILL STAY CONSTANT – from 180 degs. Only it's strength will change
for "_TWS" from _TWS_min to _TWS_max step _TWS_change_step do {
	systemChat format ["Wind speed updated: %1", _TWS];
	setWind [0, _TWS, true];  // blows from 180

	for "_dir" from _start_dir to _start_dir+_end_dir step _dir_step do {

		player setDir _dir;
		systemChat format ["Dir updated: %1", _dir];

		// Update the wind delta, wd, the difference between wind dir and plr dir
		private _wd = abs((ACE_player call CBA_fnc_headDir select 0) - windDir);
		if (_wd > 90) then {
			_wd = abs(_wd-180);
		};

		// Measured/True WS ratios based on prior measurements
		private _MT_ratio = 0.6;
		switch (stance player) do {
			case "PRONE": {}; //0.6
			case "CROUCH": {_MT_ratio = 0.69};
			case "STAND": {_MT_ratio = 0.73};
			default {_MT_ratio = 1};  // Shouldnt get used; swimming & free fall
		};

		// Indent for clarity, no functional effect
		// Measure the conventional clock dir wind speed
			///  With Measured Wind Speed
			private _MWS = [eyePos ACE_player, true, true, true] call ace_weather_fnc_calculateWindSpeed;
			// Kestrel Gives 1 decimal accuracy
			_MWS = [_MWS,1] call BIS_fnc_cutDecimals;

			private _wind_clock_dir = round (_wd/30);

			// sin(12*30) == sin(0*30), but clearer due to 12 being a clock dir, 0 not
			if (_wind_clock_dir == 0 ) then {_wind_clock_dir=12};

			// Gets the approximated direction like the Shift+K arrow
			// with the Kestrel-accuracy wind speed measurement
			// Measured CrossWind Speed Clock Dir
			private _MCWS_CD = sin(_wind_clock_dir*30) * (_MWS);

			// TODO explain _MT_ratio
			private _MCWS_CD_Corr = sin(_wind_clock_dir*30) * (_MWS/_MT_ratio);
			///  With TWS
			private _TWS_CD = sin(_wind_clock_dir*30) * (_TWS);

		// Measure crosswind by degree
			// With MWS
			// Accurate Direction (1 deg error instead of 30 degs)
			private _MCWS_AD = sin(_wd) * (_MWS);
			// With MWS/_MT_ratio
			private _MCWS_AD_Corr = sin(_wd) * (_MWS/_MT_ratio);
			// With TWS
			private _TCWS_AD = sin(_wd) * (_TWS);

		// Push back the array of 6 different crosswind measurements to the gathered data arr
		// True wind speed as 7th element helps with sorting & row selection if the wind speed is also increased
		GATHERED_WIND_DATA pushBack [_MCWS_CD, _MCWS_CD_Corr, _TWS_CD, _MCWS_AD, _MCWS_AD_Corr, _TCWS_AD, _dir, _TWS];

		sleep _sleep_time;

	};
};
