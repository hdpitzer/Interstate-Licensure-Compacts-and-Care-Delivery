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
*** EARLY ADOPTERS VS. NEVER ADOPTERS
***************************************************************************

* Early adopters = first treatment cohort
gen early_adopter = (imlc_firstyear == 2018)

* Never adopters = never treated during 2017-2023
gen never_adopter = missing(imlc_firstyear)

* Analysis sample: early adopters + never adopters
gen early_never_sample = early_adopter==1 | never_adopter==1


***************************************************************************
*** CHECK STATE COUNTS
***************************************************************************

egen tag_state_en = tag(origin_state) if early_never_sample==1

tab early_adopter if tag_state_en==1
tab origin_state if tag_state_en==1 & never_adopter==1

tab year imlc_enacted_dd if early_never_sample==1




***************************************************************************
*** IMLC EFFECTS BY ADOPTION COHORT
*** Each treatment cohort compared with states untreated through 2023
***************************************************************************

eststo clear


***************************************************************************
*** 1. DEFINE NEVER-TREATED STATES
***************************************************************************

* imlc_firstyear already contains first treatment year
* Missing = untreated throughout 2017-2023
gen never_imlc = missing(imlc_firstyear)

tab imlc_firstyear
tab never_imlc if tag_state==1


***************************************************************************
*** 2. 2018 COHORT VS. NEVER TREATED
***************************************************************************

gen sample_2018 = (imlc_firstyear==2018 | never_imlc==1)

qui reghdfe ln_em_cnt ///
    imlc_enacted_dd parity ///
    if sample_2018==1, ///
    absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo vol_2018

qui reghdfe share_new ///
    imlc_enacted_dd parity ///
    if sample_2018==1, ///
    absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo new_2018

qui reghdfe avg_visit_time ///
    imlc_enacted_dd parity ///
    if sample_2018==1, ///
    absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo time_2018

qui reghdfe telehealth_share ///
    imlc_enacted_dd parity ///
    if sample_2018==1, ///
    absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo tele_2018


***************************************************************************
*** 3. 2019 COHORT VS. NEVER TREATED
***************************************************************************

gen sample_2019 = (imlc_firstyear==2019 | never_imlc==1)

qui reghdfe ln_em_cnt ///
    imlc_enacted_dd parity ///
    if sample_2019==1, ///
    absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo vol_2019

qui reghdfe share_new ///
    imlc_enacted_dd parity ///
    if sample_2019==1, ///
    absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo new_2019

qui reghdfe avg_visit_time ///
    imlc_enacted_dd parity ///
    if sample_2019==1, ///
    absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo time_2019

qui reghdfe telehealth_share ///
    imlc_enacted_dd parity ///
    if sample_2019==1, ///
    absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo tele_2019


***************************************************************************
*** 4. 2020 COHORT VS. NEVER TREATED
***************************************************************************

gen sample_2020 = (imlc_firstyear==2020 | never_imlc==1)

qui reghdfe ln_em_cnt ///
    imlc_enacted_dd parity ///
    if sample_2020==1, ///
    absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo vol_2020

qui reghdfe share_new ///
    imlc_enacted_dd parity ///
    if sample_2020==1, ///
    absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo new_2020

qui reghdfe avg_visit_time ///
    imlc_enacted_dd parity ///
    if sample_2020==1, ///
    absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo time_2020

qui reghdfe telehealth_share ///
    imlc_enacted_dd parity ///
    if sample_2020==1, ///
    absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo tele_2020


***************************************************************************
*** 5. 2022 COHORT VS. NEVER TREATED
***************************************************************************

gen sample_2022 = (imlc_firstyear==2022 | never_imlc==1)

qui reghdfe ln_em_cnt ///
    imlc_enacted_dd parity ///
    if sample_2022==1, ///
    absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo vol_2022

qui reghdfe share_new ///
    imlc_enacted_dd parity ///
    if sample_2022==1, ///
    absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo new_2022

qui reghdfe avg_visit_time ///
    imlc_enacted_dd parity ///
    if sample_2022==1, ///
    absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo time_2022

qui reghdfe telehealth_share ///
    imlc_enacted_dd parity ///
    if sample_2022==1, ///
    absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo tele_2022


***************************************************************************
*** 6. 2023 COHORT VS. NEVER TREATED
***************************************************************************

gen sample_2023 = (imlc_firstyear==2023 | never_imlc==1)

qui reghdfe ln_em_cnt ///
    imlc_enacted_dd parity ///
    if sample_2023==1, ///
    absorb(npi year) cluster(npi)
summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo vol_2023

qui reghdfe share_new ///
    imlc_enacted_dd parity ///
    if sample_2023==1, ///
    absorb(npi year) cluster(npi)
summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo new_2023

qui reghdfe avg_visit_time ///
    imlc_enacted_dd parity ///
    if sample_2023==1, ///
    absorb(npi year) cluster(npi)
summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo time_2023

qui reghdfe telehealth_share ///
    imlc_enacted_dd parity ///
    if sample_2023==1, ///
    absorb(npi year) cluster(npi)
summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo tele_2023


***************************************************************************
*** 7. DISPLAY BY OUTCOME
***************************************************************************

*** E/M VOLUME
esttab ///
    vol_2018 vol_2019 vol_2020 vol_2022 vol_2023, ///
    keep(imlc_enacted_dd) ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N mean, ///
        fmt(%9.0fc %9.3f) ///
        labels("Observations" "Mean dependent variable")) ///
    mtitles("2018" "2019" "2020" "2022" "2023")


*** SHARE NEW
esttab ///
    new_2018 new_2019 new_2020 new_2022 new_2023, ///
    keep(imlc_enacted_dd) ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N mean, ///
        fmt(%9.0fc %9.3f) ///
        labels("Observations" "Mean dependent variable")) ///
    mtitles("2018" "2019" "2020" "2022" "2023")


*** AVERAGE VISIT TIME
esttab ///
    time_2018 time_2019 time_2020 time_2022 time_2023, ///
    keep(imlc_enacted_dd) ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N mean, ///
        fmt(%9.0fc %9.3f) ///
        labels("Observations" "Mean dependent variable")) ///
    mtitles("2018" "2019" "2020" "2022" "2023")


*** TELEHEALTH SHARE
esttab ///
    tele_2018 tele_2019 tele_2020 tele_2022 tele_2023, ///
    keep(imlc_enacted_dd) ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N mean, ///
        fmt(%9.0fc %9.3f) ///
        labels("Observations" "Mean dependent variable")) ///
    mtitles("2018" "2019" "2020" "2022" "2023")
