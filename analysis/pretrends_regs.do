clear all 

global wd "/Volumes/Untitled/Interstate Licensure"

*********************************************************************

use "${wd}/data/output/NPPES/state_year_physician_supply_population", clear

merge 1:1 state year using "${wd}/data/output/PUF/puf_state_year_compact_2017_2023", nogen


***************************************************************************
*** 1. SET UP PANEL
***************************************************************************

* Declare panel
xtset state_fips year

* Check IMLC participation
tab year imlc_enacted_dd

* Check key state-level variables
summ ///
    physicians_per_100k ///
    multistate_share ///
    ln_em_volume ///
    share_new ///
    avg_visit_time ///
    telehealth_share


***************************************************************************
*** 2. CREATE ONE-YEAR LAGS
***************************************************************************

* Licensed physician supply
gen l_physicians_per_100k = L.physicians_per_100k

* Share of physicians reporting licenses in multiple states
gen l_multistate_share = L.multistate_share

* Care-delivery outcomes
gen l_ln_em_volume = L.ln_em_volume

gen l_share_new = L.share_new

gen l_avg_visit_time = L.avg_visit_time

gen l_telehealth_share = L.telehealth_share


***************************************************************************
*** 3. CHECK LAGGED VARIABLES
***************************************************************************

summ ///
    l_physicians_per_100k ///
    l_multistate_share ///
    l_ln_em_volume ///
    l_share_new ///
    l_avg_visit_time ///
    l_telehealth_share

* Lags should be missing in 2017
count if year==2017 & !missing(l_physicians_per_100k)

* Should return zero
assert missing(l_physicians_per_100k) if year==2017

save "${wd}/data/output/NPPES/state_year_lag", replace


***************************************************************************
*** 4. INDIVIDUAL PREDICTORS
***
*** PANEL A: YEAR FIXED EFFECTS ONLY
***
*** These specifications allow both between-state and within-state
*** differences in lagged characteristics to predict IMLC participation.
***************************************************************************

* Licensed physicians per 100,000
reghdfe imlc_enacted_dd ///
    l_physicians_per_100k, ///
    absorb(year) ///
    vce(cluster state_fips)
eststo supply_year


* Multistate licensure share
reghdfe imlc_enacted_dd ///
    l_multistate_share, ///
    absorb(year) ///
    vce(cluster state_fips)
eststo multistate_year


* Outpatient visit volume
reghdfe imlc_enacted_dd ///
    l_ln_em_volume, ///
    absorb(year) ///
    vce(cluster state_fips)
eststo volume_year


* Share of new patients
reghdfe imlc_enacted_dd ///
    l_share_new, ///
    absorb(year) ///
    vce(cluster state_fips)
eststo new_year


* Average visit time
reghdfe imlc_enacted_dd ///
    l_avg_visit_time, ///
    absorb(year) ///
    vce(cluster state_fips)
eststo time_year


* Telehealth share
reghdfe imlc_enacted_dd ///
    l_telehealth_share, ///
    absorb(year) ///
    vce(cluster state_fips)
eststo tele_year


***************************************************************************
*** 5. INDIVIDUAL PREDICTORS
***
*** PANEL B: STATE + YEAR FIXED EFFECTS
***
*** These specifications ask whether within-state changes in lagged
*** characteristics are associated with IMLC participation.
***************************************************************************

* Licensed physicians per 100,000
reghdfe imlc_enacted_dd ///
    l_physicians_per_100k, ///
    absorb(state_fips year) ///
    vce(cluster state_fips)
eststo supply_state


* Multistate licensure share
reghdfe imlc_enacted_dd ///
    l_multistate_share, ///
    absorb(state_fips year) ///
    vce(cluster state_fips)
eststo multistate_state


* Outpatient visit volume
reghdfe imlc_enacted_dd ///
    l_ln_em_volume, ///
    absorb(state_fips year) ///
    vce(cluster state_fips)
eststo volume_state


* Share of new patients
reghdfe imlc_enacted_dd ///
    l_share_new, ///
    absorb(state_fips year) ///
    vce(cluster state_fips)
eststo new_state


* Average visit time
reghdfe imlc_enacted_dd ///
    l_avg_visit_time, ///
    absorb(state_fips year) ///
    vce(cluster state_fips)
eststo time_state


* Telehealth share
reghdfe imlc_enacted_dd ///
    l_telehealth_share, ///
    absorb(state_fips year) ///
    vce(cluster state_fips)
eststo tele_state


***************************************************************************
*** 6. COMBINED SPECIFICATION
***
*** Start with physician supply + four care-delivery outcomes.
*** Leave multistate share out initially because it is more closely
*** connected to the mechanism directly affected by IMLC.
***************************************************************************

*** Year FE only

reghdfe imlc_enacted_dd ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_share_new ///
    l_avg_visit_time ///
    l_telehealth_share, ///
    absorb(year) ///
    vce(cluster state_fips)

eststo combined_year


*** State + year FE

reghdfe imlc_enacted_dd ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_share_new ///
    l_avg_visit_time ///
    l_telehealth_share, ///
    absorb(state_fips year) ///
    vce(cluster state_fips)

eststo combined_state


***************************************************************************
*** 7. OPTIONAL: ADD LAGGED MULTISTATE SHARE TO COMBINED MODEL
***************************************************************************

*** Year FE only

reghdfe imlc_enacted_dd ///
    l_physicians_per_100k ///
    l_multistate_share ///
    l_ln_em_volume ///
    l_share_new ///
    l_avg_visit_time ///
    l_telehealth_share, ///
    absorb(year) ///
    vce(cluster state_fips)

eststo combined_multi_year


*** State + year FE

reghdfe imlc_enacted_dd ///
    l_physicians_per_100k ///
    l_multistate_share ///
    l_ln_em_volume ///
    l_share_new ///
    l_avg_visit_time ///
    l_telehealth_share, ///
    absorb(state_fips year) ///
    vce(cluster state_fips)

eststo combined_multi_state


***************************************************************************
*** 8. DISPLAY INDIVIDUAL RESULTS
***************************************************************************

*** Year FE only

esttab ///
    supply_year ///
    multistate_year ///
    volume_year ///
    new_year ///
    time_year ///
    tele_year, ///
    keep( ///
        l_physicians_per_100k ///
        l_multistate_share ///
        l_ln_em_volume ///
        l_share_new ///
        l_avg_visit_time ///
        l_telehealth_share ///
    ) ///
    se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, labels("Observations" "R-squared"))


*** State + year FE

esttab ///
    supply_state ///
    multistate_state ///
    volume_state ///
    new_state ///
    time_state ///
    tele_state, ///
    keep( ///
        l_physicians_per_100k ///
        l_multistate_share ///
        l_ln_em_volume ///
        l_share_new ///
        l_avg_visit_time ///
        l_telehealth_share ///
    ) ///
    se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, labels("Observations" "R-squared"))


***************************************************************************
*** 9. DISPLAY COMBINED RESULTS
***************************************************************************

esttab ///
    combined_year ///
    combined_state ///
    combined_multi_year ///
    combined_multi_state, ///
    keep( ///
        l_physicians_per_100k ///
        l_multistate_share ///
        l_ln_em_cnt ///
        l_share_new ///
        l_avg_visit_time ///
        l_telehealth_share ///
    ) ///
    se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, labels("Observations" "R-squared"))




