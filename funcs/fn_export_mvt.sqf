/*
 *  Author: P1ker1
 *
 *  Logs muzzle velocities to __ .rpt __   TIME;SPEED
 *  Utilizes CBA_missionTime which is slightly stabler
 *  It is intended to be used with "Fired" event handler
 *
 *  Arguments: https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#Fired
 *  Return: displays the hint (last command)
 *  Example: N/A, use wit the event handlers
 */

params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
private _start = CBA_missionTime;
private _previous_speed = speed _projectile;
private _current_ratio = (speed _projectile)/_previous_speed;

// While the bullet is alive,
waitUntil {
	diag_log format["%1;%2", CBA_missionTime -_start, speed _projectile/3.6] ;
	_current_ratio = (speed _projectile)/_previous_speed;
	_previous_speed = speed _projectile;

	// The mv won't decrease to 96.5% unless sth hit it
	!alive _projectile || (_current_ratio < 0.965);
};

systemChat "WaitUntil finished – Values extracted to .rpt";
