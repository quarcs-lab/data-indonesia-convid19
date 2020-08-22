* explore GDP data
use GDP
describe


* Import and translate to stata shapa file
clear
spshape2dta covid

* NOTE:  Two stata files will be created
* covid_monthly_shp.dta
* covid_monthly.dta

* explore my spatial data: covid_monthly
use covid

* describe and summarize covid.dta
describe
summarize

* change the spatial-unit id from _ID to fips
spset _ID, modify replace

* modify the coordinate system from planar to latlong
spset, modify coordsys(latlong, miles)


* Check spatial ID and coordinate system
spset

* merge with myDATA
merge 1:1 _ID using GDP
keep if _merge==3
drop _merge

* save new extended MAP data
save mymap_and_data , replace

use mymap_and_data
describe

* label the variables
label variable _ID "Province code"
label variable Prov_x "Province Name"
label variable q1_19 "GDP quarter 1 of 2019"
label variable q2_19 "GDP quarter 2 of 2019"
label variable q3_19 "GDP quarter 3 of 2019"
label variable q4_19 "GDP quarter 4 of 2019"
label variable q1_20 "GDP quarter 1 of 2019"

foreach var of varlist q1_15-q2_20 {
   generate ln_`var' = log(`var')
 }

** Before Covid Model

***Option I : Time period ( Quarter I 2015 - Quarter IV 2019)
* Calculate growth rate 2015q1-2019q4
gen g_gdp1 = log(q4_19/q1_15)

* Plot beta convergence
twoway (scatter g_gdp1 ln_q1_15) (lfit g_gdp1 ln_q1_15), legend(off) name(beta_gdp1, replace)
graph save   "beta-gdp1.gph", replace
graph export "beta-gdp1.pdf", replace


* Non-spatial Beta regression (OLS)
reg g_gdp1 ln_q1_15, robust
estat ic
gen speed_gdp1 = - (log(1+_b[ln_q1_15])/16)
gen halfLife_gdp1 = log(2)/speed_gdp1

sum speed_gdp1 halfLife_gdp1

* create the spatial weights matrix
spmatrix create idistance W 

* Moran's I Residual
estat moran, errorlag(W)

* spatial Lag Model, MLE
spregress g_gdp1 ln_q1_15, ml dvarlag (W)
gen speed_gdp2 = - (log(1+_b[ln_q1_15])/16)
gen halfLife_gdp2 = log(2)/speed_gdp2
estat impact
estat ic

* spatial Error Model, MLE
spregress g_gdp1 ln_q1_15, ml errorlag (W)
gen speed_gdp3 = - (log(1+_b[ln_q1_15])/16)
gen halfLife_gdp3 = log(2)/speed_gdp3
estat impact
estat ic

***Option II : Time period ( Quarter I 2019 - Quarter IV 2019)
* Calculate growth rate 2019q1-2019q4
gen g_gdp2 = log(q4_19/q1_19)

* Plot beta convergence
twoway (scatter g_gdp2 ln_q1_19) (lfit g_gdp2 ln_q1_19), legend(off) name(beta_gdp2, replace)
graph save   "beta-gdp2.gph", replace
graph export "beta-gdp2.pdf", replace


* Beta regression
reg g_gdp2 ln_q1_19, robust
gen speed_gdp4 = - (log(1+_b[ln_q1_19])/4)
gen halfLife_gdp4 = log(2)/speed_gdp4

sum speed_gdp4 halfLife_gdp4

* Moran's I Residual
estat moran, errorlag(W)

* spatial Lag Model, MLE
spregress g_gdp2 ln_q1_19, ml dvarlag (W)
gen speed_gdp5 = - (log(1+_b[ln_q1_19])/4)
gen halfLife_gdp5 = log(2)/speed_gdp5
estat impact
estat ic

* spatial Error Model, MLE
spregress g_gdp2 ln_q1_19, ml errorlag (W)
gen speed_gdp6 = - (log(1+_b[ln_q1_19])/4)
gen halfLife_gdp6 = log(2)/speed_gdp6
estat impact
estat ic



** After Covid Model
*** Option I : Time period (Quarter I 2020 - Quarter 2 2020)
* Calculate growth rate 2020q1-2020q2
gen g_gdp3 = log(q2_20/q1_20)

* Plot beta convergence
twoway (scatter g_gdp3 ln_q1_20) (lfit g_gdp3 ln_q1_20), legend(off) name(beta_gdp3, replace)
graph save   "beta-gdp3.gph", replace
graph export "beta-gdp3.pdf", replace

* Beta regression
reg g_gdp3 ln_q1_20 rate_chg, robust
gen speed_gdp7 = - (log(1+_b[ln_q1_20])/2)
gen halfLife_gdp7 = log(2)/speed_gdp7

sum speed_gdp7 halfLife_gdp7

* Moran's I Residual
estat moran, errorlag(W)

* spatial Lag Model, MLE
spregress g_gdp3 ln_q1_20 rate_chg, ml dvarlag (W)
gen speed_gdp8 = - (log(1+_b[ln_q1_20])/2)
gen halfLife_gdp8 = log(2)/speed_gdp8
estat impact
estat ic

* spatial Error Model, MLE
spregress g_gdp3 ln_q1_20 rate_chg, ml errorlag (W)
gen speed_gdp9 = - (log(1+_b[ln_q1_20])/2)
gen halfLife_gdp9 = log(2)/speed_gdp9
estat impact
estat ic

** After Covid Model 
*** Option II : Time period ( Quarter I 2019 - Quarter 2 2020)
* Calculate growth rate 2019q1-2020q2
gen g_gdp4 = log(q2_20/q1_19)

* Plot beta convergence
twoway (scatter g_gdp4 ln_q1_19) (lfit g_gdp4 ln_q1_19), legend(off) name(beta_gdp4, replace)
graph save   "beta-gdp4.gph", replace
graph export "beta-gdp4.pdf", replace


* Beta regression
reg g_gdp4 ln_q1_19 rate_chg, robust
gen speed_gdp10 = - (log(1+_b[ln_q1_19])/6)
gen halfLife_gdp10 = log(2)/speed_gdp10

* Moran's I Residual
estat moran, errorlag(W)

* spatial Lag Model, MLE
spregress g_gdp4 ln_q1_19 rate_chg, ml dvarlag (W)
gen speed_gdp11 = - (log(1+_b[ln_q1_19])/6)
gen halfLife_gdp11 = log(2)/speed_gdp11
estat impact
estat ic

* spatial Error Model, MLE
spregress g_gdp4 ln_q1_19 rate_chg, ml errorlag (W)
gen speed_gdp12 = - (log(1+_b[ln_q1_19])/6)
gen halfLife_gdp12 = log(2)/speed_gdp12
estat impact
estat ic


*** Erase "unnecesary" files
*They are erased because they can be re-generated when the entire do file is run.
* Also because it is not possible to upload a file that is >100MB to github
erase myMAP_shp.dta
