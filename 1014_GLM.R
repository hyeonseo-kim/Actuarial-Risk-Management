# Example 5.8.

nloglik <- function(x, theta){
-sum(log(dexp(x, rate = 1/theta)))
}

data = c(10.3, 19.7, 15.4, 29.6, 20)

optim(nloglik, x = data, par = 10)

mean(data)

# Example(ppt 15p)
nloglik <- function(x, theta){
-sum(log(dpois(x, lambda = theta)))
}

data = c(0,0,3)

optim(nloglik, x = data, par = 10)

mean(data)

y = c(2,0,1)
n_log_lik <-function(y, lambda){
	-sum(log(dpois(y, lambda)))}
optim(n_log_lik, par = c(3), y = c(2,0,1))
