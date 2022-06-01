library("Rcpp")
library("rstanarm")
library('tidyverse')
library('here')
library("brms")

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
