clear

* create a new file that complies all the results and calculate the biases
tempname results
postfile `results' count bias_RA var_RA bias_IPW var_IPW bias_AIPW var_AIPW bias_IPWRA var_IPWRA bias_NNMATCH var_NNMATCH bias_PSMATCH var_PSMATCH   using Temp/results_compiled.dta, replace

* loop in 1,000 shapes
forvalues count = 1/1000 {
  local post_results
  use Temp/results_`count'.dta, clear
  * loop in 6 estimators and calculate the biases (estimated ATE - true ATE and their variances)
  foreach estimator in ra ipw aipw ipwra nnmatch psmatch {
    capture drop bias
    gen bias = ATE_`estimator'-True_ATE
    su bias
    local bias = r(mean)
    su ATE_`estimator'
    local var = r(sd)^2
    local post_results `post_results' (`bias') (`var')
  }
  post `results' (`count') `post_results'
}
postclose `results'

* merge the results with shape combination csv
import delim shape_comb.csv, clear
gen count=_n
merge 1:1 count using Temp/results_compiled

* calculate the mean squared error for each estimator
foreach estimator in RA IPW AIPW IPWRA NNMATCH PSMATCH {
  gen MSE_`estimator' = bias_`estimator'^2+var_`estimator'
}

* generate the minimum of biases and see which estimator yields the minimum
gen min_absbias = min(abs(bias_RA),abs(bias_IPW),abs(bias_AIPW),abs(bias_IPWRA))
gen minimizing_absbias = 1 if abs(bias_RA)==min_absbias
replace minimizing_absbias = 2 if abs(bias_IPW)==min_absbias
replace minimizing_absbias = 3 if abs(bias_AIPW)==min_absbias
replace minimizing_absbias = 4 if abs(bias_IPWRA)==min_absbias


export delim results.csv, replace

*end
