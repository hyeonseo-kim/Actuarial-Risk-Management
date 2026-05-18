#install.packages("nimble")
###########################
### Example 1 #############
###########################
library(nimble)

model <- nimbleCode({
  #likelihood 
  for(i in 1:n){
  y[i] ~ dpois(lambda=lambda)
  }
  # prior
  lambda ~ dlnorm(meanlog=1, taulog=0.1)
})

model

my.data <- list(y = c(0,0,3)) 
# z will not be used though
my.constants <-list(n=3)
parameters.to.save <- c("lambda")

# init1 <- list(lambda = 0.1)
# init2 <- list(lambda = 0.5)
# init3 <- list(lambda = 0.9)
# initial.values <- list(init1, init2, init3)
# initial.values <- function() list(lambda = runif(1,0,1))

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

str(mcmc.output)

dim(mcmc.output$chain1)
head(mcmc.output$chain1)

mean(mcmc.output$chain1[,"lambda"])
sd(mcmc.output$chain1[,"lambda"])
quantile(mcmc.output$chain1[,"lambda"], probs=c(2.5, 97.5)/100)

plot(density(mcmc.output$chain1[,"lambda"]))

# install.packages("MCMCvis")
library(MCMCvis)
MCMCsummary(object = mcmc.output, round = 2, params = "lambda")
MCMCplot(object = mcmc.output, 
         params = 'lambda')

MCMCtrace(object = mcmc.output,
          pdf = FALSE, # no export to PDF
          ind = TRUE, # separate density lines per chain
          params = "lambda")

lambda_samples <- c(mcmc.output$chain1[,'lambda'], 
                   mcmc.output$chain2[,'lambda'],
                   mcmc.output$chain3[,'lambda'])
quantile(lambda_samples, probs=c(2.5, 97.5)/100)
mean(lambda_samples)
# Compare the result with the following:
#qgamma(0.025, shape=3.1, rate=3.1)
#qgamma(0.975, shape=3.1, rate=3.1)



###########################
### Example 2 #############
###########################
library(nimble)
model <- nimbleCode({
  # likelihood
  for(i in 1:n){
    y[i] ~ dbern(prob = theta)
  }
  # prior
  theta ~ dbeta(1, 1)
})

model

my.data <- list(y = c(1, 0, 0, 1, 1)) 
# z will not be used though
my.constants <-list(n=5)
parameters.to.save <- c("theta")


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

# install.packages("MCMCvis")
library(MCMCvis)
MCMCsummary(object = mcmc.output, round = 2, params = "theta")
MCMCtrace(object = mcmc.output,
          pdf = FALSE, # no export to PDF
          ind = TRUE, # separate density lines per chain
          params = "theta")


# Comparable with 
qbeta(c(0.025, 0.975), 1+3, 1+2)


###########################
### Example 3: basic method
###########################

# Data generation: don't need to understand
set.seed(456)
n <- 100
x1 <- runif(n, 0, 10)
x2 <- rnorm(n, 5, 2)
x3 <- rbinom(n, 1, 0.5)
y  <- 2 + 0.8*x1 - 1.2*x2 + 3*x3 + rnorm(n, 0, 2)
data <- data.frame(x1, x2, x3, y)
head(data) # What you are given is a data.frame "data"

model <- nimbleCode({
  for (i in 1:n){
    mu[i] <- beta0 + beta1*x1[i] + beta2*x2[i] + beta3*x3[i]
    y[i] ~ dnorm(mean=mu[i], sd=sigma)
  }
  beta0 ~ dnorm(0,sd=3)
  beta1 ~ dnorm(0,sd=3)
  beta2 ~ dnorm(0,sd=3)
  beta3 ~ dnorm(0,sd=3)
  sigma ~ dgamma(shape = 1/3, rate=1/3)
})

my.data <- list(y = data$y) 
# z will not be used though
my.constants <-list(n=100, x1=data$x1, x2=data$x2, x3=data$x3)
parameters.to.save <- c("beta0", "beta1", "beta2", "beta3", "sigma")

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


MCMCsummary(object = mcmc.output, round = 2, params = c("beta0", "beta1", "beta2", "beta3", "sigma"))

lm(y~x1+x2+x3, data=data)  

# results in MCMCsummary and lm(y~x1+x2+x3, data=data) are not the same.

MCMCtrace(object = mcmc.output,
          pdf = FALSE, # no export to PDF
          ind = TRUE, # separate density lines per chain
          params = c("beta0","beta1"))


###
data <- data.frame(x1,x2,x3,y)
X = model.matrix(y~-1+x1+x2+x3, data = data)

###########################
### Example 3: inprod #####
###########################
# For the alternative way, define the matrix x
x <- as.matrix(data[, c("x1", "x2", "x3")])

# Nimble Code: Equivalent way using inprod
model <- nimbleCode({
  #likelihood 
  for(i in 1:n){
    mu[i] <- beta0 + inprod(beta[1:3], x[i, 1:3])
    y[i] ~ dnorm(mean=mu[i], sd=sigma)
    # mu[i] <- (beta[1:p] %*% x[i, 1:p])[1,1]
    # y[i] ~ dmnorm(beta0 + mu[i], cov = mycov)
  }
  # prior
  beta0 ~ dnorm(0, sd = 100)
  for(j in 1:3){
    beta[j] ~ dnorm(0, sd = 100)
  }
  sigma ~ dunif(0, 100) 
})


my.data <- list(y = data$y) 
# z will not be used though
my.constants <-list(n=100, x=x)
parameters.to.save <- c("beta0", "beta", "sigma")

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

MCMCsummary(object = mcmc.output, round = 2, params = c("beta0", "beta", "sigma"))

lm(y~x1+x2+x3, data=data)  

# results in MCMCsummary and lm(y~x1+x2+x3, data=data) are not the same.

MCMCtrace(object = mcmc.output,
          pdf = FALSE, # no export to PDF
          ind = TRUE, # separate density lines per chain
          params = c("beta0","beta1"))













###########################
### Example 3: matrix mult
###########################
# For the alternative way, define the matrix x
x <- as.matrix(data[, c("x1", "x2", "x3")])

# Nimble Code: Equivalent way using inprod
model <- nimbleCode({
  #likelihood 
  for(i in 1:n){
    mu[i] <- (beta[1:p] %*% x[i, 1:p])[1,1]
    y[i] ~ dnorm(beta0 + mu[i], sd = sigma)
  }
  # prior
  beta0 ~ dnorm(0, sd = 100)
  beta[1:p] ~ dmnorm(zeros[1:p], cov = mycov[1:p, 1:p])
  sigma ~ dunif(0, 100) 
})


my.data <- list(y = data$y) 
# z will not be used though
zeros = rep(0,3)
mycov = diag(3.0, 3)
my.constants <-list(n=100, x=x, mycov = mycov, p=3, zeros=zeros)
parameters.to.save <- c("beta0", "beta", "sigma")

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

MCMCsummary(object = mcmc.output, round = 2, params = c("beta0", "beta", "sigma"))

lm(y~x1+x2+x3, data=data)  

# results in MCMCsummary and lm(y~x1+x2+x3, data=data) are not the same.

MCMCtrace(object = mcmc.output,
          pdf = FALSE, # no export to PDF
          ind = TRUE, # separate density lines per chain
          params = c("beta0","beta1"))


# Example 4
library(nimble)
set.seed(456)
n  <- 100
x1 <- runif(n, 0, 10)
x2 <- rnorm(n, 5, 2)
x3 <- rbinom(n, 1, 0.5)
lambda <- exp(0.5 + 0.2*x1 - 0.1*x2 + 0.3*x3)
y  <- rpois(n, lambda)
data <- data.frame(x1, x2, x3, y)
head(data)

y
X = model.matrix( y ~x1+x2+x3, data=data)
dim(X)


model <- nimbleCode({
  #likelihood 
  for(i in 1:n){
    lambda[i] <- exp(inprod(X[i,1:p], beta[1:p])) 
    y[i] ~ dpois(lambda=lambda[i])
  }
  # prior
  beta[1] ~ dnorm(0, sd=3)
  beta[2] ~ dnorm(0, sd=3)  
  beta[3] ~ dnorm(0, sd=3)    
  beta[4] ~ dnorm(0, sd=3)     
})



my.data <- list(y = y) 
my.constants <-list(n=100, X=X, p=4)
parameters.to.save <- c("beta")


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


output<-MCMCsummary(object = mcmc.output, round = 2, params = c("beta"))

output[,"mean"]

lm(y~x1+x2+x3, data=data)  

# results in MCMCsummary and lm(y~x1+x2+x3, data=data) are not the same.

MCMCtrace(object = mcmc.output,
          pdf = FALSE, # no export to PDF
          ind = TRUE, # separate density lines per chain
          params = c("beta0","beta1"))





########################################
### Exercise 2: Poisson regression
########################################


library(faraway)
data(africa)
africa2 <- na.omit(africa)

Y  <- africa2$miltcoup
X  <- model.matrix(Y ~ parties + pollib, data = africa2)




########################################
### Example 6 for logistic regression
########################################

library(ISLR2)
head(Default)
X = model.matrix(default~ student+ balance+income,  data=Default)
Y = as.numeric(Default$default)-1
head(X)
Y
dim(X)


model <- nimbleCode({
  #likelihood 
  for(i in 1:n){
    t[i] <- inprod(X[i,1:p], beta[1:p])
    q[i] <- 1/(1+ exp(-t[i]) )
    y[i] ~ dbern(q[i])
  }
  # prior
  beta[1] ~ dnorm(0, sd=3)
  beta[2] ~ dnorm(0, sd=3)  
  beta[3] ~ dnorm(0, sd=3)    
  beta[4] ~ dnorm(0, sd=3)     
})



my.data <- list(y = Y) 
my.constants <-list(n=10000, X=X, p=4)
parameters.to.save <- c("beta")


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


output<-MCMCsummary(object = mcmc.output, round = 2, params = c("beta"))

output[,"mean"]
