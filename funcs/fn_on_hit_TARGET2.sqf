params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect"]; 

Projectile_Impact_Aux_TGT2 setPosASL _position;

systemChat "target 2 hit";

_target setDamage 0;

/*   Lets put this on hold for now :)
// Source for the output
// https://github.com/acemod/ACE3/blob/76676eee462cb0bbe400a482561c148d8652b550/extensions/medical/handleDamage.h#L46
private _extensionOutput = "ace_medical" callExtension format ["HandleDamageWounds,%1,%2,%3,%4", _selection, _ammo select 3, "bullet", _woundID];

systemChat str(_extensionOutput);
*/