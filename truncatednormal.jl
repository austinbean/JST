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
        # function TruncatedNormal(mu::Float64, sigma::Float64, ll::Float64, ul::Float64)
        #     ll <= ul || throw(ArgumentError("Lower Limit ll must be less than upper limit ul in Truncated Normal"))
        #     # ll < ul 
        #     new(mu, sigma, ll, ul)
        # end  
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


