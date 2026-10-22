clear all 

global wd "/Volumes/Untitled/Interstate Licensure"



********* 2017 **************
import delimited "${wd}/data/input/NPPES/npi2017raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")

		
** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
frame create stlookup
frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2017clean.dta", replace


clear
********* 2018 **************
import delimited "${wd}/data/input/NPPES/npi2018raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")
		

** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
// frame create stlookup
// frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2018clean.dta", replace


clear
********* 2019 **************
import delimited "${wd}/data/input/NPPES/npi2019raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")
		

** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
// frame create stlookup
// frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2019clean.dta", replace


clear
********* 2020 **************
import delimited "${wd}/data/input/NPPES/npi2020raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")
		

** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
// frame create stlookup
// frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2020clean.dta", replace


clear
********* 2021 **************
import delimited "${wd}/data/input/NPPES/npi2021raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")
		

** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
// frame create stlookup
// frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2021clean.dta", replace


clear
********* 2022 **************
import delimited "${wd}/data/input/NPPES/npi2022raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")
		

** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
// frame create stlookup
// frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2022clean.dta", replace


clear
********* 2023 **************
import delimited "${wd}/data/input/NPPES/npi2023raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")
		

** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
// frame create stlookup
// frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2023clean.dta", replace


clear
********* 2024 **************
import delimited "${wd}/data/input/NPPES/npi2024raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")
		

** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
// frame create stlookup
// frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2024clean.dta", replace


clear
********* 2025 **************
import delimited "${wd}/data/input/NPPES/npi2025raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providergendercode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")
		

** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
// frame create stlookup
// frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2025clean.dta", replace


clear
********* 2026 **************
import delimited "${wd}/data/input/NPPES/npi2026raw.csv"



keep npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providersexcode healthcareprovidertaxonomycode_1 providerlicensenumberstatecode_1 healthcareproviderprimarytaxonom healthcareprovidertaxonomycode_2 providerlicensenumberstatecode_2 v56 healthcareprovidertaxonomycode_3 providerlicensenumberstatecode_3 v60 healthcareprovidertaxonomycode_4 providerlicensenumberstatecode_4 v64 healthcareprovidertaxonomycode_5 providerlicensenumberstatecode_5 v68 healthcareprovidertaxonomycode_6 providerlicensenumberstatecode_6 v72 healthcareprovidertaxonomycode_7 providerlicensenumberstatecode_7 v76 healthcareprovidertaxonomycode_8 providerlicensenumberstatecode_8 v80 healthcareprovidertaxonomycode_9 providerlicensenumberstatecode_9 v84 v85 v87 v88 v89 v91 v92 v93 v95 v96 v97 v99 v100 v101 v103 v104 v105 v107 v108 issoleproprietor

order npi providercredentialtext providerenumerationdate lastupdatedate npideactivationdate npireactivationdate providersexcode issoleproprietor providerlicensenumberstatecode_1 providerlicensenumberstatecode_2 providerlicensenumberstatecode_3 providerlicensenumberstatecode_4 providerlicensenumberstatecode_5 providerlicensenumberstatecode_6 providerlicensenumberstatecode_7 providerlicensenumberstatecode_8 providerlicensenumberstatecode_9 v87 v91 v95 v99 v103 v107 healthcareprovidertaxonomycode_1 healthcareprovidertaxonomycode_2 healthcareprovidertaxonomycode_3 healthcareprovidertaxonomycode_4 healthcareprovidertaxonomycode_5 healthcareprovidertaxonomycode_6 healthcareprovidertaxonomycode_7 healthcareprovidertaxonomycode_8 healthcareprovidertaxonomycode_9 v85 v89 v93 v97 v101 v105 healthcareproviderprimarytaxonom v56 v60 v64 v68 v72 v76 v80 v84 v88 v92 v96 v100 v104 v108


** drop unnecessary taxonomies (first pass)
forvalues i = 1/9 {
    rename healthcareprovidertaxonomycode_`i' taxcode_`i'
}

rename v85 taxcode_10
rename v89 taxcode_11
rename v93 taxcode_12
rename v97 taxcode_13
rename v101 taxcode_14
rename v105 taxcode_15

* dentists
drop if inlist(substr(taxcode_1,1,4), ///
		"1223", "1224", "124Q", "125J", "125Q", "1269", "1268", "125K")

* chiropractors 
drop if inlist(substr(taxcode_1,1,4), ///
		"111N")
		
* optometrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"152W", "156F")
		
* podiatrists 
drop if inlist(substr(taxcode_1,1,4), ///
		"211D", "213E")
		

** Rename license states
forvalues i = 1/9 {
    rename providerlicensenumberstatecode_`i' plstate_`i'
}

rename v87 plstate_10
rename v91 plstate_11
rename v95 plstate_12
rename v99 plstate_13
rename v103 plstate_14
rename v107 plstate_15

forvalues i = 1/15 {
    replace plstate_`i' = upper(trim(plstate_`i'))
}

** merge fips
// frame create stlookup
// frame stlookup: use "/Volumes/Untitled/Interstate Licensure/data/input/stlookup.dta", clear


forvalues i = 1/15 {

    frlink m:1 plstate_`i', frame(stlookup postal)
    frget plfips_`i' = stfips, from(stlookup)

    drop stlookup
}

foreach v of varlist plfips_1-plfips_15 {
    replace `v' = . if `v' == 72
}


** Create unique state count var
egen n_unique_states = rownvals(plfips_1-plfips_15)

** save
save "${wd}/data/output/NPPES/npi2026clean.dta", replace
