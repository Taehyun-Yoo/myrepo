#Chapter 1_repo
#load needed packages
library("Rcpp")
library("rstanarm")

#load data
hibbs <- read.table("../ElectionsEconomy/data/hibbs.dat", header=TRUE)
#plot data
plot(hibbs$growth, hibbs$vote, xlab="Average recent growth in personal income",
     ylab="Incumbent party's vote share")
#regression
M1 <- stan_glm(vote ~ growth, data=hibbs)
#add fitted line
abline(coef(M1), col="gray")

#types of fitting
#1:least squares regression
fit <- lm(vote ~ growth, data = hibbs)
#2:maximum likelihood (maybe later)
#3:Bayesian regression
fit <- stan_glm(vote ~ growth, data=hibbs)
#3-1:running Bayesian regression faster using optimizing mode when dataset is large
fit <- stan_glm(vote ~ growth, data=hibbs, algorithm = "optimizing")

