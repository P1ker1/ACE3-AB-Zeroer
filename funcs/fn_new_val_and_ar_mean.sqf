/*
 * Author: P1ker / Ari Hietanen
 * 
 * After receiving a new value, will calculate a new mean for the global var array and return it's new mean
 *
 * Arguments (from Fired EH) https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#Fired:
 * 
 * <ARRAY> Receiver array
 * <NUMBER> Number to be appended 
 *
 * Return Value:
 * <NUMBER> The new mean of the array
 *
 * Example:
 * 
 * ^ Requires the .sqf to be in the mission folder
 */
 
params ["_source_array", "_insert_num"];
_source_array pushBack _insert_num;

private _return_string = "The current arithmetic mean is "+str(
	_source_array call BIS_fnc_arithmeticMean);

[_source_array, _return_string] 