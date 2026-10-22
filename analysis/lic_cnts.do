clear all 

global wd "/Volumes/Untitled/Interstate Licensure"
******************************************************************************

use "${wd}/data/output/licensure_ch2_2017_2023", clear


***************************************************************************
*** LICENSURE TRANSITIONS
***************************************************************************

* Declare provider-year panel
xtset npi year

*------------------------------------------------------------
* 1. Previous year's number of licensed states
*------------------------------------------------------------

gen lag_n_states = L.n_unique_states

* Only define transitions when years are consecutive
gen consecutive = year == L.year + 1


*------------------------------------------------------------
* 2. Cap at 4+ states for readable transition categories
*------------------------------------------------------------

gen n_states_cat = n_unique_states
replace n_states_cat = 4 if n_states_cat >= 4

gen lag_states_cat = lag_n_states
replace lag_states_cat = 4 if lag_states_cat >= 4 & lag_states_cat != .


*------------------------------------------------------------
* 3. Full year-to-year transition matrix
*------------------------------------------------------------

tab lag_states_cat n_states_cat if consecutive, row

/*
Rows = number of states in year t-1
Columns = number of states in year t

For example:
    row 1, column 2 = physicians going from 1 -> 2
    row 2, column 3 = physicians going from 2 -> 3
*/


*------------------------------------------------------------
* 4. Explicit counts of upward transitions
*------------------------------------------------------------

count if lag_states_cat==1 & n_states_cat==2 & consecutive
display "1 -> 2: " r(N)

count if lag_states_cat==1 & n_states_cat==3 & consecutive
display "1 -> 3: " r(N)

count if lag_states_cat==1 & n_states_cat==4 & consecutive
display "1 -> 4+: " r(N)

count if lag_states_cat==2 & n_states_cat==3 & consecutive
display "2 -> 3: " r(N)

count if lag_states_cat==2 & n_states_cat==4 & consecutive
display "2 -> 4+: " r(N)

count if lag_states_cat==3 & n_states_cat==4 & consecutive
display "3 -> 4+: " r(N)


***************************************************************************
*** LICENSURE TRANSITIONS AFTER IMLC ADOPTION
***************************************************************************

*------------------------------------------------------------
* 1. Transition matrix after IMLC is active
*------------------------------------------------------------

* Counts
tab lag_states_cat n_states_cat if imlc_enacted_dd==1

* Row percentages
tab lag_states_cat n_states_cat if imlc_enacted_dd==1, row


*------------------------------------------------------------
* 2. Explicit counts of upward transitions after IMLC
*------------------------------------------------------------

count if lag_states_cat==1 & n_states_cat==2 & imlc_enacted_dd==1
display "Post-IMLC: 1 -> 2: " r(N)

count if lag_states_cat==1 & n_states_cat==3 & imlc_enacted_dd==1
display "Post-IMLC: 1 -> 3: " r(N)

count if lag_states_cat==1 & n_states_cat==4 & imlc_enacted_dd==1
display "Post-IMLC: 1 -> 4+: " r(N)

count if lag_states_cat==2 & n_states_cat==3 & imlc_enacted_dd==1
display "Post-IMLC: 2 -> 3: " r(N)

count if lag_states_cat==2 & n_states_cat==4 & imlc_enacted_dd==1
display "Post-IMLC: 2 -> 4+: " r(N)

count if lag_states_cat==3 & n_states_cat==4 & imlc_enacted_dd==1
display "Post-IMLC: 3 -> 4+: " r(N)


***************************************************************************
*** COMPARE LICENSURE INCREASES WITH AND WITHOUT IMLC
***************************************************************************

* Indicator for any increase in number of licensed states
gen increased_states = n_unique_states > lag_n_states ///
    if lag_n_states != .

* Compare probability of increasing licenses
tab imlc_enacted_dd increased_states, row


*------------------------------------------------------------
* 3. Transition matrices without vs. with IMLC
*------------------------------------------------------------

* IMLC not active
tab lag_states_cat n_states_cat if imlc_enacted_dd==0, row

* IMLC active
tab lag_states_cat n_states_cat if imlc_enacted_dd==1, row


***************************************************************************
*** CHECK FOR REPEATED TRANSITIONS BY THE SAME PHYSICIAN
***************************************************************************

* Check whether physicians make the same upward transition more than once

gen trans_12 = lag_states_cat==1 & n_states_cat==2 & imlc_enacted_dd==1
gen trans_13 = lag_states_cat==1 & n_states_cat==3 & imlc_enacted_dd==1
gen trans_14 = lag_states_cat==1 & n_states_cat==4 & imlc_enacted_dd==1
gen trans_23 = lag_states_cat==2 & n_states_cat==3 & imlc_enacted_dd==1
gen trans_24 = lag_states_cat==2 & n_states_cat==4 & imlc_enacted_dd==1
gen trans_34 = lag_states_cat==3 & n_states_cat==4 & imlc_enacted_dd==1

foreach x in 12 13 14 23 24 34 {
    bysort npi: egen n_trans_`x' = total(trans_`x')
    
    * One observation per physician for this diagnostic
    egen tag_`x' = tag(npi) if n_trans_`x'>0
    
    tab n_trans_`x' if tag_`x'==1
}
