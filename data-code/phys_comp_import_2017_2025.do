clear all 

global wd "/Volumes/Untitled/Interstate Licensure"

*********************************************************************
*Append and reshpape each year
*-----------------------------------------
* 2017
*-----------------------------------------

use "${wd}/data/input/physician-compare/doctors_and_clinicians_2017/apr_2017", clear
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2017/jul_2017", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2017/dec_2017", force 
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2017/oct_2017", force
save "${wd}/data/input/physician-compare/doctors_and_clinicians_2017", replace

drop allsecondaryspecialties organizationlegalname grouppracticepacid numberofgrouppracticemembers phonenumber hospitalaffiliationccn* hospitalaffiliationlbn* professionalacceptsmedicareassig reportedqualitymeasure usedelectronichealthrecords committedtohearthealththroughthe v42

drop line1streetaddress line2streetaddress markerofaddressline2suppression city state zipcode

drop professionalenrollmentid pacid firstname lastname middlename suffix credential 


foreach var of varlist gender medicalschoolname graduationyear primaryspecialty secondaryspecialty1 secondaryspecialty2 secondaryspecialty3 secondaryspecialty4 {
	bysort npi: egen n_`var' = nvals(`var')
	}
	
drop if n_gender >1
drop if n_medicalschoolname >1
drop if n_graduationyear >1

rename primaryspecialty specialty1
rename secondaryspecialty1 specialty2
rename secondaryspecialty2 specialty3
rename secondaryspecialty3 specialty4
rename secondaryspecialty4 specialty5

duplicates drop

gen rowid = _n
reshape long specialty, i(rowid) j(specialty_num)

drop if specialty == ""
drop specialty_num rowid
duplicates drop

bysort npi: gen specialty_num = _n
reshape wide specialty, i(npi) j(specialty_num)

save "${wd}/data/output/physician-compare/doctors_and_clinicians_2017", replace

*-----------------------------------------
* 2018
*-----------------------------------------

use "${wd}/data/input/physician-compare/doctors_and_clinicians_2018/apr_2018", clear
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2018/jul_2018", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2018/dec_2018", force 
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2018/oct_2018", force
save "${wd}/data/input/physician-compare/doctors_and_clinicians_2018", replace

drop sec_spec_all org_nm org_pac_id num_org_mem phn_numbr hosp_afl_* hosp_afl_lbn_* assgn pqrs ehr mhi 

drop adr_ln_1 adr_ln_2 ln_2_sprs cty st zip

drop ind_pac_id ind_enrl_id frst_nm lst_nm mid_nm suff cred 

duplicates drop 

foreach var of varlist gndr med_sch grd_yr pri_spec sec_spec_1 sec_spec_2 sec_spec_3 sec_spec_4 {
	bysort npi: egen n_`var' = nvals(`var')
	}
	
drop if n_gndr >1
drop if n_med_sch >1
drop if n_grd_yr >1

rename pri_spec specialty1
rename sec_spec_1 specialty2
rename sec_spec_2 specialty3
rename sec_spec_3 specialty4
rename sec_spec_4 specialty5

duplicates drop

rename gndr gender 
rename med_sch medicalschoolname
rename grd_yr graduationyear

drop n_*

gen rowid = _n
reshape long specialty, i(rowid) j(specialty_num)

drop if specialty == ""
drop specialty_num rowid
duplicates drop

bysort npi: gen specialty_num = _n
reshape wide specialty, i(npi) j(specialty_num)

save "${wd}/data/output/physician-compare/doctors_and_clinicians_2018", replace

*-----------------------------------------
* 2019
*-----------------------------------------

use "${wd}/data/input/physician-compare/doctors_and_clinicians_2019/apr_2019", clear
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2019/jul_2019", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2019/dec_2019", force 
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2019/oct_2019", force
save "${wd}/data/input/physician-compare/doctors_and_clinicians_2019", replace

drop sec_spec_all org_nm org_pac_id num_org_mem phn_numbr hosp_afl_* hosp_afl_lbn_* assgn pqrs ehr mhi 

drop adr_ln_1 adr_ln_2 ln_2_sprs cty st zip

drop ind_pac_id ind_enrl_id frst_nm lst_nm mid_nm suff cred 

duplicates drop 

foreach var of varlist gndr med_sch grd_yr pri_spec sec_spec_1 sec_spec_2 sec_spec_3 sec_spec_4 {
	bysort npi: egen n_`var' = nvals(`var')
	}
	
drop if n_gndr >1
drop if n_med_sch >1
drop if n_grd_yr >1

rename pri_spec specialty1
rename sec_spec_1 specialty2
rename sec_spec_2 specialty3
rename sec_spec_3 specialty4
rename sec_spec_4 specialty5

rename gndr gender 
rename med_sch medicalschoolname
rename grd_yr graduationyear

drop n_*

gen rowid = _n
reshape long specialty, i(rowid) j(specialty_num)

drop if specialty == ""
drop specialty_num rowid
duplicates drop

bysort npi: gen specialty_num = _n
reshape wide specialty, i(npi) j(specialty_num)

save "${wd}/data/output/physician-compare/doctors_and_clinicians_2019", replace

*-----------------------------------------
* 2020
*-----------------------------------------

use "${wd}/data/input/physician-compare/doctors_and_clinicians_2020/aug_2020", clear
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2020/nov_2020", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2020/dec_2020", force 
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2020/oct_2020", force
save "${wd}/data/input/physician-compare/doctors_and_clinicians_2020", replace

drop sec_spec_all org_nm org_pac_id num_org_mem phn_numbr hosp_afl_* hosp_afl_lbn_* ind_assgn grp_assgn adrs_id

drop adr_ln_1 adr_ln_2 ln_2_sprs cty st zip 

drop ind_pac_id ind_enrl_id frst_nm lst_nm mid_nm suff cred 

duplicates drop 

foreach var of varlist gndr med_sch grd_yr pri_spec sec_spec_1 sec_spec_2 sec_spec_3 sec_spec_4 {
	bysort npi: egen n_`var' = nvals(`var')
	}
	
drop if n_gndr >1
drop if n_med_sch >1
drop if n_grd_yr >1

rename pri_spec specialty1
rename sec_spec_1 specialty2
rename sec_spec_2 specialty3
rename sec_spec_3 specialty4
rename sec_spec_4 specialty5

rename gndr gender 
rename med_sch medicalschoolname
rename grd_yr graduationyear

drop n_*

gen rowid = _n
reshape long specialty, i(rowid) j(specialty_num)

drop if specialty == ""
drop specialty_num rowid
duplicates drop

bysort npi: gen specialty_num = _n
reshape wide specialty, i(npi) j(specialty_num)

save "${wd}/data/output/physician-compare/doctors_and_clinicians_2020", replace

*-----------------------------------------
* 2021
*-----------------------------------------

use "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/jan_2021", clear
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/feb_2021", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/mar_2021", force 
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/apr_2021", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/may_2021", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/jun_2021", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/jul_2021", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/aug_2021", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/sep_2021", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/oct_2021", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/nov_2021", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2021/dec_2021", force
save "${wd}/data/input/physician-compare/doctors_and_clinicians_2021", replace

drop sec_spec_all org_nm org_pac_id num_org_mem phn_numbr hosp_afl_* hosp_afl_lbn_* ind_assgn grp_assgn adrs_id

drop adr_ln_1 adr_ln_2 ln_2_sprs cty st zip 

drop ind_pac_id ind_enrl_id frst_nm lst_nm mid_nm suff cred 

duplicates drop 

foreach var of varlist gndr med_sch grd_yr pri_spec sec_spec_1 sec_spec_2 sec_spec_3 sec_spec_4 {
	bysort npi: egen n_`var' = nvals(`var')
	}
	
drop if n_gndr >1
drop if n_med_sch >1
drop if n_grd_yr >1

rename pri_spec specialty1
rename sec_spec_1 specialty2
rename sec_spec_2 specialty3
rename sec_spec_3 specialty4
rename sec_spec_4 specialty5

rename gndr gender 
rename med_sch medicalschoolname
rename grd_yr graduationyear

drop n_*

gen rowid = _n
reshape long specialty, i(rowid) j(specialty_num)

drop if specialty == ""
drop specialty_num rowid
duplicates drop

bysort npi: gen specialty_num = _n
reshape wide specialty, i(npi) j(specialty_num)

save "${wd}/data/output/physician-compare/doctors_and_clinicians_2021", replace

*-----------------------------------------
* 2022
*-----------------------------------------

use "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/jan_2022", clear
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/feb_2022", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/mar_2022", force 
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/apr_2022", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/may_2022", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/jun_2022", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/jul_2022", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/aug_2022", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/sep_2022", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/oct_2022", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/nov_2022", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2022/dec_2022", force
save "${wd}/data/input/physician-compare/doctors_and_clinicians_2022", replace

drop sec_spec_all org_nm org_pac_id num_org_mem phn_numbr hosp_afl_* hosp_afl_lbn_* ind_assgn grp_assgn adrs_id

drop adr_ln_1 adr_ln_2 ln_2_sprs cty st zip 

drop ind_pac_id ind_enrl_id frst_nm lst_nm mid_nm suff cred 

duplicates drop 

foreach var of varlist gndr med_sch grd_yr pri_spec sec_spec_1 sec_spec_2 sec_spec_3 sec_spec_4 {
	bysort npi: egen n_`var' = nvals(`var')
	}
	
drop if n_gndr >1
drop if n_med_sch >1
drop if n_grd_yr >1

rename pri_spec specialty1
rename sec_spec_1 specialty2
rename sec_spec_2 specialty3
rename sec_spec_3 specialty4
rename sec_spec_4 specialty5

rename gndr gender 
rename med_sch medicalschoolname
rename grd_yr graduationyear

drop n_*

gen rowid = _n
reshape long specialty, i(rowid) j(specialty_num)

drop if specialty == ""
drop specialty_num rowid
duplicates drop

bysort npi: gen specialty_num = _n
reshape wide specialty, i(npi) j(specialty_num)

save "${wd}/data/output/physician-compare/doctors_and_clinicians_2022", replace

*-----------------------------------------
* 2023
*-----------------------------------------

use "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/jan_2023", clear
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/feb_2023", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/mar_2023", force 
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/apr_2023", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/may_2023", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/jun_2023", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/jul_2023", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/aug_2023", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/sep_2023", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/oct_2023", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/nov_2023", force
	append using "${wd}/data/input/physician-compare/doctors_and_clinicians_2023/dec_2023", force
save "${wd}/data/input/physician-compare/doctors_and_clinicians_2023", replace

drop sec_spec_all org_nm org_pac_id num_org_mem phn_numbr ind_assgn grp_assgn adrs_id facilityname citytown state zipcode telephonenumber telehlth

drop adr_ln_1 adr_ln_2 ln_2_sprs cty st zip 

drop ind_pac_id ind_enrl_id frst_nm lst_nm mid_nm suff cred providerfirstname providerlastname providermiddlename

duplicates drop 

foreach var of varlist gndr med_sch grd_yr pri_spec sec_spec_1 sec_spec_2 sec_spec_3 sec_spec_4 {
	bysort npi: egen n_`var' = nvals(`var')
	}
	
drop if n_gndr >1
drop if n_med_sch >1
drop if n_grd_yr >1

rename pri_spec specialty1
rename sec_spec_1 specialty2
rename sec_spec_2 specialty3
rename sec_spec_3 specialty4
rename sec_spec_4 specialty5

rename gndr gender 
rename med_sch medicalschoolname
rename grd_yr graduationyear

drop n_*

gen rowid = _n
reshape long specialty, i(rowid) j(specialty_num)

drop if specialty == ""
drop specialty_num rowid
duplicates drop

bysort npi: gen specialty_num = _n
reshape wide specialty, i(npi) j(specialty_num)

save "${wd}/data/output/physician-compare/doctors_and_clinicians_2023", replace


*********************************************************************

forvalues year=2017/2023 {
     use "${wd}/data/output/physician-compare/doctors_and_clinicians_`year'", clear
	 
	 gen year = `year'
	 
	 save "${wd}/data/output/physician-compare/doctors_and_clinicians_`year'", replace
}




use "${wd}/data/output/physician-compare/doctors_and_clinicians_2017", clear

forvalues year=2018/2023 {
    append using "${wd}/data/output/physician-compare/doctors_and_clinicians_`year'", force
}


save "${wd}/data/output/physician-compare/doctors_and_clinicians_2017_2023", replace
