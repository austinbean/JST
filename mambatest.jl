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
        ()->MvNormal(3, sqrt(1000)),
        false 
        ),

    s2 = Stochastic(1,
         ()-> InverseGamma(0.001, 0.001),
         false)


    ) # of model 

# Initial values 
# NB: doing this for i = 1:n creates n copies so that n chains can be run.  

initialv =[ Dict{Symbol, Any}(
        :y => dat[:y],
        :β => [1.0, 2.0, 3.0],
        :s2 => [3.0]
        )]



# Sampling scheme...

samp1 = [NUTS([:β, :s2])]

setsamplers!(m1, samp1)

sim = mcmc(m1, dat, initialv, 1000, burnin = 100, thin = 1, chains = 1)








