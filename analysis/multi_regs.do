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
***************************************************************************
*** Multistate vs. single-state physicians
***************************************************************************


***************************************************************************
*** 1. OUTPATIENT E/M VOLUME
***************************************************************************

qui reghdfe ln_em_cnt ///
    multistate parity, ///
    absorb(npi year) cluster(npi)

summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo volume


***************************************************************************
*** 2. SHARE OF NEW PATIENT VISITS
***************************************************************************

qui reghdfe share_new ///
    multistate parity, ///
    absorb(npi year) cluster(npi)

summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo new


***************************************************************************
*** 3. AVERAGE VISIT TIME
***************************************************************************

qui reghdfe avg_visit_time ///
    multistate parity, ///
    absorb(npi year) cluster(npi)

summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo time


***************************************************************************
*** 4. TELEHEALTH SHARE
***************************************************************************

qui reghdfe telehealth_share ///
    multistate parity, ///
    absorb(npi year) cluster(npi)

summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo tele


***************************************************************************
*** DISPLAY RESULTS
***************************************************************************

esttab ///
    volume ///
    new ///
    time ///
    tele, ///
    keep(multistate) ///
    b(5) se(5) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N mean, ///
        fmt(%9.0fc %9.3f) ///
        labels("Observations" "Mean dependent variable")) ///
    mtitles( ///
        "E/M Volume" ///
        "Share New" ///
        "Avg. Visit Time" ///
        "Telehealth Share" ///
    )
