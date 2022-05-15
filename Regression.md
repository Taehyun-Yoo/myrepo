---
title: "Regression"
author: "Taehyun Yoo"
date: '2022-05-15'
output: 
  html_document: 
    keep_md: yes
---


```r
## insert your brilliant WORKING code here
hibbs <- read.table("../ElectionsEconomy/data/hibbs.dat", header=TRUE)
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