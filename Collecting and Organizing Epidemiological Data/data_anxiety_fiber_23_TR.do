/***************************************************************************
Exploring the relation between mental health and dietary fiber intake.
Only for demonstration purposes!

Package egenmore is required for dummy data generation using binary sequences.

By Thomas Roosdorp
2023-01-13
****************************************************************************/

* CREATING DUMMY DATA -------------------------------------------------------
clear all

* How many dummy respondents to generate data for
scalar n = 30

set obs `=n'
set seed 1234 // Set the seed for reproducibility

* Create a list of variable names
local list_of_vars "id age gender q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14 q15 q16 q17 q18"

* Split the list into separate elements
local vars: list retokenize list_of_vars

* Loop through the list of variables as elements
quietly{
	foreach var of local vars {
		* Create a new empty variable with the name of the current element
		generate int `var' = .
	}
}

* Generate values to each variable with different distributions for n observations
quietly {
	forvalues i = 1/`=n' {
		replace id = `i' in `i'
		* Section A. Dietary habits
		replace q1 = runiformint(0,7) in `i'
		replace q2 = runiformint(0,7) in `i'
		replace q3 = runiformint(0,4) in `i'
		replace q4 = runiformint(0,4) in `i'
		replace q5 = runiformint(0,4) in `i'
		replace q6 = runiformint(0,7) in `i'
		replace q7 = rbinomial(1, 0.25) in `i'
		replace q8 = runiformint(0,4) in `i' 
	
		* Section B. Anxiety symptoms
		replace q9 = runiformint(0,3) in `i'
		replace q10 = runiformint(0,3) in `i'
		replace q11 = runiformint(0,3) in `i'
		replace q12 = runiformint(0,4) in `i'
		replace q13 = runiformint(0,4) in `i'
		replace q14 = runiformint(0,4) in `i'
		replace q15 = runiformint(0,4) in `i'
		replace q16 = runiformint(0,4) in `i'
		replace q17 = runiformint(0,4) in `i'
		replace q18 = round(rnormal(100,25)) in `i' // Multi-choice question
	
		* Section C. Demographics
		replace age = runiformint(18, 64) in `i'
		replace gender = runiformint(0, 1) in `i'
	}
}

* Generate multi-choice result into a many-to-one string from a random 
* normal distribution. Needs to be string to keep leading zeros.
egen string_binary = base(q18)

drop q18
rename string_binary q18
order q18, after(q17)

* Generate fake missing data for a few select variables for demonstration
forvalues i = 1/`=n' {
	
	* Dietary intake
	if rbinomial(1, 0.05) == 1 {
		replace q4 = . in `i'
		replace q8 = . in `i'
	}
	* Anxiety symptoms
	if rbinomial(1, 0.05) == 1 {
		replace q12 = . in `i'
		replace q15 = . in `i'
		replace q17 = . in `i'
	}
}

* VALIDATION AND CLEANING DATA ------------------------------------------------

misstable sum, all

* ID variable must contain distinct values
duplicates report id

drop if age < 18 & age > 64

* Finding and removing missing values recursively
ds, has(type numeric)
foreach v of var `r(varlist)' {
	drop if `v' == .
}

* Label variables
* DEMOGRAPHICS
label variable id "Assigned identifier for respondents"
label variable age "Reported age of respondent"
label variable gender "Which gender respondent identifies with"

* DIETARY HABITS
label variable q1 ///
	"Over the past month, how often did you eat fresh fruit?"
label variable q2 ///
	"Over the past month, how often did you eat avocado or guacamole?"
label variable q3 ///
	"How much of the time eating did you eat cooked vegetables/greens?"
label variable q4 ///
	"How much of the time eating did you eat raw vegetables/greens?"
label variable q5 ///
	"How much of the time eating did you eat whole grain foods?"
label variable q6 ///
	"Over the past month, how often did you ingest probiotic foods?"
label variable q7 "Have you taken probiotic supplements the last month?"
label variable q8 "How would you rate your fiber intake?"

* ANXIETY SYMPTOMS
label variable q9 "Feeling nervous or anxious"
label variable q10 "Worrying too much about different things"
label variable q11 "Trouble relaxing"
label variable q12 "Problems with concentration or attention"
label variable q13 ///
	"Trouble functioning at home, work or socially due to anxiety"
label variable q14 "Depressed mood"
label variable q15 "Feelings of insomnia"
label variable q16 "Feelings of drymouth or headaches"
label variable q17 "Feelings of pressure or constriction in the chest"
label variable q18 "Experience of anxiety symptoms"

* Create value label sets
label define gender ///
	0 "Female" ///
	1 "Male" ///
	2 "Other" //

label define time_freq_8_scale ///
	0 "1 time or less in the past month" ///
	1 "2-3 times in the past month" ///
	2 "1 time per week" ///
	3 "2 times per week" ///
	4 "3-4 times per week" ///
	5 "5-6 times per week" ///
	6 "1 time per day" ///
	7 "2 or more times per day"

label define time_prop_5_scale ///
	0 "Almost never or never" ///
	1 "About 1/4 of the time" ///
	2 "About 1/2 of the time" ///
	3 "About 3/4 of the time" ///
	4 "About always or always"
								 
label define yesno 0 "No" 1 "Yes"

label define rating_fiber_5_scale ///
	0 "Very high" ///
	1 "Somewhat high" ///
	2 "Average" ///
	3 "Somewhat low" ///
	4 "Very low"
							  
label define freq_anx_4_scale ///
	0 "Not at all" ///
	1 "Several days" ///
	2 "Over half the days" ///
	3 "Nearly every day"
								
label define rating_anx_5_scale ///
	0 "Not present" ///
	1 "Mild" ///
	2 "Moderate" ///
	3 "Severe" ///
	4 "Very severe"
	
* Dynamically assigns value labels to variables
* Return a list of available datasets and their characteristics
quietly: ds

* Loop through the variables in the dataset
foreach v of var `r(varlist)' {
	
    * Apply label values to the variables based on the variable name
	if inlist("`v'", "gender") {
		label values `v' gender
	}	
    if inlist("`v'", "q1", "q2", "q6") {
        label values `v' time_freq_8_scale
    }
    if inlist("`v'", "q3", "q4", "q5") {
        label values `v' time_prop_5_scale
    }
    if inlist("`v'", "q7") {
        label values `v' yesno
    }
    if inlist("`v'", "q8") {
        label values `v' rating_fiber_5_scale
    }
    if inlist("`v'", "q9", "q10", "q11") {
        label values `v' freq_anx_4_scale
    }
    if inlist("`v'", "q12", "q13", "q14", "q15", "q16", "q17") {
        label values `v' rating_anx_5_scale
    }
}

* DESCRIBING THE DATA --------------------------------------------------------
misstable summarize
summarize age
tabulate gender
summarize q1-q8 	// Dietary intake
summarize q9-q18 	// Anxiety symptoms

* ORGANIZING THE DATA --------------------------------------------------------
egen age_cat = cut(age), at(18, 25, 35, 45, 55, 65) icodes

order age_cat, after(age)

label variable age_cat "Age categories"
label define age_cat_5 0 "18-24" 1 "25-34" 2 "35-44" 3 "45-54" 4 "55-64"
label values age_cat age_cat_5

* Average the score for fiber intake and anxiety scores for each individual
egen fiber_score = rowmean(q1-q8)
egen anxiety_score = rowmean(q9-q17)

format fiber_score anxiety_score %02.1f

label variable fiber_score "Average score for fiber intake score"
label variable anxiety_score "Average score for anxiety score"

summarize fiber_score anxiety_score, detail

* Dummy encoding fiber and anxiety scores with mean as cutoff point
quietly su fiber_score, detail
generate high_fiber = fiber_score >= r(mean) if fiber_score != .

quietly su anxiety_score, detail
generate high_anxiety = anxiety_score >= r(mean) if anxiety_score != .

label variable high_fiber ///
	"Indicator variable for high fiber intake with cutoff at mean value"
label variable high_anxiety ///
	"Indicator variable for high anxiety with cutoff at mean value"

label define lowhigh 0 "Low" 1 "High"
label values high_fiber high_anxiety lowhigh

* EXPLORATORY VISUALIZATION --------------------------------------------------
histogram fiber_score
histogram anxiety_score
scatter fiber_score anxiety_score

* ANALYSIS -------------------------------------------------------------------
tabstat high_fiber high_anxiety, by(age_cat) stat(mean median sd)
correlate high_fiber high_anxiety
tabulate high_fiber high_anxiety, chi2