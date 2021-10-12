use "C:\Users\j\Desktop\results.dta", clear

* see the effects of p(x) regardless of mu1 and mu0
ta minimizing_absbias

* p0=p1=0.5, most convex/concave
keep if p_0 == 0.5 & p_1 == 0.5
ta minimizing_absbias

* alpha2=+-0.5, p(x) monotonic
use "C:\Users\j\Desktop\results.dta", clear
keep if alpha_2 == 0.5 | alpha_2 == -0.5
ta minimizing_absbias

* alpha2=+-1.42, p(x) monotonic
use "C:\Users\j\Desktop\results.dta", clear
keep if alpha_2 == -1.42 | alpha_2 == 1.42
ta minimizing_absbias

* full matrix is the total number of observations collasped by parameters of mu1 and mu0, used to calculate the proportion of cases where RA is the best estimator
use "C:\Users\j\Desktop\results.dta", clear
collapse (count) minimizing_absbias, by (beta_2 gamma_2)
mkmat minimizing_absbias
mkmat minimizing_absbias, matrix(full)
matrix list full

* collapse if RA is the best one, calculate the proportion
use "C:\Users\j\Desktop\results.dta", clear
gen ra_count = 0
replace ra_count = 1 if minimizing_absbias == 1
collapse (sum) ra_count, by (beta_2 gamma_2)
gen ra_prop = 0
forvalues i=1/`=_N' {
	replace ra_prop = ra_count[`i']/(full[`i', 1]) in `i'
}
sort ra_prop
list

* doubly robust estimators, when perform better, collapse by the the parameter of p(x) and the parameters of mu1 and mu0
* collaspe by alpha_2
use "C:\Users\j\Desktop\results.dta", clear
collapse (count) minimizing_absbias, by (alpha_2)
mkmat minimizing_absbias
mkmat minimizing_absbias, matrix(full)
matrix list full

use "C:\Users\j\Desktop\results.dta", clear
gen dr_count = 0
replace dr_count = 1 if minimizing_absbias == 3 | minimizing_absbias ==4
collapse (sum) dr_count, by (alpha_2)
gen dr_prop = 0
forvalues i=1/`=_N' {
	replace dr_prop = dr_count[`i']/(full[`i', 1]) in `i'
}
sort dr_prop
list

* collapse by beta_2 and gamma_2
use "C:\Users\j\Desktop\results.dta", clear
collapse (count) minimizing_absbias, by (beta_2 gamma_2)
mkmat minimizing_absbias
mkmat minimizing_absbias, matrix(full)
matrix list full

use "C:\Users\j\Desktop\results.dta", clear
gen dr_count = 0
replace dr_count = 1 if minimizing_absbias == 3 | minimizing_absbias ==4
collapse (sum) dr_count, by (beta_2 gamma_2)
gen dr_prop = 0
forvalues i=1/`=_N' {
	replace dr_prop = dr_count[`i']/(full[`i', 1]) in `i'
}
sort dr_prop
list

* collapse by alpha_2, beta_2 and gamma_2
use "C:\Users\j\Desktop\results.dta", clear
collapse (count) minimizing_absbias, by (alpha_2 beta_2 gamma_2)
mkmat minimizing_absbias
mkmat minimizing_absbias, matrix(full)
matrix list full

use "C:\Users\j\Desktop\results.dta", clear
use "C:\Users\j\Desktop\results.dta", clear
gen dr_count = 0
replace dr_count = 1 if minimizing_absbias == 3 | minimizing_absbias ==4
collapse (sum) dr_count, by (alpha_2 beta_2 gamma_2)
gen dr_prop = 0
forvalues i=1/`=_N' {
	replace dr_prop = dr_count[`i']/(full[`i', 1]) in `i'
}
sort dr_prop
list

