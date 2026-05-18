y = c(2,0,1)
n_log_lik <-function(y, lambda){
	-sum(log(dpois(y, lambda)))}
optim(n_log_lik, par = c(3), y = c(2,0,1))