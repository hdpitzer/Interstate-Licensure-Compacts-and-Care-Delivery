clear all 

global wd "/Volumes/Untitled/Interstate Licensure"

***************************************************************************

use "${wd}/data/output/PUF/puf_licensure_merge_2016_2023", clear


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
merge m:1 state year using "${wd}/data/output/NPPES/state_year_lag", nogen


***************************************************************************
*** ITT: BASELINE VS. STATE-LEVEL CONTROLS
*** Common sample: 2018–2023
***************************************************************************

eststo clear


***************************************************************************
*** 1. OUTPATIENT E/M VOLUME
***************************************************************************

* Baseline
qui reghdfe ln_em_cnt ///
    imlc_enacted_dd parity ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo volume_base


* With lagged state controls
qui reghdfe ln_em_cnt ///
    imlc_enacted_dd parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ em_cnt if e(sample)
estadd scalar mean = r(mean)
eststo volume_ctrl



***************************************************************************
*** 2. SHARE OF NEW PATIENT VISITS
***************************************************************************

* Baseline
qui reghdfe share_new ///
    imlc_enacted_dd parity ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo new_base


* With lagged state controls
qui reghdfe share_new ///
    imlc_enacted_dd parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ share_new if e(sample)
estadd scalar mean = r(mean)
eststo new_ctrl



***************************************************************************
*** 3. AVERAGE VISIT TIME
***************************************************************************

* Baseline
qui reghdfe avg_visit_time ///
    imlc_enacted_dd parity ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo time_base


* With lagged state controls
qui reghdfe avg_visit_time ///
    imlc_enacted_dd parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)
eststo time_ctrl



***************************************************************************
*** 4. TELEHEALTH SHARE
***************************************************************************

* Baseline
qui reghdfe telehealth_share ///
    imlc_enacted_dd parity ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo tele_base


* With lagged state controls
qui reghdfe telehealth_share ///
    imlc_enacted_dd parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ telehealth_share if e(sample)
estadd scalar mean = r(mean)
eststo tele_ctrl



***************************************************************************
*** 5. DISPLAY SIDE-BY-SIDE COMPARISON
***************************************************************************

esttab volume_base volume_ctrl ///
       new_base new_ctrl ///
       time_base time_ctrl ///
       tele_base tele_ctrl, ///
    keep(imlc_enacted_dd) ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N mean, ///
        fmt(%9.0fc %9.2f) ///
        labels("Observations" "Mean dependent variable")) ///
    mtitles( ///
        "Volume: Baseline" ///
        "Volume: Controls" ///
        "New Patient: Baseline" ///
        "New Patient: Controls" ///
        "Visit Time: Baseline" ///
        "Visit Time: Controls" ///
        "Telehealth: Baseline" ///
        "Telehealth: Controls" ///
    )
	
	

	
***************************************************************************
*** IMLC × MULTISTATE: BASELINE VS. STATE-LEVEL CONTROLS
*** Common sample: 2018–2023
***************************************************************************

eststo clear


***************************************************************************
*** 1. OUTPATIENT E/M VOLUME
***************************************************************************

* Baseline
qui reghdfe ln_em_cnt ///
    imlc_enacted_dd##multistate ///
    parity ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ em_cnt if e(sample)
estadd scalar mean = r(mean)

qui lincom ///
    1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

estadd scalar imlc_ms    = r(estimate)
estadd scalar imlc_ms_se = r(se)

eststo volume_base_int


* With lagged state controls
qui reghdfe ln_em_cnt ///
    imlc_enacted_dd##multistate ///
    parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ em_cnt if e(sample)
estadd scalar mean = r(mean)

qui lincom ///
    1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

estadd scalar imlc_ms    = r(estimate)
estadd scalar imlc_ms_se = r(se)

eststo volume_ctrl_int



***************************************************************************
*** 2. SHARE OF NEW PATIENT VISITS
***************************************************************************

* Baseline
qui reghdfe share_new ///
    imlc_enacted_dd##multistate ///
    parity ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ share_new if e(sample)
estadd scalar mean = r(mean)

qui lincom ///
    1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

estadd scalar imlc_ms    = r(estimate)
estadd scalar imlc_ms_se = r(se)

eststo new_base_int


* With lagged state controls
qui reghdfe share_new ///
    imlc_enacted_dd##multistate ///
    parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ share_new if e(sample)
estadd scalar mean = r(mean)

qui lincom ///
    1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

estadd scalar imlc_ms    = r(estimate)
estadd scalar imlc_ms_se = r(se)

eststo new_ctrl_int



***************************************************************************
*** 3. AVERAGE VISIT TIME
***************************************************************************

* Baseline
qui reghdfe avg_visit_time ///
    imlc_enacted_dd##multistate ///
    parity ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

qui lincom ///
    1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

estadd scalar imlc_ms    = r(estimate)
estadd scalar imlc_ms_se = r(se)

eststo time_base_int


* With lagged state controls
qui reghdfe avg_visit_time ///
    imlc_enacted_dd##multistate ///
    parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ avg_visit_time if e(sample)
estadd scalar mean = r(mean)

qui lincom ///
    1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

estadd scalar imlc_ms    = r(estimate)
estadd scalar imlc_ms_se = r(se)

eststo time_ctrl_int



***************************************************************************
*** 4. TELEHEALTH SHARE
***************************************************************************

* Baseline
qui reghdfe telehealth_share ///
    imlc_enacted_dd##multistate ///
    parity ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

qui lincom ///
    1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

estadd scalar imlc_ms    = r(estimate)
estadd scalar imlc_ms_se = r(se)

eststo tele_base_int


* With lagged state controls
qui reghdfe telehealth_share ///
    imlc_enacted_dd##multistate ///
    parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share ///
    if year>=2018 & year<=2023, ///
    absorb(npi year) cluster(npi)

summ telehealth_share if e(sample)
estadd scalar mean = r(mean)

qui lincom ///
    1.imlc_enacted_dd + ///
    1.imlc_enacted_dd#1.multistate

estadd scalar imlc_ms    = r(estimate)
estadd scalar imlc_ms_se = r(se)

eststo tele_ctrl_int



***************************************************************************
*** 5. DISPLAY SIDE-BY-SIDE
***************************************************************************

esttab ///
    volume_base_int volume_ctrl_int ///
    new_base_int new_ctrl_int ///
    time_base_int time_ctrl_int ///
    tele_base_int tele_ctrl_int, ///
    keep( ///
        1.imlc_enacted_dd ///
        1.multistate ///
        1.imlc_enacted_dd#1.multistate ///
    ) ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats( ///
        imlc_ms imlc_ms_se N mean, ///
        fmt(3 3 %9.0fc %9.2f) ///
        labels( ///
            "IMLC effect when multistate" ///
            "SE: IMLC effect when multistate" ///
            "Observations" ///
            "Mean dependent variable" ///
        ) ///
    ) ///
    mtitles( ///
        "Volume: Baseline" ///
        "Volume: Controls" ///
        "New Patient: Baseline" ///
        "New Patient: Controls" ///
        "Visit Time: Baseline" ///
        "Visit Time: Controls" ///
        "Telehealth: Baseline" ///
        "Telehealth: Controls" ///
    )
