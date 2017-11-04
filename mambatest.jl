# Mamba.jl test...

using Mamba 

include("DataGen.jl")

#=
Generates 50 observations of the model

y_i = β1 + β2*x_2i + β3*x_3i + ε_i

where:
β1 = 0
β2 = 1
β3 = -1
and x_2, x_3, ε ∼ N(0,1)

=#

test1 = DataGen1(50)

# Save the data 
    dat = Dict{Symbol, Any}()
    dat[:y] = test1[:,1]
    dat[:x1] = test1[:,2]
    dat[:x2] = test1[:,3]
    dat[:x3] = test1[:,4]
    dat[:xm] = hcat(dat[:x1], dat[:x2], dat[:x3])

# Initial values



m1 = Model(

    y = Stochastic(1,
        (mu, s2) -> MvNormal(mu, sqrt.(s2)),
        false
        ),

    mu = Logical(1,
         (xm, β)-> xm*β,
         false
        ),

    β = Stochastic(1,
        ()->MvNormal(3, sqrt(1000)), # s2??  
        false 
        ),

    s2 = Stochastic( # a 1 here implies a dimension for array nodes, so this must be 0 for a scalar.
         ()-> InverseGamma(0.001, 0.001), # note this one can't have "1," at the top line - not sure why...?  maybe that's a higher dim object??
         )


    ) # of model 




# Sampling scheme...

samp1 = [NUTS([:β, :s2])]


# Initial values 
# NB: doing this for i = 1:n creates n copies so that n chains can be run.  

initialv =[ Dict{Symbol, Any}(
        :y => dat[:y],
        :β => [1.0, 2.0, 3.0],
        :s2 => 1.3
        )]


# calling these by hand may give better error messages?  yes - these are very useful.  
setsamplers!(m1, samp1)
setinputs!(m1, dat)
setinits!(m1, initialv)
#simulate!(m1) # this function doesn't work - deprecated perhaps?


sim1 = mcmc(m1, dat, initialv, 1000, burnin = 100, thin = 1, chains = 1)



# Try a second model...
# this model features censored data...
# requires latent variable

# simple w/ truncated normal:




test21 = DataGen2(50)

dat21 = Dict{Symbol, Any}()
    dat21[:y] = test21[:,1]
    dat21[:x3] = test21[:,4]
    dat21[:xm] = dat21[:x3]
    


m21 = Model(

    y = Stochastic(1,
        (mu, s2) -> TruncatedNormal(mu, sqrt(s2), 0, 10), # would like this to be truncated.  Takes additional args anyway though...
        false
        ),

    mu = Logical(1,
         (xm, β)-> xm*β,
         false
        ),

    β = Stochastic(
        ()->Normal(1, sqrt(1000))
        ),

    s2 = Stochastic(
         ()-> InverseGamma(0.001, 0.001), # note this one can't have "1," at the top line - not sure why...?  maybe that's a higher dim object??
         )
    ) # of model 


samp2 = [NUTS([:β, :s2])]
# Initial values 
# NB: doing this for i = 1:n creates n copies so that n chains can be run.  

initialv21 =[ Dict{Symbol, Any}(
        :y => dat[:y],
        :β => 1.0,
        :s2 => 1.3
        )]

setsamplers!(m21, samp2)
setinputs!(m21, dat21)
setinits!(m21, initialv21)
#simulate!(m1) # this function doesn't work - deprecated perhaps?


sim1 = mcmc(m21, dat21, initialv21, 1000, burnin = 100, thin = 1, chains = 1)


# Trying with more complicated...




test2 = DataGen2(50)

dat2 = Dict{Symbol, Any}(
    dat2[:y] = test2[:,1]
    dat2[:x1] = test2[:,2]
    dat2[:x2] = test2[:,3]
    dat2[:x3] = test2[:,4]
    dat2[:xm] = hcat(dat2[:x1], dat2[:x2], dat2[:x3])
    )


m2 = Model(

    y = Stochastic(1,
        (mu, s2) -> MvNormal(mu, sqrt.(s2)),
        false
        ),

    mu = Logical(1,
         (xm, β)-> xm*β,
         false
        ),

    β = Stochastic(1,
        ()->MvNormal(3, sqrt(1000)), # s2??  
        false 
        ),

    s2 = Stochastic(
         ()-> InverseGamma(0.001, 0.001), # note this one can't have "1," at the top line - not sure why...?  maybe that's a higher dim object??
         )


    ) # of model 




