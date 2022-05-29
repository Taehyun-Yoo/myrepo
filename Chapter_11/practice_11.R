library("Rcpp")
library("rstanarm")
library('tidyverse')
library('here')
library("brms")
library("haven")

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