# Tests for Truncated Normal Distribution:


# Testing the Truncated dist... 
# These tests all pass.
module Testing end
eval(Testing, distextend)
d = Testing.TruncatedNormal(0, 1, 0, 1)
Testing.minimum(d)
Testing.maximum(d)
Testing.insupport(d, 5.0)
Testing.insupport(d, 0.5)
Testing.logpdf(d, 0.5)
Testing.logpdf(d, -1.0)
Testing.logpdf(d, 2.0)


# Try to implement a sampler with it...


dat1 = Dict{Symbol, Any}(
  :x1 => [1, 2, 3, 4, 5],
  :y => [1, 3, 3, 3, 5],
)
dat1[:xm] = dat1[:x1]


# this works
m1 = Model(

    y = Stochastic(1,
        (mu, s2) -> MvNormal(mu, sqrt(s2)),  
        false
        ),

    mu = Logical(1,
         (xm, β)-> xm*β,
         false
        ),

    β = Stochastic(
        ()->TruncatedNormal(0, 1, 0, 0.5), # would like this to be truncated.  
        ),

    s2 = Stochastic(
         ()-> InverseGamma(0.001, 0.001) 
         )
    ) # of model 


samp2 = [NUTS([:β, :s2])]

initialv1 =[ Dict{Symbol, Any}(
        :y => dat1[:y],
        :β => 0.5,
        :s2 => 1.3
        )]

setsamplers!(m1, samp2)
setinputs!(m1, dat1)
setinits!(m1, initialv1)


sim1 = mcmc(m1, dat1, initialv1, 1000, burnin = 100, thin = 1, chains = 1)


# Second version - try to get the vector aspect:


m2 = Model(

    y = Stochastic(1,
        (mu, s2) -> 
        begin  # this block I think is going to let me apply the new univariate dist Truncated to the whole mu ???
            sigma = sqrt(s2)
            UnivariateDistribution[
            TruncatedNormal(mu[i], sigma, 0, 1,) for i = 1:length(mu) # truncated normal draws for |mu| parameters.  
            ]  
        end, 
        false
        ),

    mu = Logical(1,
         (xm, β)-> xm*β,
         false
        ),

    β = Stochastic(1,
        ()->MvNormal(2, sqrt(1000)),   
        ),

    s2 = Stochastic(
         ()-> InverseGamma(0.001, 0.001) 
         )
    ) # of model 

# Set Sampling Scheme:
    samp2 = [NUTS([:β, :s2])]

    setsamplers!(m2, samp2)


# Set Data: 
    dat2 = Dict{Symbol, Any}(
      :x1 => [1, 2, 3, 4, 5],
      :y => [1, 3, 3, 3, 5],
    )
    dat2[:xm] = hcat(ones(5), dat2[:x1])

    setinputs!(m2, dat2)


# Set Initial Values:
    initialv2 =[ Dict{Symbol, Any}(
            :y => dat2[:y],
            :β => [0.5,0.5],
            :s2 => 1.3
            )]

    setinits!(m2, initialv2)

# Run the simulation
    sim2 = mcmc(m2, dat2, initialv2, 1000, burnin = 100, thin = 1, chains = 1)

