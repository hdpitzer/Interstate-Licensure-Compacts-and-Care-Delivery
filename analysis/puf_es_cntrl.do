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
merge m:1 state year using "${wd}/data/output/NPPES/state_year_lag", nogen


***************************************************************************

** ITT event studies **

***************************************************************************
** E/M VOLUME
***************************************************************************

* Canonical ES
eststo m1_ctrl: reghdfe ln_em_cnt ///
    imlc_enacted_dd_bef_* ///
    imlc_enacted_dd_aft_* ///
    imlc_enacted_dd_y ///
    parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share, ///
    absorb(npi year) ///
    cluster(npi)


* SA ES
eventstudyinteract ln_em_cnt ///
    imlc_enacted_dd_bef_* ///
    imlc_enacted_dd_aft_*, ///
    absorb(npi year) ///
    cohort(min_imlc_enacted_dd) ///
    covariates( ///
        parity ///
        l_physicians_per_100k ///
        l_ln_em_volume ///
        l_telehealth_share ///
    ) ///
    control_cohort(imlc_enacted_dd_never) ///
    vce(cluster npi)


* Graph
event_plot e(b_iw)#e(V_iw) m1_ctrl, ciplottype(rcap) ///
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
    stub_lead(imlc_enacted_dd_bef_# imlc_enacted_dd_bef_#) ///
    stub_lag(imlc_enacted_dd_aft_# imlc_enacted_dd_aft_#) ///
    trimlag(4) trimlead(4) ///
    together plottype(scatter) perturb(-.2 -.0)

graph save "Graph" ///
    "${wd}/analysis/figures/event_em_cnt_ctrl.gph", replace

graph export ///
    "${wd}/analysis/figures/event_em_cnt_ctrl.tif", ///
    as(tif) replace


***************************************************************************
** NEW PATIENT SHARE
***************************************************************************

* Canonical ES
eststo m2_ctrl: reghdfe share_new ///
    imlc_enacted_dd_bef_* ///
    imlc_enacted_dd_aft_* ///
    imlc_enacted_dd_y ///
    parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share, ///
    absorb(npi year) ///
    cluster(npi)


* SA ES
eventstudyinteract share_new ///
    imlc_enacted_dd_bef_* ///
    imlc_enacted_dd_aft_*, ///
    absorb(npi year) ///
    cohort(min_imlc_enacted_dd) ///
    covariates( ///
        parity ///
        l_physicians_per_100k ///
        l_ln_em_volume ///
        l_telehealth_share ///
    ) ///
    control_cohort(imlc_enacted_dd_never) ///
    vce(cluster npi)


* Graph
event_plot e(b_iw)#e(V_iw) m2_ctrl, ciplottype(rcap) ///
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
    stub_lead(imlc_enacted_dd_bef_# imlc_enacted_dd_bef_#) ///
    stub_lag(imlc_enacted_dd_aft_# imlc_enacted_dd_aft_#) ///
    trimlag(4) trimlead(4) ///
    together plottype(scatter) perturb(-.2 -.0)

graph save "Graph" ///
    "${wd}/analysis/figures/event_share_new_ctrl.gph", replace

graph export ///
    "${wd}/analysis/figures/event_share_new_ctrl.tif", ///
    as(tif) replace


***************************************************************************
** AVERAGE VISIT TIME
***************************************************************************

* Canonical ES
eststo m3_ctrl: reghdfe avg_visit_time ///
    imlc_enacted_dd_bef_* ///
    imlc_enacted_dd_aft_* ///
    imlc_enacted_dd_y ///
    parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share, ///
    absorb(npi year) ///
    cluster(npi)


* SA ES
eventstudyinteract avg_visit_time ///
    imlc_enacted_dd_bef_* ///
    imlc_enacted_dd_aft_*, ///
    absorb(npi year) ///
    cohort(min_imlc_enacted_dd) ///
    covariates( ///
        parity ///
        l_physicians_per_100k ///
        l_ln_em_volume ///
        l_telehealth_share ///
    ) ///
    control_cohort(imlc_enacted_dd_never) ///
    vce(cluster npi)


* Graph
event_plot e(b_iw)#e(V_iw) m3_ctrl, ciplottype(rcap) ///
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
    stub_lead(imlc_enacted_dd_bef_# imlc_enacted_dd_bef_#) ///
    stub_lag(imlc_enacted_dd_aft_# imlc_enacted_dd_aft_#) ///
    trimlag(4) trimlead(4) ///
    together plottype(scatter) perturb(-.2 -.0)

graph save "Graph" ///
    "${wd}/analysis/figures/event_avg_visit_time_ctrl.gph", replace

graph export ///
    "${wd}/analysis/figures/event_avg_visit_time_ctrl.tif", ///
    as(tif) replace


***************************************************************************
** TELEHEALTH SHARE
***************************************************************************

* Canonical ES
eststo m4_ctrl: reghdfe telehealth_share ///
    imlc_enacted_dd_bef_* ///
    imlc_enacted_dd_aft_* ///
    imlc_enacted_dd_y ///
    parity ///
    l_physicians_per_100k ///
    l_ln_em_volume ///
    l_telehealth_share, ///
    absorb(npi year) ///
    cluster(npi)


* SA ES
eventstudyinteract telehealth_share ///
    imlc_enacted_dd_bef_* ///
    imlc_enacted_dd_aft_*, ///
    absorb(npi year) ///
    cohort(min_imlc_enacted_dd) ///
    covariates( ///
        parity ///
        l_physicians_per_100k ///
        l_ln_em_volume ///
        l_telehealth_share ///
    ) ///
    control_cohort(imlc_enacted_dd_never) ///
    vce(cluster npi)


* Graph
event_plot e(b_iw)#e(V_iw) m4_ctrl, ciplottype(rcap) ///
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
    stub_lead(imlc_enacted_dd_bef_# imlc_enacted_dd_bef_#) ///
    stub_lag(imlc_enacted_dd_aft_# imlc_enacted_dd_aft_#) ///
    trimlag(4) trimlead(4) ///
    together plottype(scatter) perturb(-.2 -.0)

graph save "Graph" ///
    "${wd}/analysis/figures/event_tele_share_ctrl.gph", replace

graph export ///
    "${wd}/analysis/figures/event_tele_share_ctrl.tif", ///
    as(tif) replace


