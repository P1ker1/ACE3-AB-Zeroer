// Previous undertakings...
// some values testing			https://www.symbolab.com/solver/step-by-step/%5Cfrac%7B%5Cleft(273.15%2Bt_%7B0%7D%5Cright)%5Ccdot%5Cleft(%5Cleft(%5Cfrac%7B700%7D%7B1013.25%7D%5Cright)%5E%7B%5Cfrac%7B1%7D%7B5.255754495%7D%7D-1%5Cright)%7D%7B-0.0065%7D%3Da%2C%20t_%7B0%7D%3D40%2B0.0065%5Ccdot%20%20a

// NOTE THIS IS NOT ACTUAL CPP FILE. I JUST FORMAT IT FOR HIGHLIGHTING :)


// Step by step
// Raw code
((1013.25 - 10 * GVAR(currentOvercast)) * (1 - (0.0065 * (EGVAR(common,mapAltitude) + _this)) / (KELVIN(GVAR(currentTemperature)) + 0.0065 * EGVAR(common,mapAltitude))) ^ 5.255754495);

// replacing macros
/*
 *  GVAR(currentOvercast) 				= O				for overcast
 *  EGVAR(common,mapAltitude) 			= a_0			for altitude 	at altitude of 0 (map level), in ASL
 *  KELVIN(GVAR(currentTemperature))  	= (t_0+273.15)  for temperature at altitude of 0 (map level), in ASL
 *	_this 								= a_1  			for altitude, 1 for the altitude where the measurement happens 				TODO should this be ASL, too? I guess
 */
((1013.25 - 10 * O) * (1 - (0.0065 * (a_0 + a_1)) / ((t_0+273.15) + 0.0065 * a_0)) ^ 5.255754495);


// replacing coefficients with symbols (excluding 10 and 1 which aren't clearly explained and shouldn't affect too much)
/*
 *  1013.25		= p_0	for barom pressure at 0m ASL
 *  0.0065		= d		for the delta
 *  5.255754495	= c		for c as any random coefficient :)
 *	273.15		= k		for kelvin (transition)
 */
((p_0 - 10 * O) * (1 - (d * (a_0 + a_1)) / ((t_0+k) + d * a_0)) ^ c);
 
 
 // removing spaces and the semi colon + extra parenthesis at the beginning & end
(p_0-10*O)*(1-(d*(a_0+a_1))/((t_0+k)+d*a_0))^c

// Simplify by removing a_0 and overcast
p_0*(1-(d*a_1)/(t_0+k))^c	;

// 

// ^that should be about finished
// t_1
// (GVAR(currentTemperature) - 0.0065 * _this)

t_0 - d*a_1 ;// (=t_1)

// --> 
t_0=t_1+d*a_1	;


// https://quickmath.com/webMathematica3/quickmath/equations/solve/advanced.jsp#c=solve_solveequationsadvanced&v1=a_1%2520%253D%2520p_0*%25281-%2528d*a_1%2529%2F%2528t_0%2Bk%2529%2529%255Ec%250At_0%253Dt_1%2Bd*a_1%250A%250Aa_1%2520%253D%2520p_0*%25281-%2528d*a_1%2529%2F%2528%2528t_1%2Bd*a_1%2529%2Bk%2529%2529%255Ec&v2=a_1%250At_0&v3=1&v4=8

// a_1 based on the first equations : https://cdn.discordapp.com/attachments/695265941377908738/834217444385095741/2179ecc73d317542d014276e108cb90b-3.png

// thus
// https://quickmath.com/webMathematica3/quickmath/equations/solve/advanced.jsp#c=solve_solveequationsadvanced&v1=p_1%2520%253D%2520p_0*%25281-%2528d*a_1%2529%2F%2528%2528t_1%2Bd*a_1%2529%2Bk%2529%2529%255Ec&v2=a_1
//  that is https://quickmath.com/webMathematica3/quickmath/algebra/simplify/advanced.jsp#c=simplify_simplifyadvanced&v1=%2528%2528%2528p_1%2Fp_0%2529%255E%25281%2Fc%2529-1%2529*t_1%2Bk*%2528p_1%2Fp_0%2529%255E%25281%2Fc%2529-k%2529%2F%2528d*%2528p_1%2Fp_0%2529%255E%25281%2Fc%2529%2529

a_1 = -(((p_1/p_0)^(1/c)-1)*t_1+k*(p_1/p_0)^(1/c)-k)/(d*(p_1/p_0)^(1/c))

// with a_1, t_0

// Ok, it works now, let's bring the extra stuff back anyway, now, as it does work
(p_0-10*O)*(1-(d*(a_0+a_1))/((t_0+k)+d*a_0))^c

// after a while
// https://quickmath.com/webMathematica3/quickmath/equations/solve/advanced.jsp#c=solve_solveequationsadvanced&v1=%2528t_0%2Bk-a_1*d%2529%2F%2528t_0%2Bk%2Ba_0*d%2529%253D%2528p_1%2F%2528p_0-10*O%2529%2529%255E%25281%2Fc%2529&v2=a_1&v3=1&v4=8
// now

a_1 = -(((p_1/(p_0-10*o))^(1/c)-1)*t_0+(k+a_0*d)*(p_1/(p_0-10*o))^(1/c)-k)/d

// gotta replace t_0 ofc.

a_1 = -(((p_1/(p_0-10*o))^(1/c)-1)*t_1+(k+a_0*d)*(p_1/(p_0-10*o))^(1/c)-k)/(d*(p_1/(p_0-10*o))^(1/c))