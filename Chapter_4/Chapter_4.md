---
title: "Chapter_4"
author: "Taehyun Yoo"
date: '2022-05-19'
output: 
  html_document: 
    keep_md: yes
---



# 4.2 Estimates, standard errors, and confidence intervals

```r
y <- 40
n <- 100
estimate <- y/n

se <- sqrt(estimate*(1-estimate)/n)
int_95 <- estimate + qnorm(c(0.025, 0.975))*se
int_95
```

```
## [1] 0.3039818 0.4960182
```

```r
y <- rep(c(0,1,2,3,4), c(600,300,50,30,20))
n <- length(y)
estimate <- mean(y)
se <- sd(y)/sqrt(n)
int_50 <- estimate + qt(c(0.25, 0.75), n-1)*se
int_95 <- estimate + qt(c(0.025, 0.975), n-1)*se
int_50
```

```
## [1] 0.5513272 0.5886728
```

```r
int_95
```

```
## [1] 0.5156936 0.6243064
```
