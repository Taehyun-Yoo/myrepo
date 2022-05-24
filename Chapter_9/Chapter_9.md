---
title: "Chapter_9"
author: "Taehyun Yoo"
date: '2022-05-22'
output: 
  html_document: 
    keep_md: yes
---



# 9.1 Propagating uncertainty in inference using posterior simulations

```r
hibbs <- here("..", "ElectionsEconomy", "data", "hibbs.dat")
hibbs <- read.table(hibbs, header = TRUE)
hibbs
```

```
##    year growth  vote inc_party_candidate other_candidate
## 1  1952   2.40 44.60           Stevenson      Eisenhower
## 2  1956   2.89 57.76          Eisenhower       Stevenson
## 3  1960   0.85 49.91               Nixon         Kennedy
## 4  1964   4.21 61.34             Johnson       Goldwater
## 5  1968   3.02 49.60            Humphrey           Nixon
## 6  1972   3.62 61.79               Nixon        McGovern
## 7  1976   1.08 48.95                Ford          Carter
## 8  1980  -0.39 44.70              Carter          Reagan
## 9  1984   3.86 59.17              Reagan         Mondale
## 10 1988   2.27 53.94           Bush, Sr.         Dukakis
## 11 1992   0.38 46.55           Bush, Sr.         Clinton
## 12 1996   1.04 54.74             Clinton            Dole
## 13 2000   2.36 50.27                Gore       Bush, Jr.
## 14 2004   1.72 51.24           Bush, Jr.           Kerry
## 15 2008   0.10 46.32              McCain           Obama
## 16 2012   0.95 52.00               Obama          Romney
```

```r
M1 <- brm(
  vote ~ growth, 
  data = hibbs
)
```

```
## Compiling Stan program...
```

```
## Start sampling
```

```
## 
## SAMPLING FOR MODEL '2a34e405a032f5f810ea9b5e8efaa185' NOW (CHAIN 1).
## Chain 1: 
## Chain 1: Gradient evaluation took 0 seconds
## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Chain 1: Adjust your expectations accordingly!
## Chain 1: 
## Chain 1: 
## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 1: 
## Chain 1:  Elapsed Time: 0.066 seconds (Warm-up)
## Chain 1:                0.053 seconds (Sampling)
## Chain 1:                0.119 seconds (Total)
## Chain 1: 
## 
## SAMPLING FOR MODEL '2a34e405a032f5f810ea9b5e8efaa185' NOW (CHAIN 2).
## Chain 2: 
## Chain 2: Gradient evaluation took 0 seconds
## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Chain 2: Adjust your expectations accordingly!
## Chain 2: 
## Chain 2: 
## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 2: 
## Chain 2:  Elapsed Time: 0.071 seconds (Warm-up)
## Chain 2:                0.053 seconds (Sampling)
## Chain 2:                0.124 seconds (Total)
## Chain 2: 
## 
## SAMPLING FOR MODEL '2a34e405a032f5f810ea9b5e8efaa185' NOW (CHAIN 3).
## Chain 3: 
## Chain 3: Gradient evaluation took 0 seconds
## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Chain 3: Adjust your expectations accordingly!
## Chain 3: 
## Chain 3: 
## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 3: 
## Chain 3:  Elapsed Time: 0.063 seconds (Warm-up)
## Chain 3:                0.072 seconds (Sampling)
## Chain 3:                0.135 seconds (Total)
## Chain 3: 
## 
## SAMPLING FOR MODEL '2a34e405a032f5f810ea9b5e8efaa185' NOW (CHAIN 4).
## Chain 4: 
## Chain 4: Gradient evaluation took 0 seconds
## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
## Chain 4: Adjust your expectations accordingly!
## Chain 4: 
## Chain 4: 
## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 4: 
## Chain 4:  Elapsed Time: 0.063 seconds (Warm-up)
## Chain 4:                0.049 seconds (Sampling)
## Chain 4:                0.112 seconds (Total)
## Chain 4:
```

```r
sims <- as.matrix(M1)
Median <- apply(sims, 2, median)
MAD_SD <- apply(sims, 2, mad)
print(cbind(Median, MAD_SD))
```

```
##                 Median    MAD_SD
## b_Intercept  46.213021 1.6914284
## b_growth      3.056252 0.7035783
## sigma         3.941874 0.7507760
## lprior       -5.228466 0.1075339
## lp__        -48.066725 1.1189316
```

```r
#a <- sims[,1]
#b <- sims[,2]
#z <- a/b
#print(c(median(z), mad(z)))
```

# 9.2 Prediction and uncertainty : predict, posterior_linpred, and posterior_predict

```r
hibbs
```

```
##    year growth  vote inc_party_candidate other_candidate
## 1  1952   2.40 44.60           Stevenson      Eisenhower
## 2  1956   2.89 57.76          Eisenhower       Stevenson
## 3  1960   0.85 49.91               Nixon         Kennedy
## 4  1964   4.21 61.34             Johnson       Goldwater
## 5  1968   3.02 49.60            Humphrey           Nixon
## 6  1972   3.62 61.79               Nixon        McGovern
## 7  1976   1.08 48.95                Ford          Carter
## 8  1980  -0.39 44.70              Carter          Reagan
## 9  1984   3.86 59.17              Reagan         Mondale
## 10 1988   2.27 53.94           Bush, Sr.         Dukakis
## 11 1992   0.38 46.55           Bush, Sr.         Clinton
## 12 1996   1.04 54.74             Clinton            Dole
## 13 2000   2.36 50.27                Gore       Bush, Jr.
## 14 2004   1.72 51.24           Bush, Jr.           Kerry
## 15 2008   0.10 46.32              McCain           Obama
## 16 2012   0.95 52.00               Obama          Romney
```
