/*
Biostatistics I, Stata lab
2022-11-15
Thomas Roosdorp
*/

clear all

frame rename default chd

set scheme white_tableau
 
use "http://www.stats4life.se/data/wcgs", clear

twoway (scatter weight height, msymbol(square) msize(vsmall)) ///
(lfit weight height, lc(black%60) lw(thin)), ///
ytitle("Body Weight (lbs)") xtitle("Height (Inch)") ///
ylabel(100(50)300, angle(horiz) grid) ///
xlabel(60(3)78, grid) plotregion(style(none)) legend(off)

* Part I: Basic descriptive commands
* 1. Count the number of new CHD cases occurred during the follow-up time
count if chd69 == 1
scalar N = r(N)
count

display as text "Incidence of CHD is: " %2.1f `N' / r(N) * 100 "%"

* 2. Count the number of CHD cases among smokers and non-smokers
tabulate smoke chd69

* 3. Produce a table of descriptive statistics (median, 25th percentile, and 75th
* percentile) of systolic blood pressure by CHD status.

tabstat sbp, by(chd69) stats(p25 p50 p75)

* 4. Dichotomise diastolic blood pressure (above/below median) and examine the
* observed CHD risk in the two groups.

summarize dbp, detail
generate high_dbp = dbp >= r(p50) & dbp != .

label var high_dbp "Diastolic Blood Pressure"
label define lowhigh 0 "Low" 1 "High"
label values high_dbp lowhigh

tabulate high_dbp chd69, row

* 5.There are two strange observations: A person with a total cholesterol level of
* 645 units and a person smoking 99 cigarettes per day. Replace them to missing.
summarize chol, detail
replace chol = . if chol > 600

summarize ncigs, detail
replace ncigs = . if ncigs > 90

* Part II: Visualisations
* 1. Produce a scatter plot of weight and height
scatter height weight

* 2. Produce a histogram of the body mass index distribution
histogram bmi, freq

* 3. Overlay a smoothed histogram (kernel density) of the total cholesterol
* distribution among cases and non-cases of CHD.
twoway ///
	(kdensity chol if chd69 == 1, lcolor(red)) ///
	(kdensity chol if chd69 == 0, lcolor(blue)), ///
	ytitle("Density") ///
	xtitle("Cholesterol (mg/dL)") ///
	legend(order(1 "CHD" 2 "No CHD"))

* Extra I:
frame create outbreak
frame change outbreak

input day outbreaks
1 10
2 8
3 12
4 15
5 20
6 19
7 23
8 21
9 20
10 20
end

twoway ///
	(scatter outbreaks day) ///
	(lfit outbreaks day), ///
	ytitle("Outbreaks (n)") xtitle("Day")