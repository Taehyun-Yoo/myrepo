library("Rcpp")
library("rstanarm")
library('tidyverse')
library('here')
library("brms")
library("arm")
library("loo")

n <- 50
a <- 2
b <- 3
x_mean <- -a/b
x_sd <- 4/b
x <- rnorm(n, x_mean, x_sd)
y <- rbinom(n, 1, invlogit(a + b*x))
fake_1 <- data.frame(x, y)
head(fake_1)

fit_1 <- stan_glm(y ~ x, family=binomial(link="logit"), data=fake_1, refresh=0)
a_hat <- coef(fit_1)[1]
b_hat <- coef(fit_1)[2]

wells <- here("..", "Arsenic", "data", "wells.csv")
wells <- read.csv(wells)
wells

fit_4 <- stan_glm(switch ~ dist100 + arsenic + dist100:arsenic,
                  family=binomial(link="logit"), data=wells)
print(fit_4)

wells$c_dist100 <- wells$dist100 - mean(wells$dist100)
wells$c_arsenic <- wells$arsenic - mean(wells$arsenic)

fit_5 <- stan_glm(switch ~ c_dist100 + c_arsenic + c_dist100:c_arsenic,
                  family=binomial(link="logit"), data=wells)

plot(wells$dist, wells$y_jitter, xlim=c(0,max(wells$dist)))
curve(invlogit(cbind(1, x/100, 0.5, 0.5*x/100) %*% coef(fit_4)), add=TRUE)
curve(invlogit(cbind(1, x/100, 1.0, 1.0*x/100) %*% coef(fit_4)), add=TRUE)

fit_6 <- stan_glm(switch ~ dist100 + arsenic + educ4,
                  family=binomial(link="logit"), data=wells)

wells$c_educ4 <- wells$educ4 - mean(wells$educ4)

fit_6_inter <- stan_glm(switch ~ c_dist100 + c_arsenic + c_educ4 + c_dist100:c_educ4 + c_arsenic:c_educ4,
                  family=binomial(link="logit"), data=wells)

fit <- stan_glm(switch ~ dist100, family=binomial(link="logit"), data=wells)
sims <- as.matrix(fit)
n_sims <- nrow(sims)
plot(sims[,1], sims[,2], xlab=expression(beta[0]), ylab=expression(beta[1]))
plot(wells$dist100, wells$y)
for(s in 1:20){
  curve(invlogit(sims[s,1] + sims[s,2]*x), col="gray", lwd=0.5, add=TRUE)
}
curve(invlogit(mean(sims[,1]) + mean(sims[,2])*x), add=TRUE)

#X_new가 어디 있지?
#n_new <- nrow(X_new)
#y_new <- array(NA, c(n_sims, n_new))
#for (s in 1:n_sims){
#  p_new <- invlogit(X_new %*% sims[s,])
#  y_new[s,] <- rbinom(n_new, 1, p_new)
#}

#y_new <- array(NA, c(n_sims, n_new))
#for (s in 1:n_sims){
#  epsilon_new <- logit(runif(n_new, 0, 1))
#  z_new <- X_new %*% t(sims[s,]) + epsilon_new
#  y_new[s,] <- ifelse(z_new > 0, 1, 0)
#}

fit_7 <- stan_glm(switch ~ dist100 + arsenic + educ4, family=binomial(link="logit"),
                  data=wells)

b <- coef(fit_7)

hi <- 1
lo <- 0
delta <- invlogit(b[1] + b[2]*hi + b[3]*wells$arsenic + b[4]*wells$educ4) -
  invlogit(b[1] + b[2]*lo + b[3]*wells$arsenic + b[4]*wells$educ4)
round(mean(delta), 2)

hi <- 1.0
lo <- 0.5
delta <- invlogit(b[1] + b[2]*wells$dist100 + b[3]*hi + b[4]*wells$educ4) -
  invlogit(b[1] + b[2]*wells$dist100 + b[3]*lo + b[4]*wells$educ4)
round(mean(delta), 2)

hi <- 3
lo <- 0
delta <- invlogit(b[1] + b[2]*wells$dist100 + b[3]*wells$arsenic + b[4]*hi) -
  invlogit(b[1] + b[2]*wells$dist100 + b[3]*wells$arsenic + b[4]*lo)
round(mean(delta), 2)

fit_8 <- stan_glm(switch ~ c_dist100 + c_arsenic + c_educ4 + c_dist100:c_educ4 +
                    c_arsenic:c_educ4, family=binomial(link="logit"), data=wells)

b <- coef(fit_8)
hi <- 1
lo <- 0
delta <- invlogit(b[1] + b[2]*hi + b[3]*wells$c_arsenic + b[4]*wells$c_educ4 +
                    b[5]*hi*wells$c_educ4 + b[6]*wells$c_arsenic*wells$c_educ4) -
  invlogit(b[1] + b[2]*lo + b[3]*wells$c_arsenic + b[4]*wells$c_educ4 +
             b[5]*lo*wells$c_educ4 + b[6]*wells$c_arsenic*wells$c_educ4)
round(mean(delta), 2)

wells$log_arsenic <- log(wells$arsenic)
wells$c_log_arsenic <- wells$log_arsenic - mean(wells$log_arsenic)

fit_9 <- stan_glm(switch ~ c_dist100 + c_log_arsenic + c_educ4 + c_dist100:c_educ4 +
                    c_log_arsenic:c_educ4, family=binomial(link="logit"), data=wells)

nes <- here("..", "NES", "data", "nes.txt")
nes <- read.table(nes)
nes60 <- subset(nes, nes$year == 1960)
nes64 <- subset(nes, nes$year == 1964)
nes68 <- subset(nes, nes$year == 1968)
nes72 <- subset(nes, nes$year == 1972)

fit_60 <- stan_glm(rvote ~ female + black + income, family=binomial(link="logit"), data=nes60)
fit_64 <- stan_glm(rvote ~ female + black + income, family=binomial(link="logit"), data=nes64, prior_intercept=NULL, prior=NULL, prior_aux=NULL)
fit_68 <- stan_glm(rvote ~ female + black + income, family=binomial(link="logit"), data=nes68)
fit_72 <- stan_glm(rvote ~ female + black + income, family=binomial(link="logit"), data=nes72)
