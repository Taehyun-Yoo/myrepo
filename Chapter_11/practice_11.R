library("Rcpp")
library("rstanarm")
library('tidyverse')
library('here')
library("brms")
library("haven")
library("loo")
library("MASS")

kidiq <- here("..", "KidIQ", "data", "kidiq.csv")
kidiq <- read.csv(kidiq)
kidiq

fit_2 <- brm(kid_score ~ mom_iq, data=kidiq)
plot(kidiq$mom_iq, kidiq$kid_score, xlab="Mother IQ score", ylab="Child test score")
abline(a = fixef(fit_2)[1,1], b = fixef(fit_2)[2,1])

fit_3 <- brm(kid_score ~ mom_hs + mom_iq, data=kidiq)
colors <- ifelse(kidiq$mom_hs==1, "black", "gray")
plot(kidiq$mom_iq, kidiq$kid_score,
     xlab="Mother IQ score", ylab="Child test score", col=colors, pch=20)
b_hat <- fixef(fit_3)
abline(b_hat[1,1] + b_hat[2,1], b_hat[3,1], col="black")
abline(b_hat[1,1], b_hat[3,1], col="gray")

fit_4 <- brm(kid_score ~ mom_hs + mom_iq + mom_hs:mom_iq, data=kidiq)
colors <- ifelse(kidiq$mom_hs==1, "black", "gray")
plot(kidiq$mom_iq, kidiq$kid_score,
     xlab="Mother IQ score", ylab="Child test score", col=colors, pch=20)
b_hat <- fixef(fit_4)
abline(b_hat[1,1] + b_hat[2,1], b_hat[3,1] + b_hat[4,1], col="black")
abline(b_hat[1,1], b_hat[3,1], col="gray")

sims_2 <- as.matrix(fit_2)
n_sims_2 <- nrow(sims_2)
beta_hat_2 <- apply(sims_2, 2, median)
plot(kidiq$mom_iq, kidiq$kid_score, xlab="Mother IQ score", ylab="Child test score")
sims_display <- sample(n_sims_2, 10)
for (i in sims_display){
  abline(sims_2[i,1], sims_2[i,2], col="gray")
}
abline(a = fixef(fit_2)[1,1], b = fixef(fit_2)[2,1], col = "black")

sims_3 <- as.matrix(fit_3)
n_sims_3 <- nrow(sims_3)

par(mfrow=c(1,2))
plot(kidiq$mom_iq, kidiq$kid_score, xlab="Mother IQ score", ylab="Child test score")
mom_hs_bar <- mean(kidiq$mom_hs)
sims_display <- sample(n_sims_3, 10)
for (i in sims_display){
  curve(cbind(1, mom_hs_bar, x) %*% sims_3[i,1:3], lwd=0.5, col="gray", add=TRUE)
}
curve(cbind(1, mom_hs_bar, x) %*% fixef(fit_3)[1:3,1], col="black", add=TRUE)
plot(kidiq$mom_hs, kidiq$kid_score, xlab="Mother completed high school",
     ylab="Child test score")
mom_iq_bar <- mean(kidiq$mom_iq)
for (i in sims_display){
  curve(cbind(1, x, mom_iq_bar) %*% sims_3[i,1:3], lwd=0.5, col="gray", add=TRUE)
}
curve(cbind(1, x, mom_iq_bar) %*% fixef(fit_3)[1:3,1], col="black", add=TRUE)

N <- 100
x <- runif(N, 0, 1)
z <- sample(c(0, 1), N, replace=TRUE)
a <- 1
b <- 2
theta <- 5
sigma <- 2
y <- a + b*x + theta*z + rnorm(N, 0, sigma)
fake <- data.frame(x=x, y=y, z=z)

fit <- brm(y ~ x + z, data=fake)
par(mfrow=c(1,2))
for (i in 0:1){
  plot(range(x), range(y), type="n", main=paste("z =", i))
  points(x[z==i], y[z==i], pch=20+i)
  abline(fixef(fit)[,1]["Intercept"] + fixef(fit)[,1]["z"]*i, fixef(fit)[,1]["x"])
}

N <- 100
K <- 10
X <- array(runif(N*K, 0, 1), c(N, K))
z <- sample(c(0, 1), N, replace=TRUE)
a <- 1
b <- 1:K
theta <- 5
sigma <- 2
y <- a + X %*% b + theta*z + rnorm(N, 0, sigma)
fake <- data.frame(X=X, y=y, z=z)
#fit <- brm(y ~ X[,1] + z, data=fake)
fit <- stan_glm(y ~ X + z, data=fake)
y_hat <- predict(fit)
par(mfrow=c(1,2))
for (i in 0:1){
  plot(range(y_hat,y), range(y_hat,y), type="n", main=paste("z =", i))
  points(y_hat[z==i], y[z==i], pch=20+i)
  abline(0, 1)
}

introclass <- here("..", "Introclass", "data", "gradesW4315.dat")
introclass <- read.table(introclass, head = TRUE)

fit_1 <- brm(final ~ midterm, data=introclass)
print(fit_1)

sims <- as.matrix(fit_1)
predicted <- predict(fit_1)
resid <- introclass$final - predicted

a <- 64.5
b <- 0.7
sigma <- 14.8
n <- nrow(introclass)
introclass$final_fake <- a + b*introclass$midterm + rnorm(n, 0, sigma)

fit_fake <- brm(final_fake ~ midterm, data=introclass)
sims <- as.matrix(fit_fake)
predicted_fake <- colMeans(sims[,1] + sims[,2] %*% t(introclass$midterm))

newcomb <- here("..", "newcomb", "data", "newcomb.txt")
newcomb <- read.table(newcomb, header = TRUE)
newcomb

fit <- brm(y ~ 1, data=newcomb)

sims <- as.matrix(fit)
n_sims <- nrow(sims)
n <- length(newcomb$y)
y_rep <- array(NA, c(n_sims, n))
for (s in 1:n_sims) {
  y_rep[s,] <- rnorm(n, sims[s,1], sims[s,2])
}
#y_rep <- posterior_predict(fit)

par(mfrow=c(5,4))
for (s in sample(n_sims, 20)) {
  hist(y_rep[s,])
}

test <- function(y) {
  min(y)
}
test_rep <- apply(y_rep, 1, test)

hist(test_rep, xlim=range(test(y), test_rep))
lines(rep(test(y),2), c(0,n))

unemp <- here("..", "Unemployment", "data", "unemp.txt")
unemp <- read.table(unemp, header = TRUE)
unemp

n <- nrow(unemp)
unemp$y_lag <- c(NA, unemp$y[1:(n-1)])
fit_lag <- brm(y ~ y_lag, data=unemp)
sims <- as.matrix(fit_lag)
n_sims <- nrow(sims)
y <- unemp$y
y_rep <- array(NA, c(n_sims, n))

for (s in 1:n_sims){
  y_rep[s,1] <- y[1]
  for (t in 2:n){
    y_rep[s,t] <- sims[s,"b_Intercept"] + sims[s,"b_y_lag"] * y_rep[s,t-1] +
      rnorm(1, 0, sims[s,"sigma"])
  }
}

test <- function(y){
  n <- length(y)
  y_lag <- c(NA, y[1:(n-1)])
  y_lag_2 <- c(NA, NA, y[1:(n-2)])
  sum(sign(y-y_lag) != sign(y_lag-y_lag_2), na.rm=TRUE)
}

test_y <- test(unemp$y)
test_rep <- apply(y_rep, 1, test)

#calculate R2
fit__1 <- brm(kid_score ~ mom_hs + mom_iq, data = kidiq)
rss <- sum((kidiq$kid_score - (fixef(fit__1)[1,1] + fixef(fit__1)[2,1]*kidiq$mom_hs + fixef(fit__1)[3,1]*kidiq$mom_iq)) ^ 2)  ## residual sum of squares
tss <- sum((kidiq$kid_score - mean(kidiq$kid_score)) ^ 2)  ## total sum of squares
rsq <- 1 - rss/tss

fit__2 <- lm(kid_score ~ mom_hs, data = kidiq)
squares_of_cor <- cor(kidiq$kid_score,kidiq$mom_hs)^2

x <- 1:5 - 3
y <- c(1.7, 2.6, 2.5, 4.4, 3.8) - 3
xy <- data.frame(x,y)

fit <- lm(y ~ x, data = xy)
ols_coef <- coef(fit)
yhat <- ols_coef[1] + ols_coef[2] * x
r <- y - yhat
rsq_1 <- var(yhat)/(var(y))
rsq_2 <- var(yhat)/(var(yhat) + var(r))
round(c(rsq_1, rsq_2), 3)
fit2 <- stan_glm(y ~ x, data = xy)
fit3 <- stan_glm(y ~ x, data = xy, prior=normal(1, 0.2), prior_intercept=normal(0, 0.2))
median(bayes_R2(fit2))

n <- 20
x <- 1:n
a <- 0.2
b <- 0.3
sigma <- 1
set.seed(2141)
y <- a + b*x + sigma*rnorm(n)
fake <- data.frame(x, y)
fit_all <- brm(y ~ x, data = fake)
fit_minus_18 <- brm(y ~ x, data = fake[-18,])

n <- nrow(kidiq)
kidiqr <- kidiq
kidiqr$noise <- array(rnorm(5*n), c(n,5))
fit_3 <- brm(kid_score ~ mom_hs + mom_iq + noise, data=kidiqr)

loo_3 <- loo(fit_3)
print(loo_3)

fit_1 <- brm(kid_score ~ mom_hs, data=kidiq)
loo_1 <- loo(fit_1)
print(loo_1)

loo_compare(loo_3, loo_1)

fit_4 <- brm(kid_score ~ mom_hs + mom_iq + mom_hs:mom_iq, data=kidiq)
loo_4 <- loo(fit_4)

loo_compare(loo_3, loo_4)

k <- 30
rho <- 0.8
Sigma <- rho*array(1, c(k,k)) + (1-rho)*diag(k)
X <- mvrnorm(n, rep(0,k), Sigma)
b <- c(c(-1,1,2), rep(0, k-3))
y <- X %*% b + 2*rnorm(n)
fake <- data.frame(X, y)

fit_1 <- stan_glm(y ~ ., prior=normal(0, 10), data=fake)
loo_1 <- loo(fit_1)

kfold_1 <- kfold(fit_1, K=10)
print(kfold_1)

fit_2 <- update(fit_2, prior=hs())
kfold_2 <- kfold(fit_2, K=10)
loo_compare(kfold_1, kfold_2)
