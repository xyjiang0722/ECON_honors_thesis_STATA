di $ep_star

********************************** Y(1) **********************************
* generate upsilon_1
matrix upsilon_1 = J(10,38,0)
scalar count = 1
foreach var in $q_list {
	qui reg `var' one age age2 ed black hisp married nodeg re75 re74 if treat==1, nocons
	matrix temp = e(b)
	matrix temp = temp'
	matrix upsilon_1[1, count] = temp
	scalar count = count + 1
}


* generate pseudo_true_beta_1 and sigma_1 (for epsilon_y1 later)
reg re78 one age age2 ed black hisp married nodeg re75 re74 if treat==1, nocons
matrix pseudo_beta_1 = e(b)
matrix pseudo_beta_1 = pseudo_beta_1'
scalar sigma_1 = e(rmse)


* generate gamma_1_tilde -> gamma_1
matrix gamma_1_tilde = J(38,1,0)
forvalues i = 1/38 {
	scalar omega_`i' = runiform(-1, 1)
	matrix gamma_1_tilde[`i',1] = omega_`i'
}

matrix gamma_1_tilde_temp = gamma_1_tilde*gamma_1_tilde'
scalar gamma_1_tilde_norm = sqrt(gamma_1_tilde_temp[1,1])

matrix gamma_1 = ($ep_star / gamma_1_tilde_norm) * gamma_1_tilde


* true_beta_1
matrix true_beta_1 = pseudo_beta_1 - upsilon_1*gamma_1


* generate Y(1) (mu_1 -> Y(1))
gen mu_1 = 0
gen y_1 = 0
forvalues i = 1/`=_N' {
	* first part of mu_1: X*beta_1
	scalar count_1 = 1
	matrix var1_value_mat = J(1, 10, 0)
	foreach var1 in one age age2 ed black hisp married nodeg re75 re74 {
		scalar var1_value = `var1'[`i']
		matrix var1_value_mat[1, count_1] = var1_value
		scalar count_1 = count_1 + 1
	}	
	matrix var_x = var1_value_mat * true_beta_1
	qui replace mu_1 = var_x[1,1] in `i'
	
	* second part of mu_1: q(X)*gamma_1
	scalar count_2 = 1
	matrix var2_value_mat = J(1, 38, 0)
	foreach var2 in $q_list {
		scalar var2_value = `var2'[`i']
		matrix var2_value_mat[1, count_2] = var2_value
		scalar count_2 = count_2 + 1
	}	
	matrix var_qx = var2_value_mat * gamma_1
	qui replace mu_1 = mu_1 + var_qx[1,1] in `i'
	
	scalar epsilon_y1 = rnormal(0, sigma_1)
	
	qui replace y_1 = mu_1 + epsilon_y1 in `i'
}



********************************** Y(0) **********************************
****** same procedure ******
* generate upsilon_0
matrix upsilon_0 = J(10,38,0)
scalar count = 1
foreach var in $q_list {
	qui reg `var' one age age2 ed black hisp married nodeg re75 re74 if treat==0, nocons
	matrix temp = e(b)
	matrix temp = temp'
	matrix upsilon_0[1, count] = temp
	scalar count = count + 1
}


* generate pseudo_true_beta_0 and sigma_0 (for epsilon_y0 later)
reg re78 one age age2 ed black hisp married nodeg re75 re74 if treat==0, nocons
matrix pseudo_beta_0 = e(b)
matrix pseudo_beta_0 = pseudo_beta_0'
scalar sigma_0 = e(rmse)


* generate gamma_0_tilde -> gamma_0
matrix gamma_0_tilde = J(38,1,0)
forvalues i = 1/38 {
	scalar omega_`i' = runiform(-1, 1)
	matrix gamma_0_tilde[`i',1] = omega_`i'
}

matrix gamma_0_tilde_temp = gamma_0_tilde*gamma_0_tilde'
scalar gamma_0_tilde_norm = sqrt(gamma_0_tilde_temp[1,1])

matrix gamma_0 = ($ep_star / gamma_0_tilde_norm) * gamma_0_tilde


* true_beta_0
matrix true_beta_0 = pseudo_beta_0 - upsilon_0*gamma_0


* generate Y(0) (mu_0 -> Y(0))
gen mu_0 = 0
gen y_0 = 0
forvalues i = 1/`=_N' {
	* first part of mu_0: X*beta_0
	scalar count_1 = 1
	matrix var1_value_mat = J(1, 10, 0)
	foreach var1 in one age age2 ed black hisp married nodeg re75 re74 {
		scalar var1_value = `var1'[`i']
		matrix var1_value_mat[1, count_1] = var1_value
		scalar count_1 = count_1 + 1
	}	
	matrix var_x = var1_value_mat * true_beta_0
	qui replace mu_0 = var_x[1,1] in `i'
	
	* second part of mu_0: q(X)*gamma_0
	scalar count_2 = 1
	matrix var2_value_mat = J(1, 38, 0)
	foreach var2 in $q_list {
		scalar var2_value = `var2'[`i']
		matrix var2_value_mat[1, count_2] = var2_value
		scalar count_2 = count_2 + 1
	}	
	matrix var_qx = var2_value_mat * gamma_0
	qui replace mu_0 = mu_0 + var_qx[1,1] in `i'
	
	scalar epsilon_y0 = rnormal(0, sigma_0)
	
	qui replace y_0 = mu_0 + epsilon_y0 in `i'
}


*********************************** D ***********************************
****** same procedure for pseudo_true_beta_p and gamma_p ******
* generate pseudo_true_beta_p and sigma_0 (for epsilon_y0 later)
logit treat one age age2 ed black hisp married nodeg re75 re74, nocons
matrix pseudo_beta_p = e(b)
matrix pseudo_beta_p = pseudo_beta_p'


* generate gamma_p_tilde -> gamma_p
matrix gamma_p_tilde = J(38,1,0)
forvalues i = 1/38 {
	scalar omega_`i' = runiform(-1, 1)
	matrix gamma_p_tilde[`i',1] = omega_`i'
}

matrix gamma_p_tilde_temp = gamma_p_tilde*gamma_p_tilde'
scalar gamma_p_tilde_norm = sqrt(gamma_p_tilde_temp[1,1])   

matrix gamma_p = ($ep_star / gamma_p_tilde_norm) * gamma_p_tilde


* generate propensity score
gen p_score = .


******** Mistake in MATA: line 196 *********
/*
clear mata
mata

gamma = st_matrix("gamma_p")
pseudo_true_beta = st_matrix("pseudo_beta_p")
X = st_data(., ("one age age2 ed black hisp married nodeg re75 re74"))
qX = st_data(., (13..50))

void find_beta_p(real colvector true_beta, temp, gamma, pseudo_true_beta, real matrix X, qX){
	
	real scalar target
	
	temp = (1:/(1:+exp(X*pseudo_true_beta))):*((exp(X*true_beta'+qX*gamma):-exp(X*pseudo_true_beta)):/(1:+exp(X*true_beta'+qX*gamma)))
	target = mean(X'*temp)
}

S=optimize_init()
optimize_init_which(S, "min")
optimize_init_evaluator(S, &find_beta_p())
optimize_init_argument(S, 3, gamma)
optimize_init_argument(S, 4, pseudo_true_beta)
optimize_init_argument(S, 5, X)
optimize_init_argument(S, 6, qX)
optimize_init_params(S, J(1,10,0.1))

optimize_result_params(S)        
true_beta_p = optimize(S)       // 3010  attempt to dereference NULL pointer
true_beta_p

linear_p = X*true_beta_p + qX*gamma
p_score = invlogit(linear_p)

st_store(., "p_score", p_score)

end
*/
**********************************************


* the expressions (temp and target) are not wrong
/*
clear mata
mata
gamma = st_matrix("gamma_p")
pseudo_true_beta = st_matrix("pseudo_beta_p")
X = st_data(., ("one age age2 ed black hisp married nodeg re75 re74"))
qX = st_data(., (13..50))
true_beta = (1,1,0,1,1,0,1,1,0,1)
temp = (1:/(1:+exp(X*pseudo_true_beta))):*((exp(X*true_beta'+qX*gamma):-exp(X*pseudo_true_beta)):/(1:+exp(X*true_beta'+qX*gamma)))
target = mean(X'*temp)
temp
target
end
*/


*** This is not correct; just use it to check the rest of the codes ***
replace p_score = runiform(0,1)


gen D = rbinomial(1, p_score)


****************** Treatment effect for each individual ******************
gen ind_te = y_1*D + y_0*(1-D)











