// Inspiration taken from Ruthberg's 360 course
// https://forums.bohemia.net/forums/topic/171228-sp-360-degree-training-course/

enableSaving [false, false];

waitUntil {!isNull player};

["teleportHandler", "onMapSingleClick", {
	if (_alt) then {
		player setPosATL _pos;
	};
}] call BIS_fnc_addStackedEventHandler;

Projectile_Impact_Aux_TGT2 = "Sign_Sphere10cm_F" createVehicle [0,0,0];
// DEBUG
// Projectile_DEBUG = "Sign_Sphere100cm_F" createVehicle [0,0,0];

setWind [random 4, random 4, true];

// stores the difference between ASL height and ATL height at player's pos
a_0 = (getPosASL player select 2) - (getPosATL player select 2);

// Adding all objects near player together so they can be moved with using forEach
ALL_OBJECTS = [];
{ALL_OBJECTS pushBack _x} forEach (nearestObjects [player, ["ALL"], 200]);

// Enable the MRAD Error hints
TrainingCourse_MRAD_error = true;

// Stores the MRAD error valus & Resets them every time PGUP or PGDN is pressed
MRAD_ADJUSTMENTS = [[],[]]; // first array is for horizontal, second for vertical [x,y]
waituntil {!(IsNull (findDisplay 46))};
_keyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", "if (_this select 1 == 201 || _this select 1 == 209) then {
	hintSilent ""MRAD_ADJUSTMENTS reset to [[],[]]"";
	MRAD_ADJUSTMENTS = [[],[]];
}"];


// Ace addaction to control the wind script, except it's not required in init as it gets executed in on respawn, too
// _action = ["Set tgt & firing pos values", "Set target & firing pos values", "", {createDialog "LaptopTitle";},{true}] call ace_interact_menu_fnc_createAction;

// [player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

player addaction ["Display wind info", {
hint composeText [format ["Sensed wind: %1", ([eyePos ACE_player, true, true, true] call ace_weather_fnc_calculateWindSpeed)],
                lineBreak,
				format["True wind: %1", ([(eyePos ACE_player) vectorAdd [0,0,200], true, true, true] call ace_weather_fnc_calculateWindSpeed)],
				lineBreak,
				format["Sensed/True: %1", ([eyePos ACE_player, true, true, true] call ace_weather_fnc_calculateWindSpeed)/([(eyePos ACE_player) vectorAdd [0,0,200], true, true, true] call ace_weather_fnc_calculateWindSpeed)]];
}, "", 0, false, false];
