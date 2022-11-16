* Program to simulate the random generation on a larger scale
* Creating the program/function to house the code
program define sim_test, rclass // class that returns results with r()

syntax [, obs(real 100) theta(real 0.5)] // Creating arguments with default values
drop _all // Drops all observations and variables
set obs `obs' // Set obs with value specified from the argument obs
gen y = rbinomial(1, `theta') // Generate binomial with value from argument theta
quietly: summarize y // Generate (invisibly) descriptive statistics which saves using r()

* Finally return the value from r(mean) as a scalar named est_theta
* A scalar is a named entity that stores a single value (number, string or missing)
return scalar est_theta = r(mean)

end

* Run the program/function using default values
sim_test

* Command that uses Monte Carlo simulation for repeated random sampling
simulate est_theta = r(est_theta), /// // Save the result from the command as est_theta
	reps(100): /// // Repeat this 100 times
	sim_test, /// // Which program/function do we want to use
	obs(10000) theta(0.2) // Input values for the program/function arguments

* As one line
* simulate est_theta = r(est_theta), reps(100): sim_test, obs(10000) theta(0.2)
	
summarize est_theta
histogram est_theta, normal

* Doing a much larger sampling with 100,000 repitions
quietly { // quietly stops the command to output anything to the console
	simulate est_theta = r(est_theta), reps(100000): sim_test, obs(10000) theta(0.2)
}

summarize est_theta
histogram est_theta, normal