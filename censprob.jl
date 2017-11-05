# probit with latent variables.  Two choice case...


using Mamba 

include("truncatednormal.jl")
include("DataGen.jl")

# Generates 20 censored data points: β1 + β2*randn() + β3*randn() + ε then reports 1 or 0 depending if >= 0 or not.
# β1 = 0.0, β2 = 1.0, β3 = -1.0
# x1, x2, x3 ~ Normal(0,1) iid.

inp1 = DataGen2(20); 

data = Dict{Symbol,Any}(
    :y => inp1[:,1],
    :x1 => inp1[:,2],
    :x2 => inp1[:,3],
    :x3 => inp1[:,4]
    )
data[:xm] = hcat(data[:x1], data[:x2], data[:x3])


#=
Some notes from examples... 
- in "bones" an intermediate vector can be created in the main stochastic node to hold some values.  
- this may require defining my own sampler.  See the tutorial on that, I think.  
=#

m1 = Model(

    y = Stochastic(1, # this is 1-dimensional since β1, β2, β3 all appear 
        (mu, sigma, ll, ul) -> [TruncatedNormal(mu,sqrt(sigma) ,ll ,ul) for i =1:length(mu)],
        false),

#=
To do: reorganize the matrix inp1.  Maybe sort in advance.
Design the sampler.... this should do something like in two blocks
draw conditional on previous val.  I think this can be done.
Create an intermediate vector in the sampler, I think.  
=#


    mu = Logical(1,
        (xm,β) -> xm*β,
        false),

    ll = Logical(
        () -> 0
        ),

    ul = Logical(
        () -> 10
        ),

    β = Stochastic(1,
        () -> MvNormal(3, sqrt(1000)) # draws three independent normal parameters β1 - β3 
        false,
        ),

     
    sig = Stochastic(
        ()->InverseGamma(0.01, 0.01) # not doing anything with this one yet
        )
    )







