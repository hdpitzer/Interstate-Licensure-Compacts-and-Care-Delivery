clear all 

global wd "/Volumes/Untitled/Interstate Licensure"

*********************************************************************

forvalues year=2017/2026 {
     use "${wd}/data/output/NPPES/npi`year'clean", clear
	 
	 gen year = `year'
	 
	 save "${wd}/data/output/NPPES/npi`year'clean", replace
}




use "${wd}/data/output/NPPES/npi2017clean", clear

forvalues year=2018/2026 {
    append using "${wd}/data/output/NPPES/npi`year'clean", force
}

drop healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108

drop if n_unique_states < 1

save "${wd}/data/output/NPPES/npi_2017_2026_full", replace


*********************************************************************
** Limit sample to one state license at first observation

bys npi (year): gen first_year = year[1]
gen in_first_year = (year == first_year)

gen multi_state_first = in_first_year & n_unique_states > 1

by npi: egen drop_provider = max(multi_state_first)

drop if drop_provider
drop drop_provider multi_state_first


** Limit to providers who retain origin state license
forvalues i=1/15 {
	replace plstate_`i'= "" if plstate_`i' == "NA"
}

gen origin_state = ""

forvalues i=1/15 {
	replace origin_state = plstate_`i' if in_first_year & origin_state == "" & plstate_`i' != ""
}

by npi (year): replace origin_state = origin_state[1]


gen has_origin = 0

forvalues i=1/15 {
	replace has_origin = 1 if plstate_`i' == origin_state
}


gen lost_origin = (has_origin == 0)
by npi: egen drop_provider = max(lost_origin)

drop if drop_provider
drop drop_provider lost_origin has_origin


save "${wd}/data/output/NPPES/npi_2017_2026_full", replace

*********************************************************************
** Merge compacts


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


save "${wd}/data/output/NPPES/npi_compact_merge_2017_2026", replace

***************************************************************************
** Merge phys comp

merge m:1 npi year using "${wd}/data/output/physician-compare/doctors_and_clinicians_2017_2023", keep(1 3) nogen

drop if year >2023
drop if graduationyear ==.


save "${wd}/data/output/licensure_full_2017_2023", replace





