clear all


global wd "/Users/Student/Library/CloudStorage/OneDrive-Emory/04 Spring 2026/Interstate Licensure"


forvalues year=2013/2023 {
	local year2 = `year'
	import delimited "${wd}/data/input/PUF/CSV/Medicare_Physician_Other_Practitioners_by_Provider_and_Service_`year'.csv", clear
	
	gen year=`year'
	
	qui compress
	
	save "${wd}/data/input/PUF/Stata/rawpuf_`year'", replace
	
}


use "${wd}/data/input/PUF/Stata/rawpuf_2013", clear

forvalues year=2014/2023 {
    append using "${wd}/data/input/PUF/Stata/rawpuf_`year'", force
}

save "${wd}/data/input/PUF/raw_puf_2013_2023", replace


********************************************************************************

************************************************************
* Medicare Provider & Service PUF Construction File
* Outcomes:
* 1. Telehealth share (dedicated codes only)
* 2. Outpatient E/M volume
* 3. Average visit intensity (proxy for visit length)
* 4. Share of new patient visits
************************************************************

drop if year<2016

*----------------------------
* Ensure HCPCS numeric version exists
*----------------------------

capture confirm numeric variable hcpcs_cd
if _rc == 0 {
    gen hcpcs_num = hcpcs_cd
}
else {
    gen hcpcs_num = real(hcpcs_cd)
}

*----------------------------
* Define E/M visit indicators
*----------------------------

gen em_visit = ///
    inrange(hcpcs_num, 99201, 99205) | ///
    inrange(hcpcs_num, 99211, 99215)

gen new_visit = inrange(hcpcs_num, 99201, 99205)
gen est_visit = inrange(hcpcs_num, 99211, 99215)

*----------------------------
* Define dedicated telehealth codes
*----------------------------

gen tele_dedicated = 0

// replace tele_dedicated = 1 if hcpcs_cd == "G0425"
// replace tele_dedicated = 1 if hcpcs_cd == "G0426"
// replace tele_dedicated = 1 if hcpcs_cd == "G0427"
// replace tele_dedicated = 1 if hcpcs_cd == "G0406"
// replace tele_dedicated = 1 if hcpcs_cd == "G0407"
// replace tele_dedicated = 1 if hcpcs_cd == "G0408"
// replace tele_dedicated = 1 if hcpcs_cd == "G2010"
// replace tele_dedicated = 1 if hcpcs_cd == "G2012"
replace tele_dedicated = 1 if hcpcs_cd == "99441"
replace tele_dedicated = 1 if hcpcs_cd == "99442"
replace tele_dedicated = 1 if hcpcs_cd == "99443"
replace tele_dedicated = 1 if hcpcs_cd == "98966"
replace tele_dedicated = 1 if hcpcs_cd == "98967"
replace tele_dedicated = 1 if hcpcs_cd == "98968"

*----------------------------
* Define visit time proxy (approximate minutes per code)
*----------------------------
gen visit_time = .

* New patient visits (99201–99205)
replace visit_time = 15  if hcpcs_num == 99201  // ~15 min
replace visit_time = 25  if hcpcs_num == 99202  // ~25 min
replace visit_time = 35  if hcpcs_num == 99203  // ~35 min
replace visit_time = 50  if hcpcs_num == 99204  // ~50 min
replace visit_time = 60  if hcpcs_num == 99205  // ~60 min

* Established patient visits (99211–99215)
replace visit_time = 5   if hcpcs_num == 99211  // ~5 min
replace visit_time = 15  if hcpcs_num == 99212  // ~15 min
replace visit_time = 25  if hcpcs_num == 99213  // ~25 min
replace visit_time = 35  if hcpcs_num == 99214  // ~35 min
replace visit_time = 50  if hcpcs_num == 99215  // ~50 min

* Weighted visit time for averaging
gen weighted_time = visit_time * tot_srvcs


save "${wd}/data/input/PUF/puf_clean_2016_2023", replace
************************************************************
* 1. TELEHEALTH SHARE (Dedicated Codes Only)
************************************************************

preserve

gen tele_cnt = tot_srvcs if tele_dedicated==1
gen em_cnt   = tot_srvcs if em_visit==1

collapse (sum) tele_cnt em_cnt, by(rndrng_npi year)


gen telehealth_share = tele_cnt / (em_cnt + tele_cnt)


************************************************************
* 2. OUTPATIENT E/M VOLUME
************************************************************

gen ln_em_cnt = log(em_cnt)

save "${wd}/data/output/PUF/telehealth_share_provider_year_2016_2023", replace

restore

************************************************************
* 3. AVERAGE VISIT TIME
************************************************************

preserve

collapse (sum) total_weighted = weighted_time ///
         (sum) em_cnt   = tot_srvcs ///
         if em_visit==1, by(rndrng_npi year)

gen avg_visit_time = total_weighted / em_cnt

save "${wd}/data/output/PUF/visit_time_provider_year_2016_2023", replace

restore

************************************************************
* 4. SHARE OF NEW PATIENT VISITS
************************************************************

preserve

gen new_cnt = tot_srvcs if new_visit==1
gen est_cnt = tot_srvcs if est_visit==1

collapse (sum) new_cnt est_cnt, by(rndrng_npi year)

gen em_cnt = new_cnt + est_cnt
gen share_new = new_cnt / em_cnt

save "${wd}/data/output/PUF/share_new_provider_year_2016_2023", replace

restore

************************************************************
* END
************************************************************


