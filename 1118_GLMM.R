###################################

### Exercise 1: Time invariant 

###################################


library(nimble)
set.seed(20251100)

## Sizes and parameters

I  <- 200; Tt <- 4; beta <- c(-0.2, 0.6, 0.4)   
c <- 0.9; sd <- 0.5              



## Time-invariant per individual:

R  <- rgamma(I, shape = c, rate = c)      

X1 <- rnorm(I, mean = 0, sd = sd)          

X2 <- rbinom(I, size = 1, prob = 0.5)      


## Design matrix X: n x (p+1) with intercept

X <- cbind(Intercept = 1, X1 = X1, X2 = X2)

linpred <- beta[1] + beta[2]*X1 + beta[3]*X2

mu <- exp(linpred) * R   # length I

## y_train: I x Tt, independent draws over t with the same per-i mean

y_train <- matrix(NA_integer_, nrow = I, ncol = Tt)

for (t in 1:Tt) {
  y_train[, t] <- rpois(I, mu)
}



## Test at t = 5: same X and R, new Poisson draw
y_test <- rpois(I, mu)
dim(X)

# Y:[200, 4], X[200, 3]
model <- nimbleCode({
  #likelihood 
  for(i in 1:n){
    for(j in 1:t){ 
      lam[i] <- exp(b0 + b1 * X[i, 2] + b2 * X[i, 3])
      Y[i,j] ~ dpois(lam[i] * exp(R[i]))
    }
  }

  for( i in 1:n){
    R[i] ~ dnorm(0, s2)
  }
  

  # Non-informative prior for parameters
  b0 ~ dnorm(0, var=4)
  b1 ~ dnorm(0, var=4)
  b2 ~ dnorm(0, var=4)
  s2 ~ dgamma(shape=0.5,  rate=0.5)
})

my.data <- list(Y = y_train) 
my.constants <-list(X = X, n=200, t=4)
parameters.to.save <- c("b0", "b1", "b2", "s2", "R")

n.iter <- 6000
n.burnin <- 1000
n.chains <- 3
mcmc.output <- nimbleMCMC(code = model,
                          constants = my.constants,
                          data = my.data,
                          #inits = initial.values,
                          monitors = parameters.to.save,
                          niter = n.iter,
                          nburnin = n.burnin,
                          nchains = n.chains)

b0h = mean(c(mcmc.output$chain1[,201], mcmc.output$chain2[,201], 
             mcmc.output$chain3[,201]))
b1h = mean(c(mcmc.output$chain1[,202], mcmc.output$chain2[,202], 
             mcmc.output$chain3[,202]))
b2h = mean(c(mcmc.output$chain1[,203], mcmc.output$chain2[,203], 
             mcmc.output$chain3[,203]))
s2h = mean(c(mcmc.output$chain1[,204], mcmc.output$chain2[,204], 
             mcmc.output$chain3[,204]))

head(mcmc.output$chain1, 2)

## Prediction ##
dim(mcmc.output$chain1)
yhat5= rep(NA, I)
for(i in 1:I){
  Ri_samples = c(mcmc.output$chain1[,i], mcmc.output$chain2[,i], 
                 mcmc.output$chain3[,i])
  lambda_test = exp(b0h+b1h*X[i,2]+b2h*X[i,3])
  yhat5[i] = lambda_test * mean(exp(Ri_samples))
}
mean((y_test-yhat5)^2)







############################

## Example Diagnosis #######

############################

library(MCMCvis)

my_summary <-MCMCsummary(object = mcmc.output, round = 2, params = c("b0", "b1", "b2", "s2", "R"))
my_summary

MCMCtrace(object = mcmc.output,
          pdf = FALSE, # no export to PDF
          ind = TRUE, # separate density lines per chain
          params = "b1")
b0h = my_summary$mean[1]
b1h = my_summary$mean[2]
b2h = my_summary$mean[3]
s2h = my_summary$mean[4]

## Credibility Prediction ##
# i=1

# lambda_1 = exp(b0h + b1h * X[1, 2]+ b2h * X[1, 3])

# u1 = lambda_1 * exp(1/2*s2h)

# v1 = lambda_1 * exp(1/2*s2h)

# a1 = lambda_1^2 *( exp(2*s2h) - exp(s2h) )

# Z1 = 4*a1/(v1+4*a1)

# y_1 = y_train[1, ]

# prem_1 = Z1*mean(y_1) + (1-Z1)*u1





yhat5= rep(NA, I)





for(i in 1:I){
  lambda_i = exp(b0h+b1h*X[i,2]+b2h*X[i,3])
  uu = lambda_i *exp(1/2*s2h)
  vv = lambda_i *exp(1/2*s2h)
  aa =  lambda_i^2 * ( exp(2*s2h) - exp(s2h)) 
  Z = 4*aa/(vv+4*aa)
  yy = y_train[i, ]
  yhat5[i] = Z * mean(yy) + (1-Z)*uu
}

mean((y_test-yhat5)^2)

# Posterior samples

yhat5_MCMC= rep(NA, I)

for(i in 1:I){
  lambda_i = exp(b0h+b1h*X[i,2]+b2h*X[i,3])
  Ri_samples = c(mcmc.output$chain1[,i], mcmc.output$chain2[,i], mcmc.output$chain3[,i])
  yhat5_MCMC[i] =  lambda_i * mean( exp( Ri_samples ) )
  
}

mean((y_test-yhat5_MCMC)^2)