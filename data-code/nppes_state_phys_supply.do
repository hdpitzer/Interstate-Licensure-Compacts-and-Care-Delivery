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

save "${wd}/data/output/NPPES/npi_2017_2026_full_1", replace


***************************************************************************
*** CREATE PHYSICIAN-ONLY NPPES SAMPLE
***************************************************************************

*------------------------------------------------------------
* 1. Physician taxonomy
*------------------------------------------------------------
* Identify providers with at least one Allopathic & Osteopathic Physician taxonomy across the 15 taxonomy fields

gen physician_tax = 0

forvalues i = 1/15 {
    replace physician = 1 if ///
        substr(upper(trim(taxcode_`i')), 1, 2) == "20"
}

*------------------------------------------------------------
* 2. Physician credential
*------------------------------------------------------------

* Standardize credential string
gen credential_clean = upper(trim(providercredentialtext))

* Remove periods so MD/M.D. and DO/D.O. are treated the same
replace credential_clean = subinstr(credential_clean, ".", "", .)

* Identify MD or DO when they appear as distinct credentials
gen physician_cred = ///
    regexm(credential_clean, "(^|[^A-Z])MD([^A-Z]|$)") | ///
    regexm(credential_clean, "(^|[^A-Z])DO([^A-Z]|$)")



*------------------------------------------------------------
* 3. Combined physician definition
*------------------------------------------------------------

gen physician = physician_tax==1 | physician_cred==1

tab physician
tab physician_tax physician_cred



***************************************************************************
*** SAVE PHYSICIAN-ONLY FILE
***************************************************************************

keep if physician==1

save "${wd}/data/output/NPPES/npi_2017_2026_physicians", replace



***************************************************************************
*** CREATE STATE-YEAR PHYSICIAN SUPPLY DATA
***************************************************************************

* Keep variables needed for state-level measures
keep npi year n_unique_states plfips_*


*------------------------------------------------------------
* Identify multistate physicians
*------------------------------------------------------------

gen multistate = n_unique_states > 1

label var multistate "Licensed in more than one state"


*------------------------------------------------------------
* Reshape license states from wide to long
*------------------------------------------------------------

reshape long plfips_, i(npi year) j(license_num)

rename plfips_ state_fips

* Remove empty license-state slots
drop if missing(state_fips)


*------------------------------------------------------------
* Remove duplicate physician-state-year observations
*------------------------------------------------------------

* A physician may have multiple licenses/taxonomies associated with
* the same state. Each physician should count only once in each state-year.

duplicates drop npi year state_fips, force

* Confirm one observation per physician-state-year
isid npi year state_fips


***************************************************************************
*** COLLAPSE TO STATE-YEAR
***************************************************************************

collapse ///
    (count) n_physicians = npi ///
    (mean) multistate_share = multistate, ///
    by(state_fips year)

label var n_physicians ///
    "Number of physicians holding active state license"

label var multistate_share ///
    "Share of licensed physicians licensed in multiple states"


***************************************************************************
*** CHECK STATE-YEAR DATA
***************************************************************************

sort state_fips year

summ n_physicians multistate_share

list state_fips year n_physicians multistate_share ///
    in 1/30, sepby(state_fips)

isid state_fips year


***************************************************************************
*** SAVE STATE-YEAR PHYSICIAN DATA
***************************************************************************

save "${wd}/data/output/NPPES/state_year_physician_supply", replace




***************************************************************************
*** Merging state population
***************************************************************************

*** 2017-2019 Population estimates

import excel "${wd}/data/input/Census/nst-est2020int-pop.xlsx", ///
	sheet("NST-EST2020INT-POP") ///
	cellrange(A4:M64) ///
	firstrow clear

	
rename A state
rename J pop2017
rename K pop2018
rename L pop2019

keep state pop2017 pop2018 pop2019

* State observations begin with a period in the Census file
keep if substr(state,1,1)=="."

* Remove leading period
replace state = substr(state,2,.)

* Exclude Puerto Rico
drop if state=="Puerto Rico"

* Convert wide population data to long
reshape long pop, i(state) j(year)

rename pop population


tempfile pop1719
save `pop1719'



*** 2020-2023 Population estimates

import excel "${wd}/data/input/Census/NST-EST2025-POP.xlsx", ///
	sheet("NST-EST2025-POP") ///
	cellrange(A4:H64) ///
	firstrow clear
	
	
rename A state
rename C pop2020
rename D pop2021
rename E pop2022
rename F pop2023

keep state pop2020 pop2021 pop2022 pop2023

* State observations begin with a period
keep if substr(state,1,1)=="."

* Remove leading period
replace state = substr(state,2,.)

* Exclude Puerto Rico
drop if state=="Puerto Rico"

* Convert wide population data to long
reshape long pop, i(state) j(year)

rename pop population


*** 3. APPEND 2017-2019 AND 2020-2023

append using `pop1719'

sort state year

merge m:1 state using "${wd}/data/input/stlookup.dta", ///
    keepusing(stfips)
	
drop if _merge==2
drop _merge


rename stfips state_fips
order state_fips state year population
sort state_fips year

save "${wd}/data/input/Census/state_population_2017_2023", replace


*** Merge

use "${wd}/data/output/NPPES/state_year_physician_supply", clear

* Chapter 2 study period
keep if inrange(year,2017,2023)

merge 1:1 state_fips year ///
    using "${wd}/data/input/Census/state_population_2017_2023"

drop _merge




***************************************************************************
*** PHYSICIANS PER 100,000 RESIDENTS
***************************************************************************

gen physicians_per_100k = ///
    (n_physicians / population) * 100000

label var physicians_per_100k ///
    "NPPES-listed licensed physicians per 100,000 residents"

summ n_physicians population physicians_per_100k multistate_share

isid state_fips year

save "${wd}/data/output/NPPES/state_year_physician_supply_population", replace



