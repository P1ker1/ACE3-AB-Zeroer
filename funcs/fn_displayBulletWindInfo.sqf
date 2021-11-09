/*
 *  Author: P1ker1
 *
 *  Records bullet altitude and wind during the flight of the bullet and displays the data
 *  in a hint box when the bullet "dies" / alive _projectile returns false
 *  It is intended to be used with "Fired" event handler
 *
 *  Arguments: https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#Fired
 *  Return: displays the hint (last command)
 *  Example: N/A, use wit the event handlers
 */

params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

// _bullet data
private _bullet = _projectile;  // Object, the fired _bullet
private _bulletPos = getPos _bullet;
// private _aboveBulletPos = _bulletPos vectorAdd [0,0,200];
private _bulletAltitudes = [];
private _crosswindValues = [];
private _maxBulletAltATL = 0;
private _previousSpeed = speed _bullet;
private "_bulletPosATL";
private "_bulletPosASL";
private "_currentAltATL";

// _shooter data
private _shooter = _this select 7;
private _firingDir = getDir _shooter;

// Setting up some wind stuff
private _wd = abs((_shooter call CBA_fnc_headDir select 0) - windDir);
if (_wd > 90) then {_wd = abs(_wd-180)};

private _maxCW = 0;
private "_currentW";
private "_currentCW";

// Setting up the minimum
_previousSpeed = speed _bullet;
sleep 0.2;
_minRatio = (speed _bullet)/_previousSpeed;

// Actual loop to collect the data
while {alive _bullet} do {
	_bulletPosATL = getPosATL _bullet;
	_bulletPosASL = getPosASL _bullet;
	//_aboveBulletPos = _bulletPos vectorAdd [0,0,200];
	_currentAltATL = _bulletPosATL select 2;

	_currentW = [_bulletPosASL, true, true, true] call ace_weather_fnc_calculateWindSpeed;
	_currentCW = cos(abs(90-_wd)) * (_currentW);
	_crosswindValues pushBack _currentCW;

	if (_currentAltATL > _maxBulletAltATL) then {
		_maxBulletAltATL = _currentAltATL;
	};

	if (_currentCW > _maxCW) then {
		_maxCW = _currentCW;
	};

	if ((speed _bullet)/_previousSpeed < _minRatio) exitWith {};

	hint composeText
	[
	format ["Current altitude: %1", _currentAltATL],
	lineBreak,
	format ["Current CW: %1", _currentCW],
	lineBreak,
	format ["C _bullet speed / prev b speed: %1", ((speed _bullet)/_previousSpeed)]
	];

	_previousSpeed = speed _bullet;
	sleep 0.2;
};

// Display the data at the end
hint composeText
[ 	format ["Max altitude: %1", _maxBulletAltATL],
	lineBreak,
	format ["Max CW: %1", _maxCW],
	lineBreak,
	format ["Mean CW: %1", _crosswindValues call BIS_fnc_arithmeticMean]
];
