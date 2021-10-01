# generate a csv file that contains 1000 shape combinations
# p = alpha_0 + alpha_1*x + alpha_2*x^2, same as mu1 and mu0
# assume p(0)=0.25, p(1)=0.75, ...  -> three cases of assumed ranges
# each one of p, mu1 and mu2 has 10 possible shapes in the assumed ranges (concave, convex and monotonic)
# alpha_0 = p(0) and alpha_1 can be written as functions alpha_2, so only need to include alpha_2 in the csv

# assumed ranges
v1 <- c(0.75, 0.25)
v2 <- c(0.25, 0.75)
v3 <- c(0.5, 0.5)

# corresponding alpha_2 for v1 and v2
A1 <- c(-1.42, -0.5, 0.5, 1.42)

# corresponding alpha_2 for v3
A2 <- c(-1.6, 1.6)

# create a data frame
shape_comb = data.frame(matrix(ncol=9, nrow=0))

p_shape <- list()


# the first three columns: ranges of p and corresponding alpha_2
for (i in 1:4) {
  p_shape[[i]] <- c(append(v1, A1[i]))
}

for (i in 5:8) {
  p_shape[[i]] <- c(append(v2, A1[i-4]))
}

for (i in 9:10) {
  p_shape[[i]] <- c(append(v3, A2[i-8]))
}


# 4th - 6th column: ranges of mu0 and corresponding beta_2
mu0_shape <- list()

for (i in 1:4) {
  mu0_shape[[i]] <- c(append(v1, A1[i]))
}

for (i in 5:8) {
  mu0_shape[[i]] <- c(append(v2, A1[i-4]))
}

for (i in 9:10) {
  mu0_shape[[i]] <- c(append(v3, A2[i-8]))
}


# 7th - 9th column: ranges of mu1 and corresponding gamma_2
mu1_shape <- list()

for (i in 1:4) {
  mu1_shape[[i]] <- c(append(v1, A1[i]))
}

for (i in 5:8) {
  mu1_shape[[i]] <- c(append(v2, A1[i-4]))
}

for (i in 9:10) {
  mu1_shape[[i]] <- c(append(v3, A2[i-8]))
}


# generate each row and append to the csv file
for (i in p_shape) {
  for (j in mu0_shape) {
    for (k in mu1_shape) {
      new_row <- c(i[1], i[2], i[3], j[1], j[2], j[3], k[1], k[2], k[3])
      shape_comb <- rbind(shape_comb, new_row)
    }
  }
}


colnames(shape_comb) <- c("p_0", "p_1", "alpha_2", "mu0_0", "mu0_1", "beta_2", "mu1_0", "mu1_1", "gamma_2")


write.csv(shape_comb, "shape_comb.csv")



