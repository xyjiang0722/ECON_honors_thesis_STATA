cd /nas/longleaf/home/xiaoyanj/Nov14
use cps3re74.dta, clear


*************************** Copy and Paste ***************************
set seed 12345

gen one = 1

*normalize covariates by sample s.d. --- and demean. Intuitively I think of this as putting all covariates "in the same units". There may be other ways to do this...
foreach var in age ed black hisp married nodeg re75 re74 {
  su `var'
  replace `var' = (`var'-r(mean))/r(sd)
}

*make the outcome and treatment status same variance
su treat
scalar sd_treat = r(sd)
su re78
scalar sd_y = r(sd)
replace re78 = re78/sd_y*sd_treat
su re78

drop age2
gen age2 = age^2

reg re78 one age age2 ed black hisp married nodeg re75 re74 if treat==1, nocons
matrix beta1_star = e(b)

reg re78 one age age2 ed black hisp married nodeg re75 re74 if treat==0, nocons
matrix beta0_star = e(b)

logit treat one age age2 ed black hisp married nodeg re75 re74, nocons
matrix betap_star = e(b)

*add cubic of age
gen age3 = age^3
local q_list age3
*add quadratic of all other continuous variables
foreach var1 in ed re75 re74 {
  gen `var1'2 = `var1'^2
  local q_list `q_list' `var1'2
}
*add interactions of all original variables
local count1 = 1

foreach var1 in age age2 ed black hisp married nodeg re75 re74 {
  local count2 = 1
  foreach var2 in age age2 ed black hisp married nodeg re75 re74 {
      if `count1'<`count2' & ("`var1'"!="age"|"`var2'"!="age2") & ("`var1'"!="black"|"`var2'"!="hisp") {
        gen `var1'_`var2' = `var1'*`var2'
        local q_list `q_list' `var1'_`var2'
      }
      local count2 = `count2'+1
  }
  local count1 = `count1'+1
}

*Get epsilon from magnitude of the corresponding coefficients in OLS regression/Logit regression.
reg re78 one age age2 ed black hisp married nodeg re75 re74 `q_list' if treat==1, nocons
matrix temp = e(b)
* matrix temp = temp[1,12..49]    // Original code
/* Question : when I ran the do file, it showed "conformability error". 
I checked the temp matrix here, it was 1*48. So I used temp[1,11..48].
I guess we should get the sum of squares of the coefficients of q_list.
*/
matrix temp = temp[1,11..48]
matrix temp = temp*temp'
scalar epsilon_star_1 = sqrt(temp[1,1])
di epsilon_star_1
reg re78 one age age2 ed black hisp married nodeg re75 re74 `q_list' if treat==0, nocons
matrix temp = e(b)
matrix temp = temp[1,11..48]
matrix temp = temp*temp'
scalar epsilon_star_2 = sqrt(temp[1,1])
di epsilon_star_2
logit treat one age age2 ed black hisp married nodeg re75 re74 `q_list' , nocons
matrix temp = e(b)
matrix temp = temp[1,11..48]
matrix temp = temp*temp'
scalar epsilon_star_3 = sqrt(temp[1,1])
di epsilon_star_3
scalar epsilon_star = (epsilon_star_1 + epsilon_star_2 + epsilon_star_3)/3
****************************** End ****************************************


global q_list `q_list'

tempname results
postfile `results' Eplison True_ATE MSE_ra MSE_ipw MSE_aipw MSE_ipwra MSE_nnmatch MSE_psmatch using results.dta, replace
	
foreach ep_star in epsilon_star/3 epsilon_star/2 epsilon_star 2*epsilon_star 3*epsilon_star 5*epsilon_star 10*epsilon_star {
    global ep_star = `ep_star'
	do generate.do
	su ind_te 
	scalar true_ate = r(mean)
	
	* estimate by wrong models -> mse of estimators of ATE
	teffects ra (re78 age age2 ed black hisp married nodeg re75 re74) (treat)
	matrix A1 = r(table)
	scalar ate_ra = A1[1,1]
	scalar ate_ra_var = A1[2,1]
	scalar mse_ra = (ate_ra - true_ate)^2 + ate_ra_var
	
	teffects ipw (re78) (treat age age2 ed black hisp married nodeg re75 re74)
	matrix A2 = r(table)
	scalar ate_ipw = A2[1,1]
	scalar ate_ipw_var = A2[2,1]
	scalar mse_ipw = (ate_ipw - true_ate)^2 + ate_ipw_var
	
	teffects aipw (re78 age age2 ed black hisp married nodeg re75 re74) (treat age age2 ed black hisp married nodeg re75 re74)
	matrix A3 = r(table)
	scalar ate_aipw = A3[1,1]
	scalar ate_aipw_var = A3[2,1]
	scalar mse_aipw = (ate_aipw - true_ate)^2 + ate_aipw_var

	teffects ipwra (re78 age age2 ed black hisp married nodeg re75 re74) (treat age age2 ed black hisp married nodeg re75 re74)
	matrix A4 = r(table)
	scalar ate_ipwra = A4[1,1]
	scalar ate_ipwra_var = A4[2,1]
	scalar mse_ipwra = (ate_ipwra - true_ate)^2 + ate_ipwra_var

	teffects psmatch (re78) (treat age age2 ed black hisp married nodeg re75 re74)
	matrix A5 = r(table)
	scalar ate_psm = A5[1,1]
	scalar ate_psm_var = A5[2,1]
	scalar mse_psm = (ate_psm - true_ate)^2 + ate_psm_var

	teffects nnmatch (re78 age age2 ed black hisp married nodeg re75 re74) (treat)
	matrix A6 = r(table)
	scalar ate_nnm = A6[1,1]
	scalar ate_nnm_var = A6[2,1]
	scalar mse_nnm = (ate_nnm - true_ate)^2 + ate_nnm_var
	
	post `results' ($ep_star) (true_ate) (mse_ra) (mse_ipw) (mse_aipw) (mse_ipwra) (mse_nnm) (mse_psm)
	
	drop mu_1 mu_0 y_1 y_0 p_score D ind_te
}

postclose `results'




