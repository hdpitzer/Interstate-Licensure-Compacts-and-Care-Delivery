clear all 

global wd "/Volumes/Untitled/Interstate Licensure"

***************************************************************************

use "${wd}/data/output/PUF/puf_provider_year_merge_2016_2023", clear

rename rndrng_npi npi

merge m:1 npi year using "${wd}/data/output/licensure_full_2017_2023", keep(1 3)

drop if em_cnt==0
drop if _merge == 1

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


save "${wd}/data/output/PUF/puf_licensure_merge_2016_2023", replace

***************************************************************************

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


***************************************************************************
***IMLC***
***Outpatient volume

**ITT

*Full sample
qui reghdfe ln_em_cnt imlc_enacted_dd parity, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg1

*By gender
qui reghdfe ln_em_cnt imlc_enacted_dd parity if female==0, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe ln_em_cnt imlc_enacted_dd parity if female==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg3

*By grad cohort
qui reghdfe ln_em_cnt imlc_enacted_dd parity if grad_cohort<1970, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe ln_em_cnt imlc_enacted_dd parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe ln_em_cnt imlc_enacted_dd parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg6

*By specialty 
qui reghdfe ln_em_cnt imlc_enacted_dd parity if psychiatry==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe ln_em_cnt imlc_enacted_dd parity if pcp==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe ln_em_cnt imlc_enacted_dd parity if surgical==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe ln_em_cnt imlc_enacted_dd parity if nonsurg==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg11

qui reghdfe ln_em_cnt imlc_enacted_dd parity if diagnostic==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_tot_srvcs_itt.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity) order(imlc_enacted_dd parity) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers



**IMLC X Multistate

*Full sample
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if female==0, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if female==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if grad_cohort<1970, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if psychiatry==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if pcp==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if surgical==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if nonsurg==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if diagnostic==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_tot_srvcs_int.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers





***New patient share

**ITT

*Full sample
qui reghdfe share_new imlc_enacted_dd parity, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg1

*By gender
qui reghdfe share_new imlc_enacted_dd parity if female==0, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe share_new imlc_enacted_dd parity if female==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg3

*By grad cohort
qui reghdfe share_new imlc_enacted_dd parity if grad_cohort<1970, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe share_new imlc_enacted_dd parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe share_new imlc_enacted_dd parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg6

*By specialty 
qui reghdfe share_new imlc_enacted_dd parity if psychiatry==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe share_new imlc_enacted_dd parity if pcp==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe share_new imlc_enacted_dd parity if surgical==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe share_new imlc_enacted_dd parity if nonsurg==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg11

qui reghdfe share_new imlc_enacted_dd parity if diagnostic==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_share_new_itt.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity) order(imlc_enacted_dd parity) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers



**IMLC X Multistate

*Full sample
qui reghdfe share_new imlc_enacted_dd##multistate parity, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe share_new imlc_enacted_dd##multistate parity if female==0, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe share_new imlc_enacted_dd##multistate parity if female==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe share_new imlc_enacted_dd##multistate parity if grad_cohort<1970, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe share_new imlc_enacted_dd##multistate parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe share_new imlc_enacted_dd##multistate parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe share_new imlc_enacted_dd##multistate parity if psychiatry==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe share_new imlc_enacted_dd##multistate parity if pcp==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe share_new imlc_enacted_dd##multistate parity if surgical==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe share_new imlc_enacted_dd##multistate parity if nonsurg==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe share_new imlc_enacted_dd##multistate parity if diagnostic==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_share_new_int.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers





***Avg visit length

**ITT

*Full sample
qui reghdfe avg_visit_time imlc_enacted_dd parity, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg1

*By gender
qui reghdfe avg_visit_time imlc_enacted_dd parity if female==0, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe avg_visit_time imlc_enacted_dd parity if female==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg3

*By grad cohort
qui reghdfe avg_visit_time imlc_enacted_dd parity if grad_cohort<1970, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe avg_visit_time imlc_enacted_dd parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe avg_visit_time imlc_enacted_dd parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg6

*By specialty 
qui reghdfe avg_visit_time imlc_enacted_dd parity if psychiatry==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe avg_visit_time imlc_enacted_dd parity if pcp==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe avg_visit_time imlc_enacted_dd parity if surgical==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe avg_visit_time imlc_enacted_dd parity if nonsurg==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg11

qui reghdfe avg_visit_time imlc_enacted_dd parity if diagnostic==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_visit_time_itt.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity) order(imlc_enacted_dd parity) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers



**IMLC X Multistate

*Full sample
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if female==0, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if female==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if grad_cohort<1970, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if psychiatry==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if pcp==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if surgical==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if nonsurg==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if diagnostic==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_visit_time_int.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers





***Teleheath share

**ITT

*Full sample
qui reghdfe telehealth_share imlc_enacted_dd parity, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg1

*By gender
qui reghdfe telehealth_share imlc_enacted_dd parity if female==0, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe telehealth_share imlc_enacted_dd parity if female==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg3

*By grad cohort
qui reghdfe telehealth_share imlc_enacted_dd parity if grad_cohort<1970, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe telehealth_share imlc_enacted_dd parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe telehealth_share imlc_enacted_dd parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg6

*By specialty 
qui reghdfe telehealth_share imlc_enacted_dd parity if psychiatry==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe telehealth_share imlc_enacted_dd parity if pcp==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe telehealth_share imlc_enacted_dd parity if surgical==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe telehealth_share imlc_enacted_dd parity if nonsurg==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg11

qui reghdfe telehealth_share imlc_enacted_dd parity if diagnostic==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_telehlth_itt.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity) order(imlc_enacted_dd parity) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers



**IMLC X Multistate

*Full sample
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if female==0, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if female==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if grad_cohort<1970, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if psychiatry==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if pcp==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if surgical==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if nonsurg==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if diagnostic==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_telehlth_int.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers


****************************************************************************

** Interaction (limited sample) **

**Identify multistate year
egen multistate_year = min(cond(multistate==1, year, .)), by(npi)

egen min_imlc_enacted_dd = min(cond(imlc_enacted_dd==1,year,.)), by(origin_state)


**Categorize providers by multistate and IMLC timing
gen multistate_timing = .

* Never multistate, IMLC state
replace multistate_timing = 0 if multistate_year==. & min_imlc_enacted_dd!=.

* Multistate before IMLC
replace multistate_timing = 1 if multistate_year < min_imlc_enacted_dd ///
	& multistate_year!=. & min_imlc_enacted_dd!=.

* Becomes multistate in IMLC year
replace multistate_timing = 2 if multistate_year == min_imlc_enacted_dd ///
	& multistate_year!=. & min_imlc_enacted_dd!=.

* Becomes multistate after IMLC
replace multistate_timing = 3 if multistate_year > min_imlc_enacted_dd ///
	& multistate_year!=. & min_imlc_enacted_dd!=.

* Multistate, never IMLC
replace multistate_timing = 4 if multistate_year!=. & min_imlc_enacted_dd==.

* Never multistate, never IMLC
replace multistate_timing = 5 if multistate_year==. & min_imlc_enacted_dd==.

label define multistate_timing ///
	0 "Never multistate, IMLC" ///
	1 "Multistate before IMLC" ///
	2 "Multistate in IMLC year" ///
	3 "Multistate after IMLC" ///
	4 "Multistate, never IMLC" ///
	5 "Never multistate, never IMLC"

label values multistate_timing multistate_timing


egen npi_tag = tag(npi)

tab multistate_timing if npi_tag==1



***Outpatient volume

*Full sample
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if female==0 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if female==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if grad_cohort<1970 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if inlist(grad_cohort, 1970, 1980, 1990) & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if inlist(grad_cohort, 2000, 2010, 2020) & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if psychiatry==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if pcp==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if surgical==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if nonsurg==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity if diagnostic==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_tot_srvcs_intltd.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers


***New patient share

*Full sample
qui reghdfe share_new imlc_enacted_dd##multistate parity if multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe share_new imlc_enacted_dd##multistate parity if female==0 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe share_new imlc_enacted_dd##multistate parity if female==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe share_new imlc_enacted_dd##multistate parity if grad_cohort<1970 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe share_new imlc_enacted_dd##multistate parity if inlist(grad_cohort, 1970, 1980, 1990) & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe share_new imlc_enacted_dd##multistate parity if inlist(grad_cohort, 2000, 2010, 2020) & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe share_new imlc_enacted_dd##multistate parity if psychiatry==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe share_new imlc_enacted_dd##multistate parity if pcp==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe share_new imlc_enacted_dd##multistate parity if surgical==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe share_new imlc_enacted_dd##multistate parity if nonsurg==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe share_new imlc_enacted_dd##multistate parity if diagnostic==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_share_new_intltd.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers


***Avg visit length

*Full sample
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if female==0 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if female==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if grad_cohort<1970 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if inlist(grad_cohort, 1970, 1980, 1990) & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if inlist(grad_cohort, 2000, 2010, 2020) & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if psychiatry==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if pcp==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if surgical==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if nonsurg==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity if diagnostic==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_visit_time_intltd.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers


***Teleheath share

*Full sample
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if female==0 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if female==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if grad_cohort<1970 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if inlist(grad_cohort, 1970, 1980, 1990) & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if inlist(grad_cohort, 2000, 2010, 2020) & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if psychiatry==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if pcp==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if surgical==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if nonsurg==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity if diagnostic==1 & multistate_timing!=1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_telehlth_intltd.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers




****************************************************************************

** COVID Robustness

merge m:1 origin_state using "${wd}/data/input/covid_reciprocity", keep(1 3) nogen

foreach var in OOSstart OOSend Telehealthstart Telehealthend {
	
	gen `var'_d = 0
		replace `var'_d = 1 if year>= year(`var') & `var' !=.
	
}

gen oos = OOSstart_d
	replace oos = 0 if OOSend_d==1
gen tele = Telehealthstart_d
	replace tele = 0 if Telehealthend_d==1
	
	

	
***IMLC***
***Outpatient volume

**ITT

*Full sample
qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg1

*By gender
qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if female==0, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if female==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg3

*By grad cohort
qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if grad_cohort<1970, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg6

*By specialty 
qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if psychiatry==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if pcp==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if surgical==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if nonsurg==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg11

qui reghdfe ln_em_cnt imlc_enacted_dd parity oos tele if diagnostic==1, absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_tot_srvcs_itt_covid.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity oos tele) order(imlc_enacted_dd parity oos tele) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers



**IMLC X Multistate

*Full sample
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if female==0, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if female==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if grad_cohort<1970, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if psychiatry==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if pcp==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if surgical==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if nonsurg==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe ln_em_cnt imlc_enacted_dd##multistate parity oos tele if diagnostic==1, absorb(npi year) cluster(npi)

*mean dep var
summ em_cnt if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_tot_srvcs_int_covid.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity oos tele) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity oos tele) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers





***New patient share

**ITT

*Full sample
qui reghdfe share_new imlc_enacted_dd parity oos tele, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg1

*By gender
qui reghdfe share_new imlc_enacted_dd parity oos tele if female==0, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe share_new imlc_enacted_dd parity oos tele if female==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg3

*By grad cohort
qui reghdfe share_new imlc_enacted_dd parity oos tele if grad_cohort<1970, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe share_new imlc_enacted_dd parity oos tele if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe share_new imlc_enacted_dd parity oos tele if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg6

*By specialty 
qui reghdfe share_new imlc_enacted_dd parity oos tele if psychiatry==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe share_new imlc_enacted_dd parity oos tele if pcp==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe share_new imlc_enacted_dd parity oos tele if surgical==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe share_new imlc_enacted_dd parity oos tele if nonsurg==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg11

qui reghdfe share_new imlc_enacted_dd parity oos tele if diagnostic==1, absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_share_new_itt_covid.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity oos tele) order(imlc_enacted_dd parity oos tele) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers



**IMLC X Multistate

*Full sample
qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if female==0, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if female==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if grad_cohort<1970, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if psychiatry==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if pcp==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if surgical==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if nonsurg==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe share_new imlc_enacted_dd##multistate parity oos tele if diagnostic==1, absorb(npi year) cluster(npi)

*mean dep var
summ share_new if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12


*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_share_new_int_covid.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity oos tele) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity oos tele) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers





***Avg visit length

**ITT

*Full sample
qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg1

*By gender
qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if female==0, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if female==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg3

*By grad cohort
qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if grad_cohort<1970, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg6

*By specialty 
qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if psychiatry==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if pcp==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if surgical==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if nonsurg==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg11

qui reghdfe avg_visit_time imlc_enacted_dd parity oos tele if diagnostic==1, absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_visit_time_itt_covid.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity oos tele) order(imlc_enacted_dd parity oos tele) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers



**IMLC X Multistate

*Full sample
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if female==0, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if female==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if grad_cohort<1970, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if psychiatry==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if pcp==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if surgical==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if nonsurg==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe avg_visit_time imlc_enacted_dd##multistate parity oos tele if diagnostic==1, absorb(npi year) cluster(npi)

*mean dep var
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_visit_time_int_covid.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity oos tele) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity oos tele) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers





***Teleheath share

**ITT

*Full sample
qui reghdfe telehealth_share imlc_enacted_dd parity oos tele, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg1

*By gender
qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if female==0, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg2

qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if female==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg3

*By grad cohort
qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if grad_cohort<1970, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg4

qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg5

qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg6

*By specialty 
qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if psychiatry==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg8

qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if pcp==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg9

qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if surgical==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg10

qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if nonsurg==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg11

qui reghdfe telehealth_share imlc_enacted_dd parity oos tele if diagnostic==1, absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_telehlth_itt_covid.csv", style(tab) replace label delimiter(",") keep(imlc_enacted_dd parity oos tele) order(imlc_enacted_dd parity oos tele) stats(N mean, fmt(%6.0f %8.2f) labels("Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers



**IMLC X Multistate

*Full sample
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg1

*By gender
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if female==0, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg2

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if female==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg3

*By grad cohort
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if grad_cohort<1970, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg4

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if inlist(grad_cohort, 1970, 1980, 1990), absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg5

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if inlist(grad_cohort, 2000, 2010, 2020), absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg6

*By specialty 
qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if psychiatry==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg8

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if pcp==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg9

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if surgical==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg10

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if nonsurg==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg11

qui reghdfe telehealth_share imlc_enacted_dd##multistate parity oos tele if diagnostic==1, absorb(npi year) cluster(npi)

*mean dep var
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

* Total IMLC effect when multistate = 1
qui lincom 1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

local b  = r(estimate)
local se = r(se)
local p  = r(p)

local stars ""
if `p' < .10 local stars "*"
if `p' < .05 local stars "**"
if `p' < .01 local stars "***"

local b_fmt  : display %9.3f `b'
local se_fmt : display %9.3f `se'

estadd local imlc_ms "`b_fmt'`stars'"
estadd local imlc_ms_se `"="(`se_fmt')""'

eststo reg12



*Export results
estout reg1 reg2 reg3 reg4 reg5 reg6 reg8 reg9 reg10 reg11 reg12 using "${wd}/analysis/tables/imlc_telehlth_int_covid.csv", style(tab) replace label delimiter(",") keep(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity oos tele) order(1.imlc_enacted_dd 1.multistate 1.imlc_enacted_dd#1.multistate parity oos tele) stats(imlc_ms imlc_ms_se N mean, fmt(%6.6f %6.6f %6.0f %8.2f) labels("IMLC effect when multistate" "" "Observations" "Mean dependent variable")) cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) eqlabels(none) collabels(none) mlabels(none) nonumbers


