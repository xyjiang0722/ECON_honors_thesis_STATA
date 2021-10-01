local n_obs = `1'
set obs `n_obs'

gen x = runiform()

#read p_0, p_1 and alpha_2 from the csv file and generate alpha_0 and alpha_1
scalar alpha_0 = p_0
local alpha_0 = alpha_0
scalar alpha_1 = p_1 - p_0 - alpha_2
local alpha_1 = alpha_1

scalar beta_0 = mu0_0
local beta_0 = beta_0
scalar beta_1 = mu0_1 - mu0_0 - beta_2
local beta_1 = beta_1

scalar gamma_0 = mu1_0
local gamma_0 = gamma_0
scalar gamma_1 = mu1_1 - mu1_0 - gamma_2
local gamma_1 = gamma_1

#generate 3 uniformly distributed r.v. to compare with d, y_0 and y_1 that are of the quadratic forms and generate the true d, y_0 and y_1
gen u_d = runiform()
gen u_1 = runiform()
gen u_0 = runiform()

gen d = 1 if (alpha_0 + alpha_1*x + alpha_2*x^2 >= u_d)
replace d = 0 if d==.

gen y_0 = 1 if (beta_0 + beta_1*x + beta_2*x^2 >= u_0)
replace y_0 = 0 if y_0==.

gen y_1 = 1 if (gamma_0 + gamma_1*x + gamma_2*x^2 >= u_1)
replace y_1 = 0 if y_1==.

#true treatment effect
gen y = d*y_1+(1-d)*y_0

#P[d=1|x]=the coefficient of x in the regression d~x
regress d x
predict p_hat
replace p_hat = 0.99 if p_hat>0.99
replace p_hat = 0.01 if p_hat<0.01

#mu_1 = E[y_1|x]
regress y x if d == 1
predict mu_1

#mu_1 = E[y_1|x]
regress y x if d == 0
predict mu_0

#treatment effect for each individual
gen ind_te = y_1 - y_0
#inverse probability weighting
gen ipw_te = d*y/p_hat - (1-d)*y/(1-p_hat)
#augmented inverse probability weighting
gen aipw_te = d*y/p_hat - mu_1*(d/p_hat-1) - (1-d)*y/(1-p_hat)+ mu_0*((1-d)/(1-p_hat)-1)

gen weights_1 = 1/p_hat
gen weights_0 = 1/(1-p_hat)


*END
