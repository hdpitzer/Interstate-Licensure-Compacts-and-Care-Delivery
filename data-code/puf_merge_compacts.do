clear all


global wd "/Users/Student/Library/CloudStorage/OneDrive-Emory/04 Spring 2026/Interstate Licensure"



************************************************************
* Merge All Outcomes into One State-Year Dataset
************************************************************

* 1. Start with telehealth share
use "${wd}/data/output/PUF/telehealth_share_provider_year_2016_2023", clear

// * 2. Merge E/M volume
// merge 1:1 rndrng_npi year using "${wd}/data/output/PUF/em_volume_provider_year_2016_2023", keep(match master) nogenerate

* 3. Merge average visit time
merge 1:1 rndrng_npi year using "${wd}/data/output/PUF/visit_time_provider_year_2016_2023", keep(match master) nogenerate

* 4. Merge share of new patients
merge 1:1 rndrng_npi year using "${wd}/data/output/PUF/share_new_provider_year_2016_2023", keep(match master) nogenerate



save "${wd}/data/output/PUF/puf_provider_year_merge_2016_2023", replace

***************************************************************
// * Merge Compacts
//
// drop if em_volume == .
//
// rename rndrng_prvdr_state_fips stfips
// drop if inlist(stfips, 78, 60, 69, 66, 72, .)
//
//
// merge m:1 stfips using "${wd}/data/input/stlookup", keep(1 3) keepusing(state)
//
// merge m:1 state using "${wd}/data/input/compact_dates", keep(1 3) nogen
//
// foreach var in imlc_enacted psypact_enacted psypact_active {
//	
// 	gen `var'_dd = 0
// 		replace `var'_dd = 1 if year> year(`var') & `var' !=.
//	
// }
//
//
// replace imlc_enacted_dd=0 if year<2018
//
// gen compact = imlc_enacted_dd
// replace compact = 1 if psypact_active_dd==1
//
//
//
// save "${wd}/data/output/PUF/puf_compact_merge_2016_2023", replace
