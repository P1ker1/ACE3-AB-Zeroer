/**
 * REQUIRES CBA
 * P1ker1 / Ari Hietanen
 *
 * Fires the gun for _amount times with the minimum time between shots
 *
 * The current implementation is flawed!
 * TODO Try chaining the shots with a commands instead of using sleep
 */

 params ["_amount"];

//private _cond = {(player weaponReloadingTime [gunner (vehicle player), currentMuzzle gunner vehicle player]) == 0};
//private _stat = {player forceWeaponFire [currentMuzzle gunner vehicle player, "Single"]};
private _reload_time = getNumber (configFile >> "CfgWeapons" >> (primaryWeapon player) >> "Single" >> "reloadTime");

sleep 1;
private _start_time = time;

for "_i" from 1 to _amount do {
	systemChat format ["%1:  time=%2", _i, time-_start_time];
	player forceWeaponFire [currentMuzzle gunner vehicle player, "Single"];
	sleep (_reload_time+0.4);
};
