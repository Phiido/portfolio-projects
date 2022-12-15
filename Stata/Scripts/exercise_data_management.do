* MSc Public Health Data Management Exercise
* Course: Collecting and Organizing Epidemiological Data (4FH084)
* Date: 2022-12-13

* ----------------- Open STATA project folder
cd "~\Documents\STATA\data_management"

* ----------------- Start log process
cd logs
log using "latest.log", replace
cd ..

* ----------------- Importing data
cd data\original
clear all

* Convert data files
import delimited exercise1.csv, clear
cd ..
save exercise1.dta, replace

cd original
use exercise2
cd ..
save exercise2.dta, replace

cd original
import excel exercise3.xlsx, clear firstrow
cd ..
save exercise3.dta, replace

* Combining data sets
use exercise1, clear
append using exercise2
merge 1:1 woman_id using exercise3
sort woman_id

cd ..

* ----------------- Describing the data
describe
list in 1/5

* ----------------- Checking for missing data
misstable sum, all

* ----------------- Validate and clean data
* ID variable must contain distinct values
duplicates report woman_id // No duplicates found

* 1 non-valid observation found
drop if age >= 50

* 1 non-valid value found in address
replace address = "" if !inlist(address, "Kungsholmen", "Solna", "Sodermalm")

* 1 non-valid combination with response for non contraceptive_pill user
drop if contraceptive_pill == 0 & years_pill > 0 & years_pill != .

* Dirty method to keep wanted missing values before recursion
replace years_pill = 0 if years_pill == .

* Finding and removing missing values recursively
ds, has(type numeric)
foreach v of var `r(varlist)' {
	drop if `v' == .
}

ds, has(type string)
foreach v of var `r(varlist)' {
	drop if `v' == ""
}

replace years_pill = . if years_pill == 0

* Encode categorical data
encode address, generate(district)
encode nationality, generate(nationality_c)

* Move newly generated variables
order district, after(address)
order nationality_c, after(nationality)

* Cleanup non-needed variables
drop _merge
drop address
drop nationality
rename nationality_c nationality

* ----------------- Labelling data
label variable woman_id "Unique study ID"
label variable married "Are you currently married?"
label variable contraceptive_pill "Before you got pregnant, were you taking the contraceptive pill?"
label variable years_pill "If YES, how many years have you been taking the pill for?"
label variable nationality "What is your nationality?"
label variable first_pregnancy "Is this your first pregnancy?"
label variable age "How old is the respondent (years)"
label variable district "What clinic was the respondent recruited from?"
label variable anc_visit "Which antenatal care (ANC) visit is this (count)"

* Create labels
label define yesno 0 "No" 1 "Yes"
label define married_status 0 "Single" 1 "Married" 2 "Separated"

* Attaching labels
label values contraceptive_pill yesno
label values first_pregnancy yesno
label values married married_status

* ----------------- Exporting cleaned data
cd data
save exercise_clean.dta, replace
export excel using exercise_clean.xlsx, firstrow(var) replace
export delimited using exercise_clean.csv, delimiter(",") replace // Use of outsheet is deprecated

log close