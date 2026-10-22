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

**Create event time vars

egen min_imlc_enacted_dd = min(cond(imlc_enacted_dd==1,year,.)), by(origin_state)

gen imlc_enacted_dd_y = year - min_imlc_enacted_dd
gen imlc_enacted_dd_never = (min_imlc_enacted_dd==.)

replace imlc_enacted_dd_y = -1 if imlc_enacted_dd_y == .
replace imlc_enacted_dd_y = -4 if imlc_enacted_dd_y < -4
replace imlc_enacted_dd_y = 4 if imlc_enacted_dd_y > 4


forvalues n=-4/-2 {
	local n2 = abs(`n')
	gen imlc_enacted_dd_bef_`n2' = (imlc_enacted_dd_y==`n')
	lab var imlc_enacted_dd_bef_`n2' "`n'"
}

forvalues n=0/4 {
	gen imlc_enacted_dd_aft_`n' = (imlc_enacted_dd_y==`n')
	lab var imlc_enacted_dd_aft_`n' "`n'"
}


***************************************************************************

** ITT event studies **

**E/m volume
*Canonical ES
eststo m1: reghdfe ln_em_cnt imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*   imlc_enacted_dd_y parity, absorb(npi year) cluster(npi)

*SA ES
eventstudyinteract ln_em_cnt imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*, ///
	absorb(npi year) ///
	cohort(min_imlc_enacted_dd) ///
	covariates(parity) ///
	control_cohort(imlc_enacted_dd_never) ///
	vce(cluster npi)

	
*Graph
event_plot e(b_iw)#e(V_iw) m1, ciplottype(rcap) ///
				graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
				yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
				ytitle("Outpatient visit volume") ///
				title(`"`titletext'"') ///
				legend(rows(2) order(1 3) ///
				region(lstyle(none)) ///
				label(1 "S&A") label(3 "Canonical") on)) ///
				lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
				lead_opt2(color(green)) lag_opt2(color(green)) ///
				lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
				stub_lead(imlc_enacted_dd_bef_# imlc_enacted_dd_bef_#) stub_lag(imlc_enacted_dd_aft_# imlc_enacted_dd_aft_#) trimlag(4) trimlead(4) ///
                together plottype(scatter) perturb(-.2 -.0)

graph save "Graph" "${wd}/analysis/figures/event_em_cnt.gph", replace
graph export "${wd}/analysis/figures/event_em_cnt.tif", as(tif) replace


**New patient share
*Canonical ES
eststo m2: reghdfe share_new imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*   imlc_enacted_dd_y parity, absorb(npi year) cluster(npi)

*SA ES
eventstudyinteract share_new imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*, ///
	absorb(npi year) ///
	cohort(min_imlc_enacted_dd) ///
	covariates(parity) ///
	control_cohort(imlc_enacted_dd_never) ///
	vce(cluster npi)

	
*Graph
event_plot e(b_iw)#e(V_iw) m2, ciplottype(rcap) ///
				graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
				yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
				ytitle("New patient share") ///
				title(`"`titletext'"') ///
				legend(rows(2) order(1 3) ///
				region(lstyle(none)) ///
				label(1 "S&A") label(3 "Canonical") on)) ///
				lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
				lead_opt2(color(green)) lag_opt2(color(green)) ///
				lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
				stub_lead(imlc_enacted_dd_bef_# imlc_enacted_dd_bef_#) stub_lag(imlc_enacted_dd_aft_# imlc_enacted_dd_aft_#) trimlag(4) trimlead(4) ///
                together plottype(scatter) perturb(-.2 -.0)

graph save "Graph" "${wd}/analysis/figures/event_share_new.gph", replace
graph export "${wd}/analysis/figures/event_share_new.tif", as(tif) replace


**Avg visit time
*Canonical ES
eststo m3: reghdfe avg_visit_time imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*   imlc_enacted_dd_y parity, absorb(npi year) cluster(npi)

*SA ES
eventstudyinteract avg_visit_time imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*, ///
	absorb(npi year) ///
	cohort(min_imlc_enacted_dd) ///
	covariates(parity) ///
	control_cohort(imlc_enacted_dd_never) ///
	vce(cluster npi)

	
*Graph
event_plot e(b_iw)#e(V_iw) m3, ciplottype(rcap) ///
				graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
				yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
				ytitle("Average visit length") ///
				title(`"`titletext'"') ///
				legend(rows(2) order(1 3) ///
				region(lstyle(none)) ///
				label(1 "S&A") label(3 "Canonical") on)) ///
				lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
				lead_opt2(color(green)) lag_opt2(color(green)) ///
				lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
				stub_lead(imlc_enacted_dd_bef_# imlc_enacted_dd_bef_#) stub_lag(imlc_enacted_dd_aft_# imlc_enacted_dd_aft_#) trimlag(4) trimlead(4) ///
                together plottype(scatter) perturb(-.2 -.0)

graph save "Graph" "${wd}/analysis/figures/event_avg_visit_time.gph", replace
graph export "${wd}/analysis/figures/event_avg_visit_time.tif", as(tif) replace


**Telehealth share
*Canonical ES
eststo m4: reghdfe telehealth_share imlc_enacted_dd_bef_* imlc_enacted_dd_aft_* imlc_enacted_dd_y parity, absorb(npi year) cluster(npi)

*SA ES
eventstudyinteract telehealth_share imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*, ///
	absorb(npi year) ///
	cohort(min_imlc_enacted_dd) ///
	covariates(parity) ///
	control_cohort(imlc_enacted_dd_never) ///
	vce(cluster npi)

	
*Graph
event_plot e(b_iw)#e(V_iw) m4, ciplottype(rcap) ///
				graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
				yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
				ytitle("Telehealth share") ///
				title(`"`titletext'"') ///
				legend(rows(2) order(1 3) ///
				region(lstyle(none)) ///
				label(1 "S&A") label(3 "Canonical") on)) ///
				lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
				lead_opt2(color(green)) lag_opt2(color(green)) ///
				lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
				stub_lead(imlc_enacted_dd_bef_# imlc_enacted_dd_bef_#) stub_lag(imlc_enacted_dd_aft_# imlc_enacted_dd_aft_#) trimlag(4) trimlead(4) ///
                together plottype(scatter) perturb(-.2 -.0)

graph save "Graph" "${wd}/analysis/figures/event_tele_share.gph", replace
graph export "${wd}/analysis/figures/event_tele_share.tif", as(tif) replace




** Interaction event studies **

**Create interaction event time vars
foreach var of varlist imlc_enacted_dd_bef_* imlc_enacted_dd_aft_* {
	gen `var'_ms = `var' * multistate
}

**E/m volume
*Canonical interaction ES
eststo m5: reghdfe ln_em_cnt imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*  multistate parity, absorb(npi year) cluster(npi)

*Total IMLC effect for multistate providers
nlcom ///
	(bef4: _b[imlc_enacted_dd_bef_4] + _b[imlc_enacted_dd_bef_4_ms]) ///
	(bef3: _b[imlc_enacted_dd_bef_3] + _b[imlc_enacted_dd_bef_3_ms]) ///
	(bef2: _b[imlc_enacted_dd_bef_2] + _b[imlc_enacted_dd_bef_2_ms]) ///
	(aft0: _b[imlc_enacted_dd_aft_0] + _b[imlc_enacted_dd_aft_0_ms]) ///
	(aft1: _b[imlc_enacted_dd_aft_1] + _b[imlc_enacted_dd_aft_1_ms]) ///
	(aft2: _b[imlc_enacted_dd_aft_2] + _b[imlc_enacted_dd_aft_2_ms]) ///
	(aft3: _b[imlc_enacted_dd_aft_3] + _b[imlc_enacted_dd_aft_3_ms]) ///
	(aft4: _b[imlc_enacted_dd_aft_4] + _b[imlc_enacted_dd_aft_4_ms]), post

eststo m5_total

*Graph interaction ES
event_plot m5_total, ciplottype(rcap) ///
		graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
		yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ytitle("Outpatient visit volume: Multistate") ///
		title(`"`titletext'"') ///
		legend(off)) ///
		lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
		lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
	stub_lead(bef#) ///
	stub_lag(aft#) ///
	trimlag(4) trimlead(4) ///
	together plottype(scatter)

graph save "Graph" "${wd}/analysis/figures/event_em_cnt_int.gph", replace
graph export "${wd}/analysis/figures/event_em_cnt_int.tif", as(tif) replace


**New patient share
*Canonical interaction ES
eststo m6: reghdfe share_new imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*  multistate imlc_enacted_dd_bef_*_ms imlc_enacted_dd_aft_*_ms parity, absorb(npi year) cluster(npi)

*Total IMLC effect for multistate providers
nlcom ///
	(bef4: _b[imlc_enacted_dd_bef_4] + _b[imlc_enacted_dd_bef_4_ms]) ///
	(bef3: _b[imlc_enacted_dd_bef_3] + _b[imlc_enacted_dd_bef_3_ms]) ///
	(bef2: _b[imlc_enacted_dd_bef_2] + _b[imlc_enacted_dd_bef_2_ms]) ///
	(aft0: _b[imlc_enacted_dd_aft_0] + _b[imlc_enacted_dd_aft_0_ms]) ///
	(aft1: _b[imlc_enacted_dd_aft_1] + _b[imlc_enacted_dd_aft_1_ms]) ///
	(aft2: _b[imlc_enacted_dd_aft_2] + _b[imlc_enacted_dd_aft_2_ms]) ///
	(aft3: _b[imlc_enacted_dd_aft_3] + _b[imlc_enacted_dd_aft_3_ms]) ///
	(aft4: _b[imlc_enacted_dd_aft_4] + _b[imlc_enacted_dd_aft_4_ms]), post

eststo m6_total

*Graph interaction ES
event_plot m6_total, ciplottype(rcap) ///
	graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
		yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ytitle("New patient share: Multistate") ///
		title(`"`titletext'"') ///
		legend(off)) ///
		lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
		lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
	stub_lead(bef#) ///
	stub_lag(aft#) ///
	trimlag(4) trimlead(4) ///
	together plottype(scatter)

graph save "Graph" "${wd}/analysis/figures/event_share_new_int.gph", replace
graph export "${wd}/analysis/figures/event_share_new_int.tif", as(tif) replace


**Avg visit time
*Canonical interaction ES
eststo m7: reghdfe avg_visit_time imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*  multistate imlc_enacted_dd_bef_*_ms imlc_enacted_dd_aft_*_ms parity, absorb(npi year) cluster(npi)

*Total IMLC effect for multistate providers
nlcom ///
	(bef4: _b[imlc_enacted_dd_bef_4] + _b[imlc_enacted_dd_bef_4_ms]) ///
	(bef3: _b[imlc_enacted_dd_bef_3] + _b[imlc_enacted_dd_bef_3_ms]) ///
	(bef2: _b[imlc_enacted_dd_bef_2] + _b[imlc_enacted_dd_bef_2_ms]) ///
	(aft0: _b[imlc_enacted_dd_aft_0] + _b[imlc_enacted_dd_aft_0_ms]) ///
	(aft1: _b[imlc_enacted_dd_aft_1] + _b[imlc_enacted_dd_aft_1_ms]) ///
	(aft2: _b[imlc_enacted_dd_aft_2] + _b[imlc_enacted_dd_aft_2_ms]) ///
	(aft3: _b[imlc_enacted_dd_aft_3] + _b[imlc_enacted_dd_aft_3_ms]) ///
	(aft4: _b[imlc_enacted_dd_aft_4] + _b[imlc_enacted_dd_aft_4_ms]), post

eststo m7_total

*Graph interaction ES
event_plot m7_total, ciplottype(rcap) ///
	graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
		yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ytitle("Average visit length: Multistate") ///
		title(`"`titletext'"') ///
		legend(off)) ///
		lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
		lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
	stub_lead(bef#) ///
	stub_lag(aft#) ///
	trimlag(4) trimlead(4) ///
	together plottype(scatter)

graph save "Graph" "${wd}/analysis/figures/event_avg_visit_time_int.gph", replace
graph export "${wd}/analysis/figures/event_avg_visit_time_int.tif", as(tif) replace


**Telehealth share
*Canonical interaction ES
eststo m8: reghdfe telehealth_share imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*  multistate imlc_enacted_dd_bef_*_ms imlc_enacted_dd_aft_*_ms parity, absorb(npi year) cluster(npi)

*Total IMLC effect for multistate providers
nlcom ///
	(bef4: _b[imlc_enacted_dd_bef_4] + _b[imlc_enacted_dd_bef_4_ms]) ///
	(bef3: _b[imlc_enacted_dd_bef_3] + _b[imlc_enacted_dd_bef_3_ms]) ///
	(bef2: _b[imlc_enacted_dd_bef_2] + _b[imlc_enacted_dd_bef_2_ms]) ///
	(aft0: _b[imlc_enacted_dd_aft_0] + _b[imlc_enacted_dd_aft_0_ms]) ///
	(aft1: _b[imlc_enacted_dd_aft_1] + _b[imlc_enacted_dd_aft_1_ms]) ///
	(aft2: _b[imlc_enacted_dd_aft_2] + _b[imlc_enacted_dd_aft_2_ms]) ///
	(aft3: _b[imlc_enacted_dd_aft_3] + _b[imlc_enacted_dd_aft_3_ms]) ///
	(aft4: _b[imlc_enacted_dd_aft_4] + _b[imlc_enacted_dd_aft_4_ms]), post

eststo m8_total

*Graph interaction ES
event_plot m8_total, ciplottype(rcap) ///
	graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
		yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ytitle("Telehealth share: Multistate") ///
		title(`"`titletext'"') ///
		legend(off)) ///
		lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
		lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
	stub_lead(bef#) ///
	stub_lag(aft#) ///
	trimlag(4) trimlead(4) ///
	together plottype(scatter)

graph save "Graph" "${wd}/analysis/figures/event_tele_share_int.gph", replace
graph export "${wd}/analysis/figures/event_tele_share_int.tif", as(tif) replace










** Interaction (limited sample) **

**Identify multistate year
egen multistate_year = min(cond(multistate==1, year, .)), by(npi)


**Categorize providers by multistate and IMLC timing
gen multistate_timing = .

* Never multistate, IMLC state
replace multistate_timing = 0 if multistate_year==. & min_imlc_enacted_dd!=.

* Multistate before IMLC
replace multistate_timing = 1 if multistate_year < min_imlc_enacted_dd ///
	& multistate_year!=. & min_imlc_enacted_dd!=.

* Becomes multistate in IMLC year
replace multistate_timing = 2 if multistate_year == min_imlc_enacted_dd ///
	& multistate_year!=. & min_imlc_enacted_dd!=.

* Becomes multistate after IMLC
replace multistate_timing = 3 if multistate_year > min_imlc_enacted_dd ///
	& multistate_year!=. & min_imlc_enacted_dd!=.

* Multistate, never IMLC
replace multistate_timing = 4 if multistate_year!=. & min_imlc_enacted_dd==.

* Never multistate, never IMLC
replace multistate_timing = 5 if multistate_year==. & min_imlc_enacted_dd==.

label define multistate_timing ///
	0 "Never multistate, IMLC" ///
	1 "Multistate before IMLC" ///
	2 "Multistate in IMLC year" ///
	3 "Multistate after IMLC" ///
	4 "Multistate, never IMLC" ///
	5 "Never multistate, never IMLC"

label values multistate_timing multistate_timing


egen npi_tag = tag(npi)

tab multistate_timing if npi_tag==1


**Create interaction event time vars
foreach var of varlist imlc_enacted_dd_bef_* imlc_enacted_dd_aft_* {
	gen `var'_ms = `var' * multistate
}

**E/m volume
*Canonical interaction ES
eststo m9: reghdfe ln_em_cnt imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*  multistate parity if multistate_timing!=1, absorb(npi year) cluster(npi)

*Total IMLC effect for multistate providers
nlcom ///
	(bef4: _b[imlc_enacted_dd_bef_4] + _b[imlc_enacted_dd_bef_4_ms]) ///
	(bef3: _b[imlc_enacted_dd_bef_3] + _b[imlc_enacted_dd_bef_3_ms]) ///
	(bef2: _b[imlc_enacted_dd_bef_2] + _b[imlc_enacted_dd_bef_2_ms]) ///
	(aft0: _b[imlc_enacted_dd_aft_0] + _b[imlc_enacted_dd_aft_0_ms]) ///
	(aft1: _b[imlc_enacted_dd_aft_1] + _b[imlc_enacted_dd_aft_1_ms]) ///
	(aft2: _b[imlc_enacted_dd_aft_2] + _b[imlc_enacted_dd_aft_2_ms]) ///
	(aft3: _b[imlc_enacted_dd_aft_3] + _b[imlc_enacted_dd_aft_3_ms]) ///
	(aft4: _b[imlc_enacted_dd_aft_4] + _b[imlc_enacted_dd_aft_4_ms]), post

eststo m9_total

*Graph interaction ES
event_plot m9_total, ciplottype(rcap) ///
		graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
		yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ytitle("Outpatient visit volume: Multistate") ///
		title(`"`titletext'"') ///
		legend(off)) ///
		lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
		lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
	stub_lead(bef#) ///
	stub_lag(aft#) ///
	trimlag(4) trimlead(4) ///
	together plottype(scatter)

graph save "Graph" "${wd}/analysis/figures/event_em_cnt_int_ltd.gph", replace
graph export "${wd}/analysis/figures/event_em_cnt_int_ltd.tif", as(tif) replace


**New patient share
*Canonical interaction ES
eststo m10: reghdfe share_new imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*  multistate imlc_enacted_dd_bef_*_ms imlc_enacted_dd_aft_*_ms parity if multistate_timing!=1, absorb(npi year) cluster(npi)

*Total IMLC effect for multistate providers
nlcom ///
	(bef4: _b[imlc_enacted_dd_bef_4] + _b[imlc_enacted_dd_bef_4_ms]) ///
	(bef3: _b[imlc_enacted_dd_bef_3] + _b[imlc_enacted_dd_bef_3_ms]) ///
	(bef2: _b[imlc_enacted_dd_bef_2] + _b[imlc_enacted_dd_bef_2_ms]) ///
	(aft0: _b[imlc_enacted_dd_aft_0] + _b[imlc_enacted_dd_aft_0_ms]) ///
	(aft1: _b[imlc_enacted_dd_aft_1] + _b[imlc_enacted_dd_aft_1_ms]) ///
	(aft2: _b[imlc_enacted_dd_aft_2] + _b[imlc_enacted_dd_aft_2_ms]) ///
	(aft3: _b[imlc_enacted_dd_aft_3] + _b[imlc_enacted_dd_aft_3_ms]) ///
	(aft4: _b[imlc_enacted_dd_aft_4] + _b[imlc_enacted_dd_aft_4_ms]), post

eststo m10_total

*Graph interaction ES
event_plot m10_total, ciplottype(rcap) ///
	graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
		yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ytitle("New patient share: Multistate") ///
		title(`"`titletext'"') ///
		legend(off)) ///
		lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
		lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
	stub_lead(bef#) ///
	stub_lag(aft#) ///
	trimlag(4) trimlead(4) ///
	together plottype(scatter)

graph save "Graph" "${wd}/analysis/figures/event_share_new_int_ltd.gph", replace
graph export "${wd}/analysis/figures/event_share_new_int_ltd.tif", as(tif) replace


**Avg visit time
*Canonical interaction ES
eststo m11: reghdfe avg_visit_time imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*  multistate imlc_enacted_dd_bef_*_ms imlc_enacted_dd_aft_*_ms parity if multistate_timing!=1, absorb(npi year) cluster(npi)

*Total IMLC effect for multistate providers
nlcom ///
	(bef4: _b[imlc_enacted_dd_bef_4] + _b[imlc_enacted_dd_bef_4_ms]) ///
	(bef3: _b[imlc_enacted_dd_bef_3] + _b[imlc_enacted_dd_bef_3_ms]) ///
	(bef2: _b[imlc_enacted_dd_bef_2] + _b[imlc_enacted_dd_bef_2_ms]) ///
	(aft0: _b[imlc_enacted_dd_aft_0] + _b[imlc_enacted_dd_aft_0_ms]) ///
	(aft1: _b[imlc_enacted_dd_aft_1] + _b[imlc_enacted_dd_aft_1_ms]) ///
	(aft2: _b[imlc_enacted_dd_aft_2] + _b[imlc_enacted_dd_aft_2_ms]) ///
	(aft3: _b[imlc_enacted_dd_aft_3] + _b[imlc_enacted_dd_aft_3_ms]) ///
	(aft4: _b[imlc_enacted_dd_aft_4] + _b[imlc_enacted_dd_aft_4_ms]), post

eststo m11_total

*Graph interaction ES
event_plot m11_total, ciplottype(rcap) ///
	graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
		yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ytitle("Average visit length: Multistate") ///
		title(`"`titletext'"') ///
		legend(off)) ///
		lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
		lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
	stub_lead(bef#) ///
	stub_lag(aft#) ///
	trimlag(4) trimlead(4) ///
	together plottype(scatter)

graph save "Graph" "${wd}/analysis/figures/event_avg_visit_time_int_ltd.gph", replace
graph export "${wd}/analysis/figures/event_avg_visit_time_int_ltd.tif", as(tif) replace


**Telehealth share
*Canonical interaction ES
eststo m12: reghdfe telehealth_share imlc_enacted_dd_bef_* imlc_enacted_dd_aft_*  multistate imlc_enacted_dd_bef_*_ms imlc_enacted_dd_aft_*_ms parity if multistate_timing!=1, absorb(npi year) cluster(npi)

*Total IMLC effect for multistate providers
nlcom ///
	(bef4: _b[imlc_enacted_dd_bef_4] + _b[imlc_enacted_dd_bef_4_ms]) ///
	(bef3: _b[imlc_enacted_dd_bef_3] + _b[imlc_enacted_dd_bef_3_ms]) ///
	(bef2: _b[imlc_enacted_dd_bef_2] + _b[imlc_enacted_dd_bef_2_ms]) ///
	(aft0: _b[imlc_enacted_dd_aft_0] + _b[imlc_enacted_dd_aft_0_ms]) ///
	(aft1: _b[imlc_enacted_dd_aft_1] + _b[imlc_enacted_dd_aft_1_ms]) ///
	(aft2: _b[imlc_enacted_dd_aft_2] + _b[imlc_enacted_dd_aft_2_ms]) ///
	(aft3: _b[imlc_enacted_dd_aft_3] + _b[imlc_enacted_dd_aft_3_ms]) ///
	(aft4: _b[imlc_enacted_dd_aft_4] + _b[imlc_enacted_dd_aft_4_ms]), post

eststo m12_total

*Graph interaction ES
event_plot m12_total, ciplottype(rcap) ///
	graph_opt(xtitle("") xline(-1, lcolor(gs8) lpattern(dash)) ///
		yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ytitle("Telehealth share: Multistate") ///
		title(`"`titletext'"') ///
		legend(off)) ///
		lead_opt1(msymbol(D) color(navy)) lag_opt1(msymbol(D) color(navy)) ///
		lag_ci_opt(color(gs5)) lead_ci_opt(color(gs5)) ///
	stub_lead(bef#) ///
	stub_lag(aft#) ///
	trimlag(4) trimlead(4) ///
	together plottype(scatter)

graph save "Graph" "${wd}/analysis/figures/event_tele_share_int_ltd.gph", replace
graph export "${wd}/analysis/figures/event_tele_share_int_ltd.tif", as(tif) replace

