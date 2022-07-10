library("Rcpp")
library("rstanarm")
library('tidyverse')
library('here')
library("brms")
library("arm")
library("loo")
library("MASS")
library("bayesplot")

n <- 50
x <- runif(n, -2, 2)
a <- 1
b <- 2
linpred <- a + b*x
y <- rpois(n, exp(linpred))
fake <- data.frame(x=x, y=y)
fit_fake <- stan_glm(y ~ x, family=poisson(link="log"), data=fake)
print(fit_fake)
plot(x, y)
curve(exp(coef(fit_fake)[1] + coef(fit_fake)[2]*x), add=TRUE)

phi_grid <- c(0.1, 1, 10)
K <- length(phi_grid)
y_nb <- as.list(rep(NA, K))
fake_nb <- as.list(rep(NA, K))
fit_nb <- as.list(rep(NA, K))
for (k in 1:K){
  y_nb[[k]] <- rnegbin(n, exp(linpred), phi_grid[k])
  fake_nb[[k]] <- data.frame(x=x, y=y_nb[[k]])
  fit_nb[[k]] <- stan_glm(y ~ x, family=neg_binomial_2(link="log"), data=fake)
  print(fit_nb[[k]])
}

for (k in 1:K) {
  plot(x, y_nb[[k]])
  curve(exp(coef(fit_nb[[k]])[1] + coef(fit_nb[[k]])[2]*x), add=TRUE)
}

roaches <- here("..", "Roaches", "data", "roaches.csv")
roaches <- read.csv(roaches)
roaches$roach100 <- roaches$roach1/100
fit_1 <- stan_glm(y ~ roach100 + treatment + senior, family=neg_binomial_2,
                  offset=log(exposure2), data=roaches)
print(fit_1, digits=2)

yrep_1 <- posterior_predict(fit_1)
n_sims <- nrow(yrep_1)
subset <- sample(n_sims, 100)
ppc_dens_overlay(log10(roaches$y+1), log10(yrep_1[subset,]+1))

test <- function (y){
  mean(y==0)
}
test_rep_1 <- apply(yrep_1, 1, test)

fit_2 <- stan_glm(y ~ roach100 + treatment + senior, family=poisson,
                  offset=log(exposure2), data=roaches)
yrep_2 <- posterior_predict(fit_2)
print(mean(roaches$y==0))
print(mean(yrep_2==0))
test_rep_2 <- apply(yrep_2, 1, test)

N <- 100
height <- rnorm(N, 72, 3)
p <- 0.4 + 0.1*(height - 72)/3
n <- rep(20, N)
y <- rbinom(N, n, p)
data <- data.frame(n=n, y=y, height=height)
fit_1a <- stan_glm(cbind(y, n-y) ~ height, family=binomial(link="logit"),
                   data=data)
print(fit_1a)

wells <- here("..", "Arsenic", "data", "wells.csv")
wells <- read.csv(wells)
wells
fit_probit <- stan_glm(switch ~ dist100, family=binomial(link="probit"), data=wells)
print(fit_probit)

data <- here("..", "Storable", "data", "2playergames.csv")
data <- read.csv(data)
data_401 <- subset(data, data$person == 401)
fit_1 <- stan_polr(factor(vote) ~ value, data=data_401, prior=R2(0.3, "mean"))
print(fit_1)

expected <- function (x, c1.5, c2.5, sigma){
  p1.5 <- invlogit((x-c1.5)/sigma)
  p2.5 <- invlogit((x-c2.5)/sigma)
  return((1*(1-p1.5) + 2*(p1.5-p2.5) + 3*p2.5))
}

plot(data_401$value, data_401$vote, xlim=c(0,100), ylim=c(1,3), xlab="Value", ylab="Vote")
#lines(rep(c1.5, 2), c(1,2))
#%lines(rep(c2.5, 2), c(2,3))
#%curve(expected(x, c1.5, c2.5, sigma), add=TRUE)

wells$dist100 <- wells$dist/100
fit_2 <- stan_glm(switch ~ dist100, family=binomial(link="logit"), data=wells)

earnings <- here("..", "Earnings", "data", "earnings.csv")
earnings <- read.csv(earnings)
earnings

fit_1a <- stan_glm((earn > 0) ~ height + male, family=binomial(link="logit"), data=earnings)
fit_1b <- stan_glm(log(earn) ~ height + male, data=earnings, subset=earn>0)

new <- data.frame(height=68, male=0)
pred_1a <- posterior_predict(fit_1a, newdata=new)
pred_1b <- posterior_predict(fit_1b, newdata=new)
pred <- ifelse(pred_1a==1, exp(pred_1b), 0)
