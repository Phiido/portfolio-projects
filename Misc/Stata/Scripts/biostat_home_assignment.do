/* 
 Home assignment
 Biostatistics I, 7.5 credits (4FH083)
 Fall semester 2022
 2022-11-24
*/

* Question 1) Handling and preparing data for analysis

* Clear memory
clear all

* Import dataset from URL
use "http://www.stats4life.se/data/nhanes2bs.dta"

* Return a description of dataset
summarize

* Assume that the packages mdesc or missings is not available/installed
* Find, quantify and report missing data in variables
quietly {
	noisily di as text "Variable" _col(16) "Missing" _col(32) ///
					   "Total" _col(48) "Percent Missing"
	noisily di as text _dup(60) "-"

	count
	scalar rows = r(N)

	ds
	foreach v of var `r(varlist)' {
		count if `v' == .
		scalar pct = r(N) / rows * 100
		noisily di "`v'" _col(13)  %9.0fc `r(N)' _col(29) %9.0fc rows _col(52) %4.2f pct
	}
	noisily di as text _dup(60) "-"
}

* Replace self reported health values above max score of 5 to missing values
replace hlthstat = . if hlthstat > 5

* Create and attach label for self-reported health status (5-point Likert Scale)
label define hlthstatcat 1 "Excellent" 2 "Very good" 3 "Good" 4 "Fair" 5 "Poor"
label values hlthstat hlthstatcat

* Generate BMI values
gen bmi = weight / (height / 100)^2
format bmi %4.2f
label variable bmi "Body Mass Index (BMI) (kg/m^2)"

* Categorize BMI according to WHO standards for BMI cut-off points
gen bmicat = .
replace bmicat = 0 if bmi < 18.5
replace bmicat = 1 if bmi >= 18.5 & bmi < 25
replace bmicat = 2 if bmi >= 25 & bmi < 30
replace bmicat = 3 if bmi >= 30 & bmi != .

label variable bmicat "Body Mass Index (BMI) categories"

* Create and attach label for BMI categories
label define bmiwho 0 "<18.5" 1 "18.5-25" 2 "25-30" 3 ">=30"
label values bmicat bmiwho

* Categorize serum cholesterol with low/high based on median/50th percentile
quietly su tcresult, detail
gen hightc = tcresult >= r(p50) if tcresult != .

label variable hightc "1 if tcresult >= median, 0 if below"

* Create and attach label for total serum cholesterol indicator variable
label define lowhigh 0 "Low" 1 "High"
label values hightc lowhigh

* Question 2) Numerical and graphical presentation of descriptive statistics
tabstat sex age bmi highbp hightc, by(hlthstat) stat(mean sd) format(%4.2f)
	
graph bar highbp, over(hlthstat) ///
	bar(1, fcolor(eltblue)) ///
	title("High Blood Pressure Prevalence") ///
	ytitle("Proportion") ///
	b1title("Health status") ///
	ylabel(#4, angle(horiz) format(%3.2f)) ///
	blabel(bar, format(%3.2f)) ///
	scheme(s1mono) ///
	plotregion(style(none))	
	
* Question 3) Confidence intervals
ci mean bpsystol // Default significance level at 5%

* Question 4) Test of hypothesis

* Null hypothesis = Sample mean is equal to population mean
* Alternative hypothesis = Sample mean is not equal to the population mean
* Set the significance level at 5%

ttest bpsystol == 130 // Default significance level at 5%
