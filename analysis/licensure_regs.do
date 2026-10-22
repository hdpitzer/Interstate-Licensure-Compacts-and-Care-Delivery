clear all 

global wd "/Volumes/Untitled/Interstate Licensure"

*********************************************************************

use "${wd}/data/output/licensure_full_2017_2023", clear

**Create specialty indicators

gen psychologist = 0
foreach var in specialty1 specialty2 specialty3 specialty4 specialty5 specialty6 specialty7 specialty8 {
	replace psychologist = 1 if strpos(lower(`var'), "psycholog")
}

gen psychiatry = 0
foreach var in specialty1 specialty2 specialty3 specialty4 specialty5 specialty6 specialty7 specialty8 {
	replace psychiatry = 1 if strpos(lower(`var'), "psychiatr")
}

gen pcp = 0
foreach var in specialty1 specialty2 specialty3 specialty4 specialty5 specialty6 specialty7 specialty8 {
	replace pcp = 1 if ///
		strpos(lower(`var'), "family") | ///
		strpos(lower(`var'), "internal medicine") | ///
		strpos(lower(`var'), "geriatric medicine") | ///
		strpos(lower(`var'), "general practice") | ///
		strpos(lower(`var'), "prevent") | ///
		strpos(lower(`var'), "pediatric")
}

gen surgical = 0
foreach var in specialty1 specialty2 specialty3 specialty4 specialty5 specialty6 specialty7 specialty8 {
	replace surgical = 1 if ///
		strpos(lower(`var'), "surgery") | ///
		strpos(lower(`var'), "surgical")
}

gen nonsurg = 0
foreach var in specialty1 specialty2 specialty3 specialty4 specialty5 specialty6 specialty7 specialty8 {
	replace nonsurg = 1 if ///
		strpos(lower(`var'), "urology") | ///
		strpos(lower(`var'), "rheumatology") | ///
		strpos(lower(`var'), "radiation oncology") | ///
		strpos(lower(`var'), "pulmonary") | ///
		strpos(lower(`var'), "ophthalmology") | ///
		strpos(lower(`var'), "obstetrics") | ///
		strpos(lower(`var'), "neurology") | ///
		strpos(lower(`var'), "nephrology") | ///
		strpos(lower(`var'), "medical oncol") | ///
		strpos(lower(`var'), "hematology") | ///
		strpos(lower(`var'), "gastroent") | ///
		strpos(lower(`var'), "endocrin") | ///
		strpos(lower(`var'), "dermatology") | ///
		strpos(lower(`var'), "addiction") | ///
		strpos(lower(`var'), "immunol") | ///
		strpos(lower(`var'), "electrop") | ///
		strpos(lower(`var'), "cardiovascular") | ///
		strpos(lower(`var'), "critical care") | ///
		strpos(lower(`var'), "emergency") | ///
		strpos(lower(`var'), "gynecolog") | ///
		strpos(lower(`var'), "infectious") | ///
		strpos(lower(`var'), "interventional") | ///
		strpos(lower(`var'), "nuclear") | ///
		strpos(lower(`var'), "pain manage") | ///
		strpos(lower(`var'), "physical med") | ///
		strpos(lower(`var'), "podiatry") | ///
		strpos(lower(`var'), "sleep medi") | ///
		strpos(lower(`var'), "sports medi") | ///
		strpos(lower(`var'), "palliat") | ///
		strpos(lower(`var'), "medical geneti") | ///
		strpos(lower(`var'), "hyper") | ///
		strpos(lower(`var'), "heart fail") | ///
		strpos(lower(`var'), "otolaryngology")
}

gen diagnostic = 0
foreach var in specialty1 specialty2 specialty3 specialty4 specialty5 specialty6 specialty7 specialty8 {
	replace diagnostic = 1 if ///
		strpos(lower(`var'), "anesthes") | ///
		strpos(lower(`var'), "diagnost") | ///
		strpos(lower(`var'), "patholo")
}

**Additional cleaning

drop if graduationyear>year

gen grad_cohort = floor(graduationyear/10)*10

gen female = 0
replace female = 1 if gender == "F"

gen multistate = 0
replace multistate = 1 if n_unique_states>1



**Keep only MD and DOs for IMLC
egen category_count = rowtotal(psychiatry pcp surgical nonsurg diagnostic)
drop if category_count == 0



save "${wd}/data/output/licensure_ch2_2017_2023", replace

merge m:1 state using "${wd}/data/input/telehealth_dates", keep(1 3) nogen
foreach var in effective_start effective_end {
	
	gen `var'_d = 0
		replace `var'_d = 1 if year>= year(`var') & `var' !=.
		replace `var'_d = 0 if year== year(`var') & month(`var')>=7
	
}
rename effective_start_d parity_start
rename effective_end_d parity_end

gen parity = parity_start
	replace parity = 0 if parity_end==1

*********************************************************************

*** IMLC

qui reghdfe n_unique_states imlc_enacted_dd parity, absorb(npi year) cluster(npi)

summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg1

qui reghdfe n_unique_states imlc_enacted_dd parity if female==0, absorb(npi year) cluster(npi)

summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe n_unique_states imlc_enacted_dd parity if female==1, absorb(npi year) cluster(npi)

summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg3

qui reghdfe n_unique_states imlc_enacted_dd parity if grad_cohort<1970, absorb(npi year) cluster(npi)

summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe n_unique_states imlc_enacted_dd parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe n_unique_states imlc_enacted_dd parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg6

qui reghdfe n_unique_states imlc_enacted_dd parity if psychiatry==1, absorb(npi year) cluster(npi)
summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg7

qui reghdfe n_unique_states imlc_enacted_dd parity if pcp==1, absorb(npi year) cluster(npi)
summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe n_unique_states imlc_enacted_dd parity if surgical==1, absorb(npi year) cluster(npi)
summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe n_unique_states imlc_enacted_dd parity if nonsurg==1, absorb(npi year) cluster(npi)
summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe n_unique_states imlc_enacted_dd parity if diagnostic==1, absorb(npi year) cluster(npi)
summ n_unique_states if e(sample)
estadd scalar mean = r(mean)
eststo reg11




*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 using "${wd}/analysis/tables/lic_num_reg.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity) order(imlc_enacted_dd parity) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers



***************************************************************************
*** Robustness checks

// gen multistate = 0
// replace multistate = 1 if n_unique_states>1

*** LPM
qui reghdfe multistate imlc_enacted_dd parity, absorb(npi year) cluster(npi)

summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg1

qui reghdfe multistate imlc_enacted_dd parity if female==0, absorb(npi year) cluster(npi)

summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe multistate imlc_enacted_dd parity if female==1, absorb(npi year) cluster(npi)

summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg3

qui reghdfe multistate imlc_enacted_dd parity if grad_cohort<1970, absorb(npi year) cluster(npi)

summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe multistate imlc_enacted_dd parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe multistate imlc_enacted_dd parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg6

qui reghdfe multistate imlc_enacted_dd parity if psychiatry==1, absorb(npi year) cluster(npi)
summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg7

qui reghdfe multistate imlc_enacted_dd parity if pcp==1, absorb(npi year) cluster(npi)
summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe multistate imlc_enacted_dd parity if surgical==1, absorb(npi year) cluster(npi)
summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe multistate imlc_enacted_dd parity if nonsurg==1, absorb(npi year) cluster(npi)
summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe multistate imlc_enacted_dd parity if diagnostic==1, absorb(npi year) cluster(npi)
summ multistate if e(sample)
estadd scalar mean = r(mean)
eststo reg11




estout reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 using "${wd}/analysis/tables/lic_num_lpm.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity) order(imlc_enacted_dd parity) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers


// *** Ologit 
// gen lic_cat = n_unique_states
// replace lic_cat = 4 if n_unique_states>4
//
//
// ologit lic_cat imlc_enacted_dd parity i.year if year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg1
//
// ologit lic_cat imlc_enacted_dd parity i.year if female==0 & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg2
//
// ologit lic_cat imlc_enacted_dd parity i.year if female==1 & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg3
//
// ologit lic_cat imlc_enacted_dd parity i.year if grad_cohort<1970 & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg4
//
// ologit lic_cat imlc_enacted_dd parity i.year if inlist(grad_cohort, 1970, 1980, 1990) & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg5
//
// ologit lic_cat imlc_enacted_dd parity i.year if inlist(grad_cohort, 2000, 2010, 2020) & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg6
//
// ologit lic_cat imlc_enacted_dd parity i.year if psychiatry==1 & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg7
//
// ologit lic_cat imlc_enacted_dd parity i.year if pcp==1 & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg8
//
// ologit lic_cat imlc_enacted_dd parity i.year if surgical==1 & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg9
//
// ologit lic_cat imlc_enacted_dd parity i.year if nonsurg==1 & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg10
//
// ologit lic_cat imlc_enacted_dd parity i.year if diagnostic==1 & year>2017, vce(cluster npi)
// summ lic_cat if e(sample)
// estadd scalar mean = r(mean)
// eststo reg11
//
//
//
// estout reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 using "${wd}/analysis/tables/lic_num_ologit.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity) order(imlc_enacted_dd parity) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers
//




*** Ologit 

gen lic_cat = n_unique_states
replace lic_cat = 4 if n_unique_states > 4


*------------------------------------------------------------
* Full sample
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year if year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Male
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year if female==0 & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Female
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year if female==1 & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Graduation cohort: pre-1970
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year if grad_cohort<1970 & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Graduation cohort: 1970--1990
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year ///
    if inlist(grad_cohort, 1970, 1980, 1990) & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Graduation cohort: 2000--2020
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year ///
    if inlist(grad_cohort, 2000, 2010, 2020) & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Psychiatry
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year if psychiatry==1 & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Primary care
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year if pcp==1 & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Surgical
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year if surgical==1 & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Nonsurgical medical
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year if nonsurg==1 & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))


*------------------------------------------------------------
* Diagnostic/other
*------------------------------------------------------------

ologit lic_cat i.imlc_enacted_dd parity i.year if diagnostic==1 & year>2017, vce(cluster npi)

tab lic_cat if e(sample)

margins, dydx(imlc_enacted_dd) predict(outcome(1))
margins, dydx(imlc_enacted_dd) predict(outcome(2))
margins, dydx(imlc_enacted_dd) predict(outcome(3))
margins, dydx(imlc_enacted_dd) predict(outcome(4))
