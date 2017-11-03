


#Sample Data for Stan.  Following Geweke/Keane
"""
`DataGen1(n::Int64)`
Generates simple data.
"""
function DataGen1(n::Int64)
    srand(1) # sets random seed.
    outp = zeros(n, 4)
    β1 = 0.0
    β2 = 1.0
    β3 = -1.0
    for i = 1:n 
        cv1 = 1.0
        cv2 = randn()
        cv3 = randn()
        outp[i,1] = β1 + β2*randn() + β3*randn() + randn()
        outp[i,2] = cv1
        outp[i,3] = cv2 
        outp[i,4] = cv3 
    end 
    return outp 
end 


"""
`DataGen2(n::Int64)`
Same DGP as previous set, but now censors.
Censors data based on greater than 0 or not.
This is like the bivariate probit DGP, w/ augmentation.
"""
function DataGen2(n::Int64)
    srand(1) # sets random seed.
    outp = zeros(n,4)
    β1 = 0.0
    β2 = 1.0
    β3 = -1.0
    for i = 1:n 
        cv1 = 1
        cv2 = randn()
        cv3 = randn()
        err = randn()
        if max(β1*cv1 + β2*cv2 + β3*cv3 + err, 0.0) > 0
            outp[i,1] = 1
        else 
            outp[i,1] = 0
        end 
        outp[i,2] = cv1 
        outp[i,3] = cv2 
        outp[i,4] = cv3
    end 
    return outp 
end 

"""
`DataGen3(n::Int64)`
Same DGP as previous set, but now does not 
report the value of the latent variable v1.
You get either 1, 2, ..., choices depending on the value 
of the latent v_i
Be careful with the indexing scheme... 
"""
function DataGen3(n::Int64, choices::Int64)
    srand(1) # sets random seed.
    # doing this as... |choices| rows for each of n people.  Max will get a 1.
    # zeros(choices, covars , individuals)
    outp = zeros(choices, 5, n) # choices is number of options, 5 is one choice + 3 covariates + one error, n is number of individuals
    for i = 1:size(outp,3) # over individuals 
        for j = 1:size(outp,1) 
            outp[j,1,i] = 0       # choice made 
            outp[j,2,i] = 1       # constant 
            outp[j,3,i] = randn() # β2 × covariate - not multiplying by beta here. 
            outp[j,4,i] = randn() # β3 × covariate - not multiplying by beta here.
            outp[j,5,i] = randn() # error 
        end  
    end 
    return outp 
end 

"""
`MaxCh`
Iterates through the 3-d array to find the max choice in each block.
Note that the indexing of individuals, choices and covariates is dumb because 
of the way that it's easiest for me to think about.  
"""
function MaxCh(a::Array{Float64,3}, choices::Int64)
    # Indexing Scheme: a is (choices, choice + covariates + error, decisionmakers)
    # operates in place on A::Array{} to do the following...
    # for each block, of length choices, find the highest value of the covariates 
    # and put a 1 in that column.
    individuals = size(a,3)
    choices = size(a,1)
    covars = size(a,2)
    #outp = zeros(individuals*choices, covars)
    ix = 1
    β1 = 0.0
    β2 = 1.0
    β3 = -1.0
    for i = 1:size(a,3)         # individuals!
        mxi = 0 
        mxs = 0.0
        for k = 1:size(a,1)     # choices !
            if (β1*a[k,2,i]+β2*a[k,3,i]+β3*a[k,4,i]+a[k,5,i] > mxs)
                mxs = β1*a[k,2,i]+β2*a[k,3,i]+β3*a[k,4,i]+a[k,5,i]
                mxi = k  
            end  
        end 
        a[mxi,1,i] = 1
    end 
end 

"""
`Rshp`
Reshapes the 3-d array to a 2-d array.  
"""
function Rshp(a::Array{Float64,3})
    (individuals, covars, choices) = size(a)
    outp = zeros(individuals*choices, covars)
    ix = 1 
    for i = 1:size(a,3)               # individuals!
        for j = 1:size(a,1)           # choices!
            for k = 1:size(a,2)       # covariates!
                outp[ix,k] = a[j,k,i]
            end 
            ix += 1
        end 
    end 
    return outp 
end 


