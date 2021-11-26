*Do 1000 times:
*		1. Create a dataset with 500 draws of x from Uniform(0,1) distribution.
*		2. Calculate the ATE estimators.
*Then, save the resulting 1000 ATE estimators to a dataset in the "Temp" folder

*clear STATA space
clear all
*prevent STATA from stopping at large outputs
set more off
*Require exact variable names rather than abbreviations
set varabbrev off

cd /nas/longleaf/home/xiaoyanj/ondemand/data/sys/myjobs/projects/default/1/

*Passing inputs

*Job ID
scalar count=`1'
global count=count

*Seed
scalar seed=`2'
global seed=seed

capture log close
log using Logs/log_${count}.log, replace

*set seed for random number generator
set seed ${seed}

*read parameters from the csv file
global row=$count
import delim shape_comb.csv, clear
foreach var in p_0 p_1 alpha_2 mu0_0 mu0_1 beta_2 mu1_0 mu1_1 gamma_2 {
    scalar `var' = `var'[$row]
    global `var' = `var'
}


*Create a temporary name for the dataset that will collect the 1000 ATE estimators of x.
tempname results

*Variables in the dataset, and name of the file to save results
postfile `results' True_ATE ATE_ra ATE_ipw ATE_aipw ATE_ipwra ATE_nnmatch ATE_psmatch ///
    using Temp/results_${count}.dta, replace

global reps = 1000
forvalues rep=1/$reps {

	*clear data. (Don't use "clear all" because this would erase all information.)
	clear

	*generate data with 500 observations
	do generate_data.do 500
	
	* true treatment effect for each individual and take the average
	su ind_te
    scalar true_ate = r(mean)
    
    * regression adjustment
    teffects ra (y x) (d)
    matrix A1 = r(table)
    scalar ate_ra = A1[1,1]
    
    * ATE estimated by inverse probability weighting
    su ipw_te
    scalar ate_ipw = r(mean)
    
    * ATE estimated by augmented inverse probability weighting
    su aipw_te
    scalar ate_aipw = r(mean)
    
    * ATE estimated by inverse probability weighting with regression adjustment (linear probability option not available in STATA)
    * run weighted regression in treated and untreated groups respectively and obtain the coefficients
    regress y x [pweight=weights_1] if d==1
    matrix A2 = r(table)
    scalar alpha_hat_1 = A2[2,1]
    scalar beta_hat_1 = A2[1,1]
    regress y x [pweight=weights_0] if d==0
    matrix A3 = r(table)
    scalar alpha_hat_0 = A3[2,1]
    scalar beta_hat_0 = A3[1,1]
    gen ipwra_te = (alpha_hat_1 + beta_hat_1*x) - (alpha_hat_0 + beta_hat_0*x)
    su ipwra_te
    scalar ate_ipwra = r(mean)
    
    * Nearest-neighbor matching 
    teffects nnmatch (y x) (d)
    matrix A5 = r(table)
    scalar ate_nnmatch = A5[1,1]
    
    * Propensity score matching
    teffects psmatch (y) (d x)
    matrix A6 = r(table)
    scalar ate_psmatch = A6[1,1]	
    
    post `results' (true_ate) (ate_ra) (ate_ipw) (ate_aipw) (ate_ipwra) (ate_nnmatch) (ate_psmatch)

}

postclose `results'

*END
