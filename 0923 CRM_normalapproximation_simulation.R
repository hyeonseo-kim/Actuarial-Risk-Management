ES = 40
VS = 10*8^2/12+10*16

########
#Approximation of 95% quantile of S
########
qnorm(0.95, mean=ES, sd = sqrt(VS))
ES + 1.625*sqrt(VS)

########
#Use simulation to calculate 95% quantile of S
########more accuracy but large nsim
N = rpois(1,lambda=10)
S = sum(runif(N, min = 0, max = 8))

# 0도 성립함
sum(runif(0, min = 0, max = 8))

nsim = 10000
S = rep(NA, nsim)
for(i in 1:nsim) {
  N = rpois(1, lambda=10)
  S[i] = sum(runif(N, min = 0, max = 8))
}
S[9500]

m = rep(NA,100)
for(k in 1:100){
 nsim = 10000
 S = rep(NA, nsim)
 for(i in 1:nsim) {
  N = rpois(1, lambda=10)
  S[i] = sum(runif(N, min = 0, max = 8))
 }
 S = sort(S)
 m[k] = S[9500]
}
var(m)
mean(m)
