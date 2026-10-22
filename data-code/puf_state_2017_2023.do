clear all 

global wd "/Volumes/Untitled/Interstate Licensure"


use "${wd}/data/output/PUF/puf_licensure_merge_2016_2023", clear

*******************************************************************************
*Create state-year panel

collapse (sum) tele_cnt em_cnt total_weighted new_cnt est_cnt, ///
    by(origin_state year)

* Telehealth share
gen telehealth_share = tele_cnt / (em_cnt + tele_cnt)

* Outpatient E/M volume
gen em_volume = em_cnt
gen ln_em_volume = ln(em_volume)

* Average visit time
gen avg_visit_time = total_weighted / em_cnt

* Share of new patient visits
gen share_new = new_cnt / (new_cnt + est_cnt)


save "${wd}/data/output/PUF/puf_state_year_2016_2023", replace

*******************************************************************************
*Merge IMLC

frame create stlookup
frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


frlink m:1 origin_state, frame(stlookup postal)
frget state = state, from(stlookup)

drop if stlookup == .
drop if state == "Puerto Rico"


merge m:1 state using "${wd}/data/input/compact_dates", keep(1 3) nogen

foreach var in imlc_enacted psypact_enacted psypact_active {
	
	gen `var'_dd = 0
		replace `var'_dd = 1 if year> year(`var') & `var' !=.
	
}


replace imlc_enacted_dd=0 if year<2018

gen compact = imlc_enacted_dd
replace compact = 1 if psypact_active_dd==1


save "${wd}/data/output/PUF/puf_state_year_compact_2017_2023", replace

