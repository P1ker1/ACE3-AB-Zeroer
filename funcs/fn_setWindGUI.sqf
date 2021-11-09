params ["_full_wind_speed", "_wind_dir"];

// The trigonometry works fine, but due to systemChat prints, let's tidy em up
while {_wind_dir < 0} do {_wind_dir = _wind_dir + 360;};
while {_wind_dir > 360} do {_wind_dir = _wind_dir - 360;};

systemChat ("Wind is set to " + str(_full_wind_speed) + " m/s coming from the direction " + str(_wind_dir) + "°");

// - 180 bacause command windDir gives the value "opposite" to the "actual" wind direction
// We wanna know where the wind is blowing _FROM_
private _x_comp = _full_wind_speed * sin(_wind_dir - 180);
private _y_comp = _full_wind_speed * cos(_wind_dir - 180);

setWind [_x_comp, _y_comp, true];  // true -> Immediate change
