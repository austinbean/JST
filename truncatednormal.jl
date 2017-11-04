# truncated normal must be added and extended, I guess...

using Mamba

@everywhere distextend = quote

    using Distributions
    import Distributions: minimum, maximum, logpdf

    type TruncatedNormal <: ContinuousUnivariateDistribution
        mu::Float64
        sigma::Float64
        ll::Float64 
        ul::Float64 

        # TODO - add something like:
        # TruncatedNormal{T}(mu, sigma, ll, ul) where T =  @check_args(TruncatedNormal, ll < ul, sigma > zero(sigma); new{T}(mu, sigma, ll, ul)) 
    end

    # maximum and minimum methods 
    minimum(d::TruncatedNormal) = d.ll
    maximum(d::TruncatedNormal) = d.ul 

    # define the log pdf of the truncated normal 
    function logpdf(d::TruncatedNormal, x::Real)
        if x <= d.ll 
            return -Inf 
        elseif x >= d.ul 
            return -Inf 
        else 
            logpdf(Normal(d.mu, d.sigma), x) - log(d.sigma*( cdf(Normal(d.mu, d.sigma), (d.ul - d.mu)/d.sigma)  - cdf( Normal(d.mu, d.sigma), (d.ll - d.mu)/d.sigma) ) )
        end 
    end 
    
end

# Testing the Truncated dist... 

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


dat21 = Dict{Symbol, Any}(
  :xm => [1, 2, 3, 4, 5],
  :y => [1, 3, 3, 3, 5]
)


m21 = Model(

    y = Stochastic(
        (mu, s2) -> TruncatedNormal(mu, sqrt(s2), -10, 10), # would like this to be truncated.  Takes additional args anyway though...
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

initialv21 =[ Dict{Symbol, Any}(
        :y => [1, 2, 3, 4, 5],
        :β => 0.5,
        :s2 => 1.3
        )]

setsamplers!(m21, samp2)
setinputs!(m21, dat21)
setinits!(m21, initialv21)


sim1 = mcmc(m21, dat21, initialv21, 1000, burnin = 100, thin = 1, chains = 1)




