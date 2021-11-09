params ["_distance"];

if (parseNumber _distance == 0) then {
	systemChat "Faulty input. Insert only integers.";
} else {
	systemChat "Input OK."
};
