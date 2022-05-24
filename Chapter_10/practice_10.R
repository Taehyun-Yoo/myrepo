library("Rcpp")
library("rstanarm")
library('tidyverse')
library('here')
library("brms")

kidiq <- here("..", "KidIQ", "data", "kidiq.csv")
kidiq <- read.csv(kidiq)
kidiq

fit1 <- stan_glm(kid_score ~ mom_hs, data=kidiq)

fit2 <- stan_glm(kid_score ~ mom_iq, data=kidiq)

fit3 <- stan_glm(kid_score ~ mom_hs + mom_iq, data=kidiq)

fit4 <- brm(kid_score ~ mom_hs + mom_iq + mom_hs:mom_iq, data=kidiq)

earnings <- here("..", "Earnings", "data", "earnings.csv")
earnings <- read.csv(earnings)
earnings

fit_1 <- brm(weight ~ height, data=earnings)
M1 <- fixef(fit_1)
print(fit_1)

earnings$c_height <- earnings$height - 66
fit_3 <- brm(weight ~ c_height + male, data=earnings)
coefs_3 <- fixef(fit_3)
predicted <- coefs_3[1,1] + coefs_3[2,1]*4.0 + coefs_3[3,1]*0

fit_4 <- brm(weight ~ c_height + male + factor(ethnicity), data=earnings)
print(fit_4)

earnings$eth <- factor(earnings$ethnicity,
                       levels=c("White", "Black", "Hispanic", "Other"))
fit_5 <- brm(weight ~ c_height + male + eth, data=earnings)
print(fit_5)

earnings$eth_White <- ifelse(earnings$ethnicity=="White", 1, 0)
earnings$eth_black <- ifelse(earnings$ethnicity=="Black", 1, 0)
earnings$eth_hispanic <- ifelse(earnings$ethnicity=="Hispanic", 1, 0)
earnings$eth_other <- ifelse(earnings$ethnicity=="Other", 1, 0)

congress <- here("..", "Congress", "data", "congress.csv")
congress <- read.csv(congress)
congress
hist(congress$v88, breaks = 20)

