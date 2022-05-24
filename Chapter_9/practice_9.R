library("Rcpp")
library("rstanarm")
library('tidyverse')
library('here')
library("brms")

hibbs <- here("..", "ElectionsEconomy", "data", "hibbs.dat")
hibbs <- read.table(hibbs, header = TRUE)

m1 <- brm(
  vote ~ growth, 
  data = hibbs
)

sims3 <- as.matrix(m1)
Median <- apply(sims3, 2, median)
MAD_SD <- apply(sims3, 2, mad)
print(cbind(Median, MAD_SD))

a <- sims3[,1]
b <- sims3[,2]
z <- a/b
print(c(median(z), mad(z)))

fit3 <- stan_glm(vote ~ growth, data=hibbs)
sims2 <- as.matrix(fit3)
Median2 <- apply(sims2, 2, median)
MAD_SD2 <- apply(sims2, 2, mad)
print(cbind(Median2, MAD_SD2))

new <- data.frame(growth=2.0)
y_point_pred <- predict(m1, newdata=new)
y_linpred <- posterior_linpred(m1, newdata=new)
y_pred <- posterior_predict(m1, newdata=new)
y_pred_median <- median(y_pred)
y_pred_mad <- mad(y_pred)
win_prob <- mean(y_pred > 50)
cat("Predicted Clinton percentage of 2-party vote: ", round(y_pred_median,1),
    ", with s.e. ", round(y_pred_mad, 1), "\nPr (Clinton win) = ", round(win_prob, 2),
    sep="")

new_grid <- data.frame(growth=seq(-2.0, 4.0, 0.5))
y_point_pred_grid2 <- predict(m1, newdata=new_grid)
y_linpred_grid2 <- posterior_linpred(m1, newdata=new_grid)
y_pred_grid2 <- posterior_predict(m1, newdata=new_grid)

n_sims <- nrow(sims3)
sigma <- sims3[,3]

x_new <- rnorm(n_sims, 2.0, 0.3)
y_pred3 <- rnorm(n_sims, a + b*x_new, sigma)

earnings <- here("..", "Earnings", "data", "earnings.csv")
earnings <- read.csv(earnings)

fit1 <- brm(
  weight ~ height, 
  data = earnings
)
earnings$c_height <- earnings$height - 66
fit2 <- brm(
  weight ~ c_height, 
  data = earnings
)
print(fit2)

theta_hat_prior <- 0.524
se_prior <- 0.041
n <- 400
y <- 190
theta_hat_data <- y/n
se_data <- sqrt((y/n)*(1-y/n)/n)
theta_hat_bayes <- (theta_hat_prior/se_prior^2 + theta_hat_data/se_data^2) /
  (1/se_prior^2 + 1/se_data^2)
se_bayes <- sqrt(1/(1/se_prior^2 + 1/se_data^2))

M3 <- stan_glm(vote ~ growth, data=hibbs,
               prior_intercept=NULL, prior=NULL, prior_aux=NULL)
sims <- as.data.frame(M3)
a <- sims[,1]
b <- sims[,2]
plot(a, b)

prior_summary()