params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

systemChat "Executing handleDamage";

// TODO/Idea: calculate damage that would be dealt to the target while it actually doesn't sustain animatePylon
// Due to "_this allowDamage false;"

/*    Lets put this on hold for now :)
 * Source for the output
// https://github.com/acemod/ACE3/blob/76676eee462cb0bbe400a482561c148d8652b550/extensions/medical/handleDamage.h#L46
private _extensionOutput = "ace_medical" callExtension format ["HandleDamageWounds,%1,%2,%3,%4", _hitIndex, _damage, _typeOfDamage, _woundID];

systemChat str(_extensionOutput);
*/
