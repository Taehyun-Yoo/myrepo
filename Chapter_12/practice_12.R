library("Rcpp")
library("rstanarm")
library('tidyverse')
library('here')
library("brms")
library("bayesplot")

earnings <- here("..", "Earnings", "data", "earnings.csv")
earnings <- read.csv(earnings)
earnings

fit1 <- brm(earn ~ height, data=earnings)
rss <- sum((earnings$earn - (fixef(fit1)[1,1] + fixef(fit1)[2,1]*earnings$height)) ^ 2, na.rm = TRUE)
rsd <- sqrt(rss/(length(earnings[,1])-length(fixef(fit1)[,1])-1))

earnings$z_height <- (earnings$height - mean(earnings$height))/sd(earnings$height)
fit2 <- brm(earn ~ z_height, data = earnings)

kidiq <- here("..", "KidIQ", "data", "kidiq.csv")
kidiq <- read.csv(kidiq)
kidiq

fit3 <- brm(kid_score ~ mom_hs + mom_iq + mom_hs:mom_iq, data=kidiq)

kidiq$c_mom_hs <- kidiq$mom_hs - mean(kidiq$mom_hs)
kidiq$c_mom_iq <- kidiq$mom_iq - mean(kidiq$mom_iq)
fit4 <- brm(kid_score ~ c_mom_hs + c_mom_iq + c_mom_hs:c_mom_iq, data=kidiq)

kidiq$c2_mom_hs <- kidiq$mom_hs - 0.5
kidiq$c2_mom_iq <- kidiq$mom_iq - 100
fit5 <-brm(kid_score ~ c2_mom_hs + c2_mom_iq + c2_mom_hs:c2_mom_iq, data=kidiq)

kidiq$z_mom_hs <- (kidiq$mom_hs - mean(kidiq$mom_hs))/(2*sd(kidiq$mom_hs))
kidiq$z_mom_iq <- (kidiq$mom_iq - mean(kidiq$mom_iq))/(2*sd(kidiq$mom_iq))
fit6 <-brm(kid_score ~ z_mom_hs + z_mom_iq + z_mom_hs:z_mom_iq, data=kidiq)

logmodel_1 <- brm(log(earn) ~ height,  data=subset(earnings, earn>0))

yrep_1 <- posterior_predict(fit1)
n_sims <- nrow(yrep_1)
subset <- sample(n_sims, 100)
ppc_dens_overlay(earnings$earn, yrep_1[subset,])

yrep_log_1 <- posterior_predict(logmodel_1)
n_sims <- nrow(yrep_log_1)
subset <- sample(n_sims, 100)
ppc_dens_overlay(log(earnings$earn[earnings$earn>0]), yrep_log_1[subset,])

logmodel_1a <- brm(log10(earn) ~ height, data=subset(earnings, earn>0))

logmodel_2 <- brm(log(earn) ~ height + male, data=subset(earnings, earn>0))

logmodel_3 <- brm(log(earn) ~ height + male + height:male, data=subset(earnings, earn>0))

earnings$z_height <- (earnings$height - mean(earnings$height))/sd(earnings$height)
logmodel_4 <- brm(log(earn) ~ z_height + male + z_height:male, data=subset(earnings, earn>0))

earnings$log_height <- log(earnings$height)
logmodel_5 <- brm(log(earn) ~ log_height + male, data=subset(earnings, earn>0))

fit7 <- brm(kid_score ~ factor(mom_work), data=kidiq)

mesquite <- here("..", "Mesquite", "data", "mesquite.dat")
mesquite <- read.table(mesquite, header = TRUE)
mesquite

fit_1 <- brm(formula = weight ~ diam1 + diam2 + canopy_height +
                    total_height + density + group, data=mesquite)
(loo_1 <- loo(fit_1))
(kfold_1 <- kfold(fit_1, K=10))

fit_2 <- brm(formula = log(weight) ~ log(diam1) + log(diam2) + log(canopy_height) +
                    log(total_height) + log(density) + group, data=mesquite)
(loo_2 <- loo(fit_2))
(kfold_2 <- kfold(fit_2, K=10))
loo_compare(kfold_1, kfold_2)

loo_2_with_jacobian <- loo_2
loo_2_with_jacobian$pointwise[,1] <- loo_2_with_jacobian$pointwise[,1] -
  log(mesquite$weight)

sum(loo_2_with_jacobian$pointwise[,1])
loo_compare(kfold_1, loo_2_with_jacobian)

yrep_1 <- posterior_predict(fit_1)
n_sims <- nrow(yrep_1)
subset <- sample(n_sims, 100)
ppc_dens_overlay(mesquite$weight, yrep_1[subset,])
yrep_2 <- posterior_predict(fit_2)
ppc_dens_overlay(log(mesquite$weight), yrep_2[subset,])

mesquite$canopy_volume <- mesquite$diam1 * mesquite$diam2 * mesquite$canopy_height
fit_3 <- brm(log(weight) ~ log(canopy_volume), data=mesquite)

mesquite$canopy_area <- mesquite$diam1 * mesquite$diam2
mesquite$canopy_shape <- mesquite$diam1 / mesquite$diam2
fit_4 <- brm(formula = log(weight) ~ log(canopy_volume) + log(canopy_area) +
                    log(canopy_shape) + log(total_height) + log(density) + group, data=mesquite)

fit_5 <- brm(log(weight) ~ log(canopy_volume) + log(canopy_shape) + group,
                  data=mesquite)

data <- here("..", "Student", "data", "student-merged.csv")
data <- read.csv(data)
data

predictors <- c("school","sex","age","address","famsize","Pstatus","Medu","Fedu",
                "traveltime","studytime","failures","schoolsup","famsup","paid","activities",
                "nursery", "higher", "internet", "romantic","famrel","freetime","goout","Dalc",
                "Walc","health","absences")
data_G3mat <- subset(data, subset=G3mat>0, select=c("G3mat",predictors))
fit0 <- brm(G3mat ~ ., data=data_G3mat)

datastd_G3mat <- data_G3mat
datastd_G3mat[,predictors] <-scale(data_G3mat[,predictors])
fit__1 <- stan_glm(G3mat ~ ., data=datastd_G3mat)

fit__2 <- stan_glm(G3mat ~ ., data=datastd_G3mat,
                 prior=normal(scale=sd(datastd_G3mat$G3mat)/sqrt(0.3*26)))

p <- length(predictors)
n <- nrow(datastd_G3mat)
p0 <- 6
slab_scale <- sqrt(0.3/p0)*sd(datastd_G3mat$G3mat)
# global scale without sigma, as the scaling by sigma is done inside stan_glm
global_scale <- (p0/(p - p0))/sqrt(n)

fit__3 <- stan_glm(G3mat ~ ., data=datastd_G3mat,
                 prior=hs(global_scale=global_scale, slab_scale=slab_scale))

fit__4 <- stan_glm(G3mat ~ failures + schoolsup + goout + absences, data=datastd_G3mat)