
*Do 100 times:
*		1. Create a dataset with 500 draws of x from Uniform(0,1) distribution.
*		2. Calculate the average of x.
*Then, save the resulting 100 averages to a dataset in the "Temp" folder

*clear STATA space
clear all
*prevent STATA from stopping at large outputs
set more off
*Require exact variable names rather than abbreviations
set varabbrev off

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


scalar p_0 = `3'
global p_0 = p_0
scalar p_1 = `4'
global p_1 = p_1
scalar alpha_2 = `5'
global alpha_2 = alpha_2
scalar mu0_0 = `6'
global mu0_0 = mu0_0
scalar mu0_1 = `7'
global mu0_1 = mu0_1
scalar beta_2 = `8'
global beta_2 = beta_2
scalar mu1_0 = `9'
global mu1_0 = mu1_0
scalar mu1_1 = `10'
global mu1_1 = mu1_1
scalar gamma_2 = real("`11'")
global gamma_2 = gamma_2


*Create a temporary name for the dataset that will collect the 100 averages of x.
tempname results

*Variables in the dataset, and name of the file to save results
postfile `results' True_ATE ATE_ra ATE_ipw ATE_aipw ATE_ipwra ATE_nnmatch ATE_psmatch ///
    using /nas/longleaf/home/xiaoyanj/ondemand/data/sys/myjobs/projects/default/1/Temp/results_${count}.dta, replace

global reps = 100
forvalues rep=1/$reps {

	*clear data. (Don't use "clear all" because this would erase all information.)
	clear

	*generate data with 500 observations
	do /nas/longleaf/home/xiaoyanj/ondemand/data/sys/myjobs/projects/default/1/generate_data.do 500
	
	su ind_te
    scalar true_ate = r(mean)
    
    teffects ra (y x) (d)
    matrix A1 = r(table)
    scalar ate_ra = A1[1,1]
    
    su ipw_te
    scalar ate_ipw = r(mean)

    su aipw_te
    scalar ate_aipw = r(mean)
    
    regress y x [aweight=weights_1] if d==1
    matrix A2 = r(table)
    scalar alpha_hat_1 = A2[2,1]
    scalar beta_hat_1 = A2[1,1]
    regress y x [aweight=weights_0] if d==0
    matrix A3 = r(table)
    scalar alpha_hat_0 = A3[2,1]
    scalar beta_hat_0 = A3[1,1]
    gen ipwra_te = (alpha_hat_1 + beta_hat_1*x) - (alpha_hat_0 + beta_hat_0*x)
    su ipwra_te
    scalar ate_ipwra = r(mean)

    teffects nnmatch (y x) (d)
    matrix A5 = r(table)
    scalar ate_nnmatch = A5[1,1]

    teffects psmatch (y) (d x)
    matrix A6 = r(table)
    scalar ate_psmatch = A6[1,1]	
    
    post `results' (true_ate) (ate_ra) (ate_ipw) (ate_aipw) (ate_ipwra) (ate_nnmatch) (ate_psmatch)

}

postclose `results'

*END

